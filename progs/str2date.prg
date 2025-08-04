*!*	* Example:
*!*	lcFechadesde= '2023-09-01'

*!*	ldFechaDesde= Str2Date(lcFechaDesde)
*!*	WAIT WINDOWS ldFechaDesde

*----------------------------------------------------------------------------*
FUNCTION Str2Date(tcDate AS STRING, tcFomat AS STRING) DATE
* tcDate.......: La fecha en caracter.
* tcFormat.....: Formato de la fecha que se ingresa. Puede ser:
*                aaaa-mm-dd
*                aa-mm-dd
* 
* CONVIERTE STRING a FECHAS
* 
*----------------------------------------------------------------------------*
LOCAL lcAccepted_Formats as String, lcOldFormatDate as String, ;
		lcReturn as String
	TRY
		lcAccepted_Formats = [aaaa-mm-dd,aa-mm-dd]
		
		IF VARTYPE(tcFormats)!='C' OR EMPTY(tcFormats) THEN
			tcFormats = 'aaaa-mm-dd'
		ENDIF
		
		tcFormats = LOWER(tcFormats)
		IF !tcFormats$lcAccepted_Formats THEN
			THROW 'Error, formato incorrecto "'+tcFormats+'"'
		ENDIF
		
		DO CASE
			CASE tcFormats = 'aaaa-mm-dd'
				lcOldFormatDate = SET("Date")
				SET DATE TO YMD
				lcReturn = CTOD(tcDate)
				SET DATE TO &lcOldFormatDate
			OTHERWISE
				THROW 'Caracteristica no implementada'
		ENDCASE
	CATCH TO loEx
		WAIT WINDOWS loEx.UserValue + loEx.Message NOWAIT
		SET STEP ON
	ENDTRY
	
	RETURN lcReturn
ENDFUNC 