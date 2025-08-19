*
*|--------------------------------------------------------------------------
*| TestBase.prg
*|--------------------------------------------------------------------------
*|
*| Clase base para pruebas unitarias
*| Author.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.08.04 - 19.38
*| Purpose.....: Clase base para todas las pruebas unitarias
*|	
*| Revisions...: v1.00 
*| Basado en...: 
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS TestBase AS Custom
*
*-----------------------------------------------------------------------------------*
	HIDDEN ;
		CLASSLIBRARY,COMMENT, ;
		BASECLASS,CONTROLCOUNT, ;
		CONTROLS,OBJECTS,OBJECT,;
		HEIGHT,HELPCONTEXTID,LEFT,NAME, ;
		PARENT,PARENTCLASS,PICTURE, ;
		TAG,TOP,WHATSTHISHELPID,WIDTH

	PROTECTED ;
		TestResults, ;
		TestCount, ;
		PassedCount, ;
		FailedCount, ;
		CurrentTestName

	TestResults = .NULL.
	TestCount = 0
	PassedCount = 0
	FailedCount = 0
	CurrentTestName = ''

	*----------------------------------------------------------------------------*		
	FUNCTION GetTestCount()
	* Obtiene el total de pruebas
	*----------------------------------------------------------------------------*		
		RETURN THIS.TestCount
	ENDFUNC
	*
	*----------------------------------------------------------------------------*		
	FUNCTION GetPassedCount()
	* Obtiene el total de pruebas exitosas
	*----------------------------------------------------------------------------*		
		RETURN THIS.PassedCount
	ENDFUNC
	*
	*----------------------------------------------------------------------------*		
	FUNCTION GetFailedCount()
	* Obtiene el total de pruebas fallidas
	*----------------------------------------------------------------------------*		
		RETURN THIS.FailedCount
	ENDFUNC
	*
	*----------------------------------------------------------------------------*		
	FUNCTION INIT
	*
	*----------------------------------------------------------------------------*
		THIS.TestResults = NEWOBJECT('Collection')
		THIS.TestCount = 0
		THIS.PassedCount = 0
		THIS.FailedCount = 0
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION AssertEquals(tcExpected, tcActual, tcMessage)
	* Verifica que dos valores sean iguales
	*----------------------------------------------------------------------------*
		RETURN THIS.AssertEqual(tcExpected, tcActual, tcMessage)
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION AssertEqual(tcExpected, tcActual, tcMessage)
	* Verifica que dos valores sean iguales
	*----------------------------------------------------------------------------*
		LOCAL llResult
		llResult = (tcExpected == tcActual)
		
		THIS.AddTestResult(llResult, tcMessage, tcExpected, tcActual)
		RETURN llResult
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION AssertNotEqual(tcExpected, tcActual, tcMessage)
	* Verifica que dos valores NO sean iguales
	*----------------------------------------------------------------------------*
		LOCAL llResult
		llResult = (tcExpected != tcActual)
		
		THIS.AddTestResult(llResult, tcMessage, 'NOT ' + TRANSFORM(tcExpected), tcActual)
		RETURN llResult
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION AssertTrue(tlCondition, tcMessage)
	* Verifica que una condición sea verdadera
	*----------------------------------------------------------------------------*
		LOCAL llResult
		llResult = (tlCondition = .T.)
		
		THIS.AddTestResult(llResult, tcMessage, '.T.', TRANSFORM(tlCondition))
		RETURN llResult
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION AssertFalse(tlCondition, tcMessage)
	* Verifica que una condición sea falsa
	*----------------------------------------------------------------------------*
		LOCAL llResult
		llResult = (tlCondition = .F.)
		
		THIS.AddTestResult(llResult, tcMessage, '.F.', TRANSFORM(tlCondition))
		RETURN llResult
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION AssertNotNull(toObject, tcMessage)
	* Verifica que un objeto no sea NULL
	*----------------------------------------------------------------------------*
		LOCAL llResult
		llResult = IIF(VARTYPE(toObject) = 'O', .T., .F.)
		
		THIS.AddTestResult(llResult, tcMessage, 'NOT NULL', IIF(toObject = .NULL., 'NULL', 'Object'))
		RETURN llResult
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION AssertNull(toObject, tcMessage)
	* Verifica que un objeto sea NULL
	*----------------------------------------------------------------------------*
		LOCAL llResult
		llResult = IIF(VARTYPE(toObject) != 'O' AND toObject = .NULL., .T., .F.)
		
		THIS.AddTestResult(llResult, tcMessage, 'NULL', IIF(toObject = .NULL., 'NULL', 'Object'))
		RETURN llResult
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION AssertArray(toArray, tcMessage)
	* Verifica que una variable sea un array
	*----------------------------------------------------------------------------*
		LOCAL llResult, lnLength
		lnLength = 0
		TRY
			lnLength = ALEN(toArray)
			llResult = IIF(lnLength > 0, .T., .F.)
		CATCH
			llResult = .F.
		ENDTRY
		
		THIS.AddTestResult(llResult, tcMessage, 'ARRAY', IIF(llResult, 'Array', 'Not Array'))
		RETURN llResult
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION AssertArrayNull(toArray, tcMessage)
	* Verifica que una variable sea un array nulo
	*----------------------------------------------------------------------------*
		LOCAL llResult, lnLength
		lnLength = 0
		TRY
			lnLength = ALEN(toArray)
			llResult = IIF(lnLength = 1 AND (toArray[1] = .NULL. OR toArray[1] = .F.), .T., .F.)
		CATCH
			llResult = .T.
		ENDTRY
		
		THIS.AddTestResult(llResult, tcMessage, 'NULL',;
				 IIF(lnLength>0, IIF(llResult, 'Array NULL', 'Array NOT NULL'), 'Not Array'))
		RETURN llResult
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION AssertString(tcString, tcMessage)
	* Verifica que una variable sea un string
	*----------------------------------------------------------------------------*
		LOCAL llResult
		llResult = IIF(VARTYPE(tcString) = 'C', .T., .F.)
		
		THIS.AddTestResult(llResult, tcMessage, 'STRING', IIF(VARTYPE(tcString) = 'C', 'String', 'Not String'))
		RETURN llResult
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION AssertEmpty(tcValue, tcMessage)
	* Verifica que un valor esté vacío
	*----------------------------------------------------------------------------*
		LOCAL llResult
		llResult = EMPTY(tcValue)
		
		THIS.AddTestResult(llResult, tcMessage, 'EMPTY', TRANSFORM(tcValue))
		RETURN llResult
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION AssertNotEmpty(tcValue, tcMessage)
	* Verifica que un valor NO esté vacío
	*----------------------------------------------------------------------------*
		LOCAL llResult
		llResult = !EMPTY(tcValue)
		
		THIS.AddTestResult(llResult, tcMessage, 'NOT EMPTY', TRANSFORM(tcValue))
		RETURN llResult
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION AddTestResult(tlPassed, tcMessage, tcExpected, tcActual)
	* Agrega un resultado de prueba a la colección
	*----------------------------------------------------------------------------*
		LOCAL loResult
		
		loResult = NEWOBJECT('EMPTY')
		ADDPROPERTY(loResult, 'TestName', THIS.CurrentTestName)
		ADDPROPERTY(loResult, 'Passed', tlPassed)
		ADDPROPERTY(loResult, 'Message', tcMessage)
		ADDPROPERTY(loResult, 'Expected', tcExpected)
		ADDPROPERTY(loResult, 'Actual', tcActual)
		ADDPROPERTY(loResult, 'Timestamp', DATETIME())
		
		THIS.TestResults.Add(loResult)
		THIS.TestCount = THIS.TestCount + 1
		
		IF tlPassed
			THIS.PassedCount = THIS.PassedCount + 1
		ELSE
			THIS.FailedCount = THIS.FailedCount + 1
		ENDIF
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION SetUp()
	* Método que se ejecuta antes de cada prueba (sobrescribir en clases hijas)
	*----------------------------------------------------------------------------*
		* Override en clases hijas
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION TearDown()
	* Método que se ejecuta después de cada prueba (sobrescribir en clases hijas)
	*----------------------------------------------------------------------------*
		* Override en clases hijas
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION RunTest(tcTestName)
	* Ejecuta una prueba específica
	*----------------------------------------------------------------------------*
		LOCAL lcMethodName
		
		THIS.CurrentTestName = tcTestName
		lcMethodName = 'Test' + tcTestName
		
		TRY
			IF PEMSTATUS(THIS, lcMethodName, 5)
				THIS.SetUp()
				EVALUATE('THIS.' + lcMethodName + '()')
				THIS.TearDown()
			ELSE
				MESSAGEBOX('Método de prueba no encontrado: ' + lcMethodName, 16, 'Error')
			ENDIF
		CATCH TO loException
	        ? '   ? ERROR GRAVE al ejecutar ' + lcMethodName+ ':'
	        ? '      Mensaje: ' + loException.Message
	        ? '      Línea: ' + ALLTRIM(STR(loException.LineNo))
	        ? '      Contenido: ' + ALLTRIM(loException.LineContents)
	        ? '      Procedimiento: ' + loException.Procedure
	        ?
		ENDTRY
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION RunAllTests()
	* Ejecuta todas las pruebas de la clase
	*----------------------------------------------------------------------------*
		LOCAL lnI, lcMethodName, lnMembers
		
		* Reiniciar contadores y limpiar resultados
		THIS.TestCount = 0
		THIS.PassedCount = 0
		THIS.FailedCount = 0
		
		* Limpiar colección de resultados
		IF !ISNULL(THIS.TestResults)
			THIS.TestResults.Destroy()
		ENDIF
		THIS.TestResults = NEWOBJECT('Collection')
		
		lnMembers = AMEMBERS(laMethods, THIS.Name, 1, 'U')
		
		FOR lnIndx = 1 TO lnMembers
			lcMethodName = laMethods[lnIndx, 1]
			IF LOWER(laMethods[lnIndx, 2])='method' AND  LEFT(lcMethodName, 4) = 'Test'
				THIS.RunTest(SUBSTR(lcMethodName, 5))
			ENDIF
		ENDFOR
		
		THIS.PrintResults()
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	FUNCTION PrintResults()
	* Imprime los resultados de las pruebas
	*----------------------------------------------------------------------------*
		LOCAL lnI, loResult, lcTimestamp, lnFailedCount
		
		lcTimestamp = TTOC(DATETIME())
		
		? '=== RESULTADOS DE PRUEBAS ==='
		? 'Clase: ' + THIS.Name
		? 'Fecha y hora: ' + lcTimestamp
		? 'Total de pruebas: ' + TRANSFORM(THIS.TestCount)
		? 'Exitosas: ' + TRANSFORM(THIS.PassedCount)
		? 'Fallidas: ' + TRANSFORM(THIS.FailedCount)
		? 'Porcentaje de éxito: ' + TRANSFORM(IIF(THIS.TestCount > 0, (THIS.PassedCount / THIS.TestCount) * 100, 0), '999.99') + '%'
		? 'Total de resultados en colección: ' + TRANSFORM(THIS.TestResults.Count)
		?
		
		* Contar pruebas fallidas reales en la colección
		lnFailedCount = 0
		FOR lnI = 1 TO THIS.TestResults.Count
			loResult = THIS.TestResults.Item(lnI)
			IF !loResult.Passed
				lnFailedCount = lnFailedCount + 1
			ENDIF
		ENDFOR
		
		IF lnFailedCount > 0
			? '=== PRUEBAS FALLIDAS (' + TRANSFORM(lnFailedCount) + ') ==='
			FOR lnI = 1 TO THIS.TestResults.Count
				loResult = THIS.TestResults.Item(lnI)
				IF !loResult.Passed
					? '? PRUEBA FALLIDA: ' + loResult.TestName
					? '   Mensaje: ' + loResult.Message
					? '   Esperado: ' + TRANSFORM(loResult.Expected)
					? '   Actual: ' + TRANSFORM(loResult.Actual)
					? '   Timestamp: ' + TTOC(loResult.Timestamp)
					? '   ----------------------------------------'
					?
				ENDIF
			ENDFOR
		ELSE
			IF THIS.FailedCount > 0
				? '??  INCONSISTENCIA: FailedCount=' + TRANSFORM(THIS.FailedCount) + ' pero no hay pruebas fallidas en la colección'
				?
			ENDIF
		ENDIF
		
		IF THIS.PassedCount > 0 AND .f. && Por ahora solo muestro las que fallan.
			? '=== PRUEBAS EXITOSAS ==='
			FOR lnI = 1 TO THIS.TestResults.Count
				loResult = THIS.TestResults.Item(lnI)
				IF loResult.Passed
					? '? ' + loResult.TestName + ' - ' + loResult.Message
				ENDIF
			ENDFOR
			?
		ENDIF
		
		? '=== RESUMEN ==='
		? IIF(THIS.FailedCount = 0, '?? TODAS LAS PRUEBAS PASARON', '??  HAY PRUEBAS FALLIDAS')
		? '========================================'
		?
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	* PRIVATE define
	*
	*----------------------------------------------------------------------------*
ENDDEFINE 