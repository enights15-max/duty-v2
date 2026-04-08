# Runbook Android Release Signing

Fecha: miercoles 8 de abril de 2026  
Objetivo: dejar listo el signing real de Android para `DUTY 1.0`.

## Archivo local esperado

Ruta:

- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/android/key.properties`

Template:

- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/android/key.properties.example`

Init helper:

- `/Users/monkeyinteractive/DEV/v2/scripts/release/init-android-key-properties.sh`

## Formato

```properties
storeFile=/absolute/path/to/upload-keystore.jks
storePassword=REAL_PASSWORD
keyAlias=upload
keyPassword=REAL_PASSWORD
```

## Comportamiento actual

1. Si `key.properties` existe y contiene los 4 valores:
   - el build release de Android usa signing real
2. Si no existe o esta incompleto:
   - el build release cae a debug signing
   - eso solo sirve para pruebas internas, no para Play Store

## Pasos

1. Inicializar archivo local:

```bash
./scripts/release/init-android-key-properties.sh
```

2. Llenar los valores reales.

3. Validar con:

```bash
DUTY_RELEASE_API_BASE_URL="https://api.duty.do/v2/api" \
DUTY_RELEASE_PUBLIC_BASE_URL="https://v2.duty.do" \
./scripts/release/mobile-release-build.sh \
  --platform android \
  --check-only
```

## Criterio de salida

Este bloque queda cerrado cuando:

1. `--check-only` ya no reporta debug signing
2. el AAB release queda listo para Play Store

## Guardrail actual

Si `key.properties` existe pero aun tiene placeholders, el wrapper reporta:

1. archivo presente pero incompleto
2. placeholders detectados
3. rechazo del build de store hasta llenar valores reales
