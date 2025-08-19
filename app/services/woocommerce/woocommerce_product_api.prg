*|--------------------------------------------------------------------------
*| woocommerce_product_api.prg
*|--------------------------------------------------------------------------
*|
*| Clase para comunicación con la API de productos de WooCommerce
*| Autor.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.01.26 - 10:30
*| Purpose.....: Clase específica para comunicación con la API de productos de WooCommerce
*|	
*| Revisions...: v1.00
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS WooCommerceProductAPI AS WooCommerceBaseAPI
*-----------------------------------------------------------------------------------*
	HIDDEN ;
		CLASSLIBRARY,COMMENT, ;
		BASECLASS,CONTROLCOUNT, ;
		CONTROLS,OBJECTS,OBJECT,;
		HEIGHT,HELPCONTEXTID,LEFT,NAME, ;
		PARENT,PARENTCLASS,PICTURE, ;
		TAG,TOP,WHATSTHISHELPID,WIDTH
		
    * Propiedades protegidas (heredadas de WooCommerceBaseAPI)
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
    * Método para establecer el HTTPClient (compatibilidad)
    FUNCTION setHTTPClient(toHTTPClient)
    *
    *----------------------------------------------------------------------------*
        * Este método se mantiene por compatibilidad, pero no es necesario
        * ya que el HTTPClient se inicializa automáticamente en la clase base
        IF VARTYPE(toHTTPClient) = 'O'
            * Actualizar la referencia del HTTPClient heredado
            THIS.oHTTPClient = toHTTPClient
            RETURN .T.
        ENDIF
        RETURN .F.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para obtener productos
    FUNCTION GetProducts(tnPage, tnPerPage, tcStatus)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loProducts, lnPage, lnPerPage, loParams
        
        * Parámetros por defecto
        lnPage = IIF(EMPTY(tnPage), 1, tnPage)
        lnPerPage = IIF(EMPTY(tnPerPage), 50, tnPerPage)
        
        * Construir parámetros
        loParams = CREATEOBJECT("Collection")
        loParams.Add(ALLTRIM(STR(lnPage)), "page")
        loParams.Add(ALLTRIM(STR(lnPerPage)), "per_page")
        IF !EMPTY(tcStatus)
            loParams.Add(tcStatus, "status")
        ENDIF
        
        lcResponse = THIS.MakeRequest('products', "GET", .NULL., loParams)
        IF !EMPTY(lcResponse)
            loProducts = THIS.oJSON.Parse(lcResponse)
            RETURN loProducts
        ENDIF
        
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para obtener un producto específico
    FUNCTION GetProduct(tnProductId)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loProduct, lnProductId
        
        lnProductId = IIF(EMPTY(tnProductId), 0, tnProductId)
        
        lcResponse = THIS.MakeRequest("products/" + ALLTRIM(STR(lnProductId)), "GET")
        
        IF !EMPTY(lcResponse)
            loProduct = THIS.oJSON.Parse(lcResponse)
            RETURN loProduct
        ENDIF
        
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para crear un producto
    FUNCTION CreateProduct(toProductData)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loProduct 
        
        lcResponse = THIS.MakeRequest("products", "POST", toProductData, .NULL.)
        IF !EMPTY(lcResponse)
            loProduct = THIS.oJSON.Parse(lcResponse)
            THIS.oLogger.Log("INFO", "Producto creado exitosamente: " + ALLTRIM(STR(loProduct._id)))
            RETURN loProduct
        ENDIF
        
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para actualizar un producto
    FUNCTION UpdateProduct(tnProductId, toProductData)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loProduct, lnProductId
        
        lnProductId = IIF(EMPTY(tnProductId), 0, tnProductId)
        
        lcResponse = THIS.MakeRequest("products/" + ALLTRIM(STR(lnProductId)), "PUT", toProductData, .NULL.)
        IF !EMPTY(lcResponse)
            loProduct = THIS.oJSON.Parse(lcResponse)
            THIS.oLogger.Log("INFO", "Producto actualizado exitosamente: " + ALLTRIM(STR(lnProductId)))
            RETURN loProduct
        ENDIF
        
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para eliminar un producto
    FUNCTION DeleteProduct(tnProductId)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse
        
        lcResponse = THIS.MakeRequest("products/" + ALLTRIM(STR(tnProductId)), "DELETE")
        IF !EMPTY(lcResponse)
            THIS.oLogger.Log("INFO", "Producto eliminado exitosamente: " + ALLTRIM(STR(tnProductId)))
            RETURN .T.
        ENDIF
        RETURN .F.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para obtener productos por SKU
    FUNCTION GetProductBySKU(tcSKU)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loProducts, loProduct
        
        tcSKU = IIF(EMPTY(tcSKU), "", tcSKU)
        
        lcResponse = THIS.MakeRequest("products?sku=" + tcSKU, "GET")
        IF !EMPTY(lcResponse)
            loProducts = THIS.oJSON.Parse(lcResponse)
            
            IF !ISNULL(loProducts) AND loProducts.Count > 0
                loProduct = loProducts.Item(1)
                RETURN loProduct
            ENDIF
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para obtener productos por categoría
    FUNCTION GetProductsByCategory(tnCategoryId, tnPage, tnPerPage)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loProducts, loParams, lnPage, lnPerPage
        
        lnPage = IIF(EMPTY(tnPage), 1, tnPage)
        lnPerPage = IIF(EMPTY(tnPerPage), 50, tnPerPage)
        
        * Construir parámetros
        loParams = CREATEOBJECT("Collection")
        loParams.Add(ALLTRIM(STR(lnPage)), "page")
        loParams.Add(ALLTRIM(STR(lnPerPage)), "per_page")
        loParams.Add(ALLTRIM(STR(tnCategoryId)), "category")
        
        lcResponse = THIS.MakeRequest("products", "GET", .NULL., loParams)
        
        IF !EMPTY(lcResponse)
            loProducts = THIS.oJSON.Parse(lcResponse)
            RETURN loProducts
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para obtener productos con stock bajo
    FUNCTION GetProductsLowStock(tnThreshold, tnPage, tnPerPage)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loProducts, loParams, lnPage, lnPerPage, lnThreshold
        
        * Parámetros por defecto
        lnThreshold = IIF(EMPTY(tnThreshold), 10, tnThreshold)
        lnPage = IIF(EMPTY(tnPage), 1, tnPage)
        lnPerPage = IIF(EMPTY(tnPerPage), 50, tnPerPage)
        
        * Construir parámetros
        loParams = CREATEOBJECT("Collection")
        loParams.Add(ALLTRIM(STR(lnPage)), "page")
        loParams.Add(ALLTRIM(STR(lnPerPage)), "per_page")
        loParams.Add("true","manage_stock")
        loParams.Add("instock","stock_status")
        
        lcResponse = THIS.MakeRequest("products", "GET", .NULL., loParams)
        IF !EMPTY(lcResponse)
            loProducts = THIS.oJSON.Parse(lcResponse)
            RETURN loProducts
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para actualizar stock de un producto
    FUNCTION UpdateProductStock(tnProductId, tnStockQuantity)
    *
    *----------------------------------------------------------------------------*
        LOCAL loProductData
        
        loProductData = CREATEOBJECT("Collection")
        loProductData.Add(tnStockQuantity, "stock_quantity")
        loProductData.Add(.T., "manage_stock")
        
        RETURN THIS.UpdateProduct(tnProductId, loProductData)
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para actualizar precio de un producto
    FUNCTION UpdateProductPrice(tnProductId, tnPrice)
    *
    *----------------------------------------------------------------------------*
        LOCAL loProductData
        
        loProductData = CREATEOBJECT("Collection")
        loProductData.Add(ALLTRIM(STR(tnPrice)), "regular_price")
        
        RETURN THIS.UpdateProduct(tnProductId, loProductData)
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para limpiar el último error
    FUNCTION ClearLastError()
    *
    *----------------------------------------------------------------------------*
        THIS.cLastError = ""
        THIS.nLastResponseCode = 0
        THIS.cLastResponse = ""
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Destructor
    FUNCTION Destroy()
    *
    *----------------------------------------------------------------------------*
    ENDFUNC
    
ENDDEFINE 