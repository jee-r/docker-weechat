FROM alpine:3.20 as weechat-builder
LABEL stage=build

ENV HOME=/config \
  TERM=screen-256color \
  LANG=C.UTF-8

ARG WEECHAT_VERSION="stable"

RUN apk update ; \
  apk upgrade ; \
  apk add --no-cache \
    build-base \
    curl \
    gpg \
    tcl-dev \
    tcl \
    tk-dev \
    cpputest \
    guile-dev \
    aspell-dev \
    curl-dev \
    gettext-dev \
    gnutls-dev \
    libgcrypt-dev \
    lua-dev \
    ncurses-dev \
    perl-dev \
    python3-dev \
    ruby-dev \
    zlib-dev \
    zstd-dev \
    cjson-dev \
    asciidoctor \
    cmake \
    samurai ; \
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
  # build WeeChat
  mkdir -p /tmp/weechat/build ; \
  tar -xf /tmp/weechat.tar.xz -C /tmp/weechat --strip-components 1 ; \
  cd /tmp/weechat/build ; \
  cmake \
    .. \
    -DENABLE_TESTS=ON \
    -DCMAKE_INSTALL_PREFIX=/opt/weechat \
    -DENABLE_MAN=ON \
    -DENABLE_HEADLESS=ON \
    -DENABLE_JAVASCRIPT=OFF \
    -DENABLE_PHP=OFF \
  ; \
  make -j $(nproc) ; \
  make install

FROM alpine:3.20

LABEL name="docker-weechat" \
  maintainer="Jee jee@jeer.fr" \
  description="WeeChat (Wee Enhanced Environment for Chat) is a free chat client, fast and light, designed for many operating systems." \
  url="https://weechat.org" \
  org.label-schema.vcs-url="https://github.com/jee-r/docker-weechat" \
  org.opencontainers.image.source="https://github.com/jee-r/docker-weechat" 

COPY --from=weechat-builder /opt/weechat /opt/weechat

ENV HOME=/config \
  TERM=screen-256color \
  LANG=C.UTF-8

RUN apk update ; \
  apk upgrade ; \
  apk add --no-cache --virtual=base --upgrade \
    ca-certificates \
    gettext \
    gettext-dev \
    gnutls \
    gnutls-dev \
    libcurl \
    curl-dev \
    libgcrypt \
    libgcrypt-dev \
    ncurses-libs \
    ncurses-dev \
    ncurses-terminfo \
    tzdata \
    zlib \
    zlib-dev \
    zstd \
    zstd-libs \
    zstd-dev \
    cjson-dev \
    python3 \
    python3-dev \
    py3-requests \
    lua-dev \
    lua5.3-libs \
    perl \
    perl-dev \
    ruby-dev \
    ruby-libs \
    aspell-libs \
    aspell-dev ; \
  rm -rf /tmp/* /var/cache/apk/* ; \
  ln -sf /opt/weechat/bin/weechat /usr/bin/weechat ; \
  ln -sf /opt/weechat/bin/weechat-headless /usr/bin/weechat-headless

EXPOSE 8000 8002

STOPSIGNAL SIGQUIT
ENTRYPOINT ["weechat", "--dir", "/config"]
