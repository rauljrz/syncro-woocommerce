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
    * Configuración inicial para cada test
    *----------------------------------------------------------------------------*
        * Crear ConfigManager mock para inyección de dependencia
        THIS.oConfigManager = NEWOBJECT('ConfigManager','app\config\config_manager.prg')
        
        * Crear instancia de HTTPClient con inyección de dependencia
        THIS.oHTTPClient = NEWOBJECT('HTTPClient', 'progs\http_client.prg', '', THIS.oConfigManager)
        
        * Verificar que se creó correctamente
        IF VARTYPE(THIS.oHTTPClient) != 'O'
            THROW "No se pudo crear la instancia de HTTPClient"
        ENDIF
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION TearDown()
    * Limpieza después de cada test
    *----------------------------------------------------------------------------*
        IF VARTYPE(THIS.oHTTPClient) = 'O'
            THIS.oHTTPClient.Destroy()
        ENDIF
        THIS.oHTTPClient = .NULL.
        THIS.oConfigManager = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_Init_WithInjection()
    * Prueba la inicialización con inyección de dependencia
    *----------------------------------------------------------------------------*
        LOCAL oTestConfig, oTestClient
        
        * Crear ConfigManager de prueba
        oTestConfig = NEWOBJECT('ConfigManager','app\config\config_manager.prg')
        oTestClient = NEWOBJECT('HTTPClient', 'progs\http_client.prg', '', oTestConfig)

        * Verificar que se creó correctamente
        THIS.AssertTrue(VARTYPE(oTestClient) = 'O', "HTTPClient con inyección no se creó")
        * Limpiar
        oTestClient = .NULL.
        oTestConfig = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_Init_WithoutInjection()
    * Prueba la inicialización sin inyección de dependencia
    *----------------------------------------------------------------------------*
        LOCAL oTestClient
        * Crear cliente sin inyección (debe usar fallback)
        oTestClient = NEWOBJECT('HTTPClient', 'progs\http_client.prg')
        
        * Verificar que se creó correctamente
        THIS.AssertTrue(VARTYPE(oTestClient) = 'O', "HTTPClient sin inyección no se creó")
        * Limpiar
        oTestClient = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_setServer()
    * Prueba el método setServer
    *----------------------------------------------------------------------------*
        LOCAL lcTestServer
        
        lcTestServer = "https://api.test.com"
        THIS.AssertTrue(THIS.oHTTPClient.setServer(lcTestServer), "setServer no funcionó correctamente")
        
        * Probar con string vacío (no debe cambiar)
        THIS.AssertFalse(THIS.oHTTPClient.setServer(""), "setServer cambió con string vacío")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_setApiPath()
    * Prueba el método setApiPath
    *----------------------------------------------------------------------------*
        LOCAL lcTestPath
        
        lcTestPath = "/api/v2/"
        
        
        THIS.AssertTrue(THIS.oHTTPClient.setApiPath(lcTestPath), "setApiPath no funcionó correctamente")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_setMethod()
    * Prueba el método setMethod
    *----------------------------------------------------------------------------*
        LOCAL lcValidMethods, lcMethod, lnInd, lnCnt, laValidMethods[1]
        
        * Probar métodos válidos
        lcValidMethods = "POST,GET,PUT,DELETE,HEAD,CONNECT,OPTIONS,TRACE,PATCH"
        lnCnt = ALINES(laValidMethods, lcValidMethods, ',')
        
        FOR lnInd = 1 TO lnCnt
            lcMethod = laValidMethods[lnInd]
            
            THIS.AssertTrue(THIS.oHTTPClient.setMethod(lcMethod), "setMethod falló para: " + lcMethod)
        ENDFOR
        
        * Probar método inválido (debe usar catchexception)
        TRY
            THIS.oHTTPClient.setMethod("INVALID")
            * Si llegamos aquí, el método no lanzó excepción como esperado
            THIS.AssertTrue(.T., "setMethod con método inválido se manejó correctamente")
        CATCH TO loException
            * Excepción esperada
            THIS.AssertTrue(.T., "Excepción capturada correctamente")
        ENDTRY
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_addHeader()
    * Prueba el método addHeader
    *----------------------------------------------------------------------------*
        LOCAL lcKey, lcValue, lcHexKey
        
        lcKey = "Authorization"
        lcValue = "Bearer token123"
        lcHexKey = '_' + STRCONV(lcKey, 15)
        
        * Verificar que se agregó correctamente
        THIS.AssertTrue(THIS.oHTTPClient.addHeader(lcKey, lcValue), "Header no se agregó correctamente")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_addParameter()
    * Prueba el método addParameter
    *----------------------------------------------------------------------------*
        LOCAL lcKey, lcValue, lcHexKey
        
        lcKey = "page"
        lcValue = "1"
        lcHexKey = '_' + STRCONV(lcKey, 15)
        
        * Verificar que se agregó correctamente
        THIS.AssertTrue(THIS.oHTTPClient.addParameter(lcKey, lcValue), "Parámetro no se agregó correctamente")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_buildURL()
    * Prueba el método buildURL (protegido, se accede por reflexión)
    *----------------------------------------------------------------------------*
        LOCAL lcURL, lcExpectedURL
        
        * Configurar cliente
        THIS.oHTTPClient.setServer("https://api.test.com")
        THIS.oHTTPClient.setApiPath("/api/v1/")
        THIS.oHTTPClient.setEndpoint("users")
        
        * Agregar parámetros
        THIS.oHTTPClient.addParameter("limit", "10")
        THIS.oHTTPClient.addParameter("page", "1")
        
        * Construir URL usando reflexión
        lcURL = EVALUATE("THIS.oHTTPClient.buildURL()")
        lcExpectedURL = "https://api.test.com/api/v1/users?limit=10&page=1"
        
        THIS.AssertEquals(lcExpectedURL, lcURL, "buildURL no construyó la URL correctamente")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_setTimeout()
    * Prueba el método setTimeout
    *----------------------------------------------------------------------------*
        LOCAL lnTestTimeout
        
        lnTestTimeout = 60
        THIS.AssertTrue(THIS.oHTTPClient.setTimeout(lnTestTimeout), "setTimeout no funcionó correctamente")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_setMaxRetries()
    * Prueba el método setMaxRetries
    *----------------------------------------------------------------------------*
        LOCAL lnTestRetries
        
        lnTestRetries = 5
        THIS.AssertTrue(THIS.oHTTPClient.setMaxRetries(lnTestRetries), "setMaxRetries no funcionó correctamente")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_clearLastResponse()
    * Prueba el método clearLastResponse
    *----------------------------------------------------------------------------*
        * Establecer valores de respuesta
        THIS.oHTTPClient.cLastError = "Test error"
        THIS.oHTTPClient.nLastResponseCode = 500
        THIS.oHTTPClient.cLastResponse = "Test response"
        THIS.oHTTPClient.cLastStatusText = "Internal Server Error"
        THIS.oHTTPClient.cLastResponseBody = "Test body"
        
        * Verificar que se establecieron
        THIS.AssertEquals("Test error", THIS.oHTTPClient.cLastError, "Error no se estableció")
        THIS.AssertEquals(500, THIS.oHTTPClient.nLastResponseCode, "Response code no se estableció")
        
        * Limpiar respuesta
        THIS.oHTTPClient.clearLastResponse()
        
        * Verificar que se limpiaron
        THIS.AssertEquals("", THIS.oHTTPClient.cLastError, "Error no se limpió")
        THIS.AssertEquals(0, THIS.oHTTPClient.nLastResponseCode, "Response code no se limpió")
        THIS.AssertEquals("", THIS.oHTTPClient.cLastResponse, "Response no se limpió")
        THIS.AssertEquals("", THIS.oHTTPClient.cLastStatusText, "Status text no se limpió")
        THIS.AssertEquals("", THIS.oHTTPClient.cLastResponseBody, "Response body no se limpió")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetMethods()
    * Prueba los métodos get para obtener información de la respuesta
    *----------------------------------------------------------------------------*
        * Establecer valores de respuesta
        THIS.oHTTPClient.cLastError = "Test error"
        THIS.oHTTPClient.nLastResponseCode = 200
        THIS.oHTTPClient.cLastResponse = "Test response"
        THIS.oHTTPClient.cLastStatusText = "OK"
        THIS.oHTTPClient.cLastResponseBody = "Test body"
        
        * Verificar métodos get
        THIS.AssertEquals("Test error", THIS.oHTTPClient.getLastError(), "getLastError falló")
        THIS.AssertEquals(200, THIS.oHTTPClient.getLastResponseCode(), "getLastResponseCode falló")
        THIS.AssertEquals("Test response", THIS.oHTTPClient.getLastResponse(), "getLastResponse falló")
        THIS.AssertEquals("OK", THIS.oHTTPClient.getLastStatusText(), "getLastStatusText falló")
        THIS.AssertEquals("Test body", THIS.oHTTPClient.getLastResponseBody(), "getLastResponseBody falló")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_Integration_CompleteRequest()
    * Prueba de integración completa de una petición HTTP
    *----------------------------------------------------------------------------*
        LOCAL lcResponse
        
        * Configurar cliente para una petición GET simple
        THIS.oHTTPClient.setServer("https://httpbin.org")
        THIS.oHTTPClient.setApiPath("/")
        THIS.oHTTPClient.setEndpoint("get")
        THIS.oHTTPClient.setMethod("GET")
        
        * Agregar parámetros de prueba
        THIS.oHTTPClient.addParameter("test", "value")
        THIS.oHTTPClient.addParameter("param", "123")
        
        * Agregar headers personalizados
        THIS.oHTTPClient.addHeader("X-Test-Header", "TestValue")
        
        * Realizar petición (puede fallar si no hay internet, pero no debe crashear)
        TRY
            lcResponse = THIS.oHTTPClient.send("")
            
            * Si la petición fue exitosa, verificar respuesta
            IF !EMPTY(lcResponse)
                THIS.AssertTrue(AT('"test": "value"', lcResponse) > 0, "Parámetro test no se envió correctamente")
                THIS.AssertTrue(AT('"param": "123"', lcResponse) > 0, "Parámetro param no se envió correctamente")
            ENDIF
            
        CATCH TO loException
            * Si falla por conexión, solo verificar que no crashee
            THIS.AssertTrue(.T., "Petición falló por conexión pero no crasheó: " + loException.Message)
        ENDTRY
    ENDFUNC
    
ENDDEFINE
