# DUTY 1.0 Store Submission Checklist

Fecha base: 2026-04-08
Ventana objetivo: viernes 2026-04-10 y sábado 2026-04-11
Versión objetivo: `1.0.0+1`
Estado: operativo

## Uso
Este checklist está pensado para ejecutarse en release week sin improvisación. La idea es recorrerlo en orden:

1. readiness técnico
2. assets
3. metadata
4. privacidad
5. builds
6. submission

Marca cada punto con:
- `[ ]` pendiente
- `[x]` cerrado
- `[!]` bloqueo

## 1. Readiness técnico
### 1.1 Staging dry run
- [ ] completar `/Users/monkeyinteractive/DEV/v2/.staging-live-readiness.env`
- [ ] correr:

```bash
./scripts/security/staging-live-readiness-from-file.sh --check-only
```

- [ ] correr:

```bash
./scripts/security/staging-live-readiness-from-file.sh
```

- [ ] revisar bundle generado
- [ ] revisar `manual-evidence.md`
- [ ] generar y revisar `go-no-go-board.md`
- [ ] marcar decisión:
  - [ ] GO
  - [ ] NO-GO

### 1.2 Android signing
- [ ] completar `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/android/key.properties`
- [ ] validar que el `storeFile` exista
- [ ] validar que no queden placeholders
- [ ] correr:

```bash
./scripts/release/mobile-release-build-from-file.sh --platform android --check-only
```

### 1.3 Build config
- [ ] completar `/Users/monkeyinteractive/DEV/v2/.mobile-release.env`
- [ ] confirmar `DUTY_RELEASE_API_BASE_URL`
- [ ] confirmar `DUTY_RELEASE_PUBLIC_BASE_URL`
- [ ] revisar `DUTY_RELEASE_GOOGLE_MAPS_API_KEY` si aplica
- [ ] validar:

```bash
./scripts/release/mobile-release-build-from-file.sh --platform all --check-only
```

## 2. Assets de tienda
### 2.1 Íconos
- [ ] validar ícono Android final
- [ ] validar ícono iOS final
- [ ] confirmar 1024x1024 limpio para App Store

### 2.2 Screenshots
#### iPhone
- [ ] home / discovery
- [ ] event details
- [ ] checkout
- [ ] my tickets
- [ ] ticket details con QR
- [ ] wallet

#### Android
- [ ] home / discovery
- [ ] event details
- [ ] checkout
- [ ] my tickets
- [ ] ticket details con QR
- [ ] wallet

#### Opcionales si están impecables
- [ ] scanner success
- [ ] professional create event
- [ ] reservations

### 2.3 Calidad visual
- [ ] sin datos personales reales
- [ ] sin dominios de staging visibles
- [ ] sin features de `Phase 2`
- [ ] sin placeholders
- [ ] consistencia visual Scarlet

## 3. Metadata de tienda
Referencia: `/Users/monkeyinteractive/DEV/v2/docs/product/v1-0-store-submission-draft-2026-04-08.md`

### 3.1 Identidad
- [ ] app name final: `DUTY`
- [ ] versión visible: `1.0.0`
- [ ] bundle/package id confirmados

### 3.2 App Store
- [ ] subtitle final
- [ ] promotional text final
- [ ] long description final
- [ ] keywords final
- [ ] support URL
- [ ] privacy policy URL
- [ ] terms URL
- [ ] category final

### 3.3 Google Play
- [ ] short description final
- [ ] full description final
- [ ] support email
- [ ] privacy policy URL
- [ ] category final

## 4. Privacidad y data safety
### 4.1 Apple App Privacy
- [ ] revisar uso de cámara
- [ ] revisar biometría / Face ID
- [ ] revisar push notifications
- [ ] revisar auth / identity data
- [ ] revisar purchases / tickets / wallet
- [ ] completar formulario en App Store Connect

### 4.2 Google Play Data Safety
- [ ] revisar account data
- [ ] revisar purchase data
- [ ] revisar device/push identifiers
- [ ] revisar wallet/payment related data
- [ ] completar formulario en Play Console

### 4.3 Credenciales y terceros
- [ ] revisar restricción de Google Maps API keys
- [ ] confirmar Firebase/project config final
- [ ] confirmar Stripe config final de release

## 5. Builds finales
### 5.1 Android
- [ ] correr build release firmado:

```bash
./scripts/release/mobile-release-build-from-file.sh --platform android
```

- [ ] validar salida AAB
- [ ] guardar hash o nombre exacto del artefacto
- [ ] revisar warnings relevantes

### 5.2 iOS
- [ ] correr build release:

```bash
./scripts/release/mobile-release-build-from-file.sh --platform ios
```

- [ ] abrir archive en Xcode si aplica
- [ ] validar signing/profile final
- [ ] validar subida a App Store Connect

## 6. Smoke final
### 6.1 Consumer
- [ ] login
- [ ] discovery
- [ ] event details
- [ ] checkout
- [ ] my tickets
- [ ] ticket details
- [ ] wallet base

### 6.2 Ops / scanner
- [ ] scanner login
- [ ] scan success
- [ ] ownership correcto

### 6.3 Professional
- [ ] create event
- [ ] edit event
- [ ] management básico

### 6.4 Financial / admin
- [ ] settlement review abre
- [ ] refund tooling básico estable
- [ ] economy dashboard abre

## 7. Submission
### 7.1 App Store Connect
- [ ] metadata cargada
- [ ] screenshots cargadas
- [ ] privacy completada
- [ ] build asociada
- [ ] release notes cargadas
- [ ] submission enviada

### 7.2 Google Play Console
- [ ] app content completo
- [ ] data safety completo
- [ ] store listing completo
- [ ] screenshots cargadas
- [ ] AAB subida
- [ ] release notes cargadas
- [ ] rollout / submission enviada

## 8. Release notes draft
### ES
Primera versión pública de DUTY con descubrimiento de eventos, compra de tickets, wallet base, tickets digitales y herramientas operativas conectadas al mismo ecosistema.

### EN
First public release of DUTY with event discovery, ticket purchase, wallet basics, digital tickets, and connected operational tools in one ecosystem.

## 9. Campo de decisión final
### Estado del viernes
- [ ] listo para submission
- [ ] listo con riesgo controlado
- [ ] mover submission

### Motivos si no sale
1. ________________________________________
2. ________________________________________
3. ________________________________________

### Responsable de decisión final
- nombre: _________________________________
- fecha/hora: _____________________________

## 10. Phase 2 explícita
No meter en esta submission:

1. Ticket Rewards end-to-end
2. Sponsors
3. Promoter / Co-organizer extendido
4. Structured Event Details
5. Memberships / Community
6. POS independiente
