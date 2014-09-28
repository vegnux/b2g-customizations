#!/bin/bash
# Generar un script para vegnuxmod (roms para firefox os) que permita la automatización
# en las compilaciones de los diferentes "branches" o ramas utilizando las mismas fuentes git
# evitando la redundancia de código, en esta primera versión se manejarán las siguientes versiones.
# v1.4, v2.1 y master
#
# Se describirá a continuación paso por paso los procedimientos que se deben seguir para preparar
# el código fuente segun la rama git.
#
#############
# VARIABLES #
#############
export BUILD_BRANCH=v2.1
export ROOTDIR=$(pwd)
export WORKDIR=$ROOTDIR/B2G
#############
# FUNCIONES #
#############
function CleanAll(){
echo "** Limpiando todo el directorio de trabajo, puede tomarse unos segundos..."
cd $WORKDIR
rm -r abi \
bionic \
bootable \
build \
compare-locales \
dalvik \
dev* \
external \
frameworks \
gaia* \
gecko* \
gonk-misc \
hardware \
kernel \
lib* \
ndk \
o* \
prebuilt \
rilproxy \
system \
ve*
}
function CleanB2G(){
echo "** Limpiando solo lo relacionado con gecko y gaia, puede tomarse unos segundos..."
cd $WORKDIR
rm -r compare-locales \
gaia* \
gecko* \
gonk-misc \
o* \
vegnuxmod
}
function CreateFiles(){
cd $WORKDIR
echo "** Creando el fichero de configuraciones principal \".config\""
cat << EOF > .config
MAKE_FLAGS=-j4
GECKO_OBJDIR=$WORKDIR/objdir-gecko
DEVICE_NAME=$DEVICE
DEVICE=$DEVICE
EOF
echo "** Creando el fichero de configuraciones personales \".userconfig\""
cat << EOF > .userconfig
########################
VARIANT=user
########################
## Development
########################
#export B2G_DEBUG=1 # Debug Build
#export B2G_NOOPT=1 # Disable Optimizer
#export NOFTU=1 # Disable First Time User Experience
#export DEVICE_DEBUG=1 # Enable gaia developer mode
########################
## Bootlogo
########################
export ENABLE_DEFAULT_BOOTANIMATION=true
########################
## Make Official Branding Build
########################
export MOZILLA_OFFICIAL=1
export PRODUCTION=1
export GAIA_APP_TARGET=production
export GAIA_INSTALL_PARENT=/system/b2g
export PRESERVE_B2G_WEBAPPS=0
export B2G_SYSTEM_APPS=1
########################
## Gaia
########################
export LOCALE_BASEDIR=$WORKDIR/gaia-l10n
export LOCALES_FILE=$WORKDIR/gaia-l10n/languages_dev.json
#export GAIA_DEFAULT_LOCALE=es
export REMOTE_DEBUGGER=1
export GAIA_KEYBOARD_LAYOUTS=de,el,en,es,fr,hu,it,pl,pt-BR,ru,sr-Cyrl,sr-Latn
export GAIA_DISTRIBUTION_DIR=$WORKDIR/vegnuxmod
########################
## Gecko
########################
export L10NBASEDIR='$WORKDIR/gecko-l10n'
export MOZ_CHROME_MULTILOCALE="es-ES"
export PATH="$PATH:$WORKDIR/compare-locales/scripts"
export PYTHONPATH="$WORKDIR/compare-locales/lib"
########################
## Fota ./build.sh gecko-update-fota
########################
B2G_FOTA_DIRS="system/b2g system/xbin"
########################
EOF
echo "** Creando en fichero de repositorios extra en \".repo/local_manifests/extra.xml\""
mkdir -p .repo/local_manifests/
cat << EOF > .repo/local_manifests/extra.xml
<?xml version='1.0' encoding='UTF-8'?>
<manifest>
<remote name="cm" fetch="https://github.com/CyanogenMod/" />
<remote name="mozillaorg2" fetch="https://git.mozilla.org/" />
<remote name="vegnux" fetch="https://github.com/cargabsj175/" />
<!--adding busybox -->
<project path="external/busybox" name="android_external_busybox" remote="cm" revision="cm-9.1.0" />
<!-- Gaia languages -->
<project path="gaia-l10n/de" name="l10n/de/gaia.git" remote="mozillaorg" revision="master" />
<project path="gaia-l10n/el" name="l10n/el/gaia.git" remote="mozillaorg" revision="master" />
<project path="gaia-l10n/eo" name="l10n/eo/gaia.git" remote="mozillaorg" revision="master" />
<project path="gaia-l10n/es" name="l10n/es/gaia.git" remote="mozillaorg" revision="master" />
<project path="gaia-l10n/fr" name="l10n/fr/gaia.git" remote="mozillaorg" revision="master" />
<project path="gaia-l10n/hu" name="l10n/hu/gaia.git" remote="mozillaorg" revision="master" />
<project path="gaia-l10n/it" name="l10n/it/gaia.git" remote="mozillaorg" revision="master" />
<project path="gaia-l10n/pl" name="l10n/pl/gaia.git" remote="mozillaorg" revision="master" />
<project path="gaia-l10n/pt-BR" name="l10n/pt-BR/gaia.git" remote="mozillaorg" revision="master" />
<project path="gaia-l10n/ru" name="l10n/ru/gaia.git" remote="mozillaorg" revision="master" />
<project path="gaia-l10n/sr-Cyrl" name="l10n/sr-Cyrl/gaia.git" remote="mozillaorg" revision="master" />
<project path="gaia-l10n/sr-Latn" name="l10n/sr-Latn/gaia.git" remote="mozillaorg" revision="master" />
<!-- Gecko languages -->
<project path="compare-locales" name="l10n/compare-locales.git" remote="mozillaorg2" revision="master" />
<project path="gecko-l10n/es-ES" name="l10n/es-ES/gecko.git" remote="mozillaorg" revision="mozilla-beta" />
<!-- extra gaia apps -->
<project path="vegnuxmod" name="vegnuxmod" remote="vegnux" revision="$BUILD_BRANCH">
<copyfile src="vegnuxmod.sh" dest="../vegnuxmod-v2.1.sh" />
</project>
</manifest>
EOF
echo "** Creando en fichero de idiomas \"languages_dev.json\""
mkdir -p gaia-l10n
cat << EOF > gaia-l10n/languages_dev.json
{
"de" : "Deutsch",
"en-US" : "English (US)",
"el" : "Ελληνικά",
"eo" : "Esperanto",
"es" : "Español",
"fr" : "Français",
"hu" : "Magyar",
"it" : "Italiano",
"pl" : "Polski",
"pt-BR" : "Português (do Brasil)",
"ru" : "Русский",
"sr-Cyrl" : "Српски",
"sr-Latn" : "Srpski"
}
EOF
}
function SetBranch(){
echo "1. ¿Con qué dispositivo desea trabajar? (ej.: hamachi, inari, otoro):"
read DEVICE
echo "** Estableciendo la rama $BUILD_BRANCH para el dispositivo $DEVICE..."
cd $WORKDIR
./repo init -u https://github.com/cargabsj175/b2g-manifest.git -b $BUILD_BRANCH -m $DEVICE.xml
}
 
