# Testing Baseline Actor (P2-01)

## Objetivo
Reducir dependencia de migraciones legacy y estandarizar el bootstrap de esquemas minimos para smoke tests de flujos criticos.

## Implementacion
- Clase base: `tests/Support/ActorFeatureTestCase.php`
- Soporte de esquema: `tests/Support/ActorTestSchema.php`

## Uso
Cada test define declarativamente:
- `baselineSchema`: piezas de esquema requeridas (`users_customers`, `wallets`, `payment_methods`, `marketplace`, etc.).
- `baselineTruncate`: tablas a limpiar en cada `setUp`.
- `baselineDefaultLanguage`: si requiere idioma default para middleware/language-aware controllers.

Ejemplo:
```php
protected array $baselineSchema = ['users_customers', 'wallets'];
protected array $baselineTruncate = ['wallet_transactions', 'wallets', 'customers', 'users'];
protected bool $baselineDefaultLanguage = false;
```

## Beneficios
- Menor duplicacion entre tests.
- Menor acoplamiento a estado global de migraciones.
- Onboarding mas rapido para nuevos smoke tests.

## CI Gate Asociado
- Workflow: `.github/workflows/actor-smoke-tests.yml`
- Salidas:
  - Resultado de suite smoke (actor + marketplace + alineacion API + scanner/booking contracts)
  - Reporte JUnit: `test-results/actor-smoke-junit.xml`
  - Artifact en GitHub Actions: `actor-smoke-junit`
