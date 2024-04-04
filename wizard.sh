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

function java_function {
    server_type
}

function bedrock_function {
    GAME_TYPE="bedrock"
    SERVER_TYPE="vanilla"
    version_function_bedrock
}

function vanilla_function {
    SERVER_TYPE="vanilla"
    version_function
}

function spigot_function {
    SERVER_TYPE="spigot"
    version_function
}

function paper_function {
    SERVER_TYPE="paper"
    version_function
}

function version_function {
    VERSION_YAML=$(curl -s https://assets.ktr-server.com/minecraft-server/manifest.yaml | yq ".${GAME_TYPE}"".""${SERVER_TYPE}"".versions.latest")
    read -p "バージョン[${VERSION_YAML}]:" VERSION
    if [ -n ${VERSION} ]; then
        VERSION="${VERSION_YAML}"
    fi
    VERSION=${VERSION//./-}
    serach_function
}

function version_function_bedrock {
    VERSION_YAML=$(curl -s https://assets.ktr-server.com/minecraft-server/manifest.yaml | yq ".${GAME_TYPE}"".""${SERVER_TYPE}"".versions.latest")
    read -p "バージョン[${VERSION_YAML}]:" VERSION
    if [ -n ${VERSION} ]; then
        VERSION="${VERSION_YAML}"
    fi
    VERSION=${VERSION//./-}
    serach_function
}

function serach_function {
    # wget -q https://assets.ktr-server.com/minecraft-server/manifest.yaml -O ${YAML_FILE}
    ARRAY=".""${GAME_TYPE}"".""${SERVER_TYPE}"".""${VERSION}"".url"
    URL=$(curl -s https://assets.ktr-server.com/minecraft-server/manifest.yaml | yq ${ARRAY})
    dir_function
}

function dir_function {
    read -p "サーバーフォルダー名[minecraft]:" DIR_NAME
    if [ -n ${DIR_NAME} ]; then
        DIR_NAME="minecraft"
    fi
    filename_function
}

function filename_function {
    echo 'サーバーファイル'
    read -p "ファイル名[server]:" FILE_NAME
    if [ -n ${FILE_NAME} ]; then
        FILE_NAME="server"
    fi
    download_function
}

function download_function {
    mkdir -p "${DIR_NAME}"
    if [ ${GAME_TYPE} = "bedrock" ]; then
    wget ${URL} -O "${DIR_NAME}""/""${FILE_NAME}"".zip"
    # rm ${YAML_FILE}
    exit 2;
    elif [ ${GAME_TYPE} = "java" ]; then 
    wget ${URL} -O "${DIR_NAME}""/""${FILE_NAME}"".jar"
    # rm ${YAML_FILE}
    exit 2;
    else
        echo "error"
    fi
}

function server_type {
    GAME_TYPE="java"
    echo 'サーバーのソフトを選んでください。'
    select VAR in vanilla spigot paper q
    do
        if [ "${REPLY}" = "q" ]; then
        echo "終了します."
        exit 0
        fi
        case $VAR in
    	"vanilla" ) vanilla_function;;
    	"spigot" ) spigot_function;;
    	"paper" ) paper_function;;
    	"q" ) break ;;
    	* ) break ::
        esac
    done
}

function install_function {
    if [ "$EUID" -ne 0 ]; then
    echo "ルートユーザーで実行してください [sudo]"
    exit 1
    fi
    apt update && apt install -y snap wget unzip curl && snap install yq
}

YAML_FILE="temp.yaml"

if type "   " > /dev/null 2>&1; then
    echo
else
    echo "必要なパッケージをインストールしてもよいですか？"
    read -p "[y/n]:" ACCEPT_INSTALL
    case "$ACCEPT_INSTALL" in [nN]*)  ;; *) install_function ;; esac
fi

if type "curl" > /dev/null 2>&1; then
    echo
else
    echo "必要なパッケージをインストールしてもよいですか？"
    read -p "[y/n]:" ACCEPT_INSTALL
    case "$ACCEPT_INSTALL" in [nN]*)  ;; *) install_function ;; esac
fi

if type "wget" > /dev/null 2>&1; then
    echo
else
    echo "必要なパッケージをインストールしてもよいですか？"
    read -p "[y/n]:" ACCEPT_INSTALL
    case "$ACCEPT_INSTALL" in [nN]*)  ;; *) install_function ;; esac
fi

echo 'マイクラのタイプを選択してください。'
PS3="'q'を入力して終了 > "
select VAR in java bedrock
do
    if [ "${REPLY}" = "q" ]; then
        echo "終了します."
        exit 0
    fi
    case $VAR in
	"java" ) java_function;;
	"bedrock" ) bedrock_function;;
	* ) break ::
    esac
done