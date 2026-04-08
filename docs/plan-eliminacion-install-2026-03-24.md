# Plan de Eliminacion de `install/` y del Instalador Web

Fecha: 2026-03-24
Estado: Ejecutado
Objetivo: eliminar el proyecto duplicado `install/` y migrar a un flujo simple de despliegue basado en `subir archivos + importar base de datos + configurar .env`.

## Decision objetivo

Mantener una sola aplicacion canónica en el root del proyecto y retirar:

1. `install/` como segundo proyecto embebido.
2. el instalador web basado en `kreativdev/installer`.
3. los assets, vistas, traducciones y dumps acoplados al instalador.

## Beneficio esperado

- una sola base de codigo real
- menos trabajo duplicado en views/controllers/envs
- menos peso del repo
- menos riesgo de inconsistencias entre root e install
- despliegue beta mas simple

## Lo que se elimina

### Fase 1. Proyecto duplicado `install/`

Estado actual:
- ejecutada

Eliminar por completo:

- `/Users/monkeyinteractive/DEV/v2/install/`
- `/Users/monkeyinteractive/DEV/v2/install/installable.zip`

Esto remueve de una vez:

- `install/app`
- `install/bootstrap`
- `install/config`
- `install/database`
- `install/public`
- `install/resources`
- `install/routes`
- `install/storage`
- `install/tests`
- `install/vendor`
- `install/.env`
- `install/.env.example`
- `install/composer.json`
- `install/composer.lock`

### Fase 2. Instalador web embebido en el root

Estado actual:
- ejecutada

Eliminar dependencias y configuracion:

- `/Users/monkeyinteractive/DEV/v2/composer.json`
  - quitar `"kreativdev/installer": "^1.0"`
- `/Users/monkeyinteractive/DEV/v2/composer.lock`
  - regenerar tras `composer update` o `composer remove kreativdev/installer`
- `/Users/monkeyinteractive/DEV/v2/config/installer.php`

Eliminar vistas publicadas del instalador:

- `/Users/monkeyinteractive/DEV/v2/resources/views/vendor/installer/environment.blade.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/vendor/installer/requirements.blade.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/vendor/installer/layouts/master.blade.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/vendor/installer/layouts/master-update.blade.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/vendor/installer/environment-classic.blade.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/vendor/installer/permissions.blade.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/vendor/installer/finished.blade.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/vendor/installer/license.blade.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/vendor/installer/environment-wizard.blade.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/vendor/installer/welcome.blade.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/vendor/installer/update/finished.blade.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/vendor/installer/update/overview.blade.php`
- `/Users/monkeyinteractive/DEV/v2/resources/views/vendor/installer/update/welcome.blade.php`

Eliminar traducciones del instalador:

- `/Users/monkeyinteractive/DEV/v2/resources/lang/en/installer_messages.php`

Eliminar assets y dump ligados al instalador:

- `/Users/monkeyinteractive/DEV/v2/public/installer/`
  - incluye:
    - `css/`
    - `img/`
    - `fonts/`
    - `database.sql`

### Fase 3. Nuevo flujo simple de despliegue

Estado actual:
- reemplazo base creado en `deployment/`

Crear una estructura nueva y explicita para despliegue manual.

Propuesta:

- `/Users/monkeyinteractive/DEV/v2/deployment/README.md`
- `/Users/monkeyinteractive/DEV/v2/deployment/database/bootstrap.sql`
- `/Users/monkeyinteractive/DEV/v2/deployment/checklists/install-manual.md`
- `/Users/monkeyinteractive/DEV/v2/deployment/env/.env.example.production`

## Fuente canónica de base de datos

Actualmente el dump visible acoplado al instalador es:

- `/Users/monkeyinteractive/DEV/v2/public/installer/database.sql`

Si se elimina el instalador, ese archivo debe migrarse a una ruta neutral, por ejemplo:

- `/Users/monkeyinteractive/DEV/v2/deployment/database/bootstrap.sql`

## Cambios exactos por archivo

### 1. `composer.json`

