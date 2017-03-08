#!/bin/bash
set -e

PYTHON2_PATH="/usr/lib/python2.7/dist-packages:/usr/lib/python2.7/site-packages"
PYTHON3_PATH_debian="/usr/lib/python3/dist-packages"
PYTHON3_PATH_alpine="/usr/lib/python3.5/site-packages"
PYTHON3_PATH_fedora="/usr/lib/python3.5/site-packages"
PYTHON2_ARGS="-DBUILDSWIGNODE=OFF"
PYTHON3_ARGS="-DBUILDSWIGNODE=OFF -DBUILDPYTHON3=ON -DPYTHON_INCLUDE_DIR=/usr/local/include/python3.5m/ -DPYTHON_LIBRARY=/usr/local/lib/libpython3.so"

# $1: path
# $2: variants
set_onbuild_warning() {
	for va in $2; do
		if [ $va == 'base' ]; then
			tmp_path=$1
		else
			tmp_path="$1/$va"
		fi
		if [ -f "$tmp_path/Dockerfile" ]; then
			echo "ONBUILD RUN echo 'This repository is deprecated. Please check https://docs.resin.io/runtime/resin-base-images/ for information about Resin docker images.' " >> $tmp_path/Dockerfile
		fi
	done
	
}

# append mraa build script to the bottom of Dockerfile.
# $1: base version
# $2: path
# $3: distro
# $4: variants
append_setup_script() {
	# Can't build mraa on alpine linux, lack of necessary libraries.
	if [ $3 == 'debian' ]; then
		script_file='setup.sh'
	fi
	for va in $4; do

		if [ $va == 'base' ]; then
			tmp_path=$2
		else
			tmp_path="$2/$va"
		fi
		cp $script_file $tmp_path
		echo "COPY $script_file /$script_file" >> $tmp_path/Dockerfile
		echo "RUN bash /$script_file && rm /$script_file" >> $tmp_path/Dockerfile
		if [ $1 != "2.7" ]; then
			sed -i -e s~#{ARGS}~"$PYTHON3_ARGS"~g $tmp_path/$script_file
		else
			sed -i -e s~#{ARGS}~"$PYTHON2_ARGS"~g $tmp_path/$script_file
		fi
	done
}

# set PYTHONPATH to point to dist-packages
# $1: base version
# $2: path
# $3: variants
# $4: distro
set_pythonpath() {
	for va in $3; do

		if [ $va == 'base' ]; then
			tmp_path=$2
		else
			tmp_path="$2/$va"
		fi

		if [ $1 != "2.7" ]; then
			PPATH="PYTHON3_PATH_$4"
			echo "ENV PYTHONPATH ${!PPATH}:\$PYTHONPATH" >> $tmp_path/Dockerfile
		else
			echo "ENV PYTHONPATH $PYTHON2_PATH:\$PYTHONPATH" >> $tmp_path/Dockerfile
		fi
	done
}

devices='raspberrypi raspberrypi2 beaglebone edison nuc vab820-quad zc702-zynq7 odroid-c1 odroid-ux3 parallella-hdmi-resin nitrogen6x cubox-i ts4900 colibri-imx6 apalis-imx6 ts7700 raspberrypi3 artik5 artik10 beaglebone-green-wifi qemux86 qemux86-64 beaglebone-green intel-quark artik710 am57xx-evm up-board'
fedora_devices=' raspberrypi2 beaglebone vab820-quad zc702-zynq7 odroid-c1 odroid-ux3 parallella-hdmi-resin nitrogen6x cubox-i ts4900 colibri-imx6 apalis-imx6 raspberrypi3 artik5 artik10 beaglebone-green-wifi beaglebone-green nuc qemux86-64 artik710 am57xx-evm '
pythonVersions='2.7.12 3.3.6 3.4.4 3.5.2 3.6.0'
binary_url="http://resin-packages.s3.amazonaws.com/python/v\$PYTHON_VERSION/Python-\$PYTHON_VERSION.linux-#{TARGET_ARCH}.tar.gz"

