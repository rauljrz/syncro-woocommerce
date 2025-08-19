*|--------------------------------------------------------------------------
*| test_woocommerce_api_integration.prg
*|--------------------------------------------------------------------------
*|
*| Author......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.01.26 - 16:00
*| Purpose.....: Test de integraci�n para WooCommerceAPI con HTTPClient
*|	
*| Revisions...: v1.00
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS Test_WooCommerce_API_Integration AS TestBase
*-----------------------------------------------------------------------------------*
    PROTECTED oWooCommerceAPI
    PROTECTED oConfigManager
    
    *----------------------------------------------------------------------------*
    FUNCTION SetUp()
    * Configuraci�n inicial para cada test
    *----------------------------------------------------------------------------*
        THIS.oConfigManager = NEWOBJECT('EMPTY')
        ADDPROPERTY(THIS.oConfigManager, 'GetValue', '')
        ADDPROPERTY(THIS.oConfigManager, 'LoadConfig', '')
        
        THIS.oConfigManager.GetValue = "https://test.woocommerce.com"
        
        THIS.oWooCommerceAPI = NEWOBJECT('WooCommerceAPI', 'app\services\woocommerce\woocommerce_api.prg')
        IF VARTYPE(THIS.oWooCommerceAPI) != 'O'
            THROW "No se pudo crear la instancia de WooCommerceAPI"
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
        THIS.oConfigManager = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_Init_WithHTTPClient()
    * Prueba que WooCommerceAPI se inicialice correctamente con HTTPClient
    *----------------------------------------------------------------------------*
        THIS.AssertTrue(VARTYPE(THIS.oWooCommerceAPI.GetHTTPClient()) = 'O', "HTTPClient no se cre� en WooCommerceAPI")
        THIS.AssertTrue(VARTYPE(THIS.oWooCommerceAPI.GetProductAPI()) = 'O', "ProductAPI no se cre�")
        THIS.AssertTrue(VARTYPE(THIS.oWooCommerceAPI.GetOrderAPI()) = 'O', "OrderAPI no se cre�")
        THIS.AssertTrue(VARTYPE(THIS.oWooCommerceAPI.GetCustomerAPI()) = 'O', "CustomerAPI no se cre�")
        THIS.AssertTrue(VARTYPE(THIS.oWooCommerceAPI.GetCategoryAPI()) = 'O', "CategoryAPI no se cre�")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_HTTPClient_Configuration_Integration()
    * Prueba que la configuraci�n del HTTPClient sea correcta para WooCommerce
    *----------------------------------------------------------------------------*
        LOCAL oHTTPClient
        
        oHTTPClient = THIS.oWooCommerceAPI.GetHTTPClient()
        
        THIS.AssertTrue(VARTYPE(oHTTPClient) = 'O', "HTTPClient no est� disponible")
        THIS.AssertTrue(.T., "Test de configuraci�n de HTTPClient completado")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_Error_Handling_Integration()
    * Prueba el manejo de errores integrado entre WooCommerceAPI y HTTPClient
    *----------------------------------------------------------------------------*
        LOCAL lcLastError
        
        THIS.oWooCommerceAPI.ClearAllErrors()
        
        lcLastError = THIS.oWooCommerceAPI.GetLastError()
        THIS.AssertEquals("", lcLastError, "Deber�a no haber errores inicialmente")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_API_Stats_Integration()
    * Prueba que las estad�sticas de la API incluyan informaci�n del HTTPClient
    *----------------------------------------------------------------------------*
        LOCAL oStats, lbHasHTTPClientStats
        
        oStats = THIS.oWooCommerceAPI.GetAPIStats()
        THIS.AssertTrue(VARTYPE(oStats) = 'O', "Estad�sticas de API no se crearon")
        
        lbHasHTTPClientStats = .F.
        IF oStats.Count > 0
            FOR lnInd = 1 TO oStats.Count
                IF oStats.GetKey(lnInd) = "http_client_response_code" OR oStats.GetKey(lnInd) = "http_client_status_text"
                    lbHasHTTPClientStats = .T.
                    EXIT
                ENDIF
            ENDFOR
        ENDIF
        
        THIS.AssertTrue(lbHasHTTPClientStats, "Estad�sticas del HTTPClient no se incluyeron en API Stats")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_Destroy_Cleanup()
    * Prueba que el destructor limpie correctamente todos los recursos
    *----------------------------------------------------------------------------*
        LOCAL oHTTPClient, oProductAPI, oOrderAPI, oCustomerAPI, oCategoryAPI
        
        oHTTPClient = THIS.oWooCommerceAPI.GetHTTPClient()
        oProductAPI = THIS.oWooCommerceAPI.GetProductAPI()
        oOrderAPI = THIS.oWooCommerceAPI.GetOrderAPI()
        oCustomerAPI = THIS.oWooCommerceAPI.GetCustomerAPI()
        oCategoryAPI = THIS.oWooCommerceAPI.GetCategoryAPI()
        
        THIS.AssertTrue(VARTYPE(oHTTPClient) = 'O', "HTTPClient no existe antes de destruir")
        THIS.AssertTrue(VARTYPE(oProductAPI) = 'O', "ProductAPI no existe antes de destruir")
        
        THIS.oWooCommerceAPI.Destroy()
        THIS.AssertTrue(.T., "Test de destructor completado")
    ENDFUNC
    
ENDDEFINE
