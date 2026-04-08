# DUTY cPanel Production .env Template

Fecha: 2026-04-08
Objetivo: preparar un `.env` de producción limpio para cPanel sin copiar secretos del entorno local.
Estado: listo para rellenar

## Uso
1. crea el archivo `.env` en el servidor
2. usa esta plantilla como base
3. completa solo con valores reales del servidor
4. no copies secretos del `.env` local de desarrollo

## Plantilla sugerida
```dotenv
APP_NAME="DUTY"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://TU_DOMINIO
APP_TIMEZONE=America/Santo_Domingo

LOG_CHANNEL=stack
LOG_LEVEL=warning

DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=TU_BASE
DB_USERNAME=TU_USUARIO_DB
DB_PASSWORD=TU_PASSWORD_DB

BROADCAST_DRIVER=log
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=TU_SMTP_HOST
MAIL_PORT=587
MAIL_USERNAME=TU_SMTP_USER
MAIL_PASSWORD=TU_SMTP_PASSWORD
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=no-reply@TU_DOMINIO
MAIL_FROM_NAME="${APP_NAME}"

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_APP_CLUSTER=mt1

MIX_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
MIX_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"

STRIPE_KEY=TU_STRIPE_PUBLISHABLE_KEY
STRIPE_SECRET=TU_STRIPE_SECRET_KEY
STRIPE_WEBHOOK_SECRET=TU_STRIPE_WEBHOOK_SECRET

DUTY_IOS_APP_URL=https://apps.apple.com/app/idTU_APP_ID
DUTY_ANDROID_APP_URL=https://play.google.com/store/apps/details?id=com.duty.monkey
DUTY_APP_DEEP_LINK_BASE=duty://
DUTY_ALLOW_PUBLIC_BASE_URL=0
ENABLE_LEGACY_PGW=0

PUBLIC_API_BASE=https://TU_DOMINIO/pgw

FACEBOOK_CLIENT_ID=
FACEBOOK_CLIENT_SECRET=
FACEBOOK_CALLBACK_URL=

GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_CALLBACK_URL=

GOOGLE_MAP_API_KEY=
FIREBASE_WEB_API_KEY=
NFC_SECRET=
VAPID_PUBLIC_KEY=
VAPID_PRIVATE_KEY=

COOKIE_CONSENT_ENABLED=true
SANCTUM_STATEFUL_DOMAINS=TU_DOMINIO,www.TU_DOMINIO
SESSION_DOMAIN=.TU_DOMINIO
SESSION_SECURE_COOKIE=true
```

## Variables obligatorias para arrancar
### Core
1. `APP_NAME`
2. `APP_ENV`
3. `APP_KEY`
4. `APP_DEBUG`
5. `APP_URL`
6. `APP_TIMEZONE`

### Base de datos
1. `DB_CONNECTION`
2. `DB_HOST`
3. `DB_PORT`
4. `DB_DATABASE`
5. `DB_USERNAME`
6. `DB_PASSWORD`

### Mail
1. `MAIL_MAILER`
2. `MAIL_HOST`
3. `MAIL_PORT`
4. `MAIL_USERNAME`
5. `MAIL_PASSWORD`
6. `MAIL_ENCRYPTION`
7. `MAIL_FROM_ADDRESS`
8. `MAIL_FROM_NAME`

### Stripe
1. `STRIPE_KEY`
2. `STRIPE_SECRET`
3. `STRIPE_WEBHOOK_SECRET`

### Mobile / links
1. `DUTY_IOS_APP_URL`
2. `DUTY_ANDROID_APP_URL`
3. `DUTY_APP_DEEP_LINK_BASE`

### Otros sensibles
1. `GOOGLE_MAP_API_KEY`
2. `NFC_SECRET`
3. `VAPID_PUBLIC_KEY`
4. `VAPID_PRIVATE_KEY`

## Variables opcionales o según setup
1. `PUSHER_*`
2. `FACEBOOK_*`
3. `GOOGLE_*`
4. `FIREBASE_WEB_API_KEY`
5. `PUBLIC_API_BASE`

## Recomendaciones para este release
### 1.0
Para `1.0`, si no vas a usar gateways legacy, mantén:

```dotenv
ENABLE_LEGACY_PGW=0
```

### Stripe-only
Si el release es Stripe-only, no rellenes claves de gateways viejos como:
1. `MOLLIE_*`
2. `PAYTM_*`
3. `MYFATOORAH_*`
4. `FLW_*`
5. `XENDIT_*`

salvo que tu servidor realmente las siga necesitando por compatibilidad.

## Cómo generar APP_KEY
Si el `.env` ya está en servidor y `APP_KEY` está vacío:

```bash
php artisan key:generate --force
```

## Comandos recomendados después de guardar el .env
```bash
php artisan optimize:clear
php artisan config:clear
php artisan migrate:status
php artisan migrate --force
php artisan storage:link
php artisan view:cache
```

## Validación mínima
Después de configurar el `.env`:
1. abre home
2. prueba login admin
3. valida listado de eventos
4. valida detalle evento
5. valida checkout básico

## Errores comunes a evitar
1. dejar `APP_DEBUG=true`
2. dejar `APP_URL=http://localhost`
3. copiar secretos del entorno local por accidente
4. olvidar `SESSION_DOMAIN` y `SESSION_SECURE_COOKIE`
5. usar claves de Stripe de prueba en producción
6. dejar `PUBLIC_API_BASE` apuntando al dominio equivocado
