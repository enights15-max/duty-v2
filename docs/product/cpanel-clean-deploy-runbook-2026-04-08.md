# DUTY 2.2 Clean Deploy Runbook for cPanel

Fecha: 2026-04-08
Objetivo: publicar backend `2.2` en cPanel con base de datos limpia, conservar solo el admin actual y dejar el sistema listo para `1.0`.
Estado: operativo

## Objetivo real
Queremos lograr esto:

1. publicar el código backend del branch `2.2`
2. crear una base nueva y limpia
3. cargar la base base del sistema
4. ejecutar migraciones nuevas del proyecto
5. conservar únicamente el admin actual
6. arrancar producción/beta con usuarios operativos desde cero

## Recomendación principal
No usar `migrate:fresh` sobre la base actual.

La ruta más segura para este proyecto es:

1. crear una base nueva
2. importar:
   - `/Users/monkeyinteractive/DEV/v2/deployment/database/bootstrap.sql`
3. configurar `.env`
4. correr:

```bash
php artisan migrate --force
```

5. restaurar o reemplazar el admin actual

Esto es más seguro porque el repo ya documenta instalación manual basada en dump:

- [/Users/monkeyinteractive/DEV/v2/deployment/README.md](/Users/monkeyinteractive/DEV/v2/deployment/README.md)
- [/Users/monkeyinteractive/DEV/v2/deployment/checklists/install-manual.md](/Users/monkeyinteractive/DEV/v2/deployment/checklists/install-manual.md)

## Requisitos previos
### Necesarios
1. acceso a cPanel
2. acceso a MySQL Databases en cPanel
3. acceso a File Manager o Git Version Control en cPanel
4. acceso a Terminal de cPanel o SSH

### Si NO tienes Terminal/SSH
La publicación del código y la importación del dump siguen siendo posibles, pero:

1. no podrás correr `php artisan migrate --force` fácilmente
2. no recomiendo crear una ruta web temporal para correr migraciones

En ese caso, la mejor salida es:
1. pedir Terminal al hosting
2. o pedirles que ejecuten esos comandos por ti

## Archivos de referencia
### Base del sistema
- [/Users/monkeyinteractive/DEV/v2/deployment/database/bootstrap.sql](/Users/monkeyinteractive/DEV/v2/deployment/database/bootstrap.sql)

### Plantilla de entorno de producción
- [/Users/monkeyinteractive/DEV/v2/deployment/env/.env.example.production](/Users/monkeyinteractive/DEV/v2/deployment/env/.env.example.production)

## Fase 0. Respaldos
Antes de tocar nada:

1. backup de la base actual
2. backup del `.env` actual del servidor
3. backup del directorio publicado actual
4. confirmar rama exacta a desplegar

### Checklist
- [ ] backup DB actual descargado
- [ ] backup `.env` actual descargado
- [ ] backup del directorio actual hecho
- [ ] branch `2.2` confirmado

## Fase 1. Publicar código del branch 2.2
### Opción A. cPanel Git Version Control
Si tu cPanel tiene Git Version Control:

1. conecta el repo o actualiza el repo existente
2. checkout del branch `2.2`
3. despliega al path correcto del backend

### Opción B. Subida manual
Si no estás usando Git deployment:

1. sube el proyecto al servidor
2. asegúrate de incluir `vendor/` si no correrás `composer install` en servidor
3. verifica permisos de:
   - `storage/`
   - `bootstrap/cache/`

### Checklist
- [ ] código `2.2` visible en servidor
- [ ] `vendor/` presente o plan para instalar dependencias
- [ ] `storage/` con permisos
- [ ] `bootstrap/cache/` con permisos

## Fase 2. Crear base de datos nueva
En cPanel:

1. entra a `MySQL Databases`
2. crea una base nueva
3. crea un usuario nuevo para esa base
4. asigna todos los privilegios al usuario

### Recomendación de naming
Ejemplo:

1. DB:
   - `cpaneluser_duty22`
2. user:
   - `cpaneluser_duty22u`

### Checklist
- [ ] base nueva creada
- [ ] usuario nuevo creado
- [ ] privilegios completos asignados

## Fase 3. Importar base base del sistema
Importa este archivo en la base nueva:

- `/Users/monkeyinteractive/DEV/v2/deployment/database/bootstrap.sql`

### Opción A. phpMyAdmin
1. abre phpMyAdmin desde cPanel
2. selecciona la base nueva
3. `Import`
4. sube `bootstrap.sql`
5. ejecuta import

### Opción B. Terminal/SSH
```bash
mysql -u DB_USER -p DB_NAME < deployment/database/bootstrap.sql
```

### Checklist
- [ ] import completado sin errores
- [ ] tablas base visibles
- [ ] tabla `admins` cargada
- [ ] tabla `basic_settings` cargada

## Fase 4. Configurar .env del servidor
Usa como base:

- `/Users/monkeyinteractive/DEV/v2/deployment/env/.env.example.production`

### Variables mínimas a completar
1. `APP_NAME`
2. `APP_ENV=production`
3. `APP_DEBUG=false`
4. `APP_URL`
5. `DB_HOST`
6. `DB_PORT`
7. `DB_DATABASE`
8. `DB_USERNAME`
9. `DB_PASSWORD`
10. `STRIPE_KEY`
11. `STRIPE_SECRET`
12. `STRIPE_WEBHOOK_SECRET`
13. `DUTY_IOS_APP_URL`
14. `DUTY_ANDROID_APP_URL`
15. `PUBLIC_API_BASE` si aplica
16. `MAIL_*`
17. `GOOGLE_*`
18. `FACEBOOK_*`
19. `GOOGLE_MAP_API_KEY`
20. `NFC_SECRET`

