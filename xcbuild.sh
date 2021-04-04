#!/bin/sh

# Copy of https://github.com/tdlib/td/blob/master/example/ios/build.sh
# With some changes
#

td_path=$PWD/sources

cd $td_path
git apply ../cmake_framework.patch

cd $td_path/example/ios

rm -rf build
mkdir -p build
cd build

platforms="macOS iOS watchOS tvOS"
for platform in $platforms;
do
  echo "Platform = ${platform} Simulator = ${simulator}"
  openssl_path=$(grealpath ../third_party/openssl/${platform})
  echo "OpenSSL path = ${openssl_path}"
  openssl_crypto_library="${openssl_path}/lib/libcrypto.a"
  openssl_ssl_library="${openssl_path}/lib/libssl.a"
  options="$options -DOPENSSL_FOUND=1"
  options="$options -DOPENSSL_CRYPTO_LIBRARY=${openssl_crypto_library}"
  options="$options -DOPENSSL_SSL_LIBRARY=${openssl_ssl_library}"
  options="$options -DOPENSSL_INCLUDE_DIR=${openssl_path}/include"
  options="$options -DOPENSSL_LIBRARIES=${openssl_crypto_library};${openssl_ssl_library}"
  options="$options -DCMAKE_BUILD_TYPE=Release"
  if [[ $platform = "macOS" ]]; then
    build="build-${platform}"
    install="install-${platform}"
    rm -rf $build
    mkdir -p $build
    mkdir -p $install
    cd $build
    export MACOSX_DEPLOYMENT_TARGET="10.14"
    cmake $td_path $options -DCMAKE_INSTALL_PREFIX=../${install}
    make -j3 install || exit
    cd ..
    mkdir -p $platform
    cp $install/lib/tdjson.framework/Versions/A/tdjson $platform/tdjson
  else
    simulators="0 1"
    for simulator in $simulators;
    do
      build="build-${platform}"
      install="install-${platform}"
      if [[ $simulator = "1" ]]; then
        build="${build}-simulator"
        install="${install}-simulator"
        ios_platform="SIMULATOR"
      else
        ios_platform="OS"
      fi
      if [[ $platform = "iOS" ]]; then
        ios_deloyment_target="10.0"
      fi
      if [[ $platform = "watchOS" ]]; then
        ios_platform="WATCH${ios_platform}"
        ios_deloyment_target="5.0"
      fi
      if [[ $platform = "tvOS" ]]; then
        ios_platform="TV${ios_platform}"
        ios_deloyment_target="10.0"
      fi
      echo $ios_platform
      rm -rf $build
      mkdir -p $build
      mkdir -p $install
      cd $build
      cmake $td_path $options -DIOS_PLATFORM=${ios_platform} -DIOS_DEPLOYMENT_TARGET=${ios_deloyment_target} -DCMAKE_TOOLCHAIN_FILE=${td_path}/../iOS.cmake -DCMAKE_INSTALL_PREFIX=../${install}
      make -j3 install || exit
      cd ..
    done
    lib="install-${platform}/lib/tdjson.framework/tdjson"
    lib_simulator="install-${platform}-simulator/lib/tdjson.framework/tdjson"
    mkdir -p $platform
    lipo -create $lib $lib_simulator -o $platform/tdjson
  fi

  mkdir -p ../tdjson/$platform/include
  rsync --recursive ${install}/include/ ../tdjson/${platform}/include/
  mkdir -p ../tdjson/$platform/lib
  cp $platform/tdjson ../tdjson/$platform/lib/
done
