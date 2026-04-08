# DUTY 1.0 Store Metadata Package

Fecha: 2026-04-08
Versión objetivo: `1.0.0+1`
Estado: ready-to-copy con bloqueos explícitos

## Objetivo
Este documento deja el paquete de metadata de `DUTY 1.0` listo para copiar en:

1. App Store Connect
2. Google Play Console

La idea es minimizar trabajo manual el viernes/sábado y dejar solo los campos que dependen de URLs o decisiones externas.

## Estado de URLs públicas
### Support URL
Hay una ruta pública de contacto en web:

- ruta: `/contact`
- candidato si el dominio final es `https://v2.duty.do`:
  - `https://v2.duty.do/contact`

### Privacy Policy URL
No encontré una ruta pública confirmada en el repo para política de privacidad.

### Terms URL
No encontré una ruta pública confirmada en el repo para términos y condiciones.

## Bloqueo explícito
Antes de submission final debemos confirmar:

1. privacy policy URL real
2. terms URL real
3. que la support URL pública responda correctamente en producción

## App identity
### Confirmado
1. app name: `DUTY`
2. versión: `1.0.0`
3. build number: `1`
4. bundle/package esperado: `com.duty.monkey`

## App Store Connect
### App Name
`DUTY`

### Subtitle
Discover events, buy tickets, and manage your access

### Promotional Text
Find what is happening, secure your tickets, manage your wallet, and keep event access organized from one place.

### Keywords
events,tickets,nightlife,reservations,wallet,qr tickets,event scanner,access control,organizers

### Description
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

### Support URL
Usar cuando esté confirmado:

- `https://v2.duty.do/contact`

### Marketing URL
Opcional. Si no existe landing dedicada, no forzarla.

### Privacy Policy URL
Pendiente

### Category
Primary:

1. `Entertainment`

Secondary opcional:

1. `Lifestyle`

## Google Play Console
### App name
`DUTY`

### Short description
Discover events, buy tickets, manage your wallet, and keep your access in one place.

### Full description
DUTY brings together event discovery, ticket purchase, digital access, wallet tools, and connected event operations in one mobile experience.

Use DUTY to:

1. discover upcoming events
2. check event details before booking
3. buy tickets from your phone
4. access your digital tickets quickly
5. manage wallet features where available
6. support scanner-based entry and operational event flows
7. manage event workflows through connected professional surfaces

DUTY is designed for both attendees and event operators, with a mobile-first experience focused on clarity, speed, and control.

### App category
1. `Events`

### Contact details
#### Website
Usar cuando esté confirmado:

- `https://v2.duty.do`

#### Support URL
Usar cuando esté confirmado:

- `https://v2.duty.do/contact`

#### Email
Pendiente definir email oficial de soporte para tienda

### Privacy Policy
Pendiente

## Release notes
### ES
Primera versión pública de DUTY con descubrimiento de eventos, compra de tickets, wallet base, tickets digitales y herramientas operativas conectadas al mismo ecosistema.

### EN
First public release of DUTY with event discovery, ticket purchase, wallet basics, digital tickets, and connected operational tools in one ecosystem.

## Screenshot plan
### Mínimo recomendado
1. home / discovery
2. event details
3. checkout
4. my tickets
5. ticket details with QR
6. wallet

### No mostrar todavía
1. Ticket Rewards
2. Sponsors
3. Promoter / Co-organizer extendido
4. Memberships / Community
5. POS independiente

## App Privacy / Data Safety guidance
### Señales visibles en release
1. camera
2. biometrics / Face ID
3. push notifications
4. network access
5. identity/account data
6. wallet/payment related flows

### Formularios a completar manualmente
1. Apple App Privacy
2. Google Play Data Safety

### Punto de revisión adicional
Revisar y restringir credenciales de Google Maps en Android e iOS antes de submission final.

## Copia corta en español
### Subtítulo alternativo
Descubre eventos, compra tickets y gestiona tu acceso

### Descripción corta alterna
Explora eventos, compra tickets, usa tu wallet y accede a tus entradas desde un solo lugar.

## Bloqueos finales de metadata
1. privacy policy URL
2. terms URL
3. support email oficial
4. confirmación de dominio público final

## Decisión recomendada
La metadata de tienda ya está suficientemente preparada para submission, siempre que cerremos las URLs públicas faltantes y no prometamos funcionalidades de `Phase 2`.
