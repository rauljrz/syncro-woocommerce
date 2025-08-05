# Framework de Pruebas Unitarias para Visual FoxPro 9

## Descripción

Este framework proporciona una base sólida para realizar pruebas unitarias en Visual FoxPro 9, siguiendo las mejores prácticas y convenciones establecidas en el proyecto.

## Estructura

```
tests/
├── TestBase.prg              # Clase base para todas las pruebas
├── test_StringConnect.prg    # Pruebas específicas para StringConnect
├── ejecutar_pruebas.prg      # Script para ejecutar todas las pruebas
└── README.md                 # Esta documentación
```

## Clase TestBase

La clase `TestBase` proporciona los siguientes métodos de aserción:

### Métodos de Aserción

- `AssertEqual(tcExpected, tcActual, tcMessage)` - Verifica que dos valores sean iguales
- `AssertNotEqual(tcExpected, tcActual, tcMessage)` - Verifica que dos valores NO sean iguales
- `AssertTrue(tlCondition, tcMessage)` - Verifica que una condición sea verdadera
- `AssertFalse(tlCondition, tcMessage)` - Verifica que una condición sea falsa
- `AssertNotNull(toObject, tcMessage)` - Verifica que un objeto no sea NULL
- `AssertNull(toObject, tcMessage)` - Verifica que un objeto sea NULL
- `AssertEmpty(tcValue, tcMessage)` - Verifica que un valor esté vacío
- `AssertNotEmpty(tcValue, tcMessage)` - Verifica que un valor NO esté vacío

### Métodos de Control

- `SetUp()` - Se ejecuta antes de cada prueba (sobrescribir en clases hijas)
- `TearDown()` - Se ejecuta después de cada prueba (sobrescribir en clases hijas)
- `RunTest(tcTestName)` - Ejecuta una prueba específica
- `RunAllTests()` - Ejecuta todas las pruebas de la clase
- `PrintResults()` - Imprime los resultados de las pruebas

## Crear Nuevas Pruebas

Para crear pruebas para una nueva clase:

1. **Crear la clase de prueba** que extienda `TestBase`:

```foxpro
DEFINE CLASS Test_MiClase AS TestBase
    PROTECTED MiClaseObj
    
    FUNCTION SetUp()
        THIS.MiClaseObj = NEWOBJECT('MiClase', 'progs\MiClase.prg')
    ENDFUNC
    
    FUNCTION TearDown()
        THIS.MiClaseObj = .NULL.
    ENDFUNC
    
    FUNCTION TestInicializacion()
        THIS.AssertNotNull(THIS.MiClaseObj, 'El objeto debe inicializarse correctamente')
    ENDFUNC
    
    FUNCTION TestMetodoEspecifico()
        LOCAL lcResult
        lcResult = THIS.MiClaseObj.MiMetodo()
        THIS.AssertNotEmpty(lcResult, 'El resultado no debe estar vacío')
    ENDFUNC
ENDDEFINE
```

2. **Convenciones de nomenclatura**:
   - Clase de prueba: `Test_[NombreClase]`
   - Métodos de prueba: `Test[NombreMetodo]`
   - Archivo de prueba: `test_[NombreClase].prg`

## Ejecutar Pruebas

### Ejecutar todas las pruebas:
```foxpro
DO tests\ejecutar_pruebas.prg
```

### Ejecutar pruebas específicas:
```foxpro
loTest = NEWOBJECT('Test_StringConnect', 'tests\test_StringConnect.prg')
loTest.RunTest('Inicializacion')
loTest.RunAllTests()
```

## Ejemplo de Salida

```
=== EJECUTANDO PRUEBAS UNITARIAS ===
Fecha y hora: 26/07/01 10:30:45

--- Pruebas de StringConnect ---
=== RESULTADOS DE PRUEBAS ===
Total de pruebas: 7
Exitosas: 7
Fallidas: 0
Porcentaje de éxito: 100.00%

=== FIN DE PRUEBAS ===
```

## Mejores Prácticas

1. **Una prueba por método**: Cada método de prueba debe verificar una funcionalidad específica
2. **Nombres descriptivos**: Los nombres de las pruebas deben ser claros y descriptivos
3. **Configuración y limpieza**: Usar `SetUp()` y `TearDown()` para preparar y limpiar el entorno
4. **Mensajes claros**: Proporcionar mensajes de error descriptivos en las aserciones
5. **Independencia**: Las pruebas deben ser independientes entre sí
6. **Cobertura**: Probar tanto casos exitosos como casos de error

## Integración con el Proyecto

El framework está diseñado para integrarse con la estructura existente del proyecto:

- Usa las convenciones de nomenclatura del proyecto
- Respeta la estructura de directorios
- Utiliza las clases base existentes cuando sea apropiado
- Sigue los principios SOLID establecidos

## Dependencias

- Visual FoxPro 9
- Clases del proyecto en `progs/`
- Archivo de configuración `config.ini` (para pruebas que lo requieran) 