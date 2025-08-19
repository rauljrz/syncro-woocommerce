*|--------------------------------------------------------------------------
*| test_woocommerce_category_api.prg
*|--------------------------------------------------------------------------
*|
*| Pruebas unitarias para WooCommerceCategoryAPI
*| Autor.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.01.26 - 10:30
*| Purpose.....: Pruebas unitarias para la clase WooCommerceCategoryAPI
*|	
*| Revisions...: v1.00
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS Test_WooCommerce_Category_API AS TestBase
*-----------------------------------------------------------------------------------*
    PROTECTED oCategoryAPI
    
    *----------------------------------------------------------------------------*
    * Configuraci�n inicial para cada prueba
    FUNCTION SetUp()
    *
    *----------------------------------------------------------------------------*
        THIS.oCategoryAPI = NEWOBJECT('WooCommerceCategoryAPI', 'app\services\woocommerce\woocommerce_category_api.prg')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Limpieza despu�s de cada prueba
    FUNCTION TearDown()
    *
    *----------------------------------------------------------------------------*
        THIS.oCategoryAPI = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar inicializaci�n de la clase
    FUNCTION TestInicializacion()
    *
    *----------------------------------------------------------------------------*
        THIS.AssertNotNull(THIS.oCategoryAPI, 'El objeto debe inicializarse correctamente')
        THIS.AssertTrue(PEMSTATUS(THIS.oCategoryAPI, "GetCategories", 5), 'GetCategories debe existir')
        THIS.AssertTrue(PEMSTATUS(THIS.oCategoryAPI, "GetCategory", 5), 'GetCategory debe existir')
        THIS.AssertTrue(PEMSTATUS(THIS.oCategoryAPI, "CreateCategory", 5), 'CreateCategory debe existir')
        THIS.AssertTrue(PEMSTATUS(THIS.oCategoryAPI, "UpdateCategory", 5), 'UpdateCategory debe existir')
        THIS.AssertTrue(PEMSTATUS(THIS.oCategoryAPI, "DeleteCategory", 5), 'DeleteCategory debe existir')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo GetLastError
    FUNCTION TestGetLastError()
    *
    *----------------------------------------------------------------------------*
        LOCAL lcError
        lcError = THIS.oCategoryAPI.GetLastError()
        THIS.AssertString(lcError, 'GetLastError debe devolver un string')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo GetCategories
    FUNCTION TestGetCategories()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oCategoryAPI.GetCategories(1, 10)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetCategories debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo GetCategories con par�metros por defecto
    FUNCTION TestGetCategoriesConParametrosPorDefecto()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oCategoryAPI.GetCategories()
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetCategories sin par�metros debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo GetCategory
    FUNCTION TestGetCategory()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oCategoryAPI.GetCategory(1)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetCategory debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo CreateCategory
    FUNCTION TestCreateCategory()
    *
    *----------------------------------------------------------------------------*
        LOCAL oCategoryData, oResult
        oCategoryData = CREATEOBJECT("Collection")
        oCategoryData.Add("Test Category", "name")
        oCategoryData.Add("Test category description", "description")
        
        oResult = THIS.oCategoryAPI.CreateCategory(oCategoryData)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'CreateCategory debe devolver un objeto o NULL')
        
        * Limpiar
        oCategoryData = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo UpdateCategory
    FUNCTION TestUpdateCategory()
    *
    *----------------------------------------------------------------------------*
        LOCAL oCategoryData, oResult
        oCategoryData = CREATEOBJECT("Collection")
        oCategoryData.Add("Updated Category", "name")
        oCategoryData.Add("Updated category description", "description")
        
        oResult = THIS.oCategoryAPI.UpdateCategory(1, oCategoryData)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'UpdateCategory debe devolver un objeto o NULL')
        
        * Limpiar
        oCategoryData = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo DeleteCategory
    FUNCTION TestDeleteCategory()
    *
    *----------------------------------------------------------------------------*
        LOCAL llResult
        llResult = THIS.oCategoryAPI.DeleteCategory(1)
        THIS.AssertTrue(TYPE("llResult") = "L", 'DeleteCategory debe devolver un logical')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo GetCategoryBySlug
    FUNCTION TestGetCategoryBySlug()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oCategoryAPI.GetCategoryBySlug("test-category")
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetCategoryBySlug debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo SearchCategories
    FUNCTION TestSearchCategories()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oCategoryAPI.SearchCategories("test", 1, 10)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'SearchCategories debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo GetParentCategories
    FUNCTION TestGetParentCategories()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oCategoryAPI.GetParentCategories(1, 10)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetParentCategories debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo GetSubcategories
    FUNCTION TestGetSubcategories()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oCategoryAPI.GetSubcategories(1, 1, 10)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetSubcategories debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo UpdateCategoryName
    FUNCTION TestUpdateCategoryName()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oCategoryAPI.UpdateCategoryName(1, "New Category Name")
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'UpdateCategoryName debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todo UpdateCategoryDescription
    FUNCTION TestUpdateCategoryDescription()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oCategoryAPI.UpdateCategoryDescription(1, "New category description")
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'UpdateCategoryDescription debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar propiedades p�blicas
    FUNCTION TestPropiedadesPublicas()
    *
    *----------------------------------------------------------------------------*
    	LOCAL lcResponseCode
        lcResponseCode = THIS.oCategoryAPI.GetLastResponseCode()
        THIS.AssertString(THIS.oCategoryAPI.GetLastError(), 'GetLastError debe devolver un string')
        THIS.AssertTrue(TYPE("lcResponseCode") = "N", 'GetLastResponseCode debe devolver un n�mero')
        THIS.AssertString(THIS.oCategoryAPI.GetLastResponse(), 'GetLastResponse debe devolver un string')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todos p�blicos
    FUNCTION TestMetodosPublicos()
    *
    *----------------------------------------------------------------------------*
        THIS.AssertTrue(PEMSTATUS(THIS.oCategoryAPI, "GetLastError", 5), 'GetLastError debe ser un m�todo p�blico')
        THIS.AssertTrue(PEMSTATUS(THIS.oCategoryAPI, "GetCategories", 5), 'GetCategories debe ser un m�todo p�blico')
        THIS.AssertTrue(PEMSTATUS(THIS.oCategoryAPI, "GetCategory", 5), 'GetCategory debe ser un m�todo p�blico')
        THIS.AssertTrue(PEMSTATUS(THIS.oCategoryAPI, "CreateCategory", 5), 'CreateCategory debe ser un m�todo p�blico')
        THIS.AssertTrue(PEMSTATUS(THIS.oCategoryAPI, "UpdateCategory", 5), 'UpdateCategory debe ser un m�todo p�blico')
        THIS.AssertTrue(PEMSTATUS(THIS.oCategoryAPI, "DeleteCategory", 5), 'DeleteCategory debe ser un m�todo p�blico')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar manejo de errores
    FUNCTION TestManejoDeErrores()
    *
    *----------------------------------------------------------------------------*
        LOCAL lcErrorOriginal, lcErrorDespues
        
        lcErrorOriginal = THIS.oCategoryAPI.GetLastError()
        THIS.oCategoryAPI.GetCategory(999999)
        
        lcErrorDespues = THIS.oCategoryAPI.GetLastError()
        THIS.AssertString(lcErrorDespues, 'El error debe ser un string')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar tipos de datos de retorno
    FUNCTION TestTiposDeDatosDeRetorno()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult, llResult, lcResult
        
        * Probar GetCategories
        oResult = THIS.oCategoryAPI.GetCategories(1, 5)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetCategories debe devolver objeto o NULL')
        
        * Probar GetCategory
        oResult = THIS.oCategoryAPI.GetCategory(1)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetCategory debe devolver objeto o NULL')
        
        * Probar CreateCategory
        LOCAL oCategoryData
        oCategoryData = CREATEOBJECT("Collection")
        oCategoryData.Add("Test", "name")
        oResult = THIS.oCategoryAPI.CreateCategory(oCategoryData)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'CreateCategory debe devolver objeto o NULL')
        
        * Probar UpdateCategory
        oResult = THIS.oCategoryAPI.UpdateCategory(1, oCategoryData)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'UpdateCategory debe devolver objeto o NULL')
        
        * Probar DeleteCategory
        llResult = THIS.oCategoryAPI.DeleteCategory(1)
        THIS.AssertTrue(TYPE("llResult") = "L", 'DeleteCategory debe devolver logical')
        
        * Probar GetLastError
        lcResult = THIS.oCategoryAPI.GetLastError()
        THIS.AssertTrue(TYPE("lcResult") = "C", 'GetLastError debe devolver string')
        
        * Limpiar
        oCategoryData = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar m�todos heredados de la clase base
    FUNCTION TestMetodosHeredados()
    *
    *----------------------------------------------------------------------------*
        * Verificar que hereda m�todos de WooCommerceBaseAPI
        THIS.AssertTrue(PEMSTATUS(THIS.oCategoryAPI, "FormatDateForAPI", 5), 'Debe heredar FormatDateForAPI')
        THIS.AssertTrue(PEMSTATUS(THIS.oCategoryAPI, "BuildQueryParams", 5), 'Debe heredar BuildQueryParams')
        THIS.AssertTrue(PEMSTATUS(THIS.oCategoryAPI, "MakeRequest", 5), 'Debe heredar MakeRequest')
    ENDFUNC
    
ENDDEFINE 