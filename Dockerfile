FROM debian:latest AS base

RUN set -uex; \
    apt-get update -y; \
    apt-get install apt-cacher-ng -y; \
    mv /etc/apt-cacher-ng/acng.conf /etc/apt-cacher-ng/acng.conf.original; \
    ln -sf /dev/stdout /var/log/apt-cacher-ng/apt-cacher.log; \
    ln -sf /dev/stderr /var/log/apt-cacher-ng/apt-cacher.err; \
    apt-get clean all; \
    rm -rf /var/lib/apt/lists/*;

COPY files/* /etc/apt-cacher-ng/

LABEL org.label-schema.name="digitalsparky/apt-cacher-ng" \
      org.label-schema.version="1.6.1" \
      org.label-schema.vendor="digitalsparky" \
      org.label-schema.docker.cmd="docker run --restart always -d -v apt-cacher-ng-vol:/var/cache/apt-cacher-ng:rw -p 3142:3142 digitalsparky/apt-cacher-ng" \
      org.label-schema.url="https://github.com/digitalsparky/docker-apt-cacher-ng" \
      org.label-schema.vcs-url="https://github.com/digitalsparky/docker-apt-cacher-ng.git" \
      org.label-schema.schema-version="1.0"

FROM base AS localised
ARG locale=""
ENV ACNG_LOCALE=$locale
RUN set -uex; \
    if [ -n "$ACNG_LOCALE" ]; then \
      if [ -f "/etc/apt-cacher-ng/acng.conf.$ACNG_LOCALE" ]; then \
        cp /etc/apt-cacher-ng/acng.conf.$ACNG_LOCALE /etc/apt-cacher-ng/acng.conf; \
      fi \
    fi;

FROM localised
EXPOSE 3142
VOLUME ["/var/cache/apt-cacher-ng"]

ENTRYPOINT ["/usr/sbin/apt-cacher-ng"]
CMD ["-c","/etc/apt-cacher-ng"]