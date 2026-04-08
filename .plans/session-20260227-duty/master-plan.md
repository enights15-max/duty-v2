# Master Plan - Duty

## Resumen ejecutivo
Se prioriza cerrar la unificacion de actor en todos los flujos monetarios y asegurar trazabilidad E2E de compra/transferencia/marketplace, con gates de pruebas y KPI operativos antes de release.

## Decisiones de consenso
- Mantener modelo dual `actor_type + actor_id` con fallback temporal `user_id` hasta finalizar migracion.
- Tratar `Customer` como actor de negocio principal en endpoints `/api/customers/*`.
- Exigir firma Stripe en webhook sin bypass.
- Mantener scanner unificado en `/api/scanner/*` y no duplicar rutas paralelas.

## Plan integrado por fases

### Fase 1 (cerrar P1-01)
- Objetivo: eliminar ambiguedad de actor en wallet, NFC, payment methods, POS y booking.
- Acciones:
  - Expandir uso de scopes `forActor()` donde aun existan consultas por `user_id` directo.
  - Completar pruebas API de wallet y payment methods para actor y auth.
  - Añadir verificacion de idempotencia en operaciones de debito/credito criticas.
- Evidencia:
  - Suite smoke actor >= 1 test por flujo.
  - Sin leakage de datos entre actores.

### Fase 2 (P1-02/P1-03)
- Objetivo: robustecer marketplace y transferencias.
- Acciones:
  - Reforzar compra marketplace con llaves idempotentes deterministas por operacion.
  - Validar trazabilidad de seller payout, fee plataforma y cambio de ownership.
  - Blindar `TicketTransfer` para creacion segura, restricciones de ownership y auditoria.
- Evidencia:
  - Tests E2E: listar, comprar, transferir, rollback por error.
  - Ledger consistente (debit buyer == credit seller + fee).

### Fase 3 (P1-04)
- Objetivo: alinear cliente Flutter con contratos backend.
- Acciones:
  - Inventario endpoint por endpoint usado en app vs definido en backend.
  - Resolver mismatches de payload/campos para identidades, suscripciones y wallet.
- Evidencia:
  - Matriz de compatibilidad backend/app en verde.

### Fase 4 (P2-01/P2-02/P2-03)
- Objetivo: calidad operativa continua.
- Acciones:
  - Baseline reproducible de migraciones para entorno de test.
  - CI con smoke gates para wallet/marketplace/scanner/webhook.
  - Definir thresholds de calidad (fallo bloqueante, flaky budget).
- Evidencia:
  - Pipeline verde en rama principal con gates obligatorios.

### Fase 5 (P2-04)
- Objetivo: observabilidad y decision de release.
- Acciones:
  - Dashboard de KPIs (checkout, 5xx, scanner_fail, incidentes P0).
  - Alertas por umbral y runbook de respuesta.
- Evidencia:
  - 2 semanas de estabilidad KPI antes de go-live.

## Owners sugeridos
- Backend Core: wallet, webhook, marketplace, transferencias.
- Mobile Integracion: contratos API y regresiones Flutter.
- QA/Automation: smoke tests, casos E2E, estabilidad suites.
- DevOps: CI gates, observabilidad, alertas y runbooks.

## Riesgos abiertos
- Dependencias legacy en tablas/columnas antiguas sin baseline uniforme.
- Flujos legacy fuera de `/api/customers/*` que aun usan `User` implicitamente.
- Posibles regresiones silenciosas si no se ejecutan smoke tests por PR.

## Criterio de salida
- P0 y P1 cerrados.
- Suite smoke critica verde en CI.
- KPIs dentro de umbral por 2 semanas.
- Sin incidentes P0/P1 abiertos.
