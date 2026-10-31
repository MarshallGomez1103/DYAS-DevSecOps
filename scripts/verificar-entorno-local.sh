#!/usr/bin/env bash
# Impide desplegar si el contenedor local anterior sigue publicado fuera de loopback.
set -euo pipefail

contenedor="$(docker ps --filter 'name=^/reservas-app-1$' --format '{{.Names}}')"
[[ "$contenedor" == 'reservas-app-1' ]] || exit 0

direcciones="$(docker inspect --format '{{range $puertos := .NetworkSettings.Ports}}{{range $puertos}}{{printf "IP=%s\n" .HostIp}}{{end}}{{end}}' "$contenedor")"
while IFS= read -r direccion; do
  case "$direccion" in
    ''|IP=127.0.0.1|IP=::1) ;;
    *) echo "El contenedor local reservas-app-1 publica puertos fuera de loopback. Deténgalo o recréelo con la configuración actual." >&2; exit 1 ;;
  esac
done <<< "$direcciones"