Accion:
- eliminar la dependencia `kreativdev/installer`

Impacto:
- el paquete deja de autodescubrir rutas/controladores del instalador

### 2. `composer.lock`

Accion:
- regenerar el lock sin `kreativdev/installer`

Impacto:
- limpia el vendor tree en siguiente install/update

### 3. `config/installer.php`

Accion:
- borrar archivo

Impacto:
- la app deja de cargar config del instalador

### 4. `resources/views/vendor/installer/**`

Accion:
- borrar carpeta completa

Impacto:
- se eliminan las pantallas `/install` y `/update` del instalador web

### 5. `resources/lang/en/installer_messages.php`

Accion:
- borrar archivo

Impacto:
- se limpia el bundle de traducciones del instalador

### 6. `public/installer/**`

Accion:
- borrar carpeta completa

Impacto:
- se eliminan CSS/images/fonts del instalador y el dump SQL expuesto publicamente

### 7. `install/**`

Accion:
- borrar carpeta completa

Impacto:
- desaparece el proyecto espejo y el zip instalable

## Lo que no hace falta tocar para esta eliminacion

No es necesario tocar de entrada:

- `/Users/monkeyinteractive/DEV/v2/routes/*.php`
  - no encontramos rutas propias del proyecto cableando el instalador; venian del paquete
- `/Users/monkeyinteractive/DEV/v2/app/**`
  - no vimos controladores propios del proyecto dependientes del instalador
- `/Users/monkeyinteractive/DEV/v2/database/migrations/**`
  - salvo que quieras cambiar estrategia de bootstrap despues

## Riesgos reales

### Riesgo bajo
- perder una superficie de instalacion que hoy ya no aporta mucho
- referencias residuales en docs o scripts internos

### Riesgo medio
- que alguna doc vieja siga asumiendo `installable.zip`
- que algun proceso manual de ventas/distribucion todavia entregue el zip de `install/`

### Riesgo alto
- ninguno tecnico serio para runtime de la app, siempre que el nuevo flujo de despliegue quede documentado

## Recomendacion de ejecucion

### Paso A. Preparar el reemplazo

Antes de borrar:

1. mover `public/installer/database.sql` a `deployment/database/bootstrap.sql`
2. crear `deployment/README.md`
3. crear checklist corta de instalacion manual

### Paso B. Eliminar el proyecto duplicado

1. borrar `install/`
2. borrar `install/installable.zip`

### Paso C. Eliminar el instalador web

1. quitar `kreativdev/installer` de `composer.json`
2. borrar `config/installer.php`
3. borrar `resources/views/vendor/installer/`
4. borrar `resources/lang/en/installer_messages.php`
5. borrar `public/installer/`
6. regenerar `composer.lock`

### Paso D. Checks minimos despues de la poda

1. `composer install` o `composer update` segun el camino elegido
2. `php artisan optimize:clear`
3. `php artisan view:cache`
4. smoke simple:
   - home
   - login
   - event listing
   - event detail
   - checkout basico

## Comandos sugeridos para la ejecucion real

```bash
rm -rf /Users/monkeyinteractive/DEV/v2/install
rm -rf /Users/monkeyinteractive/DEV/v2/public/installer
rm -rf /Users/monkeyinteractive/DEV/v2/resources/views/vendor/installer
rm -f /Users/monkeyinteractive/DEV/v2/resources/lang/en/installer_messages.php
rm -f /Users/monkeyinteractive/DEV/v2/config/installer.php
```

Luego ajustar dependencias:

```bash
composer remove kreativdev/installer
php artisan optimize:clear
php artisan view:cache
```

## Orden recomendado

1. crear `deployment/` y mover el dump SQL
2. eliminar `install/`
3. eliminar instalador web del root
4. hacer smoke minimo

## Mi recomendacion final

La eliminacion tiene sentido y esta alineada con la etapa actual del producto.

Si vamos a ejecutarla, el orden correcto es:

1. crear reemplazo minimo de despliegue
2. borrar `install/`
3. borrar instalador web
4. seguir trabajando con una sola app canónica
