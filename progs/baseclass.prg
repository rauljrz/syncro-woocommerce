#INCLUDE include\default.h
*
*|--------------------------------------------------------------------------
*| baseClass
*|--------------------------------------------------------------------------
*|
*| Archivo principal del sistema
*| Author......: (raul.jrz@gmail.com) 
*| Created.....: 
*| Purpose.....: Clase base para el proyecto de eCommerce
*|
*| Revisions...: V1.0
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS baseClass AS Custom
*
*-----------------------------------------------------------------------------------*
	HIDDEN ;
		CLASSLIBRARY,COMMENT, ;
		BASECLASS,CONTROLCOUNT, ;
		CONTROLS,OBJECTS,OBJECT,;
		HEIGHT,HELPCONTEXTID,LEFT,NAME, ;
		PARENT,PARENTCLASS,PICTURE, ;
		TAG,TOP,WHATSTHISHELPID,WIDTH
	#INCLUDE include\default.h
	bRelanzarThrow = .T. &&Relanza la excepcion al nivel superior

	PROTECTED oLog, oJson, oDB, nameFile_Log
	oJson = .NULL.
	oLog  = .NULL.
	oDB   = .NULL.
	nameFile_Log = '' &&Nombre del archivo que lleva el registro de la clase

	Verbose = .F. &&If setted to TRUE, progress info will be shown.
	isLogger= .T. &&If setted to TRUE, records a log of the processes.
	
	PROTECTED responseString, responseJson
	PROTECTED errorMessage, errorNumber
	
	#DEFINE crlf CHR(13)+CHR(10)
	*----------------------------------------------------------------------------*
 	PROCEDURE Init()
	* 
	*----------------------------------------------------------------------------*
		THIS.oLog = NEWOBJECT('factory','progs\factory.prg','','logger')
		THIS.isLogger = IS_LOGGER  && Contante definida en default.h
		SET CONSOLE OFF
		SET POINT TO '.'
		SET SEPARATOR TO ','
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	FUNCTION verbose_Assign(tbNewVal)
	*
	*----------------------------------------------------------------------------*
		THIS.Verbose = IIF(VARTYPE(tbNewVal)=='L',tbNewVal,THIS.Verbose)
	ENDFUNC
	*
	*-----------------------------------------------------------------------*
	PROCEDURE get(tcProperty)
	* Retorna el contenido de la propiedad solicitada
	*-----------------------------------------------------------------------*
		LOCAL leReturn
		TRY
			THIS.checkProperty(tcProperty)
			leReturn = THIS.&tcProperty
		CATCH TO loEx
			THIS.catchexception(loEx)
		ENDTRY
		RETURN leReturn
	ENDPROC
	*
	*-----------------------------------------------------------------------*
	PROCEDURE set(tcProperty, teValue)
	* Asigna un valor a una propiedad.
	*-----------------------------------------------------------------------*
		LOCAL lbReturn
		lbReturn = .F.
		TRY
			THIS.checkProperty(tcProperty)
			THIS.&tcProperty = teValue
			lbReturn = .T.
		CATCH TO loEx
			THIS.catchexception(loEx)
		ENDTRY
		RETURN lbReturn
	ENDPROC
	*
	*-----------------------------------------------------------------------*
	PROTECTED PROCEDURE checkProperty(tcProperty)
	* Verifica que exista la propiedad
	*-----------------------------------------------------------------------*
		RETURN PEMSTATUS(THIS, tcProperty, 5)
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	FUNCTION isError()
	* Devuelve si hubo un error en la ultima accion
	*----------------------------------------------------------------------------*
		RETURN (!ISNULL(THIS.errorNumber) AND !EMPTY(THIS.errorNumber))
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION isSuccess()
	* Devuelve si fue existosa la ultima accion
	*----------------------------------------------------------------------------*
		RETURN !THIS.isError()
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION getError()
	* Devuelve un array con el error o empty si todo esta ok
	*----------------------------------------------------------------------------*
		lbReturn=.null.
		IF THIS.isError() THEN
			lbReturn=TRANSFORM(THIS.errorNumber) +' - '+THIS.errorMessage
		ENDIF
		RETURN lbReturn
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	PROTECTED FUNCTION catchexception(toEx)
	* Evento ejecutado cuando ocurre una exception
	*----------------------------------------------------------------------------*
		SYS(1104) && Purges memory cached by programs and data, 
				  && and clears and refreshes buffers for open tables.
		THIS.bRelanzarThrow = IIF(VARTYPE(THIS.bRelanzarThrow )='L',;
							 	THIS.bRelanzarThrow, .F.;
							)

		THIS.errorNumber = toEx.ErrorNo
		THIS.errorMessage= "Error!"+chr(13)+;
			               "Messages.#:"+toEx.Message+chr(13)+;
			               "Error....#:"+TRANSFORM(toEx.ErrorNo)+chr(13)+;
			               "Line.....#:"+TRANSFORM(toEx.LineNo)+chr(13)+;
				           "Error....#:"+TRANSFORM(toEx.LineContents)

		IF toEx.ErrorNo = 2071 THEN
			THIS.showVerbose(ALLTRIM(toEx.UserValue))
		ENDIF

		lolog = .NULL.
		IF PEMSTATUS(THIS,'oLog',5) AND !ISNULL(THIS.olog) THEN
			lolog = THIS.olog
		ENDIF
		
		loEx = toEx && con el solo fin de que pase a CatchException
		=NEWOBJECT('catchException','progs\catchException.prg','',THIS.bRelanzarThrow, lolog)
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION showVerbose
	LPARAMETERS tcMessage
	*
	*----------------------------------------------------------------------------*
		IF THIS.Verbose
			WAIT SUBSTR(ALLTRIM(tcMessage),1,100) WINDOW NOWAIT
		ENDIF
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	PROTECTED FUNCTION writelog
	LPARAMETERS tcLeyenda
	* 
	*----------------------------------------------------------------------------*
		IF !THIS.isLogger THEN
			RETURN
		ENDIF
		
		THIS.oLog.isLogger = THIS.isLogger
		THIS.oLog.setNameFile(THIS.nameFile_log)
		THIS.oLog.notice(crlf + tcLeyenda + crlf)
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	PROTECTED FUNCTION writelog_Secret
	LPARAMETERS tcLeyenda
	* 
	*----------------------------------------------------------------------------*
		IF !'raul'$LOWER(SYS(0)) THEN
			RETURN
		ENDIF
		
		THIS.oLog.isLogger = THIS.isLogger
		THIS.oLog.setNameFile(THIS.nameFile_log)
		THIS.oLog.notice(crlf + tcLeyenda + crlf)
	ENDFUNC
ENDDEFINE