# Roadmap Ejecutable: Financial Operations y Algoritmos Core

Fecha: 2026-04-04
Estado: Propuesto para ejecucion
Owner sugerido: Core product + backend + ops

## Objetivo

Cerrar el siguiente bloque tecnico del proyecto en un orden que reduzca riesgo operativo y nos permita salir del frente visual ya congelado para movernos a:

1. operaciones financieras confiables
2. tooling administrativo de settlement/refund
3. endurecimiento de algoritmos core
4. readiness real para produccion

## Principios de ejecucion

1. No abrir frentes nuevos de UI fuera de lo estrictamente necesario para operar el backend.
2. Cada sprint debe cerrar con:
   - tests nuevos o endurecidos
   - checklist de regresion corto
   - decision documentada si cambia una regla de negocio
3. No mezclar expansion de producto con estabilizacion de finanzas en el mismo sprint.
4. Todo lo que toque dinero debe terminar con:
   - audit trail
   - export o visibilidad admin
   - criterio claro de reconciliacion

## Orden recomendado

1. Settlement reporting y reconciliacion
2. Refund decision tooling
3. Harden de algoritmos core
4. Collaborator economy v2
5. Gateways y pagos
6. Live readiness y cutover

---

## Sprint 1: Settlement Reporting y Reconciliacion

### Objetivo

Dar a finanzas/ops una vista exportable y reconciliable del dinero por evento.

### Entregables

1. Export CSV por evento con:
   - gross collected
   - refunded amount
   - platform fees
   - reserved for owner
   - reserved for collaborators
   - released to wallet
   - claimable amount
   - treasury status
2. Export CSV de settlement queue filtrada.
3. Vista de reconciliacion por evento en admin.
4. Timeline financiero con:
   - reservation revenue
   - booking revenue
   - refunds
   - hold opened
   - admin approval
   - owner release
   - collaborator release

### Archivos probables

- `app/Services/EventTreasuryService.php`
- `app/Http/Controllers/BackEnd/EconomyController.php`
- `app/Models/EventFinancialEntry.php`
- `resources/views/backend/economy/settlements.blade.php`
- `routes/admin.php`

### Riesgo

Medio. La logica base ya existe; el riesgo esta en conciliacion incorrecta o exportes incompletos.

### Criterio de cierre

1. Un evento puede exportarse sin calculos manuales externos.
2. Admin puede explicar el saldo actual del evento usando solo el reporte.
3. Tests de treasury siguen verdes.

### Estimacion

L

---

## Sprint 2: Refund Decision Tooling

### Objetivo

Pasar de refunds operativos a refunds gobernados.

### Entregables

1. `reason_code` obligatorio para refunds admin.
2. Nota obligatoria de operador.
3. Flags de riesgo por caso:
   - reprogramacion
   - disputa
   - incidente operativo
   - goodwill/manual exception
4. Historial de decision por caso.
5. Vista admin de casos refundables y refundados con razon agregada.
6. Reglas visibles de refund window por evento.

### Archivos probables

- `app/Services/AdminReservationRefundService.php`
- `app/Http/Controllers/BackEnd/Event/ReservationController.php`
- `app/Http/Controllers/BackEnd/EconomyController.php`
- `resources/views/backend/event/reservation/partials/index-core.blade.php`
- `resources/views/backend/economy/settlements.blade.php`
- nuevas migraciones si se persisten reason codes o audit tables

### Riesgo

Alto. Toca decisiones administrativas y puede afectar casos historicos.

### Criterio de cierre

1. Ningun refund admin se ejecuta sin razon ni nota.
2. La razon del refund queda visible en admin.
3. El treasury refleja el refund sin doble conteo.

### Estimacion

L

---

## Sprint 3: Harden de Algoritmos Core

### Objetivo

Blindar algoritmos donde un bug cambia dinero, acceso o disponibilidad.

### Alcance

#### 3.1 Purchase limits

Archivo base:
- `app/Services/EventPurchaseLimitService.php`

Pendientes:
- mas casos con gifts
- receiver request vs ownership final
- mixed actor scenarios
- eventos con multiple ticket types

#### 3.2 Ticket pricing schedule

Archivo base:
- `app/Services/TicketPriceScheduleService.php`

Pendientes:
- overlap detection
- fallback pricing
- transitions entre fases
- schedule invalidation rules

#### 3.3 Inventory / sold out / waitlist / marketplace fallback

Archivo base:
- `app/Services/EventInventorySummaryService.php`

Pendientes:
- reglas mas finas de fallback
- prioridad entre waitlist y marketplace
- casos con inventory parcial por ticket type

#### 3.4 Feed relevance

Archivo base:
- `app/Services/SocialFeedService.php`

Pendientes:
- peso de señales
- orden consistente
- cobertura sin degradacion

### Entregables

