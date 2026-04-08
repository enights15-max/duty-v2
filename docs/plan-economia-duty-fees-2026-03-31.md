# Plan Economia Duty Fees - 2026-03-31

## Objetivo
Crear un sistema de economia de plataforma para Duty donde:

- cada operacion monetizable tenga una politica de fee configurable;
- el fee se pueda administrar de forma independiente por operacion;
- el cobro sea transparente para buyer/seller/host;
- toda ganancia de Duty quede registrada en un ledger economico inmutable;
- organizer y venue puedan ver cuanto beneficio generan para la plataforma;
- admin tenga una vista ejecutiva y operativa de economia, rentabilidad y take rate.

## Problema actual
Hoy ya existen fees en algunos puntos, pero estan dispersos:

- venta primaria: `Basic::commission`
- reventa: `Basic::marketplace_commission`
- wallet ledger soporta `fee` y `total_amount`

Eso resuelve casos puntuales, pero no ofrece:

- control central por tipo de operacion;
- auditoria economica consistente;
- analitica por organizer, venue, evento y operacion;
- flexibilidad para activar/desactivar fees sin tocar codigo;
- una narrativa clara de de donde gana dinero Duty.

## Principios de producto
Estas reglas recomiendo dejarlas fijas:

1. No todas las operaciones deben cobrar fee por defecto.
2. Toda operacion que cobre fee debe mostrarlo antes de confirmar.
3. Toda ganancia de Duty debe registrarse en un ledger economico inmutable.
4. Organizer y venue deben poder ver su impacto economico sobre la plataforma.
5. El sistema debe soportar fee por porcentaje, fijo o mixto.
6. El sistema debe permitir `min_fee` y `max_fee`.
7. El fee debe poder cobrarse al buyer, al seller, dividirse o absorberlo la plataforma.

## Operaciones candidatas
Propongo estandarizar un catalogo oficial de operaciones:

| Operation key | Superficie | Recomendada para fee | Comentario |
| --- | --- | --- | --- |
| `primary_ticket_sale` | Compra principal de ticket | Si | Base de negocio principal |
| `marketplace_resale` | Compra de reventa | Si | Ya existe una comision base |
| `ticket_transfer` | Transferencia manual entre usuarios | Opcional | Mejor dejar `0` por defecto |
| `gift_transfer` | Regalo / compra para otro usuario | Opcional | Mejor dejar `0` por UX |
| `reservation_payment` | Pago inicial de reserva | Si | Si la reserva es parte del funnel principal |
| `reservation_conversion` | Conversion reserva -> booking | Opcional | Cuidar doble cobro |
| `wallet_topup` | Recarga de wallet con tarjeta | Opcional | Solo si quieres trasladar parte del costo financiero |
| `wallet_transfer` | Transferencia entre wallets | Opcional | Mejor `0` o fijo bajo |
| `wallet_withdrawal` | Retiro / payout | Si | Fee fijo o mixto |
| `artist_tip` | Propina a artista | Opcional | Requiere cuidado de UX |
| `promo_ticket_issue` | Emision promo / cupon | No | No cobrar por defecto |
| `subscription_purchase` | Suscripciones futuras | Si | Si entra en roadmap |

## Recomendacion de politica por operacion

### 1. Venta primaria
- `operation_key`: `primary_ticket_sale`
- recomendacion: `percentage`
- charged_to: `buyer`
- default sugerido: reutilizar comision actual y luego migrarla a FeePolicy

### 2. Reventa / blackmarket
- `operation_key`: `marketplace_resale`
- recomendacion: `percentage`
- charged_to: `seller` o `split`
- default sugerido: migrar `marketplace_commission`
- observacion:
  - buyer debe ver el precio final;
  - seller debe ver el neto que recibe.

### 3. Transferencias sociales
- `ticket_transfer`
- `gift_transfer`
- recomendacion: `0%` por defecto
- razon:
  - son operaciones de adopcion, retencion y confianza;
  - cobrar aqui puede generar friccion innecesaria.

### 4. Wallet topup
- recomendacion: inicialmente `platform_absorbed`
- razon:
  - conviene no castigar al usuario al fondear;
  - si luego quieres monetizar, hacerlo con fee fijo pequeno o moverlo a premium.

