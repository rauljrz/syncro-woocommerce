*|--------------------------------------------------------------------------
*| test_config_manager.prg
*|--------------------------------------------------------------------------
*
*| Test unitario para la clase ConfigManager
*| Author......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.08.04 - 19.38
*| Purpose.....: Test unitario para la clase ConfigManager
*|	
*| Revisions...: v1.00
*/
*-----------------------------------------------------------------------------------*

DEFINE CLASS Test_Config_Manager AS TestBase
*
*-----------------------------------------------------------------------------------*
    PROTECTED oConfigManager
    PROTECTED cTestConfigFile
    
    *----------------------------------------------------------------------------*
    PROCEDURE Setup
    * Configuración inicial para cada prueba
    *----------------------------------------------------------------------------*
        * Crear archivo de configuración de prueba
        THIS.cTestConfigFile = "test_config.ini"
        THIS.CreateTestConfigFile()
        
        * Inicializar ConfigManager
        THIS.oConfigManager = NEWOBJECT("ConfigManager", "app\config\config_manager.prg")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TearDown
    * Limpieza después de cada prueba
    *----------------------------------------------------------------------------*
        * Eliminar archivo de prueba
        IF FILE(THIS.cTestConfigFile) 
            DELETE FILE (THIS.cTestConfigFile)
        ENDIF
        
        * Liberar objeto
        IF !ISNULL(THIS.oConfigManager)
            THIS.oConfigManager.Destroy()
        ENDIF
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE CreateTestConfigFile
    * Crear archivo de configuración de prueba
    *----------------------------------------------------------------------------*
        LOCAL cContent
        cContent = "# Archivo de configuración de prueba" + CHR(13) + CHR(10) + ;
                   "" + CHR(13) + CHR(10) + ;
                   "[DATABASE]" + CHR(13) + CHR(10) + ;
                   "DB_CONNECTION=MYSQL ODBC 5.1 DRIVER" + CHR(13) + CHR(10) + ;
                   "DB_HOST=localhost" + CHR(13) + CHR(10) + ;
                   "DB_PORT=3306" + CHR(13) + CHR(10) + ;
                   "DB_DATABASE=test_db" + CHR(13) + CHR(10) + ;
                   "DB_USERNAME=test_user" + CHR(13) + CHR(10) + ;
                   "DB_PASSWORD=test_pass" + CHR(13) + CHR(10) + ;
                   "" + CHR(13) + CHR(10) + ;
                   "[CONFIG]" + CHR(13) + CHR(10) + ;
                   "ENCRYPT=OFF" + CHR(13) + CHR(10) + ;
                   "LOG_ENABLED=ON" + CHR(13) + CHR(10) + ;
                   "LOG_LEVEL=INFO" + CHR(13) + CHR(10) + ;
                   "" + CHR(13) + CHR(10) + ;
                   "[ECOMMERCE]" + CHR(13) + CHR(10) + ;
                   "URL_ECOMMERCE=https://test.example.com/" + CHR(13) + CHR(10) + ;
                   "CK_ECOMMERCE=test_consumer_key" + CHR(13) + CHR(10) + ;
                   "CS_ECOMMERCE=test_consumer_secret" + CHR(13) + CHR(10) + ;
                   "" + CHR(13) + CHR(10) + ;
                   "[SYNC]" + CHR(13) + CHR(10) + ;
                   "SYNC_INTERVAL_MINUTES=15" + CHR(13) + CHR(10) + ;
                   "MAX_RETRIES=3" + CHR(13) + CHR(10) + ;
                   "BATCH_SIZE=50" + CHR(13) + CHR(10) + ;
                   "" + CHR(13) + CHR(10) + ;
                   "[ARGENTINA]" + CHR(13) + CHR(10) + ;
                   "CURRENCY=ARS" + CHR(13) + CHR(10) + ;
                   "DATE_FORMAT=DD/MM/YYYY" + CHR(13) + CHR(10) + ;
                   "TIMEZONE=America/Argentina/Buenos_Aires" + CHR(13) + CHR(10) + ;
                   "DECIMAL_SEPARATOR=," + CHR(13) + CHR(10) + ;
                   "THOUSANDS_SEPARATOR=." + CHR(13) + CHR(10) + ;
                   "" + CHR(13) + CHR(10) + ;
                   "[LEGACY_MAPPING]" + CHR(13) + CHR(10) + ;
                   "PRODUCT_TABLE=productos" + CHR(13) + CHR(10) + ;
                   "PRODUCT_ID_FIELD=codigo" + CHR(13) + CHR(10) + ;
                   "PRODUCT_NAME_FIELD=descripcion" + CHR(13) + CHR(10) + ;
                   "PRODUCT_PRICE_FIELD=precio" + CHR(13) + CHR(10) + ;
                   "PRODUCT_STOCK_FIELD=stock"
        
        STRTOFILE(cContent, THIS.cTestConfigFile)
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestInit
    * Probar inicialización de ConfigManager
    *----------------------------------------------------------------------------*
        THIS.AssertNotNull(THIS.oConfigManager, "ConfigManager debe inicializarse correctamente")
        THIS.AssertTrue(THIS.oConfigManager.GetConfigFile()= "config.ini", "Archivo de configuración por defecto debe ser config.ini")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestInitWithCustomFile
    * Probar inicialización con archivo personalizado
    *----------------------------------------------------------------------------*
        LOCAL oCustomConfig
        oCustomConfig = NEWOBJECT("ConfigManager", "app\config\config_manager.prg", "", THIS.cTestConfigFile)
        
        THIS.AssertNotNull(oCustomConfig, "ConfigManager debe inicializarse con archivo personalizado")
        THIS.AssertTrue(oCustomConfig.GetConfigFile() = THIS.cTestConfigFile, "Archivo de configuración debe ser el especificado")
        
        oCustomConfig.Destroy()
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestLoadConfig
    * Probar carga de configuración
    *----------------------------------------------------------------------------*
        LOCAL lbResult
        lbResult = THIS.oConfigManager.LoadConfig(THIS.cTestConfigFile)
        
        THIS.AssertTrue(lbResult, "LoadConfig debe retornar TRUE para archivo válido")
        THIS.AssertTrue(THIS.oConfigManager.GetConfigFile() = THIS.cTestConfigFile, "Archivo de configuración debe actualizarse")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestLoadConfigFileNotFound
    * Probar carga de archivo inexistente
    *----------------------------------------------------------------------------*
        LOCAL lbResult
        lbResult = THIS.oConfigManager.LoadConfig("archivo_inexistente.ini")
        
        THIS.AssertFalse(lbResult, "LoadConfig debe retornar FALSE para archivo inexistente")
        THIS.AssertNotEmpty(THIS.oConfigManager.cLastError, "Debe establecer mensaje de error")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestGetValue
    * Probar obtención de valores
    *----------------------------------------------------------------------------*
        * Cargar configuración primero
        THIS.oConfigManager.LoadConfig(THIS.cTestConfigFile)
        
        * Probar valores existentes
        THIS.AssertEqual("MYSQL ODBC 5.1 DRIVER", THIS.oConfigManager.GetValue("DATABASE", "DB_CONNECTION"), "Debe obtener valor de DATABASE.DB_CONNECTION")
        THIS.AssertEqual("localhost", THIS.oConfigManager.GetValue("DATABASE", "DB_HOST"), "Debe obtener valor de DATABASE.DB_HOST")
        THIS.AssertEqual("3306", THIS.oConfigManager.GetValue("DATABASE", "DB_PORT"), "Debe obtener valor de DATABASE.DB_PORT")
        THIS.AssertEqual("test_db", THIS.oConfigManager.GetValue("DATABASE", "DB_DATABASE"), "Debe obtener valor de DATABASE.DB_DATABASE")
        THIS.AssertEqual("test_user", THIS.oConfigManager.GetValue("DATABASE", "DB_USERNAME"), "Debe obtener valor de DATABASE.DB_USERNAME")
        THIS.AssertEqual("test_pass", THIS.oConfigManager.GetValue("DATABASE", "DB_PASSWORD"), "Debe obtener valor de DATABASE.DB_PASSWORD")
        
        * Probar valores de otras secciones
        THIS.AssertEqual("OFF", THIS.oConfigManager.GetValue("CONFIG", "ENCRYPT"), "Debe obtener valor de CONFIG.ENCRYPT")
        THIS.AssertEqual("ON", THIS.oConfigManager.GetValue("CONFIG", "LOG_ENABLED"), "Debe obtener valor de CONFIG.LOG_ENABLED")
        THIS.AssertEqual("INFO", THIS.oConfigManager.GetValue("CONFIG", "LOG_LEVEL"), "Debe obtener valor de CONFIG.LOG_LEVEL")
        
        THIS.AssertEqual("https://test.example.com/", THIS.oConfigManager.GetValue("ECOMMERCE", "URL_ECOMMERCE"), "Debe obtener valor de ECOMMERCE.URL_ECOMMERCE")
        THIS.AssertEqual("test_consumer_key", THIS.oConfigManager.GetValue("ECOMMERCE", "CK_ECOMMERCE"), "Debe obtener valor de ECOMMERCE.CK_ECOMMERCE")
        THIS.AssertEqual("test_consumer_secret", THIS.oConfigManager.GetValue("ECOMMERCE", "CS_ECOMMERCE"), "Debe obtener valor de ECOMMERCE.CS_ECOMMERCE")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestGetValueWithDefault
    * Probar obtención de valores con valor por defecto
    *----------------------------------------------------------------------------*
        * Cargar configuración primero
        THIS.oConfigManager.LoadConfig(THIS.cTestConfigFile)
        
        * Probar valor que no existe con default
        THIS.AssertEqual("default_value", THIS.oConfigManager.GetValue("DATABASE", "NON_EXISTENT", "default_value"), "Debe retornar valor por defecto para clave inexistente")
        
        * Probar sección que no existe con default
        THIS.AssertEqual("section_default", THIS.oConfigManager.GetValue("NON_EXISTENT_SECTION", "KEY", "section_default"), "Debe retornar valor por defecto para sección inexistente")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestGetValueEmpty
    * Probar obtención de valores inexistentes sin default
    *----------------------------------------------------------------------------*
        * Cargar configuración primero
        THIS.oConfigManager.LoadConfig(THIS.cTestConfigFile)
        
        * Probar valor que no existe sin default
        THIS.AssertEqual("", THIS.oConfigManager.GetValue("DATABASE", "NON_EXISTENT"), "Debe retornar cadena vacía para clave inexistente sin default")
        
        * Probar sección que no existe sin default
        THIS.AssertEqual("", THIS.oConfigManager.GetValue("NON_EXISTENT_SECTION", "KEY"), "Debe retornar cadena vacía para sección inexistente sin default")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestSetValue
    * Probar establecimiento de valores
    *----------------------------------------------------------------------------*
        * Cargar configuración primero
        THIS.oConfigManager.LoadConfig(THIS.cTestConfigFile)
        
        * Establecer nuevo valor
        LOCAL lbResult
        lbResult = THIS.oConfigManager.SetValue("TEST_SECTION", "TEST_KEY", "TEST_VALUE")
        
        THIS.AssertTrue(lbResult, "SetValue debe retornar TRUE")
        THIS.AssertEqual("TEST_VALUE", THIS.oConfigManager.GetValue("TEST_SECTION", "TEST_KEY"), "Debe poder obtener el valor establecido")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestSetValueUpdate
    * Probar actualización de valores existentes
    *----------------------------------------------------------------------------*
        * Cargar configuración primero
        THIS.oConfigManager.LoadConfig(THIS.cTestConfigFile)
        
        * Verificar valor original
        THIS.AssertEqual("localhost", THIS.oConfigManager.GetValue("DATABASE", "DB_HOST"), "Valor original debe ser localhost")
        
        * Actualizar valor
        LOCAL lbResult
        lbResult = THIS.oConfigManager.SetValue("DATABASE", "DB_HOST", "new_host")
        
        THIS.AssertTrue(lbResult, "SetValue debe retornar TRUE")
        THIS.AssertEqual("new_host", THIS.oConfigManager.GetValue("DATABASE", "DB_HOST"), "Valor debe actualizarse correctamente")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestGetSections
    * Probar obtención de secciones
    *----------------------------------------------------------------------------*
        * Cargar configuración primero
        THIS.oConfigManager.LoadConfig(THIS.cTestConfigFile)
        
        DIMENSION aSections[1]
        THIS.oConfigManager.GetSections(@aSections)
        
        THIS.AssertArray(@aSections, "GetSections debe retornar array")
        THIS.AssertTrue(ALEN(aSections) >= 6, "Debe tener al menos 6 secciones")
        
        * Verificar que las secciones esperadas estén presentes
        LOCAL lcSection, lnFound
        lnFound = 0
        
        FOR EACH lcSection IN aSections
            IF INLIST(lcSection, "DATABASE", "CONFIG", "ECOMMERCE", "SYNC", "ARGENTINA", "LEGACY_MAPPING")
                lnFound = lnFound + 1
            ENDIF
        ENDFOR
        
        THIS.AssertEqual(6, lnFound, "Debe encontrar las 6 secciones principales")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestGetKeys
    * Probar obtención de claves de una sección
    *----------------------------------------------------------------------------*
        * Cargar configuración primero
        THIS.oConfigManager.LoadConfig(THIS.cTestConfigFile)
        
        LOCAL aKeys
        DIMENSION aKeys[1]
        THIS.oConfigManager.GetKeys("DATABASE", @aKeys)
        
        THIS.AssertArray(@aKeys, "GetKeys debe retornar array")
        THIS.AssertTrue(ALEN(aKeys) >= 6, "Sección DATABASE debe tener al menos 6 claves")
        
        * Verificar que las claves esperadas estén presentes
        LOCAL lcKey, lnFound
        lnFound = 0
        
        FOR EACH lcKey IN aKeys
            IF INLIST(lcKey, "DB_CONNECTION", "DB_HOST", "DB_PORT", "DB_DATABASE", "DB_USERNAME", "DB_PASSWORD")
                lnFound = lnFound + 1
            ENDIF
        ENDFOR
        
        THIS.AssertEqual(6, lnFound, "Debe encontrar las 6 claves de DATABASE")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestGetKeysNonExistentSection
    * Probar obtención de claves de sección inexistente
    *----------------------------------------------------------------------------*
        * Cargar configuración primero
        THIS.oConfigManager.LoadConfig(THIS.cTestConfigFile)
        
        LOCAL aKeys
        DIMENSION aKeys[1]
        THIS.oConfigManager.GetKeys("NON_EXISTENT_SECTION", @aKeys)
        
        THIS.AssertArrayNull(@aKeys, "GetKeys debe retornar NULL para sección inexistente")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestSectionExists
    * Probar verificación de existencia de sección
    *----------------------------------------------------------------------------*
        * Cargar configuración primero
        THIS.oConfigManager.LoadConfig(THIS.cTestConfigFile)
        
        * Probar secciones que existen
        THIS.AssertTrue(THIS.oConfigManager.SectionExists("DATABASE"), "Sección DATABASE debe existir")
        THIS.AssertTrue(THIS.oConfigManager.SectionExists("CONFIG"), "Sección CONFIG debe existir")
        THIS.AssertTrue(THIS.oConfigManager.SectionExists("ECOMMERCE"), "Sección ECOMMERCE debe existir")
        
        * Probar sección que no existe
        THIS.AssertFalse(THIS.oConfigManager.SectionExists("NON_EXISTENT_SECTION"), "Sección inexistente debe retornar FALSE")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestKeyExists
    * Probar verificación de existencia de clave
    *----------------------------------------------------------------------------*
        * Cargar configuración primero
        THIS.oConfigManager.LoadConfig(THIS.cTestConfigFile)
        
        * Probar claves que existen
        THIS.AssertTrue(THIS.oConfigManager.KeyExists("DATABASE", "DB_HOST"), "Clave DB_HOST debe existir en DATABASE")
        THIS.AssertTrue(THIS.oConfigManager.KeyExists("CONFIG", "ENCRYPT"), "Clave ENCRYPT debe existir en CONFIG")
        
        * Probar clave que no existe
        THIS.AssertFalse(THIS.oConfigManager.KeyExists("DATABASE", "NON_EXISTENT_KEY"), "Clave inexistente debe retornar FALSE")
        
        * Probar clave en sección inexistente
        THIS.AssertFalse(THIS.oConfigManager.KeyExists("NON_EXISTENT_SECTION", "KEY"), "Clave en sección inexistente debe retornar FALSE")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestRemoveKey
    * Probar eliminación de clave
    *----------------------------------------------------------------------------*
        * Cargar configuración primero
        THIS.oConfigManager.LoadConfig(THIS.cTestConfigFile)
        
        * Verificar que la clave existe
        THIS.AssertTrue(THIS.oConfigManager.KeyExists("DATABASE", "DB_HOST"), "Clave DB_HOST debe existir antes de eliminarla")
        
        * Eliminar clave
        LOCAL lbResult
        lbResult = THIS.oConfigManager.RemoveKey("DATABASE", "DB_HOST")
        
        THIS.AssertTrue(lbResult, "RemoveKey debe retornar TRUE")
        THIS.AssertFalse(THIS.oConfigManager.KeyExists("DATABASE", "DB_HOST"), "Clave DB_HOST no debe existir después de eliminarla")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestRemoveKeyNonExistent
    * Probar eliminación de clave inexistente
    *----------------------------------------------------------------------------*
        * Cargar configuración primero
        THIS.oConfigManager.LoadConfig(THIS.cTestConfigFile)
        
        * Intentar eliminar clave inexistente
        LOCAL lbResult
        lbResult = THIS.oConfigManager.RemoveKey("DATABASE", "NON_EXISTENT_KEY")
        
        THIS.AssertFalse(lbResult, "RemoveKey debe retornar FALSE para clave inexistente")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestRemoveSection
    * Probar eliminación de sección
    *----------------------------------------------------------------------------*
        * Cargar configuración primero
        THIS.oConfigManager.LoadConfig(THIS.cTestConfigFile)
        
        * Verificar que la sección existe
        THIS.AssertTrue(THIS.oConfigManager.SectionExists("DATABASE"), "Sección DATABASE debe existir antes de eliminarla")
        
        * Eliminar sección
        LOCAL lbResult
        lbResult = THIS.oConfigManager.RemoveSection("DATABASE")
        
        THIS.AssertTrue(lbResult, "RemoveSection debe retornar TRUE")
        THIS.AssertFalse(THIS.oConfigManager.SectionExists("DATABASE"), "Sección DATABASE no debe existir después de eliminarla")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestRemoveSectionNonExistent
    * Probar eliminación de sección inexistente
    *----------------------------------------------------------------------------*
        * Cargar configuración primero
        THIS.oConfigManager.LoadConfig(THIS.cTestConfigFile)
        
        * Intentar eliminar sección inexistente
        LOCAL lbResult
        lbResult = THIS.oConfigManager.RemoveSection("NON_EXISTENT_SECTION")
        
        THIS.AssertFalse(lbResult, "RemoveSection debe retornar FALSE para sección inexistente")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestSaveConfig
    * Probar guardado de configuración
    *----------------------------------------------------------------------------*
        * Cargar configuración primero
        THIS.oConfigManager.LoadConfig(THIS.cTestConfigFile)
        
        * Agregar nueva configuración
        THIS.oConfigManager.SetValue("TEST_SAVE", "TEST_KEY", "TEST_VALUE")
        
        * Guardar en nuevo archivo
        LOCAL cNewFile, lbResult
        cNewFile = "test_save_config.ini"
        lbResult = THIS.oConfigManager.SaveConfig(cNewFile)
        
        THIS.AssertTrue(lbResult, "SaveConfig debe retornar TRUE")
        THIS.AssertTrue(FILE(cNewFile), "Archivo debe crearse")
        
        * Verificar contenido
        LOCAL cContent
        cContent = FILETOSTR(cNewFile)
        THIS.AssertTrue("TEST_SAVE" $ cContent, "Archivo debe contener sección TEST_SAVE")
        THIS.AssertTrue("TEST_KEY=TEST_VALUE" $ cContent, "Archivo debe contener clave TEST_KEY")
        
        * Limpiar
        DELETE FILE (cNewFile)
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestGetLastError
    * Probar obtención del último error
    *----------------------------------------------------------------------------*
        * Limpiar error anterior
        THIS.oConfigManager.ClearLastError()
        THIS.AssertEqual("", THIS.oConfigManager.GetLastError(), "Error debe estar vacío inicialmente")
        
        * Generar error
        THIS.oConfigManager.LoadConfig("archivo_inexistente.ini")
        
        THIS.AssertNotEmpty(THIS.oConfigManager.GetLastError(), "Debe establecer mensaje de error")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestClearLastError
    * Probar limpieza del último error
    *----------------------------------------------------------------------------*
        * Generar error
        THIS.oConfigManager.LoadConfig("archivo_inexistente.ini")
        THIS.AssertNotEmpty(THIS.oConfigManager.GetLastError(), "Debe tener error")
        
        * Limpiar error
        THIS.oConfigManager.ClearLastError()
        THIS.AssertEqual("", THIS.oConfigManager.GetLastError(), "Error debe estar vacío después de limpiar")
    ENDPROC
    
    *----------------------------------------------------------------------------*
    PROCEDURE TestGetConfigObject
    * Probar obtención del objeto de configuración
    *----------------------------------------------------------------------------*
        * Cargar configuración primero
        THIS.oConfigManager.LoadConfig(THIS.cTestConfigFile)
        
        LOCAL oConfig
        oConfig = THIS.oConfigManager.GetConfigObject()
        
        THIS.AssertNotNull(oConfig, "GetConfigObject debe retornar objeto")
        THIS.AssertTrue(oConfig.Count > 0, "Objeto de configuración debe tener elementos")
    ENDPROC
    
ENDDEFINE 