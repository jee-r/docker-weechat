FROM alpine:3.14

LABEL name="docker-weechat" \
      maintainer="Jee jee@jeer.fr" \
      description="WeeChat (Wee Enhanced Environment for Chat) is a free chat client, fast and light, designed for many operating systems." \
      url="https://weechat.org" \
      org.label-schema.vcs-url="https://github.com/jee-r/docker-weechat"

ENV HOME=/config \
    TERM=screen-256color \
    LANG=C.UTF-8

RUN apk update && \
    apk upgrade && \
    apk add --no-cache --upgrade \
      weechat \
      weechat-python \
      weechat-lua \
      weechat-perl \
      weechat-ruby \
      weechat-spell \
      tzdata && \
    rm -rf /tmp/* /var/cache/apk/*

EXPOSE 8000 8002

STOPSIGNAL SIGQUIT
ENTRYPOINT ["weechat", "--dir", "/config"]
