# Runbook Build Mobile Release

Fecha: miercoles 8 de abril de 2026  
Objetivo: dejar cerrado el proceso de build Android/iOS para `DUTY 1.0` sin improvisar variables ni comandos el dia de submission.

## Regla

Los builds release deben salir usando `dart-define`, no apoyados en fallback local.

Variables esperadas:

1. `API_BASE_URL`
2. `PUBLIC_BASE_URL`
3. `GOOGLE_MAPS_API_KEY` si aplica para el build final

## Script

Archivo:

- `/Users/monkeyinteractive/DEV/v2/scripts/release/mobile-release-build.sh`

Wrappers locales:

- `/Users/monkeyinteractive/DEV/v2/scripts/release/init-mobile-release-file.sh`
- `/Users/monkeyinteractive/DEV/v2/scripts/release/mobile-release-build-from-file.sh`
- `/Users/monkeyinteractive/DEV/v2/.mobile-release.env.example`

## Inputs requeridos

### Obligatorio

1. `DUTY_RELEASE_API_BASE_URL`

### Recomendado

1. `DUTY_RELEASE_PUBLIC_BASE_URL`
2. `DUTY_RELEASE_GOOGLE_MAPS_API_KEY`

### Opcionales

1. `--build-name`
2. `--build-number`
3. `--platform`
4. `--android-format`
5. `--ios-export-options-plist`

## Comandos recomendados

### Flujo local recomendado

1. Inicializar archivo local:

```bash
./scripts/release/init-mobile-release-file.sh
```

2. Editar:

- `/Users/monkeyinteractive/DEV/v2/.mobile-release.env`

3. Validar sin construir:

```bash
./scripts/release/mobile-release-build-from-file.sh \
  --platform all \
  --check-only
```

### Validacion Android sin construir

```bash
DUTY_RELEASE_API_BASE_URL="https://api.duty.do/v2/api" \
DUTY_RELEASE_PUBLIC_BASE_URL="https://v2.duty.do" \
./scripts/release/mobile-release-build.sh \
  --platform android \
  --check-only
```

### Validacion iOS sin construir

```bash
DUTY_RELEASE_API_BASE_URL="https://api.duty.do/v2/api" \
DUTY_RELEASE_PUBLIC_BASE_URL="https://v2.duty.do" \
./scripts/release/mobile-release-build.sh \
  --platform ios \
  --check-only
```

### Build Android AAB

```bash
DUTY_RELEASE_API_BASE_URL="https://api.duty.do/v2/api" \
DUTY_RELEASE_PUBLIC_BASE_URL="https://v2.duty.do" \
DUTY_RELEASE_GOOGLE_MAPS_API_KEY="REAL_KEY" \
./scripts/release/mobile-release-build.sh \
  --platform android \
  --android-format aab \
  --build-name 1.0.0 \
  --build-number 1
```

### Build iOS sin codesign

```bash
DUTY_RELEASE_API_BASE_URL="https://api.duty.do/v2/api" \
DUTY_RELEASE_PUBLIC_BASE_URL="https://v2.duty.do" \
DUTY_RELEASE_GOOGLE_MAPS_API_KEY="REAL_KEY" \
./scripts/release/mobile-release-build.sh \
  --platform ios \
  --build-name 1.0.0 \
  --build-number 1 \
  --ios-no-codesign
```

### Build iOS firmado con export options

```bash
DUTY_RELEASE_API_BASE_URL="https://api.duty.do/v2/api" \
DUTY_RELEASE_PUBLIC_BASE_URL="https://v2.duty.do" \
DUTY_RELEASE_GOOGLE_MAPS_API_KEY="REAL_KEY" \
./scripts/release/mobile-release-build.sh \
  --platform ios \
  --build-name 1.0.0 \
  --build-number 1 \
  --ios-export-options-plist "/absolute/path/ExportOptions.plist"
```

## Blocker conocido actual

Android sigue con release signing de debug en:

- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/android/app/build.gradle.kts`

Mientras eso no se configure con signing real:

1. el script falla en `check-only`
2. solo se puede continuar con:
   - `--allow-debug-signing`
3. eso sirve para pruebas no-store, no para submission real

Template local:

- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/android/key.properties.example`

## Decision sobre transporte de red

Se separo por configuracion:

1. Android:
   - debug -> `usesCleartextTraffic = true`
   - release -> `usesCleartextTraffic = false`
2. iOS:
   - debug -> `Runner/Info-Debug.plist` con `NSAllowsArbitraryLoads = true`
   - release/profile -> `Runner/Info-Release.plist` sin `NSAllowsArbitraryLoads`

Motivo:

1. el app usa `dart-define` para el release final
2. el fallback local sigue existiendo en:
   - `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/core/constants/app_urls.dart`
3. asi mantenemos debug util para desarrollo
4. y release mas limpio para submission

## Criterio de salida de este bloque

Este bloque se considera cerrado cuando:

1. `--check-only` Android pasa con URL real y signing real
2. `--check-only` iOS pasa con URL real
3. el comando final de build queda congelado para el sabado
