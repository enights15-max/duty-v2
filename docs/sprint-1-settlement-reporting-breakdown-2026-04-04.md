# Sprint 1 Breakdown: Settlement Reporting y Reconciliacion

Fecha: 2026-04-04
Estado: Ready for execution
Depende de: `roadmap-financial-operations-y-algoritmos-2026-04-04.md`

## Objetivo del sprint

Cerrar el primer bloque de `Financial Operations` para que finanzas y operaciones puedan:

1. entender el estado financiero real de un evento
2. exportar ese estado sin calculos manuales externos
3. reconciliar treasury, refunds, collaborator reserves y released amounts

## Estado actual del codigo

### Ya existe

1. Treasury por evento y snapshot financiero
   - `app/Services/EventTreasuryService.php`
2. Settlement review admin
   - `app/Http/Controllers/BackEnd/EconomyController.php`
   - `resources/views/backend/economy/settlements.blade.php`
3. Ledger financiero base
   - `app/Models/EventFinancialEntry.php`
4. Tests base del bloque admin/treasury
   - `tests/Feature/EventTreasuryServiceTest.php`
   - `tests/Feature/BackEnd/AdminSettlementReviewControllerTest.php`
   - `tests/Feature/BackEnd/AdminReservationRefundWorkflowTest.php`

### Falta

1. Export por evento
2. Export filtrado de settlement queue
3. Reconciliacion visual entre:
   - gross collected
   - refunded amount
   - platform fees
   - reserved for owner
   - reserved for collaborators
   - released to wallet
   - claimable amount
4. Timeline financiero mas explicativo para admin

---

## Workstream A: Data Contract de Settlement Reporting

### Meta

Definir un payload consistente para reporting/export y reutilizarlo en UI y CSV.

### Tareas

1. Crear un metodo central tipo `buildSettlementReportData(Event $event)` o equivalente en `EventTreasuryService`.
2. Consolidar un contrato unico con:
   - event identity
   - owner identity
   - treasury snapshot
   - collaborator reserve summary
   - refund summary
   - release summary
   - recent financial entries
3. Evitar que la vista admin vuelva a calcular totales por su cuenta.

### Archivos probables

- `app/Services/EventTreasuryService.php`
- `app/Services/EventCollaboratorSplitService.php`
- opcionalmente un DTO/transformer si conviene

### Aceptacion

1. Existe una sola fuente de verdad para el reporte por evento.
2. La UI y el export reutilizan el mismo contrato.

### Riesgo

Medio.

---

## Workstream B: Export por Evento

### Meta

Permitir exportar el estado financiero completo de un evento desde settlement review.

### Tareas

1. Añadir endpoint admin para export de evento:
   - CSV primero
   - XLSX solo si ya es trivial con la infraestructura actual
2. Incluir secciones o bloques exportables:
   - summary row
   - treasury amounts
   - collaborator reserves
   - refunds summary
   - release actions
   - financial entries timeline
3. Agregar CTA en `settlements.blade.php` dentro del detalle seleccionado.

### Archivos probables

- `app/Http/Controllers/BackEnd/EconomyController.php`
- `resources/views/backend/economy/settlements.blade.php`
- `routes/admin.php`
- posible export class nueva en `app/Exports`

### Aceptacion

1. Desde el detalle de un evento se descarga un archivo reconciliable.
2. El archivo permite entender el saldo sin abrir la base de datos.

### Riesgo

Medio.

---

## Workstream C: Export de Settlement Queue

### Meta

Dar a operaciones una exportacion filtrada de la cola, no solo del detalle individual.

### Tareas

1. Reutilizar filtros actuales:
   - `search`
   - `status`
   - `approval`
   - `owner_type`
2. Exportar filas con:
   - event
   - owner
   - status
   - claimable
   - hold until
   - requires admin approval
   - admin approval state
   - released to wallet
3. Añadir CTA de export en el bloque superior de filtros.

### Archivos probables

- `app/Http/Controllers/BackEnd/EconomyController.php`
- `resources/views/backend/economy/settlements.blade.php`

### Aceptacion

1. La cola exporta exactamente lo que se ve filtrado.
2. Finanzas puede trabajar la queue fuera del panel si hace falta.

### Riesgo

Bajo/medio.

---

## Workstream D: Reconciliacion Visual en Admin

