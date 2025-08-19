*|--------------------------------------------------------------------------
*| test_woocommerce_api.prg
*|--------------------------------------------------------------------------
*|
*| Author......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.01.26 - 15:30
*| Purpose.....: Test unitario para la clase WooCommerceAPI
*|	
*| Revisions...: v1.00
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS Test_WooCommerce_API AS TestBase
*-----------------------------------------------------------------------------------*
    PROTECTED oWooCommerceAPI
    PROTECTED oConfigManager
    PROTECTED oHTTPClient
    
    *----------------------------------------------------------------------------*
    FUNCTION SetUp()
    * Configuración inicial para cada test
    *----------------------------------------------------------------------------*
        * Crear ConfigManager mock para inyección de dependencia
        THIS.oConfigManager = NEWOBJECT('ConfigManager','app\config\config_manager.prg')
        
        * Crear instancia de HTTPClient con inyección de dependencia
        THIS.oHTTPClient = NEWOBJECT('HTTPClient', 'progs\http_client.prg', '', THIS.oConfigManager)
        
        * Crear instancia de WooCommerceAPI
        THIS.oWooCommerceAPI = NEWOBJECT('WooCommerceAPI', 'app\services\woocommerce\woocommerce_api.prg')
        
        * Verificar que se crearon correctamente
        IF VARTYPE(THIS.oWooCommerceAPI) != 'O'
            THROW "No se pudo crear la instancia de WooCommerceAPI"
        ENDIF
        
        IF VARTYPE(THIS.oHTTPClient) != 'O'
            THROW "No se pudo crear la instancia de HTTPClient"
        ENDIF
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION TearDown()
    * Limpieza después de cada test
    *----------------------------------------------------------------------------*
        IF VARTYPE(THIS.oWooCommerceAPI) = 'O'
            THIS.oWooCommerceAPI.Destroy()
        ENDIF
        THIS.oWooCommerceAPI = .NULL.
        
        IF VARTYPE(THIS.oHTTPClient) = 'O'
            THIS.oHTTPClient.Destroy()
        ENDIF
        THIS.oHTTPClient = .NULL.
        THIS.oConfigManager = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_Init()
    * Prueba la inicialización de la clase
    *----------------------------------------------------------------------------*
        LOCAL oTestAPI
        * Crear nueva instancia para probar
        oTestAPI = NEWOBJECT('WooCommerceAPI', 'app\services\woocommerce\woocommerce_api.prg')
        
        * Verificar que se creó correctamente
        THIS.AssertTrue(VARTYPE(oTestAPI) = 'O', "WooCommerceAPI no se creó correctamente")
        
        * Verificar que los servicios específicos están disponibles a través de métodos públicos
        THIS.AssertTrue(VARTYPE(oTestAPI.GetProductAPI()) = 'O', "ProductAPI no se inicializó")
        THIS.AssertTrue(VARTYPE(oTestAPI.GetOrderAPI()) = 'O', "OrderAPI no se inicializó")
        THIS.AssertTrue(VARTYPE(oTestAPI.GetCustomerAPI()) = 'O', "CustomerAPI no se inicializó")
        THIS.AssertTrue(VARTYPE(oTestAPI.GetCategoryAPI()) = 'O', "CategoryAPI no se inicializó")
        THIS.AssertTrue(VARTYPE(oTestAPI.GetHTTPClient()) = 'O', "HTTPClient no se inicializó")
        
        oTestAPI = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetProductAPI()
    * Prueba obtener el servicio de productos
    *----------------------------------------------------------------------------*
        LOCAL oProductAPI
        
        oProductAPI = THIS.oWooCommerceAPI.GetProductAPI()
        THIS.AssertTrue(VARTYPE(oProductAPI) = 'O', "GetProductAPI no devolvió un objeto válido")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetOrderAPI()
    * Prueba obtener el servicio de órdenes
    *----------------------------------------------------------------------------*
        LOCAL oOrderAPI
        
        oOrderAPI = THIS.oWooCommerceAPI.GetOrderAPI()
        THIS.AssertTrue(VARTYPE(oOrderAPI) = 'O', "GetOrderAPI no devolvió un objeto válido")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetCustomerAPI()
    * Prueba obtener el servicio de clientes
    *----------------------------------------------------------------------------*
        LOCAL oCustomerAPI
        
        oCustomerAPI = THIS.oWooCommerceAPI.GetCustomerAPI()
        THIS.AssertTrue(VARTYPE(oCustomerAPI) = 'O', "GetCustomerAPI no devolvió un objeto válido")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetCategoryAPI()
    * Prueba obtener el servicio de categorías
    *----------------------------------------------------------------------------*
        LOCAL oCategoryAPI
        
        oCategoryAPI = THIS.oWooCommerceAPI.GetCategoryAPI()
        THIS.AssertTrue(VARTYPE(oCategoryAPI) = 'O', "GetCategoryAPI no devolvió un objeto válido")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetHTTPClient()
    * Prueba obtener el HTTPClient
    *----------------------------------------------------------------------------*
        LOCAL oHTTPClient
        
        oHTTPClient = THIS.oWooCommerceAPI.GetHTTPClient()
        THIS.AssertTrue(VARTYPE(oHTTPClient) = 'O', "GetHTTPClient no devolvió un objeto válido")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetAPIStats()
    * Prueba obtener estadísticas de la API
    *----------------------------------------------------------------------------*
        LOCAL oStats
        
        oStats = THIS.oWooCommerceAPI.GetAPIStats()
        THIS.AssertTrue(VARTYPE(oStats) = 'O', "GetAPIStats no devolvió un objeto válido")
        THIS.AssertTrue(oStats.Count > 0, "GetAPIStats no devolvió estadísticas")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_HTTPClient_Configuration()
    * Prueba la configuración correcta del HTTPClient
    *----------------------------------------------------------------------------*
        LOCAL oHTTPClient
        
        oHTTPClient = THIS.oWooCommerceAPI.GetHTTPClient()
        THIS.AssertTrue(VARTYPE(oHTTPClient) = 'O', "HTTPClient no está disponible")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_Services_Initialization()
    * Prueba que todos los servicios se inicialicen correctamente
    *----------------------------------------------------------------------------*
        THIS.AssertTrue(VARTYPE(THIS.oWooCommerceAPI.GetProductAPI()) = 'O', "ProductAPI no está disponible")
        THIS.AssertTrue(VARTYPE(THIS.oWooCommerceAPI.GetOrderAPI()) = 'O', "OrderAPI no está disponible")
        THIS.AssertTrue(VARTYPE(THIS.oWooCommerceAPI.GetCustomerAPI()) = 'O', "CustomerAPI no está disponible")
        THIS.AssertTrue(VARTYPE(THIS.oWooCommerceAPI.GetCategoryAPI()) = 'O', "CategoryAPI no está disponible")
        THIS.AssertTrue(VARTYPE(THIS.oWooCommerceAPI.GetHTTPClient()) = 'O', "HTTPClient no está disponible")
    ENDFUNC
    
ENDDEFINE 