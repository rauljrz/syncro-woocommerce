*|--------------------------------------------------------------------------
*| test_woocommerce_order_api.prg
*|--------------------------------------------------------------------------
*|
*| Pruebas unitarias para WooCommerceOrderAPI
*| Autor.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.01.26 - 10:30
*| Purpose.....: Pruebas unitarias para la clase WooCommerceOrderAPI
*|	
*| Revisions...: v1.00
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS Test_WooCommerce_Order_API AS TestBase
*-----------------------------------------------------------------------------------*
    PROTECTED oOrderAPI
    
    *----------------------------------------------------------------------------*
    * Configuración inicial para cada prueba
    FUNCTION SetUp()
    *
    *----------------------------------------------------------------------------*
        THIS.oOrderAPI = NEWOBJECT('WooCommerceOrderAPI', 'app\services\woocommerce\woocommerce_order_api.prg')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Limpieza después de cada prueba
    FUNCTION TearDown()
    *
    *----------------------------------------------------------------------------*
        THIS.oOrderAPI = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar inicialización de la clase
    FUNCTION TestInicializacion()
    *
    *----------------------------------------------------------------------------*
        THIS.AssertNotNull(THIS.oOrderAPI, 'El objeto debe inicializarse correctamente')
        THIS.AssertTrue(PEMSTATUS(THIS.oOrderAPI, "GetOrders", 5), 'GetOrders debe existir')
        THIS.AssertTrue(PEMSTATUS(THIS.oOrderAPI, "GetOrder", 5), 'GetOrder debe existir')
        THIS.AssertTrue(PEMSTATUS(THIS.oOrderAPI, "CreateOrder", 5), 'CreateOrder debe existir')
        THIS.AssertTrue(PEMSTATUS(THIS.oOrderAPI, "UpdateOrder", 5), 'UpdateOrder debe existir')
        THIS.AssertTrue(PEMSTATUS(THIS.oOrderAPI, "DeleteOrder", 5), 'DeleteOrder debe existir')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método GetLastError
    FUNCTION TestGetLastError()
    *
    *----------------------------------------------------------------------------*
        LOCAL lcError
        lcError = THIS.oOrderAPI.GetLastError()
        THIS.AssertString(lcError, 'GetLastError debe devolver un string')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método GetOrders
    FUNCTION TestGetOrders()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oOrderAPI.GetOrders(1, 10)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetOrders debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método GetOrders con parámetros por defecto
    FUNCTION TestGetOrdersConParametrosPorDefecto()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oOrderAPI.GetOrders()
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetOrders sin parámetros debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método GetOrders con filtros de fecha
    FUNCTION TestGetOrdersConFiltrosDeFecha()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oOrderAPI.GetOrders(1, 10, DATE() - 7, DATE())
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetOrders con fechas debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método GetOrders con estado específico
    FUNCTION TestGetOrdersConEstadoEspecifico()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oOrderAPI.GetOrders(1, 10, {}, {}, "processing")
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetOrders con estado debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método GetOrder
    FUNCTION TestGetOrder()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oOrderAPI.GetOrder(1)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetOrder debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método CreateOrder
    FUNCTION TestCreateOrder()
    *
    *----------------------------------------------------------------------------*
        LOCAL oOrderData, oResult
        oOrderData = CREATEOBJECT("Collection")
        oOrderData.Add("processing", "status")
        oOrderData.Add("test@example.com", "billing")
        
        oResult = THIS.oOrderAPI.CreateOrder(oOrderData)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'CreateOrder debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método UpdateOrder
    FUNCTION TestUpdateOrder()
    *
    *----------------------------------------------------------------------------*
        LOCAL oOrderData, oResult
        oOrderData = CREATEOBJECT("Collection")
        oOrderData.Add("completed", "status")
        
        oResult = THIS.oOrderAPI.UpdateOrder(1, oOrderData)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'UpdateOrder debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método DeleteOrder
    FUNCTION TestDeleteOrder()
    *
    *----------------------------------------------------------------------------*
        LOCAL llResult
        llResult = THIS.oOrderAPI.DeleteOrder(1)
        THIS.AssertTrue(TYPE("llResult") = "L", 'DeleteOrder debe devolver un valor lógico')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método UpdateOrderStatus
    FUNCTION TestUpdateOrderStatus()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oOrderAPI.UpdateOrderStatus(1, "completed")
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'UpdateOrderStatus debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método GetOrdersByCustomer
    FUNCTION TestGetOrdersByCustomer()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oOrderAPI.GetOrdersByCustomer(1, 1, 10)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetOrdersByCustomer debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método GetOrdersByStatus
    FUNCTION TestGetOrdersByStatus()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oOrderAPI.GetOrdersByStatus("processing", 1, 10)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetOrdersByStatus debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método GetRecentOrders
    FUNCTION TestGetRecentOrders()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oOrderAPI.GetRecentOrders(7, 1, 10)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetRecentOrders debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método GetOrderStats
    FUNCTION TestGetOrderStats()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oOrderAPI.GetOrderStats(DATE() - 30, DATE())
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetOrderStats debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar propiedades públicas
    FUNCTION TestPropiedadesPublicas()
    *
    *----------------------------------------------------------------------------*
        * Solo probar propiedades públicas accesibles a través de métodos
        LOCAL lcResponseCode
        lcResponseCode = THIS.oOrderAPI.GetLastResponseCode()
        THIS.AssertString(THIS.oOrderAPI.GetLastError(), 'GetLastError debe devolver un string')
        THIS.AssertTrue(TYPE("lcResponseCode") = "N", 'GetLastResponseCode debe devolver un número')
        THIS.AssertString(THIS.oOrderAPI.GetLastResponse(), 'GetLastResponse debe devolver un string')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar métodos públicos
    FUNCTION TestMetodosPublicos()
    *
    *----------------------------------------------------------------------------*
        THIS.AssertTrue(PEMSTATUS(THIS.oOrderAPI, "GetLastError", 5), 'GetLastError debe ser un método público')
        THIS.AssertTrue(PEMSTATUS(THIS.oOrderAPI, "GetOrders", 5), 'GetOrders debe ser un método público')
        THIS.AssertTrue(PEMSTATUS(THIS.oOrderAPI, "GetOrder", 5), 'GetOrder debe ser un método público')
        THIS.AssertTrue(PEMSTATUS(THIS.oOrderAPI, "CreateOrder", 5), 'CreateOrder debe ser un método público')
        THIS.AssertTrue(PEMSTATUS(THIS.oOrderAPI, "UpdateOrder", 5), 'UpdateOrder debe ser un método público')
        THIS.AssertTrue(PEMSTATUS(THIS.oOrderAPI, "DeleteOrder", 5), 'DeleteOrder debe ser un método público')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar manejo de errores
    FUNCTION TestManejoDeErrores()
    *
    *----------------------------------------------------------------------------*
        LOCAL lcErrorOriginal, lcErrorDespues
        
        * Obtener error original
        lcErrorOriginal = THIS.oOrderAPI.GetLastError()
        
        * Intentar operación que puede generar error
        THIS.oOrderAPI.GetOrder(999999)
        
        * Obtener error después de la operación
        lcErrorDespues = THIS.oOrderAPI.GetLastError()
        
        * Verificar que el manejo de errores funciona
        THIS.AssertString(lcErrorDespues, 'El error debe ser un string')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar tipos de datos de retorno
    FUNCTION TestTiposDeDatosDeRetorno()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult, llResult
        
        * Probar GetOrders
        oResult = THIS.oOrderAPI.GetOrders(1, 5)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetOrders debe devolver un objeto o NULL')
        
        * Probar GetOrder
        oResult = THIS.oOrderAPI.GetOrder(1)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetOrder debe devolver un objeto o NULL')
        
        * Probar CreateOrder
        LOCAL oOrderData
        oOrderData = CREATEOBJECT("Collection")
        oOrderData.Add("processing", "status")
        oResult = THIS.oOrderAPI.CreateOrder(oOrderData)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'CreateOrder debe devolver un objeto o NULL')
        
        * Probar UpdateOrder
        oResult = THIS.oOrderAPI.UpdateOrder(1, oOrderData)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'UpdateOrder debe devolver un objeto o NULL')
        
        * Probar DeleteOrder
        llResult = THIS.oOrderAPI.DeleteOrder(1)
        THIS.AssertTrue(TYPE("llResult") = "L", 'DeleteOrder debe devolver un valor lógico')
        
        * Probar GetLastError
        LOCAL lcResult
        lcResult = THIS.oOrderAPI.GetLastError()
        THIS.AssertTrue(TYPE("lcResult") = "C", 'GetLastError debe devolver un string')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar herencia de WooCommerceBaseAPI
    FUNCTION TestHerenciaDeWooCommerceBaseAPI()
    *
    *----------------------------------------------------------------------------*
        * Verificar que hereda métodos de la clase base
        THIS.AssertTrue(PEMSTATUS(THIS.oOrderAPI, "FormatDateForAPI", 5), 'Debe heredar FormatDateForAPI')
        THIS.AssertTrue(PEMSTATUS(THIS.oOrderAPI, "MakeRequest", 5), 'Debe heredar MakeRequest')
    ENDFUNC
    
ENDDEFINE 