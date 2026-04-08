# Matriz de Superficies: Web vs App vs Pro

Fecha: 2026-03-24
Estado: Base operativa para rediseño y recorte de flujos
Relacionado con: `estrategia-producto-web-vs-app-2026-03-24.md`

## Estados posibles

- `KEEP ON WEB`: debe quedarse y fortalecerse en web
- `WEB -> APP BRIDGE`: debe existir en web, pero su objetivo es llevar a la app
- `APP-ONLY TARGET`: dirección final app-only
- `PRO WEB`: superficie principalmente web para organizers/artists/venues/admin
- `LEGACY HOLD`: mantener temporalmente por compatibilidad, sin empujarla más

## 1. Superficies públicas web actuales

| Superficie | Ruta actual | Estado recomendado | Nota |
|---|---|---|---|
| Home pública | `/` | `KEEP ON WEB` | Debe evolucionar a landing app-first + pro acquisition |
| Listado de eventos | `/events` | `WEB -> APP BRIDGE` | Discovery público sí, checkout protagonista no |
| Detalle de evento | `/event/{slug}/{id}` | `WEB -> APP BRIDGE` | SEO/share + CTA fuerte a la app |
| Perfil organizer | `/organizer/details/{id}/{name}` | `KEEP ON WEB` | Discovery, reputación y captación B2B |
| Perfil artist | `/artist/details/{id}/{name}` | `KEEP ON WEB` | Discovery y reputación |
| Perfil venue | `/venue/details/{id}/{name}` | `KEEP ON WEB` | Discovery y captación B2B |
| Perfil público user | `/profile/{username}` | `KEEP ON WEB` | Social/public profile ligero, sin querer reemplazar la app |
| Blog | `/blog` | `KEEP ON WEB` | SEO / posicionamiento |
| Blog detail | `/blog/{slug}` | `KEEP ON WEB` | SEO / contenido |
| FAQ | `/faq` | `KEEP ON WEB` | soporte comercial |
| About | `/about-us` | `KEEP ON WEB` | branding |
| Contact | `/contact` | `KEEP ON WEB` | captación y soporte |

## 2. Superficies consumer web actuales

| Superficie | Ruta actual | Estado recomendado | Nota |
|---|---|---|---|
| Login customer | `/customer/login` | `LEGACY HOLD` | no debe ser el centro del producto consumer |
| Signup customer | `/customer/signup` | `LEGACY HOLD` | el onboarding principal debería moverse a app |
| Customer dashboard | `/customer/dashboard` | `LEGACY HOLD` | no seguir expandiendo |
| Edit profile web | `/customer/edit-profile` | `LEGACY HOLD` | compatibilidad temporal |
| Wishlist web | `/customer/wishlist` | `LEGACY HOLD` | no priorizar sobre app |
| My bookings web | `/customer/my-bookings` | `LEGACY HOLD` | dirección final: app |
| Booking details web | `/customer/booking/details/{id}` | `LEGACY HOLD` | dirección final: app |
| My orders web | `/customer/my-orders` | `LEGACY HOLD` | dirección final: app |
| Order details web | `/customer/my-orders/details/{id}` | `LEGACY HOLD` | dirección final: app |
| Support ticket web | `/customer/support-ticket*` | `LEGACY HOLD` | puede sobrevivir, pero no es frente principal |

## 3. Checkout y compra en web

| Superficie | Ruta actual | Estado recomendado | Nota |
|---|---|---|---|
| Ticket booking web | `/ticket-booking/{id}` | `LEGACY HOLD` | mantener mientras hacemos transición |
| Event booking cancel | `/event-booking/{id}/cancel` | `LEGACY HOLD` | compatibilidad |
| Event booking complete | `/event-booking-complete` | `LEGACY HOLD` | compatibilidad |
| Checkout web | `/checkout`, `/check-out2` | `APP-ONLY TARGET` | dirección final: compra en app |
| Apply coupon event web | `/apply-coupon` | `APP-ONLY TARGET` | ligado al checkout consumer |

## 4. Shop web

| Superficie | Ruta actual | Estado recomendado | Nota |
|---|---|---|---|
| Shop listing | `/shop` | `LEGACY HOLD` | decidir más adelante si sigue existiendo fuera de la app |
| Shop details | `/shop/details/{slug}/{id}` | `LEGACY HOLD` | mantener temporalmente |
| Cart | `/shop/cart` | `LEGACY HOLD` | no expandir |
| Shop checkout | `/shop/checkout` | `APP-ONLY TARGET` | misma lógica: compra en app |
| Shop buy | `/shop/buy` | `APP-ONLY TARGET` | idealmente app |

## 5. Superficies profesionales web deseadas

Estas no tienen por qué existir todas hoy, pero deberían convertirse en prioridad.

