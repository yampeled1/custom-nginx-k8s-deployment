FROM alpine:3.2 as stage1

ENV NGINX_VERSION nginx-1.9.12
RUN apk --update add pcre-dev zlib-dev openssl-dev build-base wget && \
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    wget http://nginx.org/download/${NGINX_VERSION}.tar.gz && \
    tar -zxvf ${NGINX_VERSION}.tar.gz && \
    cd /tmp/src/${NGINX_VERSION} && \
    ./configure \
        --with-http_ssl_module \
        --prefix=/etc/nginx \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --sbin-path=/usr/local/sbin/nginx && \
    make && \
    make install

WORKDIR /etc/nginx


FROM alpine as stage2

WORKDIR /usr/local/bin
COPY --from=stage1 /usr/local/bin/nginx .
ENTRYPOINT ["su", "-", "nginx", "-c", "/bin/bash"]