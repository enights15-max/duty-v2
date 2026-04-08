# Plan Economia Compartida Por Evento - 2026-04-01

## Objetivo
Crear una capa de economia por evento donde:

- las ventas de un evento no entren de inmediato al wallet del organizer o venue;
- cada evento mantenga su propio presupuesto retenido hasta completar su ciclo operativo;
- admin pueda controlar refunds, retenciones y liberacion de fondos segun reglas;
- organizer pueda decidir si el payout se libera automaticamente o si el saldo del evento se mantiene separado hasta reclamarlo;
- el evento pueda repartir beneficios con colaboradores como artistas, venues u organizers secundarios;
- cada colaborador vea sus ganancias por evento de forma independiente y deba confirmarlas/reclamarlas antes de acreditarlas a su wallet;
- Duty mantenga trazabilidad completa de gross, fees, refunds, shares y payouts.

## Hallazgos del sistema actual
Hoy ya existe una base economica util, pero no una tesoreria por evento.

### Lo que ya existe
- `FeeEngine`, `fee_policies`, `platform_revenue_events`
- `ProfessionalBalanceService` para balances de organizer / venue / artist
- `AdminReservationRefundService` para refunds administrativos de reservas
- `BookingFundingService` y `TicketReservationService` para capturar fondos

### Problema actual
La acreditacion profesional ocurre demasiado pronto.

- `storeProfessionalOwner()` acredita directo al balance profesional:
  - `/Users/monkeyinteractive/DEV/v2/app/Http/Helpers/Helper.php`
- `ReservationBookingConversionService` tambien termina disparando esa acreditacion:
  - `/Users/monkeyinteractive/DEV/v2/app/Services/ReservationBookingConversionService.php`

Esto significa:

1. el organizer o venue puede ver dinero disponible antes de que el evento termine;
2. si hay que cancelar, cambiar fecha o reembolsar, el sistema ya mezclo ese dinero con el balance general del perfil;
3. no existe una capa clara para reservar shares de colaboradores antes de hacer payouts.

## Principios de producto
Estas reglas recomiendo fijarlas desde el inicio:

1. El dinero del evento debe vivir primero en una tesoreria del evento, no en el wallet del organizer.
2. Ningun payout a organizer, venue o artista debe salir antes de que el evento sea elegible para settlement.
3. Refunds y chargebacks deben impactar primero el presupuesto del evento.
4. Los shares de colaboradores deben calcularse sobre una base clara y auditable.
5. Cada colaborador debe poder ver su presupuesto reservado por evento antes de reclamarlo.
6. Duty debe poder retener, liberar o ajustar fondos del evento de forma administrable.
7. Todo movimiento financiero debe quedar registrado en un ledger por evento.

## Recomendacion central
Introducir una capa nueva:

### `Event Treasury`
Una tesoreria por evento que concentra:

- gross collected;
- refunds;
- platform fees;
- shares reservados;
- saldo retenido para owner;
- saldo elegible para payout;
- saldo ya liberado al wallet;
- hold windows y estado de settlement.

Esta tesoreria debe ser el intermediario obligatorio entre:

- `booking / reservation / resale`
and
- `wallet profesional`.

## Conceptos nuevos recomendados

### 1. Tesoreria del evento
Snapshot financiero del evento.

### 2. Ledger financiero del evento
Historial inmutable de entradas y salidas.

### 3. Configuracion de settlement
Reglas de hold, release automatico y grace period.

### 4. Shares de colaboradores
Reglas de reparto del net distributable.

### 5. Earnings reclamables
Montos reservados para cada collaborator que aun no entran al wallet.

## Modelo de datos recomendado

## A. Tabla `event_treasuries`
Resumen financiero vivo por evento.

Campos sugeridos:

- `id`
- `event_id`
- `currency`
- `gross_collected`
- `gross_refunded`
- `platform_fee_total`
- `chargeback_total`
- `manual_adjustment_total`
- `reserved_for_owner`
- `reserved_for_collaborators`
- `released_to_owner_wallet`
- `released_to_collaborators_wallet`
- `available_for_settlement`
- `hold_until`
- `auto_release_enabled`
- `auto_release_delay_hours`
- `settlement_status`
  - `collecting`
  - `event_pending_completion`
  - `grace_period`
  - `refund_review`
  - `hold`
  - `claimable`
  - `partially_released`
  - `released`
  - `cancelled`
