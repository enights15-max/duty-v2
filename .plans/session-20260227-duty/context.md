# Contexto de Planificacion - Duty

## Objetivo
Estabilizar el backend Laravel y su integracion con apps Flutter para evitar regresiones en flujos monetarios, compra de tickets, marketplace, scanner y webhook Stripe.

## Fuentes revisadas
- routes/api.php
- routes/scanner_api.php
- app/Providers/RouteServiceProvider.php
- app/Http/Controllers/WebhookController.php
- app/Http/Controllers/Api/WalletController.php
- app/Http/Controllers/Api/MarketplaceController.php
- app/Services/WalletService.php
- app/Services/NFCService.php
- app/Services/POSService.php
- tests/Feature/*Actor*.php

## Hallazgos base
- Dominio de actor en transicion (`Customer` vs `User`) con compatibilidad backward por `user_id`.
- Flujos criticos de wallet, payment methods y NFC ya tienen base actor-aware y pruebas smoke.
- Scanner esta unificado en superficie `/api/scanner/*`.
- Marketplace depende de wallet ledger y tiene riesgo de consistencia por idempotencia y trazabilidad.

## Resultado esperado
Un plan operativo por fases con owners, evidencias de cierre y criterios de go/no-go.
