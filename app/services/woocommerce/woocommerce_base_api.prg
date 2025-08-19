*|--------------------------------------------------------------------------
*| woocommerce_base_api.prg
*|--------------------------------------------------------------------------
*|
*| Clase base para operaciones HTTP comunes de WooCommerce
*| Autor.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.01.26 - 10:30
*| Purpose.....: Clase base para operaciones HTTP comunes de WooCommerce
*|	
*| Revisions...: v1.00
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS WooCommerceBaseAPI AS Custom
*-----------------------------------------------------------------------------------*
    * Propiedades protegidas
    PROTECTED cBaseURL
    PROTECTED cConsumerKey
    PROTECTED cConsumerSecret
    PROTECTED oLogger
    PROTECTED oJSON
    PROTECTED oHTTPClient
    PROTECTED oConfigManager
    
    * Propiedades públicas
    cLastError = ""
    nLastResponseCode = 0
    cLastResponse = ""
    
    *----------------------------------------------------------------------------*
    * Constructor
    FUNCTION Init()
    *
    *----------------------------------------------------------------------------*
        LOCAL oConfigManager
        
        * Inicializar logger
        THIS.oLogger = NEWOBJECT("Logger", "progs\logger.prg")
        
        * Inicializar JSON
        THIS.oJSON = NEWOBJECT("JSON", "progs\json.prg")
        
        * Cargar configuración
        oConfigManager = NEWOBJECT("ConfigManager", "app\config\config_manager.prg")
        IF !oConfigManager.LoadConfig("config.ini")
            THIS.oLogger.Log("ERROR", "No se pudo cargar la configuración en WooCommerceBaseAPI")
            RETURN .F.
        ENDIF
        
        * Guardar referencia al ConfigManager
        THIS.oConfigManager = oConfigManager
        
        * Configurar propiedades desde config.ini
        THIS.cBaseURL = oConfigManager.GetValue("ECOMMERCE", "URL_ECOMMERCE")
        THIS.cConsumerKey = oConfigManager.GetValue("ECOMMERCE", "CK_ECOMMERCE")
        THIS.cConsumerSecret = oConfigManager.GetValue("ECOMMERCE", "CS_ECOMMERCE")
        
        * Validar configuración
        IF EMPTY(THIS.cBaseURL) OR EMPTY(THIS.cConsumerKey) OR EMPTY(THIS.cConsumerSecret)
            THIS.oLogger.Log("ERROR", "Configuración incompleta de WooCommerce")
            RETURN .F.
        ENDIF
        
        * Asegurar que la URL termine con /
        IF RIGHT(THIS.cBaseURL, 1) != "/"
            THIS.cBaseURL = THIS.cBaseURL + "/"
        ENDIF
        
        * Inicializar HTTPClient
        THIS.oHTTPClient = NEWOBJECT("HTTPClient", "progs\http_client.prg", '', oConfigManager)
        IF ISNULL(THIS.oHTTPClient)
            THIS.oLogger.Log("ERROR", "No se pudo inicializar HTTPClient en WooCommerceBaseAPI")
            RETURN .F.
        ENDIF
        
        * Configurar HTTPClient para WooCommerce
        THIS.oHTTPClient.setServer(THIS.cBaseURL)
        THIS.oHTTPClient.setApiPath("wp-json/wc/v3/")
        THIS.oHTTPClient.setMethod("GET")
        
        * Agregar headers de autenticación
        THIS.oHTTPClient.addHeader("Content-Type", "application/json")
        THIS.oHTTPClient.addHeader("Accept", "application/json")
        THIS.oHTTPClient.addHeader("User-Agent", "WooCommerce-VFP-Client/1.0")
        
        RETURN .T.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para realizar peticiones HTTP usando HTTPClient
    FUNCTION MakeRequest(cEndpoint, cMethod, oData, oParams)
    *
    *----------------------------------------------------------------------------*
        LOCAL cResponse, cRequestBody 
        
        IF EMPTY(cMethod) && Parámetros por defecto
            cMethod = "GET"
        ENDIF
        
        THIS.oHTTPClient.setMethod(cMethod) && Configurar método HTTP
        THIS.oHTTPClient.setEndpoint(cEndpoint)
        THIS.BuildQueryParams(oParams)

        cRequestBody = "" && Preparar datos para POST/PUT
        IF VARTYPE(oData)='O';
            AND (UPPER(cMethod) = "POST" OR UPPER(cMethod) = "PUT")
            cRequestBody = THIS.oJSON.Stringify(oData)
        ENDIF
        cResponse = ""
        TRY
            cResponse = THIS.oHTTPClient.send(cRequestBody)
            
            THIS.nLastResponseCode = THIS.oHTTPClient.getLastResponseCode() && Guardar información de la respuesta
            THIS.cLastResponse = cResponse
            THIS.cLastError = THIS.oHTTPClient.getLastError()
            
            THIS.oLogger.Log("INFO", "Petición " + cMethod + " a " + cEndpoint ;
                        + " - Código: " + ALLTRIM(STR(THIS.nLastResponseCode)))
            
        CATCH TO loEx 
            THIS.cLastError = "Error en petición HTTP: ";
                     + IIF(loEx.ErrorNo=2071, loEx.UserValue, loEx.Message)
            THIS.oLogger.Log("ERROR", THIS.cLastError)
        ENDTRY
        RETURN cResponse
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para formatear fecha para la API
    FUNCTION FormatDateForAPI(dDate)
    *
    *----------------------------------------------------------------------------*
        LOCAL cFormatted, cYear, cMonth, cDay
        
        IF EMPTY(dDate) && Validar entrada
            RETURN ""
        ENDIF
        
        * Extraer componentes de la fecha y formatear con separadores
        cYear = STR(YEAR(dDate), 4)
        cMonth = PADL(MONTH(dDate), 2, "0")
        cDay = PADL(DAY(dDate), 2, "0")
        
        * Construir formato ISO 8601: YYYY-MM-DDTHH:MM:SSZ
        cFormatted = cYear + "-" + cMonth + "-" + cDay + "T00:00:00Z"
        RETURN cFormatted
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para construir parámetros de consulta
    PROTECTED FUNCTION BuildQueryParams(toParams)
    *
    *----------------------------------------------------------------------------*
        LOCAL lnInd, lnCnt, lcKey, lcValue
        
        THIS.oHTTPClient.clearParameters()
        THIS.oHTTPClient.addParameter("consumer_key", THIS.cConsumerKey)
        THIS.oHTTPClient.addParameter("consumer_secret", THIS.cConsumerSecret)
        
        IF VARTYPE(toParams)!='O' OR toParams.Count=0
            RETURN .F.
        ENDIF

        lnCnt = toParams.Count
        FOR lnInd = 1 TO lnCnt
            lcKey = toParams.GetKey(lnInd)
            lcValue = toParams.Item(lnInd)
            THIS.oHTTPClient.addParameter(lcKey, lcValue)
        ENDFOR
        RETURN .T.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para obtener el último error
    FUNCTION GetLastError()
    *
    *----------------------------------------------------------------------------*
        RETURN THIS.cLastError
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para obtener el código de respuesta
    FUNCTION GetLastResponseCode()
    *
    *----------------------------------------------------------------------------*
        RETURN THIS.nLastResponseCode
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Método para obtener la respuesta completa
    FUNCTION GetLastResponse()
    *
    *----------------------------------------------------------------------------*
        RETURN THIS.cLastResponse
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
    * Método para obtener el HTTPClient
    FUNCTION GetHTTPClient()
    *
    *----------------------------------------------------------------------------*
        RETURN THIS.oHTTPClient
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    * Destructor
    FUNCTION Destroy()
    *
    *----------------------------------------------------------------------------*
        IF VARTYPE(THIS.oHTTPClient) = 'O'
            THIS.oHTTPClient.Destroy()
        ENDIF
        THIS.oHTTPClient = .NULL.
    ENDFUNC
    
ENDDEFINE 