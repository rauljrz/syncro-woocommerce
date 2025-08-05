*
*|--------------------------------------------------------------------------
*| ejecutar_pruebas.prg
*|--------------------------------------------------------------------------
*|
*| Ejecuta las pruebas unitarias
*| Author.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.08.04 - 19.38
*| Purpose.....: Ejecuta todas las pruebas unitarias del proyecto
*|	
*| Revisions...: v1.00 
*| Basado en...: 
*|
*/
*-----------------------------------------------------------------------------------*

* Configurar el directorio de trabajo
lcPath = SYS(5) + CURDIR()
SET DEFAULT TO (lcPath)
lcProc = SET("Procedure")

IF !LOWER(SET('PROCEDURE')) $ 'testbase' 
    SET PROCEDURE TO tests\TestBase.prg ADDITIVE
ENDIF
 
IF !LOWER(SET('PROCEDURE')) $ 'date2str' 
    SET PROCEDURE TO progs\date2str.prg ADDITIVE
ENDIF

* Limpiar la pantalla
CLEAR

* Configurar archivo de salida
LOCAL cReportFile, cTimestamp
cTimestamp = TTOC(DATETIME(), 1)
cReportFile = 'reporte_pruebas_' + STRTRAN(cTimestamp, ':', '') + '.txt'
cReportFile = 'test_unitario.txt'

SET PRINT TO
DELETE FILE &cReportFile
SET PRINT TO &cReportFile
SET PRINT ON
SET CONSOLE OFF

? '==============================================================================='
? '                           REPORTE DE PRUEBAS UNITARIAS'
? '==============================================================================='
? 'Fecha y hora de ejecución: ' + TTOC(DATETIME())
? 'Directorio de trabajo: ' + CURDIR()
? 'Archivo de reporte: ' + cReportFile
? '==============================================================================='
?

* Variables para estadísticas globales
LOCAL lnTotalTests, lnTotalPassed, lnTotalFailed, lnTotalClasses
lnTotalTests = 0
lnTotalPassed = 0
lnTotalFailed = 0
lnTotalClasses = 0

lnTestCount = ADIR(laTestClasses, 'tests\test_*.prg')

? '?? CLASES DE PRUEBA ENCONTRADAS: ' + ALLTRIM(STR(lnTestCount))
?

* Ejecutar pruebas que siguen el patrón de TestBase
FOR lnIndex = 1 TO lnTestCount
    lcFileName = laTestClasses[lnIndex,1]
    lcPathFile = lcPath+'tests\'+lcFileName
    lcTestClass= JUSTSTEM(lcFileName)
    
    ? '?? EJECUTANDO: ' + lcTestClass
    ? '   Archivo: ' + lcFileName
    ? '   Ruta: ' + lcPathFile
    ?
    
    * Todas las pruebas ahora siguen el patrón TestBase
    IF !LOWER(SET('PROCEDURE'))$lcTestClass
        SET PROCEDURE TO (lcPathFile) ADDITIVE
    ENDIF

    TRY
        loTestClass = NEWOBJECT(lcTestClass, lcPathFile)
        loTestClass.RunAllTests()
        
        * Acumular estadísticas
        lnTotalTests = lnTotalTests + loTestClass.GetTestCount()
        lnTotalPassed = lnTotalPassed + loTestClass.GetPassedCount()
        lnTotalFailed = lnTotalFailed + loTestClass.GetFailedCount()
        lnTotalClasses = lnTotalClasses + 1
        
        ? '   ? Prueba completada exitosamente'
        ? '   ?? Resultados: ' + ALLTRIM(STR(loTestClass.GetPassedCount())) + '/' + ALLTRIM(STR(loTestClass.GetTestCount())) + ' exitosas'
        ?
        
    CATCH TO loException
        ? '   ? ERROR al ejecutar ' + lcTestClass + ':'
        ? '      Mensaje: ' + loException.Message
        ? '      Línea: ' + ALLTRIM(STR(loException.LineNo))
        ? '      Procedimiento: ' + loException.Procedure
        ?
    ENDTRY
    
    ? '   ' + REPLICATE('-', 60)
    ?
ENDFOR

? '==============================================================================='
? '                           RESUMEN FINAL'
? '==============================================================================='
? '?? ESTADÍSTICAS GLOBALES:'
? '   Clases ejecutadas: ' + ALLTRIM(STR(lnTotalClasses))
? '   Total de pruebas: ' + ALLTRIM(STR(lnTotalTests))
? '   Pruebas exitosas: ' + ALLTRIM(STR(lnTotalPassed))
? '   Pruebas fallidas: ' + ALLTRIM(STR(lnTotalFailed))
? '   Porcentaje de éxito: ' + TRANSFORM(IIF(lnTotalTests > 0, (lnTotalPassed / lnTotalTests) * 100, 0), '999.99') + '%'
?

IF lnTotalFailed = 0
    ? '?? ¡TODAS LAS PRUEBAS PASARON EXITOSAMENTE!'
ELSE
    ? '??  HAY PRUEBAS FALLIDAS - REVISAR REPORTE DETALLADO'
ENDIF

? '==============================================================================='
? 'Fecha y hora de finalización: ' + TTOC(DATETIME())
? 'Archivo de reporte: ' + cReportFile
? '==============================================================================='

SET PRINT TO 
SET PRINT OFF

? 'Reporte generado en: ' + cReportFile
WAIT "Presione cualquier tecla para abrir el reporte..." WINDOWS NOWAIT
MODIFY FILE &cReportFile NOWAIT
SET PROCEDURE TO (lcProc)

