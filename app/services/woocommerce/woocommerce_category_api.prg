*|--------------------------------------------------------------------------
*| woocommerce_category_api.prg
*|--------------------------------------------------------------------------
*|
*| Clase para comunicaci�n con la API de categor�as de WooCommerce
*| Autor.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.01.26 - 10:30
*| Purpose.....: Clase espec�fica para comunicaci�n con la API de categor�as de WooCommerce
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
    * M�todo para obtener categor�as
    FUNCTION GetCategories(tnPage, tnPerPage)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCategories, loParams, lnPage, lnPerPage
        
        lnPage = IIF(EMPTY(tnPage), 1, tnPage)
        lnPerPage = IIF(EMPTY(tnPerPage), 50, tnPerPage)
        
        * Construir par�metros
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
    * M�todo para obtener una categor�a espec�fica
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
    * M�todo para crear una categor�a
    FUNCTION CreateCategory(toCategoryData)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCategory
        
        lcResponse = THIS.MakeRequest("products/categories", "POST", toCategoryData)
        IF !EMPTY(lcResponse)
            loCategory = THIS.oJSON.Parse(lcResponse)
            THIS.oLogger.Log("INFO", "Categor�a creada exitosamente: " + ALLTRIM(STR(loCategory._id)))
            RETURN loCategory
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * M�todo para actualizar una categor�a
    FUNCTION UpdateCategory(tnCategoryId, toCategoryData)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCategory
        
        lcResponse = THIS.MakeRequest("products/categories/" + ALLTRIM(STR(tnCategoryId)), "PUT", toCategoryData)
        
        IF !EMPTY(lcResponse)
            loCategory = THIS.oJSON.Parse(lcResponse)
            THIS.oLogger.Log("INFO", "Categor�a actualizada exitosamente: " + ALLTRIM(STR(tnCategoryId)))
            RETURN loCategory
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * M�todo para eliminar una categor�a
    FUNCTION DeleteCategory(tnCategoryId)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse
        
        lcResponse = THIS.MakeRequest("products/categories/" + ALLTRIM(STR(tnCategoryId)), "DELETE")
        
        IF !EMPTY(lcResponse)
            THIS.oLogger.Log("INFO", "Categor�a eliminada exitosamente: " + ALLTRIM(STR(tnCategoryId)))
            RETURN .T.
        ENDIF
        
        RETURN .F.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * M�todo para obtener categor�as por slug
    FUNCTION GetCategoryBySlug(tcSlug)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCategories, loCategory
        
        lcResponse = THIS.MakeRequest("products/categories?slug=" + tcSlug, "GET")
        
        IF !EMPTY(lcResponse)
            loCategories = THIS.oJSON.Parse(lcResponse)
            
            * Verificar si hay categor�as
            IF !ISNULL(loCategories) AND loCategories.Count > 0
                loCategory = loCategories.Item(1)
                RETURN loCategory
            ENDIF
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * M�todo para buscar categor�as
    FUNCTION SearchCategories(tcSearchTerm, tnPage, tnPerPage)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCategories, loParams, lnPage, lnPerPage
        
        * Par�metros por defecto
        lnPage = IIF(EMPTY(tnPage), 1, tnPage)
        lnPerPage = IIF(EMPTY(tnPerPage), 50, tnPerPage)
        
        * Construir par�metros
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
    * M�todo para obtener categor�as padre
    FUNCTION GetParentCategories(tnPage, tnPerPage)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCategories, loParams, lnPage, lnPerPage
        
        * Par�metros por defecto
        lnPage = IIF(EMPTY(tnPage), 1, tnPage)
        lnPerPage = IIF(EMPTY(tnPerPage), 50, tnPerPage)
        
        * Construir par�metros
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
    * M�todo para obtener subcategor�as
    FUNCTION GetSubcategories(tnParentId, tnPage, tnPerPage)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCategories, loParams, lnPage, lnPerPage
        
        lnPage = IIF(EMPTY(tnPage), 1, tnPage)
        lnPerPage = IIF(EMPTY(tnPerPage), 50, tnPerPage)
        
        * Construir par�metros
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
    * M�todo para actualizar nombre de categor�a
    FUNCTION UpdateCategoryName(tnCategoryId, tcName)
    *
    *----------------------------------------------------------------------------*
        LOCAL loCategoryData
        
        loCategoryData = CREATEOBJECT("Collection")
        loCategoryData.Add(tcName, "name")
        
        RETURN THIS.UpdateCategory(tnCategoryId, loCategoryData)
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * M�todo para actualizar descripci�n de categor�a
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