### 5. Wallet withdrawal
- recomendacion: `fixed` o `percentage_plus_fixed`
- charged_to: `seller` / quien retira
- razon:
  - suele haber costo real operativo y de payout.

### 6. Reservas
- `reservation_payment`
- recomendacion: si la reserva forma parte de la venta principal, tratarla como funnel de ticketing y no duplicar fee en la conversion.

### 7. Tips
- recomendacion: si se monetiza, que sea transparente y baja.
- si el objetivo es crecimiento de creator economy, puede arrancar en `0`.

## Modelo de datos recomendado

### A. Tabla `fee_policies`
Esta tabla define que fee aplica a cada operacion.

Campos sugeridos:

- `id`
- `operation_key`
- `name`
- `description`
- `is_active`
- `fee_type`
  - `percentage`
  - `fixed`
  - `percentage_plus_fixed`
- `percentage_value`
- `fixed_value`
- `minimum_fee`
- `maximum_fee`
- `charged_to`
  - `buyer`
  - `seller`
  - `split`
  - `platform_absorbed`
- `split_buyer_percentage`
- `split_seller_percentage`
- `currency`
- `apply_to_promotional`
- `apply_to_professional_profiles`
- `metadata`
- `created_at`
- `updated_at`

### B. Tabla `platform_revenue_events`
Ledger economico inmutable. Cada fila representa ganancia o fee aplicado para Duty.

Campos sugeridos:

- `id`
- `operation_key`
- `reference_type`
- `reference_id`
- `event_id`
- `ticket_id`
- `booking_id`
- `reservation_id`
- `wallet_transaction_id`
- `organizer_identity_id`
- `venue_identity_id`
- `actor_customer_id`
- `gross_amount`
- `fee_amount`
- `net_amount`
- `charged_to`
- `currency`
- `status`
- `policy_snapshot`
- `metadata`
- `occurred_at`
- `created_at`

### C. Servicio `FeeEngine`
Responsable de:

1. recibir contexto de operacion;
2. buscar la politica aplicable;
3. calcular:
   - monto bruto
   - fee
   - neto
   - distribucion del fee
4. devolver desglose uniforme;
5. persistir `platform_revenue_events`.

## Flujo tecnico recomendado

### Paso 1
Controller/servicio de negocio envia al `FeeEngine`:

- `operation_key`
- `gross_amount`
- buyer/seller
- evento/ticket/booking
- si es promo o no
- si es actor profesional o no

### Paso 2
`FeeEngine` devuelve:

- `gross_amount`
- `fee_amount`
- `net_amount`
- `charged_to`
- `policy_snapshot`

### Paso 3
La operacion se ejecuta con ese desglose.

### Paso 4
Se registra un `platform_revenue_event`.

## Recomendaciones de UX

### Buyer
Si buyer paga fee:

- mostrar `Subtotal`
- mostrar `Cargo por procesamiento`
- mostrar `Total`

### Seller
Si el fee sale del payout:

- mostrar `Precio de venta`
- mostrar `Comision Duty`
- mostrar `Recibes neto`

### Organizer / Venue
No solo ver ventas. Tambien:

- cuanto beneficio generan a Duty;
- cuanto viene de venta primaria;
- cuanto viene de reventa;
- cuanto viene de reservas;
- top eventos por take rate.

## Superficies de admin

### 1. Fee Policies
Pantalla nueva:

- listar operation keys
- activar/desactivar
- editar tipo de fee
- editar charged_to
- editar min/max
- ver historial de cambios

### 2. Economia general
Pantalla nueva:

KPIs:
- ingreso total Duty
- ingreso hoy / semana / mes
- ingreso por tipo de operacion
- ingreso por organizer
- ingreso por venue
- ingreso por evento
- GMV primario
- GMV secundario
- take rate promedio

Filtros:
- fecha
- organizer
- venue
- evento
- operation key
- perfil profesional

### 3. Ranking de rentabilidad
Bloques sugeridos:

- top organizers por beneficio generado
- top venues por beneficio generado
- top eventos por beneficio generado
- top eventos por reventa
- top eventos por prima de reventa

