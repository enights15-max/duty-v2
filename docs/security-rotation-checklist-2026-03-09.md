# Checklist de Rotacion de Secretos (2026-03-09)

## Cambios aplicados en codigo
- [x] `public/config.php` migrado a lectura por variables de entorno.
- [x] `STRIPE_SECRET_KEY` removida de codigo versionado.
- [x] Service-account JSON en `public/assets/file/6999f02c63fd0.json` reemplazado por plantilla sin llave privada real.
- [x] `flutter/cliente_v2/lib/core/services/stripe_service.dart` sin secret key hardcodeada.
- [x] `.env` removido del indice de git (sigue local, deja de versionarse).
- [x] Gate de secretos activo (`scripts/security/secret-scan.sh`) en pre-push, pre-receive y CI (`security-secret-scan.yml`).
- [x] Endpoint legacy `public/pgw/create-payment-intent.php` deshabilitado por defecto (`ENABLE_LEGACY_PGW=0`).
- [x] Preflight local de rotacion agregado (`scripts/security/rotation-preflight.sh`) para detectar faltantes/placeholders antes de cambios en entorno.
- [x] `.env.example` alineado al modo Stripe-only para preparar rotacion sin ruido de gateways retirados.
- [x] Orquestador de ventana de rotacion agregado (`scripts/security/rotation-window-check.sh`) para ejecutar preflight estricto + scans + health checks en un solo comando.

## Acciones operativas requeridas (fuera de repo)
- [ ] Rotar llaves Stripe (secret + webhook + publishable si aplica).
- [ ] Rotar credenciales Firebase service account comprometida.
- [ ] Rotar credenciales Stripe en `public/config.php` y entorno seguro (`STRIPE_SECRET_KEY`, `STRIPE_SECRET`, `STRIPE_WEBHOOK_SECRET`, `STRIPE_KEY` si aplica).
- [ ] Cargar secretos rotados en entorno productivo/staging.
- [ ] Invalidar llaves anteriores y auditar accesos.
- [ ] Ejecutar `./scripts/security/rotation-preflight.sh --strict --env-file <env_objetivo> --scope stripe` antes de cada ventana de rotacion.
- [ ] Ejecutar `./scripts/security/rotation-window-check.sh --env-file <env_objetivo> --scope stripe --base-url <url> --auth-token <token> --require-live` durante la ventana operativa (alternativa: `--auth-username <user> --auth-password <pass>` para resolver token automaticamente; si `<url>` es dominio publico, agregar `--allow-public-base-url`).

## Verificacion posterior a rotacion
- [ ] Health check de checkout Stripe (create intent + topup-status + topup-confirm + webhook).
- [ ] Health check de wallet customer (`/customers/wallet`) y guardado de tarjetas (`/customers/payment-methods/setup-intent`).
- [ ] Smoke de Stripe en produccion (automatizado por `post-rotation-health-check.sh` via `/api/get-basic` + `/api/event/verify-payment`).
- [ ] Ejecutar `scripts/security/post-rotation-health-check.sh` con `DUTY_APP_BASE_URL` + `DUTY_AUTH_TOKEN` del entorno rotado.
- [ ] Ejecutar `./scripts/security/final-live-readiness.sh --env-file <env_objetivo> --base-url <url> --auth-token <token> --final-scope stripe --report-dir <artifact_dir>` (alternativa: `--auth-username <user> --auth-password <pass>`; si `<url>` es dominio publico, agregar `--allow-public-base-url`). Este comando deja bundle de evidencia con resumen `GO / NO-GO`, `manual-evidence.md` y logs por scope.
- [ ] Convertir el bundle a board operativo con `./scripts/security/render-live-go-no-go-board.sh --report-dir <artifact_dir> --output <md_board>`.
- [ ] Para staging/pre-live, preferir `./scripts/security/staging-live-readiness-dry-run.sh ...` si quieres bundle + board en una sola ejecución.
- [x] Confirmar `php artisan route:list` y smoke tests en verde.