| Superficie | Estado recomendado | Objetivo |
|---|---|---|
| `For Organizers` | `PRO WEB` | captación, beneficios, onboarding, credibilidad |
| `For Artists` | `PRO WEB` | captación, perfil, monetización, tips, presencia |
| `For Venues` | `PRO WEB` | captación, activación de espacios, calendario |
| `Download App` | `KEEP ON WEB` | conversión a app |
| `How Duty Works` | `KEEP ON WEB` | explicar app-first + acceso por ticket |
| `Why tickets live in the app` | `KEEP ON WEB` | justificar compra/acceso app-only |

## 6. App consumer actual

| Superficie | Ruta app | Estado recomendado | Nota |
|---|---|---|---|
| Home | `/home` | `APP-ONLY TARGET` | núcleo de retención |
| Search | `/search` | `APP-ONLY TARGET` | discovery recurrente |
| Event details | `/event-details/:id` | `APP-ONLY TARGET` | compra y social viven aquí |
| Organizer profile | `/organizer-profile/:id` | `APP-ONLY TARGET` | versión profunda y viva |
| Artist profile | `/artist-profile/:id` | `APP-ONLY TARGET` | versión profunda y viva |
| Venue profile | `/venue-profile/:id` | `APP-ONLY TARGET` | versión profunda y viva |
| User profile | `/user-profile/:id` | `APP-ONLY TARGET` | social loop |
| Social connections | `/social/connections` | `APP-ONLY TARGET` | social recurrente |
| Checkout | `/checkout` | `APP-ONLY TARGET` | compra principal |
| Reservations | `/reservations*` | `APP-ONLY TARGET` | reservas y abonos |
| Payment card/webview | `/payment-cc`, `/payment-webview` | `APP-ONLY TARGET` | pagos |
| Wallet | `/wallet` | `APP-ONLY TARGET` | funding/tickets |
| My tickets | `/my-tickets` | `APP-ONLY TARGET` | acceso |
| Ticket details | `/ticket-details/:id` | `APP-ONLY TARGET` | QR / ownership |
| Review inbox | `/reviews/pending` | `APP-ONLY TARGET` | post-evento |
| Account center | `/account-center` | `APP-ONLY TARGET` | identidad y expansión profesional |

## 7. App / pro híbrido actual

| Superficie | Ruta app | Estado recomendado | Nota |
|---|---|---|---|
| Professional events manage | `/professional/events` | `compartido` | puede coexistir con web |
| Create professional event | `/professional/events/create` | `compartido` | puede coexistir con web |
| Edit professional event | `/professional/events/:id/edit` | `compartido` | puede coexistir con web |
| Identity request | `/identity-request` | `compartido` | onboarding profesional |

## 8. Backoffice web

| Superficie | Estado recomendado | Nota |
|---|---|---|
| Admin | `PRO WEB` | se queda web |
| Organizer panel web | `PRO WEB` | se queda web |
| Venue panel web | `PRO WEB` | se queda web |
| Artist panel web | `PRO WEB` | se queda web donde tenga sentido |
| Reservations admin/pro | `PRO WEB` | claramente web |
| Withdrawals / payouts | `PRO WEB` | claramente web |
| Dashboards / moderation | `PRO WEB` | claramente web |

## 9. Reglas prácticas a partir de ahora

### Regla 1
No construir nuevas features consumer importantes en web si su destino natural es la app.

### Regla 2
Toda página pública de evento en web debe empujar a la app como cierre natural del flujo.

### Regla 3
Las superficies profesionales públicas sí se deben fortalecer en web.

### Regla 4
Las herramientas operativas complejas siguen teniendo sentido en web/backoffice.

## 10. Decisiones inmediatas de UX

### Mantener y potenciar en web
- Home
- Events listing
- Event detail
- Organizer detail
- Artist detail
- Venue detail
- Blog / FAQ / About / Contact
- nuevas páginas `For Organizers / Artists / Venues`
- `Download App`

### Empezar a despriorizar visualmente en web
- login/signup customer como protagonista
- dashboard customer web
- bookings/orders web del customer
- checkout web como CTA principal

### Mantener temporalmente por compatibilidad
- rutas customer web
- checkout web legacy
- shop checkout web legacy

## 11. Propuesta de ejecución

### Paso 1
Rediseñar la web pública con intención app-first:
- home
- event detail
- listing
- perfiles públicos
- páginas pro dedicadas

### Paso 2
Cambiar CTAs de eventos:
- de `Buy now` a `Get the app` / `Unlock tickets in the app`

### Paso 3
Crear bridge web -> app:
- QR
- badges de stores
- deep links por evento/perfil
- estado de continuidad

### Paso 4
Cortar progresivamente el checkout web consumer como flujo principal

## 12. Recomendación final

La estrategia correcta es:

- **web para atraer, explicar, posicionar y convertir**
- **app para comprar, acceder, relacionarse y volver**
- **web/pro para organizers, artists, venues y admin**

Ese modelo ordena el producto y evita que mantengamos dos experiencias consumer paralelas.
