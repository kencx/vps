FROM alpine:3.18

RUN apk update --no-cache
RUN apk add --no-cache \
    dumb-init \
    fcgiwrap spawn-fcgi \
    cgit git openssh xz \
    python3 py3-pygments py3-markdown \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

RUN addgroup -g 1000 cgit \
    && adduser -G cgit -u 1000 cgit -D

COPY --chown=cgit:cgit cgitrc /etc/cgitrc
RUN mkdir -p /etc/cgit.d \
    && chown -R cgit:cgit /etc/cgit.d

# caching
RUN mkdir -p /var/cache/cgit \
    && chown -R cgit:cgit /var/cache/cgit \
    && chmod u+g /var/cache/cgit \
    && mkdir -p /srv/git \
    && chown -R cgit:cgit /srv/git

EXPOSE 9000
ENTRYPOINT [ "/usr/bin/dumb-init", "--" ]
CMD [ "/usr/bin/spawn-fcgi", "-u", "cgit", "-g", "cgit", "-p", "9000", "-n", "/usr/bin/fcgiwrap"]
