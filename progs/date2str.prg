*----------------------------------------------------------------------------*
*FUNCTION Date2Str(
LPARAMETERS tdDate AS DATE, tcSeparator AS STRING
*) STRING
* tdDate.......: La fecha formatear.
* tcSeparator..: El caracter que se usará para separar la fecha. 
*                Para omitir serador y formar salida del formato:
*                  aaaammdd -> se debe ingresar '!'
* 
* CONVIERTE FECHAS aaaa-mm-dd
* 
*----------------------------------------------------------------------------*
	LOCAL lcDay AS STRING, lcMonth AS STRING, lcYear AS STRING, ;
		  lnDay AS NUMBER, lnMonth AS NUMBER, lnYear AS NUMBER
	lnYear = YEAR(tdDate)
	lnMonth= MONTH(tdDate)
	lnDay  = DAY(tdDate)
	
	lcYear = IIF(lnYear <100,'20','')+TRANSFORM(lnYear)
	lcMonth= IIF(lnMonth<10 ,'0' ,'')+TRANSFORM(lnMonth)
	lcDay  = IIF(lnDay  <10 ,'0' ,'')+TRANSFORM(lnDay)
	
	IF VARTYPE(tcSeparator)='C' THEN
		lcSepa= IIF(tcSeparator='!', '', tcSeparator)
	ELSE
		lcSepa= '-'
	ENDIF
	
	RETURN lcYear+lcSepa+lcMonth+lcSepa+lcDay
ENDFUNC