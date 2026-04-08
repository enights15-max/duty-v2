# Instalacion Manual

## Flujo objetivo

Este proyecto debe poder instalarse sin asistente web.

## Requisitos previos

- PHP compatible con el proyecto
- MySQL/MariaDB disponible
- extensiones PHP requeridas por Laravel y el proyecto
- acceso para subir archivos al servidor
- acceso para crear base de datos y usuario

## Pasos

### 1. Subir archivos

Sube la aplicacion completa al servidor.

Preferencia para beta:
- subir una build ya preparada con `vendor/` y assets incluidos

## 2. Configurar `.env`

1. copiar `deployment/env/.env.example.production` a `.env`
2. completar:
   - `APP_URL`
   - `APP_KEY`
   - credenciales DB
   - correo si aplica
   - Stripe
   - OAuth si aplica
   - Google Maps si aplica

Si no existe key, generar:

```bash
php artisan key:generate
```

### 3. Importar la base de datos

Importar el dump:

- `deployment/database/bootstrap.sql`

Ejemplo:

```bash
mysql -u USER -p DATABASE_NAME < deployment/database/bootstrap.sql
```

### 4. Permisos

Asegurar permisos de escritura en:

- `storage/`
- `bootstrap/cache/`

### 5. Enlace de storage

```bash
php artisan storage:link
```

### 6. Limpiar caches y regenerar vistas

```bash
php artisan optimize:clear
php artisan view:cache
```

### 7. Smoke minimo

Verificar:

- home
- login admin
- listado de eventos
- detalle de evento
- checkout Stripe basico

## Notas

- Si el servidor no incluye `vendor/`, correr `composer install` antes del smoke.
- Si cambian assets frontend, subir tambien `public/assets` y cualquier build necesaria.
- Este flujo reemplaza `install/` y el instalador web.
