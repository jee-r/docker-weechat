FROM alpine:3.17 as builder
LABEL stage=build

ENV HOME=/config \
    TERM=screen-256color \
    LANG=C.UTF-8

ARG WEECHAT_VERSION="3.7.1"


RUN set -eux ; \
    # install download/build dependencies
    apk add --no-cache \
        asciidoctor \
        cmake \
        curl \
        curl-dev \
        g++ \
        gcc \
        gettext-dev \
        gnupg \
        gnutls-dev \
        libgcrypt-dev \
        make \
        ncurses-dev \
        pkgconf \
        xz \
        zlib-dev \
        zstd-dev \
        argon2-dev \
        aspell-dev \
        guile-dev \
        libxml2-dev \
        lua5.3-dev \
        perl-dev \
        php8-dev \
        php8-embed \
        python3-dev \
        ruby-dev \
        tcl-dev ; \
    # download WeeChat
    cd /tmp ; \
    curl -o weechat.tar.xz "https://weechat.org/files/src/weechat-${WEECHAT_VERSION}.tar.xz" ; \
    if [ "$WEECHAT_VERSION" != "devel" ] ; then \
        curl -o weechat.tar.xz.asc "https://weechat.org/files/src/weechat-${WEECHAT_VERSION}.tar.xz.asc" ; \
        export GNUPGHOME="$(mktemp -d)" ; \
        gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys A9AB5AB778FA5C3522FD0378F82F4B16DEC408F8 ; \
        gpg --batch --verify /tmp/weechat.tar.xz.asc /tmp/weechat.tar.xz ; \
        gpgconf --kill all ; \
    fi ; \
    \
    # build WeeChat
    mkdir -p /tmp/weechat/build ; \
    tar -xf /tmp/weechat.tar.xz -C /tmp/weechat --strip-components 1 ; \
    cd /tmp/weechat/build ; \
    cmake \
      .. \
      -DCMAKE_INSTALL_PREFIX=/opt/weechat \
      -DENABLE_MAN=ON \
      -DENABLE_HEADLESS=ON \
    ; \
    make -j $(nproc) ; \
    make install

FROM builder as weechat-matrix-builder
LABEL stage=build
WORKDIR /tmp

COPY build/weechat-matrix .

RUN apk update ; \
    apk add --no-cache abuild ; \
    abuild-keygen -a -n ; \
    REPODEST=/tmp/out abuild -F -r

FROM alpine:3.17

LABEL name="docker-weechat" \
      maintainer="Jee jee@jeer.fr" \
      description="WeeChat (Wee Enhanced Environment for Chat) is a free chat client, fast and light, designed for many operating systems." \
      url="https://weechat.org" \
      org.label-schema.vcs-url="https://github.com/jee-r/docker-weechat" \
			org.opencontainers.image.source="https://github.com/jee-r/docker-weechat" 

ENV HOME=/config \
    TERM=screen-256color \
    LANG=C.UTF-8

COPY --from=builder /opt/weechat /opt/weechat
COPY --from=weechat-matrix-builder /tmp/out/*/*.apk /pkgs/

RUN apk update ; \
    apk upgrade ; \
    apk add --no-cache --virtual=base --upgrade \
      ca-certificates \
      gettext \
      gnutls \
      libcurl \
      libgcrypt \
      ncurses-libs \
      ncurses-terminfo \
      tzdata \
      zlib \
      zstd \
      zstd-libs \
      aspell-libs \
      guile \
      guile-libs \
      lua5.3-libs \
      perl \
      php8 \
      php8-embed \
      python3 \
      ruby-libs \
      tcl ; \
		apk add --no-cache --allow-untrusted /pkgs/* ; \
    rm -rf /tmp/* /var/cache/apk/* ; \
		ln -sf /opt/weechat/bin/weechat /usr/bin/weechat ; \
		ln -sf /opt/weechat/bin/weechat-headless /usr/bin/weechat-headless

EXPOSE 8000 8002

STOPSIGNAL SIGQUIT
ENTRYPOINT ["weechat", "--dir", "/config"]
