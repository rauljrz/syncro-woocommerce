#INCLUDE include\default.h
*
*|--------------------------------------------------------------------------
*| DB
*|--------------------------------------------------------------------------
*|
*| Clase encargada de la conexion con la base de datos
*| Autor.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.08.04 - 19.38
*| Purpose.....: Gestiona toda la conexion, SELECT, INSERT, ETC con la base de datos.
*|
*| Revisions...: V1.0
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS db AS baseClass
*
*-----------------------------------------------------------------------------------*
	PROTECTED brelanzarthrow,errormsg,errornro,odata
	NAME = "db"

	brelanzarthrow = .T.	&& Si relanza la excepcion a niveles superiores
	errormsg = .NULL.
	errornro = .NULL.
	handler_sql = 0		    && Handle que apunta a la base de datos de la contabilidad
	odata = .NULL.
	nameFile_Log = 'SQL_Stmt.log'
	#DEFINE crlf CHR(13)+CHR(10)
	
	currentDataBase = ''
	PROTECTED typeConnect, DefaultTypeConnect 
	typeConnect = .NULL.            && Identifica si estas en COMERCIAL o CONTABLE
	DefaultTypeConnect = 'CONTABLE' && Tipo de conexion por defecto.

	*----------------------------------------------------------------------------*
	PROCEDURE Init(tcTypeConnection AS STRING)
	*
	*----------------------------------------------------------------------------*
		DODEFAULT()
		islogger = .T.		    && Indica si se lleva o no un registro de acciones
		nameFile_Log = 'SQL_Stmt.log'
		
		THIS.typeConnect = IIF(VARTYPE(tcTypeConnection)='C';
								AND !EMPTY(tcTypeConnection);
								AND UPPER(ALLTRIM(tcTypeConnection))$'CONTABLE,COMERCIAL',;
									tcTypeConnection, ;
									THIS.DefaultTypeConnect;
							)
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE Unload()
	* Se ejecuta al cerrar el objecto
	*----------------------------------------------------------------------------*
		DODEFAULT()
		IF THIS.handler_sql > 0 THEN
			SQLDISCONNECT(THIS.handler_sql)
		ENDIF
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROTECTED PROCEDURE handler_sql_access
	*
	*----------------------------------------------------------------------------*
		IF THIS.handler_sql <= 0 THEN
			THIS.SQL_Connect()
		ENDIF
		RETURN THIS.handler_sql
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE start_transaction
	* Inicializa una transaccion
	*----------------------------------------------------------------------------*
		RETURN THIS.SQL_Exec('START TRANSACTION;')
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE commit
	*
	*----------------------------------------------------------------------------*
		RETURN THIS.SQL_Exec('COMMIT;')
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE Rollback
	*
	*----------------------------------------------------------------------------*
		RETURN THIS.SQL_Exec('ROLLBACK;')
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE SetData(teData)
	* Seteo los datos para ser pasados a la consulta SQL
	*----------------------------------------------------------------------------*
		IF VARTYPE(teData) = 'O' THEN
			THIS.odata = teData
		ELSE
			THIS.odata = .NULL.
		ENDIF

		RETURN .T.
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROTECTED PROCEDURE SQL_Connect()
	* Se conecta a la base de datos
	*----------------------------------------------------------------------------*
		LOCAL lbReturn, lcStringConnect, loStringConnect

		lbReturn = .F.
		TRY
			IF VARTYPE(SYS_CONN)='N' AND SYS_CONN>0 THEN
				THIS.handler_sql=SYS_CONN
			ELSE
				loStringConnect= NEWOBJECT('stringConnect', 'progs\stringconnect.prg')
				lcStringConnect= loStringConnect.getString(THIS.typeConnect)
				loStringConnect= .null.
						
				THIS.writelog_Secret(lcStringConnect)
				
				IF VARTYPE(lcStringConnect)!='C' OR LEN(lcStringConnect)<10 THEN
					THROW 'Falta datos para la conexion a la DB.'
				ENDIF
				
				THIS.Handler_SQL = SQLSTRINGCONNECT(lcStringConnect)
				lbReturn = THIS.Validate_Result(THIS.Handler_SQL)
				
				THIS.writelog_Secret('Database.: '+THIS.getCurrentRealDataBase())
			ENDIF
		CATCH TO loEx
			THIS.catchexception(loEx)
		ENDTRY

		RETURN lbReturn
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE SQL_Exec (tcStmt AS STRING, tcCursor AS STRING, tnHandler)
	* ejecuta la sentencia sql en la base de datos de la contablidad
	*----------------------------------------------------------------------------*
		LOCAL lcCursor, lnHandler, lnResult, odata, lbReturn
		lbReturn = .F.

		TRY
			odata = THIS.odata

			lcCursor = IIF(ISNULL(tcCursor) OR EMPTY(tcCursor),'',tcCursor)

			lnHandler= IIF(VARTYPE(tnHandler)='N' AND tnHandler>0,;
						tnHandler,;
						THIS.handler_sql)

			THIS.WriteLog(tcStmt)

			lnResult = IIF(EMPTY(tcCursor) OR LEN(tcCursor)<1,;
							SQLEXEC(lnHandler, tcStmt),;
							SQLEXEC(lnHandler, tcStmt, lcCursor);
						)
			lbReturn = THIS.Validate_Result(lnResult, tcStmt)

		CATCH TO loEx
			THIS.catchexception(loEx)
		ENDTRY

		RETURN lbReturn &&Retorna .T. o .F.
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROTECTED PROCEDURE Validate_Result	(tnValue AS INTEGER, tcStmt AS STRING)
	* Setea las propiedades generada por aerror()
	*----------------------------------------------------------------------------*
		LOCAL laError[1],  lcFieldName AS STRING, lcFinding AS STRING, ;
			  lcLineAll AS STRING,  lcMsg3 AS STRING, lcMsgs_users AS STRING,;
			  lcText2Save AS STRING

		IF tnValue > 0 THEN
			RETURN .T.
		ENDIF

		=AERROR(laError)
		lcMsg3 = laError[3]

		DO CASE
			CASE laError[5]=1062 AND laError[4]='23000' &&Duplicate Key
				*--- Es el texto a grabar --*
				lcFinding="Duplicate entry '"
				lcText2Save=SUBSTR(lcMsg3, AT(lcFinding, lcMsg3) + LEN(lcFinding))
				lcText2Save=SUBSTR(lcText2Save, 1, AT("'",lcText2Save)-1)

				*--- Es el nombre del campo --*
				lcFinding="for key '"
				lcFieldName=STRTRAN(;
					SUBSTR(lcMsg3, AT(lcFinding, lcMsg3) + LEN(lcFinding));
					,"'",'')

				lcMsgs_users = 'Ya existe el valor ['+lcText2Save+'], grabado en ';
					+' en el campo ['+lcFieldName+'].'
			OTHERWISE
				lcMsgs_users = lcMsg3
		ENDCASE

		lcNameDB = THIS.getCurrentDataBase()
		TEXT TO lcLineAll TEXTMERGE NOSHOW
		 Number...: <<TRANSFORM(laError[1])>>
		 Text Msg.: <<laError[2]>>
		 User Msg.: <<lcMsgs_users>>
		 Database.: <<lcNameDB>>
		 Statement:
		 	<<tcStmt>>

		ENDTEXT

		*--- gestion la excepcion y la grabo en el registro
		TRY
			THROW CHR(13)+CHR(10)+lcLineAll

		CATCH TO loEx
			THIS.catchexception(loEx)
		ENDTRY

		RETURN
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE sql_insert (tcStmt AS STRING)
	* Inserta un registro y devuelve el ultimo id
	*----------------------------------------------------------------------------*
		THIS.SQL_Exec(tcStmt)

		RETURN THIS.get_last_insert_id()
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE get_last_insert_id()
	* Devuelve el ultimo ID ingresado
	*----------------------------------------------------------------------------*
		lnLast_ID= -1
		lcStmt = 'SELECT last_insert_id() AS id;'

		TRY
			IF !THIS.SQL_Exec(lcStmt, 'crs_last_id') THEN
				THROW 'Error al obtener el ID de la inserción'
			ENDIF

			IF !USED('crs_last_id') THEN
				THROW 'No se encontró el cursor de retorno con el ultimo ID insertado'
			ENDIF

			IF RECNO('crs_last_id')<1 THEN
				THROW 'El cursor con el ID insertado no tiene registro'
			ENDIF

			SELECT * FROM crs_last_id INTO ARRAY laID

			lnLast_ID = laID[1]

			IF VARTYPE(lnLast_ID)='C' THEN
				lnLast_ID = ALLTRIM(lnLast_ID)

				IF !ISDIGIT(lnLast_ID) THEN
					THROW 'Se esperaba un Nro como ID'
				ENDIF
				lnLast_ID = VAL(lnLast_ID)
				IF lnLast_ID<=0 THEN
					THROW 'Error, No se genero el nuevo ID'
				ENDIF
			ENDIF

			IF VARTYPE(lnLast_ID)!='N' THEN
				THROW 'El valor devuelto como ID no es un numero'
			ENDIF
		CATCH TO loEx
			THIS.catchexception(loEx)
		FINALLY
			USE IN SELECT('crs_last_id')
		ENDTRY

		RETURN lnLast_ID
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	PROCEDURE is_exist_table(tcTableName AS STRING)
	* 2024.01.05
	* Verifica si existe una tabla determinada.
	*----------------------------------------------------------------------------*
		LOCAL lcStmt, lbReturn
		lbReturn = .F.
		TRY
			TEXT TO lcStmt TEXTMERGE NOSHOW PRETEXT 15
				SHOW TABLES LIKE '<<tcTableName>>';
			ENDTEXT
					
			THIS.SQL_Exec(lcStmt, 'crs_existeTabla')
			
			lbReturn = (RECCOUNT('crs_existeTabla')>0)
		CATCH TO loEx
			THIS.catchexception(loEx)
		FINALLY
			USE IN SELECT('crs_existeTabla')
		ENDTRY
		
		RETURN lbReturn
	ENDPROC
	*
	*----------------------------------------------------------------------------*
	* Description: Devuelve la base de datos activa consultando la DB
	*/
    FUNCTION getCurrentRealDataBase()
	*----------------------------------------------------------------------------*
		LOCAL laCurrentDB[1]
		TRY	
			THIS.SQL_Exec('SELECT DATABASE() AS current_database;', 'crs_currentDB')
			
			SELECT current_database FROM crs_currentDB INTO ARRAY laCurrentDB
			
			THIS.currentDataBase = ALLTRIM(laCurrentDB[1])
		CATCH TO loEx
			THIS.catchexception(loEx)
		FINALLY 
			USE IN SELECT('crs_currentDB')
		ENDTRY
		RETURN THIS.currentDataBase
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	* Description: Devuelve la base de datos activa almacenada en el inicio
	*/
    FUNCTION getCurrentDataBase()
	*----------------------------------------------------------------------------*
		RETURN THIS.currentDataBase
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	* Description: Verifica si existe un trigger en la base de datos activa
	*/
    FUNCTION ExisteTrigger(tcTrigger, tcTable)
	*----------------------------------------------------------------------------*
		LOCAL lcStmt, lbReturn, lcCurrentDataBase 
		lbReturn = .F.
		TRY				
			TEXT TO lcStmt TEXTMERGE NOSHOW PRETEXT 15
				SELECT trigger_name FROM information_schema.triggers 
					WHERE trigger_name = '<<tcTrigger>>' 
						AND event_object_table = '<<tcTable>>'
						AND trigger_schema = '<<THIS.currentDataBase>>'
					LIMIT 1;
			ENDTEXT
			
			THIS.SQL_Exec(lcStmt, 'crs_ExisteTrigger')
			
			lbReturn = (RECCOUNT('crs_ExisteTrigger')>0)
		CATCH TO loEx
			THIS.catchexception(loEx)
		FINALLY 
			USE IN SELECT('crs_ExisteTrigger')
		ENDTRY
		RETURN lbReturn
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	* Description: Verifica que exista el campo de una tabla dada en el esquema actual
	*/
    FUNCTION ExisteCampo(tcTabla, tcCampoNombre)
	*----------------------------------------------------------------------------*
		LOCAL lcStmt, lbReturn
		lbReturn = .F.
		TRY
			TEXT TO lcStmt TEXTMERGE NOSHOW PRETEXT 15
				SELECT table_schema, TABLE_NAME, column_name
					FROM `information_schema`.`COLUMNS` 
						WHERE TABLE_NAME='<<tcTabla>>' 
							AND COLUMN_NAME='<<tcCampoNombre>>'
							AND table_schema='<<THIS.currentDataBase>>'
						LIMIT 1;
			ENDTEXT
			
			THIS.SQL_Exec(lcStmt, 'crs_ExisteCampo')
			
			lbReturn = (RECCOUNT('crs_ExisteCampo')>0)
		CATCH TO loEx
			THIS.catchexception(loEx)
		FINALLY 
			USE IN SELECT('crs_ExisteCampo')
		ENDTRY
		RETURN lbReturn
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	* Description: Verifica si existe un en la base de datos activa
	*/
    FUNCTION ExisteProcedimiento(tcStoreP)
	*----------------------------------------------------------------------------*
		LOCAL lcStmt, lbReturn, lcCurrentDataBase 
		lbReturn = .F.
		TRY				
			TEXT TO lcStmt TEXTMERGE NOSHOW PRETEXT 15
			SELECT specific_name FROM information_schema.routines
			WHERE routine_name = '<<tcStoreP>>'
			    AND routine_type = 'PROCEDURE'
			    AND routine_schema = '<<THIS.currentDataBase>>'
				 LIMIT 1;
			ENDTEXT
			
			THIS.SQL_Exec(lcStmt, 'crs_ExisteSP')
			
			lbReturn = (RECCOUNT('crs_ExisteSP')>0)
		CATCH TO loEx
			THIS.catchexception(loEx)
		FINALLY 
			USE IN SELECT('crs_ExisteSP')
		ENDTRY
		RETURN lbReturn
	ENDFUNC
	*
	*----------------------------------------------------------------------------*
	* Description: Verifica si existe un en la base de datos activa
	*/
    FUNCTION ExisteFuncion(tcStoreP)
	*----------------------------------------------------------------------------*
		LOCAL lcStmt, lbReturn, lcCurrentDataBase 
		lbReturn = .F.
		TRY				
			TEXT TO lcStmt TEXTMERGE NOSHOW PRETEXT 15
			SELECT specific_name FROM information_schema.routines
			WHERE routine_name = '<<tcStoreP>>'
			    AND routine_type = 'FUNCTION'
			    AND routine_schema = '<<THIS.currentDataBase>>'
				 LIMIT 1;
			ENDTEXT
			
			THIS.SQL_Exec(lcStmt, 'crs_ExisteSP')
			
			lbReturn = (RECCOUNT('crs_ExisteSP')>0)
		CATCH TO loEx
			THIS.catchexception(loEx)
		FINALLY 
			USE IN SELECT('crs_ExisteSP')
		ENDTRY
		RETURN lbReturn
	ENDFUNC
ENDDEFINE
