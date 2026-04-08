# Estado Release 1.0

Fecha: miercoles 8 de abril de 2026  
Zona horaria: America/Santo_Domingo  
Estado actual: `GO con blockers externos`

## Resuelto hoy

1. Se inicializo el archivo local de staging:
   - `/Users/monkeyinteractive/DEV/v2/.staging-live-readiness.env`
2. Se corrigio el loader de staging para leer archivos `.env` con espacios en valores:
   - `/Users/monkeyinteractive/DEV/v2/scripts/security/staging-live-readiness-from-file.sh`
3. Se agrego validacion contra placeholders en el flujo de staging:
   - `/Users/monkeyinteractive/DEV/v2/scripts/security/staging-live-readiness-from-env.sh`
4. Se corrigio branding tecnico base del app:
   - Android label -> `DUTY`
   - iOS `CFBundleName` -> `DUTY`
5. Se removieron permisos de ubicacion no usados en la app:
   - Android:
     - `ACCESS_FINE_LOCATION`
     - `ACCESS_COARSE_LOCATION`
   - iOS:
     - `NSLocationAlwaysUsageDescription`
     - `NSLocationWhenInUseUsageDescription`
6. Se dejo preparado el pipeline de build mobile con `dart-define`:
   - `/Users/monkeyinteractive/DEV/v2/scripts/release/mobile-release-build.sh`
   - `/Users/monkeyinteractive/DEV/v2/scripts/release/mobile-release-build-from-file.sh`
7. Se corrigio una regresion real de permisos profesionales:
   - una identity `venue` ya no puede administrar eventos organizer-owned solo por ser venue anfitrion
   - archivo:
     - `/Users/monkeyinteractive/DEV/v2/app/Models/Event.php`
8. Se separo el transporte de red entre debug y release:
   - Android:
     - debug mantiene `usesCleartextTraffic = true`
     - release usa `usesCleartextTraffic = false`
   - iOS:
     - debug usa `Info-Debug.plist` con `NSAllowsArbitraryLoads = true`
     - release/profile usan `Info-Release.plist` sin `NSAllowsArbitraryLoads`

## Evidencia tecnica

### Flow de staging

1. `--check-only` ahora falla por el motivo correcto:
   - falta URL real de staging
   - falta auth real de staging
2. Ya no falla por parsing del archivo local.

### Branding y permisos

1. `plutil -lint` sobre `Info.plist`: OK
2. `AndroidManifest.xml` ya usa `android:label="DUTY"`
3. La app usa `google_maps_flutter`, pero no hay geolocalizacion del dispositivo ni request de permisos de ubicacion.

### Smoke tecnico ejecutado

Verdes:

1. `tests/Feature/Api/EventBookingContractSmokeTest.php`
2. `tests/Feature/Api/CheckoutVerifyRegressionTest.php`
3. `tests/Feature/Api/CustomerBookingIdentityFirstTest.php`
4. `tests/Feature/Api/WalletControllerActorApiTest.php`
5. `tests/Feature/Api/OrganizerScannerIdentityOwnershipTest.php`
6. `tests/Feature/Api/ProfessionalEventControllerApiTest.php`
7. `tests/Feature/BackEnd/AdminSettlementReviewControllerTest.php`
8. `tests/Feature/BackEnd/AdminReservationRefundWorkflowTest.php`
9. `tests/Feature/Api/MarketplacePurchaseActorTest.php`
10. `tests/Feature/TicketReservationServiceTest.php`

## Blockers actuales

### P0 externos

1. Falta `DUTY_STAGING_BASE_URL` real.
2. Falta auth real de staging:
   - `DUTY_STAGING_AUTH_TOKEN`
   - o `DUTY_STAGING_AUTH_USERNAME` + `DUTY_STAGING_AUTH_PASSWORD`
3. Sin eso no se puede ejecutar el dry run real ni generar el board `GO / NO-GO`.

### P1 tecnicos aun abiertos

1. Android release signing sigue apuntando a debug en ausencia de archivo real:
   - `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/android/app/build.gradle.kts`
   - esto bloquea submission real hasta configurar signing de release
   - init helper:
     - `/Users/monkeyinteractive/DEV/v2/scripts/release/init-android-key-properties.sh`

## Decision sobre red/transporte

No se tocaron todavia:

1. `android:usesCleartextTraffic`
2. `NSAllowsArbitraryLoads`

Motivo:

1. Ya no se aplican igual en todos los builds.
2. Debug sigue flexible para trabajo local.
3. Release/profile quedan mas cerrados para submission.

## Siguiente paso exacto

1. Completar `.staging-live-readiness.env` con datos reales.
2. Correr:

```bash
./scripts/security/staging-live-readiness-from-file.sh --check-only
```

3. Si sale verde:

```bash
./scripts/security/staging-live-readiness-from-file.sh
```

4. Con el bundle real:
   - revisar `summary.json`
   - revisar `README.md`
   - revisar `go-no-go-board.md`
   - clasificar blockers `P0/P1/P2`

5. Validar build release con:
   - `/Users/monkeyinteractive/DEV/v2/scripts/release/mobile-release-build.sh`

## Archivos tocados en este avance

1. `/Users/monkeyinteractive/DEV/v2/scripts/security/staging-live-readiness-from-file.sh`
2. `/Users/monkeyinteractive/DEV/v2/scripts/security/staging-live-readiness-from-env.sh`
3. `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/android/app/src/main/AndroidManifest.xml`
4. `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/ios/Runner/Info.plist`
