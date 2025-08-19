*|--------------------------------------------------------------------------
*| woocommerce_api.prg
*|--------------------------------------------------------------------------
*|
*| Clase coordinadora para comunicacin con la API de WooCommerce
*| Autor.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.08.04 - 19.38
*| Purpose.....: Clase coordinadora para comunicacin con la API de WooCommerce
*|	
*| Revisions...: v1.00
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS WooCommerceAPI AS WooCommerceBaseAPI
*-----------------------------------------------------------------------------------*
	HIDDEN ;
		CLASSLIBRARY,COMMENT, ;
		BASECLASS,CONTROLCOUNT, ;
		CONTROLS,OBJECTS,OBJECT,;
		HEIGHT,HELPCONTEXTID,LEFT,NAME, ;
		PARENT,PARENTCLASS,PICTURE, ;
		TAG,TOP,WHATSTHISHELPID,WIDTH
		
    * Propiedades protegidas para servicios especficos
    PROTECTED oProductAPI
    PROTECTED oOrderAPI
    PROTECTED oCustomerAPI
    PROTECTED oCategoryAPI
    PROTECTED oHTTPClient
    
    *----------------------------------------------------------------------------*
    FUNCTION Init()
    *
    *----------------------------------------------------------------------------*
        IF !DODEFAULT()
            RETURN .F.
        ENDIF
        
        * El HTTPClient ya está inicializado en la clase base (WooCommerceBaseAPI)
        * No es necesario crear uno nuevo aquí
        
        * Inicializar servicios especficos
        THIS.oProductAPI = NEWOBJECT("WooCommerceProductAPI", "app\services\woocommerce\woocommerce_product_api.prg")
        THIS.oOrderAPI = NEWOBJECT("WooCommerceOrderAPI", "app\services\woocommerce\woocommerce_order_api.prg")
        THIS.oCustomerAPI = NEWOBJECT("WooCommerceCustomerAPI", "app\services\woocommerce\woocommerce_customer_api.prg")
        THIS.oCategoryAPI = NEWOBJECT("WooCommerceCategoryAPI", "app\services\woocommerce\woocommerce_category_api.prg")
        
        IF ISNULL(THIS.oProductAPI) OR ISNULL(THIS.oOrderAPI) OR ISNULL(THIS.oCustomerAPI) OR ISNULL(THIS.oCategoryAPI)
            THIS.oLogger.Log("ERROR", "No se pudieron inicializar los servicios especficos de WooCommerce")
            RETURN .F.
        ENDIF
        
        RETURN .T.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * MTODOS DE PRODUCTOS - Delegados al servicio especfico
    *----------------------------------------------------------------------------*
    
    * Mtodo para obtener productos
    FUNCTION GetProducts(nPage, nPerPage, cStatus)
        RETURN THIS.oProductAPI.GetProducts(nPage, nPerPage, cStatus)
    ENDFUNC
    
    * Mtodo para obtener un producto especfico
    FUNCTION GetProduct(nProductId)
        RETURN THIS.oProductAPI.GetProduct(nProductId)
    ENDFUNC
    
    * Mtodo para crear un producto
    FUNCTION CreateProduct(oProductData)
        RETURN THIS.oProductAPI.CreateProduct(oProductData)
    ENDFUNC
    
    * Mtodo para actualizar un producto
    FUNCTION UpdateProduct(nProductId, oProductData)
        RETURN THIS.oProductAPI.UpdateProduct(nProductId, oProductData)
    ENDFUNC
    
    * Mtodo para eliminar un producto
    FUNCTION DeleteProduct(nProductId)
        RETURN THIS.oProductAPI.DeleteProduct(nProductId)
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * MTODOS DE PEDIDOS - Delegados al servicio especfico
    *----------------------------------------------------------------------------*
    
    * Mtodo para obtener pedidos
    FUNCTION GetOrders(nPage, nPerPage, dDateFrom, dDateTo, cStatus)
        RETURN THIS.oOrderAPI.GetOrders(nPage, nPerPage, dDateFrom, dDateTo, cStatus)
    ENDFUNC
    
    * Mtodo para obtener un pedido especfico
    FUNCTION GetOrder(nOrderId)
        RETURN THIS.oOrderAPI.GetOrder(nOrderId)
    ENDFUNC
    
    * Mtodo para actualizar un pedido
    FUNCTION UpdateOrder(nOrderId, oOrderData)
        RETURN THIS.oOrderAPI.UpdateOrder(nOrderId, oOrderData)
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * MTODOS DE CLIENTES - Delegados al servicio especfico
    *----------------------------------------------------------------------------*
    
    * Mtodo para obtener clientes
    FUNCTION GetCustomers(nPage, nPerPage)
        RETURN THIS.oCustomerAPI.GetCustomers(nPage, nPerPage)
    ENDFUNC
    
    * Mtodo para crear un cliente
    FUNCTION CreateCustomer(oCustomerData)
        RETURN THIS.oCustomerAPI.CreateCustomer(oCustomerData)
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * MTODOS DE CATEGORAS - Delegados al servicio especfico
    *----------------------------------------------------------------------------*
    
    * Mtodo para obtener categoras
    FUNCTION GetCategories(nPage, nPerPage)
        RETURN THIS.oCategoryAPI.GetCategories(nPage, nPerPage)
    ENDFUNC
    
    * Mtodo para crear una categora
    FUNCTION CreateCategory(oCategoryData)
        RETURN THIS.oCategoryAPI.CreateCategory(oCategoryData)
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * MTODOS PARA OBTENER SERVICIOS ESPECFICOS
    *----------------------------------------------------------------------------*
    
    * Mtodo para obtener servicio de productos
    FUNCTION GetProductAPI()
        RETURN THIS.oProductAPI
    ENDFUNC
    
    * Mtodo para obtener servicio de pedidos
    FUNCTION GetOrderAPI()
        RETURN THIS.oOrderAPI
    ENDFUNC
    
    * Mtodo para obtener servicio de clientes
    FUNCTION GetCustomerAPI()
        RETURN THIS.oCustomerAPI
    ENDFUNC
    
    * Mtodo para obtener servicio de categoras
    FUNCTION GetCategoryAPI()
        RETURN THIS.oCategoryAPI
    ENDFUNC
    
    * Mtodo para obtener HTTPClient
    FUNCTION GetHTTPClient()
        RETURN THIS.oHTTPClient
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * MTODOS DE UTILIDAD
    *----------------------------------------------------------------------------*
    
    * Mtodo para obtener el ultimo error de cualquier servicio
    FUNCTION GetLastError()
        * Intentar obtener error del servicio correspondiente
        IF !EMPTY(THIS.oProductAPI.GetLastError())
            RETURN THIS.oProductAPI.GetLastError()
        ENDIF
        
        IF !EMPTY(THIS.oOrderAPI.GetLastError())
            RETURN THIS.oOrderAPI.GetLastError()
        ENDIF
        
        IF !EMPTY(THIS.oCustomerAPI.GetLastError())
            RETURN THIS.oCustomerAPI.GetLastError()
        ENDIF
        
        IF !EMPTY(THIS.oCategoryAPI.GetLastError())
            RETURN THIS.oCategoryAPI.GetLastError()
        ENDIF
        
        * Si no hay errores en servicios específicos, verificar HTTPClient
        IF !EMPTY(THIS.oHTTPClient.getLastError())
            RETURN THIS.oHTTPClient.getLastError()
        ENDIF
        
        RETURN THIS.cLastError
    ENDFUNC
    
    * Mtodo para limpiar errores de todos los servicios
    FUNCTION ClearAllErrors()
        THIS.cLastError = ""
        THIS.oProductAPI.ClearLastError()
        THIS.oOrderAPI.ClearLastError()
        THIS.oCustomerAPI.ClearLastError()
        THIS.oCategoryAPI.ClearLastError()
        THIS.oHTTPClient.clearLastResponse()
    ENDFUNC
    
    * Mtodo para probar conectividad de todos los servicios
    FUNCTION TestConnectivity()
        LOCAL llProductTest, llOrderTest, llCustomerTest, llCategoryTest
        
        llProductTest = !ISNULL(THIS.oProductAPI.GetProducts(1, 1))
        llOrderTest = !ISNULL(THIS.oOrderAPI.GetOrders(1, 1))
        llCustomerTest = !ISNULL(THIS.oCustomerAPI.GetCustomers(1, 1))
        llCategoryTest = !ISNULL(THIS.oCategoryAPI.GetCategories(1, 1))
        
        IF llProductTest AND llOrderTest AND llCustomerTest AND llCategoryTest
            THIS.oLogger.Log("INFO", "Conectividad de servicios WooCommerce exitosa")
            RETURN .T.
        ENDIF
        
        THIS.cLastError = "Error de conectividad en servicios WooCommerce"
        THIS.oLogger.Log("ERROR", THIS.cLastError)
        RETURN .F.
    ENDFUNC
    
    * Mtodo para obtener estadsticas de la API
    FUNCTION GetAPIStats()
        LOCAL oStats
        
        oStats = CREATEOBJECT("Collection")
        
        * Obtener estadsticas de cada servicio
        oStats.Add(THIS.oProductAPI.GetLastResponseCode(), "product_api_response_code")
        oStats.Add(THIS.oOrderAPI.GetLastResponseCode(), "order_api_response_code")
        oStats.Add(THIS.oCustomerAPI.GetLastResponseCode(), "customer_api_response_code")
        oStats.Add(THIS.oCategoryAPI.GetLastResponseCode(), "category_api_response_code")
        
        * Agregar estadísticas del HTTPClient
        oStats.Add(THIS.oHTTPClient.getLastResponseCode(), "http_client_response_code")
        oStats.Add(THIS.oHTTPClient.getLastStatusText(), "http_client_status_text")
        
        RETURN oStats
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Destructor
    FUNCTION Destroy()
    *
    *----------------------------------------------------------------------------*
    ENDFUNC
    
ENDDEFINE 