# Plan De Seguimiento - Proyecto Duty

## 1. Objetivo
Estabilizar y asegurar Duty (backend Laravel + apps Flutter) para operar sin regresiones en compra, wallet, marketplace, scanner y gestión de identidades.

## 2. Alcance
- Backend API/Web: rutas, seguridad, servicios y consistencia de modelos.
- Apps Flutter: alineación de endpoints y flujos críticos.
- Calidad operativa: tests, CI, observabilidad y criterios de salida.

## 3. Cadencia De Seguimiento
- Daily (15 min): bloqueos, incidentes, cambios de alcance.
- Semanal (60 min): avance vs plan, KPIs, riesgos.
- Quincenal: decisión de release/no release.

## 4. KPIs Del Proyecto
- Tasa de checkout exitoso >= 98%.
- Errores 5xx API < 1%.
- Fallos de scanner por ticket < 0.5%.
- Incidentes P0 abiertos > 24h = 0.
- Pruebas críticas (smoke) en CI = 100% verde.

## 5. Backlog Priorizado

### P0 - Seguridad y continuidad (inmediato)
- P0-01: Bloquear ruta publica `/migrate` y rutas debug.
  - Referencias: `routes/web.php`, `routes/api.php`.
- P0-02: Exigir firma de webhook Stripe siempre (sin fallback inseguro).
  - Referencias: `app/Http/Controllers/WebhookController.php`, `config/services.php`.
- P0-03: Normalizar ruta scanner activa (evitar duplicidad de superficies API).
  - Referencias: `routes/api.php`, `routes/scanner_api.php`, `app/Providers/RouteServiceProvider.php`.

### P1 - Consistencia funcional (Semana 2-4)
- P1-01: Unificar dominio `Customer/User` en wallet, POS, NFC, marketplace y booking.
  - Referencias: `app/Services/WalletService.php`, `app/Services/POSService.php`, `app/Services/NFCService.php`, `app/Http/Controllers/Api/EventController.php`.
- P1-02: Corregir compra marketplace (credito a vendedor y trazabilidad).
  - Referencias: `app/Http/Controllers/Api/MarketplaceController.php`.
- P1-03: Corregir `TicketTransfer` para `create()` seguro.
  - Referencias: `app/Models/TicketTransfer.php`.
- P1-04: Alinear rutas backend con app cliente (identidades/suscripciones).
  - Referencias: `routes/api.php`, `flutter/cliente_v2/lib/core/constants/app_urls.dart`.

### P2 - Calidad y operacion (Semana 4-8)
- P2-01: Baseline de migraciones reproducible para test.
  - Referencias: `database/migrations`, `phpunit.xml`.
- P2-02: Suite de smoke tests: booking, wallet ledger, marketplace, scanner.
  - Referencias: `tests/Feature`.
- P2-03: Pipeline CI con gates de seguridad y pruebas criticas.
- P2-04: Dashboard de observabilidad y alertas por KPI.

## 6. Cronograma Operativo (8 Semanas)

### Semana 1
- Ejecutar P0-01 y P0-02.
- Definir superficie scanner oficial (P0-03).
- Entregable: hardening aplicado + checklist de verificacion.

### Semana 2
- Arrancar P1-01: mapa de entidades y contrato unico de actor autenticado.
- Entregable: decision tecnica documentada + plan de refactor por modulo.

### Semana 3
- Implementar refactor wallet/POS/NFC sobre dominio unificado.
- Entregable: flujo de topup/debit/capture funcionando en entorno QA.

### Semana 4
- Implementar P1-02 y P1-03 (marketplace + transferencias).
- Entregable: compra/reventa/transferencia E2E validada.

### Semana 5
- Implementar P1-04 (alineacion endpoints app-backend).
- Entregable: app cliente sin endpoints huérfanos.

### Semana 6
- Ejecutar P2-01: baseline de BD para testing y local setup.
- Entregable: `php artisan test` ejecutable en entorno limpio.

### Semana 7
- Ejecutar P2-02 + P2-03 (smoke tests + CI gates).
- Entregable: pipeline verde en rama principal.

### Semana 8
- Ejecutar P2-04 (KPI dashboard + alertas) y evaluación go-live.
- Entregable: reporte final de estabilidad y recomendación de release.

## 7. Tablero De Seguimiento (plantilla)
Usar estas columnas en el board:
- `Backlog`
- `Ready`
- `In Progress`
- `Blocked`
- `QA`
- `Done`

Cada ticket debe incluir:
- `ID`: P0-01, P1-03, etc.
- `Owner`
- `Fecha objetivo`
- `Riesgo`
- `Evidencia de cierre` (PR, test, log, captura).

## 8. Riesgos Activos
- Inconsistencia de modelos de usuario (Customer/User) en flujos monetarios.
- Superficies API duplicadas para scanner (mitigado en Sprint 0; monitorear regresiones).
- Cobertura de pruebas insuficiente para los módulos nuevos.
- Migraciones acopladas a tablas legacy sin baseline consistente.

