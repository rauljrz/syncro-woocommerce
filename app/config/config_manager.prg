*|--------------------------------------------------------------------------
*| config_manager.prg
*|--------------------------------------------------------------------------
*|
*| Clase para gestión de configuración del sistema
*| Autor.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.08.04 - 19.38
*| Purpose.....: Clase para gestión de configuración del sistema
*|	
*| Revisions...: v1.00
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS ConfigManager AS Custom
*
*-----------------------------------------------------------------------------------*
	HIDDEN ;
		CLASSLIBRARY,COMMENT, ;
		BASECLASS,CONTROLCOUNT, ;
		CONTROLS,OBJECTS,OBJECT,;
		HEIGHT,HELPCONTEXTID,LEFT,NAME, ;
		PARENT,PARENTCLASS,PICTURE, ;
		TAG,TOP,WHATSTHISHELPID,WIDTH
    * Propiedades protegidas
    PROTECTED cConfigFile
    PROTECTED oConfig
    PROTECTED oLogger
    
    * Propiedades públicas
    cLastError = ""
    
    * Constructor
    FUNCTION Init(cConfigFile)
        * Inicializar logger
        THIS.oLogger = NEWOBJECT("Logger", "progs\logger.prg")
        
        * Configurar archivo de configuración
        IF !EMPTY(cConfigFile)
            THIS.cConfigFile = cConfigFile
        ELSE
            THIS.cConfigFile = "config.ini"
        ENDIF
        
        THIS.oConfig = CREATEOBJECT("Collection")
        RETURN .T.
    ENDFUNC

    FUNCTION GetConfigFile()
        RETURN THIS.cConfigFile
    ENDFUNC
    
    * Método para cargar configuración desde archivo
    FUNCTION LoadConfig(cConfigFile)
        LOCAL cFile, cLine, cSection, cKey, cValue
        LOCAL nHandle, oSection
        
        * Usar archivo especificado o el por defecto
        IF !EMPTY(cConfigFile)
            THIS.cConfigFile = cConfigFile
        ENDIF
        
        * Verificar que el archivo existe
        IF !FILE(THIS.cConfigFile)
            THIS.cLastError = "Archivo de configuración no encontrado: " + THIS.cConfigFile
            THIS.oLogger.Log("ERROR", THIS.cLastError)
            RETURN .F.
        ENDIF
        
        * Limpiar configuración anterior
        THIS.oConfig.Destroy()
        
        * Leer archivo de configuración
        nHandle = FOPEN(THIS.cConfigFile, 0)
        IF nHandle < 0
            THIS.cLastError = "No se pudo abrir el archivo de configuración: " + THIS.cConfigFile
            THIS.oLogger.Log("ERROR", THIS.cLastError)
            RETURN .F.
        ENDIF
        
        cSection = ""
        
        DO WHILE !FEOF(nHandle)
            cLine = ALLTRIM(FGETS(nHandle))
            
            * Ignorar líneas vacías y comentarios
            IF !EMPTY(cLine) AND LEFT(cLine, 1) != "#"
                * Verificar si es una sección
                IF LEFT(cLine, 1) = "[" AND RIGHT(cLine, 1) = "]"
                    cSection = SUBSTR(cLine, 2, LEN(cLine) - 2)
                    oSection = CREATEOBJECT("Collection")
                    THIS.oConfig.Add(oSection, cSection)
                ELSE
                    * Verificar si hay una sección activa
                    IF !EMPTY(cSection)
                        * Buscar el separador =
                        LOCAL nPos
                        nPos = AT("=", cLine)
                        IF nPos > 0
                            cKey = ALLTRIM(LEFT(cLine, nPos - 1))
                            cValue = ALLTRIM(SUBSTR(cLine, nPos + 1))
                            
                            * Obtener la sección actual
                            LOCAL oCurrentSection
                            oCurrentSection = THIS.oConfig.Item(cSection)
                            oCurrentSection.Add(cValue, cKey)
                        ENDIF
                    ENDIF
                ENDIF
            ENDIF
        ENDDO
        
        FCLOSE(nHandle)
        RETURN .T.
    ENDFUNC
    
    * Método para obtener un valor de configuración
    FUNCTION GetValue(cSection, cKey, cDefault)
        LOCAL oSection, cValue
        
        * Verificar que la sección existe
        IF !THIS.oConfig.GetKey(cSection) > 0
            IF !EMPTY(cDefault)
                RETURN cDefault
            ENDIF
            RETURN ""
        ENDIF
        
        * Obtener la sección
        oSection = THIS.oConfig.Item(cSection)
        
        * Verificar que la clave existe
        IF !oSection.GetKey(cKey) > 0
            IF !EMPTY(cDefault)
                RETURN cDefault
            ENDIF
            RETURN ""
        ENDIF
        
        * Obtener el valor
        cValue = oSection.Item(cKey)
        
        RETURN cValue
    ENDFUNC
    
    * Método para establecer un valor de configuración
    FUNCTION SetValue(cSection, cKey, cValue)
        LOCAL oSection
        
        * Verificar que la sección existe
        IF !THIS.oConfig.GetKey(cSection) > 0
            * Crear nueva sección
            oSection = CREATEOBJECT("Collection")
            THIS.oConfig.Add(oSection, cSection)
        ELSE
            oSection = THIS.oConfig.Item(cSection)
        ENDIF
        
        * Verificar si la clave ya existe
        IF oSection.GetKey(cKey) > 0
            oSection.Remove(cKey)
        ENDIF
        
        * Agregar el valor
        oSection.Add(cValue, cKey)
        
        RETURN .T.
    ENDFUNC
    
    * Método para guardar configuración en archivo
    FUNCTION SaveConfig(cConfigFile)
        LOCAL nHandle, cSection, oSection, cKey, cValue
        LOCAL nSectionCount, nKeyCount, i, j
        
        * Usar archivo especificado o el por defecto
        IF !EMPTY(cConfigFile)
            THIS.cConfigFile = cConfigFile
        ENDIF
        
        * Crear archivo de configuración
        nHandle = FCREATE(THIS.cConfigFile)
        IF nHandle < 0
            THIS.cLastError = "No se pudo crear el archivo de configuración: " + THIS.cConfigFile
            THIS.oLogger.Log("ERROR", THIS.cLastError)
            RETURN .F.
        ENDIF
        
        * Escribir encabezado
        FPUTS(nHandle, "# Archivo de configuraciones #")
        FPUTS(nHandle, "")
        
        * Recorrer todas las secciones
        nSectionCount = THIS.oConfig.Count
        FOR i = 1 TO nSectionCount
            cSection = THIS.oConfig.GetKey(i)
            oSection = THIS.oConfig.Item(i)
            
            * Escribir sección
            FPUTS(nHandle, "[" + cSection + "]")
            
            * Recorrer todas las claves de la sección
            nKeyCount = oSection.Count
            FOR j = 1 TO nKeyCount
                cKey = oSection.GetKey(j)
                cValue = oSection.Item(j)
                
                * Escribir clave=valor
                FPUTS(nHandle, cKey + "=" + cValue)
            ENDFOR
            
            * Línea en blanco entre secciones
            FPUTS(nHandle, "")
        ENDFOR
        
        FCLOSE(nHandle)
        RETURN .T.
    ENDFUNC
    
    * Método para obtener todas las secciones
    FUNCTION GetSections(aSections)
        LOCAL aSections, nCount, i
        
        nCount = THIS.oConfig.Count
        DIMENSION aSections(nCount)
        
        FOR i = 1 TO nCount
            aSections[i] = THIS.oConfig.GetKey(i)
        ENDFOR
        RETURN .T.
    ENDFUNC
    
    * Método para obtener todas las claves de una sección
    FUNCTION GetKeys(cSection, aKeys)
        LOCAL oSection, aKeys, nCount, i
        
        * Verificar que la sección existe
        IF !THIS.oConfig.GetKey(cSection) > 0
            RETURN .NULL.
        ENDIF
        
        oSection = THIS.oConfig.Item(cSection)
        nCount = oSection.Count
        DIMENSION aKeys(nCount)
        
        FOR i = 1 TO nCount
            aKeys[i] = oSection.GetKey(i)
        ENDFOR
        RETURN .T.
    ENDFUNC
    
    * Método para verificar si existe una sección
    FUNCTION SectionExists(cSection)
        RETURN THIS.oConfig.GetKey(cSection) > 0
    ENDFUNC
    
    * Método para verificar si existe una clave
    FUNCTION KeyExists(cSection, cKey)
        LOCAL oSection
        
        * Verificar que la sección existe
        IF !THIS.oConfig.GetKey(cSection) > 0
            RETURN .F.
        ENDIF
        
        oSection = THIS.oConfig.Item(cSection)
        RETURN oSection.GetKey(cKey) > 0
    ENDFUNC
    
    * Método para eliminar una clave
    FUNCTION RemoveKey(cSection, cKey)
        LOCAL oSection
        
        * Verificar que la sección existe
        IF !THIS.oConfig.GetKey(cSection) > 0
            RETURN .F.
        ENDIF
        
        oSection = THIS.oConfig.Item(cSection)
        
        * Verificar que la clave existe
        IF !oSection.GetKey(cKey) > 0
            RETURN .F.
        ENDIF
        
        oSection.Remove(cKey)
        RETURN .T.
    ENDFUNC
    
    * Método para eliminar una sección
    FUNCTION RemoveSection(cSection)
        * Verificar que la sección existe
        IF !THIS.oConfig.GetKey(cSection) > 0
            RETURN .F.
        ENDIF
        
        THIS.oConfig.Remove(cSection)
        RETURN .T.
    ENDFUNC
    
    * Método para obtener el último error
    FUNCTION GetLastError()
        RETURN THIS.cLastError
    ENDFUNC
    
    * Método para limpiar el último error
    FUNCTION ClearLastError()
        THIS.cLastError = ""
    ENDFUNC
    
    * Método para obtener la configuración completa como objeto
    FUNCTION GetConfigObject()
        RETURN THIS.oConfig
    ENDFUNC
    
    * Destructor
    FUNCTION Destroy()
    ENDFUNC
    
ENDDEFINE 