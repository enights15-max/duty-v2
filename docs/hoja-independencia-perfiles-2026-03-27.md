# Hoja De Independencia De Perfiles

Fecha: 2026-03-27

## Objetivo
Definir qué significa que cada perfil de Duty sea realmente independiente del usuario base y ordenar las siguientes implementaciones por impacto.

La idea no es solo cambiar UI. La independencia real implica:

1. identidad pública propia
2. branding propio
3. comunicación propia
4. operación propia
5. configuración propia
6. permisos y ownership propios

---

## Regla principal

Un perfil profesional no debe sentirse como "el mismo usuario con otra portada".

Cada perfil profesional debe poder existir como una entidad con:

- `display_name` propio
- `slug/@handle` propio
- avatar y portada propios
- enlaces y bio propios
- dashboard propio
- inbox/notificaciones propias
- settings propias
- share/QR propios

---

## Matriz General

| Área | Personal | Organizer | Artist | Venue |
|---|---|---|---|---|
| Nombre propio | Sí | Sí | Sí | Sí |
| Handle propio visible | Parcial | Parcial | Parcial | Parcial |
| Avatar propio | Sí | Sí | Sí | Sí |
| Portada propia | No | Parcial | Sí | Sí |
| Bio / contenido público propio | Parcial | Parcial | Sí | Parcial |
| Dashboard propio | No | Sí | Sí | Sí |
| Settings propias | Parcial | Parcial | Parcial | Parcial |
| Chat como identidad | No | Parcial | Parcial | Parcial |
| Inbox separada por perfil | No | Parcial | Parcial | Parcial |
| Wallet propia | Sí | Sí | Sí | Parcial |
| Share / QR propio | Parcial | Parcial | Parcial | Parcial |
| Miembros / permisos por identidad | No | Base lista | Base lista | Base lista |

Estado:
- `Sí`: ya existe funcionalmente y se siente propio.
- `Parcial`: existe la base, pero todavía depende del usuario personal o no está cerrada en UX/datos.
- `No`: todavía no existe como superficie real.

---

## Estado Actual Por Perfil

### 1. Personal

#### Ya está
- perfil base del usuario
- `username` propio
- avatar propio
- edición de perfil personal
- wallet personal
- home/feed consumer
- tickets y actividad personal

#### Aún depende de otras capas
- comparte demasiado espacio con settings generales
- no tiene separación fuerte entre identidad personal y rol de owner de perfiles pro

#### Recomendación
- mantenerlo como cuenta madre del usuario
- no sobrecargarlo con datos operativos de perfiles pro

---

### 2. Organizer

#### Ya está
- perfil profesional
- dashboard profesional
- wallet profesional
- estadísticas
- eventos gestionados
- edición del perfil pro

Archivos base:
- `flutter/cliente_v2/lib/features/events/presentation/pages/professional_dashboard_page.dart`
- `flutter/cliente_v2/lib/features/events/presentation/pages/professional_stats_page.dart`
- `app/Http/Controllers/Api/ProfessionalDashboardController.php`

#### Falta para independencia real
- `@handle` editable como organizer, no solo derivado
- settings propias del organizer
- inbox/notifications más explícitas como organizer
- chat representado como organizer y no como usuario base
- portada/branding más consistente en todas las superficies

#### Prioridad
Alta

---

### 3. Artist

#### Ya está
- perfil profesional con foto, portada, galería y media
- links sociales/música
- booking notes
- dashboard/stats compartidos de perfil pro
- edición de perfil pro

Archivos base:
- `flutter/cliente_v2/lib/features/profile/presentation/pages/artist_profile_page.dart`
- `resources/views/frontend/artist/details.blade.php`
- `app/Services/ArtistPublicProfileService.php`

#### Falta para independencia real
- `@handle` editable y estable por artista
- chat/booking claramente como artista
- inbox propia de booking/contact
- settings de artista más cercanas a press kit
- share/EPK más autónomo

#### Prioridad
Alta

---

### 4. Venue

#### Ya está
- perfil profesional
- logo y portada
- ubicación y datos de venue
- dashboard pro
- edición del perfil pro
- redes + WhatsApp

Archivos base:
- `flutter/cliente_v2/lib/features/events/presentation/pages/venue_profile_page.dart`
- `app/Services/VenuePublicProfileService.php`

#### Falta para independencia real
- `@handle` propio editable
- settings de venue más operativas
- chat representado como venue
- inbox y requests asociados al venue
- agenda/availability del venue
- share/link del venue más autónomo

#### Prioridad
Alta

---

## Las 6 Capas De Independencia

### A. Identidad Pública

