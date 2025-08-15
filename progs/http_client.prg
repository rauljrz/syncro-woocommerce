#include include/default.h
*|--------------------------------------------------------------------------
*| http_client.prg
*|--------------------------------------------------------------------------
*|
*| Author......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.01.26 - 15:30
*| Purpose.....: Clase cliente HTTP reutilizable para peticiones REST
*|	
*| Revisions...: v1.00
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS HTTPClient AS Custom
*-----------------------------------------------------------------------------------*
	HIDDEN ;
		CLASSLIBRARY,COMMENT, ;
		BASECLASS,CONTROLCOUNT, ;
		CONTROLS,OBJECTS,OBJECT,;
		HEIGHT,HELPCONTEXTID,LEFT,NAME, ;
		PARENT,PARENTCLASS,PICTURE, ;
		TAG,TOP,WHATSTHISHELPID,WIDTH
    
	*-- Indica si se relanza la excepcion a un nivel superior
	PROTECTED brelanzarthrow
	brelanzarthrow = .T.

    * Propiedades protegidas
    PROTECTED cServer, cApiPath, cEndpoint, cMethod, lIsLogger, nTimeout, nMaxRetries,;
                oConfigManager, oLogger, oHeaders, oParameters
    
    * Propiedades públicas
    cLastError = ""
    nLastResponseCode = 0
    cLastResponse = ""
    cLastStatusText = ""
    cLastResponseBody = ""
    
    *----------------------------------------------------------------------------*
    FUNCTION Init(toConfigManager)
    * Inicializa la clase HTTPClient
    *----------------------------------------------------------------------------*
        LOCAL oConfigManager
        
        * Inicializar logger
        THIS.oLogger = NEWOBJECT("Logger", "progs\logger.prg")
        THIS.oLogger.SetLevel(4)  && Graba desde el nivel 4 (Notice) hasta el 1 (Critical)
        THIS.oLogger.isLogger = .T.
        THIS.oLogger.setNameFile('HTTPClient.log')
        
        * Inicializar objetos para headers y parámetros
        THIS.oHeaders = NEWOBJECT('EMPTY')
        THIS.oParameters = NEWOBJECT('EMPTY')
        
        * Configuración por defecto
        THIS.cServer = "http://localhost"
        THIS.cApiPath = "/api/v1/"
        THIS.cMethod = "GET"
        THIS.cEndpoint = ""
        THIS.lIsLogger = .T.
        THIS.nTimeout = 30
        THIS.nMaxRetries = 3
        
        * Inyección de dependencia para ConfigManager
        IF VARTYPE(toConfigManager) = 'O'
            THIS.oConfigManager = toConfigManager
            * Cargar configuración desde el objeto inyectado
            THIS.cServer = THIS.oConfigManager.GetValue("HTTP", "SERVER", THIS.cServer)
            THIS.cApiPath = THIS.oConfigManager.GetValue("HTTP", "API_PATH", THIS.cApiPath)
            THIS.nTimeout = VAL(THIS.oConfigManager.GetValue("HTTP", "TIMEOUT", ALLTRIM(STR(THIS.nTimeout))))
            THIS.nMaxRetries = VAL(THIS.oConfigManager.GetValue("HTTP", "MAX_RETRIES", ALLTRIM(STR(THIS.nMaxRetries))))
        ELSE
            * Intentar crear ConfigManager si no se inyectó (fallback)
            oConfigManager = NEWOBJECT("ConfigManager", "app\config\config_manager.prg")
            IF VARTYPE(oConfigManager) = 'O' AND oConfigManager.LoadConfig("config.ini")
                THIS.oConfigManager = oConfigManager
                THIS.cServer = THIS.oConfigManager.GetValue("HTTP", "SERVER", THIS.cServer)
                THIS.cApiPath = THIS.oConfigManager.GetValue("HTTP", "API_PATH", THIS.cApiPath)
                THIS.nTimeout = VAL(THIS.oConfigManager.GetValue("HTTP", "TIMEOUT", ALLTRIM(STR(THIS.nTimeout))))
                THIS.nMaxRetries = VAL(THIS.oConfigManager.GetValue("HTTP", "MAX_RETRIES", ALLTRIM(STR(THIS.nMaxRetries))))
            ENDIF
        ENDIF
        
        * Configurar headers por defecto
        THIS.addHeader("Content-Type", "application/json")
        THIS.addHeader("HttpVersion", "1.1")
        THIS.addHeader("UserAgent", "HTTPClient-VFP/1.0")
        RETURN .T.
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION setServer(tcServer)
    * Establece la URL del servidor
    *----------------------------------------------------------------------------*
        LOCAL lbReturn
        lbReturn = .F.
        IF VARTYPE(tcServer) = 'C' AND !EMPTY(tcServer)
            THIS.cServer = ALLTRIM(tcServer)
            lbReturn = .T.
        ENDIF
        RETURN lbReturn
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION setApiPath(tcApiPath)
    * Establece la ruta base de la API
    *----------------------------------------------------------------------------*
        LOCAL lbReturn
        lbReturn = .F.
        IF VARTYPE(tcApiPath) = 'C' AND !EMPTY(tcApiPath)
            THIS.cApiPath = ALLTRIM(tcApiPath)
            lbReturn = .T.
        ENDIF
        RETURN lbReturn
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION setMethod(tcMethod)
    * Establece el método HTTP (GET, POST, PUT, DELETE, etc.)
    *----------------------------------------------------------------------------*
        LOCAL lcValidMethods, lcMethod, lbReturn
        lbReturn = .F.
        lcValidMethods = "POST,GET,PUT,DELETE,HEAD,CONNECT,OPTIONS,TRACE,PATCH"
        lcMethod = UPPER(ALLTRIM(tcMethod)) && Convertir a mayúsculas
        
        IF lcMethod $ lcValidMethods
            THIS.cMethod = lcMethod
            lbReturn = .T.
        ELSE
            THIS.oLogger.Log("ERROR", "Método HTTP no válido: " + tcMethod)
            THIS.cLastError = "Método HTTP no válido: " + tcMethod
        ENDIF
        RETURN lbReturn
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION setEndpoint(tcEndpoint)
    * Establece el endpoint específico de la API
    *----------------------------------------------------------------------------*
        LOCAL lbReturn
        lbReturn = .F.
        IF VARTYPE(tcEndpoint) = 'C'
            THIS.cEndpoint = ALLTRIM(tcEndpoint)
            lbReturn = .T.
        ENDIF
        RETURN lbReturn
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION addHeader(tcKey, tcValue)
    * Agrega un header HTTP
    *----------------------------------------------------------------------------*
        LOCAL lcKey, lcValue, lbReturn
        lbReturn = .F.
        
        TRY
            * Convertir a hexadecimal para evitar conflictos con caracteres especiales
            lcKey = '_' + STRCONV(tcKey, 15)
            lcValue = TRANSFORM(tcValue)
            
            IF PEMSTATUS(THIS.oHeaders, lcKey, 5)
                THIS.oHeaders.&lcKey = lcValue
            ELSE
                ADDPROPERTY(THIS.oHeaders, lcKey, lcValue)
            ENDIF
            
            lbReturn = .T.
        CATCH TO loEx
            THIS.oLogger.Log("ERROR", "Error al agregar header: ";
                        + IIF(loEx.ErrorNo=2071, loEx.UserValue, loEx.Message))
            THIS.catchException(loEx)
        ENDTRY
        RETURN lbReturn
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION addParameter(tcKey, tcValue)
    * Agrega un parámetro de consulta para la URL
    *----------------------------------------------------------------------------*
        LOCAL lcKey, lcValue, lbReturn
        lbReturn = .F.
        
        TRY
            * Convertir a hexadecimal para evitar conflictos con caracteres especiales
            lcKey = '_' + STRCONV(tcKey, 15)
            lcValue = TRANSFORM(tcValue)
            
            IF PEMSTATUS(THIS.oParameters, lcKey, 5)
                THIS.oParameters.&lcKey = lcValue
            ELSE
                ADDPROPERTY(THIS.oParameters, lcKey, lcValue)
            ENDIF
            
            lbReturn = .T.
        CATCH TO loEx 
        	SET STEP ON 
            THIS.oLogger.Log("ERROR", "Error al agregar parámetro: ";
                    + IIF(loEx.ErrorNo=2071, loEx.UserValue, loEx.Message))
            THIS.catchException( loEx)
        ENDTRY
        RETURN lbReturn
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION clearHeaders()
    * Limpia todos los headers
    *----------------------------------------------------------------------------*
        THIS.oHeaders = NEWOBJECT('EMPTY')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION clearParameters()
    * Limpia todos los parámetros
    *----------------------------------------------------------------------------*
        THIS.oParameters = NEWOBJECT('EMPTY')
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    *PROTECTED
    FUNCTION buildURL()
    * Construye la URL completa con parámetros
    *----------------------------------------------------------------------------*
        LOCAL lcURL, lcParameters
        lcURL = ALLTRIM(THIS.cServer) ;
                    + ALLTRIM(THIS.cApiPath) ;
                    + ALLTRIM(THIS.cEndpoint)
        
        lcParameters = THIS.getParameters()
        IF !EMPTY(lcParameters)
            lcURL = lcURL + "?" + lcParameters
        ENDIF
        RETURN lcURL
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION getParameters()
    * Devuelve una lista de parametros cargados
    *----------------------------------------------------------------------------*
    	LOCAL lcParameters, lcKey, lcValue, lnInd, lnCnt, laProperties
    	DIMENSION laProperties[1]
    	lnCnt = AMEMBERS(laProperties, THIS.oParameters, 0)
        
        lcParameters = ""
        FOR lnInd = 1 TO lnCnt
            lcKey = laProperties[lnInd]
            lcValue = THIS.oParameters.&lcKey
            
            IF lnInd > 1
                lcParameters = lcParameters + "&"
            ENDIF
            
            lcParameters = lcParameters + STRCONV(lcKey, 16) + "=" + lcValue
        ENDFOR
        RETURN lcParameters
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION send(tcBody)
    * Envía la petición HTTP y retorna la respuesta
    *----------------------------------------------------------------------------*
        LOCAL lcURL, lcBody, lcResponse, lcStatusText, lcBodyResponse
        LOCAL loHttp, lnCnt, lnInd, lcKey, laHeader, laProperties
        
        THIS.clearLastResponse() && Limpiar estado anterior
        
        lcURL = THIS.buildURL()  && Construir URL
        lcBody = IIF(VARTYPE(tcBody) != 'C', '', ALLTRIM(tcBody)) && Preparar body
       SET STEP ON 
        THIS.oLogger.notice(' REQUEST ';
							+crlf +' -  URL....: '+lcURL;
							+crlf +' -  Method.: '+THIS.cMethod;
							+crlf +' -  Body...: '+lcBody)
        TRY
            loHttp = CREATEOBJECT("WinHttp.WinHttpRequest.5.1")  && Crear objeto HTTP
            WITH loHttp
                .setTimeouts(THIS.nTimeout * 1000, THIS.nTimeout * 1000, THIS.nTimeout * 1000, THIS.nTimeout * 1000) && Configurar timeout
                .open(THIS.cMethod, lcURL, .F.)
                
                DIMENSION laHeader[1]
                lnCnt = AMEMBERS(laHeader, THIS.oHeaders, 0) && Configurar headers
                FOR lnInd = 1 TO lnCnt
                    lcKey = laHeader[lnInd]
                    .SetRequestHeader(STRCONV(lcKey, 16), THIS.oHeaders.&lcKey)
                ENDFOR
                .send(lcBody) && Enviar petición
                
                THIS.nLastResponseCode = .Status
                lcStatusText = .StatusText
                lcBodyResponse = .responseText && Obtener respuesta
                
                IF !INLIST(THIS.nLastResponseCode, 0, 200, 201, 202, 204, 422)
                    IF THIS.nLastResponseCode = 404
                        THROW "Endpoint no encontrado: " + lcURL
                    ENDIF
                    
                    IF THIS.nLastResponseCode != 500 AND !EMPTY(lcBodyResponse)
                        IF AT('"error":', lcBodyResponse) > 0
                            lcError = STREXTRACT(lcBodyResponse, '"error":"', '"')
                            THROW lcError
                        ELSE
                            THROW lcBodyResponse
                        ENDIF
                    ENDIF
                    
                    THROW "Error HTTP " + ALLTRIM(STR(THIS.nLastResponseCode)) + ": " + lcStatusText
                ENDIF
                
                * Determinar tipo de respuesta
                IF THIS.isTextResponse(.GetAllResponseHeaders)
                    lcResponse = .responseText
                    THIS.cLastResponseBody = lcResponse
                ELSE
                    lcResponse = .responseBody
                    THIS.cLastResponseBody = "Contenido binario"
                ENDIF
                
                THIS.cLastStatusText = lcStatusText
                THIS.cLastResponse = lcResponse
            ENDWITH
            
        CATCH TO loEx 
            THIS.cLastError = "Error en petición HTTP: " ;
                        + IIF(loEx.ErrorNo=2071, loEx.UserValue, loEx.Message) ;
                        + crlf + 'URL: ' + lcURL
            THIS.oLogger.critical(THIS.cLastError)
            THROW THIS.cLastError
        FINALLY
            loHttp = .NULL.
            THIS.oLogger.notice(' RESPONSE ';
            				+crlf +' -  Status Code.....: '+TRANSFORM(THIS.nLastResponseCode);
							+crlf +' -  Status Text.....: '+THIS.cLastStatusText;
							+crlf +' -  Body............: '+THIS.cLastResponseBody)
        ENDTRY
        
        RETURN lcResponse
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    PROTECTED FUNCTION isTextResponse(tcHeaders)
    * Verifica si la respuesta es de tipo texto
    *----------------------------------------------------------------------------*
        LOCAL laTypes, lcTypes, lnCnt, lnLoop, lbSuccess
        lcTypes = 'text/css,text/csv,application/javascript,application/json,application/xhtml+xml,application/problem+json,text/plain'
        
        DIMENSION laTypes[1]
        lnCnt = ALINES(laTypes, lcTypes, ',')
        lbSuccess = .F.
        
        FOR lnLoop = 1 TO lnCnt
            IF laTypes[lnLoop] $ LOWER(tcHeaders)
                lbSuccess = .T.
                EXIT
            ENDIF
        ENDFOR
        
        RETURN lbSuccess
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION getLastError()
    * Retorna el último error ocurrido
    *----------------------------------------------------------------------------*
        RETURN THIS.cLastError
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION getLastResponseCode()
    * Retorna el último código de respuesta HTTP
    *----------------------------------------------------------------------------*
        RETURN THIS.nLastResponseCode
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION getLastStatusText()
    * Retorna el último texto de estado HTTP
    *----------------------------------------------------------------------------*
        RETURN THIS.cLastStatusText
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION getLastResponse()
    * Retorna la última respuesta completa
    *----------------------------------------------------------------------------*
        RETURN THIS.cLastResponse
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION getLastResponseBody()
    * Retorna el body de la última respuesta
    *----------------------------------------------------------------------------*
        RETURN THIS.cLastResponseBody
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION clearLastResponse()
    * Limpia toda la información de la última respuesta
    *----------------------------------------------------------------------------*
        THIS.cLastError = ""
        THIS.nLastResponseCode = 0
        THIS.cLastResponse = ""
        THIS.cLastStatusText = ""
        THIS.cLastResponseBody = ""
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION setTimeout(tnTimeout)
    * Establece el timeout en segundos
    *----------------------------------------------------------------------------*
        IF VARTYPE(tnTimeout) = 'N' AND tnTimeout > 0
            THIS.nTimeout = tnTimeout
        ENDIF
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION setMaxRetries(tnMaxRetries)
    * Establece el número máximo de reintentos
    *----------------------------------------------------------------------------*
        IF VARTYPE(tnMaxRetries) = 'N' AND tnMaxRetries >= 0
            THIS.nMaxRetries = tnMaxRetries
        ENDIF
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION setLogging(tlEnable)
    * Habilita o deshabilita el logging
    *----------------------------------------------------------------------------*
        IF VARTYPE(tlEnable) = 'L'
            THIS.lIsLogger = tlEnable
            THIS.oLogger.isLogger = THIS.lIsLogger
        ENDIF
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    PROTECTED FUNCTION catchException(toEx)
    * Captura y maneja las excepciones de forma centralizada
    *----------------------------------------------------------------------------*
        LOCAL oLog

        loEx = toEx
        oLog = .NULL.
        IF PEMSTATUS(THIS, 'oLogger', 5) AND !ISNULL(THIS.oLogger)
            oLog = THIS.oLogger
        ENDIF
        SYS(1104) && Purges memory cached by programs and data, and clears and refreshes buffers for open tables.
        
        * Usar la clase catchException si existe, o crear una nueva
        IF FILE("progs\catchexception.prg")
            =NEWOBJECT('catchException','progs\catchException.prg','',THIS.bRelanzarThrow, oLog)        
        ELSE
            * Fallback: crear excepción básica
            IF VARTYPE(toEx) = 'C'
                THROW toEx
            ELSE
                THROW toEx.Message
            ENDIF
        ENDIF
    ENDFUNC
    
    *----------------------------------------------------------------------------*
    FUNCTION Destroy()
    * Destruye la clase y limpia recursos
    *----------------------------------------------------------------------------*
        * Limpiar objetos
        THIS.oHeaders = .NULL.
        THIS.oParameters = .NULL.
        *THIS.oLogger = .NULL.
        THIS.oConfigManager = .NULL.
    ENDFUNC
    
ENDDEFINE