## 9. Criterio De Cierre Del Plan
El plan se considera completado cuando:
- Todos los P0 y P1 estan en `Done`.
- KPI semanal estable por 2 semanas consecutivas.
- Smoke tests y CI en verde.
- Sin incidentes P0/P1 abiertos.

## 10. Estado Actual (2026-02-27)
- `P0-01` Completado: eliminada ruta publica `/migrate` y endpoint debug de autenticacion.
- `P0-02` Completado: webhook Stripe validado siempre con `Stripe-Signature` y `STRIPE_WEBHOOK_SECRET`.
- `P0-03` Completado: scanner unificado en superficie `/api/scanner/*`; removidas rutas duplicadas en `routes/api.php` y app `organizer_app` alineada.
- `P1-01` En progreso: primera iteracion de unificacion de actor en wallet/NFC/POS (guardrails para `Customer`, normalizacion de `user_type` y resolucion segura de actor en webhook).
- `P1-01` Iteracion 2 aplicada: nueva capa persistente `actor_type + actor_id` (wallets, nfc_tokens, payment_methods) con compatibilidad backward sobre `user_id`.
- `P1-01` Iteracion 3 aplicada: scopes `forActor()` en modelos de wallet/NFC/payment methods y controladores API consumiendo actor unificado.
- `P1-01` Smoke tests actor en verde: `tests/Feature/ActorScopeAndWalletServiceTest.php` valida separacion wallet por actor y filtro `PaymentMethod::forActor()`.
- `P1-01` Smoke NFC en verde: `tests/Feature/NfcActorScopeTest.php` valida persistencia de actor en `NFCService::linkToken()` y aislamiento por `NfcToken::forActor()`.
- Calidad tests: esquema minimo de actor unificado extraido a trait reutilizable `tests/Support/ActorTestSchema.php` para reducir duplicacion y acelerar nuevos smoke tests.
- `P1-01` Smoke webhook en verde: `tests/Feature/WebhookActorResolutionTest.php` valida resolucion de actor y guardado de `PaymentMethod` con `actor_type/actor_id` en `handleSetupIntentSucceeded()`.
- `P1-01` Smoke payment methods en verde: `tests/Feature/Api/PaymentMethodsActorApiTest.php` valida filtro por actor y caso no autenticado en `PaymentMethodController::index`.
- `P1-01` Smoke wallet API en verde: `tests/Feature/Api/WalletControllerActorApiTest.php` valida retiro exitoso con débito en ledger, bloqueo por fondos insuficientes y rechazo de actor no `Customer`.
- `P1-01` Suite actor unificado actual en verde (11 tests): `ActorScopeAndWalletServiceTest`, `NfcActorScopeTest`, `WebhookActorResolutionTest`, `PaymentMethodsActorApiTest`, `WalletControllerActorApiTest`.
- `P1-02` Iteracion 1 aplicada: `MarketplaceController::purchase()` usa `lockForUpdate()` sobre booking, valida vendedor existente y aplica idempotency key determinista por `(booking,buyer)` para ledger debit/credit.
- `P1-02` Hardening operativo: notificaciones desacopladas del commit de compra (fallo de push no revierte transaccion financiera ya confirmada).
- `P1-02` Smoke marketplace en verde: `tests/Feature/Api/MarketplacePurchaseActorTest.php` valida compra E2E con traspaso de ownership, registro en `ticket_transfers` y consistencia de montos buyer/seller.
- `P1-03` Iteracion 1 aplicada: `TicketTransfer` ahora permite `create()` seguro con `fillable` explicito para evitar errores de asignacion masiva.
- `P1-03` Iteracion 2 aplicada: `MarketplaceController::transfer()` desacopla notificacion post-commit (fallo de push no provoca `500` sobre transferencia ya confirmada).
- `P1-03` Smoke transferencias en verde: `tests/Feature/Api/MarketplaceTransferActorTest.php` cubre exito, self-transfer bloqueada, receptor inexistente y ticket no transferible.
- Calidad tests: `ActorTestSchema` ampliado con columnas de perfil en `customers` (`username/fname/lname/phone/photo`) para reproducir flujos reales de transferencia.
- Suite actor+marketplace actual en verde (16 tests): `ActorScopeAndWalletServiceTest`, `NfcActorScopeTest`, `WebhookActorResolutionTest`, `PaymentMethodsActorApiTest`, `WalletControllerActorApiTest`, `MarketplacePurchaseActorTest`, `MarketplaceTransferActorTest`.
- `P1-04` Iteracion 1 aplicada (alineacion app-backend):
  - `AppUrls` corregido para rutas customer-scope de marketplace (`/customers/marketplace/*`) e identidades (`/customers/me/identities`, `/customers/identities*`).
  - `OrganizerRemoteDataSource` corregido para `follow/unfollow` segun contrato backend (`POST /organizers/follow|unfollow` con body `id,type`).
  - Rutas de suscripcion agregadas en backend (`GET /customers/subscriptions/plans`, `POST /customers/subscriptions/subscribe`) reutilizando `SubscriptionController`.
  - Eliminada llamada Flutter a endpoint debug obsoleto `/api/debug-auth`.
