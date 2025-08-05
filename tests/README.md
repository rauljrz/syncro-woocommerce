# Framework de Pruebas Unitarias para Visual FoxPro 9

## Descripción

Este framework proporciona una base sólida para realizar pruebas unitarias en Visual FoxPro 9, siguiendo las mejores prácticas y convenciones establecidas en el proyecto.

## Estructura

```
tests/
├── testbase.prg              # Clase base para todas las pruebas
├── ejecutar_pruebas.prg     # Script para ejecutar todas las pruebas
└── README.md                # Esta documentación
```

## Clase TestBase

La clase `TestBase` proporciona los siguientes métodos de aserción y control:

### Métodos de Aserción

#### Comparación de Valores
- `AssertEqual(tcExpected, tcActual, tcMessage)` - Verifica que dos valores sean iguales
- `AssertNotEqual(tcExpected, tcActual, tcMessage)` - Verifica que dos valores NO sean iguales

#### Condiciones Booleanas
- `AssertTrue(tlCondition, tcMessage)` - Verifica que una condición sea verdadera
- `AssertFalse(tlCondition, tcMessage)` - Verifica que una condición sea falsa

#### Verificación de Objetos
- `AssertNotNull(toObject, tcMessage)` - Verifica que un objeto no sea NULL
- `AssertNull(toObject, tcMessage)` - Verifica que un objeto sea NULL

#### Verificación de Arrays
- `AssertArray(toArray, tcMessage)` - Verifica que una variable sea un array válido
- `AssertArrayNull(toArray, tcMessage)` - Verifica que una variable sea un array nulo

#### Verificación de Tipos de Datos
- `AssertString(tcString, tcMessage)` - Verifica que una variable sea de tipo 'C' (carácter)
- `AssertEmpty(tcValue, tcMessage)` - Verifica que un valor esté vacío
- `AssertNotEmpty(tcValue, tcMessage)` - Verifica que un valor NO esté vacío

### Métodos de Control

#### Configuración y Limpieza
- `SetUp()` - Se ejecuta antes de cada prueba (sobrescribir en clases hijas)
- `TearDown()` - Se ejecuta después de cada prueba (sobrescribir en clases hijas)

#### Ejecución de Pruebas
- `RunTest(tcTestName)` - Ejecuta una prueba específica
- `RunAllTests()` - Ejecuta todas las pruebas de la clase

#### Gestión de Resultados
- `PrintResults()` - Imprime los resultados de las pruebas
- `AddTestResult(tlPassed, tcMessage, tcExpected, tcActual)` - Agrega un resultado de prueba

### Propiedades de TestBase

- `TestResults` - Colección con los resultados de las pruebas
- `TestCount` - Contador total de pruebas ejecutadas
- `PassedCount` - Contador de pruebas exitosas
- `FailedCount` - Contador de pruebas fallidas
- `CurrentTestName` - Nombre de la prueba actual en ejecución

## Gestión de Arrays

### Pasar Arrays por Referencia

En Visual FoxPro 9, cuando se necesita pasar un array como parámetro y que la función pueda modificarlo, se debe usar el símbolo `@` (arroba):

```vfp
* Ejemplo de función que modifica un array
FUNCTION ModificarArray(@taArray)
    taArray[1] = "Nuevo valor"
    RETURN .T.
ENDFUNC

* Llamada a la función
LOCAL aMiArray[3]
aMiArray[1] = "Valor original"
ModificarArray(@aMiArray)  && Usar @ para pasar por referencia
```

### Uso en Tests

En los tests unitarios, cuando se usa `AssertArray()`, **NO** se necesita el símbolo `@`:

```vfp
* CORRECTO - AssertArray no requiere @
LOCAL aTestArray[3]
aTestArray[1] = "test"
THIS.AssertArray(aTestArray, "El array debe ser válido")

* INCORRECTO - No usar @ con AssertArray
THIS.AssertArray(@aTestArray, "El array debe ser válido")
```

## Propiedades y Métodos PROTECTED

### Definición

Las propiedades y métodos marcados como `PROTECTED` en Visual FoxPro 9 solo pueden ser accedidos desde dentro de la clase o desde clases que hereden de ella. No pueden ser accedidos desde fuera de la clase.

### Ejemplo de Definición

```vfp
DEFINE CLASS MiClase AS Custom
    * Propiedades protegidas
    PROTECTED oDB
    PROTECTED cConfigFile
    
    * Propiedades públicas
    cLastError = ""
    
    * Métodos protegidos
    PROTECTED FUNCTION ConfigurarDB()
        * Lógica interna
    ENDFUNC
    
    * Métodos públicos
    FUNCTION GetLastError()
        RETURN THIS.cLastError
    ENDFUNC
ENDDEFINE
```

### Reglas para Tests Unitarios

#### ✅ **PERMITIDO** - Probar propiedades y métodos públicos
```vfp
* Verificar propiedades públicas
THIS.AssertString(THIS.oMiClase.cLastError, "cLastError debe ser un string")

* Verificar métodos públicos
THIS.AssertTrue(PEMSTATUS(THIS.oMiClase, "GetLastError", 5), "GetLastError debe existir")
```

