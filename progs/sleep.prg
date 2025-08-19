FUNCTION SLEEP(tnSegundos)
    * Espera activa por tnSegundos
    LOCAL lnInicio, lnActual, lnEspera
    lnEspera = tnSegundos
    lnInicio = SECONDS()
    lnActual = SECONDS()
    SET STEP ON 
    DO WHILE (lnActual - lnInicio) < lnEspera
        * No hacer nada, solo esperar
        lnActual = SECONDS()
    ENDDO

ENDFUNC