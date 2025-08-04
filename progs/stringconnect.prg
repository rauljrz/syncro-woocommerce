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
		
		loDataConnection = IIF(UPPER(tcTipoDB)='CONTABLE',;
							 THIS.ReadContable(),;
							 THIS.ReadComercial())
							 
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
	FUNCTION setSistema(toSistema)
	* Carga en el Objeto Sistema (Legacy) los datos para conectarse a contable
	*----------------------------------------------------------------------------*
		loContable = THIS.ReadContable()

		IF PEMSTATUS(toSistema, 'DriverODBC',5)
			ADDPROPERTY(toSistema, 'DriverODBC')
		ENDIF
		
		WITH toSistema
			.DriverODBC= loContable.DB_CONNECTION
			.bdservidor= loContable.DB_HOST
			.bdpuerto  = loContable.DB_PORT
			.bd        = loContable.DB_DATABASE
			.bdusuario = loContable.DB_USERNAME
			.bdpassword= loContable.DB_PASSWORD
		ENDWITH
		RETURN toSistema
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION ReadContable()
	*  Lee desde el .ini la configuracion para la conexion a CONTABLE
	*----------------------------------------------------------------------------*
		WITH NEWOBJECT('iniFile', 'progs\inifile.prg','',THIS.FileIni)
			.set_password('','only')
			lcDriverID  = .GET([DATABASE], 'DB_CONNECTION',SPACE(100))
			lcEncrypt   = .GET([CONFIG], 'ENCRYPT', 'OFF')

			IF lcEncrypt != 'OFF' THEN
				.set_password(_SCREEN.password_cipher)
			ENDIF
			lcServerID= ALLTRIM(.GET([CONTABLE], 'DB_HOST',SPACE(100)))
			lcNmroPort= ALLTRIM(.GET([CONTABLE], 'DB_PORT'))
			lcDataBase= ALLTRIM(.GET([CONTABLE], 'DB_DATABASE',SPACE(100)))
			lcUserName= ALLTRIM(.GET([CONTABLE], 'DB_USERNAME',SPACE(100)))
			lcPassWord= ALLTRIM(.GET([CONTABLE], 'DB_PASSWORD',SPACE(100)))
		ENDWITH

		loContable = NEWOBJECT('EMPTY')
		ADDPROPERTY(loContable, 'DB_CONNECTION', lcDriverID)
		ADDPROPERTY(loContable, 'DB_HOST'      , lcServerID)
		ADDPROPERTY(loContable, 'DB_PORT'      , lcNmroPort)
		ADDPROPERTY(loContable, 'DB_DATABASE'  , lcDataBase)
		ADDPROPERTY(loContable, 'DB_USERNAME'  , lcUserName)
		ADDPROPERTY(loContable, 'DB_PASSWORD'  , lcPassWord)		
		RETURN loContable
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