for device in $devices; do
	case "$device" in
	'raspberrypi')
		binary_arch='armv6hf'
		alpine_binary_arch='alpine-armhf'
	;;
	'raspberrypi2')
		binary_arch='armv7hf'
		alpine_binary_arch='alpine-armhf'
		fedora_binary_arch='fedora-armhf'
	;;
	'raspberrypi3')
		binary_arch='armv7hf'
		alpine_binary_arch='alpine-armhf'
		fedora_binary_arch='fedora-armhf'
	;;
	'beaglebone')
		binary_arch='armv7hf'
		alpine_binary_arch='alpine-armhf'
		fedora_binary_arch='fedora-armhf'
	;;
	'beaglebone-green-wifi')
		binary_arch='armv7hf'
		alpine_binary_arch='alpine-armhf'
		fedora_binary_arch='fedora-armhf'
	;;
	'beaglebone-green')
		binary_arch='armv7hf'
		alpine_binary_arch='alpine-armhf'
		fedora_binary_arch='fedora-armhf'
	;;
	'edison')
		binary_arch='i386'
		alpine_binary_arch='alpine-i386'
	;;
	'qemux86')
		binary_arch='i386'
		alpine_binary_arch='alpine-i386'
	;;
	'intel-quark')
		binary_arch='i386'
		alpine_binary_arch='alpine-i386'
	;;
	'nuc')
		binary_arch='amd64'
		alpine_binary_arch='alpine-amd64'
		fedora_binary_arch='fedora-amd64'
	;;
	'qemux86-64')
		binary_arch='amd64'
		alpine_binary_arch='alpine-amd64'
		fedora_binary_arch='fedora-amd64'
	;;
	'up-board')
		binary_arch='amd64'
		alpine_binary_arch='alpine-amd64'
		fedora_binary_arch='fedora-amd64'
	;;
	'vab820-quad')
		binary_arch='armv7hf'
		alpine_binary_arch='alpine-armhf'
		fedora_binary_arch='fedora-armhf'
	;;
	'zc702-zynq7')
		binary_arch='armv7hf'
		alpine_binary_arch='alpine-armhf'
		fedora_binary_arch='fedora-armhf'
	;;
	'odroid-c1')
		binary_arch='armv7hf'
		alpine_binary_arch='alpine-armhf'
		fedora_binary_arch='fedora-armhf'
	;;
	'odroid-ux3')
		binary_arch='armv7hf'
		alpine_binary_arch='alpine-armhf'
		fedora_binary_arch='fedora-armhf'
	;;
	'parallella-hdmi-resin')
		binary_arch='armv7hf'
		alpine_binary_arch='alpine-armhf'
		fedora_binary_arch='fedora-armhf'
	;;
	'nitrogen6x')
		binary_arch='armv7hf'
		alpine_binary_arch='alpine-armhf'
		fedora_binary_arch='fedora-armhf'
	;;
	'cubox-i')
		binary_arch='armv7hf'
		alpine_binary_arch='alpine-armhf'
		fedora_binary_arch='fedora-armhf'
	;;
	'ts4900')
		binary_arch='armv7hf'
		alpine_binary_arch='alpine-armhf'
		fedora_binary_arch='fedora-armhf'
	;;
	'colibri-imx6')
		binary_arch='armv7hf'
		alpine_binary_arch='alpine-armhf'
		fedora_binary_arch='fedora-armhf'
	;;
	'apalis-imx6')
		binary_arch='armv7hf'
		alpine_binary_arch='alpine-armhf'
		fedora_binary_arch='fedora-armhf'
	;;
	'am57xx-evm')
		binary_arch='armv7hf'
		alpine_binary_arch='alpine-armhf'
		fedora_binary_arch='fedora-armhf'
	;;
	'ts7700')
		binary_arch='armel'
		# Not supported yet
		#alpine_binary_url=$resinUrl
		#alpine_binary_arch='alpine-armhf'
	;;
	'artik5')
		binary_arch='armv7hf'
		alpine_binary_arch='alpine-armhf'
		fedora_binary_arch='fedora-armhf'
	;;
	'artik10')
		binary_arch='armv7hf'
		alpine_binary_arch='alpine-armhf'
		fedora_binary_arch='fedora-armhf'
	;;
	'artik710')
		binary_arch='armv7hf'
		alpine_binary_arch='alpine-armhf'
		fedora_binary_arch='fedora-armhf'
	;;
	esac
	for pythonVersion in $pythonVersions; do

		if [ $pythonVersion != "2.7.12" ]; then
			template='Dockerfile.python3.tpl'
			slimTemplate='Dockerfile.python3.slim.tpl'
		else
			template='Dockerfile.tpl'
			slimTemplate='Dockerfile.slim.tpl'
		fi
		baseVersion=$(expr match "$pythonVersion" '\([0-9]*\.[0-9]*\)')

		# Debian

		# Extract checksum
		checksum=$(grep " Python-$pythonVersion.linux-$binary_arch.tar.gz" SHASUMS256.txt)

		debian_dockerfilePath=$device/debian/$baseVersion
		mkdir -p $debian_dockerfilePath
		sed -e s~#{FROM}~"resin/$device-buildpack-deps:jessie"~g \
				-e s~#{PYTHON_VERSION}~"$pythonVersion"~g \
				-e s~#{PYTHON_BASE_VERSION}~"$baseVersion"~g \
				-e s~#{BINARY_URL}~"$binary_url"~g \
				-e s~#{CHECKSUM}~"$checksum"~g \
				-e s~#{TARGET_ARCH}~"$binary_arch"~g $template > $debian_dockerfilePath/Dockerfile

		mkdir -p $debian_dockerfilePath/wheezy
		sed -e s~#{FROM}~"resin/$device-buildpack-deps:wheezy"~g \
				-e s~#{PYTHON_VERSION}~"$pythonVersion"~g \
				-e s~#{PYTHON_BASE_VERSION}~"$baseVersion"~g \
				-e s~#{BINARY_URL}~"$binary_url"~g \
				-e s~#{CHECKSUM}~"$checksum"~g \
				-e s~#{TARGET_ARCH}~"$binary_arch"~g $template > $debian_dockerfilePath/wheezy/Dockerfile

		mkdir -p $debian_dockerfilePath/onbuild
		sed -e s~#{FROM}~"resin/$device-python:$pythonVersion"~g Dockerfile.onbuild.tpl > $debian_dockerfilePath/onbuild/Dockerfile
		mkdir -p $debian_dockerfilePath/slim

		# Only for RPI1 device
		if [ $device == "raspberrypi" ]; then
			sed -e s~#{FROM}~"resin/rpi-raspbian:jessie"~g \
				-e s~#{PYTHON_VERSION}~"$pythonVersion"~g \
				-e s~#{PYTHON_BASE_VERSION}~"$baseVersion"~g \
				-e s~#{BINARY_URL}~"$binary_url"~g \
				-e s~#{CHECKSUM}~"$checksum"~g \
				-e s~#{TARGET_ARCH}~"$binary_arch"~g $slimTemplate > $debian_dockerfilePath/slim/Dockerfile
		else
			sed -e s~#{FROM}~"resin/$device-debian:jessie"~g \
				-e s~#{PYTHON_VERSION}~"$pythonVersion"~g \
				-e s~#{PYTHON_BASE_VERSION}~"$baseVersion"~g \
				-e s~#{BINARY_URL}~"$binary_url"~g \
				-e s~#{CHECKSUM}~"$checksum"~g \
				-e s~#{TARGET_ARCH}~"$binary_arch"~g $slimTemplate > $debian_dockerfilePath/slim/Dockerfile
		fi

		# Only for intel edison
		if [ $device == "edison" ]; then
			append_setup_script "$baseVersion" "$debian_dockerfilePath" "debian" "base wheezy slim"
		fi

		set_pythonpath "$baseVersion" "$debian_dockerfilePath" "base wheezy slim" "debian"

		set_onbuild_warning "$debian_dockerfilePath" "base wheezy slim onbuild"

		# Alpine
		# TODO: install mraa on Edison

		# armel device not supported yet.
		if [ $device == "ts7700" ]; then
			continue
		fi

		if [ $pythonVersion != "2.7.12" ]; then
			template='Dockerfile.alpine.python3.tpl'
			slimTemplate='Dockerfile.alpine.python3.slim.tpl'
		else
			template='Dockerfile.alpine.tpl'
			slimTemplate='Dockerfile.alpine.slim.tpl'
		fi

		# Extract checksum
		checksum=$(grep " Python-$pythonVersion.linux-$alpine_binary_arch.tar.gz" SHASUMS256.txt)

		alpine_dockerfilePath=$device/alpine/$baseVersion
		mkdir -p $alpine_dockerfilePath
		sed -e s~#{FROM}~"resin/$device-alpine-buildpack-deps:latest"~g \
				-e s~#{PYTHON_VERSION}~"$pythonVersion"~g \
				-e s~#{PYTHON_BASE_VERSION}~"$baseVersion"~g \
				-e s~#{BINARY_URL}~"$binary_url"~g \
				-e s~#{CHECKSUM}~"$checksum"~g \
				-e s~#{TARGET_ARCH}~"$alpine_binary_arch"~g $template > $alpine_dockerfilePath/Dockerfile

		mkdir -p $alpine_dockerfilePath/onbuild
		sed -e s~#{FROM}~"resin/$device-alpine-python:$pythonVersion"~g Dockerfile.onbuild.tpl > $alpine_dockerfilePath/onbuild/Dockerfile

		mkdir -p $alpine_dockerfilePath/slim
		sed -e s~#{FROM}~"resin/$device-alpine:latest"~g \
				-e s~#{PYTHON_VERSION}~"$pythonVersion"~g \
				-e s~#{PYTHON_BASE_VERSION}~"$baseVersion"~g \
				-e s~#{BINARY_URL}~"$binary_url"~g \
				-e s~#{CHECKSUM}~"$checksum"~g \
				-e s~#{TARGET_ARCH}~"$alpine_binary_arch"~g $slimTemplate > $alpine_dockerfilePath/slim/Dockerfile

		mkdir -p $alpine_dockerfilePath/edge
		sed -e s~#{FROM}~"resin/$device-alpine-buildpack-deps:edge"~g \
				-e s~#{PYTHON_VERSION}~"$pythonVersion"~g \
				-e s~#{PYTHON_BASE_VERSION}~"$baseVersion"~g \
				-e s~#{BINARY_URL}~"$binary_url"~g \
				-e s~#{CHECKSUM}~"$checksum"~g \
				-e s~#{TARGET_ARCH}~"$alpine_binary_arch"~g $template > $alpine_dockerfilePath/edge/Dockerfile

		set_pythonpath "$baseVersion" "$alpine_dockerfilePath" "base edge slim" "alpine"
		set_onbuild_warning "$alpine_dockerfilePath" "base edge slim onbuild"
	done
	# Fedora
	if [[ $fedora_devices == *" $device "* ]]; then
		fedora_python_versions='2 3'
		for version in $fedora_python_versions; do
			if [ $version == "2" ]; then
				template='Dockerfile.fedora.tpl'
			else
				template='Dockerfile.fedora.python3.tpl'
			fi
			fedora_dockerfilePath=$device/fedora/$version
			mkdir -p $fedora_dockerfilePath
			sed -e s~#{FROM}~"resin/$device-fedora-buildpack-deps:latest"~g $template > $fedora_dockerfilePath/Dockerfile

			mkdir -p $fedora_dockerfilePath/23
			sed -e s~#{FROM}~"resin/$device-fedora-buildpack-deps:23"~g $template > $fedora_dockerfilePath/23/Dockerfile

			mkdir -p $fedora_dockerfilePath/onbuild
			sed -e s~#{FROM}~"resin/$device-fedora-python:$version"~g Dockerfile.onbuild.tpl > $fedora_dockerfilePath/onbuild/Dockerfile

			mkdir -p $fedora_dockerfilePath/slim
			sed -e s~#{FROM}~"resin/$device-fedora:latest"~g $template > $fedora_dockerfilePath/slim/Dockerfile

			set_onbuild_warning "$fedora_dockerfilePath" "base 23 slim onbuild"

		done
	fi
done