- `last_settlement_run_at`
- `created_at`
- `updated_at`

## B. Tabla `event_financial_entries`
Ledger inmutable por evento.

Campos sugeridos:

- `id`
- `event_id`
- `treasury_id`
- `entry_type`
  - `primary_sale`
  - `reservation_payment`
  - `reservation_conversion`
  - `marketplace_revenue`
  - `refund`
  - `chargeback`
  - `platform_fee`
  - `owner_share_reserved`
  - `collaborator_share_reserved`
  - `owner_wallet_release`
  - `collaborator_wallet_release`
  - `manual_adjustment`
  - `hold_release`
- `reference_type`
- `reference_id`
- `booking_id`
- `reservation_id`
- `ticket_id`
- `identity_id`
- `counterparty_identity_id`
- `gross_amount`
- `fee_amount`
- `net_amount`
- `currency`
- `status`
- `metadata`
- `occurred_at`
- `created_at`

## C. Tabla `event_settlement_settings`
Politica financiera por evento.

Campos sugeridos:

- `id`
- `event_id`
- `hold_mode`
  - `manual_admin`
  - `auto_after_event`
  - `auto_after_grace_period`
- `grace_period_hours`
- `refund_window_hours`
- `auto_release_owner_share`
- `auto_release_collaborator_shares`
- `allow_partial_release`
- `requires_admin_approval`
- `date_change_refund_enabled`
- `date_change_refund_window_hours`
- `cancellation_refund_mode`
  - `full`
  - `partial`
  - `manual`
- `default_refund_note_template`
- `created_at`
- `updated_at`

## D. Tabla `event_collaborator_splits`
Reglas de reparto.

Campos sugeridos:

- `id`
- `event_id`
- `identity_id`
- `role_type`
  - `artist`
  - `venue`
  - `organizer`
  - `host`
  - `promoter`
- `split_type`
  - `percentage`
  - `fixed`
- `split_basis`
  - `net_event_revenue`
  - `gross_ticket_sales`
- `split_value`
- `status`
  - `draft`
  - `confirmed`
  - `locked`
  - `cancelled`
- `notes`
- `created_by_identity_id`
- `created_at`
- `updated_at`

## E. Tabla `event_collaborator_earnings`
Monto reservado para cada collaborator por evento.

Campos sugeridos:

- `id`
- `event_id`
- `treasury_id`
- `split_id`
- `identity_id`
- `role_type`
- `reserved_amount`
- `released_amount`
- `claimed_amount`
- `status`
  - `pending_event_completion`
  - `pending_release`
  - `claimable`
  - `claimed`
  - `cancelled`
- `claim_required`
- `claimed_at`
- `released_at`
- `created_at`
- `updated_at`

## F. Tabla opcional `event_refund_cases`
Casos de refund relacionados al evento.

Campos sugeridos:

- `id`
- `event_id`
- `reason_type`
  - `cancellation`
  - `date_change`
  - `incident`
  - `manual_exception`
- `status`
  - `open`
  - `in_review`
  - `resolved`
- `refund_window_starts_at`
- `refund_window_ends_at`
- `created_by_admin_id`
- `notes`
- `created_at`
- `updated_at`

## Regla de settlement recomendada

### Owner
El organizer o venue owner del evento no recibe dinero directo al wallet durante la venta.

En vez de esto:

- `booking -> ProfessionalBalanceService -> wallet profesional`

debe ocurrir:

- `booking -> event treasury -> owner share reserved`

Y luego:

- `event completed + grace period + no bloqueos -> owner earning claimable`

### Colaboradores
Los artistas o venues invitados no deben cobrar directo sobre cada venta.

En vez de eso:

- el share se calcula sobre el pool elegible del evento;
- se reserva en `event_collaborator_earnings`;
- luego queda `claimable`;
- finalmente se acredita al wallet del collaborator solo al reclamar o por auto-release.

## Base de calculo recomendada para shares
Mi recomendacion fuerte:

### V1
Calcular shares sobre:

