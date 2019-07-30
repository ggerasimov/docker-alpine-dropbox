FROM alpine:3.10

ARG GLIBC_VERSION=2.29-r0

ARG UID=1000
ARG GID=1000

ENV LANG=C.UTF-8

RUN apk add --no-cache --update ca-certificates \
    && addgroup -g $GID user \
    && adduser -u $UID -h /home/user -s /bin/sh -D -G user user \
    && mkdir -p /home/user/.dropbox /home/user/Dropbox \
    && cd /home/user && wget -O - https://www.dropbox.com/download?plat=lnx.x86_64 | tar xzf - \
    && wget https://www.dropbox.com/download?dl=packages/dropbox.py -O /usr/local/bin/dropbox-cli \
    && wget https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -O /etc/apk/keys/sgerrand.rsa.pub \
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-$GLIBC_VERSION.apk \
            https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-bin-$GLIBC_VERSION.apk \
            https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-i18n-$GLIBC_VERSION.apk \
    && apk add --no-cache glibc-$GLIBC_VERSION.apk glibc-bin-$GLIBC_VERSION.apk glibc-i18n-$GLIBC_VERSION.apk python3 \
    && /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true \
    && echo "export LANG=$LANG" > /etc/profile.d/locale.sh \
    && chmod +x /usr/local/bin/dropbox-cli \
    && chown user:user -R /home/user/ /usr/local/bin/dropbox-cli \
    && apk del glibc-i18n \
    && rm glibc-$GLIBC_VERSION.apk glibc-bin-$GLIBC_VERSION.apk glibc-i18n-$GLIBC_VERSION.apk /etc/apk/keys/sgerrand.rsa.pub \
    && echo "Installed Dropbox version:" $(cat /home/user/.dropbox-dist/VERSION)

USER user
EXPOSE 17500
WORKDIR /home/user/Dropbox
VOLUME ["/home/user/Dropbox", "/home/user/.dropbox"]
CMD ["/home/user/.dropbox-dist/dropboxd"]
