FROM caddy:2.7.5-builder-alpine AS builder
RUN xcaddy build \
  --with github.com/greenpau/caddy-git@v1.0.9

FROM caddy:2.7.5-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
