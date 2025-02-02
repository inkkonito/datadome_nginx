#!/bin/bash

apt-get install -yq curl 

# Create a temporary directory to work in
tmp_dir=$(mktemp -d -t datadome-XXXXXXXXXX)
echo $tmp_dir

# Get the Nginx version in use
nginx_version=$(nginx -v 2>&1 | grep -oP 'nginx\/\K([0-9.]*)')
echo $nginx_version

# Download and untar the Nginx sources to compile dynamic module
curl -sLo ${tmp_dir}/nginx-${nginx_version}.tar.gz http://nginx.org/download/nginx-${nginx_version}.tar.gz
tar -C ${tmp_dir} -xzf ${tmp_dir}/nginx-${nginx_version}.tar.gz

# Download and untar DataDome module sources
curl -sLo ${tmp_dir}/datadome_nginx_module.tar.gz https://package.datadome.co/linux/DataDome-Nginx-latest.tgz
tar -C ${tmp_dir} -zxf ${tmp_dir}/datadome_nginx_module.tar.gz

# Get the name of the DataDome module directory
datadome_dir=$(basename $(ls ${tmp_dir}/DataDome-NginxDome-* -d1))

# Get the compilation flags used during the compilation of nginx, and remove any --add-dynamic-module flag we find
# This is important because when compiling the modules, you have to use the same flags that have been used when compiling nginx
nginx_flags="$(nginx -V 2>&1 | grep -oP 'configure arguments: \K(.*)' | sed -e 's/--add-dynamic-module=\S*//g')"
echo $nginx_flags

# Launch the nginx configure script with same flags + the DataDome dynamic module
cd ${tmp_dir}/nginx-${nginx_version} && eval "./configure --with-debug --add-dynamic-module=../${datadome_dir} ${nginx_flags}"

# Compile the modules
make -C ${tmp_dir}/nginx-${nginx_version} -f objs/Makefile modules

# Ensure Nginx module directory is created
mkdir -p /etc/nginx/modules

# Copy the .so modules to nginx configuration
cp ${tmp_dir}/nginx-${nginx_version}/objs/ngx_http_data_dome_*.so /etc/nginx/modules/
