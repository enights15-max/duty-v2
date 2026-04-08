# Sprint 1 - Live Cutover Checklist

Fecha de preparación: 2026-03-18
Entorno objetivo: staging/live
Estado actual: listo en local, pendiente credenciales Stripe y validación live

## 1. Estado base ya validado

### Gates locales en verde

- `/Users/monkeyinteractive/DEV/v2/scripts/ops/prepare-launch-manual-qa.sh` -> `OK`
- `/Users/monkeyinteractive/DEV/v2/scripts/ops/local-e2e-check.sh` -> `33 passed, 0 failed`
- `/Users/monkeyinteractive/DEV/v2/scripts/ops/launch-core-feature-smoke.sh` -> `20 passed, 0 failed`
- `/Users/monkeyinteractive/DEV/v2/scripts/ops/nonstop-closeout.sh` -> `PASS`

### QA local lista

- customer: `qa_e2e_customer / Qa123456!`
- admin: `qa_e2e_admin / QaAdmin123!`

Referencia de estado:
- [/Users/monkeyinteractive/DEV/v2/docs/sprint-1-live-readiness-board-2026-03-18.md](/Users/monkeyinteractive/DEV/v2/docs/sprint-1-live-readiness-board-2026-03-18.md)

## 2. Bloqueos reales para cutover live

Resultado de:

```bash
./scripts/security/rotation-preflight.sh
```

### Credenciales faltantes

- `STRIPE_KEY`
- `STRIPE_SECRET`
- `STRIPE_WEBHOOK_SECRET`
- `STRIPE_SECRET_KEY`

### Valores de prueba que no deben pasar a live

- `STRIPE_SECRET`
- `STRIPE_SECRET_KEY`

### Nota

- Firebase sigue correctamente sanitizado en repo. La clave real debe inyectarse por entorno seguro.

## 3. Checklist de ventana live

### Antes de tocar secretos

- `[ ]` Confirmar que Stripe será el único gateway activo en live.
- `[ ]` Confirmar base URL final para health checks.
- `[ ]` Confirmar token o credenciales reales para smoke post-rotación.
- `[ ]` Confirmar backup / snapshot previo si aplica.

### Rotación

- `[ ]` Inyectar las claves reales de Stripe faltantes.
- `[ ]` Reemplazar cualquier clave Stripe de prueba por claves reales.
- `[ ]` Verificar que `.env`/secret manager no dejó placeholders.

### Preflight estricto

Ejecutar:

```bash
./scripts/security/rotation-preflight.sh --strict
```

Aceptar si:
- `Missing keys = 0`
- `Placeholder-like values = 0`
- `Test-value warnings = 0`

### Ventana completa de verificación

Ejecutar con URL/token reales:

```bash
./scripts/security/rotation-window-check.sh \
  --base-url "https://TU_BASE_URL" \
  --auth-token "TOKEN_REAL" \
  --require-live \
  --allow-public-base-url
```

O con login:

```bash
./scripts/security/rotation-window-check.sh \
  --base-url "https://TU_BASE_URL" \
  --auth-username "USUARIO_REAL" \
  --auth-password "PASSWORD_REAL" \
  --require-live \
  --allow-public-base-url
```

Aceptar si:
- preflight estricto pasa
- secret scan pasa
- wallet smoke pasa
- setup-intent pasa
- topup intent/status/confirm pasan
- verify-payment responde correctamente para Stripe

### Evidencia final automatizada

Ejecutar al cierre de la ventana para dejar bundle de evidencia:

```bash
./scripts/security/final-live-readiness.sh \
  --env-file .env \
  --base-url "https://TU_BASE_URL" \
  --auth-token "TOKEN_REAL" \
  --final-scope stripe \
  --allow-public-base-url \
  --report-dir "storage/app/live-readiness/final-cutover-$(date +%Y%m%d_%H%M%S)"
```

Si es una ventana de staging o pre-live y quieres correr bundle + board en un solo paso:

```bash
./scripts/security/staging-live-readiness-dry-run.sh \
  --env-file .env \
  --base-url "https://staging.example.com" \
  --auth-token "TOKEN_REAL" \
  --final-scope stripe \
  --allow-public-base-url
```

El bundle deja:
- `README.md` con resumen `GO / NO-GO` automatizado
- `summary.json`
- `manual-evidence.md`
- logs por scope ejecutado

Para convertir ese bundle en board de decisión:

```bash
./scripts/security/render-live-go-no-go-board.sh \
  --report-dir "storage/app/live-readiness/final-cutover-YYYYMMDD_HHMMSS" \
  --output "docs/live-go-no-go-board.md"
```

Guardar además:
- evidencia manual complementaria
- responsable de la ventana
- decisión final de salida

## 4. QA manual live mínima

Usar como guía:
- [/Users/monkeyinteractive/DEV/v2/docs/qa-manual-lanzamiento-local-2026-03-12.md](/Users/monkeyinteractive/DEV/v2/docs/qa-manual-lanzamiento-local-2026-03-12.md)

Priorizar en live:

- `[ ]` login/session
- `[ ]` checkout mixto real
- `[ ]` wallet + topup real
- `[ ]` reservas y abonos
- `[ ]` scanner
- `[ ]` loyalty redemptions
- `[ ]` follow/unfollow organizer
- `[ ]` create/edit event con authoring profesional

## 5. Criterio de salida de Sprint 1

Sprint 1 puede darse por cerrado para live cuando:

- `[ ]` preflight estricto verde
- `[ ]` rotation window check verde
- `[ ]` QA manual live sin `P0`
- `[ ]` sin `P1` bloqueante
- `[ ]` evidencia de cierre guardada

## 6. Evidencia sugerida

- output de `rotation-preflight --strict`
- output de `rotation-window-check`
- bundle de `final-live-readiness.sh`
- capturas o notas de QA manual
- lista de secretos rotados y responsable de provisión
