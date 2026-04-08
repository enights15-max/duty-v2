# DUTY cPanel Admin Migration SQL

Fecha: 2026-04-08
Objetivo: conservar solo el admin actual al arrancar la nueva base limpia.

## Cuándo usar esto
Después de:

1. crear la base nueva
2. importar:
   - `/Users/monkeyinteractive/DEV/v2/public/installer/database.sql`

Y antes de:

1. hacer login admin final
2. correr smoke operativo

## Estrategia recomendada
No insertes un admin nuevo a ciegas si el dump ya trae `id = 1`.

La forma más segura es:

1. sacar la fila real del admin actual desde la base vieja
2. hacer `UPDATE` sobre `admins.id = 1` en la base nueva

Eso evita problemas de:
- autoincrement
- llaves únicas
- residuos del admin viejo del dump

## Paso 1. Extraer el admin actual desde la base vieja
Ejecuta esto en la base actual:

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
ORDER BY id ASC;
```

### Qué debes tomar de ahí
Del admin que quieres conservar, copia estos valores:

1. `role_id`
2. `first_name`
3. `last_name`
4. `image`
5. `username`
6. `email`
7. `phone`
8. `address`
9. `details`
10. `password`
11. `status`

### Muy importante
El campo `password` debe ir como hash ya existente.  
No pongas la contraseña en texto plano.

## Paso 2. Revisar el admin del dump en la base nueva
Después de importar la base nueva, valida esto:

```sql
SELECT id, username, email, role_id, status
FROM admins
ORDER BY id ASC;
```

Lo esperado es que exista al menos:

1. `id = 1`
2. usuario admin heredado del dump

## Paso 3. Reemplazar el admin del dump por tu admin actual
Usa esta plantilla:

```sql
UPDATE admins
SET
  role_id = NULL,
  first_name = 'TU_NOMBRE',
  last_name = 'TU_APELLIDO',
  image = NULL,
  username = 'TU_USUARIO_ADMIN',
  email = 'TU_EMAIL_ADMIN',
  phone = NULL,
  address = NULL,
  details = NULL,
  password = 'TU_HASH_BCRYPT_ACTUAL',
  status = 1,
  updated_at = NOW()
WHERE id = 1;
```

## Variante si tu admin tiene role_id
Si tu admin actual sí tiene `role_id`, usa ese valor:

```sql
UPDATE admins
SET
  role_id = 4,
  first_name = 'TU_NOMBRE',
  last_name = 'TU_APELLIDO',
  image = 'tu-imagen.png',
  username = 'TU_USUARIO_ADMIN',
  email = 'TU_EMAIL_ADMIN',
  phone = 'TU_TELEFONO',
  address = 'TU_DIRECCION',
  details = NULL,
  password = 'TU_HASH_BCRYPT_ACTUAL',
  status = 1,
  updated_at = NOW()
WHERE id = 1;
```

## Paso 4. Validar que no queden admins extra
Si quieres arrancar con un solo admin:

```sql
SELECT id, username, email
FROM admins
ORDER BY id ASC;
```

Si aparecen admins extra que no quieres conservar:

```sql
DELETE FROM admins
WHERE id <> 1;
```

### Pausa importante
Haz esto solo si confirmas que no necesitas otros admins operativos.

## Paso 5. Verificación final del admin
Valida:

```sql
SELECT id, username, email, role_id, status
FROM admins
WHERE id = 1;
```

## Secuencia exacta después del import
### Orden recomendado
1. importar `public/installer/database.sql`
2. actualizar admin
3. correr migraciones
4. limpiar cachés
5. crear storage link
6. probar login admin

## Comandos después del import
Desde la raíz del proyecto en el servidor:

```bash
php artisan migrate:status
php artisan migrate --force
php artisan optimize:clear
php artisan storage:link
php artisan view:cache
```

## Verificación rápida posterior
### SQL
```sql
SELECT COUNT(*) AS admins_total FROM admins;
SELECT id, username, email FROM admins ORDER BY id ASC;
```

### App
1. abrir login admin
2. iniciar sesión con tu admin actual
3. entrar al dashboard
4. abrir eventos
5. abrir settings

## Si el login falla
Revisa en este orden:

1. `username` o `email` realmente guardados
2. `password` hash copiado correctamente
3. `status = 1`
4. `APP_KEY` correcta en `.env`
5. caché limpia:

```bash
php artisan optimize:clear
```

## Nota final
Si quieres iniciar con usuarios operativos en cero, no importes `backup_v2tickets.sql` ni `dutyrdco_v2tickets.sql` como base principal.

Quédate con:

- `public/installer/database.sql`

y luego sustituye únicamente el admin.
