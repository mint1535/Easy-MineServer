#!/bin/bash
# helpを作成
function usage {
  cat <<EOM
Usage: $(basename "$0") [OPTION]...
  -h          Display help
  -s            Server Type
  -vl Value    Minecraft version list
  -v VALUE    Minecraft version (default:latest)
  -b          Change Minecraft Server to "bedrock server"
  -c VALUE    A explanation for arg called c
  -d VALUE    A explanation for arg called d
EOM
  exit 2
}

GAME_TYPE="vanilla"
YAML_FILE="temp.yaml"
VERSION="1-20-4"
DIR_NAME="minecraft"
FILE_NAME="server"
# 引数別の処理定義
while getopts ":vlsvbh-:" optKey; do
  case "$optKey" in
    -)
      case "${OPTARG}" in
          version)
            echo "version"
            ;;
          help |*)
            usage
         esac
         ;;
    l)
      echo "バージョンリスト"
      exit 2;
      ;;
    s)
      SERVER_TYPE=${ORTARG}
      ;;
    v)
      VERSION=${ORTARG}
      ;;
    b)
      GAME_TYPE="bedrock"
      ;;
    h | *)
      usage
      ;;
  esac
done

wget -q https://assets.ktr-server.com/minecraft-server/java/manifest.yaml -O ${YAML_FILE}
ARRAY=".""${GAME_TYPE}"".""${VERSION}"".url"
URL=$(yq ${ARRAY} ${YAML_FILE})
echo ${URL}
mkdir -p ${DIR_NAME}
wget -q ${URL} -O ${DIR_NAME}"/"${FILE_NAME}".jar"
rm ${YAML_FILE}