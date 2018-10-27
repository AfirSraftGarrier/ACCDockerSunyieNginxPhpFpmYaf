FROM centos:7.5.1804
MAINTAINER the acc xy server <afirsraftgarrier@qq.com>

# 安装不需要输入确认Y
RUN yum -y install git bzip2 bzip2-devel wget vim pcre pcre-devel openssl openssl-devel libicu-devel gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel ncurses ncurses-devel curl curl-devel krb5-devel libidn libidn-devel openldap openldap-devel nss_ldap jemalloc-devel cmake boost-devel bison automake libevent libevent-devel gd gd-devel libtool* libmcrypt libmcrypt-devel mcrypt mhash libxslt libxslt-devel readline readline-devel gmp gmp-devel libcurl libcurl-devel openjpeg-devel; \
cp -frp /usr/lib64/libldap* /usr/lib/; \
# 创建php-fpm用户
groupadd php-fpm; \
useradd -s /sbin/nologin -g php-fpm -M php-fpm; \
cd /; \
mkdir acc; cd acc; \
mkdir install; cd install; \
wget http://us1.php.net/distributions/php-7.2.11.tar.gz; \
tar -zxvf php-7.2.11.tar.gz; \
cd php-7.2.11; \
./configure \
--prefix=/usr/local/php \
--with-config-file-path=/usr/local/php/etc \
--with-zlib-dir \
--with-freetype-dir \
--enable-mbstring \
--with-libxml-dir=/usr \
# --enable-xmlreader \
# --enable-xmlwriter \
--enable-soap \
--enable-calendar \
--with-curl \
--with-zlib \
--with-gd \
--with-pdo-sqlite \
--with-pdo-mysql \
--with-mysqli \
--with-mysql-sock \
--enable-mysqlnd \
--disable-rpath \
--enable-inline-optimization \
--with-bz2 \
--with-zlib \
--enable-sockets \
--enable-sysvsem \
--enable-sysvshm \
--enable-pcntl \
--enable-mbregex \
--enable-exif \
--enable-bcmath \
--with-mhash \
--enable-zip \
--with-pcre-regex \
--with-jpeg-dir=/usr \
--with-png-dir=/usr \
--with-openssl \
--enable-ftp \
--with-kerberos \
--with-gettext \
--with-xmlrpc \
--with-xsl \
--enable-fpm \
--with-fpm-user=php-fpm \
--with-fpm-group=php-fpm \
# --with-fpm-systemd \
--disable-fileinfo; \
make -j 4 && make install; \
cp php.ini-development /usr/local/php/etc/php.ini; \
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf; \
cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf; \
cd ..;\

# 下载并安装nginx
wget http://nginx.org/download/nginx-1.15.5.tar.gz; \
tar -zxvf nginx-1.15.5.tar.gz; \
cd nginx-1.15.5; \
./configure --with-http_ssl_module; \
make && make install; \
cd ..; \
# 删掉php和nginx安装文件
rm -rf *; \
# 删除安装缓存
rm -rf /var/cache/*; \

# 增加开机脚本的可执行权限
# chmod 755 /etc/rc.local; \
# 将开机脚本放到开机执行文件中
# echo "/acc/shell/start.sh" >> /etc/rc.local; \
echo "export PATH=$PATH:/usr/local/nginx/sbin/:/usr/local/php/sbin/:/usr/local/php/bin:/var/www/ACCDOCKER/docker/" >> /root/.bashrc; \

# 将启动执行脚本拷贝到image中
# ADD ./start.sh /acc/shell/start.sh
# 增加可执行权限
# RUN chmod 755 /acc/shell/start.sh
# 开机启动脚本
# CMD ["/bin/bash", "/acc/shell/start.sh"]

# 修改nginx配置
sed '${ x; s,.*,include /var/www/NGINX-CONFIG/*.conf;,p; x; }' /usr/local/nginx/conf/nginx.conf >> /usr/local/nginx/conf/nginx.conf.bak; \
mv /usr/local/nginx/conf/nginx.conf.bak /usr/local/nginx/conf/nginx.conf; \
# 修改php配置，以支持php-fpm重启
sed -ie 's/;pid/pid/g'  /usr/local/php/etc/php-fpm.conf; \
# 安装yaf
/usr/local/php/bin/pecl install yaf; \
echo "extension=yaf.so" >> /usr/local/php/etc/php.ini; \
# 安装mysql支持旧版本的mysql_connect
git clone https://github.com/php/pecl-database-mysql mysql --recursive; \
cd mysql/; \
/usr/local/php/bin/phpize; \
./configure --with-php-config=/usr/local/php/bin/php-config; \
make && make install; \
echo "extension=mysql.so" >> /usr/local/php/etc/php.ini; \
# 清除安装文件
cd ..; rm -rf mysql; rm -rf /tmp/*;
