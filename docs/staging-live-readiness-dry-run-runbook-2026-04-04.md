# Staging Live Readiness Dry Run Runbook

Fecha: 2026-04-04  
Estado: listo para ejecutar  
Objetivo: correr un dry run completo de readiness en staging y salir con bundle + board de decisión sin improvisación.

## Cuándo usarlo

Usar este runbook cuando ya existan:

1. URL real de staging.
2. secretos reales de staging cargados.
3. token o credenciales reales de un customer QA.
4. ventana aprobada para probar topup/setup-intent/verify-payment.

No usarlo:

1. con placeholders de Stripe/Firebase;
2. sin confirmación de entorno objetivo;
3. como sustituto de QA manual live.

## Inputs requeridos

1. `BASE_URL`
2. `ENV_FILE`
3. `AUTH_TOKEN` o `AUTH_USERNAME` + `AUTH_PASSWORD`
4. opcional:
   - `IDENTITY_ID`
   - `TOPUP_AMOUNT`
   - `FINAL_SCOPE`

## Comando recomendado

### Paso 0: validar inputs sin tocar APIs

```bash
./scripts/security/staging-live-readiness-dry-run.sh \
  --env-file .env \
  --base-url "https://staging.example.com" \
  --auth-token "TOKEN_REAL" \
  --final-scope stripe \
  --allow-public-base-url \
  --check-only
```

Aceptar si:

1. imprime el resumen de inputs esperado;
2. termina en `CHECK-ONLY OK`;
3. no hay dudas sobre:
   - URL objetivo
   - modo de autenticación
   - scope final
   - ubicación del bundle

Si prefieres no poner secretos en el comando ni en el historial, usa el wrapper por entorno:

```bash
DUTY_STAGING_BASE_URL="https://staging.example.com" \
DUTY_STAGING_AUTH_TOKEN="TOKEN_REAL" \
DUTY_STAGING_ALLOW_PUBLIC_BASE_URL=1 \
./scripts/security/staging-live-readiness-from-env.sh --check-only
```

Si prefieres mantenerlos en un archivo local no versionado:

1. inicializa el archivo local con permisos seguros:

```bash
./scripts/security/init-staging-live-readiness-file.sh
```

2. revisa y completa:
   - `.staging-live-readiness.env`
3. ejecuta:

```bash
./scripts/security/staging-live-readiness-from-file.sh --check-only
```

### Paso 1: correr el dry run real

Con token:

```bash
./scripts/security/staging-live-readiness-dry-run.sh \
  --env-file .env \
  --base-url "https://staging.example.com" \
  --auth-token "TOKEN_REAL" \
  --final-scope stripe \
  --allow-public-base-url
```

Con login:

```bash
./scripts/security/staging-live-readiness-dry-run.sh \
  --env-file .env \
  --base-url "https://staging.example.com" \
  --auth-username "qa_customer_real" \
  --auth-password "PASSWORD_REAL" \
  --auth-device-name "staging-readiness-window" \
  --final-scope stripe \
  --allow-public-base-url
```

Con wrapper por entorno:

```bash
DUTY_STAGING_BASE_URL="https://staging.example.com" \
DUTY_STAGING_AUTH_TOKEN="TOKEN_REAL" \
DUTY_STAGING_ALLOW_PUBLIC_BASE_URL=1 \
./scripts/security/staging-live-readiness-from-env.sh
```

Con archivo local:

```bash
./scripts/security/staging-live-readiness-from-file.sh
```

## Qué genera

Por defecto:

- bundle:
  - `storage/app/live-readiness/staging-dry-run-YYYYMMDD_HHMMSS`
- board:
  - `<report-dir>/go-no-go-board.md`

Dentro del bundle:

1. `README.md`
2. `summary.json`
3. `manual-evidence.md`
4. `stripe-scope.log`
5. `<final-scope>-scope.log`
6. `go-no-go-board.md`

## Checklist mínimo de inputs reales

Antes de correr el dry run real, confirmar:

