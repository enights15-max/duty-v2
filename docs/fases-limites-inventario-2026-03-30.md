# Fases de Ejecucion: Limite por Usuario Final + Sold Out + Dashboard de Preventa

Fecha: 2026-03-30

## Reglas de producto fijas

1. El limite es por usuario final de la boleta.
2. Las boletas regalo pendientes tambien cuentan contra ese usuario.
3. El blackmarket no se muestra dentro del evento mientras haya taquilla oficial.
4. Sold out debe reforzar demanda, no generar confusion.
5. Organizer y venue deben ver inventario y preventa como parte central de su dashboard.

## Orden de ejecucion

### Fase 1. Capa base de inventario y disponibilidad

Objetivo:
- crear una sola fuente de verdad por evento para disponibilidad oficial, low stock, sold out y fallback a blackmarket.

Resultado esperado:
- `primary_available_tickets`
- `primary_tickets_sold`
- `primary_total_inventory`
- `primary_sell_through_percent`
- `primary_sold_out`
- `low_stock`
- `low_stock_count`
- `marketplace_available_count`
- `show_marketplace_fallback`
- `availability_state`
- `demand_label`

### Fase 2. Limite de compra por usuario final

Objetivo:
- dejar de contar el limite solo por comprador y pasar a validarlo por quien terminara teniendo la boleta.

Reglas aplicadas:
- las boletas que el comprador se queda cuentan contra el comprador
- las boletas asignadas cuentan contra el destinatario
- las boletas regalo pendientes tambien cuentan contra el destinatario

### Fase 3. Checkout adaptado a la regla nueva

Objetivo:
- permitir que alguien que ya lleno su cupo siga comprando, pero solo para otros usuarios validos.

Resultado esperado:
- si el comprador ya llego a su tope, los tickets nuevos no pueden quedarse con el
- los destinatarios que ya llegaron a su limite aparecen visibles pero bloqueados
- la UI explica por que el ticket debe asignarse

### Fase 4. Estado dinamico del evento

Objetivo:
- comunicar claramente si un evento esta disponible, en ultimas entradas, sold out o sold out con fallback en blackmarket.

Reglas aplicadas:
- si hay taquilla principal disponible, no se muestra blackmarket en el evento
- si la taquilla principal se agoto y hay reventa, se muestra como fallback
- sold out se usa como senal de demanda y disponibilidad agotada, no como estado ambiguo

### Fase 5. Dashboard de organizer y venue

Objetivo:
- darle al operador del evento visibilidad real de preventa, inventario y actividad comercial.

KPIs sugeridos:
- boletas vendidas
- boletas disponibles
- sell-through
- eventos agotados
- eventos con low stock
- eventos con fallback en blackmarket

### Fase 6. Validacion y cierre

Objetivo:
- validar reglas de limite, stock y fallback con tests y revisar UX.

Casos minimos:
- comprador en limite puede comprar para otros
- destinatario en limite no puede recibir mas
- transferencias pendientes cuentan contra el destinatario
- low stock aparece antes de sold out
- blackmarket solo aparece si la taquilla oficial esta agotada
- dashboard profesional refleja inventario real

