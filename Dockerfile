FROM alpine:3.23 AS weechat-builder
LABEL stage=build

ENV HOME=/config \
  TERM=screen-256color \
  LANG=C.UTF-8

ARG WEECHAT_VERSION="4.8.1"

RUN set -eux; \
  apk update ; \
  apk upgrade ; \
  apk add --no-cache \
    build-base \
    gnupg \
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
    lua5.4-dev \
    ncurses-dev \
    perl-dev \
    python3-dev \
    ruby-dev \
    zlib-dev \
    zstd-dev \
    cjson-dev \
    asciidoctor \
    cmake \
    samurai

# Get, verify and extract Weechat
WORKDIR /tmp
RUN set -eux; \
    curl -o weechat.tar.xz "https://weechat.org/files/src/weechat-${WEECHAT_VERSION}.tar.xz"; \
    if [ "$WEECHAT_VERSION" != "devel" ]; then \
        curl -o weechat.tar.xz.asc "https://weechat.org/files/src/weechat-${WEECHAT_VERSION}.tar.xz.asc"; \
        export GNUPGHOME="$(mktemp -d)"; \
        # Import key without triggering gpg-agent
        gpg --batch --no-tty --pinentry-mode loopback \
            --keyserver hkps://keys.openpgp.org \
            --recv-keys A9AB5AB778FA5C3522FD0378F82F4B16DEC408F8; \
        # Verify tarball
        gpg --batch --no-tty --pinentry-mode loopback --trust-model always \
            --verify weechat.tar.xz.asc weechat.tar.xz; \
        rm -rf "$GNUPGHOME"; \
    fi; \
    mkdir -p /tmp/weechat/build; \
    tar -xf /tmp/weechat.tar.xz -C /tmp/weechat --strip-components 1

# Build Weechat
WORKDIR /tmp/weechat/build 
RUN set -eux; \
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

# Build final image
FROM alpine:3.23

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

RUN set -eux; \
  apk update ; \
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
    lua5.4-dev \
    lua5.4-libs \
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
ENTRYPOINT ["weechat-headless", "--dir", "/config"]