### Meta

Hacer que el detalle del settlement explique matematicamente el estado actual.

### Tareas

1. Añadir bloque de reconciliacion visible:
   - gross collected
   - minus refunded
   - minus platform fees
   - minus collaborator reserves
   - equals owner reserved / available / claimable
2. Señalar diferencias entre:
   - `available_for_settlement`
   - `claimable_amount`
   - `released_to_wallet`
3. Mostrar si el gap se debe a:
   - hold
   - admin approval pendiente
   - collaborator reserves
   - already released

### Archivos probables

- `resources/views/backend/economy/settlements.blade.php`
- `app/Http/Controllers/BackEnd/EconomyController.php`
- posiblemente `app/Services/EventTreasuryService.php`

### Aceptacion

1. El detalle explica por que un evento no esta totalmente liberable.
2. Admin puede razonar el monto sin leer raw ledger rows.

### Riesgo

Medio.

---

## Workstream E: Timeline Financiero Expandido

### Meta

Mejorar la legibilidad de `EventFinancialEntry` para soporte y operaciones.

### Tareas

1. Revisar `entry_type` actuales:
   - `owner_share_reserved`
   - `owner_share_released_to_wallet`
   - `collaborator_share_reserved`
   - `collaborator_share_released_to_wallet`
   - `reservation_payment_reserved`
   - `reservation_refund_processed`
   - `settlement_hold_opened`
   - `refund_window_opened`
   - `settlement_release_approved`
2. Mapear cada uno a copy operativa clara en admin.
3. Mostrar metadata relevante:
   - release source
   - admin approver
   - reference type/id
   - amount triplet gross/fee/net si aplica

### Archivos probables

- `app/Models/EventFinancialEntry.php`
- `app/Http/Controllers/BackEnd/EconomyController.php`
- `resources/views/backend/economy/settlements.blade.php`

### Aceptacion

1. Una persona de ops puede leer la timeline sin conocer los nombres internos del sistema.
2. Las acciones de approval/release quedan distinguibles del resto.

### Riesgo

Bajo.

---

## Workstream F: Tests

### Meta

No sacar reporting sin cobertura minima del contrato y de los exports.

### Tareas

1. Extender `AdminSettlementReviewControllerTest` con:
   - detalle del settlement con reconciliacion
   - export de queue
   - export por evento
2. Extender `EventTreasuryServiceTest` si aparece logica nueva en report builders.
3. Validar compatibilidad SQLite:
   - evitar funciones no soportadas
   - preferir `CASE WHEN` sobre helpers mas exoticos

### Archivos probables

- `tests/Feature/BackEnd/AdminSettlementReviewControllerTest.php`
- `tests/Feature/EventTreasuryServiceTest.php`

### Aceptacion

1. Tests verdes para detalle y export.
2. El sprint no introduce deuda de reporting sin test.

### Riesgo

Bajo/medio.

---

## Orden exacto de ejecucion

1. Workstream A
2. Workstream D
3. Workstream E
4. Workstream B
5. Workstream C
6. Workstream F

## Por que este orden

1. Primero definimos el contrato del reporte.
2. Luego lo usamos para hacer visible la reconciliacion.
3. Despues exportamos sobre la misma estructura.
4. Cerramos con tests cuando la forma final ya existe.

## No hacer en este sprint

1. Reason codes de refund
2. Rediseño grande de reservations admin
3. Splits v2 de colaboradores
4. Nuevos gateways
5. Live cutover

Eso pertenece a sprints siguientes y mezclarlo ahora meteria demasiado riesgo.

## Definition of done del sprint

1. Admin puede abrir un evento en settlement review y entender:
   - cuanto entro
   - cuanto se refundo
   - cuanto esta reservado
   - cuanto ya se libero
   - cuanto es reclamable
2. Admin puede exportar:
   - el evento
   - la queue filtrada
3. La timeline financiera es entendible para operaciones.
4. Los tests del bloque quedan verdes.

## Recomendacion de implementacion inmediata

Si queremos ejecutarlo ya, la primera tarea concreta deberia ser:

1. introducir `buildSettlementReportData()` en `EventTreasuryService`
2. conectar ese payload al detalle de `settlements.blade.php`
3. a partir de ahi, sacar export por evento y export de queue
