*----------------------------------------------------------------------------*
FUNCTION encrypt(tcStr, tcPassword)
*----------------------------------------------------------------------------*
    loCipher = NEWOBJECT('cipher')

    RETURN loCipher.encrypt(tcStr, tcPassword)
ENDFUNC
*
*----------------------------------------------------------------------------*
FUNCTION decrypt(tcStr, tcPassword)
*----------------------------------------------------------------------------*
    RETURN encrypt(tcStr, tcPassword)
ENDFUNC
*
*
*|--------------------------------------------------------------------------
*| cipher.prg
*|--------------------------------------------------------------------------
*|
*| Archivo principal del sistema
*| Author......: RaÃºl Jrz (raul.jrz@gmail.com) 
*| Created.....: 24.01.18 - 19.38
*| Purpose.....: Libreria de compresion de datos basado en cipher.fll
*|	
*| Revisions...: v1.00 
*| Basado en...: -->  cipher50.fll <--
*|               https://www.berezniker.com/content/pages/visual-foxpro/vfp-implementation-cipher-encryption
*|               This is a VFP implementation of the Cipher encryption. Cipher50 C source code and the 
*|               binary is available as separate downloads File #21474 and File #9222 at http://www.UniversalThread.com.
*|
*|               Cipher was originally put into the public domain by Tom Rettig Associates in 1991 and has been 
*|               re-produced by different parties as necessary for newer versions of FoxPro. Obviously, the VFP 
*|               implementation is much slower than the C library and should be used for short strings, 
*|               like passwords, only. The code has been tested under VFP 8.0 and VFP 9.0 but should work in 
*|               previous versions. If it doesn't, feel free to modify it.
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS cipher AS Custom
*
*-----------------------------------------------------------------------------------*
	#DEFINE   PW_MIN_LEN   3		&&  /* min number of characters in the password */
	#DEFINE   PW_MIN_NUM   1000		&&  /* min value for the password seed */
	PROTECTED PassWord, LenMinPassword
	PassWord = .null.
	MinLenPW = PW_MIN_LEN           && /* minimum length of the password */

	*----------------------------------------------------------------------------*
	FUNCTION setPassWord (tcPassword)
	* Assign the password by default.
	*----------------------------------------------------------------------------*
		IF PCOUNT()<=0 OR EMPTY(tcPassword) THEN
			ERROR 10, 'Debe ingresar una password como llave'
		ENDIF
		
		tcPassWord=ALLTRIM(tcPassword)
		IF LEN(tcPassword) < THIS.MinLenPW  THEN
			ERROR 11, 'El password debe tener una longitud minima de: '+TRANSFORM(THIS.MinLenPW)+' caracteres'
		ENDIF
		
		IF VARTYPE(tcPassword)#'C' THEN
			ERROR 12, 'El password debe ser caracter'
		ENDIF
		THIS.PassWord = tcPassWord
	ENDFUNC
	
	*----------------------------------------------------------------------------*
	FUNCTION getPassWord ()
	* Retorna el valor del password activo
	*----------------------------------------------------------------------------*
		IF VARTYPE(THIS.password)#'C' THEN
			ERROR 13, 'No se definio un password de encriptación'
		ENDIF
		RETURN THIS.password
	ENDFUNC

	*----------------------------------------------------------------------------*
	FUNCTION setMinLengthPW (tnLen)
	* I assign the minimum length for the encryption password.
	*----------------------------------------------------------------------------*
		IF VARTYPE(tnLen)='N' AND tnLen>=PW_MIN_LEN THEN
			THIS.MinLenPW = tnLen
		ENDIF
	ENDFUNC	
	
	*----------------------------------------------------------------------------*
	FUNCTION encrypt (tcStr, tcPassword)
	* Alias to encrypt using the cipher method.
	*----------------------------------------------------------------------------*
		RETURN THIS.cipher(tcStr, IIF(PCOUNT()=2,tcPassword,.null.))
	ENDFUNC

	*----------------------------------------------------------------------------*
	FUNCTION decrypt (tcStr, tcPassword)
	* Alias to decrypt using the cipher method.
	*----------------------------------------------------------------------------*
		RETURN THIS.cipher(tcStr, IIF(PCOUNT()=2,tcPassword,.null.))
	ENDFUNC

	*----------------------------------------------------------------------------*
	FUNCTION cipher (tcStr, tcPassword)
	* Parameters:
	*   tcStr      - string to encrypt/decrypt
	*   tcPassword - password to use for encryption/decryption 
	*
	*----------------------------------------------------------------------------*
		LOCAL lnStrLen, lnPassLen, lnPassNum, laPassword[1,2], lcPassword
		LOCAL lcStrOut, lnPassPos, lnNum01, lcStrOut, lnInPos, lnPassPos
		
		IF PCOUNT()=2 AND VARTYPE(tcPassword)$'C' THEN
			THIS.setPassword(tcPassword)
		ENDIF
		lnStrLen = LEN(tcStr)
		 
		* Because of the bug in the original C code we've to add CHR(0) to the password and use it later
		lcPassword = THIS.getPassword() + CHR(0)
		lnPassLen  = LEN(lcPassword)
		DIMENSION laPassword[lnPassLen+1,2]
		FOR lnPassPos=1 TO lnPassLen
			laPassword[lnPassPos,2] = SUBSTR(lcPassword,lnPassPos,1)
			laPassword[lnPassPos,1] = ASC(laPassword[lnPassPos,2])
		ENDFOR
		 
		* Get seed value
		lnPassNum = INT((((THIS.CipherGetPnum(lcPassword)/997) - 1) % 254) + 1 )
		lcStrOut  = ""
		lnPassPos = 1
		 
		* Encode/decode each character
		FOR lnInPos=0 TO lnStrLen-1
			* Get new seed value
			lnNum01 = (( lnPassNum + (lnInPos - lnStrLen)) - 1)
			lnPassNum = (ABS(lnNum01) % 254) * SIGN(lnNum01) + 1
			* Encode current character
			lnByte = BITXOR( ASC(SUBSTR(tcStr,lnInPos+1,1)), ;
				BITXOR(lnPassNum, laPassword[lnPassPos,1]))
			* Convert signed value to unsigned, if necessary
			lnByte = BITAND(lnByte, 0xFF)
			* If result is zero, use current character
			lcStrOut = lcStrOut + IIF(lnByte = 0, SUBSTR(tcStr,lnInPos+1,1), CHR(lnByte))
			* Advance to the next password character
			lnPassPos = IIF( lnPassPos => lnPassLen, 1, lnPassPos + 1)
		ENDFOR
		 
		RETURN lcStrOut
	ENDFUNC

	*----------------------------------------------------------------------------*
	FUNCTION CipherGetPnum(tcStr)
	* Returns a seed value based on the string passed as parameter
	*----------------------------------------------------------------------------*
		LOCAL liRet, lnPos
		liRet = 1
		FOR lnPos=0 TO LEN(tcStr ) - 1
			liRet = liRet + ASC(SUBSTR(tcStr,lnPos+1,1)) + lnPos
		ENDFOR
		DO WHILE (liRet < PW_MIN_NUM)
			liRet = BITLSHIFT(liRet,1)
		ENDDO
		RETURN liRet
	ENDFUNC

ENDDEFINE