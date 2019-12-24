FROM alpine:3.2 as stage1

ENV NGINX_VERSION nginx-1.9.12
RUN apk --update add pcre-dev zlib-dev openssl-dev build-base wget libgcc && \
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    wget http://nginx.org/download/${NGINX_VERSION}.tar.gz && \
    tar -zxvf ${NGINX_VERSION}.tar.gz && \
    cd /tmp/src/${NGINX_VERSION} && \
    ./configure \
        --user=nginx \
        --with-http_ssl_module \
        --prefix=/etc/nginx \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --sbin-path=/usr/local/sbin/nginx && \
    make && \
    make install


FROM alpine:3.2 as stage2
RUN apk --update add pcre-dev zlib-dev openssl-dev build-base
WORKDIR /usr/local/sbin
COPY --from=stage1 /usr/local/sbin .
COPY --from=stage1 /etc/nginx /etc/nginx
COPY --from=stage1 /var/log/nginx /var/log/nginx
RUN addgroup -S nginx \
    && adduser -S nginx -D -G nginx  \
    && touch /run/nginx.pid \
    && chown -R nginx:nginx /run/nginx.pid \
    && chown -R nginx:nginx /var/log/nginx \
    && chown -R nginx:nginx /etc/nginx 

USER nginx
COPY ./entrypoint.sh .
ENTRYPOINT entrypoint.sh