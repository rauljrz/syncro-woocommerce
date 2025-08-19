*-----------------------------------------------------------------------------------*
* Common include file for syncro-woocommerce
* note: you must issue compile classlib * command if changing this file
*-----------------------------------------------------------------------------------*

#define xCodeJson 'json'
#define xEncripts 'cipher'

*-- Parametros para el archivo de configuracion de syncro-woocommerce --*
#define FILE_CONFIGW   'config.fpw'        &&archivo de configuracion de vfp
#define CONFIG_INI     'config.ini'        &&archivo de configuracion de la APP 

*-- Clave para la encriptacion del archivo --*
#define PASS_ENCRIPT   '97d897eb3ab77bab57fd1e5e0edcf1084052937b97a0ca7bdac3350b35e2dac6'

*-- Configuracion para el http y su log --*
#define IS_LOGGER .T.                      &&Si se crea o no un archivo de registro
#define NAME_LOG  'syncro-woocommerce.log' &&Nombre del archivo en LOG

#DEFINE CRLF			CHR(13)+CHR(10)