`net_event_revenue = gross_collected - refunds - platform_fees - chargebacks - manual_negative_adjustments`

No recomiendo arrancar sobre bruto.

### Por que
Porque si repartimos sobre bruto:

- el sistema puede quedar negativo tras refunds;
- el organizer puede terminar debiendo dinero;
- la conciliacion se vuelve mucho mas fragil.

## Reglas de refunds recomendadas

### 1. Cancelacion total
- refund completo elegible;
- settlement bloqueado;
- no liberar owner share ni collaborator shares;
- admin puede devolver desde treasury.

### 2. Cambio de fecha
- refund opcional dentro de una ventana configurable;
- por defecto recomiendo `72 horas` desde el anuncio;
- mientras la ventana este abierta, el settlement debe quedar en `refund_review`.

### 3. Excepcion manual
- admin puede abrir un caso;
- el evento entra en `hold`;
- se frena cualquier auto-release hasta resolver.

### 4. Chargeback o disputa
- bloquea settlement automatico;
- entra en `hold`;
- puede requerir ajuste manual del treasury.

## Politica de release recomendada

### Default recomendado
- `auto_after_grace_period`
- `grace_period_hours = 72`

### Opciones soportadas

#### `manual_admin`
- admin libera el evento manualmente

#### `auto_after_event`
- se libera apenas pasa la fecha/hora final del evento
- no lo recomiendo como default

#### `auto_after_grace_period`
- se libera despues de terminar el evento y vencer la ventana de riesgo
- es la mejor opcion por defecto

## Regla de UX y control para organizer
El organizer debe poder elegir por evento:

1. `Auto transferir al wallet al quedar claimable`
2. `Mantener saldo del evento separado hasta reclamarlo`

Eso se guarda en `event_settlement_settings.auto_release_owner_share`.

## Regla de UX y control para colaboradores
El collaborator debe ver su earning por evento en estado:

- `Pendiente por completar evento`
- `Pendiente por liberacion`
- `Listo para reclamar`
- `Acreditado al wallet`

Mi recomendacion:
- dejar `claim_required = true` por defecto para collaborators;
- para owner, configurable.

## Recomendacion sobre reventa y marketplace

### V1
No mezclaria la reventa dentro del treasury del evento como share para owner/collaborators.

Duty ya puede monetizar blackmarket via fee propio, pero:

- no lo meteria en el distributable pool del evento en la primera fase;
- si se quiere, se puede agregar despues como politica aparte.

### Motivo
La reventa introduce:

- seller payout;
- multiple ownership;
- fees propios;
- mas complejidad regulatoria y operativa.

Mejor empezar con:

- primary sales;
- reservation payments;
- reservation conversions.

## Recomendacion sobre tickets promocionales o gratuitos
Para tickets emitidos por promocion o cortesia:

- no generan gross collected;
- no participan en net distributable, salvo politica explicita;
- si luego se habilita reventa para promos, debe tratarse como una politica separada.

## Servicios recomendados

### 1. `EventTreasuryService`
Responsable de:

- crear y mantener `event_treasuries`;
- recalcular snapshot desde ledger si hace falta;
- exponer summary por evento.

### 2. `EventFinancialLedgerService`
Responsable de:

- registrar `event_financial_entries`;
- centralizar tipos de entrada;
- garantizar idempotencia.

### 3. `EventSettlementService`
Responsable de:

- decidir si un evento ya es claimable;
- mover estados financieros;
- reservar owner share y collaborator shares;
- liberar montos a wallet cuando corresponda.

### 4. `EventRefundPolicyService`
Responsable de:

- evaluar si un refund esta permitido;
- abrir casos de refund por cambio de fecha o cancelacion;
- exponer ventanas vigentes.

### 5. `EventCollaboratorSplitService`
Responsable de:

- validar shares;
- evitar que sumen mas de 100%;
- calcular reserved earnings.

### 6. `EventPayoutClaimService`
Responsable de:

- convertir `claimable earnings` a creditos de wallet;
- registrar ledger;
- marcar claims como acreditados.

## Cambios recomendados al flujo actual

### A. Quitar acreditacion inmediata
Hoy:

- `storeProfessionalOwner($booking)` acredita al balance profesional

Recomendacion:

