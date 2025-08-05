*- Test de la calse iniFile
IF .T. THEN
	lcFileIni = SYS(5)+CURDIR()+'checkversion.ini'
	lcPathServer='http://rauljrz.me/update_app/xiram/'
	lcSection = 'UPDATE'
	lcEntry   = 'localversion'
	lcEntry   = 'pathserver'
	lcEntry   = 'last_check'

	loIni = CREATEOBJECT('iniFile', lcFileIni)
	
*	lcPathServer = loIni.GET(lcSection, lcEntry)
	lcLast_Check = loIni.GET(lcSection, lcEntry)
*	lnVersion = VAL(TRANSFORM(loIni.GET(lcSection, lcEntry)))
	lcBase64 = STRCONV(lcPathServer,13)
	lcEntry  = 'pathserver'
	loIni.SET(lcSection, lcEntry, lcBase64)
	lcEntry   = 'last_check'
	loIni.SET(lcSection, lcEntry, '2021.01.04')	

*	? lnVersion
	SET STEP ON 
ENDIF

*
*|--------------------------------------------------------------------------
*| iniFile
*|--------------------------------------------------------------------------
*|
*| A class that allows easy read/write access to INI files.
*|  The name of the INI file to read/write to. Initialized in Init(), 
*|  but can be overridden in Set() or Get().
*| Author......: Raul Jrz (raul.jrz@gmail.com)
*| Created.....: 2021.01.08 - 15.50
*| Purpose.....: ini file manager
*| Web site....: http://rauljrz.me
*|
*| 
*| Revisions...: v1.00
*|
*| LICENSE:
*|----------------------------------------------------------------------------
*| "THE BEER-WARE LICENSE" (Revision 42):
*|----------------------------------------------------------------------------
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS iniFile AS CUSTOM
*
*-----------------------------------------------------------------------------------*
	HIDDEN ;
		CLASSLIBRARY,COMMENT, ;
		BASECLASS,CONTROLCOUNT, ;
		CONTROLS,OBJECTS,OBJECT,;
		HEIGHT,HELPCONTEXTID,LEFT,NAME, ;
		PARENT,PARENTCLASS,PICTURE, ;
		TAG,TOP,WHATSTHISHELPID,WIDTH

	bRelanzarThrow = .T. &&Relanza la excepcion al nivel superior
	PROTECTED inifile &&
	PROTECTED password
	*
	*----------------------------------------------------------------------------*
	FUNCTION Set_Password(tcPassword, tcTemporal)
	* Setea un password para la grabacion de datos
	*----------------------------------------------------------------------------*
		THIS.password = tcPassword

		IF !PEMSTATUS(_SCREEN,'password_cipher',5) THEN
			_SCREEN.AddProperty('password_cipher', '')
		ENDIF
		
		IF VARTYPE(tcTemporal)='C' AND;
			(LOWER(tcTemporal)='only' OR LOWER(tcTemporal)='off') THEN
			RETURN
		ENDIF
		
		_SCREEN.password_cipher = tcPassword
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION SET(tcSection, tcEntryName, teValue)
	* Wrrite the data to the .ini file
	*----------------------------------------------------------------------------*
		LOCAL lcINIFile, lcValue, leNewValue
		
		TRY
			*-- Make sure we passed in a value to store
			IF PCOUNT() < 3 THEN
				THROW 'Faltan parametros al set() del .ini'
			ENDIF

			*-- Convert value to character if necessary
			lcValue  = IIF(VARTYPE(teValue)  = "C", teValue, TRANSFORM(teValue))
			
			IF VARTYPE(THIS.password)='C' AND !EMPTY(THIS.password) THEN
				lcValue= THIS.encrypt(lcValue, THIS.password)
			ENDIF
			
			*-- Use tcINIFile if passed
			lcINIFile= THIS.inifile

			IF UPPER(lcINIFile) = "WIN.INI" THEN
				lnResult = WriteProfileString(tcSection, tcEntryName, lcValue)
			ELSE
				lnResult = WritePrivateProfileString(tcSection, tcEntryName, lcValue, lcINIFile)
			ENDIF
		CATCH TO loEx
			THIS.catchException(loEx)
		ENDTRY
		RETURN (lnResult>=1)
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	FUNCTION decrypt(leValue, tcPassword)
	*
	*----------------------------------------------------------------------------*
		RETURN decrypt(leValue, tcPassword)
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION encrypt(leValue, tcPassword)
	*
	*----------------------------------------------------------------------------*
		RETURN encrypt(leValue, tcPassword)
	ENDFUNC	
	*
	*----------------------------------------------------------------------------*
	FUNCTION getOrCreate(tcSection, tcEntryName, teDefault)
	* Si no existe la entrada en el .ini, lo crea con el valor por default.
	*----------------------------------------------------------------------------*
		LOCAL leValue
		TRY
			leValue = THIS.GET(tcSection, tcEntryName, '')
			
			IF EMPTY(leValue) THEN
				THIS.SET(tcSection, tcEntryName, teDefault)
				leValue = teDefault
			ENDIF
		CATCH TO loEx
			THIS.catchException(loEx)
		ENDTRY
		RETURN leValue
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION GET(tcSection, tcEntryName, teDefault)
	* Reads the .ini file searching for a particular entry.
	*----------------------------------------------------------------------------*
		LOCAL lcINIFile, lcValue, lcBuffer, leEntryValue, lnNumBytes

		*-- Setup default value
		leEntryValue = IIF(VARTYPE(teDefault)='U', '', teDefault)

		*-- Use tcINIFile if passed
		lcINIFile= THIS.inifile
		lcBuffer = SPACE(255) + CHR(0)

		IF UPPER(lcINIFile) = "WIN.INI" THEN
			lnNumBytes = GetProfileString(tcSection, tcEntryName,;
				"", @lcBuffer, LEN(lcBuffer))
		ELSE
			lnNumBytes = GetPrivateProfileString(tcSection, tcEntryName, "", ;
				@lcBuffer, LEN(lcBuffer), lcINIFile)
		ENDIF

		IF lnNumBytes = 0 THEN
			RETURN leEntryValue
		ELSE
			leValue = LEFT(lcBuffer, lnNumBytes)
			RETURN IIF(VARTYPE(THIS.password)='C' AND !EMPTY(THIS.password),;
						THIS.decrypt(leValue, THIS.password),;
						leValue)
		ENDIF
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	FUNCTION INIT (tcINIFile)
	* Initialize the necessary libraries.
	*----------------------------------------------------------------------------*
		IF VARTYPE(tcINIFile)!='C' OR LEN(ALLTRIM(tcINIFile))<4 THEN
			THROW 'Debe especificar un archivo de configuración'
		ENDIF
		*-- DECLARE DLL statements for reading/writing to private INI files
		DECLARE INTEGER GetPrivateProfileString IN Win32API ;
			STRING cSection, STRING cKey, STRING cDefault, STRING @cBuffer, ;
			INTEGER nBufferSize, STRING cINIFile

		DECLARE INTEGER WritePrivateProfileString IN Win32API ;
			STRING cSection, STRING cKey, STRING cValue, STRING cINIFile

		*-- DECLARE DLL statements for reading/writing to WIN.INI file
		DECLARE INTEGER GetProfileString IN Win32API ;
			STRING cSection, STRING cKey, STRING cDefault, ;
			STRING @cBuffer, INTEGER nBufferSize

		DECLARE INTEGER WriteProfileString IN Win32API ;
			STRING cSection, STRING cKey, STRING cValue

		THIS.iniFile = tcIniFile
		THIS.password = IIF(PEMSTATUS(_SCREEN,'password_cipher',5),;
								_SCREEN.password_cipher,;
								'')
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	PROTECTED PROCEDURE iniFile_ASSIGN (teNewValue)
	* magic method to assign value in property "iniFile"
	*----------------------------------------------------------------------------*
		TRY
			THIS.inifile = IIF(VARTYPE(teNewValue)='C', teNewValue, "WIN.INI")
			IF THIS.inifile!="WIN.INI" AND !FILE(THIS.inifile) THEN
				THROW 'No existe el archivo '+THIS.inifile
			ENDIF
		CATCH TO loEx
			THIS.catchException(loEx)
		ENDTRY
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE set_iniFile(teNewValue)
	* assign value in property "iniFile"
	*----------------------------------------------------------------------------*
		THIS.inifile = teNewValue
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROTECTED FUNCTION catchexception(toEx)
	* Evento ejecutado cuando ocurre una exception
	*----------------------------------------------------------------------------*
		LOCAL lbReThrow
		lbReThrow = IIF(VARTYPE(THIS.bRelanzarThrow )='L',;
							 THIS.bRelanzarThrow, .F.;
						)

		THIS.oException  = toEx
		THIS.errorNumber = toEx.ErrorNo
		THIS.errorMessage= "Error!"+chr(13)+;
			               "Messages.#:"+toEx.Message+chr(13)+;
			               "Error....#:"+TRANSFORM(toEx.ErrorNo)+chr(13)+;
			               "Line.....#:"+TRANSFORM(toEx.LineNo)+chr(13)+;
				           "Error....#:"+TRANSFORM(toEx.LineContents)

		*IF VARTYPE(toEx.UserValue)!='C' THEN
			loEx = toEx
			=NEWOBJECT('catchException','catchException.PRG','', lbReThrow)  &&Guardo y relanzo la excepcion
		*ENDIF
	ENDFUNC
ENDDEFINE
