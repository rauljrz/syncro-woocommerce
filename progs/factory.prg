#INCLUDE include\default.h
*|--------------------------------------------------------------------------
*| factory
*|--------------------------------------------------------------------------
*|
*| factory of classes. It works from DI & IoC ensuring to create only one instance per class
*| Author.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.08.04 - 19.38
*| Purpose.....: Dependency Injection (DI) & Inversion of Control (IoC)
*|
*| Revisions...: V1.0
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS factory AS CUSTOM
*
*-----------------------------------------------------------------------------------*
	HIDDEN ;
		CLASSLIBRARY,COMMENT, ;
		BASECLASS,CONTROLCOUNT, ;
		CONTROLS,OBJECTS,OBJECT,;
		HEIGHT,HELPCONTEXTID,LEFT,NAME, ;
		PARENT,PARENTCLASS,PICTURE, ;
		TAG,TOP,WHATSTHISHELPID,WIDTH
	HIDDEN ClassInstance
	#DEFINE CLIENT_CLASS "classinstance"
	
	*----------------------------------------------------------------------------*
	FUNCTION INIT(tcClassName AS STRING) AS void
	* Inicializa solo si es la primera vez. En las siguientes usa la instanciada.
	*----------------------------------------------------------------------------*
		THIS.ClassInstance = tcClassName
		TRY
			=REMOVEPROPERTY(_SCREEN, CLIENT_CLASS)
		ENDTRY
	
		loInstance = .null.
		IF PEMSTATUS(_SCREEN, tcClassName, 5) THEN
			IF TYPE('_SCREEN.'+tcClassName)!='O' THEN
				REMOVEPROPERTY(_SCREEN, tcClassName)
			ELSE
				loInstance = EVALUATE("_SCREEN." + ALLTRIM(tcClassName))
			ENDIF
		ENDIF
			
		IF !ISNULL(loInstance) THEN
			RETURN loInstance
		ENDIF

		TRY		
			DO CASE
				CASE LOWER(tcClassName) == LOWER('Logger') 
					loInstance = NEWOBJECT('logger','progs\logger.prg')
					loInstance.SetLevel(4)  && Graba desde el nivel 4 (Notice) hasta el 1 (Critical)
					loInstance.isLogger=IS_LOGGER   && Si es .F. No graba nada.

				CASE LOWER(tcClassName) == LOWER('json') 
					loInstance =  NEWOBJECT(tcClassName,'progs\json.prg')

				CASE LOWER(tcClassName) == LOWER('dbcontable') 
					loInstance =  NEWOBJECT('db','progs\db.prg','','CONTABLE')
					loInstance.isLogger=IS_LOGGER  

				CASE LOWER(tcClassName) == LOWER('dbcomercial') 
					loInstance =  NEWOBJECT('db','progs\db.prg','','COMERCIAL')
					loInstance.isLogger=IS_LOGGER  
																		
				OTHERWISE
					loInstance = NEWOBJECT(tcClassName)
			ENDCASE
			
			_SCREEN.ADDPROPERTY(tcClassName,  loInstance)
		CATCH TO loEx
			=NEWOBJECT('catchException','progs\catchException.prg','',.T.)
		ENDTRY
		RETURN loInstance
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION This_Access(tcAttribute AS STRING) AS OBJECT
	* Busca si existe en el contenedor la clase instanciada y la devuelve.
	*----------------------------------------------------------------------------*
		LOCAL loCallBack AS OBJECT
*!*			TRY
			IF INLIST(LOWER(tcAttribute), CLIENT_CLASS)
				loCallBack = THIS
			ELSE
*!*					IF TYPE('_SCREEN.'+tcAttribute )!='O' THEN
*!*						WAIT WINDOWS 'No es un objeto '+tcAttribute+' (in factory)'
*!*						SUSPEND
*!*						REMOVEPROPERTY(_SCREEN, THIS.ClassInstance)
*!*					ENDIF
				loCallBack = EVALUATE("_SCREEN." + THIS.ClassInstance)
			ENDIF
			IF ISNULL(loCallBack) THEN
				REMOVEPROPERTY(_SCREEN, THIS.ClassInstance)
				WAIT WINDOWS 'No instanciado'
				SET STEP ON
			ENDIF
*!*			CATCH TO loEx
*!*				=NEWOBJECT('catchException','progs\catchException.prg','',.T.)
*!*			ENDTRY
		RETURN loCallBack 
	ENDFUNC
ENDDEFINE