1. `BASE_URL`
   - dominio correcto de staging
   - responde por HTTPS si aplica
2. `ENV_FILE`
   - apunta al entorno que realmente vas a validar
3. autenticación
   - `AUTH_TOKEN` válido de un customer QA
   - o `AUTH_USERNAME` + `AUTH_PASSWORD` funcionales
4. `FINAL_SCOPE`
   - normalmente `stripe`
5. `ALLOW_PUBLIC_BASE_URL`
   - usarlo solo si el host es público de verdad
6. `IDENTITY_ID`
   - opcional, pero útil si el smoke necesita scope profesional específico
7. `TOPUP_AMOUNT`
   - monto razonable para staging y consistente con el entorno

## Criterio de aceptación automática

Aceptar la parte automatizada si:

1. `stripe_scope_status = passed`
2. `final_scope_status = passed`
3. `automated_recommendation = GO`
4. `exit_code = 0`

## Criterio de salida operativa

El dry run de staging se considera listo para revisión si:

1. el bundle existe;
2. el board existe;
3. no hay `FAILED` en los checks automatizados;
4. `manual-evidence.md` fue completado por QA/ops;
5. la decisión final quedó documentada como:
   - `GO`
   - o `NO-GO` con follow-up claro.

## Manual gates que siguen siendo obligatorios

1. login/session
2. mixed checkout real
3. wallet + topup real
4. reservas y abonos
5. marketplace
6. scanner
7. account center
8. create/edit event profesional

## Si falla

1. revisar primero:
   - `stripe-scope.log`
   - `<final-scope>-scope.log`
2. confirmar:
   - base URL correcta
   - token válido
   - secretos reales del entorno
   - gateway activo esperado
3. no declarar `GO` si el bundle quedó en:
   - `NO-GO`
   - `not_run`
   - o si falta la evidencia manual

## Archivos involucrados

- [/Users/monkeyinteractive/DEV/v2/scripts/security/staging-live-readiness-dry-run.sh](/Users/monkeyinteractive/DEV/v2/scripts/security/staging-live-readiness-dry-run.sh)
- [/Users/monkeyinteractive/DEV/v2/scripts/security/init-staging-live-readiness-file.sh](/Users/monkeyinteractive/DEV/v2/scripts/security/init-staging-live-readiness-file.sh)
- [/Users/monkeyinteractive/DEV/v2/scripts/security/staging-live-readiness-from-env.sh](/Users/monkeyinteractive/DEV/v2/scripts/security/staging-live-readiness-from-env.sh)
- [/Users/monkeyinteractive/DEV/v2/scripts/security/staging-live-readiness-from-file.sh](/Users/monkeyinteractive/DEV/v2/scripts/security/staging-live-readiness-from-file.sh)
- [/Users/monkeyinteractive/DEV/v2/.staging-live-readiness.env.example](/Users/monkeyinteractive/DEV/v2/.staging-live-readiness.env.example)
- [/Users/monkeyinteractive/DEV/v2/scripts/security/final-live-readiness.sh](/Users/monkeyinteractive/DEV/v2/scripts/security/final-live-readiness.sh)
- [/Users/monkeyinteractive/DEV/v2/scripts/security/render-live-go-no-go-board.sh](/Users/monkeyinteractive/DEV/v2/scripts/security/render-live-go-no-go-board.sh)
- [/Users/monkeyinteractive/DEV/v2/docs/security-rotation-checklist-2026-03-09.md](/Users/monkeyinteractive/DEV/v2/docs/security-rotation-checklist-2026-03-09.md)
- [/Users/monkeyinteractive/DEV/v2/docs/sprint-1-live-cutover-checklist-2026-03-18.md](/Users/monkeyinteractive/DEV/v2/docs/sprint-1-live-cutover-checklist-2026-03-18.md)
- [/Users/monkeyinteractive/DEV/v2/docs/qa-manual-lanzamiento-local-2026-03-12.md](/Users/monkeyinteractive/DEV/v2/docs/qa-manual-lanzamiento-local-2026-03-12.md)
