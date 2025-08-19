*|--------------------------------------------------------------------------
*| woocommerce_order_api.prg
*|--------------------------------------------------------------------------
*|
*| Clase para comunicaci�n con la API de pedidos de WooCommerce
*| Autor.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.01.26 - 10:30
*| Purpose.....: Clase espec�fica para comunicaci�n con la API de pedidos de WooCommerce
*|	
*| Revisions...: v1.00
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS WooCommerceOrderAPI AS WooCommerceBaseAPI
*-----------------------------------------------------------------------------------*
    *----------------------------------------------------------------------------*
    * Constructor
    FUNCTION Init()
    *
    *----------------------------------------------------------------------------*
        IF !DODEFAULT()
            RETURN .F.
        ENDIF
        RETURN .T.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * M�todo para obtener pedidos
    FUNCTION GetOrders(tnPage, tnPerPage, tdDateFrom, tdDateTo, tcStatus)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loOrders, loParams, lnPage, lnPerPage, ldDateFrom, ldDateTo
        
        * Par�metros por defecto
        lnPage = IIF(EMPTY(tnPage), 1, tnPage)
        lnPerPage = IIF(EMPTY(tnPerPage), 50, tnPerPage)
        
        * Construir par�metros
        loParams = CREATEOBJECT("Collection")
        loParams.Add(ALLTRIM(STR(lnPage)), "page")
        loParams.Add(ALLTRIM(STR(lnPerPage)), "per_page")
        
        * Agregar filtros de fecha
        IF !EMPTY(tdDateFrom)
            loParams.Add(THIS.FormatDateForAPI(tdDateFrom), "after")
        ENDIF
        
        IF !EMPTY(tdDateTo)
            loParams.Add(THIS.FormatDateForAPI(tdDateTo), "before")
        ENDIF
        
        * Agregar filtro de estado
        IF !EMPTY(tcStatus)
            loParams.Add(tcStatus, "status")
        ENDIF
        
        lcResponse = THIS.MakeRequest('orders', "GET", .NULL., loParams)
        
        IF !EMPTY(lcResponse)
            loOrders = THIS.oJSON.Parse(lcResponse)
            RETURN loOrders
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * M�todo para obtener un pedido espec�fico
    FUNCTION GetOrder(tnOrderId)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loOrder
        
        lcResponse = THIS.MakeRequest('orders/' + ALLTRIM(STR(tnOrderId)), "GET")
        
        IF !EMPTY(lcResponse)
            loOrder = THIS.oJSON.Parse(lcResponse)
            RETURN loOrder
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * M�todo para crear un pedido
    FUNCTION CreateOrder(toOrderData)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loOrder
        
        lcResponse = THIS.MakeRequest("orders", "POST", toOrderData)
        
        IF !EMPTY(lcResponse)
            loOrder = THIS.oJSON.Parse(lcResponse)
            RETURN loOrder
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * M�todo para actualizar un pedido
    FUNCTION UpdateOrder(tnOrderId, toOrderData)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loOrder
        
        lcResponse = THIS.MakeRequest('orders/' + ALLTRIM(STR(tnOrderId)), "PUT", toOrderData)
        
        IF !EMPTY(lcResponse)
            loOrder = THIS.oJSON.Parse(lcResponse)
            RETURN loOrder
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * M�todo para eliminar un pedido
    FUNCTION DeleteOrder(tnOrderId)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse
        
        lcResponse = THIS.MakeRequest('orders/' + ALLTRIM(STR(tnOrderId)), "DELETE")
        IF !EMPTY(lcResponse)
            RETURN .T.
        ENDIF
        RETURN .F.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * M�todo para actualizar estado de un pedido
    FUNCTION UpdateOrderStatus(tnOrderId, tcStatus)
    *
    *----------------------------------------------------------------------------*
        LOCAL loOrderData
        
        loOrderData = CREATEOBJECT("Collection")
        loOrderData.Add(tcStatus, "status")
        
        RETURN THIS.UpdateOrder(tnOrderId, loOrderData)
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * M�todo para obtener pedidos por cliente
    FUNCTION GetOrdersByCustomer(tnCustomerId, tnPage, tnPerPage)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loOrders, loParams, lnPage, lnPerPage, lnCustomerId
        
        * Par�metros por defecto
        lnPage = IIF(EMPTY(tnPage), 1, tnPage)
        lnPerPage = IIF(EMPTY(tnPerPage), 50, tnPerPage)
        lnCustomerId = IIF(EMPTY(tnCustomerId), 0, tnCustomerId)
        
        * Construir par�metros
        loParams = CREATEOBJECT("Collection")
        loParams.Add(ALLTRIM(STR(lnPage)), "page")
        loParams.Add(ALLTRIM(STR(lnPerPage)), "per_page")
        loParams.Add(ALLTRIM(STR(lnCustomerId)), "customer")
        
        lcResponse = THIS.MakeRequest('orders', "GET", .NULL., loParams)
        
        IF !EMPTY(lcResponse)
            loOrders = THIS.oJSON.Parse(lcResponse)
            RETURN loOrders
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * M�todo para obtener pedidos por estado
    FUNCTION GetOrdersByStatus(tcStatus, tnPage, tnPerPage)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loOrders, loParams, lnPage, lnPerPage
        
        * Par�metros por defecto
        lnPage = IIF(EMPTY(tnPage), 1, tnPage)
        lnPerPage = IIF(EMPTY(tnPerPage), 50, tnPerPage)
        
        * Construir par�metros
        loParams = CREATEOBJECT("Collection")
        loParams.Add(ALLTRIM(STR(lnPage)), "page")
        loParams.Add(ALLTRIM(STR(lnPerPage)), "per_page")
        loParams.Add(tcStatus, "status")
        
        lcResponse = THIS.MakeRequest('orders', "GET", .NULL., loParams)
        IF !EMPTY(lcResponse)
            loOrders = THIS.oJSON.Parse(lcResponse)
            RETURN loOrders
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * M�todo para obtener pedidos recientes
    FUNCTION GetRecentOrders(tnDays, tnPage, tnPerPage)
    *
    *----------------------------------------------------------------------------*
        LOCAL ldDateFrom
        
        ldDateFrom = DATE() - tnDays
        RETURN THIS.GetOrders(tnPage, tnPerPage, ldDateFrom, DATE(), "")
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * M�todo para obtener estad�sticas de pedidos
    FUNCTION GetOrderStats(tdDateFrom, tdDateTo, tnPage, tnPerPage)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loStats, loParams, lnPage, lnPerPage, ldDateFrom, ldDateTo
        
        * Par�metros por defecto
        lnPage = IIF(EMPTY(tnPage), 1, tnPage)
        lnPerPage = IIF(EMPTY(tnPerPage), 50, tnPerPage)
        
        * Construir par�metros
        loParams = CREATEOBJECT("Collection")
        loParams.Add(ALLTRIM(STR(lnPage)), "page")
        loParams.Add(ALLTRIM(STR(lnPerPage)), "per_page")
        
        * Agregar filtros de fecha
        IF !EMPTY(tdDateFrom)
            loParams.Add(THIS.FormatDateForAPI(tdDateFrom), "after")
        ENDIF
        
        IF !EMPTY(tdDateTo)
            loParams.Add(THIS.FormatDateForAPI(tdDateTo), "before")
        ENDIF
        
        lcResponse = THIS.MakeRequest('orders', "GET", .NULL., loParams)
        
        IF !EMPTY(lcResponse)
            loStats = THIS.oJSON.Parse(lcResponse)
            RETURN loStats
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Destructor
    FUNCTION Destroy()
    *
    *----------------------------------------------------------------------------*
    ENDFUNC
    
ENDDEFINE 