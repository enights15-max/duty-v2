# DUTY 1.0 Store Submission Draft

Fecha: 2026-04-08
Estado: draft operativo para release week
Versión objetivo: `1.0.0+1`
App name objetivo: `DUTY`

## Objetivo
Este documento concentra lo necesario para preparar la submission de `DUTY 1.0` en App Store y Play Store sin abrir alcance nuevo. La idea es tener un paquete claro para viernes/sábado:

1. metadata de tienda
2. checklist de screenshots
3. privacidad/data safety
4. blockers reales
5. copy base de release

## Resumen de producto para 1.0
`DUTY` es una app mobile para descubrir eventos, comprar entradas, gestionar tickets, usar wallet, acceder al scanner operativo y administrar eventos desde superficies profesionales ya disponibles.

### Qué sí entra en 1.0
1. descubrimiento de eventos
2. detalle de evento
3. checkout principal
4. mis tickets y detalle de ticket
5. wallet base
6. scanner base
7. create/edit/manage event para perfiles profesionales
8. reservations base
9. admin operations ya implementadas

### Qué no debemos prometer todavía en 1.0
1. Ticket Rewards end-to-end
2. Sponsors
3. Promoter / Co-organizer extendido
4. Memberships / Community
5. POS independiente
6. perks avanzados y rewards claim en bar/caja

## Identidad de release confirmada
1. Android app label: `DUTY`
2. iOS display name: `DUTY`
3. bundle/application id esperado: `com.duty.monkey`
4. versión actual en Flutter: `1.0.0+1`

## Store Positioning
### Categoría sugerida
1. iOS: `Entertainment`
2. Android: `Events` o `Entertainment`

### Público principal
1. asistentes a eventos
2. organizers y colaboradores profesionales
3. staff operativo con scanner

## App Store Copy Draft
### Subtitle sugerido
Discover events, buy tickets, and manage your access

### Promotional text sugerido
Find what is happening, secure your tickets, manage your wallet, and keep event access organized from one place.

### Short description sugerida para Play Store
Discover events, buy tickets, manage your wallet, and keep your access in one place.

### Long description draft
DUTY helps you move through the event experience from discovery to entry.

With DUTY you can:

1. discover upcoming events
2. review event details before you buy
3. purchase tickets from your phone
4. access and manage your tickets in one place
5. use wallet features where available
6. scan and validate access in operational flows
7. manage events through professional surfaces connected to the same ecosystem

DUTY is built to support both attendees and event operations with a mobile-first experience focused on clarity, speed, and control.

Whether you are buying access, checking your ticket details, or operating event flows, DUTY keeps the core experience connected in one app.

### Keywords ideas
1. events
2. tickets
3. nightlife
4. reservations
5. wallet
6. qr tickets
7. event scanner
8. access control
9. organizers

## Capturas requeridas
### iPhone
Tomar al menos estas 6:
1. home / discovery
2. event details
3. checkout
4. my tickets
5. ticket details with QR
6. wallet

### Android phone
Tomar las mismas 6:
1. home / discovery
2. event details
3. checkout
4. my tickets
5. ticket details with QR
6. wallet

### Opcionales si salen estables
1. scanner login / scan success
2. professional create event
3. reservations flow

### Qué evitar en screenshots
1. features de phase 2
2. texto temporal o placeholders
3. datos personales reales
4. entorno local
5. staging domains visibles

## Privacidad y Data Safety
### Señales confirmadas por el build actual
1. internet: sí
2. camera: sí
3. push notifications / remote notifications: sí
4. Face ID / biometrics: sí
5. location: no en release
6. arbitrary loads / cleartext: no en release

### Permisos visibles en release
#### iOS
1. `NSCameraUsageDescription`
2. `NSFaceIDUsageDescription`
3. `remote-notification`

#### Android
1. `INTERNET`
2. `CAMERA`

### Data disclosure preliminar
Esto hay que validar con producto/legal antes de submission final, pero el cuestionario de tienda probablemente tocará:

1. datos de cuenta e identidad
2. información de compra y tickets
3. identificadores del dispositivo / push token
4. wallet / pagos
5. contenido subido por el usuario cuando aplique

### Punto sensible a confirmar
La app usa:
1. `firebase_messaging`
2. `firebase_auth`
3. `flutter_stripe`
4. `google_maps_flutter`
5. `image_picker`
6. `mobile_scanner`

Antes de submission final debemos completar:
1. cuestionario de App Privacy de Apple
2. formulario Data safety de Google Play

## URLs requeridas para submission
Estas deben quedar definidas con URLs públicas reales:

1. Support URL
2. Privacy Policy URL
3. Terms URL
4. Marketing URL opcional

### Estado actual
No dejé estas URLs cerradas en código ni en docs de release. Hay que confirmarlas antes de submission.

## Checklist de assets
### Confirmado
1. Android launcher icons presentes
2. iOS AppIcon set presente
3. launch assets presentes

### Por revisar manualmente
1. icono final 1024x1024 sin transparencias extrañas
2. consistencia visual entre Android e iOS
3. screenshots limpios en línea Scarlet
4. revisar restricción de credenciales Google Maps en Android/iOS

## Blockers reales al 2026-04-08
1. staging dry run real pendiente
2. Android signing real pendiente
3. URLs públicas de soporte / privacidad / términos por confirmar
4. App Privacy y Data safety por completar
5. screenshots finales por tomar
6. revisar credenciales hardcodeadas de Google Maps y confirmar que estén restringidas para release

## GO / NO-GO para submission
### GO si
1. staging dry run sale sin blockers críticos
2. Android signing real validado
3. build Android release y build iOS release pasan
4. smoke manual final pasa
5. URLs públicas están confirmadas
6. formularios de privacidad están listos
7. screenshots están exportadas

### NO-GO si
1. falla checkout real o wallet real
2. falla my tickets / scanner
3. staging dry run no cierra
4. signing Android no queda listo
5. submission metadata sigue incompleta el viernes en la noche

## Pendientes exactos para viernes
1. correr staging dry run real
2. completar `android/key.properties`
3. correr `mobile-release-build-from-file.sh --platform all --check-only`
4. tomar screenshots
5. fijar URLs públicas
6. cerrar copy final de tienda
7. completar privacy/data safety

## Submission package mínimo
### Debe salir de esta semana con esto completo
1. build AAB firmado
2. build iOS listo para archive/submission
3. screenshots base
4. app description
5. short description
6. keywords
7. support/privacy URLs
8. checklist GO firmado por nosotros

## Recomendación
La app ya está cerca de una `1.0` publicable. Lo correcto esta semana no es abrir features nuevas, sino cerrar este paquete de submission y tratar `Ticket Rewards`, `Sponsors`, `Promoter`, `Memberships` y `POS` como `Phase 2`.
