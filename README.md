# Sistema Intermediario VFP9 - WooCommerce

## Descripción

Sistema desarrollado en Visual FoxPro 9 que actúa como intermediario entre un sistema legacy y una tienda online de WooCommerce, permitiendo la sincronización bidireccional de datos y la gestión automatizada de pedidos.

## Características Principales

- ✅ **Sincronización de Productos**: Crear, actualizar y modificar precios en WooCommerce
- ✅ **Gestión de Pedidos**: Descarga automática de nuevos pedidos desde WooCommerce
- ✅ **Gestión de Clientes**: Sincronización bidireccional de clientes
- ✅ **Configuración Flexible**: Mapeo configurable de campos entre sistemas
- ✅ **Sistema de Logging**: Logs detallados y configurables
- ✅ **Cumplimiento Argentino**: Configuración específica para Argentina (moneda, fechas, etc.)
- ✅ **Manejo de Errores**: Sistema robusto de reintentos y manejo de excepciones

## Estructura del Proyecto

```
/api-ecommerce/
├── config.ini                 # Configuración principal
├── README.md                  # Este archivo
├── progs/                     # Clases base existentes
│   ├── db.prg                # Conexión a base de datos
│   ├── logger.prg            # Sistema de logging
│   ├── json.prg              # Manejo de JSON
│   ├── catchexception.prg    # Manejo de excepciones
│   ├── cipher.prg            # Encriptación
│   ├── factory.prg           # Factory pattern
│   ├── stringconnect.prg     # Conexión de strings
│   └── str2date.prg          # Conversión de fechas
├── app/                      # Nueva estructura
│   ├── config/               # Configuraciones específicas
│   │   ├── config_manager.prg    # Gestor de configuración
│   │   └── database_schema.sql   # Esquema de base de datos
│   ├── services/             # Lógica de negocio
│   │   ├── woocommerce/      # Servicios de WooCommerce
│   │   │   └── woocommerce_api.prg
│   │   ├── sync/             # Servicios de sincronización
│   │   │   └── sync_manager.prg
│   │   └── legacy/           # Servicios del sistema legacy
│   │       └── legacy_connector.prg
│   ├── models/               # Modelos de datos
│   │   ├── woocommerce/      # Modelos de WooCommerce
│   │   └── legacy/           # Modelos del sistema legacy
│   ├── repositories/         # Acceso a datos
│   └── http/                 # Controladores HTTP
│       ├── controllers/      # Controladores
│       └── middleware/       # Middleware
├── logs/                     # Archivos de log
├── data/                     # Datos temporales
├── tests/                    # Pruebas unitarias
│   ├── test_stringconnect.prg
│   ├── testbase.prg
│   ├── ejecutar_pruebas.prg
│   └── README.md
└── documentations/           # Documentación
    └── Instrucciones.md      # Análisis preliminar
```

## Configuración

### Archivo config.ini

El archivo `config.ini` contiene toda la configuración del sistema:

```ini
[DATABASE]
DB_CONNECTION=MYSQL ODBC 5.1 DRIVER

[COMERCIAL]
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=mgcagontech
DB_USERNAME=root
DB_PASSWORD=

[CONFIG]
ENCRYPT=OFF
LOG_ENABLED=ON
LOG_LEVEL=INFO
LOG_RETENTION_DAYS=30

[ECOMMERCE]
URL_ECOMMERCE=https://mediumvioletred-armadillo-288296.hostingersite.com/
CK_ECOMMERCE=ck_c4bdb15c8b8a52af1ed62f1ef7d51abb8751fe93
CS_ECOMMERCE=cs_7260ed1104ec8130999bff063c9e6d5afc89c699

[SYNC]
SYNC_INTERVAL_MINUTES=15
MAX_RETRIES=3
BATCH_SIZE=50

[ARGENTINA]
CURRENCY=ARS
DATE_FORMAT=DD/MM/YYYY
TIMEZONE=America/Argentina/Buenos_Aires
DECIMAL_SEPARATOR=,
THOUSANDS_SEPARATOR=.

[LEGACY_MAPPING]
PRODUCT_TABLE=productos
PRODUCT_ID_FIELD=codigo
PRODUCT_NAME_FIELD=descripcion
PRODUCT_PRICE_FIELD=precio
PRODUCT_STOCK_FIELD=stock

ORDER_TABLE=pedidos
ORDER_ID_FIELD=numero_pedido
ORDER_DATE_FIELD=fecha_pedido
ORDER_STATUS_FIELD=estado

CUSTOMER_TABLE=clientes
CUSTOMER_ID_FIELD=codigo_cliente
CUSTOMER_NAME_FIELD=nombre
CUSTOMER_EMAIL_FIELD=email
```

### Base de Datos

El sistema utiliza las siguientes tablas intermediarias:

- `config_mapping`: Mapeo de campos entre sistemas
- `sync_products`: Sincronización de productos
- `sync_orders`: Sincronización de pedidos
- `sync_customers`: Sincronización de clientes
- `sync_logs`: Logs de sincronización
- `sync_categories`: Sincronización de categorías
- `system_config`: Configuración del sistema

## Instalación

### Requisitos Previos