- reemplazarlo por registro en treasury
- luego, settlement decide cuando ese dinero pasa al wallet

### B. Mantener compatibilidad temporal
Para no romper demasiado al inicio:

- introducir feature flag o branch de flujo:
  - `event_treasury_enabled`
- si esta desactivado:
  - sigue flujo actual
- si esta activado:
  - no se acredita al wallet
  - entra al treasury

## Superficies de producto recomendadas

## Organizer / Venue dashboard
Nuevo bloque:

### `Economia del evento`
- gross vendido
- refunds
- fees Duty
- saldo retenido
- saldo elegible
- saldo reclamado
- fecha estimada de liberacion
- estado financiero

## Collaborator dashboard
Nuevo bloque:

### `Colaboraciones`
- evento
- rol
- porcentaje o split
- monto reservado
- estado
- CTA `Reclamar`

## Admin
Nuevos paneles:

### 1. `Event Treasury`
- lista de eventos con treasury
- hold status
- claimable status
- refunds abiertos
- release controls

### 2. `Collaborator Splits`
- configurar shares por evento
- bloquear shares al cerrar lineup/venue

### 3. `Settlement Control`
- auto-release / manual release
- grace period
- refund windows

## Plan por fases

## Fase 1. Base de treasury por evento
Objetivo:
- separar el dinero del evento del wallet profesional

Entregables:
- `event_treasuries`
- `event_financial_entries`
- `EventTreasuryService`
- `EventFinancialLedgerService`
- cambios para que bookings y reservation conversions escriban en treasury en vez de acreditar directo

## Fase 2. Settlement hold
Objetivo:
- controlar cuando el dinero es liberable

Entregables:
- `event_settlement_settings`
- `EventSettlementService`
- estados financieros del evento
- auto hold, grace period, manual release

## Fase 3. Refund governance
Objetivo:
- ligar refunds al ciclo financiero del evento

Entregables:
- `event_refund_cases`
- reglas por cancelacion y cambio de fecha
- bloqueos de settlement mientras exista riesgo abierto

## Fase 4. Shared economy / collaborator splits
Objetivo:
- repartir revenue por evento de forma controlada

Entregables:
- `event_collaborator_splits`
- `event_collaborator_earnings`
- `EventCollaboratorSplitService`
- `EventPayoutClaimService`

## Fase 5. Professional dashboards
Objetivo:
- hacer visible la economia compartida

Entregables:
- organizer / venue event treasury view
- collaborator earnings list
- claim flow

## Fase 6. Admin operations
Objetivo:
- dar control a operaciones y soporte

Entregables:
- hold / release panel
- refund windows panel
- manual adjustments
- exports y audit log financiero

## Riesgos y mitigaciones

### Riesgo 1
Duplicar logica entre treasury y wallet.

Mitigacion:
- treasury como capa previa y ledger canonico;
- wallet solo al momento del claim/release.

### Riesgo 2
Permitir shares inconsistentes.

Mitigacion:
- v1 solo porcentaje;
- solo sobre net event revenue;
- suma total `<= 100%`.

### Riesgo 3
Refunds despues de liberar fondos.

Mitigacion:
- grace period;
- hold;
- release condicionado a settlement status.

### Riesgo 4
Complicar demasiado la primera entrega.

Mitigacion:
- v1 sin reventa en el distributable pool;
- v1 sin fixed+percentage splits;
- v1 sin nested collaborator hierarchies.

## Defaults recomendados

- settlement default: `auto_after_grace_period`
- grace period default: `72h`
- collaborators default basis: `net_event_revenue`
- collaborators default release: `claim_required`
- owner default release: configurable, pero recomendado `manual claim`
- date change refund window default: `72h`
- cancellation refund mode default: `full`

## Recomendacion final
No implementaria shares o claims antes de introducir treasury.

El orden correcto es:

1. separar dinero del evento del wallet profesional;
2. introducir settlement y hold;
3. conectar refunds al treasury;
4. despues agregar shared economy con colaboradores.

Con ese orden:

- protegemos al negocio frente a cancelaciones y refunds;
- evitamos mezclar saldos del evento con saldos del perfil;
- y dejamos una base seria para repartir beneficios entre organizer, venue y artistas.
