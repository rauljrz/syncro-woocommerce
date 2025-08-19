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
    * Configuraci�n inicial para cada test
    *----------------------------------------------------------------------------*
        * Crear ConfigManager mock para inyecci�n de dependencia
        THIS.oConfigManager = NEWOBJECT('ConfigManager','app\config\config_manager.prg')
        
        * Crear instancia de HTTPClient con inyecci�n de dependencia
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
    * Limpieza despu�s de cada test
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
    * Prueba la inicializaci�n de la clase
    *----------------------------------------------------------------------------*
        LOCAL oTestAPI
        * Crear nueva instancia para probar
        oTestAPI = NEWOBJECT('WooCommerceAPI', 'app\services\woocommerce\woocommerce_api.prg')
        
        * Verificar que se cre� correctamente
        THIS.AssertTrue(VARTYPE(oTestAPI) = 'O', "WooCommerceAPI no se cre� correctamente")
        
        * Verificar que los servicios espec�ficos est�n disponibles a trav�s de m�todos p�blicos
        THIS.AssertTrue(VARTYPE(oTestAPI.GetProductAPI()) = 'O', "ProductAPI no se inicializ�")
        THIS.AssertTrue(VARTYPE(oTestAPI.GetOrderAPI()) = 'O', "OrderAPI no se inicializ�")
        THIS.AssertTrue(VARTYPE(oTestAPI.GetCustomerAPI()) = 'O', "CustomerAPI no se inicializ�")
        THIS.AssertTrue(VARTYPE(oTestAPI.GetCategoryAPI()) = 'O', "CategoryAPI no se inicializ�")
        THIS.AssertTrue(VARTYPE(oTestAPI.GetHTTPClient()) = 'O', "HTTPClient no se inicializ�")
        
        oTestAPI = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetProductAPI()
    * Prueba obtener el servicio de productos
    *----------------------------------------------------------------------------*
        LOCAL oProductAPI
        
        oProductAPI = THIS.oWooCommerceAPI.GetProductAPI()
        THIS.AssertTrue(VARTYPE(oProductAPI) = 'O', "GetProductAPI no devolvi� un objeto v�lido")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetOrderAPI()
    * Prueba obtener el servicio de �rdenes
    *----------------------------------------------------------------------------*
        LOCAL oOrderAPI
        
        oOrderAPI = THIS.oWooCommerceAPI.GetOrderAPI()
        THIS.AssertTrue(VARTYPE(oOrderAPI) = 'O', "GetOrderAPI no devolvi� un objeto v�lido")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetCustomerAPI()
    * Prueba obtener el servicio de clientes
    *----------------------------------------------------------------------------*
        LOCAL oCustomerAPI
        
        oCustomerAPI = THIS.oWooCommerceAPI.GetCustomerAPI()
        THIS.AssertTrue(VARTYPE(oCustomerAPI) = 'O', "GetCustomerAPI no devolvi� un objeto v�lido")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetCategoryAPI()
    * Prueba obtener el servicio de categor�as
    *----------------------------------------------------------------------------*
        LOCAL oCategoryAPI
        
        oCategoryAPI = THIS.oWooCommerceAPI.GetCategoryAPI()
        THIS.AssertTrue(VARTYPE(oCategoryAPI) = 'O', "GetCategoryAPI no devolvi� un objeto v�lido")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetHTTPClient()
    * Prueba obtener el HTTPClient
    *----------------------------------------------------------------------------*
        LOCAL oHTTPClient
        
        oHTTPClient = THIS.oWooCommerceAPI.GetHTTPClient()
        THIS.AssertTrue(VARTYPE(oHTTPClient) = 'O', "GetHTTPClient no devolvi� un objeto v�lido")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetAPIStats()
    * Prueba obtener estad�sticas de la API
    *----------------------------------------------------------------------------*
        LOCAL oStats
        
        oStats = THIS.oWooCommerceAPI.GetAPIStats()
        THIS.AssertTrue(VARTYPE(oStats) = 'O', "GetAPIStats no devolvi� un objeto v�lido")
        THIS.AssertTrue(oStats.Count > 0, "GetAPIStats no devolvi� estad�sticas")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_HTTPClient_Configuration()
    * Prueba la configuraci�n correcta del HTTPClient
    *----------------------------------------------------------------------------*
        LOCAL oHTTPClient
        
        oHTTPClient = THIS.oWooCommerceAPI.GetHTTPClient()
        THIS.AssertTrue(VARTYPE(oHTTPClient) = 'O', "HTTPClient no est� disponible")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_Services_Initialization()
    * Prueba que todos los servicios se inicialicen correctamente
    *----------------------------------------------------------------------------*
        THIS.AssertTrue(VARTYPE(THIS.oWooCommerceAPI.GetProductAPI()) = 'O', "ProductAPI no est� disponible")
        THIS.AssertTrue(VARTYPE(THIS.oWooCommerceAPI.GetOrderAPI()) = 'O', "OrderAPI no est� disponible")
        THIS.AssertTrue(VARTYPE(THIS.oWooCommerceAPI.GetCustomerAPI()) = 'O', "CustomerAPI no est� disponible")
        THIS.AssertTrue(VARTYPE(THIS.oWooCommerceAPI.GetCategoryAPI()) = 'O', "CategoryAPI no est� disponible")
        THIS.AssertTrue(VARTYPE(THIS.oWooCommerceAPI.GetHTTPClient()) = 'O', "HTTPClient no est� disponible")
    ENDFUNC
    
ENDDEFINE 