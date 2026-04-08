# Plan Scanner Universal App 2026-03-25

## Objetivo

Convertir el boton central del bottom nav de la app en un **scanner universal de Duty** con tres usos claros:

1. escanear QR de evento para abrir el evento y comprar
2. escanear QR de receptor para transferir tickets
3. mostrar `My Code` para que otro usuario pueda transferirnos un ticket

La meta es que este boton sea una superficie central del producto, no solo un icono decorativo.

## Decision de producto

El scanner consumer **no** debe reutilizar el scanner de organizer para check-in.

Separamos responsabilidades:

- `consumer scanner`: descubrir eventos, comprar, recibir transferencias
- `organizer scanner`: validar tickets y controlar acceso

Esto evita mezclar:

- acceso al evento
- ownership del ticket
- descubrimiento y compra

## Estado actual

### App

- el boton central hoy solo redirige a `My Tickets`
  - `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/core/widgets/scaffold_with_navbar.dart`
- no existe libreria de scanning instalada en Flutter
  - `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/pubspec.yaml`
- ya existe deep link web -> app para eventos compartidos
  - `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/core/constants/app_urls.dart`
  - `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/core/routes/app_router.dart`
  - `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/core/services/app_link_service.dart`

### Backend

- ya existe scanner organizer/admin para validar tickets
  - `/Users/monkeyinteractive/DEV/v2/routes/scanner_api.php`
  - `/Users/monkeyinteractive/DEV/v2/app/Http/Controllers/ScannerApi/OrganizerScannerController.php`
- ya existe transferencia de tickets por username/email
  - `/Users/monkeyinteractive/DEV/v2/routes/api.php`
  - `/Users/monkeyinteractive/DEV/v2/app/Http/Controllers/Api/MarketplaceController.php`
- ya existe QR bridge de evento para abrir web -> app
  - `/Users/monkeyinteractive/DEV/v2/routes/web.php`
  - `/Users/monkeyinteractive/DEV/v2/app/Http/Controllers/FrontEnd/ProductController.php`

## Recomendacion principal

El scanner debe nacer con esta jerarquia:

1. `Scan Event`
2. `Transfer Ticket`
3. `My Code`

No recomiendo usar el QR del ticket de entrada para transferencia.

### Por que no mezclar el QR del ticket con transferencia

Ese QR hoy representa acceso/check-in.

Si tambien representa transferencia, mezclamos dos cosas sensibles:

- autorizacion de entrada
- cambio de ownership

Eso complica reglas, UX y seguridad.

La solucion correcta es manejar **QR distintos por intencion**.

## Contrato de QR recomendado

### 1. QR de evento

Uso:
- posters
- flyers
- mesas
- social print
- venues

Formato recomendado:

- `https://tu-dominio/open/event/{id}/{slug}`

Ya tenemos casi este flujo.

Comportamiento:
- si la app esta instalada: abre evento
- si no esta instalada: abre bridge web y manda a instalar la app

### 2. QR de receptor de transferencia

Uso:
- una persona le quiere pasar un ticket a otra

Formato recomendado:

- `https://tu-dominio/open/transfer-recipient/{signed-token}`

El token debe resolver:

- `customer_id`
- expiracion corta o razonable
- firma segura

Comportamiento:
- la persona que envia escanea el QR del receptor
- la app llena el destinatario automaticamente
- luego confirma la transferencia

### 3. QR de ticket de entrada

Uso:
- acceso/check-in

Mantener el formato actual del sistema organizer.

Comportamiento:
- solo organizer/admin scanner debe consumirlo para escanear entrada

## UX recomendada del boton central

### Comportamiento inicial

Tap al boton central:
- abre `ScannerPage`

### Primera version del scanner

Layout:
- camara full-screen
- framing box central
- controles abajo

Tabs o chips inferiores:
- `Event`
- `Transfer`
- `My Code`

### Modo Event

Texto:
- `Scan an event QR to open the date in Duty`

Resultado:
- abrir directo `/event-details/:id`
- mostrar CTA fuerte de compra

### Modo Transfer

Texto:
- `Scan someone's Duty code to send them a ticket`

Resultado:
- resolver receptor
- abrir confirmacion de transferencia

### Modo My Code

Mostrar:
- QR de mi usuario como receptor
- username
- nombre
- subtitulo tipo `Scan to send me a ticket`

## MVP recomendado

### MVP 1

**Event scanner**

Capacidad:
- abrir camera
- leer QR de evento
- parsear URL Duty
- navegar a detalle del evento

Este es el corte correcto para activar el boton central rapido.

### MVP 2

**Transfer by scan**

Capacidad:
- generar QR de receptor
- escanear QR de receptor
- usar el flujo existente de transferencia

### MVP 3

**Scanner hub completo**

