#!/bin/bash
echo -e "\n----------------------------------------------"
echo -e "----       Clonador de idiomas B2G        ----"
echo -e "----    Script creado por @amirtorrez     ----"
echo -e "----------------------------------------------"

## Variables de idiomas
LANG_DIR1="gaia-l10n"; ## Carpeta donde irán todos los idiomas de GAIA
LANG_DIR2="gecko-l10n"; ## Carpeta donde irán todos los idiomas de GECKO
LANG_VERSION="master"; ## Version de B2G para los idiomas (master,v2_1, v2_0, v1_4, etc)
LANG_DIR3="compare-locales"; ## Carpeta donde irán los scripts compare-locales

## Se verifica que el paquete mercurial esté instalado
if [ -x /usr/bin/hg ]; then
## si está instalado se ejecuta el script

## Si existe la carpeta anterior la borramos
## para meter los nuevos archivos dentro
if [ -d $LANG_DIR1 ]; then
rm -r -f $LANG_DIR1
fi

if [ -d $LANG_DIR2 ]; then
rm -r -f $LANG_DIR2
fi

## Definimos la url de descarga
## dependiendo la version de B2G
if [ "$LANG_VERSION" = "master" ]; then
	LANG_URL="gaia-l10n";
else
	LANG_URL="releases/gaia-l10n/$LANG_VERSION";
fi

echo -e "\nClonando idiomas GAIA\n";
## Clonamos los idiomas desde mozilla
hg clone https://hg.mozilla.org/$LANG_URL/bn-BD $LANG_DIR1/bn-BD
hg clone https://hg.mozilla.org/$LANG_URL/de $LANG_DIR1/de
hg clone https://hg.mozilla.org/$LANG_URL/el $LANG_DIR1/el
hg clone https://hg.mozilla.org/$LANG_URL/en-US $LANG_DIR1/en-US
hg clone https://hg.mozilla.org/$LANG_URL/es $LANG_DIR1/es
hg clone https://hg.mozilla.org/$LANG_URL/fr $LANG_DIR1/fr
hg clone https://hg.mozilla.org/$LANG_URL/hi-IN $LANG_DIR1/hi-IN
hg clone https://hg.mozilla.org/$LANG_URL/hu $LANG_DIR1/hu
hg clone https://hg.mozilla.org/$LANG_URL/it $LANG_DIR1/it
hg clone https://hg.mozilla.org/$LANG_URL/ja $LANG_DIR1/ja
hg clone https://hg.mozilla.org/$LANG_URL/pl $LANG_DIR1/pl
hg clone https://hg.mozilla.org/$LANG_URL/pt-BR $LANG_DIR1/pt-BR
hg clone https://hg.mozilla.org/$LANG_URL/ru $LANG_DIR1/ru
hg clone https://hg.mozilla.org/$LANG_URL/sv-SE $LANG_DIR1/sv-SE
hg clone https://hg.mozilla.org/$LANG_URL/zh-CN $LANG_DIR1/zh-CN

echo -e "\nClonando idiomas GECKO\n";
## Clonamos los idiomas desde mozilla
hg clone https://hg.mozilla.org/l10n-central/bn-BD $LANG_DIR2/bn-BD
hg clone https://hg.mozilla.org/l10n-central/de $LANG_DIR2/de
hg clone https://hg.mozilla.org/l10n-central/el $LANG_DIR2/el
hg clone https://hg.mozilla.org/l10n-central/en-GB $LANG_DIR2/en-GB
hg clone https://hg.mozilla.org/l10n-central/es-MX $LANG_DIR2/es-MX
hg clone https://hg.mozilla.org/l10n-central/fr $LANG_DIR2/fr
hg clone https://hg.mozilla.org/l10n-central/hi-IN $LANG_DIR2/hi-IN
hg clone https://hg.mozilla.org/l10n-central/hu $LANG_DIR2/hu
hg clone https://hg.mozilla.org/l10n-central/it $LANG_DIR2/it
hg clone https://hg.mozilla.org/l10n-central/ja $LANG_DIR2/ja
hg clone https://hg.mozilla.org/l10n-central/pl $LANG_DIR2/pl
hg clone https://hg.mozilla.org/l10n-central/pt-BR $LANG_DIR2/pt-BR
hg clone https://hg.mozilla.org/l10n-central/ru $LANG_DIR2/ru
hg clone https://hg.mozilla.org/l10n-central/sv-SE $LANG_DIR2/sv-SE
hg clone https://hg.mozilla.org/l10n-central/zh-CN $LANG_DIR2/zh-CN

echo -e "\nClonando compare-locales\n";
## Clonamos los scripts comparadores desde mozilla
hg clone https://hg.mozilla.org/build/compare-locales $LANG_DIR3/

## Nos ubicamos dentro la carpeta de los idiomas
cd $LANG_DIR1

## Creamos el archivo languages_dev.json
cat << EOF > languages_dev.json
{
  "bn-BD"     : "বাংলা (বাংলাদেশ)",
  "de"        : "Deutsch",
  "el"        : "Ελληνικά",
  "en-US"     : "English (US)",
  "es"        : "Español",
  "fr"        : "Français",
  "hi-IN"     : "हिन्दी (भारत)",
  "hu"        : "Magyar",
  "it"        : "Italiano",
  "ja"        : "日本語",
  "pl"        : "Polski",
  "pt-BR"     : "Português (do Brasil)",
  "ru"        : "Русский",
  "sv-SE"     : "Svenska",
  "zh-CN"     : "中文 (简体)"
}
EOF

## Descargamos el archivo json que lista todos los idiomas
wget https://raw.githubusercontent.com/amirtorrez/b2g-custome/master/gaia-l10n/languages_all.json

## Salimos y nos ubicamos dentro del siguiente directorio
cd ../$LANG_DIR2

## Creamos el archivo all-locales
cat << EOF > all-locales
bn-BD
de
el
en-GB
es-MX
fr
hi-IN
hu
it
ja
pl
pt-BR
ru
sv-SE
zh-CN
EOF

## Si el paquete mercurial no está instalado
## se muestra un aviso al usuario
else
echo -e '\nSe necesita "mercurial" instalado para usar este script.\n';
fi
