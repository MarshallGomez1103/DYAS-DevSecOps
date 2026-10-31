#!/usr/bin/env bash
set -euo pipefail

raiz="$(cd "$(dirname "$0")/../../.." && pwd)"
temporal="$(mktemp -d)"
trap 'rm -rf "$temporal"' EXIT
cat > "$temporal/docker" <<'EOF'
#!/usr/bin/env bash
case "$1" in
  ps)
    [[ "$CASO" != error ]] || exit 1
    [[ "$CASO" == ausente ]] || echo reservas-app-1
    ;;
  inspect)
    case "$CASO" in
      local) echo IP=127.0.0.1 ;;
      ipv6) echo IP=::1 ;;
      publico) echo IP=0.0.0.0 ;;
      vacio) echo IP= ;;
      *) exit 1 ;;
    esac
    ;;
  *) exit 1 ;;
esac
EOF
chmod +x "$temporal/docker"
export PATH="$temporal:$PATH"

for CASO in ausente local ipv6; do
  export CASO
  "$raiz/scripts/verificar-entorno-local.sh"
done
for CASO in publico vacio error inspect_error; do
  export CASO
  if "$raiz/scripts/verificar-entorno-local.sh" 2>/dev/null; then
    echo "El caso $CASO debió bloquear el despliegue." >&2
    exit 1
  fi
done
echo 'Aislamiento local: siete casos verificados.'
