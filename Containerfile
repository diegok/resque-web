# syntax=docker/dockerfile:1

# ---------------------------------------------------------------------------
# Stage 1: build the Vue 3 frontend into lib/Resque/Web/public
# ---------------------------------------------------------------------------
FROM docker.io/node:22-trixie-slim AS frontend

WORKDIR /app/client

# Install deps first (better layer caching)
COPY client/package.json client/yarn.lock ./
RUN yarn install --frozen-lockfile

# Build the SPA. vue.config.js outputDir is '../lib/Resque/Web/public',
# so the assets land in /app/lib/Resque/Web/public.
COPY client/ ./
RUN mkdir -p /app/lib/Resque/Web/public && yarn build

# ---------------------------------------------------------------------------
# Stage 2: Perl/Mojolicious runtime serving the API + built SPA
# ---------------------------------------------------------------------------
FROM docker.io/perl:5.42-trixie AS runtime

ARG VERSION=0.1.0

# OCI image metadata (shown by registries)
LABEL org.opencontainers.image.title="resque-web" \
      org.opencontainers.image.description="Mojolicious + Vue web UI for Resque (Perl)" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.source="https://github.com/gonzalo-radio/resque-web" \
      org.opencontainers.image.licenses="Perl-5"

# Run Mojolicious in production mode (quieter logs, production defaults)
ENV MOJO_MODE=production

WORKDIR /app

# Perl deps + the Mojolicious optional modules. JSON::XS is essential: without it
# Resque::Encoder falls back to JSON::PP, whose utf8 decoder is quadratic on
# non-ASCII input and wedges the workers sub-tasks on multi-MB payloads.
RUN cpanm --notest --no-man-pages Mojolicious Resque Redis JSON::XS \
        EV Cpanel::JSON::XS IO::Socket::SSL Net::DNS::Native IO::Socket::Socks \
        Role::Tiny Future::AsyncAwait \
    && rm -rf /root/.cpanm

# Backend source
COPY lib/ ./lib/
COPY script/ ./script/

# Built frontend from stage 1
COPY --from=frontend /app/lib/Resque/Web/public ./lib/Resque/Web/public

# Point the app at redis (see setup_plugins in lib/Resque/Web.pm). The config
# reads $RESQUE_REDIS / $RESQUE_NAMESPACE at runtime, so a published image can
# target any redis without rebuilding.
COPY container/resque-web.conf /etc/resque-web.conf

# Drop privileges: the app only reads world-readable files, writes nothing to
# disk and binds a port > 1024, so it runs fine as an unprivileged user.
RUN useradd --system --no-create-home --uid 10001 appuser
USER appuser

EXPOSE 8888

# Liveness probe via core Perl (no curl dependency).
# NOTE: podman only records HEALTHCHECK when building with `--format docker`
# (the default OCI format drops it); image.mk passes that flag.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD perl -MHTTP::Tiny -e 'exit(HTTP::Tiny->new(timeout=>3)->get("http://127.0.0.1:8888/ping")->{success} ? 0 : 1)'

# prefork = multi-worker server, appropriate for production
CMD ["perl", "script/resque-web", "prefork", "-l", "http://*:8888"]
