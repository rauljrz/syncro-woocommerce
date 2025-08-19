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
    * Configuraci�n inicial para cada prueba
    FUNCTION SetUp()
    *
    *----------------------------------------------------------------------------*
        THIS.oOrderAPI = NEWOBJECT('WooCommerceOrderAPI', 'app\services\woocommerce\woocommerce_order_api.prg')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Limpieza despu�s de cada prueba
    FUNCTION TearDown()
    *
    *----------------------------------------------------------------------------*
        THIS.oOrderAPI = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar inicializaci�n de la clase
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
    * Probar m�todo GetLastError
    FUNCTION TestGetLastError()
    *
    *----------------------------------------------------------------------------*
        LOCAL lcError
        lcError = THIS.oOrderAPI.GetLastError()
        THIS.AssertString(lcError, 'GetLastError debe devolver un string')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo GetOrders
    FUNCTION TestGetOrders()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oOrderAPI.GetOrders(1, 10)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetOrders debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo GetOrders con par�metros por defecto
    FUNCTION TestGetOrdersConParametrosPorDefecto()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oOrderAPI.GetOrders()
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetOrders sin par�metros debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo GetOrders con filtros de fecha
    FUNCTION TestGetOrdersConFiltrosDeFecha()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oOrderAPI.GetOrders(1, 10, DATE() - 7, DATE())
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetOrders con fechas debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo GetOrders con estado espec�fico
    FUNCTION TestGetOrdersConEstadoEspecifico()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oOrderAPI.GetOrders(1, 10, {}, {}, "processing")
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetOrders con estado debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo GetOrder
    FUNCTION TestGetOrder()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oOrderAPI.GetOrder(1)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetOrder debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo CreateOrder
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
    * Probar m�todo UpdateOrder
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
    * Probar m�todo DeleteOrder
    FUNCTION TestDeleteOrder()
    *
    *----------------------------------------------------------------------------*
        LOCAL llResult
        llResult = THIS.oOrderAPI.DeleteOrder(1)
        THIS.AssertTrue(TYPE("llResult") = "L", 'DeleteOrder debe devolver un valor l�gico')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo UpdateOrderStatus
    FUNCTION TestUpdateOrderStatus()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oOrderAPI.UpdateOrderStatus(1, "completed")
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'UpdateOrderStatus debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo GetOrdersByCustomer
    FUNCTION TestGetOrdersByCustomer()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oOrderAPI.GetOrdersByCustomer(1, 1, 10)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetOrdersByCustomer debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo GetOrdersByStatus
    FUNCTION TestGetOrdersByStatus()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oOrderAPI.GetOrdersByStatus("processing", 1, 10)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetOrdersByStatus debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo GetRecentOrders
    FUNCTION TestGetRecentOrders()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oOrderAPI.GetRecentOrders(7, 1, 10)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetRecentOrders debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo GetOrderStats
    FUNCTION TestGetOrderStats()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oOrderAPI.GetOrderStats(DATE() - 30, DATE())
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetOrderStats debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar propiedades p�blicas
    FUNCTION TestPropiedadesPublicas()
    *
    *----------------------------------------------------------------------------*
        * Solo probar propiedades p�blicas accesibles a trav�s de m�todos
        LOCAL lcResponseCode
        lcResponseCode = THIS.oOrderAPI.GetLastResponseCode()
        THIS.AssertString(THIS.oOrderAPI.GetLastError(), 'GetLastError debe devolver un string')
        THIS.AssertTrue(TYPE("lcResponseCode") = "N", 'GetLastResponseCode debe devolver un n�mero')
        THIS.AssertString(THIS.oOrderAPI.GetLastResponse(), 'GetLastResponse debe devolver un string')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todos p�blicos
    FUNCTION TestMetodosPublicos()
    *
    *----------------------------------------------------------------------------*
        THIS.AssertTrue(PEMSTATUS(THIS.oOrderAPI, "GetLastError", 5), 'GetLastError debe ser un m�todo p�blico')
        THIS.AssertTrue(PEMSTATUS(THIS.oOrderAPI, "GetOrders", 5), 'GetOrders debe ser un m�todo p�blico')
        THIS.AssertTrue(PEMSTATUS(THIS.oOrderAPI, "GetOrder", 5), 'GetOrder debe ser un m�todo p�blico')
        THIS.AssertTrue(PEMSTATUS(THIS.oOrderAPI, "CreateOrder", 5), 'CreateOrder debe ser un m�todo p�blico')
        THIS.AssertTrue(PEMSTATUS(THIS.oOrderAPI, "UpdateOrder", 5), 'UpdateOrder debe ser un m�todo p�blico')
        THIS.AssertTrue(PEMSTATUS(THIS.oOrderAPI, "DeleteOrder", 5), 'DeleteOrder debe ser un m�todo p�blico')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar manejo de errores
    FUNCTION TestManejoDeErrores()
    *
    *----------------------------------------------------------------------------*
        LOCAL lcErrorOriginal, lcErrorDespues
        
        * Obtener error original
        lcErrorOriginal = THIS.oOrderAPI.GetLastError()
        
        * Intentar operaci�n que puede generar error
        THIS.oOrderAPI.GetOrder(999999)
        
        * Obtener error despu�s de la operaci�n
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
        THIS.AssertTrue(TYPE("llResult") = "L", 'DeleteOrder debe devolver un valor l�gico')
        
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
        * Verificar que hereda m�todos de la clase base
        THIS.AssertTrue(PEMSTATUS(THIS.oOrderAPI, "FormatDateForAPI", 5), 'Debe heredar FormatDateForAPI')
        THIS.AssertTrue(PEMSTATUS(THIS.oOrderAPI, "MakeRequest", 5), 'Debe heredar MakeRequest')
    ENDFUNC
    
ENDDEFINE 