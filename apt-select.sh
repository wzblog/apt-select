#!/bin/bash

_github="https://github.com/wzblog/apt-select"
_app="apt-select"
_system=${2}
_version=${3}

function e()
{
    echo -e "\033[${1}m${2}\033[0m"
}

# Backup source
function backup()
{
    echo -e "\033[32m* 开始备份源\033[0m"
    cp /etc/apt/sources.list /etc/apt/sources.list.backup

    if [[ -e /etc/apt/sources.list.backup ]]
    then
        e 32 "* 备份源成功"
    else
        e 31 "* 备份源失败"
        exit 1
    fi
}


function update()
{
    e 32 "* 开始清除旧软件源"
    apt-get clean
    apt-get autoclean
    e 32 "* 结束清除旧软件源"
    e 32 "* 开始更新软件源"
    apt-get update
    e 32 "* 结束更新软件源"
}


function setSource()
{
    e 32 "* 开始修改源"
    echo "----------"
    echo "+ System: ${1}"
    echo "+ Version: ${2}"
    echo "+ Server: ${3}"
    echo "----------"
    e 32 "* 开始复制指定源文件"

    _path=$(pwd)/${1}/${2}/${3}/sources.list

    if [[ -e ${_path} ]]
    then
        cp $(pwd)/${1}/${2}/${3}/sources.list /etc/apt/sources.list
        e 32 "* 复制完成"

        # update software sources
        update
    else
        e 31 "* ${_path} 文件未找到"
        exit 1
    fi
}


# 系统类型与版本检查函数
function checkSystem()
{
    # 系统类型与版本检查
    _system=$(lsb_release -i | awk '{ print tolower($3) }')
    _version=$(lsb_release -r | awk '{ print tolower($2) }')

    echo "系统："${_system}
    echo "版本："${_version}

    printf "系统类型与版本是否与你的系统所匹配(Y/n):"
    read _mark

    _mark=${_mark:-'Y'}

    if [[ ${_mark} != 'Y' && ${_mark} != 'y' ]]
    then
        printHelp
        e 31 "请手动指定你的系统版本"
        exit 1
    fi
}



# 输出帮助信息
function printHelp()
{
    echo "----------"
    echo "+-------------------------------+"
    echo "|    Manager for ${_app}     |"
    echo "+-------------------------------+"
    echo "${_app} [system version] ali (阿里源)"
    echo "${_app} [system version] thu (清华源)"
    echo "${_app} [system version] 163 (163源)"
    echo "----------"
}

# 如果没有手动指定则自动获取
if [[ -z ${_system} || -z ${_version} ]]
then
    checkSystem
fi



if [[ ${1} = "ali" || ${1} = "thu" || ${1} = "163" ]]
then
    # start backup
    backup
fi


case ${1} in
    ali )
        setSource ${_system} ${_version} aliyun
    ;;
    thu )
        setSource ${_system} ${_version} tsinghua
    ;;
    163 )
        setSource ${_system} ${_version} 163
    ;;
    * )
        printHelp
    ;;
esac

e 33 "* ${_github}"
