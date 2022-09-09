#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     build-image.sh
# UpdateDate:   2022/09/08
# Description:  Build docker images for edge-cross-compile.
# Example:
#               #Build docker images: gcc-linaro + gcc-arm
#               #./build-image.sh -l 1 -a 1
#               #Build docker images: gcc-linaro
                #./build-image.sh
#               #./build-image.sh -l 1
#               #Build docker images: gcc-arm
#               #./build-image.sh -a 1
# Depends:
#               gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu.tgz(ftp://download.cambricon.com:8821/***/gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu.tgz)
#               gcc-arm-none-eabi-8-2018-q4-major.tar.gz(ftp://download.cambricon.com:8821/***/gcc-arm-none-eabi-8-2018-q4-major.tar.gz)
# Notes:
#               1.gcc-linaro&cntoolkit-edge has been deployed to the container.
#                 gcc-linaro(/opt/work/gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu)
#               2.These environment variables has been set in the container
#                 BIN_DIR_GCC_Linaro=/opt/work/gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu/bin
#                 BIN_DIR_GCC_ARM=/opt/work/gcc-arm-none-eabi-8-2018-q4-major/bin
#                 PATH=$BIN_DIR_GCC_Linaro:$BIN_DIR_GCC_ARM:$PATH
# -------------------------------------------------------------------------------
#################### function ####################
help_info() {
    echo "
Build docker images for edge-cross-compile.
Usage:
    $0 <command> [arguments]
The commands are:
    -h      Help info.
    -l      FLAG_with_gcc_linaro_installed.(0/1;default:1)
    -a      FLAG_with_gcc_arm_installed.(0/1;default:0)

Examples:
    $0 -h
    $0 -l 1 -a 1
    $0 -l 1
    $0 -a 1
Use '$0 -h' for more information about a command.
    "
}

#################### main ####################
# Source env
source "./env.sh"

##FLAG_with_***_installed
FLAG_with_gcc_linaro_installed=1
FLAG_with_gcc_arm_installed=0
FLAG_with_gcc_linaro_installed2dockerfile="yes"
FLAG_with_gcc_arm_installed2dockerfile="no"

#if [[ $# -eq 0 ]];then
#    help_info && exit 0
#fi

# Get parameters
while getopts "h:m:v:n:l:a:c:" opt; do
    case $opt in
    h) help_info  &&  exit 0
        ;;
    l) FLAG_with_gcc_linaro_installed=$OPTARG
        ;;
    a) FLAG_with_gcc_arm_installed=$OPTARG
        ;;
    \?)
        help_info && exit 0
        ;;
    esac
done

## 0.check
if [ ! -d "$PATH_WORK" ];then
    mkdir -p $PATH_WORK
else
    echo "Directory($PATH_WORK): Exists!"
fi

### Sync FILENAME_EDGE_GCC_LINARO
pushd "${PATH_WORK}"
if [ $FLAG_with_gcc_linaro_installed -eq 1 ];then
    if [ -f "${FILENAME_EDGE_GCC_LINARO}" ];then
        echo "File(${FILENAME_EDGE_GCC_LINARO}): Exists!"
    else
        echo -e "${red}File(${FILENAME_EDGE_GCC_LINARO}): Not exist!${none}"
        echo -e "${yellow}1.Please download ${FILENAME_EDGE_GCC_LINARO} from FTP(ftp://download.cambricon.com:8821/***)!${none}"
        echo -e "${yellow}  For further information, please contact us.${none}"
        echo -e "${yellow}2.Copy the dependent packages(${FILENAME_EDGE_GCC_LINARO}) into the directory!${none}"
        echo -e "${yellow}  eg: cp -v /data/ftp/product/cross-compile-toolchain/aarch64/${FILENAME_EDGE_GCC_LINARO} ./${PATH_WORK}${none}"
        exit -1
    fi
    FLAG_with_gcc_linaro_installed2dockerfile="yes"
else
    FLAG_with_gcc_linaro_installed2dockerfile="no"
fi
popd
### Sync FILENAME_EDGE_GCC_ARM
pushd "${PATH_WORK}"
if [ $FLAG_with_gcc_arm_installed -eq 1 ];then
    if [ -f "${FILENAME_EDGE_GCC_ARM}" ];then
        echo "File(${FILENAME_EDGE_GCC_ARM}): Exists!"
    else
        echo -e "${red}File(${FILENAME_EDGE_GCC_ARM}): Not exist!${none}"
        echo -e "${yellow}1.Please download ${FILENAME_EDGE_GCC_ARM} from FTP(ftp://download.cambricon.com:8821/***)!${none}"
        echo -e "${yellow}  For further information, please contact us.${none}"
        echo -e "${yellow}2.Copy the dependent packages(${FILENAME_EDGE_GCC_ARM}) into the directory!${none}"
        echo -e "${yellow}  eg: cp -v /data/ftp/product/cross-compile-toolchain/m0/${FILENAME_EDGE_GCC_ARM} ./${PATH_WORK}${none}"
        exit -1
    fi
    FLAG_with_gcc_arm_installed2dockerfile="yes"
else
    FLAG_with_gcc_arm_installed2dockerfile="no"
fi
popd

#1.build image
echo "====================== build image ======================"
sudo docker build -f ./${DIR_DOCKER}/$FILENAME_DOCKERFILE \
    --build-arg path_work=${PATH_WORK} \
    --build-arg edge_gcc_linaro=${FILENAME_EDGE_GCC_LINARO} \
    --build-arg edge_gcc_arm=${FILENAME_EDGE_GCC_ARM} \
    --build-arg with_gcc_linaro_installed=${FLAG_with_gcc_linaro_installed2dockerfile} \
    --build-arg with_gcc_arm_installed=${FLAG_with_gcc_arm_installed2dockerfile} \
    -t $NAME_IMAGE .

#2.save image
echo "====================== save image ======================"
sudo docker save -o $FILENAME_IMAGE $NAME_IMAGE
sync && sync
sudo chmod 664 $FILENAME_IMAGE
mv $FILENAME_IMAGE ./${DIR_DOCKER}/
ls -la ./${DIR_DOCKER}/$FILENAME_IMAGE
