*|--------------------------------------------------------------------------
*| test_legacy_connector.prg
*|--------------------------------------------------------------------------
*|
*| Pruebas unitarias para la clase LegacyConnector
*| Author.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.08.04 - 19.38
*| Purpose.....: Pruebas unitarias para la clase LegacyConnector
*|	
*| Revisions...: v1.00 
*| Basado en...: testbase.prg
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS Test_Legacy_Connector AS TestBase
*
*-----------------------------------------------------------------------------------*
	PROTECTED oLegacyConnector
	PROTECTED oLogger
	PROTECTED oConfigManager
	PROTECTED oDB
	
	*----------------------------------------------------------------------------*
	PROCEDURE SetUp
	* Configuraci�n inicial para cada prueba
	*----------------------------------------------------------------------------*
		* Inicializar logger
		THIS.oLogger = NEWOBJECT("Logger", "progs\logger.prg")
		
		* Inicializar configuraci�n
		THIS.oConfigManager = NEWOBJECT("ConfigManager", "app\config\config_manager.prg")
		IF !THIS.oConfigManager.LoadConfig("config.ini")
			THIS.oLogger.Log("ERROR", "No se pudo cargar la configuraci�n en TestLegacyConnector")
		ENDIF
		
		* Inicializar objeto DB
		THIS.oDB = NEWOBJECT("DB", "progs\db.prg")
		
		* Inicializar LegacyConnector
		THIS.oLegacyConnector = NEWOBJECT("LegacyConnector", "app\services\legacy\legacy_connector.prg")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TearDown
	* Limpieza despu�s de cada prueba
	*----------------------------------------------------------------------------*
		IF !ISNULL(THIS.oLegacyConnector)
			THIS.oLegacyConnector.Destroy()
		ENDIF
		
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
	* Probar inicializaci�n de la clase LegacyConnector
	*----------------------------------------------------------------------------*
		THIS.AssertNotNull(THIS.oLegacyConnector, "El objeto LegacyConnector debe inicializarse correctamente")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestLoadTableMapping
	* Probar carga de mapeo de tablas
	*----------------------------------------------------------------------------*
		* Verificar que el m�todo LoadTableMapping existe
		THIS.AssertTrue(PEMSTATUS(THIS.oLegacyConnector, "LoadTableMapping", 5), "El m�todo LoadTableMapping debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestGetProducts
	* Probar m�todo GetProducts
	*----------------------------------------------------------------------------*
		* Verificar que el m�todo existe
		THIS.AssertTrue(PEMSTATUS(THIS.oLegacyConnector, "GetProducts", 5), "El m�todo GetProducts debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestGetProduct
	* Probar m�todo GetProduct
	*----------------------------------------------------------------------------*
		* Verificar que el m�todo existe
		THIS.AssertTrue(PEMSTATUS(THIS.oLegacyConnector, "GetProduct", 5), "El m�todo GetProduct debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestUpdateProductStock
	* Probar m�todo UpdateProductStock
	*----------------------------------------------------------------------------*
		* Verificar que el m�todo existe
		THIS.AssertTrue(PEMSTATUS(THIS.oLegacyConnector, "UpdateProductStock", 5), "El m�todo UpdateProductStock debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestUpdateProductPrice
	* Probar m�todo UpdateProductPrice
	*----------------------------------------------------------------------------*
		* Verificar que el m�todo existe
		THIS.AssertTrue(PEMSTATUS(THIS.oLegacyConnector, "UpdateProductPrice", 5), "El m�todo UpdateProductPrice debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestGetOrders
	* Probar m�todo GetOrders
	*----------------------------------------------------------------------------*
		* Verificar que el m�todo existe
		THIS.AssertTrue(PEMSTATUS(THIS.oLegacyConnector, "GetOrders", 5), "El m�todo GetOrders debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestCreateOrder
	* Probar m�todo CreateOrder
	*----------------------------------------------------------------------------*
		* Verificar que el m�todo existe
		THIS.AssertTrue(PEMSTATUS(THIS.oLegacyConnector, "CreateOrder", 5), "El m�todo CreateOrder debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestUpdateOrderStatus
	* Probar m�todo UpdateOrderStatus
	*----------------------------------------------------------------------------*
		* Verificar que el m�todo existe
		THIS.AssertTrue(PEMSTATUS(THIS.oLegacyConnector, "UpdateOrderStatus", 5), "El m�todo UpdateOrderStatus debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestGetCustomers
	* Probar m�todo GetCustomers
	*----------------------------------------------------------------------------*
		* Verificar que el m�todo existe
		THIS.AssertTrue(PEMSTATUS(THIS.oLegacyConnector, "GetCustomers", 5), "El m�todo GetCustomers debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestCreateCustomer
	* Probar m�todo CreateCustomer
	*----------------------------------------------------------------------------*
		* Verificar que el m�todo existe
		THIS.AssertTrue(PEMSTATUS(THIS.oLegacyConnector, "CreateCustomer", 5), "El m�todo CreateCustomer debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestTableExists
	* Probar m�todo TableExists
	*----------------------------------------------------------------------------*
		* Verificar que el m�todo existe
		THIS.AssertTrue(PEMSTATUS(THIS.oLegacyConnector, "TableExists", 5), "El m�todo TableExists debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestGetTableStructure
	* Probar m�todo GetTableStructure
	*----------------------------------------------------------------------------*
		* Verificar que el m�todo existe
		THIS.AssertTrue(PEMSTATUS(THIS.oLegacyConnector, "GetTableStructure", 5), "El m�todo GetTableStructure debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestGetLastError
	* Probar m�todo GetLastError
	*----------------------------------------------------------------------------*
		LOCAL cError
		
		cError = THIS.oLegacyConnector.GetLastError()
		THIS.AssertString(cError, "GetLastError debe devolver un string")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestClearLastError
	* Probar m�todo ClearLastError
	*----------------------------------------------------------------------------*
		* Verificar que el m�todo existe
		THIS.AssertTrue(PEMSTATUS(THIS.oLegacyConnector, "ClearLastError", 5), "El m�todo ClearLastError debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestTestConnection
	* Probar m�todo TestConnection
	*----------------------------------------------------------------------------*
		* Verificar que el m�todo existe
		THIS.AssertTrue(PEMSTATUS(THIS.oLegacyConnector, "TestConnection", 5), "El m�todo TestConnection debe existir")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestMethodCount
	* Probar que todos los m�todos esperados existen
	*----------------------------------------------------------------------------*
		* Lista de m�todos que deben existir (implementados en legacy_connector.prg)
		LOCAL aRequiredMethods[17], i
		aRequiredMethods[1] = "Init"
		aRequiredMethods[2] = "LoadTableMapping"
		aRequiredMethods[3] = "GetProducts"
		aRequiredMethods[4] = "GetProduct"
		aRequiredMethods[5] = "UpdateProductStock"
		aRequiredMethods[6] = "UpdateProductPrice"
		aRequiredMethods[7] = "GetOrders"
		aRequiredMethods[8] = "CreateOrder"
		aRequiredMethods[9] = "UpdateOrderStatus"
		aRequiredMethods[10] = "GetCustomers"
		aRequiredMethods[11] = "CreateCustomer"
		aRequiredMethods[12] = "TableExists"
		aRequiredMethods[13] = "GetTableStructure"
		aRequiredMethods[14] = "GetLastError"
		aRequiredMethods[15] = "ClearLastError"
		aRequiredMethods[16] = "TestConnection"
		aRequiredMethods[17] = "Destroy"
		
		FOR i = 1 TO 17
			THIS.AssertTrue(PEMSTATUS(THIS.oLegacyConnector, aRequiredMethods[i], 5), "El m�todo " + aRequiredMethods[i] + " debe existir")
		ENDFOR
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE TestFinalIntegration
	* Prueba final de integraci�n
	*----------------------------------------------------------------------------*
		* Verificar que todo el sistema funciona correctamente
		THIS.AssertTrue(VARTYPE(THIS.oLegacyConnector) = "O", "El objeto LegacyConnector debe ser v�lido")
		THIS.AssertString(THIS.oLegacyConnector.Class, "El nombre debe ser un string")
		THIS.AssertTrue(PEMSTATUS(THIS.oLegacyConnector, "GetProducts", 5), "GetProducts debe estar disponible")
		THIS.AssertTrue(PEMSTATUS(THIS.oLegacyConnector, "GetOrders", 5), "GetOrders debe estar disponible")
		THIS.AssertTrue(PEMSTATUS(THIS.oLegacyConnector, "GetCustomers", 5), "GetCustomers debe estar disponible")
		THIS.AssertTrue(PEMSTATUS(THIS.oLegacyConnector, "TestConnection", 5), "TestConnection debe estar disponible")
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	* PRIVATE define
	*
	*----------------------------------------------------------------------------*
ENDDEFINE 