*|--------------------------------------------------------------------------
*| DOCUMENTACIÓN DE LA CLASE LOGGER
*|--------------------------------------------------------------------------
*|
*| La clase Logger permite registrar eventos y mensajes del sistema en archivos
*| de log con diferentes niveles de severidad para facilitar el debugging y
*| monitoreo de aplicaciones.
*|
*| NIVELES DE LOG DISPONIBLES:
*| - CRITICAL (1): Errores críticos que requieren atención inmediata
*| - WARNING  (2): Advertencias sobre posibles problemas
*| - NOTICE   (3): Información importante pero no crítica
*| - INFO     (4): Información general del flujo de la aplicación
*|
*| EJEMPLO DE USO BÁSICO:
*|
*| LOCAL loLogger
*| loLogger = NEWOBJECT("Logger", "progs\logger.prg")
*|
*| * Configurar archivo de log personalizado
*| loLogger.SetLogFile("mi_aplicacion.log")
*|
*| * Registrar diferentes tipos de mensajes
*| loLogger.Critical("Error crítico en conexión a base de datos")
*| loLogger.Warning("Memoria RAM por encima del 80%")
*| loLogger.Notice("Usuario admin ha iniciado sesión")
*| loLogger.Info("Proceso de sincronización iniciado")
*|
*| EJEMPLO DE USO AVANZADO CON CONFIGURACIÓN:
*|
*| LOCAL loLogger
*| loLogger = NEWOBJECT("Logger", "progs\logger.prg")
*|
*| * Configurar nivel mínimo de log (solo CRITICAL y WARNING)
*| loLogger.SetLevel(2)
*|
*| * Personalizar formato de salida
*| loLogger.SetFormat("DATETIME - [levelname] - MESSAGE")
*|
*| * Activar/desactivar logging
*| loLogger.SetEnabled(.T.)
*|
*| * Usar en bloques TRY...CATCH
*| TRY
*|     * Código que puede fallar
*|     THIS.oDB.SQL_Exec(cSQL, "crs_Result")
*|     loLogger.Info("Consulta ejecutada correctamente")
*| CATCH TO loException
*|     loLogger.Critical("Error en consulta SQL: " + loException.Message)
*| ENDTRY
*|
*| INTEGRACIÓN CON OTRAS CLASES:
*|
*| * En servicios WooCommerce
*| LOCAL loOrderAPI, loLogger
*| loOrderAPI = NEWOBJECT('WooCommerceOrderAPI', 'app\services\woocommerce\woocommerce_order_api.prg')
*| loLogger = NEWOBJECT("Logger", "progs\logger.prg")
*|
*| loLogger.Info("Iniciando sincronización de pedidos")
*| loOrders = loOrderAPI.GetRecentOrders(7)
*| IF ISNULL(loOrders)
*|     loLogger.Warning("No se encontraron pedidos recientes")
*| ELSE
*|     loLogger.Info("Procesados " + ALLTRIM(STR(loOrders.Count)) + " pedidos")
*| ENDIF
*|
*| PROPIEDADES PRINCIPALES:
*| - namefile: Nombre del archivo de log (por defecto "logger.LOG")
*| - LEVEL: Nivel mínimo de mensajes a registrar (1-4)
*| - islogger: Activar/desactivar el logging (.T./.F.)
*| - FORMAT: Formato de salida de los mensajes
*|
*| MÉTODOS PRINCIPALES:
*| - Critical(tcMessage): Registra mensaje crítico
*| - Warning(tcMessage): Registra advertencia
*| - Notice(tcMessage): Registra notificación
*| - Info(tcMessage): Registra información general
*| - SetLogFile(tcFileName): Establece archivo de log personalizado
*| - SetLevel(tnLevel): Establece nivel mínimo de logging
*| - SetEnabled(tlEnabled): Activa/desactiva el logging
*|
*/

