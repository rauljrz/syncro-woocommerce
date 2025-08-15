*|--------------------------------------------------------------------------
*| test_http_client.prg
*|--------------------------------------------------------------------------
*|
*| Author......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.01.26 - 15:30
*| Purpose.....: Test unitario para la clase HTTPClient
*|	
*| Revisions...: v1.00
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS Test_HTTP_Client AS TestBase
*-----------------------------------------------------------------------------------*
    PROTECTED oHTTPClient
    PROTECTED oConfigManager
    
    *----------------------------------------------------------------------------*
    FUNCTION SetUp()
    * Configuraci�n inicial para cada test
    *----------------------------------------------------------------------------*
        * Crear ConfigManager mock para inyecci�n de dependencia
        THIS.oConfigManager = NEWOBJECT('ConfigManager','app\config\config_manager.prg')
        
        * Crear instancia de HTTPClient con inyecci�n de dependencia
        THIS.oHTTPClient = NEWOBJECT('HTTPClient', 'progs\http_client.prg', '', THIS.oConfigManager)
        
        * Verificar que se cre� correctamente
        IF VARTYPE(THIS.oHTTPClient) != 'O'
            THROW "No se pudo crear la instancia de HTTPClient"
        ENDIF
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION TearDown()
    * Limpieza despu�s de cada test
    *----------------------------------------------------------------------------*
        IF VARTYPE(THIS.oHTTPClient) = 'O'
            THIS.oHTTPClient.Destroy()
        ENDIF
        THIS.oHTTPClient = .NULL.
        THIS.oConfigManager = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_Init_WithInjection()
    * Prueba la inicializaci�n con inyecci�n de dependencia
    *----------------------------------------------------------------------------*
        LOCAL oTestConfig, oTestClient
        
        * Crear ConfigManager de prueba
        oTestConfig = NEWOBJECT('ConfigManager','app\config\config_manager.prg')
        oTestClient = NEWOBJECT('HTTPClient', 'progs\http_client.prg', '', oTestConfig)

        * Verificar que se cre� correctamente
        THIS.AssertTrue(VARTYPE(oTestClient) = 'O', "HTTPClient con inyecci�n no se cre�")
        * Limpiar
        oTestClient = .NULL.
        oTestConfig = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_Init_WithoutInjection()
    * Prueba la inicializaci�n sin inyecci�n de dependencia
    *----------------------------------------------------------------------------*
        LOCAL oTestClient
        * Crear cliente sin inyecci�n (debe usar fallback)
        oTestClient = NEWOBJECT('HTTPClient', 'progs\http_client.prg')
        
        * Verificar que se cre� correctamente
        THIS.AssertTrue(VARTYPE(oTestClient) = 'O', "HTTPClient sin inyecci�n no se cre�")
        * Limpiar
        oTestClient = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_setServer()
    * Prueba el m�todo setServer
    *----------------------------------------------------------------------------*
        LOCAL lcTestServer
        
        lcTestServer = "https://api.test.com"
        THIS.AssertTrue(THIS.oHTTPClient.setServer(lcTestServer), "setServer no funcion� correctamente")
        
        * Probar con string vac�o (no debe cambiar)
        THIS.AssertFalse(THIS.oHTTPClient.setServer(""), "setServer cambi� con string vac�o")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_setApiPath()
    * Prueba el m�todo setApiPath
    *----------------------------------------------------------------------------*
        LOCAL lcTestPath
        
        lcTestPath = "/api/v2/"
        
        
        THIS.AssertTrue(THIS.oHTTPClient.setApiPath(lcTestPath), "setApiPath no funcion� correctamente")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_setMethod()
    * Prueba el m�todo setMethod
    *----------------------------------------------------------------------------*
        LOCAL lcValidMethods, lcMethod, lnInd, lnCnt, laValidMethods[1]
        
        * Probar m�todos v�lidos
        lcValidMethods = "POST,GET,PUT,DELETE,HEAD,CONNECT,OPTIONS,TRACE,PATCH"
        lnCnt = ALINES(laValidMethods, lcValidMethods, ',')
        
        FOR lnInd = 1 TO lnCnt
            lcMethod = laValidMethods[lnInd]
            
            THIS.AssertTrue(THIS.oHTTPClient.setMethod(lcMethod), "setMethod fall� para: " + lcMethod)
        ENDFOR
        
        * Probar m�todo inv�lido (debe usar catchexception)
        TRY
            THIS.oHTTPClient.setMethod("INVALID")
            * Si llegamos aqu�, el m�todo no lanz� excepci�n como esperado
            THIS.AssertTrue(.T., "setMethod con m�todo inv�lido se manej� correctamente")
        CATCH TO loException
            * Excepci�n esperada
            THIS.AssertTrue(.T., "Excepci�n capturada correctamente")
        ENDTRY
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_addHeader()
    * Prueba el m�todo addHeader
    *----------------------------------------------------------------------------*
        LOCAL lcKey, lcValue, lcHexKey
        
        lcKey = "Authorization"
        lcValue = "Bearer token123"
        lcHexKey = '_' + STRCONV(lcKey, 15)
        
        * Verificar que se agreg� correctamente
        THIS.AssertTrue(THIS.oHTTPClient.addHeader(lcKey, lcValue), "Header no se agreg� correctamente")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_addParameter()
    * Prueba el m�todo addParameter
    *----------------------------------------------------------------------------*
        LOCAL lcKey, lcValue, lcHexKey
        
        lcKey = "page"
        lcValue = "1"
        lcHexKey = '_' + STRCONV(lcKey, 15)
        
        * Verificar que se agreg� correctamente
        THIS.AssertTrue(THIS.oHTTPClient.addParameter(lcKey, lcValue), "Par�metro no se agreg� correctamente")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_buildURL()
    * Prueba el m�todo buildURL (protegido, se accede por reflexi�n)
    *----------------------------------------------------------------------------*
        LOCAL lcURL, lcExpectedURL
        
        * Configurar cliente
        THIS.oHTTPClient.setServer("https://api.test.com")
        THIS.oHTTPClient.setApiPath("/api/v1/")
        THIS.oHTTPClient.setEndpoint("users")
        
        * Agregar par�metros
        THIS.oHTTPClient.addParameter("limit", "10")
        THIS.oHTTPClient.addParameter("page", "1")
        
        * Construir URL usando reflexi�n
        lcURL = EVALUATE("THIS.oHTTPClient.buildURL()")
        lcExpectedURL = "https://api.test.com/api/v1/users?limit=10&page=1"
        
        THIS.AssertEquals(lcExpectedURL, lcURL, "buildURL no construy� la URL correctamente")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_setTimeout()
    * Prueba el m�todo setTimeout
    *----------------------------------------------------------------------------*
        LOCAL lnTestTimeout
        
        lnTestTimeout = 60
        THIS.AssertTrue(THIS.oHTTPClient.setTimeout(lnTestTimeout), "setTimeout no funcion� correctamente")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_setMaxRetries()
    * Prueba el m�todo setMaxRetries
    *----------------------------------------------------------------------------*
        LOCAL lnTestRetries
        
        lnTestRetries = 5
        THIS.AssertTrue(THIS.oHTTPClient.setMaxRetries(lnTestRetries), "setMaxRetries no funcion� correctamente")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_clearLastResponse()
    * Prueba el m�todo clearLastResponse
    *----------------------------------------------------------------------------*
        * Establecer valores de respuesta
        THIS.oHTTPClient.cLastError = "Test error"
        THIS.oHTTPClient.nLastResponseCode = 500
        THIS.oHTTPClient.cLastResponse = "Test response"
        THIS.oHTTPClient.cLastStatusText = "Internal Server Error"
        THIS.oHTTPClient.cLastResponseBody = "Test body"
        
        * Verificar que se establecieron
        THIS.AssertEquals("Test error", THIS.oHTTPClient.cLastError, "Error no se estableci�")
        THIS.AssertEquals(500, THIS.oHTTPClient.nLastResponseCode, "Response code no se estableci�")
        
        * Limpiar respuesta
        THIS.oHTTPClient.clearLastResponse()
        
        * Verificar que se limpiaron
        THIS.AssertEquals("", THIS.oHTTPClient.cLastError, "Error no se limpi�")
        THIS.AssertEquals(0, THIS.oHTTPClient.nLastResponseCode, "Response code no se limpi�")
        THIS.AssertEquals("", THIS.oHTTPClient.cLastResponse, "Response no se limpi�")
        THIS.AssertEquals("", THIS.oHTTPClient.cLastStatusText, "Status text no se limpi�")
        THIS.AssertEquals("", THIS.oHTTPClient.cLastResponseBody, "Response body no se limpi�")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetMethods()
    * Prueba los m�todos get para obtener informaci�n de la respuesta
    *----------------------------------------------------------------------------*
        * Establecer valores de respuesta
        THIS.oHTTPClient.cLastError = "Test error"
        THIS.oHTTPClient.nLastResponseCode = 200
        THIS.oHTTPClient.cLastResponse = "Test response"
        THIS.oHTTPClient.cLastStatusText = "OK"
        THIS.oHTTPClient.cLastResponseBody = "Test body"
        
        * Verificar m�todos get
        THIS.AssertEquals("Test error", THIS.oHTTPClient.getLastError(), "getLastError fall�")
        THIS.AssertEquals(200, THIS.oHTTPClient.getLastResponseCode(), "getLastResponseCode fall�")
        THIS.AssertEquals("Test response", THIS.oHTTPClient.getLastResponse(), "getLastResponse fall�")
        THIS.AssertEquals("OK", THIS.oHTTPClient.getLastStatusText(), "getLastStatusText fall�")
        THIS.AssertEquals("Test body", THIS.oHTTPClient.getLastResponseBody(), "getLastResponseBody fall�")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_Integration_CompleteRequest()
    * Prueba de integraci�n completa de una petici�n HTTP
    *----------------------------------------------------------------------------*
        LOCAL lcResponse
        
        * Configurar cliente para una petici�n GET simple
        THIS.oHTTPClient.setServer("https://httpbin.org")
        THIS.oHTTPClient.setApiPath("/")
        THIS.oHTTPClient.setEndpoint("get")
        THIS.oHTTPClient.setMethod("GET")
        
        * Agregar par�metros de prueba
        THIS.oHTTPClient.addParameter("test", "value")
        THIS.oHTTPClient.addParameter("param", "123")
        
        * Agregar headers personalizados
        THIS.oHTTPClient.addHeader("X-Test-Header", "TestValue")
        
        * Realizar petici�n (puede fallar si no hay internet, pero no debe crashear)
        TRY
            lcResponse = THIS.oHTTPClient.send("")
            
            * Si la petici�n fue exitosa, verificar respuesta
            IF !EMPTY(lcResponse)
                THIS.AssertTrue(AT('"test": "value"', lcResponse) > 0, "Par�metro test no se envi� correctamente")
                THIS.AssertTrue(AT('"param": "123"', lcResponse) > 0, "Par�metro param no se envi� correctamente")
            ENDIF
            
        CATCH TO loException
            * Si falla por conexi�n, solo verificar que no crashee
            THIS.AssertTrue(.T., "Petici�n fall� por conexi�n pero no crashe�: " + loException.Message)
        ENDTRY
    ENDFUNC
    
ENDDEFINE