- Evidencia de alineacion documentada en `docs/matriz-alineacion-api-flutter-2026-02-27.md`.
- `P1-04` Iteracion 2 aplicada:
  - `SubscriptionService::createCheckoutSession()` adaptado para actor `Customer/User` (metadata `actor_type/actor_id`, nombre compatible por modelo).
  - Smoke tests en verde para contratos alineados:
    - `tests/Feature/Api/FollowControllerApiTest.php`
    - `tests/Feature/Api/SubscriptionControllerApiTest.php`
- Suite actor+marketplace+alineacion API actual en verde (20 tests): `ActorScopeAndWalletServiceTest`, `NfcActorScopeTest`, `WebhookActorResolutionTest`, `PaymentMethodsActorApiTest`, `WalletControllerActorApiTest`, `MarketplacePurchaseActorTest`, `MarketplaceTransferActorTest`, `FollowControllerApiTest`, `SubscriptionControllerApiTest`.
- `P2-01` Iteracion 1 aplicada: baseline reusable de pruebas actor con `tests/Support/ActorFeatureTestCase.php` (bootstrap declarativo de schema + truncate + language).
- `P2-01` Estandarizacion inicial completada: suite smoke actor migrada al baseline comun; guia documentada en `docs/testing-baseline-actor.md`.
- `P2-03` Iteracion 1 aplicada: workflow CI inicial `/.github/workflows/actor-smoke-tests.yml` ejecuta gate de regresion para suite actor/marketplace/alineacion API en `push` y `pull_request` a `main/master`.
- `P2-03` Iteracion 2 aplicada: gate CI ampliado con smoke de scanner + booking contracts (`ScannerContractSmokeTest`, `EventBookingContractSmokeTest`).
- `P2-03` Iteracion 3 aplicada: workflow publica reporte JUnit (`test-results/actor-smoke-junit.xml`) como artifact y resumen en `GITHUB_STEP_SUMMARY` para branch protection readiness.
- `P2-03` Iteracion 4 preparada: playbook de branch protection y script GitHub API (`scripts/ci/configure-branch-protection-github.sh`) + fallback local pre-push (`scripts/git-hooks/pre-push`) para hosting no-GitHub.
- Suite smoke focalizada actual en verde (25 tests): actor + marketplace + alineacion API + scanner/booking contracts.

## 11. Logica De Funcionamiento (Mapa Actual)
### Flujo A: Checkout / Booking
- Entrada: endpoints publicos de eventos + `event-booking` y verificacion de pago.
- Nucleo: `EventController` crea reserva y, para flujo wallet/topup, delega a Stripe y servicios de wallet.
- Riesgo principal: mantener consistente el actor autenticado y la trazabilidad de pago/reserva.

### Flujo B: Wallet / Ledger
- Entrada: `/api/customers/wallet*` autenticado por `sanctum`.
- Nucleo: `WalletController` delega en `WalletService` (`getOrCreateWallet`, `credit`, `debit`).
- Regla: wallet por actor (`actor_type + actor_id`) con fallback `user_id` para compatibilidad legacy.

### Flujo C: Payment Methods (Stripe SetupIntent)
- Entrada: `/api/customers/payment-methods*` y webhook `setup_intent.succeeded`.
- Nucleo: `WebhookController::handleSetupIntentSucceeded()` persiste metadatos de tarjeta.
- Regla: guardar y consultar metodos por actor para evitar filtraciones entre dominios `Customer/User`.

### Flujo D: NFC + POS
- Entrada: `/api/customers/nfc/*` y `/api/pos/capture`.
- Nucleo: `NFCService` vincula y valida token; `POSService` valida token/PIN, debita wallet y registra transaccion POS.
- Regla: bloqueo transaccional en ledger y control de limites diarios del token NFC.

### Flujo E: Marketplace y Transferencias
- Entrada: `/api/customers/marketplace/*` y `/api/customers/bookings/{id}/transfer`.
- Nucleo: `MarketplaceController` ejecuta debito comprador, credito vendedor y cambio de ownership.
- Riesgo principal: idempotencia y consistencia atomica en compra/reventa/transfer.

### Flujo F: Scanner
- Entrada oficial: `/api/scanner/*` (organizer/admin).
- Nucleo: validacion de QR y cambio de estado de ticket.
- Regla: mantener una sola superficie API para evitar drift entre apps y backend.

## 12. Plan De Seguimiento Inmediato (Proximos 7-14 dias)
- `P1-01-Cierre`: eliminar consultas monetarias residuales por `user_id` directo y migrarlas a `forActor()`.
- `P1-02-Arranque`: definir tests E2E de marketplace con escenarios success/fail/rollback.
- `P1-03-Arranque`: auditar `TicketTransfer` y endurecer validaciones de ownership + anti-duplicado.
- `P2-01-Iteracion2`: extender baseline comun a mas suites de `tests/Feature` fuera del dominio actor/marketplace.
- `P2-03-Iteracion5`: aplicar branch protection en remoto final (pendiente segun plataforma del repositorio productivo).
