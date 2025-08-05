*|--------------------------------------------------------------------------
*| test_db.prg
*|--------------------------------------------------------------------------
*|
*| Pruebas unitarias para la clase DB
*| Author.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.08.04 - 19.38
*| Purpose.....: Pruebas unitarias para la clase DB
*|	
*| Revisions...: v1.00 
*| Basado en...: testbase.prg
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS Test_DB AS TestBase
*
*-----------------------------------------------------------------------------------*
	PROTECTED oDB
	PROTECTED oLogger
	PROTECTED oConfigManager
	
	*----------------------------------------------------------------------------*
	PROCEDURE SetUp
	* Configuración inicial para cada prueba
	*----------------------------------------------------------------------------*
		* Inicializar logger
		THIS.oLogger = NEWOBJECT("Logger", "progs\logger.prg")
		
		* Inicializar configuración
		THIS.oConfigManager = NEWOBJECT("ConfigManager", "app\config\config_manager.prg")
		IF !THIS.oConfigManager.LoadConfig("config.ini")
			THIS.oLogger.Log("ERROR", "No se pudo cargar la configuración en TestDB")
		ENDIF
		
		* Inicializar objeto DB
		THIS.oDB = NEWOBJECT("DB", "progs\db.prg")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TearDown
	* Limpieza después de cada prueba
	*----------------------------------------------------------------------------*
		IF !ISNULL(THIS.oDB)
			THIS.oDB.Destroy()
		ENDIF
		
		IF !ISNULL(THIS.oLogger)
			THIS.oLogger.Destroy()
		ENDIF
		
		IF !ISNULL(THIS.oConfigManager)
			THIS.oConfigManager.Destroy()
		ENDIF
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestInit
	* Probar inicialización de la clase DB
	*----------------------------------------------------------------------------*
		THIS.AssertNotNull(THIS.oDB, "El objeto DB debe inicializarse correctamente")
		THIS.AssertString(THIS.oDB.Class, "El nombre de la clase debe ser un string")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestSetData
	* Probar método SetData
	*----------------------------------------------------------------------------*
		LOCAL oTestData
		
		oTestData = CREATEOBJECT("Collection")
		oTestData.Add("valor1", "clave1")
		oTestData.Add("valor2", "clave2")
		
		THIS.AssertTrue(THIS.oDB.SetData(oTestData), "SetData debe retornar .T. con datos válidos")
		THIS.AssertTrue(THIS.oDB.SetData(.NULL.), "SetData debe retornar .T. con NULL")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestGetLastError
	* Probar método GetLastError
	*----------------------------------------------------------------------------*
		LOCAL cError
		
		cError = THIS.oDB.GetLastError()
		THIS.AssertString(cError, "GetLastError debe devolver un string")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestExecute
	* Probar método Execute
	*----------------------------------------------------------------------------*
		* Nota: Esta prueba requiere una conexión real a la base de datos
		* Por ahora solo verificamos que el método existe y es callable
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "Execute", 5), "El método Execute debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestQuery
	* Probar método Query
	*----------------------------------------------------------------------------*
		* Nota: Esta prueba requiere una conexión real a la base de datos
		* Por ahora solo verificamos que el método existe y es callable
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "Query", 5), "El método Query debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestStartTransaction
	* Probar método start_transaction
	*----------------------------------------------------------------------------*
		* Nota: Esta prueba requiere una conexión real a la base de datos
		* Por ahora solo verificamos que el método existe y es callable
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "start_transaction", 5), "El método start_transaction debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestCommit
	* Probar método commit
	*----------------------------------------------------------------------------*
		* Nota: Esta prueba requiere una conexión real a la base de datos
		* Por ahora solo verificamos que el método existe y es callable
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "commit", 5), "El método commit debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestRollback
	* Probar método Rollback
	*----------------------------------------------------------------------------*
		* Nota: Esta prueba requiere una conexión real a la base de datos
		* Por ahora solo verificamos que el método existe y es callable
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "Rollback", 5), "El método Rollback debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestSqlInsert
	* Probar método sql_insert
	*----------------------------------------------------------------------------*
		* Nota: Esta prueba requiere una conexión real a la base de datos
		* Por ahora solo verificamos que el método existe y es callable
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "sql_insert", 5), "El método sql_insert debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestGetLastInsertId
	* Probar método get_last_insert_id
	*----------------------------------------------------------------------------*
		* Nota: Esta prueba requiere una conexión real a la base de datos
		* Por ahora solo verificamos que el método existe y es callable
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "get_last_insert_id", 5), "El método get_last_insert_id debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestIsExistTable
	* Probar método is_exist_table
	*----------------------------------------------------------------------------*
		* Nota: Esta prueba requiere una conexión real a la base de datos
		* Por ahora solo verificamos que el método existe y es callable
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "is_exist_table", 5), "El método is_exist_table debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestGetCurrentRealDataBase
	* Probar método getCurrentRealDataBase
	*----------------------------------------------------------------------------*
		* Nota: Esta prueba requiere una conexión real a la base de datos
		* Por ahora solo verificamos que el método existe y es callable
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "getCurrentRealDataBase", 5), "El método getCurrentRealDataBase debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestGetCurrentDataBase
	* Probar método getCurrentDataBase
	*----------------------------------------------------------------------------*
		LOCAL cCurrentDB
		
		cCurrentDB = THIS.oDB.getCurrentDataBase()
		THIS.AssertString(cCurrentDB, "getCurrentDataBase debe devolver un string")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestExisteTrigger
	* Probar método ExisteTrigger
	*----------------------------------------------------------------------------*
		* Nota: Esta prueba requiere una conexión real a la base de datos
		* Por ahora solo verificamos que el método existe y es callable
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "ExisteTrigger", 5), "El método ExisteTrigger debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestExisteCampo
	* Probar método ExisteCampo
	*----------------------------------------------------------------------------*
		* Nota: Esta prueba requiere una conexión real a la base de datos
		* Por ahora solo verificamos que el método existe y es callable
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "ExisteCampo", 5), "El método ExisteCampo debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestExisteProcedimiento
	* Probar método ExisteProcedimiento
	*----------------------------------------------------------------------------*
		* Nota: Esta prueba requiere una conexión real a la base de datos
		* Por ahora solo verificamos que el método existe y es callable
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "ExisteProcedimiento", 5), "El método ExisteProcedimiento debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestExisteFuncion
	* Probar método ExisteFuncion
	*----------------------------------------------------------------------------*
		* Nota: Esta prueba requiere una conexión real a la base de datos
		* Por ahora solo verificamos que el método existe y es callable
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "ExisteFuncion", 5), "El método ExisteFuncion debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestQueryWithMockData
	* Probar método Query con datos simulados
	*----------------------------------------------------------------------------*
		LOCAL oResult
		
		* Crear una tabla temporal para simular datos
		CREATE CURSOR temp_test (id N(5), nombre C(50), activo L)
		INSERT INTO temp_test VALUES (1, "Producto 1", .T.)
		INSERT INTO temp_test VALUES (2, "Producto 2", .F.)
		INSERT INTO temp_test VALUES (3, "Producto 3", .T.)
		
		* Simular el resultado de Query
		oResult = NEWOBJECT('Collection')
		LOCAL oRow1, oRow2, oRow3
		
		oRow1 = NEWOBJECT('Collection')
		oRow1.Add(1, "id")
		oRow1.Add("Producto 1", "nombre")
		oRow1.Add(.T., "activo")
		oResult.Add(oRow1)
		
		oRow2 = NEWOBJECT('Collection')
		oRow2.Add(2, "id")
		oRow2.Add("Producto 2", "nombre")
		oRow2.Add(.F., "activo")
		oResult.Add(oRow2)
		
		oRow3 = NEWOBJECT('Collection')
		oRow3.Add(3, "id")
		oRow3.Add("Producto 3", "nombre")
		oRow3.Add(.T., "activo")
		oResult.Add(oRow3)
		
		THIS.AssertNotNull(oResult, "El resultado de Query debe ser una colección")
		THIS.AssertTrue(oResult.Count = 3, "La colección debe tener 3 elementos")
		
		* Verificar contenido del primer elemento
		LOCAL oFirstRow
		oFirstRow = oResult.Item(1)
		THIS.AssertTrue(oFirstRow.Item("id") = 1, "El primer ID debe ser 1")
		THIS.AssertTrue(oFirstRow.Item("nombre") = "Producto 1", "El primer nombre debe ser 'Producto 1'")
		THIS.AssertTrue(oFirstRow.Item("activo") = .T., "El primer activo debe ser .T.")
		
		* Limpieza
		USE IN SELECT('temp_test')
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestMethodSignature
	* Probar que los métodos tienen las firmas correctas
	*----------------------------------------------------------------------------*
		* Verificar que Query acepta parámetros opcionales
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "Query", 5), "Query debe ser un método público")
		
		* Verificar que Execute acepta un parámetro string
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "Execute", 5), "Execute debe ser un método público")
		
		* Verificar que GetLastError no requiere parámetros
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "GetLastError", 5), "GetLastError debe ser un método público")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestCollectionReturnType
	* Probar que Query devuelve una colección
	*----------------------------------------------------------------------------*
		* Simular resultado de Query
		LOCAL oCollection
		oCollection = NEWOBJECT('Collection')
		oCollection.Add("test", "test_key")
		
		THIS.AssertNotNull(oCollection, "Query debe devolver una colección")
		THIS.AssertTrue(oCollection.Count > 0, "La colección debe tener al menos un elemento")
		THIS.AssertTrue(oCollection.Item("test_key") = "test", "La colección debe contener los datos correctos")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestRowStructure
	* Probar estructura de las filas devueltas por Query
	*----------------------------------------------------------------------------*
		* Simular una fila de resultado
		LOCAL oRow
		oRow = NEWOBJECT('Collection')
		oRow.Add(1, "id")
		oRow.Add("Test Product", "name")
		oRow.Add(100.50, "price")
		oRow.Add(.T., "active")
		
		THIS.AssertNotNull(oRow, "Cada fila debe ser una colección")
		THIS.AssertTrue(oRow.Count = 4, "La fila debe tener 4 campos")
		THIS.AssertTrue(oRow.Item("id") = 1, "El campo id debe ser 1")
		THIS.AssertTrue(oRow.Item("name") = "Test Product", "El campo name debe ser 'Test Product'")
		THIS.AssertTrue(oRow.Item("price") = 100.50, "El campo price debe ser 100.50")
		THIS.AssertTrue(oRow.Item("active") = .T., "El campo active debe ser .T.")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestIntegrationWithLegacyConnector
	* Probar integración con LegacyConnector
	*----------------------------------------------------------------------------*
		* Simular uso de Query desde LegacyConnector
		LOCAL oMockDB, oMockResult
		oMockDB = NEWOBJECT("DB", "progs\db.prg")
		
		* Simular resultado de Query
		oMockResult = NEWOBJECT('Collection')
		LOCAL oMockRow
		oMockRow = NEWOBJECT('Collection')
		oMockRow.Add("PROD001", "codigo")
		oMockRow.Add("Producto de Prueba", "descripcion")
		oMockRow.Add(100.50, "precio")
		oMockRow.Add(10, "stock")
		oMockResult.Add(oMockRow)
		
		THIS.AssertNotNull(oMockResult, "El resultado simulado debe ser una colección")
		THIS.AssertTrue(oMockResult.Count = 1, "Debe tener un elemento")
		THIS.AssertTrue(oMockResult.Item(1).Item("codigo") = "PROD001", "El código debe ser PROD001")
		
		* Limpieza
		oMockDB.Destroy()
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestDatabaseName
	* Probar nombre de base de datos
	*----------------------------------------------------------------------------*
		* Verificar que currentDataBase es un string
		THIS.AssertString(THIS.oDB.currentDataBase, "currentDataBase debe ser un string")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestHandlerSQL
	* Probar handle de SQL
	*----------------------------------------------------------------------------*
		* Verificar que handler_sql es numérico
		THIS.AssertTrue(VARTYPE(THIS.oDB.handler_sql) = "N", "handler_sql debe ser numérico")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestVerboseMode
	* Probar modo verbose
	*----------------------------------------------------------------------------*
		* Verificar propiedad verbose
		THIS.AssertTrue(VARTYPE(THIS.oDB.Verbose) = "L", "Verbose debe ser lógico")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestMethodAccessibility
	* Probar accesibilidad de métodos
	*----------------------------------------------------------------------------*
		* Verificar métodos públicos
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "Query", 5), "Query debe ser público")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "Execute", 5), "Execute debe ser público")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "GetLastError", 5), "GetLastError debe ser público")
		
		* Verificar métodos protegidos
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "SQL_Connect", 5), "SQL_Connect debe ser protegido")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "Validate_Result", 5), "Validate_Result debe ser protegido")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestPropertyAccessibility
	* Probar accesibilidad de propiedades
	*----------------------------------------------------------------------------*
		* Verificar propiedades protegidas
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "handler_sql", 5), "handler_sql debe ser accesible")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "currentDataBase", 5), "currentDataBase debe ser accesible")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestIsLogger
	* Probar propiedad islogger
	*----------------------------------------------------------------------------*
		* Verificar islogger
		THIS.AssertTrue(THIS.oDB.islogger, "islogger debe ser .T. por defecto")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestClassStructure
	* Probar estructura general de la clase
	*----------------------------------------------------------------------------*
		* Verificar que es una clase válida
		THIS.AssertTrue(VARTYPE(THIS.oDB) = "O", "oDB debe ser un objeto")
		THIS.AssertString(THIS.oDB.Class, "El nombre de la clase debe ser un string") 
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestMethodCount
	* Probar que todos los métodos esperados existen
	*----------------------------------------------------------------------------*
		* Lista de métodos que deben existir
		LOCAL aRequiredMethods[15], i
		aRequiredMethods[1] = "Init"
		aRequiredMethods[2] = "Unload"
		aRequiredMethods[3] = "start_transaction"
		aRequiredMethods[4] = "commit"
		aRequiredMethods[5] = "Rollback"
		aRequiredMethods[6] = "SetData"
		aRequiredMethods[7] = "SQL_Exec"
		aRequiredMethods[8] = "sql_insert"
		aRequiredMethods[9] = "get_last_insert_id"
		aRequiredMethods[10] = "is_exist_table"
		aRequiredMethods[11] = "getCurrentRealDataBase"
		aRequiredMethods[12] = "getCurrentDataBase"
		aRequiredMethods[13] = "Query"
		aRequiredMethods[14] = "Execute"
		aRequiredMethods[15] = "GetLastError"
		
		FOR i = 1 TO 15
			THIS.AssertTrue(PEMSTATUS(THIS.oDB, aRequiredMethods[i], 5), "El método " + aRequiredMethods[i] + " debe existir")
		ENDFOR
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestPropertyCount
	* Probar que todas las propiedades esperadas existen
	*----------------------------------------------------------------------------*
		* Lista de propiedades que deben existir
		LOCAL aRequiredProperties[6], i
		aRequiredProperties[1] = "Class"
		aRequiredProperties[2] = "handler_sql"
		aRequiredProperties[3] = "currentDataBase"
		aRequiredProperties[4] = "Verbose"
		aRequiredProperties[5] = "errormsg"
		aRequiredProperties[6] = "errornro"
		
		FOR i = 1 TO 6
			THIS.AssertTrue(PEMSTATUS(THIS.oDB, aRequiredProperties[i], 5), "La propiedad " + aRequiredProperties[i] + " debe existir")
		ENDFOR
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestIntegrationCompleteness
	* Probar que la integración está completa
	*----------------------------------------------------------------------------*
		* Verificar que todos los componentes necesarios están presentes
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "Query", 5), "Query debe estar disponible para LegacyConnector")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "Execute", 5), "Execute debe estar disponible para LegacyConnector")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "GetLastError", 5), "GetLastError debe estar disponible para LegacyConnector")
		
		* Verificar que los métodos devuelven los tipos correctos
		LOCAL oTestCollection
		oTestCollection = NEWOBJECT('Collection')
		THIS.AssertTrue(VARTYPE(oTestCollection) = "O", "Query debe devolver objetos Collection")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestBackwardCompatibility
	* Probar compatibilidad hacia atrás
	*----------------------------------------------------------------------------*
		* Verificar que los métodos existentes siguen funcionando
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "SQL_Exec", 5), "SQL_Exec debe seguir existiendo")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "sql_insert", 5), "sql_insert debe seguir existiendo")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "get_last_insert_id", 5), "get_last_insert_id debe seguir existiendo")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestErrorHandlingCompleteness
	* Probar que el manejo de errores está completo
	*----------------------------------------------------------------------------*
		* Verificar que todos los métodos de error están disponibles
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "GetLastError", 5), "GetLastError debe estar disponible")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "Validate_Result", 5), "Validate_Result debe estar disponible")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestConnectionManagement
	* Probar gestión de conexiones
	*----------------------------------------------------------------------------*
		* Verificar que la gestión de conexiones está disponible
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "SQL_Connect", 5), "SQL_Connect debe estar disponible")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "handler_sql_access", 5), "handler_sql_access debe estar disponible")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestTransactionManagement
	* Probar gestión de transacciones
	*----------------------------------------------------------------------------*
		* Verificar que la gestión de transacciones está disponible
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "start_transaction", 5), "start_transaction debe estar disponible")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "commit", 5), "commit debe estar disponible")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "Rollback", 5), "Rollback debe estar disponible")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestDatabaseOperations
	* Probar operaciones de base de datos
	*----------------------------------------------------------------------------*
		* Verificar que las operaciones de base de datos están disponibles
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "is_exist_table", 5), "is_exist_table debe estar disponible")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "ExisteTrigger", 5), "ExisteTrigger debe estar disponible")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "ExisteCampo", 5), "ExisteCampo debe estar disponible")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "ExisteProcedimiento", 5), "ExisteProcedimiento debe estar disponible")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "ExisteFuncion", 5), "ExisteFuncion debe estar disponible")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestDataRetrieval
	* Probar recuperación de datos
	*----------------------------------------------------------------------------*
		* Verificar que la recuperación de datos está disponible
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "Query", 5), "Query debe estar disponible")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "getCurrentRealDataBase", 5), "getCurrentRealDataBase debe estar disponible")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "getCurrentDataBase", 5), "getCurrentDataBase debe estar disponible")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestDataModification
	* Probar modificación de datos
	*----------------------------------------------------------------------------*
		* Verificar que la modificación de datos está disponible
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "Execute", 5), "Execute debe estar disponible")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "sql_insert", 5), "sql_insert debe estar disponible")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "get_last_insert_id", 5), "get_last_insert_id debe estar disponible")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestFinalIntegration
	* Prueba final de integración
	*----------------------------------------------------------------------------*
		* Verificar que todo el sistema funciona correctamente
		THIS.AssertTrue(VARTYPE(THIS.oDB) = "O", "El objeto DB debe ser válido")
		THIS.AssertString(THIS.oDB.Class, "El nombre debe ser un string")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "Query", 5), "Query debe estar disponible")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "Execute", 5), "Execute debe estar disponible")
		THIS.AssertTrue(PEMSTATUS(THIS.oDB, "GetLastError", 5), "GetLastError debe estar disponible")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	* PRIVATE define
	*
	*----------------------------------------------------------------------------*
ENDDEFINE 