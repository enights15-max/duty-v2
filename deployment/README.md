# Deployment

Este directorio reemplaza el flujo antiguo basado en `install/` y en el instalador web.

## Objetivo

A futuro, el despliegue del proyecto debe funcionar con un flujo simple:

1. subir archivos del proyecto al servidor
2. configurar `.env`
3. importar la base de datos base
4. dar permisos a carpetas necesarias
5. limpiar y regenerar caches

## Contenido

- `database/bootstrap.sql`
  - dump base del sistema para instalaciones manuales
- `checklists/install-manual.md`
  - pasos operativos de instalación
- `env/.env.example.production`
  - ejemplo base de variables para producción/beta cerrada

## Nota

`database/bootstrap.sql` queda como la fuente canónica actual para instalaciones manuales del proyecto.

El dump proviene del flujo antiguo de instalación, pero ya no depende del instalador web ni de la carpeta `install/`.