function NewRepo(){
echo "** Creando el directorio de trabajo por primera vez..."
git clone https://github.com/mozilla-b2g/B2G
if [[ -d $WORKDIR ]];then
SetBranch
else
echo ""
echo "** ERROR: No se pudo descargar el directorio de trabajo..."
echo ""
fi
}
 
function UpdateAll(){
cd $WORKDIR
./repo sync -j4
}
 
function UpdateB2G(){
cd $WORKDIR
CleanB2G 2>/dev/null
echo "** Actualizando gecko y gaia..."
./repo sync gaia
./repo sync gecko
./repo sync vegnuxmod
./repo sync gonk-misc
echo "** Actualizando los lenguajes de gaia..."
./repo sync gaia-l10n/de
./repo sync gaia-l10n/el
./repo sync gaia-l10n/eo
./repo sync gaia-l10n/es
./repo sync gaia-l10n/fr
./repo sync gaia-l10n/hu
./repo sync gaia-l10n/it
./repo sync gaia-l10n/pl
./repo sync gaia-l10n/pt-BR
./repo sync gaia-l10n/ru
./repo sync gaia-l10n/sr-Cyrl
./repo sync gaia-l10n/sr-Latn
echo "** Actualizando los lenguajes de gecko..."
./repo sync compare-locales
./repo sync gecko-l10n/es-ES
}
 