#INCLUDE include\default.h
*
*|--------------------------------------------------------------------------
*| logger
*|--------------------------------------------------------------------------
*|
*| clase encarga de realizar las grabaciones de actividades para los logs
*| Author.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz
*| Created.....: 2025.08.04 - 19.38
*| Purpose.....: Grabar en archivo las acciones del sistema.
*|
*| Revisions...: V1.0
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS logger AS CUSTOM
*
*-----------------------------------------------------------------------------------*
	HIDDEN ;
		CLASSLIBRARY,COMMENT, ;
		BASECLASS,CONTROLCOUNT, ;
		CONTROLS,OBJECTS,OBJECT,;
		HEIGHT,HELPCONTEXTID,LEFT,NAME, ;
		PARENT,PARENTCLASS,PICTURE, ;
		TAG,TOP,WHATSTHISHELPID,WIDTH

	PROTECTED current_level,current_message,FORMAT,LEVEL,namefile
	current_level = 0		&& Nivel del mensaje en ejecucion
	current_message = ''    && Mensaje actual en String que se va a grabar
	FORMAT = "DATETIME - levelname - MESSAGE"		&& formato de salida
	islogger = .T.		    && Indica si se graba o no en archivo log
	LEVEL = 4		        && Indica el nivel de info que esta grabando
	NAME = "logger"
	namefile = 'logger.LOG'	&& el nombre del archivo en donde grabar el log
	*
	*----------------------------------------------------------------------------*
	PROCEDURE INIT
	*
	*----------------------------------------------------------------------------*
		LOCAL laTypeLevel[4]

		laTypeLevel[1]='CRITICAL'
		laTypeLevel[2]='WARNING'
		laTypeLevel[3]='Notice'
		laTypeLevel[4]='Info'

		THIS.ADDPROPERTY('typelevel[4]')
		*DIMENSION THIS.typelevel[4]
		=ACOPY(laTypeLevel, THIS.typelevel)
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE setFormat	(tcFormat AS STRING)
	* Setea el formato
	*----------------------------------------------------------------------------*
		LOCAL lbReturn
		lbReturn = .F.

		TRY
			IF VARTYPE(tcFormat)!='C' OR EMPTY(tcFormat) THEN
				THROW 'Debe ingresar un formato válido en String-'
			ENDIF

			THIS.FORMAT = ALLTRIM(tcFormat)
			lbReturn = .T.

		CATCH TO loEx
			WAIT WINDOWS THIS.message_exception(loEx) NOWAIT
		ENDTRY

		RETURN lbReturn
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE getFormat
	* Devuelve el formato
	*----------------------------------------------------------------------------*
		RETURN THIS.FORMAT
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE setLevel (tnLevel AS INTEGER)	&& Setea el nivel que va a grabar.
	*!*	Niveles de mensajes a grabar. Si es Nivel 3, graba los 3, 2 y 1
	*!*	Niveles 1 y 2 son Excepciones y Errores, 3 y 4 ayudas en la depuración.

	*!*	4 Info.....: Mensajes que ayudan en la depuración.
	*!*	3 Notice...: Mensajes de advertencia por sucesos definidos por el programador.
	*!*	2 Warning..: Errores que pueden ser salvados y seguir ejecutando.
	*!*	1 Critical.: Errores graves, que abortan el normal procedimiento.
	*
	*----------------------------------------------------------------------------*
		LOCAL lbReturn
		lbReturn = .F.

		TRY
			IF VARTYPE(tnLevel)!='N' THEN
				THROW 'Debe ingresar un valor numerico entre 1.. 4'
			ENDIF

			IF !BETWEEN(tnLevel, 1, 4) THEN
				THROW 'El valor permitido para el nivel de registro es de 1 a 4'
			ENDIF

			THIS.LEVEL = tnLevel
			lbReturn = .T.

		CATCH TO loEx
			WAIT WINDOWS THIS.message_exception(loEx) NOWAIT
		ENDTRY

		RETURN lbReturn
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE getlevel		&& Devuelve el nivel de info que esta grabando
	*
	*----------------------------------------------------------------------------*
	*!*	Niveles de mensajes a grabar. Si es Nivel 3, graba los 3, 2 y 1
	*!*	Niveles 1 y 2 son Excepciones y Errores, 3 y 4 ayudas en la depuración.

	*!*	4 Info.....: Mensajes que ayudan en la depuración.
	*!*	3 Notice...: Mensajes de advertencia por sucesos definidos por el programador.
	*!*	2 Warning..: Errores que pueden ser salvados y seguir ejecutando.
	*!*	1 Critical.: Errores graves, que abortan el normal procedimiento.
		RETURN THIS.LEVEL
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROTECTED PROCEDURE get_current_level 
	* Devuelve el nivel actual del proceso
	*----------------------------------------------------------------------------*
		WITH THIS
			IF VARTYPE (.current_level)!='N' OR;
					!BETWEEN(.current_level, 1, 4) THEN
				.current_level=4
			ENDIF
		ENDWITH

		RETURN THIS.current_level
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE setNameFile (tcNameFile AS STRING) && Setea el nombre del archivo
	*
	*----------------------------------------------------------------------------*
		LOCAL lbReturn
		lbReturn = .F.

		TRY
			IF VARTYPE(tcNameFile)!='C' OR EMPTY(tcNameFile) THEN
				THROW 'Debe ingresar un nombre de archivo válido'
			ENDIF

			THIS.namefile= ALLTRIM(tcNameFile)
			lbReturn = .T.

		CATCH TO loEx
			*SET STEP ON 
			*WAIT WINDOWS THIS.message_exception(loEx)
			lbReturn = .F.
		ENDTRY

		RETURN lbReturn
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE getNameFile		&& Obtiene el nombre del archivo
	*
	*----------------------------------------------------------------------------*
		IF EMPTY(THIS.namefile) THEN
			THIS.namefile = 'logger.log'
		ENDIF

		RETURN IIF(THIS.current_level==1, 'error.log', THIS.namefile)
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE getFullNameFile		&& Obtiene el nombre del archivo y el path
	*
	*----------------------------------------------------------------------------*
		LOCAL lcDirectory, lcNameFile
		lcDirectory = 'Logs'

		THIS.check_folder(lcDirectory)
		lcNameFile = ALLTRIM(lcDirectory) +'\'+Date2Str(DATE(),'!')+ '_';
					+THIS.getnamefile()

		RETURN lcNameFile
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE critical
	* Graba los errores
	*----------------------------------------------------------------------------*
		LPARAMETERS teMessage
		THIS.current_level = 1

		RETURN THIS.WRITE(teMessage)
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE warning (tcMessage AS STRING)
	* graba llamadas de atencion
	*----------------------------------------------------------------------------*
		THIS.current_level = 2

		RETURN THIS.WRITE(tcMessage)
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE Notice (tcMessage AS STRING)
	* Graba noticias
	*----------------------------------------------------------------------------*
		THIS.current_level = 3

		RETURN THIS.WRITE(tcMessage)
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE Info (tcMessage AS STRING)
	* Graba informacion
	*----------------------------------------------------------------------------*
		THIS.current_level = 4

		RETURN THIS.WRITE(tcMessage)
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE Log (tcLevel AS STRING, tcMessage AS STRING)
	* Método genérico para logging que acepta nivel como parámetro
	*----------------------------------------------------------------------------*
		LOCAL lcLevel, lbReturn
		
		lcLevel = UPPER(ALLTRIM(tcLevel))
		lbReturn = .F.
		
		DO CASE
			CASE lcLevel = "CRITICAL" OR lcLevel = "ERROR"
				lbReturn = THIS.Critical(tcMessage)
			CASE lcLevel = "WARNING" OR lcLevel = "WARN"
				lbReturn = THIS.Warning(tcMessage)
			CASE lcLevel = "NOTICE" OR lcLevel = "INFO"
				lbReturn = THIS.Notice(tcMessage)
			CASE lcLevel = "DEBUG" OR lcLevel = "INFO"
				lbReturn = THIS.Info(tcMessage)
			OTHERWISE
				* Por defecto usar nivel INFO
				lbReturn = THIS.Info(tcMessage)
		ENDCASE
		
		RETURN lbReturn
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROTECTED PROCEDURE message_exception (toException)
	*   Genera un mensaje a partir del objecto Exception
	*----------------------------------------------------------------------------*
		LOCAL lcMessage

		IF !EMPTY(toException.USERVALUE) THEN
			lcMessage = toException.USERVALUE
		ELSE
			lcMessage = "Error grave: " +CHR(13)+CHR(10);
				+' Error:.....' + STR(toException.ERRORNO)+CHR(13)+CHR(10);
				+' Line No:...' + STR(toException.LINENO) +CHR(13)+CHR(10);
				+' Message:...' + toException.MESSAGE     +CHR(13)+CHR(10);
				+' Procedure:.' + toException.PROCEDURE
		ENDIF
		RETURN lcMessage
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE Write	(teMessage AS STRING)	&& Graba en un archivo
	*!*	Niveles de mensajes a grabar. Si es Nivel 3, graba los 3, 2 y 1
	*!*	Niveles 1 y 2 son Excepciones y Errores, 3 y 4 ayudas en la depuración.

	*!*	4 Info.....: Mensajes que ayudan en la depuración.
	*!*	3 Notice...: Mensajes de advertencia por sucesos definidos por el programador.
	*!*	2 Warning..: Errores que pueden ser salvados y seguir ejecutando.
	*!*	1 Critical.: Errores graves, que abortan el normal procedimiento.
	*
	*----------------------------------------------------------------------------*
		LOCAL lbReturn, lcMessage AS STRING, lcMsg AS STRING,;
			  loEx AS OBJECT,  loExn AS OBJECT
		#DEFINE crlf CHR(13)+CHR(10)

		lbReturn = .F.
		lnLevel_Warning = 2 &&Esto, si o si se graba.

		TRY
			IF (THIS.islogger AND THIS.get_current_level() <= THIS.LEVEL);
					OR  THIS.get_current_level()<=lnLevel_Warning THEN

				IF VARTYPE(teMessage)='O' THEN
					loExn = teMessage
					lcMsg = ' CATCH exception '
				ELSE
					loExn = .NULL.
					lcMsg = ALLTRIM(teMessage)
				ENDIF

				lcMessage= THIS.put_message(lcMsg, loExn)

				lbReturn = THIS.save_log(lcMessage)

			ENDIF
		CATCH TO loEx
			WAIT WINDOWS THIS.message_exception(loEx)
		ENDTRY

		RETURN lbReturn

	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE put_message (tcMessage, toException)
	* Arma el mensaje a guardar
	*----------------------------------------------------------------------------*
		#DEFINE crlf CHR(13)+CHR(10)

		lcTypeLevel= ALLTRIM(THIS.typelevel[THIS.get_current_level()])
		lcStr = "#=["+lcTypeLevel+']'+ REPLICATE('=',75-LEN(lcTypeLevel)-3) +"#"

		IF THIS.current_level=1 THEN &&Error CRITICO
			lcStr = lcStr + crlf + tcMessage

		ELSE
			DIMENSION laStackInfo[1]
			=ASTACKINFO(laStackInfo)

			lcMetodo= laStackInfo[ALEN(laStackInfo,1)-3 ,3]
			lcStr   = lcStr + crlf ;
				+ "Hora......: " + TTOC(DATETIME())   + crlf ;
				+ "Usuario...: " + SYS(0)             + crlf ;
				+ "Metodo....: " + lcMetodo           + crlf ;
				+ "Mensaje...: " + ALLTRIM(tcMessage)
		ENDIF

		IF VARTYPE(toException)='O' THEN
			lcStr =lcStr+ "Metodo....: " + toException.PROCEDURE  + crlf ;
				+ "NumError..: " + TRANSFORM(toException.ERRORNO) + crlf ;
				+ "Linea.....: " + TRANSFORM(toException.LINENO)  + crlf ;
				+ "Contenido.: " + toException.LINECONTENTS       + crlf ;
				+ "Mensaje...: " + toException.MESSAGE            + crlf ;
				+ "........................"                      + crlf ;
				+ "User Info.: " + toException.USERVALUE          + crlf
		ENDIF

		RETURN lcStr + crlf
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE save_log (tcMessages AS STRING)
	* Guarda en un archivo el log
	*----------------------------------------------------------------------------*
		LOCAL lcDirectory AS STRING, lcNameFile AS STRING
		#DEFINE crlf CHR(13)+CHR(10)

		lcNameFile = THIS.getFullNameFile()

		*- 2024.02.05 
		THIS.delete_logger(lcNameFile)
*!*			TRY
*!*				AllGarbageFileCollector() &&Esta funcion esta en el main
*!*			CATCH TO loNotAction
*!*			ENDTRY

		RETURN (;
			STRTOFILE(tcMessages + crlf, lcNameFile, 1) > 0;
			)
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE check_folder(tcFolder AS STRING)
	* Verifica si la carpeta log existe, de lo contrario la crea
	*----------------------------------------------------------------------------*
		IF !DIRECTORY(tcFolder) THEN
			MKDIR(tcFolder)
		ENDIF
		RETURN DIRECTORY(tcFolder)
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE delete_logger(tcNameFile AS STRING)
	* Borra si supera el tamaño o el tiempo
	*----------------------------------------------------------------------------*
		LOCAL ldDate AS DATE

		IF FILE(tcNameFile) AND ADIR(laDir, tcNameFile)>0 THEN
			ldDate = laDir[1,3]

			IF ldDate < DATE() THEN
				DELETE FILE tcNameFile
			ENDIF
		ENDIF
	ENDPROC
	*
ENDDEFINE
