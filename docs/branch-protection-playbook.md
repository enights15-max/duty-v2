# Branch Protection Playbook (P2-03 Iteracion 4)

## Estado actual
- Remoto detectado en este entorno: `ssh://dutyrdco@duty.do/...`
- No hay `gh` CLI instalado.
- Por lo anterior, la configuracion remota de branch protection no puede aplicarse automaticamente desde esta maquina.

## Opcion A: GitHub (automatizada por script)
Si el repositorio existe en GitHub, ejecutar:

```bash
GITHUB_TOKEN=<token_con_repo_admin> \
./scripts/ci/configure-branch-protection-github.sh <owner> <repo> main
```

El script exige:
- Required status check: `Actor Smoke Tests`
- Requiere 1 aprobacion de PR
- Bloquea force-push y delete
- Requiere resolucion de conversaciones

## Opcion B: Fallback local (hosting no-GitHub)
Activar hook local para bloquear pushes con smoke tests en rojo:

```bash
git config core.hooksPath scripts/git-hooks
```

Esto ejecuta el gate antes de cada `git push`:
- actor + marketplace + API alignment + scanner/booking contracts.

## Gate objetivo
- Workflow: `.github/workflows/actor-smoke-tests.yml`
- Reporte JUnit: `test-results/actor-smoke-junit.xml`
- Artifact en Actions: `actor-smoke-junit`
