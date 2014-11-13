#!/bin/bash
# Generar un script para vegnuxmod (roms para firefox os) que permita la automatización
# en las compilaciones de los diferentes "branches" o ramas utilizando las mismas fuentes git
# evitando la redundancia de código, en esta primera versión se manejarán las siguientes versiones.
# v1.4, v2.0 y master
#
# Se describirá a continuación paso por paso los procedimientos que se deben seguir para preparar
# el código fuente segun la rama git.
#
#############
# VARIABLES #
#############
export ROOTDIR=$(pwd)
export WORKDIR=$ROOTDIR/B2G
#############
# RPI		#
#############
export DEVICE=rpi
export BUILD_BRANCH=master
#############
# FUNCIONES #
#############
function CleanAll(){
echo "** Limpiando todo el directorio de trabajo, puede tomarse unos segundos..."
cd $WORKDIR
rm -r abi \
bionic \
bootable \
brcm_usrlib \
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
PRODUCT_NAME=$DEVICE
EOF
echo "** Creando el fichero de configuraciones personales \".userconfig\""
cat << EOF > .userconfig
########################
VARIANT=user
########################
## Make Official Branding Build
########################
export MOZILLA_OFFICIAL=1
export PRODUCTION=1
export GAIA_APP_TARGET=production
########################
## Gaia
########################
export LOCALE_BASEDIR=$WORKDIR/B2G/gaia-l10n
export LOCALES_FILE=$WORKDIR/B2G/gaia-l10n/languages_dev.json
#export GAIA_DEFAULT_LOCALE=es
export REMOTE_DEBUGGER=1
export GAIA_KEYBOARD_LAYOUTS=de,el,en,es,fr,hu,it,pl,pt-BR,ru,sr-Cyrl,sr-Latn
## Gecko
########################
export L10NBASEDIR='$WORKDIR/B2G/gecko-l10n'
export MOZ_CHROME_MULTILOCALE="es-ES"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:$WORKDIR/B2G/compare-locales/scripts"
export PYTHONPATH="$WORKDIR/B2G/compare-locales/lib"
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
<project path="gaia-l10n/de" name="l10n/de/gaia.git" remote="mozillaorg" revision="$BUILD_BRANCH" />
<project path="gaia-l10n/el" name="l10n/el/gaia.git" remote="mozillaorg" revision="$BUILD_BRANCH" />
<project path="gaia-l10n/eo" name="l10n/eo/gaia.git" remote="mozillaorg" revision="$BUILD_BRANCH" />
<project path="gaia-l10n/es" name="l10n/es/gaia.git" remote="mozillaorg" revision="$BUILD_BRANCH" />
<project path="gaia-l10n/hu" name="l10n/hu/gaia.git" remote="mozillaorg" revision="$BUILD_BRANCH" />
<project path="gaia-l10n/it" name="l10n/it/gaia.git" remote="mozillaorg" revision="$BUILD_BRANCH" />
<project path="gaia-l10n/pt-BR" name="l10n/pt-BR/gaia.git" remote="mozillaorg" revision="$BUILD_BRANCH" />
<project path="gaia-l10n/ru" name="l10n/ru/gaia.git" remote="mozillaorg" revision="$BUILD_BRANCH" />
<project path="gaia-l10n/sr-Cyrl" name="l10n/sr-Cyrl/gaia.git" remote="mozillaorg" revision="$BUILD_BRANCH" />
<project path="gaia-l10n/sr-Latn" name="l10n/sr-Latn/gaia.git" remote="mozillaorg" revision="$BUILD_BRANCH" />
<!-- Gecko languages -->
<project path="compare-locales" name="compare-locales" remote="vegnux" revision="master" />
<project path="gecko-l10n/es-ES" name="l10n/es-ES/gecko.git" remote="mozillaorg" revision="mozilla-beta" />
<!-- extra gaia apps -->
<project path="vegnuxmod" name="vegnuxmod" remote="vegnux" revision="$BUILD_BRANCH">
<copyfile src="vegnuxmod.sh" dest="../vegnuxmod-master-rpi.sh" />
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
CF_MSG0="* Copiando ${CF_XUL}..."
CF_MSG1="** No existe el fichero ${CF_XUL} necesario para gaia."
CF_MSG2="Desea descargarlo? (s/n)"
CF_MSG3="No se puede continuar."
# para v1.3
if [[ $BUILD_BRANCH == v1.3 ]]; then
CF_XUL=xulrunner-26.0a1.en-US.linux-x86_64.sdk.tar.bz2
if [[ -f $ROOTDIR/${CF_XUL} ]];then
echo ${CF_MSG0}
mkdir -p $WORKDIR/gaia
cp -v $ROOTDIR/${CF_XUL} $WORKDIR/gaia/.
else
echo ${CF_MSG1}
echo ${CF_MSG2}
read DOWN_XUL
if [[ "$DOWN_XUL" == "s" ]];then
wget -c "https://ftp.mozilla.org/pub/mozilla.org/xulrunner/nightly/2013/09/2013-09-03-03-02-01-mozilla-central/${CF_XUL}"
else
echo ${CF_MSG3}
exit 0
fi
fi	
# para v1.4
elif [[ $BUILD_BRANCH == v1.4 ]]; then
CF_XUL=xulrunner-30.0a1.en-US.linux-x86_64.sdk.tar.bz2
if [[ -f $ROOTDIR/${CF_XUL} ]];then
echo ${CF_MSG0}
mkdir -p $WORKDIR/gaia
cp -v $ROOTDIR/${CF_XUL} $WORKDIR/gaia/.
else
echo ${CF_MSG1}
echo ${CF_MSG2}
read DOWN_XUL
if [[ "$DOWN_XUL" == "s" ]];then
wget -c "https://ftp.mozilla.org/pub/mozilla.org/xulrunner/nightly/2014/02/2014-02-07-03-02-01-mozilla-central/${CF_XUL}"
else
echo ${CF_MSG3}
exit 0
fi
fi	
# para v2.0
elif [[ $BUILD_BRANCH == v2.0 ]]; then
CF_XUL=xulrunner-30.0a1.en-US.linux-x86_64.sdk.tar.bz2
if [[ -f $ROOTDIR/${CF_XUL} ]];then
echo ${CF_MSG0}
mkdir -p $WORKDIR/gaia
cp -v $ROOTDIR/${CF_XUL} $WORKDIR/gaia/.
else
echo ${CF_MSG1}
echo ${CF_MSG2}
read DOWN_XUL
if [[ "$DOWN_XUL" == "s" ]];then
wget -c "https://ftp.mozilla.org/pub/mozilla.org/xulrunner/nightly/2014/02/2014-02-07-03-02-01-mozilla-central/${CF_XUL}"
else
echo ${CF_MSG3}
exit 0
fi
fi	
# para 2.1
elif [[ $BUILD_BRANCH == 2.1 ]]; then
if [[ -f $ROOTDIR/${CF_XUL} ]];then
echo ${CF_MSG0}
mkdir -p $WORKDIR/gaia
cp -v $ROOTDIR/${CF_XUL} $WORKDIR/gaia/.
else
echo ${CF_MSG1}
echo ${CF_MSG2}
read DOWN_XUL
if [[ "$DOWN_XUL" == "s" ]];then
CF_XUL=xulrunner-33.0a1.en-US.linux-x86_64.sdk.tar.bz2
wget -c "https://ftp.mozilla.org/pub/mozilla.org/xulrunner/nightly/2014-07-21-06-21-16-mozilla-central/${CF_XUL}"
else
echo ${CF_MSG3}
exit 0
fi
fi
# para master
elif [[ $BUILD_BRANCH == master ]]; then
if [[ -f $ROOTDIR/${CF_XUL} ]];then
echo ${CF_MSG0}
mkdir -p $WORKDIR/gaia
cp -v $ROOTDIR/${CF_XUL} $WORKDIR/gaia/.
else
echo ${CF_MSG1}
echo ${CF_MSG2}
read DOWN_XUL
if [[ "$DOWN_XUL" == "s" ]];then
CF_XUL=b2g-34.0a1.multi.linux-x86_64.tar.bz2
wget -c "http://ftp.mozilla.org/pub/mozilla.org/b2g/nightly/2014/08/2014-08-12-04-02-01-mozilla-central/${CF_XUL}"
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
