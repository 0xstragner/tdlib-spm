#!/bin/sh

ROOT=$PWD

TDLIB_VERSION=1.7.0
TDLIB=$ROOT/sources

TDLIB_MODULEMAP=$ROOT/templates/modulemap
TDLIB_INFO=$ROOT/templates/info

rm -rf $TDLIB
git clone --depth 1 --branch v$TDLIB_VERSION git@github.com:tdlib/td.git $TDLIB

cd $TDLIB
mkdir native-build
cd native-build

cmake ..
cmake --build . --target prepare_cross_compiling

cd $TDLIB/example/ios
./build-openssl.sh

cd $ROOT
./xcbuild.sh

cd $TDLIB/example/ios/build
LIBNAME=libtdjson

XCFRAMEWORK_BUILD_PATH=$ROOT/build

rm -rf $XCFRAMEWORK_BUILD_PATH
mkdir -p $XCFRAMEWORK_BUILD_PATH

XCFRAMEWORK_COMPONENTS_PATH=$XCFRAMEWORK_BUILD_PATH/frameworks

mkdir -p $XCFRAMEWORK_COMPONENTS_PATH

PLATFORMS="iOS macOS watchOS tvOS"
for PLATFORM in $PLATFORMS;
do
    SIMULATOR_PATH=$XCFRAMEWORK_COMPONENTS_PATH/$PLATFORM-simulator
    DEVICE_PATH=$XCFRAMEWORK_COMPONENTS_PATH/$PLATFORM-device

    cd $PLATFORM

    lipo -create $LIBNAME.dylib -output $LIBNAME
    install_name_tool -id @rpath/$LIBNAME.framework/$LIBNAME $LIBNAME

    ARCHS=$(lipo -archs $LIBNAME)
    for ARCH in $ARCHS;
    do
        lipo $LIBNAME -thin $ARCH -output $LIBNAME-$ARCH
    done

    if [[ $PLATFORM = "macOS" ]]; 
    then
        mkdir $DEVICE_PATH

        DEVICE_ARCHS="$LIBNAME-x86_64"
        DEVICE_FRAMEWORK_PATH=$DEVICE_PATH/$LIBNAME.framework
        mkdir $DEVICE_FRAMEWORK_PATH

        lipo -create $DEVICE_ARCHS -output $DEVICE_FRAMEWORK_PATH/$LIBNAME
    else
        mkdir $SIMULATOR_PATH
        mkdir $DEVICE_PATH

        SIMULATOR_ARCHS=""
        DEVICE_ARCHS=""

        if [[ $PLATFORM = "iOS" ]];
        then
            SIMULATOR_ARCHS="$LIBNAME-i386 $LIBNAME-x86_64"
            DEVICE_ARCHS="$LIBNAME-arm64 $LIBNAME-armv7 $LIBNAME-armv7s"
        elif [[ $PLATFORM = "watchOS" ]];
        then
            SIMULATOR_ARCHS="$LIBNAME-i386"
            DEVICE_ARCHS="$LIBNAME-armv7k"
        elif [[ $PLATFORM = "tvOS" ]];
        then
            SIMULATOR_ARCHS="$LIBNAME-x86_64"
            DEVICE_ARCHS="$LIBNAME-arm64"
        fi
        
        SIMULATOR_FRAMEWORK_PATH=$SIMULATOR_PATH/$LIBNAME.framework
        mkdir $SIMULATOR_FRAMEWORK_PATH

        DEVICE_FRAMEWORK_PATH=$DEVICE_PATH/$LIBNAME.framework
        mkdir $DEVICE_FRAMEWORK_PATH

        lipo -create $SIMULATOR_ARCHS -output $SIMULATOR_FRAMEWORK_PATH/$LIBNAME
        lipo -create $DEVICE_ARCHS -output $DEVICE_FRAMEWORK_PATH/$LIBNAME
    fi

    cd ..

    if [ -d "install-$PLATFORM" ] 
    then
        cp -R install-$PLATFORM/include/td $DEVICE_PATH/include
    fi

    if [ -d "install-$PLATFORM-simulator" ] 
    then
        cp -R install-$PLATFORM/include/td $SIMULATOR_PATH/include
    fi
done 

FRAMEWORKS=()
INDEX=0
for FRAMEWORK_PATH_PARENT in $XCFRAMEWORK_COMPONENTS_PATH/*; 
do
    FRAMEWORK_PATH="$FRAMEWORK_PATH_PARENT/$LIBNAME.framework"

    mkdir $FRAMEWORK_PATH/Headers
    mkdir $FRAMEWORK_PATH/Modules

    cp $TDLIB_INFO $FRAMEWORK_PATH/Info.plist
    cp $TDLIB_MODULEMAP $FRAMEWORK_PATH/Modules/module.modulemap

    FRAMEWORK_INCLUDE=$FRAMEWORK_PATH_PARENT/include

    LC_ALL=C find $FRAMEWORK_INCLUDE -type f -exec sed -i '' 's/td\/telegram\///g' {} \;
    LC_ALL=C find $FRAMEWORK_INCLUDE -type f -exec sed -i '' 's/td\/tl\///g' {} \;

    cp -a $FRAMEWORK_INCLUDE/telegram/. $FRAMEWORK_PATH/Headers
    cp -a $FRAMEWORK_INCLUDE/tl/. $FRAMEWORK_PATH/Headers

    rm -rf $FRAMEWORK_INCLUDE

    FRAMEWORKS[$INDEX]="-framework $FRAMEWORK_PATH"
    ((INDEX=INDEX+1))
done

xcodebuild -create-xcframework ${FRAMEWORKS[@]} -output $XCFRAMEWORK_BUILD_PATH/$LIBNAME.xcframework
rm -rf $TDLIB