- Visual FoxPro 9
- MySQL Server
- Acceso a API de WooCommerce (Consumer Key y Consumer Secret)

### Pasos de Instalación

1. **Clonar o descargar el proyecto**
2. **Configurar la base de datos**:
   ```sql
   -- Ejecutar el script de esquema
   SOURCE app/config/database_schema.sql;
   ```
3. **Configurar config.ini**:
   - Actualizar credenciales de base de datos
   - Configurar URL y credenciales de WooCommerce
   - Ajustar mapeo de tablas según el sistema legacy
4. **Probar la conexión**:
   ```foxpro
   DO app/services/legacy/legacy_connector.prg
   ```

## Uso

### Sincronización Manual

```foxpro
* Inicializar SyncManager
LOCAL oSyncManager
oSyncManager = NEWOBJECT("SyncManager", "app/services/sync/sync_manager.prg")

* Sincronizar productos desde legacy a WooCommerce
oSyncManager.SyncProductsFromLegacy()

* Sincronizar pedidos desde WooCommerce
oSyncManager.SyncOrdersFromWooCommerce()

* Sincronizar clientes desde WooCommerce
oSyncManager.SyncCustomersFromWooCommerce()
```

### Sincronización Automática

El sistema puede configurarse para ejecutar sincronizaciones automáticas:

```foxpro
* Configurar intervalo de sincronización (en config.ini)
SYNC_INTERVAL_MINUTES=15

* Habilitar sincronización automática
oSyncManager.SetSyncEnabled(.T.)
```

### Monitoreo

Los logs se almacenan en la carpeta `logs/` y en la tabla `sync_logs`:

```sql
-- Ver estado de sincronización
SELECT * FROM v_sync_status;

-- Ver errores recientes
SELECT * FROM v_recent_errors;
```

## API de WooCommerce

El sistema utiliza la API REST de WooCommerce v3 para las siguientes operaciones:

### Productos
- `GET /wp-json/wc/v3/products` - Listar productos
- `POST /wp-json/wc/v3/products` - Crear producto
- `PUT /wp-json/wc/v3/products/{id}` - Actualizar producto
- `DELETE /wp-json/wc/v3/products/{id}` - Eliminar producto

### Pedidos
- `GET /wp-json/wc/v3/orders` - Listar pedidos
- `GET /wp-json/wc/v3/orders/{id}` - Obtener pedido específico
- `PUT /wp-json/wc/v3/orders/{id}` - Actualizar estado de pedido

### Clientes
- `GET /wp-json/wc/v3/customers` - Listar clientes
- `POST /wp-json/wc/v3/customers` - Crear cliente

## Consideraciones para Argentina

### Moneda y Formato
- **Moneda**: Peso Argentino (ARS)
- **Formato de fecha**: DD/MM/YYYY
- **Separador decimal**: coma (,)
- **Separador de miles**: punto (.)

### Facturación Electrónica
El sistema está preparado para integración con AFIP y facturación electrónica.

### Impuestos
- Manejo de IVA (21%)
- Configuración flexible de impuestos provinciales

## Desarrollo

### Estructura de Clases

#### WooCommerceAPI
Clase principal para comunicación con la API de WooCommerce:
- Autenticación con Consumer Key/Secret
- Manejo de peticiones HTTP
- Reintentos automáticos
- Logging de operaciones

#### SyncManager
Gestor de sincronización entre sistemas:
- Sincronización de productos
- Sincronización de pedidos
- Sincronización de clientes
- Manejo de errores y reintentos

#### LegacyConnector
Conector con el sistema legacy:
- Consultas a base de datos legacy
- Mapeo flexible de campos
- Validación de datos

#### ConfigManager
Gestor de configuración:
- Carga desde archivo config.ini
- Validación de configuración
- Acceso a valores de configuración

### Patrones de Diseño

- **Factory Pattern**: Para creación de objetos
- **Repository Pattern**: Para acceso a datos
- **Service Pattern**: Para lógica de negocio
- **Configuration Pattern**: Para gestión de configuración

### Manejo de Errores

- Sistema de logging detallado
- Reintentos automáticos con backoff exponencial
- Validación de datos
- Manejo de excepciones

## Testing

El proyecto incluye pruebas unitarias en la carpeta `tests/`:

```foxpro
* Ejecutar todas las pruebas
DO tests/ejecutar_pruebas.prg
```

## Logs

Los logs se almacenan en:
- **Archivos**: Carpeta `logs/`
- **Base de datos**: Tabla `sync_logs`

Niveles de log disponibles:
- `INFO`: Información general
- `WARNING`: Advertencias
- `ERROR`: Errores
- `DEBUG`: Información de depuración

## Mantenimiento

### Backup
- Backup automático de datos de sincronización
- Procedimientos de recuperación
- Validación de integridad de datos

### Monitoreo
- Dashboard de estado de sincronización
- Alertas de errores críticos
- Métricas de rendimiento

## Soporte

Para soporte técnico o consultas:
- Revisar la documentación en `documentations/`
- Verificar logs en `logs/`
- Consultar la tabla `sync_logs` en la base de datos

## Licencia

Este proyecto es de uso interno para la empresa.

---

**Versión**: 1.0  
**Fecha**: 2024  
**Autor**: Sistema de Desarrollo Automático 