#### ❌ **NO PERMITIDO** - Probar propiedades y métodos protegidos
```vfp
* INCORRECTO - Intentar acceder a propiedades protegidas
THIS.AssertNotNull(THIS.oMiClase.oDB, "oDB debe existir")  && Error
THIS.AssertString(THIS.oMiClase.cConfigFile, "cConfigFile debe ser string")  && Error

* INCORRECTO - Intentar verificar métodos protegidos
THIS.AssertTrue(PEMSTATUS(THIS.oMiClase, "ConfigurarDB", 5), "ConfigurarDB debe existir")  && Error
```

#### ✅ **ALTERNATIVA CORRECTA** - Probar comportamiento público
```vfp
* En lugar de probar propiedades protegidas, probar métodos públicos que las usan
THIS.AssertTrue(PEMSTATUS(THIS.oMiClase, "GetLastError", 5), "GetLastError debe existir")
THIS.AssertTrue(PEMSTATUS(THIS.oMiClase, "Inicializar", 5), "Inicializar debe existir")
```

## Crear Nuevas Pruebas

Para crear pruebas para una nueva clase:

1. **Crear la clase de prueba** que extienda `TestBase`:

```vfp
DEFINE CLASS Test_MiClase AS TestBase
    PROTECTED oMiClase
    
    FUNCTION SetUp()
        THIS.oMiClase = NEWOBJECT('MiClase', 'progs\MiClase.prg')
    ENDFUNC
    
    FUNCTION TearDown()
        THIS.oMiClase = .NULL.
    ENDFUNC
    
    FUNCTION TestInicializacion()
        THIS.AssertNotNull(THIS.oMiClase, 'El objeto debe inicializarse correctamente')
    ENDFUNC
    
    FUNCTION TestMetodoEspecifico()
        LOCAL lcResult
        lcResult = THIS.oMiClase.MiMetodo()
        THIS.AssertNotEmpty(lcResult, 'El resultado no debe estar vacío')
    ENDFUNC
    
    FUNCTION TestArray()
        LOCAL aTestArray[3]
        aTestArray[1] = "test"
        THIS.AssertArray(aTestArray, 'Debe ser un array válido')
    ENDFUNC
ENDDEFINE
```

2. **Convenciones de nomenclatura**:
   - Clase de prueba: `Test_[NombreClase]`
   - Métodos de prueba: `Test[NombreMetodo]`
   - Archivo de prueba: `test_[NombreClase].prg`

## Ejecutar Pruebas

### Ejecutar todas las pruebas:
```vfp
DO tests\ejecutar_pruebas.prg
```

### Ejecutar pruebas específicas:
```vfp
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

### 1. **Una prueba por método**
Cada método de prueba debe verificar una funcionalidad específica.

### 2. **Nombres descriptivos**
Los nombres de las pruebas deben ser claros y descriptivos.

### 3. **Configuración y limpieza**
Usar `SetUp()` y `TearDown()` para preparar y limpiar el entorno.

### 4. **Mensajes claros**
Proporcionar mensajes de error descriptivos en las aserciones.

### 5. **Independencia**
Las pruebas deben ser independientes entre sí.

### 6. **Cobertura**
Probar tanto casos exitosos como casos de error.

### 7. **Respetar encapsulación**
- ✅ Probar solo propiedades y métodos públicos
- ❌ No intentar acceder a propiedades o métodos protegidos
- ✅ Probar el comportamiento público que resulta del uso de elementos protegidos

### 8. **Gestión correcta de arrays**
- ✅ Usar `@` solo cuando la función modifica el array
- ✅ No usar `@` con métodos de aserción como `AssertArray()`
- ✅ Verificar que los arrays existen antes de usarlos

## Integración con el Proyecto

El framework está diseñado para integrarse con la estructura existente del proyecto:

- Usa las convenciones de nomenclatura del proyecto
- Respeta la estructura de directorios
- Utiliza las clases base existentes cuando sea apropiado
- Sigue los principios SOLID establecidos
- Respeta la encapsulación de las clases

## Dependencias

- Visual FoxPro 9
- Clases del proyecto en `progs/`
- Archivo de configuración `config.ini` (para pruebas que lo requieran)

## Solución de Problemas Comunes

### Error: "Function argument value, type, or count is invalid"
- **Causa**: Intentar acceder a propiedades o métodos protegidos
- **Solución**: Probar solo métodos públicos o verificar que el método existe con `PEMSTATUS()`

### Error: "Array not found"
- **Causa**: Array no inicializado o no pasado correctamente
- **Solución**: Verificar que el array existe antes de usarlo y usar `@` cuando sea necesario

### Error: "Property not found"
- **Causa**: Intentar acceder a propiedades protegidas
- **Solución**: Probar solo propiedades públicas o métodos que las usen 