ARG TRAEFIK_VERSION=2.2.4
FROM traefik:${TRAEFIK_VERSION}
COPY myentrypoint.sh /
VOLUME [ "/data" ]
ENTRYPOINT [ "/myentrypoint.sh" ]