### Si el APP_KEY está vacío
Desde terminal:

```bash
php artisan key:generate --force
```

### Checklist
- [ ] `.env` creado
- [ ] DB conectada a la base nueva
- [ ] `APP_KEY` válida
- [ ] Stripe completado
- [ ] mail completado

## Fase 5. Ejecutar migraciones nuevas
Ya con la base base importada y el `.env` apuntando a la DB nueva:

```bash
php artisan migrate --force
php artisan optimize:clear
php artisan view:cache
php artisan storage:link
```

### Recomendación
Primero valida el estado:

```bash
php artisan migrate:status
```

### Resultado esperado
1. el dump deja una base funcional
2. `migrate --force` aplica únicamente las migraciones que faltan
3. la tabla `migrations` queda al día

### Checklist
- [ ] `migrate:status` revisado
- [ ] `migrate --force` ejecutado
- [ ] `optimize:clear` ejecutado
- [ ] `view:cache` ejecutado
- [ ] `storage:link` ejecutado

## Fase 6. Conservar solo el admin actual
Aquí hay dos caminos.

### Recomendación
Usar el admin actual real y no el admin histórico del dump.

## Opción 1. Reemplazar el admin por defecto con los datos actuales
Primero, desde la base actual, exporta solo el admin actual:

```sql
SELECT
  id,
  role_id,
  first_name,
  last_name,
  image,
  username,
  email,
  phone,
  address,
  details,
  password,
  status,
  created_at,
  updated_at
FROM admins
WHERE id = 1;
```

Si tu admin actual no es `id = 1`, ajusta el `WHERE`.

Luego, en la base nueva:

```sql
UPDATE admins
SET
  role_id = <ROLE_ID_O_NULL>,
  first_name = '<FIRST_NAME>',
  last_name = '<LAST_NAME>',
  image = '<IMAGE_OR_NULL>',
  username = '<USERNAME>',
  email = '<EMAIL>',
  phone = '<PHONE_OR_NULL>',
  address = '<ADDRESS_OR_NULL>',
  details = '<DETAILS_OR_NULL>',
  password = '<HASH_ACTUAL>',
  status = 1,
  updated_at = NOW()
WHERE id = 1;
```

### Opción 2. Borrar el admin del dump e insertar el admin actual
```sql
DELETE FROM admins;
```

Luego:

```sql
INSERT INTO admins (
  id,
  role_id,
  first_name,
  last_name,
  image,
  username,
  email,
  phone,
  address,
  details,
  password,
  status,
  created_at,
  updated_at
) VALUES (
  1,
  NULL,
  'TU_NOMBRE',
  'TU_APELLIDO',
  NULL,
  'tu_admin',
  'tu@email.com',
  NULL,
  NULL,
  NULL,
  'HASH_BCRYPT_ACTUAL',
  1,
  NOW(),
  NOW()
);
```

### Mi recomendación
Usa **Opción 1** si el `id = 1` ya existe en el dump.  
Es más simple y evita problemas de autoincrement.

### Checklist
- [ ] admin actual exportado desde DB vieja
- [ ] admin actualizado o insertado en DB nueva
- [ ] login admin validado

## Fase 7. Mantener usuarios operativos en cero
Si la DB nueva sale solo desde `bootstrap.sql` más migraciones y solo restauras el admin, entonces:

1. clientes operativos arrancan en cero
2. organizers/venues/artists operativos arrancan en cero
3. bookings/tickets/wallet real arrancan en cero

### Muy importante
No mezcles la DB actual de usuarios reales con esta base nueva si el objetivo es reiniciar operación.

## Fase 8. Smoke mínimo después del deploy
### Backend/web
1. home pública
2. login admin
3. listado de eventos
4. detalle de evento
5. contacto web

### App/API
1. auth base
2. discover
3. event details
4. checkout Stripe básico
5. my tickets
6. wallet básico

### Admin/ops
1. dashboard admin
2. settlements
3. reservations
4. scanner base

### Checklist
- [ ] home responde
- [ ] login admin responde
- [ ] admin dashboard abre
- [ ] eventos listan
- [ ] checkout básico responde

## Comandos recomendados en servidor
### Desde la raíz del proyecto
```bash
php artisan optimize:clear
php artisan migrate:status
php artisan migrate --force
php artisan storage:link
php artisan view:cache
```

### Si falta vendor
```bash
composer install --no-dev --optimize-autoloader
```

## Qué no hacer
### No recomendado
```bash
php artisan migrate:fresh --seed --force
```

### Razón
Este proyecto está orientado a instalación manual basada en dump:

- `deployment/database/bootstrap.sql`

No tenemos garantía aquí de que un `fresh --seed` deje todo el sistema listo igual de bien que el bootstrap base.

## Decisión recomendada
### Sí, es posible
Y la ruta correcta para ti es:

1. publicar código `2.2`
2. crear DB nueva
3. importar `bootstrap.sql`
4. correr `php artisan migrate --force`
5. restaurar solo el admin actual
6. hacer smoke

## Checklist final corto
- [ ] código `2.2` desplegado
- [ ] DB nueva creada
- [ ] `bootstrap.sql` importado
- [ ] `.env` configurado
- [ ] migraciones ejecutadas
- [ ] admin actual restaurado
- [ ] smoke básico verde

## Próximo paso recomendado
Antes de hacerlo en servidor, conviene preparar:

1. los valores reales del `.env`
2. la fila exacta del admin actual
3. el orden de ejecución en cPanel

Si quieres, el siguiente paso te lo dejo como:

1. **SQL exacto para exportar tu admin actual**
2. **template de `.env` de producción ya rellenable**
3. **checklist corto para la persona que hará el deploy en cPanel**
