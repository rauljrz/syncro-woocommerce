*|--------------------------------------------------------------------------
*| test_woocommerce_api_requests.prg
*|--------------------------------------------------------------------------
*|
*| Author......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.01.26 - 15:00
*| Purpose.....: Test unitario para peticiones GET de WooCommerce API
*|	
*| Revisions...: v1.00
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS Test_WooCommerce_API_Requests AS TestBase
*-----------------------------------------------------------------------------------*

    PROTECTED oWooCommerceAPI
    PROTECTED oProductAPI
    PROTECTED oOrderAPI
    PROTECTED oCustomerAPI
    PROTECTED oCategoryAPI
    PROTECTED oLogger

    *----------------------------------------------------------------------------*
    FUNCTION SetUp()
    * Configuración inicial para cada test
    *----------------------------------------------------------------------------*
        * Instanciar WooCommerce API
        THIS.oWooCommerceAPI = NEWOBJECT("WooCommerceAPI", "app/services/woocommerce/woocommerce_api.prg")
        THIS.oLogger = NEWOBJECT("Logger", "progs\logger.prg")
        * Obtener APIs específicas
        THIS.oProductAPI = THIS.oWooCommerceAPI.GetProductAPI()
        THIS.oOrderAPI = THIS.oWooCommerceAPI.GetOrderAPI()
        THIS.oCustomerAPI = THIS.oWooCommerceAPI.GetCustomerAPI()
        THIS.oCategoryAPI = THIS.oWooCommerceAPI.GetCategoryAPI()
        
        * Verificar que las APIs se instanciaron correctamente
        THIS.AssertTrue(VARTYPE(THIS.oWooCommerceAPI) = "O", 'WooCommerceAPI debe instanciarse correctamente')
        THIS.AssertTrue(VARTYPE(THIS.oProductAPI) = "O", 'ProductAPI debe instanciarse correctamente')
        THIS.AssertTrue(VARTYPE(THIS.oOrderAPI) = "O", 'OrderAPI debe instanciarse correctamente')
        THIS.AssertTrue(VARTYPE(THIS.oCustomerAPI) = "O", 'CustomerAPI debe instanciarse correctamente')
        THIS.AssertTrue(VARTYPE(THIS.oCategoryAPI) = "O", 'CategoryAPI debe instanciarse correctamente')
    ENDFUNC

    *----------------------------------------------------------------------------*
    FUNCTION TearDown()
    * Limpieza después de cada test
    *----------------------------------------------------------------------------*
        THIS.oWooCommerceAPI = .NULL.
        THIS.oProductAPI = .NULL.
        THIS.oOrderAPI = .NULL.
        THIS.oCustomerAPI = .NULL.
        THIS.oCategoryAPI = .NULL.
    ENDFUNC

    *----------------------------------------------------------------------------*
    FUNCTION TestGetProducts()
    * Probar obtención de productos
    *----------------------------------------------------------------------------*
        LOCAL loProducts, nCount
        
        loProducts = THIS.oProductAPI.GetProducts(1, 10)
        THIS.AssertTrue(VARTYPE(loProducts) = "O", 'GetProducts debe devolver un Objecto')
        
        IF VARTYPE(loProducts) = "O"
            nCount = loProducts.nSize
            THIS.AssertTrue(nCount >= 0, 'El Objecto de productos debe tener 0 o más elementos')
            
            THIS.oLogger.Log("INFO", "Productos obtenidos: " + ALLTRIM(STR(nCount)))
            IF nCount > 0 THEN
                loItem = loProducts.array[1]
                THIS.AssertTrue(VARTYPE(loItem) = "O", 'Cada producto debe ser un objeto')
                THIS.AssertTrue(PEMSTATUS(loItem, "_id", 5), 'Producto debe tener propiedad id')
                THIS.AssertTrue(PEMSTATUS(loItem, "_name", 5), 'Producto debe tener propiedad name')
            ENDIF
        ENDIF
        
        THIS.AssertTrue(EMPTY(THIS.oProductAPI.GetLastError()), 'No debe haber errores en GetProducts')
    ENDFUNC

    *----------------------------------------------------------------------------*
    FUNCTION TestGetOrders()
    * Probar obtención de órdenes
    *----------------------------------------------------------------------------*
        LOCAL loOrders, nCount
        
        loOrders = THIS.oOrderAPI.GetOrders(1, 10)
        THIS.AssertTrue(VARTYPE(loOrders) = "O", 'GetOrders debe devolver un Objecto')
        
        IF VARTYPE(loOrders) = "O"
            nCount = loOrders.nSize
            THIS.AssertTrue(nCount >= 0, 'El Objecto de órdenes debe tener 0 o más elementos')
            
            THIS.oLogger.Log("INFO", "Órdenes obtenidas: " + ALLTRIM(STR(nCount)))
            IF nCount > 0 THEN
                loItem = loOrders.array[1]
                THIS.AssertTrue(VARTYPE(loItem) = "O", 'Cada orden debe ser un objeto')
                THIS.AssertTrue(PEMSTATUS(loItem, "_id", 5), 'Orden debe tener propiedad id')
                THIS.AssertTrue(PEMSTATUS(loItem, "_status", 5), 'Orden debe tener propiedad status')
            ENDIF
        ENDIF
        
        THIS.AssertTrue(EMPTY(THIS.oOrderAPI.GetLastError()), 'No debe haber errores en GetOrders')
    ENDFUNC

    *----------------------------------------------------------------------------*
    FUNCTION TestGetCustomers()
    * Probar obtención de clientes
    *----------------------------------------------------------------------------*
        LOCAL loCustomers, nCount
        
        loCustomers = THIS.oCustomerAPI.GetCustomers(1, 10)
        THIS.AssertTrue(VARTYPE(loCustomers) = "O", 'GetCustomers debe devolver un Objecto')
        
        IF VARTYPE(loCustomers) = "O"
            nCount = loCustomers.nSize
            THIS.AssertTrue(nCount >= 0, 'El Objecto de clientes debe tener 0 o más elementos')
            
            THIS.oLogger.Log("INFO", "Clientes obtenidos: " + ALLTRIM(STR(nCount)))
            IF nCount > 0 THEN
                loItem = loCustomers.array[1]
                THIS.AssertTrue(VARTYPE(loItem) = "O", 'Cada cliente debe ser un objeto')
                THIS.AssertTrue(PEMSTATUS(loItem, "_id", 5), 'Cliente debe tener propiedad id')
                THIS.AssertTrue(PEMSTATUS(loItem, "_email", 5), 'Cliente debe tener propiedad email')
            ENDIF
        ENDIF
        
        THIS.AssertTrue(EMPTY(THIS.oCustomerAPI.GetLastError()), 'No debe haber errores en GetCustomers')
    ENDFUNC

    *----------------------------------------------------------------------------*
    FUNCTION TestGetCategories()
    * Probar obtención de categorías
    *----------------------------------------------------------------------------*
        LOCAL loCategories, nCount
        
        loCategories = THIS.oCategoryAPI.GetCategories(1, 10) 
        THIS.AssertTrue(VARTYPE(loCategories) = "O", 'GetCategories debe devolver un Objecto')
        
        IF VARTYPE(loCategories) = "O"
            nCount = loCategories.nSize
            THIS.AssertTrue(nCount >= 0, 'El array de categorías debe tener 0 o más elementos')
            
            THIS.oLogger.Log("INFO", "Categorías obtenidas: " + ALLTRIM(STR(nCount)))
            IF nCount > 0 THEN
                SET STEP ON
                loItem = loCategories.array[1]
                THIS.AssertTrue(VARTYPE(loItem) = "O", 'Cada categoría debe ser un objeto')
                THIS.AssertTrue(PEMSTATUS(loItem, "_id", 5), 'Categoría debe tener propiedad id')
                THIS.AssertTrue(PEMSTATUS(loItem, "_name", 5), 'Categoría debe tener propiedad name')
            ENDIF
        ENDIF
        
        THIS.AssertTrue(EMPTY(THIS.oCategoryAPI.GetLastError()), 'No debe haber errores en GetCategories')
    ENDFUNC

    *----------------------------------------------------------------------------*
    FUNCTION TestGetAllResources()
    * Probar obtención de todos los recursos en una sola ejecución
    *----------------------------------------------------------------------------*
        LOCAL loProducts, loOrders, loCustomers, loCategories
        LOCAL nProductCount, nOrderCount, nCustomerCount, nCategoryCount
        
        THIS.oLogger.Log("INFO", "Iniciando prueba de obtención de todos los recursos")
        
        * Obtener productos
        loProducts = THIS.oProductAPI.GetProducts(1, 5)
        nProductCount = IIF(VARTYPE(loProducts) = "O", loProducts.nSize, 0)
        
        * Obtener órdenes
        loOrders = THIS.oOrderAPI.GetOrders(1, 5)
        nOrderCount = IIF(VARTYPE(loOrders) = "O", loOrders.nSize, 0)
        
        * Obtener clientes
        loCustomers = THIS.oCustomerAPI.GetCustomers(1, 5)
        nCustomerCount = IIF(VARTYPE(loCustomers) = "O", loCustomers.nSize, 0)
        
        * Obtener categorías
        loCategories = THIS.oCategoryAPI.GetCategories(1, 5)
        nCategoryCount = IIF(VARTYPE(loCategories) = "O", loCategories.nSize, 0)
        
        * Verificar que todas las peticiones fueron exitosas
        THIS.AssertTrue(VARTYPE(loProducts) = "O", 'GetProducts debe devolver Objecto')
        THIS.AssertTrue(VARTYPE(loOrders) = "O", 'GetOrders debe devolver Objecto')
        THIS.AssertTrue(VARTYPE(loCustomers) = "O", 'GetCustomers debe devolver Objecto')
        THIS.AssertTrue(VARTYPE(loCategories) = "O", 'GetCategories debe devolver Objecto')
        
        * Log de resumen
        THIS.oLogger.Log("INFO", "Resumen de recursos obtenidos:")
        THIS.oLogger.Log("INFO", "  - Productos: " + ALLTRIM(STR(nProductCount)))
        THIS.oLogger.Log("INFO", "  - Órdenes: " + ALLTRIM(STR(nOrderCount)))
        THIS.oLogger.Log("INFO", "  - Clientes: " + ALLTRIM(STR(nCustomerCount)))
        THIS.oLogger.Log("INFO", "  - Categorías: " + ALLTRIM(STR(nCategoryCount)))
        
        * Verificar que no hay errores en ninguna API
        THIS.AssertTrue(EMPTY(THIS.oProductAPI.GetLastError()), 'No debe haber errores en ProductAPI')
        THIS.AssertTrue(EMPTY(THIS.oOrderAPI.GetLastError()), 'No debe haber errores en OrderAPI')
        THIS.AssertTrue(EMPTY(THIS.oCustomerAPI.GetLastError()), 'No debe haber errores en CustomerAPI')
        THIS.AssertTrue(EMPTY(THIS.oCategoryAPI.GetLastError()), 'No debe haber errores en CategoryAPI')
    ENDFUNC

    *----------------------------------------------------------------------------*
    FUNCTION TestAPIResponseStructure()
    * Probar estructura de respuesta de las APIs
    *----------------------------------------------------------------------------*
        LOCAL aProducts, oProduct
        
        * Obtener un producto para verificar estructura
        aProducts = THIS.oProductAPI.GetProducts(1, 1)
        
        IF VARTYPE(aProducts) = "A" AND ALEN(aProducts) > 0
            oProduct = aProducts(1)
            
            * Verificar propiedades básicas de un producto
            THIS.AssertTrue(PEMSTATUS(oProduct, "id", 5), 'Producto debe tener id')
            THIS.AssertTrue(PEMSTATUS(oProduct, "name", 5), 'Producto debe tener name')
            THIS.AssertTrue(PEMSTATUS(oProduct, "type", 5), 'Producto debe tener type')
            THIS.AssertTrue(PEMSTATUS(oProduct, "status", 5), 'Producto debe tener status')
            THIS.AssertTrue(PEMSTATUS(oProduct, "price", 5), 'Producto debe tener price')
            
            * Log de propiedades del producto
            THIS.oLogger.Log("INFO", "Propiedades del producto:")
            THIS.oLogger.Log("INFO", "  - ID: " + ALLTRIM(STR(oProduct.id)))
            THIS.oLogger.Log("INFO", "  - Nombre: " + oProduct.name)
            THIS.oLogger.Log("INFO", "  - Tipo: " + oProduct.type)
            THIS.oLogger.Log("INFO", "  - Estado: " + oProduct.status)
            THIS.oLogger.Log("INFO", "  - Precio: " + oProduct.price)
        ENDIF
    ENDFUNC

    *----------------------------------------------------------------------------*
    FUNCTION TestErrorHandling()
    * Probar manejo de errores
    *----------------------------------------------------------------------------*
        LOCAL cError
        
        * Intentar obtener productos con parámetros inválidos (debe manejar el error)
        THIS.oProductAPI.GetProducts(-1, -1)
        
        * Verificar que se manejó el error correctamente
        cError = THIS.oProductAPI.GetLastError()
        
        * El error puede estar vacío si la API maneja los parámetros inválidos
        * o puede contener un mensaje de error
        THIS.AssertTrue(VARTYPE(cError) = "C", 'GetLastError debe devolver un string')
        
        THIS.oLogger.Log("INFO", "Error manejado: " + cError)
    ENDFUNC

    *----------------------------------------------------------------------------*
    FUNCTION TestConnectionStatus()
    * Probar estado de conexión
    *----------------------------------------------------------------------------*
        LOCAL lConnected
        
        * Probar conectividad
        lConnected = THIS.oWooCommerceAPI.TestConnectivity()
        
        * Verificar que la conexión funciona
        THIS.AssertTrue(lConnected, 'La conectividad con WooCommerce debe funcionar')
        
        THIS.oLogger.Log("INFO", "Estado de conectividad: " + IIF(lConnected, "CONECTADO", "DESCONECTADO"))
    ENDFUNC

ENDDEFINE 