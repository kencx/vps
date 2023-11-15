FROM caddy:2.7.5-builder-alpine AS builder
RUN xcaddy build \
    --with github.com/greenpau/caddy-git=github.com/kencx/caddy-git@force-pull \
    --with github.com/caddy-dns/cloudflare

FROM caddy:2.7.5-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
