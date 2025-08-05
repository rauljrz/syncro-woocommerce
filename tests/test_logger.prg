*|--------------------------------------------------------------------------
*| test_logger.prg
*|--------------------------------------------------------------------------
*
*| Test unitario para la clase Logger
*| Author......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.08.04 - 19.38
*| Purpose.....: Test unitario para verificar el método Log() de la clase logger
*|	
*| Revisions...: v1.00
*/
*-----------------------------------------------------------------------------------*

DEFINE CLASS Test_Logger AS TestBase
*
*-----------------------------------------------------------------------------------*
    PROTECTED oLogger
    PROTECTED cTestLogFile
    
    *----------------------------------------------------------------------------*
    PROCEDURE Setup
    * Configuración inicial para cada prueba
    *----------------------------------------------------------------------------*
        * Inicializar Logger
        THIS.oLogger = NEWOBJECT("Logger", "progs\logger.prg")
        
        * Configurar archivo de log de prueba
        THIS.cTestLogFile = "Logs\" + DTOC(DATE(), 1) + "_test_logger.LOG"
        THIS.oLogger.setNameFile("test_logger.LOG")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TearDown
    * Limpieza después de cada prueba
    *----------------------------------------------------------------------------*
        * Liberar objeto
        IF !ISNULL(THIS.oLogger)
            THIS.oLogger.Destroy()
        ENDIF
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestInit
    * Probar inicialización de Logger
    *----------------------------------------------------------------------------*
        THIS.AssertNotNull(THIS.oLogger, "Logger debe inicializarse correctamente")
        THIS.AssertTrue(THIS.oLogger.islogger, "Logger debe estar habilitado por defecto")
        THIS.AssertEqual(4, THIS.oLogger.getLevel(), "Nivel por defecto debe ser 4 (INFO)")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestLogInfo
    * Probar método Log con nivel INFO
    *----------------------------------------------------------------------------*
        LOCAL lbResult
        lbResult = THIS.oLogger.Log("INFO", "Este es un mensaje de información de prueba")
        
        THIS.AssertTrue(lbResult, "Log con nivel INFO debe retornar TRUE")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestLogWarning
    * Probar método Log con nivel WARNING
    *----------------------------------------------------------------------------*
        LOCAL lbResult
        lbResult = THIS.oLogger.Log("WARNING", "Este es un mensaje de advertencia de prueba")
        
        THIS.AssertTrue(lbResult, "Log con nivel WARNING debe retornar TRUE")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestLogError
    * Probar método Log con nivel ERROR
    *----------------------------------------------------------------------------*
        LOCAL lbResult
        lbResult = THIS.oLogger.Log("ERROR", "Este es un mensaje de error de prueba")
        
        THIS.AssertTrue(lbResult, "Log con nivel ERROR debe retornar TRUE")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestLogCritical
    * Probar método Log con nivel CRITICAL
    *----------------------------------------------------------------------------*
        LOCAL lbResult
        lbResult = THIS.oLogger.Log("CRITICAL", "Este es un mensaje crítico de prueba")
        
        THIS.AssertTrue(lbResult, "Log con nivel CRITICAL debe retornar TRUE")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestLogDebug
    * Probar método Log con nivel DEBUG
    *----------------------------------------------------------------------------*
        LOCAL lbResult
        lbResult = THIS.oLogger.Log("DEBUG", "Este es un mensaje de debug de prueba")
        
        THIS.AssertTrue(lbResult, "Log con nivel DEBUG debe retornar TRUE")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestLogInvalidLevel
    * Probar método Log con nivel inválido (debe usar INFO por defecto)
    *----------------------------------------------------------------------------*
        LOCAL lbResult
        lbResult = THIS.oLogger.Log("NIVEL_INVALIDO", "Este es un mensaje con nivel inválido")
        
        THIS.AssertTrue(lbResult, "Log con nivel inválido debe retornar TRUE (usa INFO por defecto)")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestLogVsOriginalMethods
    * Comparar método Log con métodos originales
    *----------------------------------------------------------------------------*
        LOCAL lbResult1, lbResult2
        
        * Probar método original Info
        lbResult1 = THIS.oLogger.Info("Mensaje usando método Info() original")
        
        * Probar método nuevo Log
        lbResult2 = THIS.oLogger.Log("INFO", "Mensaje usando método Log() nuevo")
        
        THIS.AssertTrue(lbResult1, "Método Info() original debe retornar TRUE")
        THIS.AssertTrue(lbResult2, "Método Log() nuevo debe retornar TRUE")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestLogFileCreation
    * Verificar que se crea el archivo de log
    *----------------------------------------------------------------------------*
        LOCAL lbResult, lcLogFile
        
        * Generar un log
        lbResult = THIS.oLogger.Log("INFO", "Mensaje de prueba para verificar creación de archivo")
        
        * Verificar que el archivo existe
        lcLogFile = THIS.oLogger.getFullNameFile()
        THIS.AssertTrue(FILE(lcLogFile), "Archivo de log debe crearse después de escribir")
        
        THIS.AssertTrue(lbResult, "Log debe retornar TRUE cuando se crea el archivo")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestLogLevels
    * Probar diferentes niveles de log
    *----------------------------------------------------------------------------*
        LOCAL lbResult
        
        * Probar todos los niveles válidos
        lbResult = THIS.oLogger.Log("INFO", "Mensaje INFO")
        THIS.AssertTrue(lbResult, "Nivel INFO debe funcionar")
        
        lbResult = THIS.oLogger.Log("WARN", "Mensaje WARN")
        THIS.AssertTrue(lbResult, "Nivel WARN debe funcionar")
        
        lbResult = THIS.oLogger.Log("ERROR", "Mensaje ERROR")
        THIS.AssertTrue(lbResult, "Nivel ERROR debe funcionar")
        
        lbResult = THIS.oLogger.Log("CRITICAL", "Mensaje CRITICAL")
        THIS.AssertTrue(lbResult, "Nivel CRITICAL debe funcionar")
        
        lbResult = THIS.oLogger.Log("DEBUG", "Mensaje DEBUG")
        THIS.AssertTrue(lbResult, "Nivel DEBUG debe funcionar")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestLoggerProperties
    * Verificar propiedades del logger
    *----------------------------------------------------------------------------*
        THIS.AssertNotEmpty(THIS.oLogger.getFormat(), "Formato no debe estar vacío")
        THIS.AssertNotEmpty(THIS.oLogger.getNameFile(), "Nombre de archivo no debe estar vacío")
        THIS.AssertTrue(THIS.oLogger.islogger, "Logger debe estar habilitado")
        THIS.AssertEqual(4, THIS.oLogger.getLevel(), "Nivel por defecto debe ser 4 (INFO)")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestSetLevel
    * Probar cambio de nivel de log
    *----------------------------------------------------------------------------*
        LOCAL lbResult
        
        * Cambiar nivel a 2 (WARNING)
        lbResult = THIS.oLogger.setLevel(2)
        THIS.AssertTrue(lbResult, "setLevel debe retornar TRUE")
        THIS.AssertEqual(2, THIS.oLogger.getLevel(), "Nivel debe cambiar a 2")
        
        * Cambiar nivel a 4 (INFO)
        lbResult = THIS.oLogger.setLevel(4)
        THIS.AssertTrue(lbResult, "setLevel debe retornar TRUE")
        THIS.AssertEqual(4, THIS.oLogger.getLevel(), "Nivel debe cambiar a 4")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDure TestSetLevelInvalid
    * Probar setLevel con valores inválidos
    *----------------------------------------------------------------------------*
        LOCAL lbResult, lnOriginalLevel
        
        lnOriginalLevel = THIS.oLogger.getLevel()
        
        * Intentar con nivel inválido (0)
        lbResult = THIS.oLogger.setLevel(0)
        THIS.AssertFalse(lbResult, "setLevel con valor 0 debe retornar FALSE")
        
        * Intentar con nivel inválido (5)
        lbResult = THIS.oLogger.setLevel(5)
        THIS.AssertFalse(lbResult, "setLevel con valor 5 debe retornar FALSE")
        
        * Verificar que el nivel no cambió
        THIS.AssertEqual(lnOriginalLevel, THIS.oLogger.getLevel(), "Nivel no debe cambiar con valores inválidos")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestSetFormat
    * Probar cambio de formato
    *----------------------------------------------------------------------------*
        LOCAL lbResult, lcOriginalFormat, lcNewFormat
        
        lcOriginalFormat = THIS.oLogger.getFormat()
        lcNewFormat = "NEW_FORMAT - {level} - {message}"
        
        lbResult = THIS.oLogger.setFormat(lcNewFormat)
        THIS.AssertTrue(lbResult, "setFormat debe retornar TRUE")
        THIS.AssertEqual(lcNewFormat, THIS.oLogger.getFormat(), "Formato debe cambiar")
        
        * Restaurar formato original
        THIS.oLogger.setFormat(lcOriginalFormat)
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestSetFormatInvalid
    * Probar setFormat con valores inválidos
    *----------------------------------------------------------------------------*
        LOCAL lbResult, lcOriginalFormat
        
        lcOriginalFormat = THIS.oLogger.getFormat()
        
        * Intentar con formato vacío
        lbResult = THIS.oLogger.setFormat("")
        THIS.AssertFalse(lbResult, "setFormat con valor vacío debe retornar FALSE")
        
        * Verificar que el formato no cambió
        THIS.AssertEqual(lcOriginalFormat, THIS.oLogger.getFormat(), "Formato no debe cambiar con valor inválido")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestSetNameFile
    * Probar cambio de nombre de archivo
    *----------------------------------------------------------------------------*
        LOCAL lbResult, lcOriginalFile, lcNewFile
        
        lcOriginalFile = THIS.oLogger.getNameFile()
        lcNewFile = "test_new_file.log"
        
        lbResult = THIS.oLogger.setNameFile(lcNewFile)
        THIS.AssertTrue(lbResult, "setNameFile debe retornar TRUE")
        THIS.AssertEqual(lcNewFile, THIS.oLogger.getNameFile(), "Nombre de archivo debe cambiar")
        
        * Restaurar nombre original
        THIS.oLogger.setNameFile(lcOriginalFile)
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestSetNameFileInvalid
    * Probar setNameFile con valores inválidos
    *----------------------------------------------------------------------------*
        LOCAL lbResult, lcOriginalFile
        
        lcOriginalFile = THIS.oLogger.getNameFile()
        
        * Intentar con nombre vacío
        lbResult = THIS.oLogger.setNameFile("")
        THIS.AssertFalse(lbResult, "setNameFile con valor vacío debe retornar FALSE")
        
        * Verificar que el nombre no cambió
        THIS.AssertEqual(lcOriginalFile, THIS.oLogger.getNameFile(), "Nombre de archivo no debe cambiar con valor inválido")
    ENDPROC
    
ENDDEFINE 