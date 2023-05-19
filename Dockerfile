FROM alpine:3.18

LABEL name="docker-weechat" \
      maintainer="Jee jee@jeer.fr" \
      description="WeeChat (Wee Enhanced Environment for Chat) is a free chat client, fast and light, designed for many operating systems." \
      url="https://weechat.org" \
      org.label-schema.vcs-url="https://github.com/jee-r/docker-weechat" \
			org.opencontainers.image.source="https://github.com/jee-r/docker-weechat" 

ENV HOME=/config \
    TERM=screen-256color \
    LANG=C.UTF-8

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
      python3 \
      python3-dev \
      py3-requests \
      ruby-libs \
      tcl \
      weechat  \
      weechat-lang \
      weechat-lua \
      weechat-perl \
      weechat-python \
      weechat-ruby \
      weechat-spell; \
    rm -rf /tmp/* /var/cache/apk/* 

EXPOSE 8000 8002

STOPSIGNAL SIGQUIT
ENTRYPOINT ["weechat", "--dir", "/config"]
