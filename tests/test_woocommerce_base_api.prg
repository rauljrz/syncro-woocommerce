*|--------------------------------------------------------------------------
*| test_woocommerce_base_api.prg
*|--------------------------------------------------------------------------
*|
*| Pruebas unitarias para WooCommerceBaseAPI
*| Autor.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.01.26 - 10:30
*| Purpose.....: Pruebas unitarias para la clase WooCommerceBaseAPI
*|	
*| Revisions...: v1.00
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS Test_WooCommerce_Base_API AS TestBase
*-----------------------------------------------------------------------------------*
    PROTECTED oBaseAPI
    
    *----------------------------------------------------------------------------*
    * Configuraci�n inicial para cada prueba
    FUNCTION SetUp()
    *
    *----------------------------------------------------------------------------*
        THIS.oBaseAPI = NEWOBJECT('WooCommerceBaseAPI', 'app\services\woocommerce\woocommerce_base_api.prg')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Limpieza despu�s de cada prueba
    FUNCTION TearDown()
    *
    *----------------------------------------------------------------------------*
        THIS.oBaseAPI = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar inicializaci�n de la clase
    FUNCTION TestInicializacion()
    *
    *----------------------------------------------------------------------------*
        THIS.AssertNotNull(THIS.oBaseAPI, 'El objeto debe inicializarse correctamente')
        THIS.AssertTrue(PEMSTATUS(THIS.oBaseAPI, "MakeRequest", 5), 'MakeRequest debe existir')
        THIS.AssertTrue(PEMSTATUS(THIS.oBaseAPI, "FormatDateForAPI", 5), 'FormatDateForAPI debe existir')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo GetLastError
    FUNCTION TestGetLastError()
    *
    *----------------------------------------------------------------------------*
        LOCAL lcError
        lcError = THIS.oBaseAPI.GetLastError()
        THIS.AssertString(lcError, 'GetLastError debe devolver un string')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo GetLastResponseCode
    FUNCTION TestGetLastResponseCode()
    *
    *----------------------------------------------------------------------------*
        LOCAL lnCode
        lnCode = THIS.oBaseAPI.GetLastResponseCode()
        THIS.AssertTrue(TYPE("lnCode") = "N", 'GetLastResponseCode debe devolver un n�mero')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo GetLastResponse
    FUNCTION TestGetLastResponse()
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse
        lcResponse = THIS.oBaseAPI.GetLastResponse()
        THIS.AssertString(lcResponse, 'GetLastResponse debe devolver un string')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo ClearLastError
    FUNCTION TestClearLastError()
    *
    *----------------------------------------------------------------------------*
        THIS.oBaseAPI.ClearLastError()
        THIS.AssertEmpty(THIS.oBaseAPI.GetLastError(), 'ClearLastError debe limpiar el error')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo FormatDateForAPI
    FUNCTION TestFormatDateForAPI()
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResult
        lcResult = THIS.oBaseAPI.FormatDateForAPI(DATE())
        THIS.AssertString(lcResult, 'FormatDateForAPI debe devolver un string')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo FormatDateForAPI con fecha vac�a
    FUNCTION TestFormatDateForAPIConFechaVacia()
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResult
        lcResult = THIS.oBaseAPI.FormatDateForAPI({})
        THIS.AssertEmpty(lcResult, 'FormatDateForAPI con fecha vac�a debe devolver string vac�o')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar propiedades p�blicas
    FUNCTION TestPropiedadesPublicas()
    *
    *----------------------------------------------------------------------------*
        * Solo probar propiedades p�blicas accesibles
        THIS.AssertString(THIS.oBaseAPI.GetLastError(), 'GetLastError debe devolver un string')
        lnResult = THIS.oBaseAPI.GetLastResponseCode()
        THIS.AssertTrue(TYPE("lnResult") = "N", 'GetLastResponseCode debe devolver un n�mero')
        THIS.AssertString(THIS.oBaseAPI.GetLastResponse(), 'GetLastResponse debe devolver un string')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todos p�blicos
    FUNCTION TestMetodosPublicos()
    *
    *----------------------------------------------------------------------------*
        THIS.AssertTrue(PEMSTATUS(THIS.oBaseAPI, "GetLastError", 5), 'GetLastError debe ser un m�todo p�blico')
        THIS.AssertTrue(PEMSTATUS(THIS.oBaseAPI, "GetLastResponseCode", 5), 'GetLastResponseCode debe ser un m�todo p�blico')
        THIS.AssertTrue(PEMSTATUS(THIS.oBaseAPI, "GetLastResponse", 5), 'GetLastResponse debe ser un m�todo p�blico')
        THIS.AssertTrue(PEMSTATUS(THIS.oBaseAPI, "ClearLastError", 5), 'ClearLastError debe ser un m�todo p�blico')
        THIS.AssertTrue(PEMSTATUS(THIS.oBaseAPI, "FormatDateForAPI", 5), 'FormatDateForAPI debe ser un m�todo p�blico')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar manejo de errores
    FUNCTION TestManejoDeErrores()
    *
    *----------------------------------------------------------------------------*
        LOCAL lcErrorOriginal, lcErrorDespues
        lcErrorOriginal = THIS.oBaseAPI.GetLastError()
        THIS.oBaseAPI.MakeRequest("invalid/endpoint", "GET")
        lcErrorDespues = THIS.oBaseAPI.GetLastError()
        THIS.AssertString(lcErrorDespues, 'El error debe ser un string')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar formato de fecha ISO 8601
    FUNCTION TestFormatoFechaISO8601()
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResult, dTestDate
        dTestDate = DATE()
        
        lcResult = THIS.oBaseAPI.FormatDateForAPI(dTestDate)
        * Verificar que el formato es correcto (YYYY-MM-DDTHH:MM:SSZ)
        THIS.AssertTrue(AT("T", lcResult) > 0, 'El formato debe contener T')
        THIS.AssertTrue(RIGHT(lcResult, 1) = "Z", 'El formato debe terminar con Z')
        THIS.AssertTrue(LEN(lcResult) = 20, 'El formato debe tener 20 caracteres ('+lcResult+")")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar conexi�n exitosa por m�todo GET con query parameters
    FUNCTION TestConexionExitosaGETConQueryParams()
    *
    *----------------------------------------------------------------------------*
        LOCAL loParams, lcResponse, lcEndpoint
        
        SET STEP on
        * Crear objeto Collection para los par�metros de consulta
        loParams = NEWOBJECT("Collection")
        loParams.Add("per_page", "10")
        loParams.Add("status", "publish")
        loParams.Add("orderby", "date")
        loParams.Add("order", "desc")
        
        * Endpoint de prueba (productos de WooCommerce)
        lcEndpoint = "products"
        
        * Realizar petici�n GET con par�metros
        lcResponse = THIS.oBaseAPI.MakeRequest(lcEndpoint, "GET", .NULL., loParams)
        
        * Verificar que no hay error
        THIS.AssertEmpty(THIS.oBaseAPI.GetLastError(), 'No debe haber error en la conexi�n exitosa')
        
        * Verificar que se recibi� respuesta
        THIS.AssertNotEmpty(lcResponse, 'Debe recibirse una respuesta del servidor')
        
        * Verificar c�digo de respuesta (200 = OK, 201 = Created, etc.)
        THIS.AssertTrue(THIS.oBaseAPI.GetLastResponseCode() >= 200 AND ;
                       THIS.oBaseAPI.GetLastResponseCode() < 300, ;
                       'El c�digo de respuesta debe ser exitoso (200-299)')
        
        * Verificar que la respuesta contiene datos JSON v�lidos
        IF !EMPTY(lcResponse)
            THIS.AssertTrue(LEFT(ALLTRIM(lcResponse), 1) = "[" OR ;
                           LEFT(ALLTRIM(lcResponse), 1) = "{", ;
                           'La respuesta debe ser JSON v�lido (array o objeto)')
        ENDIF
        
        * Verificar que se guard� la respuesta en las propiedades
        THIS.AssertEqual(lcResponse, THIS.oBaseAPI.GetLastResponse(), ;
                        'GetLastResponse debe devolver la misma respuesta que MakeRequest')
        
        * Limpiar para siguiente prueba
        THIS.oBaseAPI.ClearLastError()
    ENDFUNC
    
ENDDEFINE 