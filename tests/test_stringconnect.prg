*
*|--------------------------------------------------------------------------
*| Test_StringConnect.prg
*|--------------------------------------------------------------------------
*|
*| Prueba de la clase StringConnect
*| Author.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.08.04 - 19.38
*| Purpose.....: Prueba de la clase StringConnect
*|	
*| Revisions...: v1.00 
*| Basado en...: 
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS Test_StringConnect AS TestBase
*
*-----------------------------------------------------------------------------------*
	HIDDEN ;
		CLASSLIBRARY,COMMENT, ;
		BASECLASS,CONTROLCOUNT, ;
		CONTROLS,OBJECTS,OBJECT,;
		HEIGHT,HELPCONTEXTID,LEFT,NAME, ;
		PARENT,PARENTCLASS,PICTURE, ;
		TAG,TOP,WHATSTHISHELPID,WIDTH

	PROTECTED ;
		StringConnectObj, ;
		TestConfigFile

	StringConnectObj = .NULL.
	TestConfigFile = ''
	
	*----------------------------------------------------------------------------*		
	FUNCTION INIT
	*
	*----------------------------------------------------------------------------*
		DODEFAULT()
		THIS.TestConfigFile = SYS(5) + CURDIR() + 'test_config.ini'
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION SetUp()
	* Configuración antes de cada prueba
	*----------------------------------------------------------------------------*
		THIS.CreateTestConfigFile()
		THIS.StringConnectObj = NEWOBJECT('StringConnect', 'progs\StringConnect.prg')
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION TearDown()
	* Limpieza después de cada prueba
	*----------------------------------------------------------------------------*
		THIS.StringConnectObj = .NULL.
		THIS.DeleteTestConfigFile()
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION TestInicializacion
	* Prueba la inicialización correcta de la clase
	*----------------------------------------------------------------------------*
		THIS.AssertNotNull(THIS.StringConnectObj, 'El objeto StringConnect debe inicializarse correctamente')
		THIS.AssertNotEmpty(THIS.StringConnectObj.getFileIni(), 'El archivo de configuración debe estar definido')
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION TestGetStringComercial
	* Prueba la obtención del string de conexión para COMERCIAL
	*----------------------------------------------------------------------------*
		LOCAL lcResult
		
		lcResult = THIS.StringConnectObj.getString('COMERCIAL')
		THIS.AssertNotEmpty(lcResult, 'El string de conexión para COMERCIAL no debe estar vacío')
		THIS.AssertTrue(AT('DRIVER=', lcResult) > 0, 'El string debe contener DRIVER=')
		THIS.AssertTrue(AT('SERVER=', lcResult) > 0, 'El string debe contener SERVER=')
		THIS.AssertTrue(AT('UID=', lcResult) > 0, 'El string debe contener UID=')
		THIS.AssertTrue(AT('PWD=', lcResult) > 0, 'El string debe contener PWD=')
		THIS.AssertTrue(AT('DATABASE=', lcResult) > 0, 'El string debe contener DATABASE=')
		THIS.AssertTrue(AT('PORT=', lcResult) > 0, 'El string debe contener PORT=')
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION TestGetStringTipoInvalido
	* Prueba el manejo de tipos de base de datos inválidos
	*----------------------------------------------------------------------------*
		LOCAL lcResult
		
		lcResult = THIS.StringConnectObj.getString('INVALIDO')
		THIS.AssertFalse(lcResult, 'Debe retornar .F. para tipos inválidos')
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION TestReadComercial
	* Prueba la lectura de configuración para COMERCIAL
	*----------------------------------------------------------------------------*
		LOCAL loResult
		
		loResult = THIS.StringConnectObj.ReadComercial()
		THIS.AssertNotNull(loResult, 'El resultado de ReadComercial no debe ser NULL')
		THIS.AssertNotEmpty(loResult.DB_CONNECTION, 'DB_CONNECTION no debe estar vacío')
		THIS.AssertNotEmpty(loResult.DB_HOST, 'DB_HOST no debe estar vacío')
		THIS.AssertNotEmpty(loResult.DB_PORT, 'DB_PORT no debe estar vacío')
		THIS.AssertNotEmpty(loResult.DB_DATABASE, 'DB_DATABASE no debe estar vacío')
		THIS.AssertNotEmpty(loResult.DB_USERNAME, 'DB_USERNAME no debe estar vacío')
		*THIS.AssertNotEmpty(loResult.DB_PASSWORD, 'DB_PASSWORD no debe estar vacío')
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION CreateTestConfigFile()
	* Crea un archivo de configuración de prueba
	*----------------------------------------------------------------------------*
		LOCAL lcContent, lcPrint
		
		lcPrint = SET("Printer")
		*SET PRINTER TO
		SET PRINTER OFF
		TEXT TO lcContent NOSHOW TEXTMERGE 
[DATABASE]
DB_CONNECTION=MySQL ODBC 8.0 Driver

[CONFIG]
ENCRYPT=OFF

[COMERCIAL]
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=comercial_test
DB_USERNAME=test_user
DB_PASSWORD=test_password
		ENDTEXT
		
		STRTOFILE(lcContent, THIS.TestConfigFile)
		*SET PRINTER &lcPrint
		SET PRINTER ON
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION DeleteTestConfigFile()
	* Elimina el archivo de configuración de prueba
	*----------------------------------------------------------------------------*
		IF FILE(THIS.TestConfigFile)
			DELETE FILE (THIS.TestConfigFile)
		ENDIF
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	* PRIVATE define
	*
	*----------------------------------------------------------------------------*
ENDDEFINE
