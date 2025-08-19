*|--------------------------------------------------------------------------
*| test_woocommerce_product_api.prg
*|--------------------------------------------------------------------------
*|
*| Author......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.01.26 - 15:30
*| Purpose.....: Test unitario para la clase WooCommerceProductAPI
*|	
*| Revisions...: v1.00
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS Test_WooCommerce_Product_API AS TestBase
*-----------------------------------------------------------------------------------*
    PROTECTED oProductAPI
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
        
        * Crear instancia de WooCommerceProductAPI
        THIS.oProductAPI = NEWOBJECT('WooCommerceProductAPI', 'app\services\woocommerce\woocommerce_product_api.prg')
        
        * Verificar que se crearon correctamente
        IF VARTYPE(THIS.oProductAPI) != 'O'
            THROW "No se pudo crear la instancia de WooCommerceProductAPI"
        ENDIF
        
        IF VARTYPE(THIS.oHTTPClient) != 'O'
            THROW "No se pudo crear la instancia de HTTPClient"
        ENDIF
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION TearDown()
    * Limpieza despu�s de cada test
    *----------------------------------------------------------------------------*
        IF VARTYPE(THIS.oProductAPI) = 'O'
            THIS.oProductAPI.Destroy()
        ENDIF
        THIS.oProductAPI = .NULL.
        
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
        oTestAPI = NEWOBJECT('WooCommerceProductAPI', 'app\services\woocommerce\woocommerce_product_api.prg')
        
        * Verificar que se cre� correctamente
        THIS.AssertTrue(VARTYPE(oTestAPI) = 'O', "WooCommerceProductAPI no se cre� correctamente")
        
        * Verificar que los m�todos p�blicos est�n disponibles
        THIS.AssertTrue(PEMSTATUS(oTestAPI, "GetProducts", 5), "GetProducts debe estar disponible")
        THIS.AssertTrue(PEMSTATUS(oTestAPI, "GetProduct", 5), "GetProduct debe estar disponible")
        THIS.AssertTrue(PEMSTATUS(oTestAPI, "CreateProduct", 5), "CreateProduct debe estar disponible")
        THIS.AssertTrue(PEMSTATUS(oTestAPI, "UpdateProduct", 5), "UpdateProduct debe estar disponible")
        THIS.AssertTrue(PEMSTATUS(oTestAPI, "DeleteProduct", 5), "DeleteProduct debe estar disponible")
        
        * Limpiar
        oTestAPI = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_FormatDateForAPI_ValidDate()
    * Prueba el formateo de fechas para la API
    *----------------------------------------------------------------------------*
        LOCAL dTestDate, cFormattedDate
        dTestDate = DATE(2025, 1, 26)
        cFormattedDate = THIS.oProductAPI.FormatDateForAPI(dTestDate)
        THIS.AssertEquals("2025-01-26T00:00:00Z", cFormattedDate, "Formato de fecha incorrecto")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_FormatDateForAPI_EmptyDate()
    * Prueba el formateo de fecha vac�a
    *----------------------------------------------------------------------------*
        LOCAL cFormattedDate
        cFormattedDate = THIS.oProductAPI.FormatDateForAPI({})
        THIS.AssertEquals("", cFormattedDate, "Fecha vac�a no se manej� correctamente")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_Methods_Availability()
    * Prueba que todos los m�todos p�blicos est�n disponibles
    *----------------------------------------------------------------------------*
        * Verificar m�todos heredados de la clase base
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "GetLastError", 5), "GetLastError debe estar disponible")
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "GetLastResponseCode", 5), "GetLastResponseCode debe estar disponible")
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "GetLastResponse", 5), "GetLastResponse debe estar disponible")
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "ClearLastError", 5), "ClearLastError debe estar disponible")
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "FormatDateForAPI", 5), "FormatDateForAPI debe estar disponible")
        
        * Verificar m�todos espec�ficos de productos
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "GetProducts", 5), "GetProducts debe estar disponible")
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "GetProduct", 5), "GetProduct debe estar disponible")
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "CreateProduct", 5), "CreateProduct debe estar disponible")
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "UpdateProduct", 5), "UpdateProduct debe estar disponible")
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "DeleteProduct", 5), "DeleteProduct debe estar disponible")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetProducts_ConParametros()
    * Prueba el m�todo GetProducts con par�metros
    *----------------------------------------------------------------------------*
        LOCAL loProducts, loParams

        loParams = CREATEOBJECT("Empty")
        ADDPROPERTY(loParams, "page", "1")
        ADDPROPERTY(loParams, "per_page", "5")
        ADDPROPERTY(loParams, "status", "publish")
        
        * Simular respuesta exitosa (esto ser�a mock en un test real)
        * Por ahora solo verificamos que el m�todo existe y se puede llamar
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "GetProducts", 5), "GetProducts debe estar disponible")
        
        * Verificar que acepta par�metros
        THIS.AssertTrue(VARTYPE(THIS.oProductAPI.GetProducts(1, 5, "publish")) != "U", "GetProducts debe aceptar par�metros")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetProducts_SinParametros()
    * Prueba el m�todo GetProducts sin par�metros (valores por defecto)
    *----------------------------------------------------------------------------*
        LOCAL loProducts
        
        THIS.AssertTrue(VARTYPE(THIS.oProductAPI.GetProducts()) != "U", "GetProducts debe funcionar sin par�metros")
        loProducts = THIS.oProductAPI.GetProducts()
        THIS.AssertTrue(VARTYPE(loProducts) != "U", "GetProducts debe devolver un resultado v�lido")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetProduct_ConID()
    * Prueba el m�todo GetProduct con ID espec�fico
    *----------------------------------------------------------------------------*
        LOCAL loProduct
        
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "GetProduct", 5), "GetProduct debe estar disponible")
        THIS.AssertTrue(VARTYPE(THIS.oProductAPI.GetProduct(1)) != "U", "GetProduct debe aceptar ID num�rico")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_CreateProduct_ConDatos()
    * Prueba el m�todo CreateProduct con datos de producto
    *----------------------------------------------------------------------------*
        LOCAL loProductData, loProduct
        
        loProductData = CREATEOBJECT("Empty")
        ADDPROPERTY(loProductData, "name", "Producto Test")
        ADDPROPERTY(loProductData, "description", "Descripci�n del producto de prueba")
        ADDPROPERTY(loProductData, "regular_price", "100.00")
        ADDPROPERTY(loProductData, "type", "simple")
        
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "CreateProduct", 5), "CreateProduct debe estar disponible")
        THIS.AssertTrue(VARTYPE(THIS.oProductAPI.CreateProduct(loProductData)) != "U", "CreateProduct debe aceptar datos de producto")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_UpdateProduct_ConDatos()
    * Prueba el m�todo UpdateProduct con datos de actualizaci�n
    *----------------------------------------------------------------------------*
        LOCAL loProductData, loProduct
        
        loProductData = CREATEOBJECT("Empty")
        ADDPROPERTY(loProductData, "name", "Producto Actualizado")
        ADDPROPERTY(loProductData, "regular_price", "150.00")
        
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "UpdateProduct", 5), "UpdateProduct debe estar disponible")
        THIS.AssertTrue(VARTYPE(THIS.oProductAPI.UpdateProduct(1, loProductData)) != "U", "UpdateProduct debe aceptar ID y datos")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_DeleteProduct_ConID()
    * Prueba el m�todo DeleteProduct con ID espec�fico
    *----------------------------------------------------------------------------*
        LOCAL llResult
        
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "DeleteProduct", 5), "DeleteProduct debe estar disponible")
        
        llResult = THIS.oProductAPI.DeleteProduct(1)
        THIS.AssertTrue(VARTYPE(llResult) = "L", "DeleteProduct debe devolver un valor l�gico")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetProductBySKU_ConSKU()
    * Prueba el m�todo GetProductBySKU con SKU espec�fico
    *----------------------------------------------------------------------------*
        LOCAL loProduct
        
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "GetProductBySKU", 5), "GetProductBySKU debe estar disponible")
        
        loProduct = THIS.oProductAPI.GetProductBySKU("TEST-SKU-001")
        THIS.AssertTrue(VARTYPE(loProduct) != "U", "GetProductBySKU debe aceptar SKU de texto")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetProductsByCategory_ConParametros()
    * Prueba el m�todo GetProductsByCategory con par�metros
    *----------------------------------------------------------------------------*
        LOCAL loProducts
        
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "GetProductsByCategory", 5), "GetProductsByCategory debe estar disponible")
        
        loProducts = THIS.oProductAPI.GetProductsByCategory(1, 1, 10)
        THIS.AssertTrue(VARTYPE(loProducts) != "U", "GetProductsByCategory debe aceptar par�metros")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetProductsByCategory_SinParametros()
    * Prueba el m�todo GetProductsByCategory sin par�metros (valores por defecto)
    *----------------------------------------------------------------------------*
        LOCAL loProducts
        
        loProducts = THIS.oProductAPI.GetProductsByCategory(1)
        THIS.AssertTrue(VARTYPE(loProducts) != "U", "GetProductsByCategory debe funcionar solo con categor�a")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetProductsLowStock_ConParametros()
    * Prueba el m�todo GetProductsLowStock con par�metros
    *----------------------------------------------------------------------------*
        LOCAL loProducts
        
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "GetProductsLowStock", 5), "GetProductsLowStock debe estar disponible")
        
        loProducts = THIS.oProductAPI.GetProductsLowStock(5, 1, 10)
        THIS.AssertTrue(VARTYPE(loProducts) != "U", "GetProductsLowStock debe aceptar par�metros")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_GetProductsLowStock_SinParametros()
    * Prueba el m�todo GetProductsLowStock sin par�metros (valores por defecto)
    *----------------------------------------------------------------------------*
        LOCAL loProducts
        
        loProducts = THIS.oProductAPI.GetProductsLowStock()
        THIS.AssertTrue(VARTYPE(loProducts) != "U", "GetProductsLowStock debe funcionar con valores por defecto")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_UpdateProductStock_ConParametros()
    * Prueba el m�todo UpdateProductStock con par�metros
    *----------------------------------------------------------------------------*
        LOCAL loResult
        
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "UpdateProductStock", 5), "UpdateProductStock debe estar disponible")
        
        loResult = THIS.oProductAPI.UpdateProductStock(1, 25)
        THIS.AssertTrue(VARTYPE(loResult) != "U", "UpdateProductStock debe aceptar ID y cantidad")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_UpdateProductPrice_ConParametros()
    * Prueba el m�todo UpdateProductPrice con par�metros
    *----------------------------------------------------------------------------*
        LOCAL loResult
        
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "UpdateProductPrice", 5), "UpdateProductPrice debe estar disponible")
        
        loResult = THIS.oProductAPI.UpdateProductPrice(1, 199.99)
        THIS.AssertTrue(VARTYPE(loResult) != "U", "UpdateProductPrice debe aceptar ID y precio")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_setHTTPClient_Compatibility()
    * Prueba el m�todo setHTTPClient para compatibilidad
    *----------------------------------------------------------------------------*
        LOCAL loTestHTTPClient, llResult
        
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "setHTTPClient", 5), "setHTTPClient debe estar disponible")
        
        loTestHTTPClient = NEWOBJECT("HTTPClient", "progs\http_client.prg", '', THIS.oConfigManager)
        
        llResult = THIS.oProductAPI.setHTTPClient(loTestHTTPClient)
        THIS.AssertTrue(llResult, "setHTTPClient debe aceptar objeto HTTPClient v�lido")
        
        llResult = THIS.oProductAPI.setHTTPClient(.NULL.)
        THIS.AssertFalse(llResult, "setHTTPClient debe rechazar objeto NULL")
        
        loTestHTTPClient = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_ClearLastError_Functionality()
    * Prueba la funcionalidad del m�todo ClearLastError
    *----------------------------------------------------------------------------*
        LOCAL lcErrorBefore, lcErrorAfter
        
        THIS.AssertTrue(PEMSTATUS(THIS.oProductAPI, "ClearLastError", 5), "ClearLastError debe estar disponible")
        
        THIS.oProductAPI.cLastError = "Error de prueba"
        THIS.oProductAPI.nLastResponseCode = 500
        THIS.oProductAPI.cLastResponse = "Respuesta de error"
        
        lcErrorBefore = THIS.oProductAPI.GetLastError()
        THIS.AssertNotEmpty(lcErrorBefore, "El error debe haberse establecido")
        
        THIS.oProductAPI.ClearLastError()
        
        lcErrorAfter = THIS.oProductAPI.GetLastError()
        THIS.AssertEmpty(lcErrorAfter, "ClearLastError debe limpiar el error")
        THIS.AssertEqual(0, THIS.oProductAPI.GetLastResponseCode(), "ClearLastError debe limpiar el c�digo de respuesta")
        THIS.AssertEmpty(THIS.oProductAPI.GetLastResponse(), "ClearLastError debe limpiar la respuesta")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Test_Destroy_Method()
    * Prueba el m�todo Destroy
    *----------------------------------------------------------------------------*
        LOCAL oTestAPI
        
        oTestAPI = NEWOBJECT('WooCommerceProductAPI', 'app\services\woocommerce\woocommerce_product_api.prg')
        THIS.AssertTrue(VARTYPE(oTestAPI) = 'O', "WooCommerceProductAPI debe crearse correctamente")
        THIS.AssertTrue(PEMSTATUS(oTestAPI, "Destroy", 5), "Destroy debe estar disponible")
        
        oTestAPI.Destroy()
        oTestAPI = .NULL.
    ENDFUNC
    
ENDDEFINE 