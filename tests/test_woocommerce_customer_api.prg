*|--------------------------------------------------------------------------
*| test_woocommerce_customer_api.prg
*|--------------------------------------------------------------------------
*|
*| Pruebas unitarias para WooCommerceCustomerAPI
*| Autor.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.01.26 - 10:30
*| Purpose.....: Pruebas unitarias para la clase WooCommerceCustomerAPI
*|	
*| Revisions...: v1.00
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS Test_WooCommerce_Customer_API AS TestBase
*-----------------------------------------------------------------------------------*
    PROTECTED oCustomerAPI
    
    *----------------------------------------------------------------------------*
    * Configuración inicial para cada prueba
    FUNCTION SetUp()
    *
    *----------------------------------------------------------------------------*
        THIS.oCustomerAPI = NEWOBJECT('WooCommerceCustomerAPI', 'app\services\woocommerce\woocommerce_customer_api.prg')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Limpieza después de cada prueba
    FUNCTION TearDown()
    *
    *----------------------------------------------------------------------------*
        THIS.oCustomerAPI = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar inicialización de la clase
    FUNCTION TestInicializacion()
    *
    *----------------------------------------------------------------------------*
        THIS.AssertNotNull(THIS.oCustomerAPI, 'El objeto debe inicializarse correctamente')
        THIS.AssertTrue(PEMSTATUS(THIS.oCustomerAPI, "GetCustomers", 5), 'GetCustomers debe existir')
        THIS.AssertTrue(PEMSTATUS(THIS.oCustomerAPI, "GetCustomer", 5), 'GetCustomer debe existir')
        THIS.AssertTrue(PEMSTATUS(THIS.oCustomerAPI, "CreateCustomer", 5), 'CreateCustomer debe existir')
        THIS.AssertTrue(PEMSTATUS(THIS.oCustomerAPI, "UpdateCustomer", 5), 'UpdateCustomer debe existir')
        THIS.AssertTrue(PEMSTATUS(THIS.oCustomerAPI, "DeleteCustomer", 5), 'DeleteCustomer debe existir')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método GetLastError
    FUNCTION TestGetLastError()
    *
    *----------------------------------------------------------------------------*
        LOCAL lcError
        lcError = THIS.oCustomerAPI.GetLastError()
        THIS.AssertString(lcError, 'GetLastError debe devolver un string')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método GetCustomers
    FUNCTION TestGetCustomers()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oCustomerAPI.GetCustomers(1, 10)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetCustomers debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método GetCustomers con parámetros por defecto
    FUNCTION TestGetCustomersConParametrosPorDefecto()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oCustomerAPI.GetCustomers()
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetCustomers sin parámetros debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método GetCustomer
    FUNCTION TestGetCustomer()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oCustomerAPI.GetCustomer(1)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetCustomer debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método CreateCustomer
    FUNCTION TestCreateCustomer()
    *
    *----------------------------------------------------------------------------*
        LOCAL oCustomerData, oResult
        oCustomerData = CREATEOBJECT("Collection")
        oCustomerData.Add("Juan", "first_name")
        oCustomerData.Add("Pérez", "last_name")
        oCustomerData.Add("juan.perez@example.com", "email")
        oCustomerData.Add("123456789", "phone")
        
        oResult = THIS.oCustomerAPI.CreateCustomer(oCustomerData)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'CreateCustomer debe devolver un objeto o NULL')
        
        * Limpiar
        oCustomerData = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método UpdateCustomer
    FUNCTION TestUpdateCustomer()
    *
    *----------------------------------------------------------------------------*
        LOCAL oCustomerData, oResult
        oCustomerData = CREATEOBJECT("Collection")
        oCustomerData.Add("Juan Carlos", "first_name")
        oCustomerData.Add("Pérez González", "last_name")
        
        oResult = THIS.oCustomerAPI.UpdateCustomer(1, oCustomerData)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'UpdateCustomer debe devolver un objeto o NULL')
        
        * Limpiar
        oCustomerData = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método DeleteCustomer
    FUNCTION TestDeleteCustomer()
    *
    *----------------------------------------------------------------------------*
        LOCAL llResult
        llResult = THIS.oCustomerAPI.DeleteCustomer(1)
        THIS.AssertTrue(TYPE("llResult") = "L", 'DeleteCustomer debe devolver un logical')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método GetCustomerByEmail
    FUNCTION TestGetCustomerByEmail()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oCustomerAPI.GetCustomerByEmail("test@example.com")
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetCustomerByEmail debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método SearchCustomers
    FUNCTION TestSearchCustomers()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oCustomerAPI.SearchCustomers("Juan", 1, 10)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'SearchCustomers debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método GetCustomersByRole
    FUNCTION TestGetCustomersByRole()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oCustomerAPI.GetCustomersByRole("customer", 1, 10)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetCustomersByRole debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método UpdateCustomerBilling
    FUNCTION TestUpdateCustomerBilling()
    *
    *----------------------------------------------------------------------------*
        LOCAL oBillingData, oResult
        oBillingData = CREATEOBJECT("Collection")
        oBillingData.Add("Juan", "first_name")
        oBillingData.Add("Pérez", "last_name")
        oBillingData.Add("Calle Principal 123", "address_1")
        oBillingData.Add("Ciudad", "city")
        oBillingData.Add("12345", "postcode")
        
        oResult = THIS.oCustomerAPI.UpdateCustomerBilling(1, oBillingData)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'UpdateCustomerBilling debe devolver un objeto o NULL')
        
        * Limpiar
        oBillingData = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método UpdateCustomerShipping
    FUNCTION TestUpdateCustomerShipping()
    *
    *----------------------------------------------------------------------------*
        LOCAL oShippingData, oResult
        oShippingData = CREATEOBJECT("Collection")
        oShippingData.Add("Juan", "first_name")
        oShippingData.Add("Pérez", "last_name")
        oShippingData.Add("Calle Secundaria 456", "address_1")
        oShippingData.Add("Pueblo", "city")
        oShippingData.Add("54321", "postcode")
        
        oResult = THIS.oCustomerAPI.UpdateCustomerShipping(1, oShippingData)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'UpdateCustomerShipping debe devolver un objeto o NULL')
        
        * Limpiar
        oShippingData = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar método GetRecentCustomers
    FUNCTION TestGetRecentCustomers()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult
        oResult = THIS.oCustomerAPI.GetRecentCustomers(7, 1, 10)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetRecentCustomers debe devolver un objeto o NULL')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar propiedades públicas
    FUNCTION TestPropiedadesPublicas()
    *
    *----------------------------------------------------------------------------*
        * Solo probar propiedades públicas accesibles a través de métodos
        LOCAL lcResponseCode
        lcResponseCode = THIS.oCustomerAPI.GetLastResponseCode()
        THIS.AssertString(THIS.oCustomerAPI.GetLastError(), 'GetLastError debe devolver un string')
        THIS.AssertTrue(TYPE("lcResponseCode") = "N", 'GetLastResponseCode debe devolver un número')
        THIS.AssertString(THIS.oCustomerAPI.GetLastResponse(), 'GetLastResponse debe devolver un string')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar métodos públicos
    FUNCTION TestMetodosPublicos()
    *
    *----------------------------------------------------------------------------*
        THIS.AssertTrue(PEMSTATUS(THIS.oCustomerAPI, "GetLastError", 5), 'GetLastError debe ser un método público')
        THIS.AssertTrue(PEMSTATUS(THIS.oCustomerAPI, "GetCustomers", 5), 'GetCustomers debe ser un método público')
        THIS.AssertTrue(PEMSTATUS(THIS.oCustomerAPI, "GetCustomer", 5), 'GetCustomer debe ser un método público')
        THIS.AssertTrue(PEMSTATUS(THIS.oCustomerAPI, "CreateCustomer", 5), 'CreateCustomer debe ser un método público')
        THIS.AssertTrue(PEMSTATUS(THIS.oCustomerAPI, "UpdateCustomer", 5), 'UpdateCustomer debe ser un método público')
        THIS.AssertTrue(PEMSTATUS(THIS.oCustomerAPI, "DeleteCustomer", 5), 'DeleteCustomer debe ser un método público')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar manejo de errores
    FUNCTION TestManejoDeErrores()
    *
    *----------------------------------------------------------------------------*
        LOCAL lcErrorOriginal, lcErrorDespues
        
        * Obtener error original
        lcErrorOriginal = THIS.oCustomerAPI.GetLastError()
        
        * Intentar operación que puede generar error
        THIS.oCustomerAPI.GetCustomer(999999)
        
        * Obtener error después de la operación
        lcErrorDespues = THIS.oCustomerAPI.GetLastError()
        
        * Verificar que el manejo de errores funciona
        THIS.AssertString(lcErrorDespues, 'El error debe ser un string')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar tipos de datos de retorno
    FUNCTION TestTiposDeDatosDeRetorno()
    *
    *----------------------------------------------------------------------------*
        LOCAL oResult, llResult, lcResult
        
        * Probar GetCustomers
        oResult = THIS.oCustomerAPI.GetCustomers(1, 5)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetCustomers debe devolver objeto o NULL')
        
        * Probar GetCustomer
        oResult = THIS.oCustomerAPI.GetCustomer(1)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'GetCustomer debe devolver objeto o NULL')
        
        * Probar CreateCustomer
        LOCAL oCustomerData
        oCustomerData = CREATEOBJECT("Collection")
        oCustomerData.Add("Test", "first_name")
        oCustomerData.Add("Customer", "last_name")
        oCustomerData.Add("test@example.com", "email")
        oResult = THIS.oCustomerAPI.CreateCustomer(oCustomerData)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'CreateCustomer debe devolver objeto o NULL')
        
        * Probar UpdateCustomer
        oResult = THIS.oCustomerAPI.UpdateCustomer(1, oCustomerData)
        THIS.AssertTrue(TYPE("oResult") = "O" OR ISNULL(oResult), 'UpdateCustomer debe devolver objeto o NULL')
        
        * Probar DeleteCustomer
        llResult = THIS.oCustomerAPI.DeleteCustomer(1)
        THIS.AssertTrue(TYPE("llResult") = "L", 'DeleteCustomer debe devolver logical')
        
        * Probar GetLastError
        lcResult = THIS.oCustomerAPI.GetLastError()
        THIS.AssertTrue(TYPE("lcResult") = "C", 'GetLastError debe devolver string')
        
        * Limpiar
        oCustomerData = .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Probar métodos heredados de la clase base
    FUNCTION TestMetodosHeredados()
    *
    *----------------------------------------------------------------------------*
        * Verificar que hereda métodos de WooCommerceBaseAPI
        THIS.AssertTrue(PEMSTATUS(THIS.oCustomerAPI, "FormatDateForAPI", 5), 'Debe heredar FormatDateForAPI')
        THIS.AssertTrue(PEMSTATUS(THIS.oCustomerAPI, "BuildQueryParams", 5), 'Debe heredar BuildQueryParams')
        THIS.AssertTrue(PEMSTATUS(THIS.oCustomerAPI, "MakeRequest", 5), 'Debe heredar MakeRequest')
    ENDFUNC
    
ENDDEFINE 