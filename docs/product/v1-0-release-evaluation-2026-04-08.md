# Evaluacion de Release 1.0 - 2026-04-08

## Decision ejecutiva

Se puede publicar `1.0` esta semana **si y solo si** reducimos el scope al core estable y cerramos los bloqueantes operativos de release.

No recomiendo esperar a:

- Ticket Rewards completo
- Sponsors
- Promoter / co-organizer nuevo
- Community / Memberships
- POS independiente para bar/caja

Esas ideas son buenas, pero pertenecen a `1.1+` o `Phase 2`.

## Recomendacion honesta

### Publicar esta semana: SI, con scope controlado

Recomiendo publicar `1.0` esta semana si el objetivo es:

1. salir al mercado;
2. validar uso real;
3. empezar a recoger feedback;
4. dejar la segunda etapa para revenue expansion.

### Publicar esta semana: NO, si el objetivo es incluir todas las ideas nuevas

No recomiendo publicar esta semana si la expectativa es salir con:

1. rewards completos end-to-end staff operation;
2. sponsors;
3. promoter split experience nueva;
4. memberships;
5. POS;
6. structured event details reemplazando todo lo manual.

Eso ya no es `1.0`. Eso es una fase nueva de producto.

## Estado actual del proyecto

### Muy avanzado / usable

1. auth y onboarding base
2. discovery / event details
3. checkout y ticketing
4. wallet y topup base
5. reservations
6. scanner general
7. professional event management
8. admin ops
9. treasury / refunds / collaborator economy
10. gateway contract
11. visual system Scarlet

### Aun no validados en entorno real

1. staging dry run real
2. live cutover real
3. secrets reales de Stripe inyectados
4. QA manual en entorno real

### Nuevas ideas abiertas

1. Ticket Rewards
2. Sponsors
3. Promoter / co-organizer
4. Structured Event Details
5. Community / Memberships
6. POS independiente

## Scope recomendado para publicar 1.0

### Incluir en 1.0

1. login / signup / recovery
2. home / search / explore
3. event details
4. checkout principal
5. my tickets
6. ticket details
7. wallet base
8. scanner base
9. reservations si son parte del negocio actual
10. professional event create/edit/manage
11. admin settlement/refund tooling que ya esta construido

### Incluir solo si pasa smoke real

1. wallet topup real
2. mixed checkout real
3. marketplace
4. loyalty redemptions

### Dejar fuera de marketing principal de 1.0

1. Ticket Rewards como feature anunciada
2. claim scanner de rewards para staff
3. sponsors
4. promoter/collaboration v2
5. memberships
6. POS commerce

## Bloqueantes reales para publicar 1.0 esta semana

### P0 - no se publica sin esto

1. ejecutar staging dry run real
2. completar bundle y board `GO / NO-GO`
3. confirmar claves reales de Stripe
4. QA manual minima en staging o pre-live
5. corregir branding tecnico de app antes del build final

### P1 - muy recomendado cerrar antes de submission

1. cambiar label Android de `cliente_v2` a `DUTY`
2. revisar `NSAllowsArbitraryLoads = true` en iOS
3. revisar si los permisos de ubicacion son realmente necesarios para 1.0
4. confirmar metadata de tienda:
   - nombre
   - descripcion
   - screenshots
   - privacy policy
   - support URL
5. confirmar signing y build release reales

## Hallazgos tecnicos de store readiness

### Android

Archivo:
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/android/app/src/main/AndroidManifest.xml`

Hallazgos:
1. `android:label="cliente_v2"` debe cambiarse antes de release
2. `usesCleartextTraffic="true"` merece revision para release

### iOS

Archivo:
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/ios/Runner/Info.plist`

Hallazgos:
1. `CFBundleDisplayName` ya dice `DUTY`
2. `NSAllowsArbitraryLoads = true` merece revision antes de App Store
3. hay permisos de camara, FaceID y ubicacion; conviene verificar que todos sean estrictamente necesarios para `1.0`

### Versionado

Archivo:
- `/Users/monkeyinteractive/DEV/v2/flutter/cliente_v2/pubspec.yaml`

Estado:
1. `version: 1.0.0+1`
2. bundle ids definidos:
   - Android: `com.duty.monkey`
   - iOS: `com.duty.monkey`

## Lo que recomiendo mover explicitamente a segunda etapa

### Phase 2A

1. Ticket Rewards end-to-end
2. staff reward claim UX
3. rewards analytics
4. transfer behavior de rewards

### Phase 2B

1. sponsors catalog
2. sponsor assignment por evento
3. sponsor analytics
4. sponsor visibility en event view

### Phase 2C

1. promoter identity / collaborator UX extendida
2. co-organizer visibility
3. split authoring mas rico
4. promoter dashboards

### Phase 2D

1. structured event details
2. memberships
3. POS independiente
4. CRM organizer

## Decision de producto para 1.0

La narrativa de `1.0` debe ser:

1. descubrir eventos
2. comprar / reservar
3. administrar tickets
4. pagar con Duty
5. operar eventos profesionalmente

No debe intentar contar todavia la historia completa de:

1. rewards
2. sponsors
3. community commerce
4. POS

## Plan de esta semana

### Dia 1

1. staging dry run `check-only`
2. staging dry run real
3. generar bundle y board
4. revisar blockers P0/P1

### Dia 2

1. corregir branding release:
   - Android label
   - revisar ATS / cleartext
2. smoke de checkout / wallet / scanner / create event
3. definir lista final de features visibles de 1.0

### Dia 3

1. QA manual completa de release scope
2. cerrar bugs P0/P1
3. preparar assets y metadata de tiendas

### Dia 4

1. build release Android
2. build/archive iOS
3. submission o beta cerrada segun resultado

## Regla de decision final

### GO esta semana si:

1. el dry run real sale verde
2. no queda ningun P0
3. el scope de 1.0 esta congelado
4. QA manual pasa sin regresion grave

### NO-GO esta semana si:

1. staging/live no esta validado
2. Stripe real no esta listo
3. wallet/checkout/scanner no pasan smoke real
4. seguimos intentando meter ideas nuevas en el mismo release

## Recomendacion final

Mi recomendacion es:

1. **si publicar 1.0 esta semana**
2. **con scope reducido y congelado**
3. **moviendo Ticket Rewards, Sponsors, Promoter, Memberships y POS a Phase 2**

La condicion es que tratemos esta semana como una **semana de release**, no como una semana de expansion de producto.