#### Qué ya tenemos
- `display_name`
- `slug`
- avatar
- portada

#### Qué falta
1. `handle` editable por identidad
2. validación de unicidad por identidad
3. visualización consistente del handle en:
   - profile hero
   - chat headers
   - account center
   - search/discovery
4. descripción corta/tagline por perfil

#### Recomendación
Hacer que el `slug` sea editable desde el formulario del perfil pro y usarlo como handle visible canónico.

---

### B. Branding

#### Qué ya tenemos
- avatar/portada por artist y venue
- base de avatar por organizer

#### Qué falta
1. organizer con la misma calidad de branding que artist/venue
2. share image por perfil
3. QR/share assets por perfil
4. opcional después:
   - color/acento del perfil
   - press cover por artista

---

### C. Comunicación

#### Qué ya tenemos
- chat existe
- contacto ya se está orientando a chat como canal principal

#### Qué falta
1. que el chat se abra como identidad
2. que las notificaciones indiquen la identidad emisora/receptora
3. bandeja/inbox separada por identidad
4. templates de contacto:
   - booking
   - venue inquiry
   - organizer inquiry

#### Recomendación
Separar internamente:
- `owner_user_id`
- `display identity`

El owner puede seguir siendo la misma persona, pero el emisor visual debe ser el perfil.

---

### D. Operación

#### Qué ya tenemos
- organizer/artist/venue comparten dashboard pro
- wallet pro ya existe
- stats ya existe

#### Qué falta
1. organizer: approvals/inbox más fuerte
2. artist: bookings/contact flow real
3. venue: agenda/requests/availability
4. surfaces específicas por tipo

#### Recomendación
El siguiente salto no debería ser más UI genérica, sino "operación por tipo".

---

### E. Configuración

#### Qué ya tenemos
- edición del perfil personal
- edición del perfil profesional

#### Qué falta
1. settings específicas por perfil
2. separar:
   - account settings
   - professional settings
3. settings por tipo:
   - artist settings
   - venue settings
   - organizer settings

#### Recomendación
Crear luego una `Professional Settings` por identidad activa, en vez de meter todo dentro del form de solicitud/edición.

---

### F. Permisos y Ownership

#### Qué ya tenemos
- `identities`
- `identity_members`
- ownership base

#### Qué falta
1. roles útiles:
   - owner
   - admin
   - editor
   - finance
   - support
2. UI para gestionar miembros
3. audit simple por identidad

#### Recomendación
Esto no tiene que ir primero, pero sí debe entrar pronto si el producto quiere escalar a equipos.

---

## Recomendación De Implementación

### Corte 1
Handle propio editable por perfil

#### Incluye
- campo `handle/slug` en organizer, artist y venue
- validación de unicidad
- mostrarlo en profile hero, account center y share

#### Razón
Es el cambio con mejor impacto de independencia visible.

---

### Corte 2
Chat e inbox como identidad

#### Incluye
- mensajes enviados/recibidos como organizer/artist/venue
- encabezados correctos
- notificaciones ligadas al perfil activo

#### Razón
Hace que el perfil deje de sentirse prestado por el usuario personal.

---

### Corte 3
Settings propias por perfil

#### Incluye
- `Professional Settings`
- branding
- contacto
- visibilidad
- links/redes
- preferencias por tipo

#### Razón
Consolida el perfil como producto independiente.

---

### Corte 4
Operación específica por tipo

#### Organizer
- approvals
- ventas
- eventos activos

#### Artist
- bookings
- media
- press surface

#### Venue
- agenda
- requests
- availability

---

### Corte 5
Miembros y permisos

#### Incluye
- invitar miembros
- permisos por perfil
- ownership compartido

---

## Recomendación Más Fuerte

Si solo vamos a hacer un siguiente paso grande, debería ser este:

1. `handle` propio editable por perfil
2. `chat/inbox` como identidad
3. `professional settings` separadas

Ese combo es lo que más empuja a que cada perfil se sienta realmente suyo.

---

## Checklist De Perfil Independiente

Un perfil profesional se considera independiente cuando cumple:

- tiene `display_name` y `@handle` propios
- tiene avatar y portada propias
- tiene bio y links propios
- tiene chat como identidad
- tiene inbox/notificaciones propias
- tiene dashboard propio
- tiene settings propias
- tiene share/link/QR propios
- tiene permisos propios

---

## Decisión Recomendada

### No hacer
- seguir heredando username personal en perfiles pro
- usar el perfil personal como fallback visual dominante
- mezclar comunicación profesional con inbox personal

### Sí hacer
- tratar cada perfil pro como entidad de producto
- usar `identity.slug` como handle público
- separar ownership interno de identidad visible

