*|--------------------------------------------------------------------------
*| woocommerce_customer_api.prg
*|--------------------------------------------------------------------------
*|
*| Clase para comunicación con la API de clientes de WooCommerce
*| Autor.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.01.26 - 10:30
*| Purpose.....: Clase específica para comunicación con la API de clientes de WooCommerce
*|	
*| Revisions...: v1.00
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS WooCommerceCustomerAPI AS WooCommerceBaseAPI
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
    * Método para obtener clientes
    FUNCTION GetCustomers(tnPage, tnPerPage)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCustomers, loParams, lnPage, lnPerPage
        
        * Parámetros por defecto
        lnPage = IIF(EMPTY(tnPage), 1, tnPage)
        lnPerPage = IIF(EMPTY(tnPerPage), 50, tnPerPage)
        
        * Construir parámetros
        loParams = CREATEOBJECT("Collection")
        loParams.Add(ALLTRIM(STR(lnPage)), "page")
        loParams.Add(ALLTRIM(STR(lnPerPage)), "per_page")
        
        lcResponse = THIS.MakeRequest('customers', "GET", .NULL., loParams)
        IF !EMPTY(lcResponse)
            loCustomers = THIS.oJSON.Parse(lcResponse)
            RETURN loCustomers
        ENDIF
        
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para obtener un cliente específico
    FUNCTION GetCustomer(tnCustomerId)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCustomer
        
        lcResponse = THIS.MakeRequest('customers/' + ALLTRIM(STR(tnCustomerId)), "GET")
        
        IF !EMPTY(lcResponse)
            loCustomer = THIS.oJSON.Parse(lcResponse)
            RETURN loCustomer
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para crear un cliente
    FUNCTION CreateCustomer(oCustomerData)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCustomer
        
        lcResponse = THIS.MakeRequest("customers", "POST", oCustomerData)
        
        IF !EMPTY(lcResponse)
            loCustomer = THIS.oJSON.Parse(lcResponse)
            THIS.oLogger.Log("INFO", "Cliente creado exitosamente: " + ALLTRIM(STR(loCustomer.id)))
            RETURN loCustomer
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para actualizar un cliente
    FUNCTION UpdateCustomer(tnCustomerId, toCustomerData)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCustomer
        
        lcResponse = THIS.MakeRequest('customers/' + ALLTRIM(STR(tnCustomerId)), "PUT", toCustomerData)
        
        IF !EMPTY(lcResponse)
            loCustomer = THIS.oJSON.Parse(lcResponse)
            THIS.oLogger.Log("INFO", "Cliente actualizado exitosamente: " + ALLTRIM(STR(tnCustomerId)))
            RETURN loCustomer
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para eliminar un cliente
    FUNCTION DeleteCustomer(tnCustomerId)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse
        
        lcResponse = THIS.MakeRequest('customers/' + ALLTRIM(STR(tnCustomerId)), "DELETE")
        
        IF !EMPTY(lcResponse)
            THIS.oLogger.Log("INFO", "Cliente eliminado exitosamente: " + ALLTRIM(STR(tnCustomerId)))
            RETURN .T.
        ENDIF
        RETURN .F.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para obtener cliente por email
    FUNCTION GetCustomerByEmail(cEmail)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCustomers, loCustomer
        
        lcResponse = THIS.MakeRequest('customers?email=' + cEmail, "GET")
        
        IF !EMPTY(lcResponse)
            loCustomers = THIS.oJSON.Parse(lcResponse)
            
            * Verificar si hay clientes
            IF !ISNULL(loCustomers) AND loCustomers.Count > 0
                loCustomer = loCustomers.Item(1)
                RETURN loCustomer
            ENDIF
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para buscar clientes
    FUNCTION SearchCustomers(tcSearchTerm, tnPage, tnPerPage)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCustomers, loParams, lnPage, lnPerPage
        
        * Parámetros por defecto
        lnPage = IIF(EMPTY(tnPage), 1, tnPage)
        lnPerPage = IIF(EMPTY(tnPerPage), 50, tnPerPage)
        
        * Construir parámetros
        loParams = CREATEOBJECT("Collection")
        loParams.Add(ALLTRIM(STR(lnPage)), "page")
        loParams.Add(ALLTRIM(STR(lnPerPage)), "per_page")
        loParams.Add(tcSearchTerm, "search")
        
        lcResponse = THIS.MakeRequest('customers', "GET", .NULL., loParams)
        IF !EMPTY(lcResponse)
            loCustomers = THIS.oJSON.Parse(lcResponse)
            RETURN loCustomers
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para obtener clientes por rol
    FUNCTION GetCustomersByRole(tcRole, tnPage, tnPerPage)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCustomers, loParams, lnPage, lnPerPage
        
        * Parámetros por defecto
        lnPage = IIF(EMPTY(tnPage), 1, tnPage)
        lnPerPage = IIF(EMPTY(tnPerPage), 50, tnPerPage)
        
        * Construir parámetros
        loParams = CREATEOBJECT("Collection")
        loParams.Add(ALLTRIM(STR(lnPage)), "page")
        loParams.Add(ALLTRIM(STR(lnPerPage)), "per_page")
        loParams.Add(tcRole, "role")
        
        lcResponse = THIS.MakeRequest('customers', "GET", .NULL., loParams)
        IF !EMPTY(lcResponse)
            loCustomers = THIS.oJSON.Parse(lcResponse)
            RETURN loCustomers
        ENDIF
        RETURN .NULL.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para actualizar datos de facturación
    FUNCTION UpdateCustomerBilling(tnCustomerId, toBillingData)
    *
    *----------------------------------------------------------------------------*
        LOCAL loCustomerData
        
        loCustomerData = CREATEOBJECT("Collection")
        loCustomerData.Add(toBillingData, "billing")
        
        RETURN THIS.UpdateCustomer(tnCustomerId, loCustomerData)
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para actualizar datos de envío
    FUNCTION UpdateCustomerShipping(tnCustomerId, toShippingData)
    *
    *----------------------------------------------------------------------------*
        LOCAL loCustomerData
        
        loCustomerData = CREATEOBJECT("Collection")
        loCustomerData.Add(toShippingData, "shipping")
        
        RETURN THIS.UpdateCustomer(tnCustomerId, loCustomerData)
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para obtener clientes recientes
    FUNCTION GetRecentCustomers(tnDays, tnPage, tnPerPage)
    *
    *----------------------------------------------------------------------------*
        LOCAL lcResponse, loCustomers, loParams, ldDateFrom, lnPage, lnPerPage
        
        * Parámetros por defecto
        lnPage = IIF(EMPTY(tnPage), 1, tnPage)
        lnPerPage = IIF(EMPTY(tnPerPage), 50, tnPerPage)
        
        ldDateFrom = DATE() - tnDays
        
        * Construir parámetros
        loParams = CREATEOBJECT("Collection")
        loParams.Add(ALLTRIM(STR(lnPage)), "page")
        loParams.Add(ALLTRIM(STR(lnPerPage)), "per_page")
        loParams.Add(THIS.FormatDateForAPI(ldDateFrom), "after")
        
        lcResponse = THIS.MakeRequest('customers', "GET", .NULL., loParams)
        IF !EMPTY(lcResponse)
            loCustomers = THIS.oJSON.Parse(lcResponse)
            RETURN loCustomers
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