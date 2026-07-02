---
name: laravel-docker
description: Opinionated Docker setup for Laravel — dev with Sail, production multi-stage image (php-fpm+nginx or FrankenPHP/Octane). Use when containerizing a Laravel app or writing a Dockerfile/compose for it.
---

# Dockerizing Laravel (opinionated)

## Dev vs prod — don't share one image
- **Dev**: use **Laravel Sail** (`php artisan sail:install`) unless you have a reason not to.
  It gives app + DB + redis + mailpit with zero hand-written Dockerfile. Don't reinvent it.
- **Prod**: a slim, multi-stage, non-root image. Two good choices:
  - **php-fpm + nginx** — battle-tested, explicit. Default if unsure.
  - **FrankenPHP (+ Octane)** — single binary, faster, worker mode. Use when you want Octane.

## Production rules
- **Multi-stage**: build assets (node) + composer deps in builder stages, copy only artifacts
  into a minimal runtime. Final image has no node, no dev composer deps.
- **`composer install --no-dev --optimize-autoloader`**. Run `config:cache`, `route:cache`,
  `event:cache`, `view:cache` at build time (NOT `config:cache` if env varies per deploy — cache at boot then).
- **Non-root user.** Storage + bootstrap/cache writable by it.
- **No secrets baked in** — env injected at runtime. `.dockerignore` excludes `.env`, `node_modules`, `vendor`, `.git`, `tests`.
- **Migrations are a deploy step**, not a container entrypoint side effect, unless single-instance.
- One process per container. Queue workers + scheduler are **separate** services from the web container.

## Minimal prod Dockerfile (php-fpm)
```dockerfile
# ---- assets ----
FROM node:22-alpine AS assets
WORKDIR /app
COPY package*.json vite.config.* ./
RUN npm ci
COPY resources resources
COPY . .
RUN npm run build

# ---- composer deps ----
FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-scripts --optimize-autoloader --no-interaction

# ---- runtime ----
FROM php:8.4-fpm-alpine AS app
RUN apk add --no-cache libpng libzip icu \
 && docker-php-ext-install pdo_mysql bcmath gd zip intl opcache
WORKDIR /var/www
COPY --chown=www-data:www-data . .
COPY --from=vendor /app/vendor ./vendor
COPY --from=assets /app/public/build ./public/build
USER www-data
EXPOSE 9000
CMD ["php-fpm"]
```
Pair with an nginx container serving `public/` and proxying `*.php` to `app:9000`.

## compose (prod-ish) — separate concerns
```yaml
services:
  app:        { build: ., depends_on: [db, redis] }        # php-fpm
  web:        { image: nginx:alpine, ports: ["80:80"], depends_on: [app] }
  queue:      { build: ., command: php artisan queue:work --tries=3 }
  scheduler:  { build: ., command: php artisan schedule:work }
  db:         { image: mysql:8 }
  redis:      { image: redis:7 }
```

## ponytail check
Need queue + scheduler + horizon? Add them as you actually use them — don't pre-wire
services you don't run yet. Sail already covers all of dev; only write a Dockerfile when you ship.
