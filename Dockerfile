FROM alpine:edge

ARG AUUID="31034190-cfde-47c0-98fc-b71416d3c97a"
ARG CADDYIndexPage="https://github.com/AYJCSGM/mikutap/archive/master.zip"
ARG ParameterSSENCYPT="chacha20-ietf-poly1305"
ARG PORT=8080

ADD etc/Caddyfile /tmp/Caddyfile
ADD etc/xray.json /tmp/xray.json
ADD start.sh /start.sh

RUN apk update && \
    apk add --no-cache ca-certificates caddy tor wget unzip && \
    wget -O /xray https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64 && \
    chmod +x /xray && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /etc/caddy/ /usr/share/caddy && \
    echo -e "User-agent: *\nDisallow: /" > /usr/share/caddy/robots.txt && \
    wget $CADDYIndexPage -O /usr/share/caddy/index.html && \
    unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && \
    mv /usr/share/caddy/*/* /usr/share/caddy/ && \
    cat /tmp/Caddyfile | sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" > /etc/caddy/Caddyfile && \
    cat /tmp/xray.json | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$ParameterSSENCYPT/$ParameterSSENCYPT/g" > /xray.json

RUN chmod +x /start.sh

CMD ["/start.sh"]
