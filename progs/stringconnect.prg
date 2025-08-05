#INCLUDE include\default.h
*
*|--------------------------------------------------------------------------
*| StringConnect.prg
*|--------------------------------------------------------------------------
*|
*| Lee del archivo config.ini la configuracion para la conexion a la db
*| Author.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 25.07.01
*| Purpose.....: Cargar las conexiones a la base de datos.
*|	
*| Revisions...: v1.00 
*| Basado en...: 
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS StringConnect AS Custom
*
*-----------------------------------------------------------------------------------*
	HIDDEN ;
		CLASSLIBRARY,COMMENT, ;
		BASECLASS,CONTROLCOUNT, ;
		CONTROLS,OBJECTS,OBJECT,;
		HEIGHT,HELPCONTEXTID,LEFT,NAME, ;
		PARENT,PARENTCLASS,PICTURE, ;
		TAG,TOP,WHATSTHISHELPID,WIDTH

	PROTECTED FileIni
	FileIni=''
	*----------------------------------------------------------------------------*		
	FUNCTION INIT
	*
	*----------------------------------------------------------------------------*
		THIS.FileIni = SYS(5)+CURDIR()+CONFIG_INI
	ENDFUNC
	*
	*----------------------------------------------------------------------------*		
	FUNCTION getFileIni
	*
	*----------------------------------------------------------------------------*
		RETURN THIS.FileIni
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION getString(tcTipoDB)
	* Devuelve el string para conectarse a la base de datos
	*----------------------------------------------------------------------------*
		IF !INLIST(UPPER(tcTipoDB),'CONTABLE','COMERCIAL')
			*MESSAGEBOX('Las posibles opciones son: CONTABLE o COMERCIAL', 0, 'ERROR')
			RETURN .F.
		ENDIF
		
		loDataConnection = THIS.ReadComercial()
							 
		TEXT TO lcStringConnect TEXTMERGE NOSHOW PRETEXT 15
			DRIVER={<<loDataConnection.DB_CONNECTION>>};
			SERVER=<<loDataConnection.DB_HOST>>;
			UID=<<loDataConnection.DB_USERNAME>>;
			PWD=<<loDataConnection.DB_PASSWORD>>;
			DATABASE=<<loDataConnection.DB_DATABASE>>;
			PORT=<<loDataConnection.DB_PORT>>;
			OPTIONS=131329;
		ENDTEXT
		RETURN lcStringConnect
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION ReadComercial()
	* Lee desde el .ini la configuracion para la conexion a COMERCIAL
	*----------------------------------------------------------------------------*
		WITH NEWOBJECT('iniFile', 'progs\inifile.prg','',THIS.FileIni)
			.set_password('','only')
			lcDriverID  = .GET([DATABASE], 'DB_CONNECTION',SPACE(100))
			lcEncrypt   = .GET([CONFIG], 'ENCRYPT', 'OFF')

			IF lcEncrypt != 'OFF' THEN
				.set_password(_SCREEN.password_cipher)
			ENDIF
			lcServerID= ALLTRIM(.GET([COMERCIAL], 'DB_HOST',SPACE(100)))
			lcNmroPort= ALLTRIM(.GET([COMERCIAL], 'DB_PORT'))
			lcDataBase= ALLTRIM(.GET([COMERCIAL], 'DB_DATABASE',SPACE(100)))
			lcUserName= ALLTRIM(.GET([COMERCIAL], 'DB_USERNAME',SPACE(100)))
			lcPassWord= ALLTRIM(.GET([COMERCIAL], 'DB_PASSWORD',SPACE(100)))
		ENDWITH

		loComercial = NEWOBJECT('EMPTY')
		ADDPROPERTY(loComercial, 'DB_CONNECTION', lcDriverID)
		ADDPROPERTY(loComercial, 'DB_HOST'      , lcServerID)
		ADDPROPERTY(loComercial, 'DB_PORT'      , lcNmroPort)
		ADDPROPERTY(loComercial, 'DB_DATABASE'  , lcDataBase)
		ADDPROPERTY(loComercial, 'DB_USERNAME'  , lcUserName)
		ADDPROPERTY(loComercial, 'DB_PASSWORD'  , lcPassWord)		
		RETURN loComercial
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	* PRIVATE define
	*
	*----------------------------------------------------------------------------*
ENDDEFINE