## Superficies para organizer y venue

### Dashboard profesional
Nuevo bloque `Economia`

KPIs:
- `Comision generada`
- `Venta primaria`
- `Reventa`
- `Take rate`
- `Eventos que mas ingresos dejan a Duty`

### Por evento
En inventario o detalle profesional:

- `GMV primario`
- `GMV secundario`
- `Comision plataforma`
- `Reventas cerradas`
- `Precio promedio de reventa`
- `Precio maximo de reventa`

## Guardrails recomendados

1. No permitir cobrar fee doble accidentalmente en reserva + conversion.
2. No registrar revenue event sin policy snapshot.
3. Toda politica inactiva debe seguir preservando historico de eventos ya cobrados.
4. Los reportes deben salir del ledger economico, no recalcularse desde tablas transaccionales.
5. Toda superficie que cobre fee debe ser transparente.

## Riesgos

### Riesgo 1: sobre-cobrar todo
Si cobramos en cualquier micro movimiento:

- baja conversion;
- aumenta friccion;
- afecta percepcion de confianza.

### Riesgo 2: logica duplicada
Si seguimos usando:

- `Basic::commission`
- `Basic::marketplace_commission`
- fees sueltos en controllers

el sistema economico se vuelve fragil.

### Riesgo 3: reporting no confiable
Sin ledger inmutable, los dashboards de economia siempre seran debatibles.

## Plan por fases

### Fase 1. Catalogo y decisiones de producto
Objetivo:
- congelar el catalogo de operaciones monetizables;
- definir para cada una:
  - cobra o no cobra;
  - quien paga;
  - tipo de fee.

Entregables:
- matriz final de operaciones;
- defaults por operacion;
- decisiones de UX/transparencia.

### Fase 2. Fee policies
Objetivo:
- crear `fee_policies`;
- mover settings actuales hacia este nuevo modelo.

Entregables:
- migracion;
- modelo;
- CRUD admin;
- seeds iniciales con:
  - `primary_ticket_sale`
  - `marketplace_resale`
  - `wallet_withdrawal`

### Fase 3. Fee engine
Objetivo:
- servicio unico para calcular fees y devolver breakdown consistente.

Entregables:
- `FeeEngine`
- `FeeContext`
- `FeeBreakdown`
- tests unitarios

### Fase 4. Ledger economico
Objetivo:
- crear `platform_revenue_events`.

Entregables:
- migracion;
- modelo;
- registro automatico desde:
  - venta primaria
  - reventa

### Fase 5. Integracion progresiva
Objetivo:
- reemplazar fees hardcodeados por `FeeEngine`.

Orden sugerido:
1. venta primaria
2. reventa
3. wallet withdrawal
4. reservas
5. tips
6. wallet topup / wallet transfer si aplica

### Fase 6. Analitica y panel admin
Objetivo:
- construir dashboard economico global.

Entregables:
- KPIs globales
- filtros
- ranking organizer/venue/evento
- export basico

### Fase 7. Economia profesional
Objetivo:
- llevar insight de rentabilidad a organizer y venue.

Entregables:
- bloque `Economia` en dashboard profesional
- metrics por evento
- ranking interno

## Recomendacion de ejecucion
Mi recomendacion de orden tecnico:

1. `Fase 1`
2. `Fase 2`
3. `Fase 3`
4. `Fase 4`
5. `Fase 5` solo para venta primaria y reventa
6. `Fase 6`
7. `Fase 7`

Razon:

- primero definimos politica;
- luego la hacemos configurable;
- luego creamos el motor;
- luego registramos revenue;
- despues sustituimos logica vieja.

## Recomendacion final
No intentaria cobrar fee en todas las operaciones desde el dia uno.

La estrategia correcta es:

- centralizar;
- hacer configurable;
- hacer visible;
- registrar todo;
- y luego expandir.

La prioridad recomendada para lanzamiento de esta iniciativa es:

1. `primary_ticket_sale`
2. `marketplace_resale`
3. `wallet_withdrawal`

Con eso ya tienes:

- control de las dos fuentes mas claras de revenue;
- una base analitica seria;
- y espacio para crecer sin volver a reescribir la economia despues.
