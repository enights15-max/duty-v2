# Matriz De Alineacion API-Flutter (2026-02-27)

## Estado General
- Objetivo: validar consistencia entre rutas backend Laravel y endpoints consumidos por `flutter/cliente_v2`.
- Resultado: se corrigieron desalineaciones criticas en marketplace, identidades, follow/unfollow y suscripciones.

## Correcciones Aplicadas

### 1) Marketplace customer scope
- Backend esperado:
  - `GET /api/customers/marketplace/tickets`
  - `POST /api/customers/marketplace/purchase/{id}`
- Antes en Flutter:
  - `GET /api/marketplace/tickets`
  - `POST /api/marketplace/purchase/{id}`
- Corregido en:
  - `flutter/cliente_v2/lib/core/constants/app_urls.dart`

### 2) Identidades bajo customer scope
- Backend esperado:
  - `GET /api/customers/me/identities`
  - `POST /api/customers/identities`
  - `PATCH /api/customers/identities/{id}`
- Antes en Flutter:
  - `GET /api/me/identities`
  - `POST /api/identities`
  - `PATCH /api/identities/{id}`
- Corregido en:
  - `flutter/cliente_v2/lib/core/constants/app_urls.dart`

### 3) Follow/Unfollow organizador
- Backend esperado:
  - `POST /api/organizers/follow` con body `{ id, type }`
  - `POST /api/organizers/unfollow` con body `{ id, type }`
- Antes en Flutter:
  - `POST /api/organizers/{id}/follow`
  - `POST /api/organizers/{id}/unfollow`
- Corregido en:
  - `flutter/cliente_v2/lib/features/events/data/datasources/organizer_remote_data_source.dart`

### 4) Suscripciones cliente
- Flutter ya consumia:
  - `GET /api/customers/subscriptions/plans`
  - `POST /api/customers/subscriptions/subscribe`
- Backend no exponia estas rutas en `api.php`.
- Corregido en:
  - `routes/api.php` (grupo `/customers` con `auth:sanctum`)
  - Controlador existente reutilizado: `SubscriptionController`

### 5) Limpieza de endpoint de debug obsoleto
- Se removio llamada de debug a `/api/debug-auth` en:
  - `flutter/cliente_v2/lib/features/profile/data/datasources/customer_remote_data_source.dart`

## Pendientes Recomendados
- Validar respuestas reales de suscripciones (`status/data/checkout_url`) contra manejo de UI en `membership_remote_data_source.dart`.
- Agregar smoke tests API para rutas de suscripciones y follow/unfollow.
- Cerrar checklist de compatibilidad en QA manual (login -> profile -> marketplace -> transfer -> memberships).

## Evidencia Nueva (Iteracion 2)
- Smoke tests agregados:
  - `tests/Feature/Api/FollowControllerApiTest.php`
  - `tests/Feature/Api/SubscriptionControllerApiTest.php`
- Ajuste de compatibilidad actor en servicio:
  - `app/Services/SubscriptionService.php` ahora soporta actor `Customer` y `User` en `createCheckoutSession()`.

## Evidencia Nueva (Iteracion 3)
- Smoke tests de contrato agregados:
  - `tests/Feature/Api/ScannerContractSmokeTest.php`
  - `tests/Feature/Api/EventBookingContractSmokeTest.php`
- Gate CI ampliado para incluir scanner + booking contract smoke.