1. Matriz de edge cases por algoritmo.
2. Tests de regresion ampliados.
3. Regla documentada cuando exista una decision no obvia.

### Riesgo

Alto. Estas zonas cambian experiencia y dinero.

### Criterio de cierre

1. Cada servicio sensible gana tests de regresion nuevos.
2. Los casos ambiguos quedan documentados.
3. No hay cambios de algoritmo sin prueba asociada.

### Estimacion

L

---

## Sprint 4: Collaborator Economy v2

### Objetivo

Expandir el motor de colaboraciones mas alla del caso v1.

### Entregables

1. Soporte para `fixed` splits.
2. Bases adicionales ademas de `net_event_revenue`, si se aprueban:
   - gross ticket sales
   - net after platform fees
   - owner share basis
3. Reglas de validacion para evitar distribuciones invalidas.
4. Mejor reporting por colaborador y por evento.
5. Revisar si necesitamos partial release o no.

### Archivos probables

- `app/Services/EventCollaboratorSplitService.php`
- `app/Models/EventCollaboratorSplit.php`
- `app/Models/EventCollaboratorEarning.php`
- controllers y pantallas de colaboraciones ya existentes

### Riesgo

Alto. Si se abre demasiado rapido, se vuelve fragil y dificil de auditar.

### Recomendacion

No implementar multiples bases a la vez. Empezar por:

1. `fixed`
2. mantener `%` sobre `net_event_revenue`
3. solo abrir otra base si hay caso de negocio fuerte

### Criterio de cierre

1. Nuevos tipos de split tienen tests.
2. El claim del owner nunca pisa reservas de colaboradores.
3. Los reportes de colaboracion siguen conciliando con treasury.

### Estimacion

L

---

## Sprint 5: Pagos y Gateways

### Objetivo

Quitar rigidez en la verificacion de pagos y preparar crecimiento.

### Entregables

1. Abstraccion de gateway en verificacion de pagos.
2. Separacion mas clara entre:
   - card payment
   - wallet
   - bonus
   - mixed funding
3. Contrato de verificacion independiente del proveedor.
4. Tests por gateway/source soportado.

### Archivo base

- `app/Services/EventPaymentVerificationService.php`

### Riesgo

Medio/alto. Si se toca sin contrato claro, rompe checkout.

### Criterio de cierre

1. Stripe sigue estable.
2. El servicio deja de tener acoplamiento duro a un unico gateway.
3. El flujo mixed funding no pierde trazabilidad.

### Estimacion

M/L

---

## Sprint 6: Live Readiness y Cutover

### Objetivo

Cerrar el gap entre "ya funciona" y "ya se puede operar en vivo".

### Fuentes

- `docs/security-rotation-checklist-2026-03-09.md`
- `docs/sprint-1-live-cutover-checklist-2026-03-18.md`
- `docs/qa-manual-lanzamiento-local-2026-03-12.md`

### Entregables

1. Rotacion real de credenciales pendientes.
2. Smoke test real de:
   - login
   - checkout
   - reservations
   - wallet
   - marketplace
   - scanner
   - account center
3. Health checks y observabilidad basica para salida.
4. Cierre del cutover checklist.

### Riesgo

Muy alto operativamente; bajo en implementacion pura.

### Criterio de cierre

1. Checklists principales en verde.
2. Riesgos operativos documentados.
3. Go/no-go claro.

### Estimacion

L

---

## Dependencias entre sprints

1. Sprint 1 debe salir antes que Sprint 4.
2. Sprint 2 debe salir antes del cierre de Sprint 6.
3. Sprint 3 puede arrancar en paralelo parcial con Sprint 2, pero no mezclar mas de dos algoritmos sensibles a la vez.
4. Sprint 5 solo debe abrirse cuando checkout actual este estable y reconciliado.

## Secuencia recomendada de ejecucion real

1. Sprint 1
2. Sprint 2
3. Sprint 3 dividido en sub-batches:
   - purchase limits
   - pricing
   - inventory
   - feed
4. Sprint 4
5. Sprint 5
6. Sprint 6

## Recomendacion de foco inmediato

Si queremos avanzar con el mayor impacto posible en negocio y control, la siguiente ejecucion deberia ser:

1. Sprint 1: settlement reporting y reconciliacion
2. Sprint 2: refund decision tooling
3. Sprint 3A: purchase limits + pricing

Con eso ya tendriamos:

- mejor control del dinero
- mejor soporte/admin ops
- menos riesgo en funciones que afectan compra y acceso

## Definicion de exito del roadmap

Podemos considerar este bloque cerrado cuando:

1. finanzas puede reconciliar un evento sin soporte de desarrollo
2. refund ops tiene razones y auditoria suficientes
3. algoritmos sensibles tienen cobertura de edge cases
4. collaborator economy soporta al menos una expansion segura mas
5. el proyecto tiene checklist de salida real ejecutable y actualizado
