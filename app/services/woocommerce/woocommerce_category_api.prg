*|--------------------------------------------------------------------------
*| woocommerce_category_api.prg
*|--------------------------------------------------------------------------
*|
*| Clase para comunicación con la API de categorías de WooCommerce
*| Autor.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.01.26 - 10:30
*| Purpose.....: Clase específica para comunicación con la API de categorías de WooCommerce
*|	
*| Revisions...: v1.00
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS WooCommerceCategoryAPI AS WooCommerceBaseAPI
*-----------------------------------------------------------------------------------*
	HIDDEN ;
		CLASSLIBRARY,COMMENT, ;
		BASECLASS,CONTROLCOUNT, ;
		CONTROLS,OBJECTS,OBJECT,;
		HEIGHT,HELPCONTEXTID,LEFT,NAME, ;
		PARENT,PARENTCLASS,PICTURE, ;
		TAG,TOP,WHATSTHISHELPID,WIDTH
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
    * Método para obtener categorías
    FUNCTION GetCategories(tnPage, tnPerPage)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCategories, loParams, lnPage, lnPerPage
        
        lnPage = IIF(EMPTY(tnPage), 1, tnPage)
        lnPerPage = IIF(EMPTY(tnPerPage), 50, tnPerPage)
        
        * Construir parámetros
        loParams = CREATEOBJECT("Collection")
        loParams.Add(ALLTRIM(STR(lnPage)), "page")
        loParams.Add(ALLTRIM(STR(lnPerPage)), "per_page")
        
        lcResponse = THIS.MakeRequest("products/categories", "GET", .NULL., loParams)
        
        IF !EMPTY(lcResponse)
            loCategories = THIS.oJSON.Parse(lcResponse)
            RETURN loCategories
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para obtener una categoría específica
    FUNCTION GetCategory(tnCategoryId)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCategory
        
        lcResponse = THIS.MakeRequest("products/categories/" + ALLTRIM(STR(tnCategoryId)), "GET")
        
        IF !EMPTY(lcResponse)
            loCategory = THIS.oJSON.Parse(lcResponse)
            RETURN loCategory
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para crear una categoría
    FUNCTION CreateCategory(toCategoryData)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCategory
        
        lcResponse = THIS.MakeRequest("products/categories", "POST", toCategoryData)
        IF !EMPTY(lcResponse)
            loCategory = THIS.oJSON.Parse(lcResponse)
            THIS.oLogger.Log("INFO", "Categoría creada exitosamente: " + ALLTRIM(STR(loCategory._id)))
            RETURN loCategory
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para actualizar una categoría
    FUNCTION UpdateCategory(tnCategoryId, toCategoryData)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCategory
        
        lcResponse = THIS.MakeRequest("products/categories/" + ALLTRIM(STR(tnCategoryId)), "PUT", toCategoryData)
        
        IF !EMPTY(lcResponse)
            loCategory = THIS.oJSON.Parse(lcResponse)
            THIS.oLogger.Log("INFO", "Categoría actualizada exitosamente: " + ALLTRIM(STR(tnCategoryId)))
            RETURN loCategory
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para eliminar una categoría
    FUNCTION DeleteCategory(tnCategoryId)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse
        
        lcResponse = THIS.MakeRequest("products/categories/" + ALLTRIM(STR(tnCategoryId)), "DELETE")
        
        IF !EMPTY(lcResponse)
            THIS.oLogger.Log("INFO", "Categoría eliminada exitosamente: " + ALLTRIM(STR(tnCategoryId)))
            RETURN .T.
        ENDIF
        
        RETURN .F.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para obtener categorías por slug
    FUNCTION GetCategoryBySlug(tcSlug)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCategories, loCategory
        
        lcResponse = THIS.MakeRequest("products/categories?slug=" + tcSlug, "GET")
        
        IF !EMPTY(lcResponse)
            loCategories = THIS.oJSON.Parse(lcResponse)
            
            * Verificar si hay categorías
            IF !ISNULL(loCategories) AND loCategories.Count > 0
                loCategory = loCategories.Item(1)
                RETURN loCategory
            ENDIF
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para buscar categorías
    FUNCTION SearchCategories(tcSearchTerm, tnPage, tnPerPage)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCategories, loParams, lnPage, lnPerPage
        
        * Parámetros por defecto
        lnPage = IIF(EMPTY(tnPage), 1, tnPage)
        lnPerPage = IIF(EMPTY(tnPerPage), 50, tnPerPage)
        
        * Construir parámetros
        loParams = CREATEOBJECT("Collection")
        loParams.Add(ALLTRIM(STR(lnPage)), "page")
        loParams.Add(ALLTRIM(STR(lnPerPage)), "per_page")
        loParams.Add(tcSearchTerm, "search")
        
        lcResponse = THIS.MakeRequest("products/categories", "GET", .NULL., loParams)
        
        IF !EMPTY(lcResponse)
            loCategories = THIS.oJSON.Parse(lcResponse)
            RETURN loCategories
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para obtener categorías padre
    FUNCTION GetParentCategories(tnPage, tnPerPage)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCategories, loParams, lnPage, lnPerPage
        
        * Parámetros por defecto
        lnPage = IIF(EMPTY(tnPage), 1, tnPage)
        lnPerPage = IIF(EMPTY(tnPerPage), 50, tnPerPage)
        
        * Construir parámetros
        loParams = CREATEOBJECT("Collection")
        loParams.Add(ALLTRIM(STR(lnPage)), "page")
        loParams.Add(ALLTRIM(STR(lnPerPage)), "per_page")
        loParams.Add("0", "parent")
        
        lcResponse = THIS.MakeRequest("products/categories", "GET", .NULL., loParams)
        
        IF !EMPTY(lcResponse)
            loCategories = THIS.oJSON.Parse(lcResponse)
            RETURN loCategories
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para obtener subcategorías
    FUNCTION GetSubcategories(tnParentId, tnPage, tnPerPage)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCategories, loParams, lnPage, lnPerPage
        
        lnPage = IIF(EMPTY(tnPage), 1, tnPage)
        lnPerPage = IIF(EMPTY(tnPerPage), 50, tnPerPage)
        
        * Construir parámetros
        loParams = CREATEOBJECT("Collection")
        loParams.Add(ALLTRIM(STR(lnPage)), "page")
        loParams.Add(ALLTRIM(STR(lnPerPage)), "per_page")
        loParams.Add(ALLTRIM(STR(tnParentId)), "parent")
        
        lcResponse = THIS.MakeRequest("products/categories", "GET", .NULL., loParams)
        
        IF !EMPTY(lcResponse)
            loCategories = THIS.oJSON.Parse(lcResponse)
            RETURN loCategories
        ENDIF
        
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para actualizar nombre de categoría
    FUNCTION UpdateCategoryName(tnCategoryId, tcName)
    *
    *----------------------------------------------------------------------------*
        LOCAL loCategoryData
        
        loCategoryData = CREATEOBJECT("Collection")
        loCategoryData.Add(tcName, "name")
        
        RETURN THIS.UpdateCategory(tnCategoryId, loCategoryData)
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para actualizar descripción de categoría
    FUNCTION UpdateCategoryDescription(tnCategoryId, tcDescription)
    *
    *----------------------------------------------------------------------------*
        LOCAL loCategoryData
        
        loCategoryData = CREATEOBJECT("Collection")
        loCategoryData.Add(tcDescription, "description")
        
        RETURN THIS.UpdateCategory(tnCategoryId, loCategoryData)
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Destructor
    FUNCTION Destroy()
    *
    *----------------------------------------------------------------------------*
    ENDFUNC
    
ENDDEFINE 