function CopyFiles(){
CF_XUL=xulrunner-33.0a1.en-US.linux-x86_64.sdk.tar.bz2
CF_MSG0="* Copiando ${CF_XUL}..."
CF_MSG1="** No existe el fichero ${CF_XUL} necesario para gaia."
CF_MSG2="Desea descargarlo? (s/n)"
CF_MSG3="No se puede continuar."
if [[ $BUILD_BRANCH == v2.1 ]];then
if [[ -f $ROOTDIR/${CF_XUL} ]];then
echo ${CF_MSG0}
mkdir -p $WORKDIR/gaia
cp -v $ROOTDIR/${CF_XUL} $WORKDIR/gaia/.
else
echo ${CF_MSG1}
echo ${CF_MSG2}
read DOWN_XUL
if [[ "$DOWN_XUL" == "s" ]];then
wget -c "https://ftp.mozilla.org/pub/mozilla.org/xulrunner/nightly/2014-07-21-06-21-16-mozilla-central/${CF_XUL}"
else
echo ${CF_MSG3}
exit 0
fi
fi	
fi
}
 
function help(){
echo ""
echo "$0 version $BUILD_BRANCH by cargabsj175"
echo "Proyecto Vegnux 2007-$(date +%Y)."
echo ""
echo "Modo de uso: $0 --opcion"
echo ""
echo "--build, compila tu Firefox OS."
echo "--clean-all, limpia el directorio de trabajo para comenzar con una rama nueva."
echo "--clean-b2g, limpia solo los directorios relacionados con Firefox OS."
echo "--prepare, crea y establece ficheros necesarios para un dispositivo y rama determinada."
echo "--help, muestra este mensaje."
echo "--new-repo, crea un directorio de trabajo desde cero."
echo "--update-all, limpia el directorio de trabajo y actualiza los repositorios."
echo "--update-b2g, limpia solo lo relacionado con Firefox OS y actualiza los repositorios."
echo ""
}
 
#############
# VEGNUXMOD #
#############
 
if [ -d $WORKDIR ];then
# > 1. Limpiar el árbol de directorio del código fuente de una compilación anterior:
if [[ "${1}" == --clean-all ]];then
cd $WORKDIR
CleanAll 2>/dev/null
elif [[ "${1}" == --clean-b2g ]];then
cd $WORKDIR
CleanB2G 2>/dev/null
elif [[ "${1}" == --prepare ]];then
# > 2. establecer la rama con la que se va a trabajar
# > 3. Crear el archivo de configuración principal ".config"
# > 4. Crear el archivo configuraciones de usuario ".userconfig"
# > 5. Crear el archivo xml con los repos extra
# > 6. Crear el archivo de idiomas de gaia
SetBranch
CreateFiles
CopyFiles
# > 7. Construir todo
elif [[ "${1}" == --build ]];then
cd $WORKDIR
./build.sh -j4
elif [[ "${1}" == --update-all ]];then
UpdateAll
elif [[ "${1}" == --update-b2g ]];then
UpdateB2G
elif [[ "${1}" == --help ]];then
help
fi
else
if [[ "${1}" == --new-repo ]];then
NewRepo
elif [[ "${1}" == --help ]];then
help
else
echo "** ERROR: ¡No existe el directorio B2G en la ruta $ROOTDIR!"
echo "** Si no tiene un directorio de trabajo puede intentar crear uno con la opción --new-repo"
fi
exit 0
fi
