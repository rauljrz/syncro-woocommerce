*|--------------------------------------------------------------------------
*| catchException.prg
*|--------------------------------------------------------------------------
*|
*| Clase para manejo de excepciones
*| Autor.......: Raul Juarez (raul.jrz[at]gmail.com)
*| Repository..: https://github.com/rauljrz/syncro-woocommerce
*| Created.....: 2025.08.04 - 19.38
*| Purpose.....: Clase para manejo de excepciones
*|	
*| Revisions...: v1.00
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS catchException AS Exception
*
*-----------------------------------------------------------------------------------*
	oLog = .null.
	
	*----------------------------------------------------------------------------*
	FUNCTION init (tbRelanzarThrow, toLog)
	* tbRelanzarThrow: Si es True, envia la excepcion al nivel superior
	*----------------------------------------------------------------------------*
		LOCAL lcStr, lcPrograms
		IF VARTYPE(loEx.StackInfo)='U' THEN
			IF VARTYPE(toLog)='O' THEN
				THIS.oLog = toLog
			ENDIF
			ADDPROPERTY(loEx,'TimeStamp',TTOC(DATETIME()))
			ADDPROPERTY(loEx,'UserName',SYS(0))
			ADDPROPERTY(loEx,'StackInfo[1]')
			ASTACKINFO(loEx.StackInfo)

			lcPrograms=''
			FOR lnInd=1 TO ALEN(loEx.StackInfo,1)-2
				lcPrograms = lcPrograms;
							 +TRANSFORM(lnInd)+' - ';
							 +TRANSFORM(loEx.StackInfo[lnInd,4])                                                   +CHR(13)+CHR(10) ;
							 +SPACE(17)+"Metodo..: "+TRANSFORM(loEx.StackInfo[lnInd,3])                            +CHR(13)+CHR(10) ;
							 +SPACE(17)+"Llamada.: "+ALLTRIM(STRTRAN(TRANSFORM(loEx.StackInfo[lnInd,6]),CHR(9),''))+CHR(13)+CHR(10) ;
							 +SPACE(17)+"Line Nro: "+TRANSFORM(loEx.StackInfo[lnInd,5])                            +CHR(13)+CHR(10) ;
							 +SPACE(12)
			ENDFOR
			ADDPROPERTY(loEx,'StackText',"Stack info: " + lcPrograms)

			lcStr = ''
			lcStr = lcStr + "Hora......: " + TTOC(DATETIME())        + CHR(13)+CHR(10) ;
						  + "Usuario...: " + SYS(0)                  + CHR(13)+CHR(10) ;
						  + "Stack info: " + lcPrograms              + CHR(13)+CHR(10) ;
						  + "Metodo....: " + loEx.Procedure          + CHR(13)+CHR(10) ;
						  + "NumError..: " + TRANSFORM(loEx.ErrorNo) + CHR(13)+CHR(10) ;
						  + "Linea.....: " + TRANSFORM(loEx.LineNo)  + CHR(13)+CHR(10) ;
						  + "Contenido.: " + loEx.LineContents       + CHR(13)+CHR(10) ;
						  + "Mensaje...: " + loEx.Message            + CHR(13)+CHR(10) ;
						  + "........................"               + CHR(13)+CHR(10) ;
						  + "User Info.: " + loEx.UserValue          + CHR(13)+CHR(10) 
			THIS.UserValue = lcStr
			THIS.SaveLogError(THIS.UserValue)
		ENDIF

		IF _VFP.StartMode = 0 THEN
			SET STEP ON 
		ENDIF

		IF tbRelanzarThrow THEN
			THROW               &&Relanza la Excepcion para el nivel superior
		ENDIF
	ENDFUNC
	
	*----------------------------------------------------------------------------*
	FUNCTION SaveLogError(tcString)
	*----------------------------------------------------------------------------*
		LOCAL lbReturn
		IF ISNULL(THIS.oLog) THEN
			tcString = CHR(13)+CHR(10) +"#"+ REPLICATE('=',75)+"#"+CHR(13)+CHR(10) +;
					   tcString
			lbReturn = STRTOFILE(tcString,'error.log',.T.)
		ELSE
			lbReturn = THIS.oLog.Critical(tcString)
		ENDIF
		RETURN lbReturn
	ENDFUNC
	
ENDDEFINE