Capacidad:
- flash
- vibracion/haptic
- scan desde galeria
- errores por tipo
- analytics

## Fases de implementacion

## Fase 1. Scanner base para eventos

### Frontend

Agregar dependencia:
- `mobile_scanner`
  - `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/pubspec.yaml`

Crear pantalla:
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/features/scanner/presentation/pages/scanner_page.dart`

Crear util de parseo:
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/features/scanner/domain/duty_scan_parser.dart`

Conectar boton central:
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/core/widgets/scaffold_with_navbar.dart`

Agregar ruta:
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/core/routes/app_router.dart`

### Regla de parseo

Aceptar:
- `https://.../open/event/{id}/{slug}`
- `duty://event/{id}`

Si detecta evento:
- navegar a `/event-details/{id}`

### Criterio de salida

- el boton central ya abre scanner real
- escanear un QR de evento abre el evento correcto
- el usuario puede comprar desde ahi

## Fase 2. QR de receptor para transferencia

### Backend

Agregar endpoint para QR del usuario actual:
- `GET /transfers/my-qr`

Agregar endpoint para resolver token escaneado:
- `POST /transfers/verify-recipient-token`

Archivos:
- `/Users/monkeyinteractive/DEV/v2/routes/api.php`
- `/Users/monkeyinteractive/DEV/v2/app/Http/Controllers/Api/MarketplaceController.php`

### Recomendacion tecnica

El token del QR debe ser firmado.

Opciones:
- signed route temporal
- token firmado propio con payload corto

Payload recomendado:
- `customer_id`
- `username`
- `issued_at`
- `expires_at`
- `signature`

### Frontend

Pantalla `My Code`:
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/features/scanner/presentation/pages/my_receive_code_page.dart`

Integracion con transfer existente:
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/features/profile/presentation/pages/ticket_details_page.dart`
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/lib/features/profile/presentation/providers/marketplace_provider.dart`

### Flujo recomendado

1. desde un ticket, usuario toca `Transfer`
2. elige `Scan recipient`
3. escanea QR del receptor
4. la app muestra receptor verificado
5. confirma transferencia
6. backend crea transfer pendiente como hoy

### Criterio de salida

- ya no hace falta escribir email/username manualmente
- transferir por QR usa el mismo backend actual

## Fase 3. Pulido del scanner

### Mejoras UX

- torch/flash
- haptic feedback
- error copy por tipo
- bloqueo de re-scan inmediato
- opcion `Scan from photo`

### Mejoras de producto

- banner `Scanned from QR`
- auto-open buy intent en evento
- historial corto de escaneos recientes

### Analytics recomendados

- scan_started
- scan_success_event
- scan_success_transfer
- scan_invalid
- scan_to_event_view
- scan_to_checkout
- scan_to_purchase

## Sugerencias de producto

## 1. Este boton debe vender la accion mas fuerte

La promesa principal del scanner debe ser:

- `Scan to unlock events`

No `Scan tickets`.

Eso empuja discovery + conversion.

## 2. Transfer por scanner si, pero como segundo modo

Es muy buena idea, pero no debe ser la primera historia del boton.

El valor mas inmediato esta en:

- flyer
- cartel
- QR en venue
- poster compartido

## 3. My Code puede convertirse en gesto social

`My Code` no solo sirve para recibir tickets.

Tambien puede servir luego para:
- add friend
- follow
- profile handshake
- invite flow

No recomiendo implementarlo todo ahora, pero conviene diseñarlo ya con esa expansion en mente.

## Riesgos y decisiones

## Riesgo 1. Mezclar scanner consumer y scanner organizer

No hacerlo.

Decision:
- scanner consumer separado
- scanner organizer separado

## Riesgo 2. Usar el QR del ticket para transferencia

No hacerlo.

Decision:
- QR de receptor independiente

## Riesgo 3. Scanner ambiguo

Si abres camara sin contexto, el usuario no sabe que escanear.

Decision:
- tabs o chips claros:
  - Event
  - Transfer
  - My Code

## Orden recomendado de ejecucion

1. crear `ScannerPage`
2. conectar el boton central
3. soportar QR de evento
4. validar navegacion evento -> compra
5. crear `My Code`
6. crear verificacion de receptor por token
7. integrar `Transfer by scan`
8. pulir UX del scanner

## Mi recomendacion final

El siguiente corte correcto es:

### Corte A

**scanner de evento**

Porque:
- activa el boton central de verdad
- tiene alto valor
- aprovecha el bridge ya construido
- no depende de cambios grandes en transferencias

### Corte B

**transfer by scan**

Porque:
- ya tienes backend de transfer
- solo falta quitar friccion al destinatario

### Corte C

**scanner hub premium**

Porque:
- ahi ya vale la pena pulir experiencia, modos y analytics

