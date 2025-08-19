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
    * Configuración inicial para cada prueba
    FUNCTION SetUp()
    *
    *----------------------------------------------------------------------------*
        THIS.oBaseAPI = NEWOBJECT('WooCommerceBaseAPI', 'app\services\woocommerce\woocommerce_base_api.prg')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Limpieza después de cada prueba
    FUNCTION TearDown()
    *
    *----------------------------------------------------------------------------*
        THIS.oBaseAPI = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar inicialización de la clase
    FUNCTION TestInicializacion()
    *
    *----------------------------------------------------------------------------*
        THIS.AssertNotNull(THIS.oBaseAPI, 'El objeto debe inicializarse correctamente')
        THIS.AssertTrue(PEMSTATUS(THIS.oBaseAPI, "MakeRequest", 5), 'MakeRequest debe existir')
        THIS.AssertTrue(PEMSTATUS(THIS.oBaseAPI, "FormatDateForAPI", 5), 'FormatDateForAPI debe existir')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método GetLastError
    FUNCTION TestGetLastError()
    *
    *----------------------------------------------------------------------------*
        LOCAL lcError
        lcError = THIS.oBaseAPI.GetLastError()
        THIS.AssertString(lcError, 'GetLastError debe devolver un string')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método GetLastResponseCode
    FUNCTION TestGetLastResponseCode()
    *
    *----------------------------------------------------------------------------*
        LOCAL lnCode
        lnCode = THIS.oBaseAPI.GetLastResponseCode()
        THIS.AssertTrue(TYPE("lnCode") = "N", 'GetLastResponseCode debe devolver un número')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método GetLastResponse
    FUNCTION TestGetLastResponse()
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse
        lcResponse = THIS.oBaseAPI.GetLastResponse()
        THIS.AssertString(lcResponse, 'GetLastResponse debe devolver un string')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método ClearLastError
    FUNCTION TestClearLastError()
    *
    *----------------------------------------------------------------------------*
        THIS.oBaseAPI.ClearLastError()
        THIS.AssertEmpty(THIS.oBaseAPI.GetLastError(), 'ClearLastError debe limpiar el error')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método FormatDateForAPI
    FUNCTION TestFormatDateForAPI()
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResult
        lcResult = THIS.oBaseAPI.FormatDateForAPI(DATE())
        THIS.AssertString(lcResult, 'FormatDateForAPI debe devolver un string')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método FormatDateForAPI con fecha vacía
    FUNCTION TestFormatDateForAPIConFechaVacia()
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResult
        lcResult = THIS.oBaseAPI.FormatDateForAPI({})
        THIS.AssertEmpty(lcResult, 'FormatDateForAPI con fecha vacía debe devolver string vacío')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar propiedades públicas
    FUNCTION TestPropiedadesPublicas()
    *
    *----------------------------------------------------------------------------*
        * Solo probar propiedades públicas accesibles
        THIS.AssertString(THIS.oBaseAPI.GetLastError(), 'GetLastError debe devolver un string')
        lnResult = THIS.oBaseAPI.GetLastResponseCode()
        THIS.AssertTrue(TYPE("lnResult") = "N", 'GetLastResponseCode debe devolver un número')
        THIS.AssertString(THIS.oBaseAPI.GetLastResponse(), 'GetLastResponse debe devolver un string')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar métodos públicos
    FUNCTION TestMetodosPublicos()
    *
    *----------------------------------------------------------------------------*
        THIS.AssertTrue(PEMSTATUS(THIS.oBaseAPI, "GetLastError", 5), 'GetLastError debe ser un método público')
        THIS.AssertTrue(PEMSTATUS(THIS.oBaseAPI, "GetLastResponseCode", 5), 'GetLastResponseCode debe ser un método público')
        THIS.AssertTrue(PEMSTATUS(THIS.oBaseAPI, "GetLastResponse", 5), 'GetLastResponse debe ser un método público')
        THIS.AssertTrue(PEMSTATUS(THIS.oBaseAPI, "ClearLastError", 5), 'ClearLastError debe ser un método público')
        THIS.AssertTrue(PEMSTATUS(THIS.oBaseAPI, "FormatDateForAPI", 5), 'FormatDateForAPI debe ser un método público')
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
    * Probar conexión exitosa por método GET con query parameters
    FUNCTION TestConexionExitosaGETConQueryParams()
    *
    *----------------------------------------------------------------------------*
        LOCAL loParams, lcResponse, lcEndpoint
        
        SET STEP on
        * Crear objeto Collection para los parámetros de consulta
        loParams = NEWOBJECT("Collection")
        loParams.Add("per_page", "10")
        loParams.Add("status", "publish")
        loParams.Add("orderby", "date")
        loParams.Add("order", "desc")
        
        * Endpoint de prueba (productos de WooCommerce)
        lcEndpoint = "products"
        
        * Realizar petición GET con parámetros
        lcResponse = THIS.oBaseAPI.MakeRequest(lcEndpoint, "GET", .NULL., loParams)
        
        * Verificar que no hay error
        THIS.AssertEmpty(THIS.oBaseAPI.GetLastError(), 'No debe haber error en la conexión exitosa')
        
        * Verificar que se recibió respuesta
        THIS.AssertNotEmpty(lcResponse, 'Debe recibirse una respuesta del servidor')
        
        * Verificar código de respuesta (200 = OK, 201 = Created, etc.)
        THIS.AssertTrue(THIS.oBaseAPI.GetLastResponseCode() >= 200 AND ;
                       THIS.oBaseAPI.GetLastResponseCode() < 300, ;
                       'El código de respuesta debe ser exitoso (200-299)')
        
        * Verificar que la respuesta contiene datos JSON válidos
        IF !EMPTY(lcResponse)
            THIS.AssertTrue(LEFT(ALLTRIM(lcResponse), 1) = "[" OR ;
                           LEFT(ALLTRIM(lcResponse), 1) = "{", ;
                           'La respuesta debe ser JSON válido (array o objeto)')
        ENDIF
        
        * Verificar que se guardó la respuesta en las propiedades
        THIS.AssertEqual(lcResponse, THIS.oBaseAPI.GetLastResponse(), ;
                        'GetLastResponse debe devolver la misma respuesta que MakeRequest')
        
        * Limpiar para siguiente prueba
        THIS.oBaseAPI.ClearLastError()
    ENDFUNC
    
ENDDEFINE 