#!/usr/bin/env bash
set -euo pipefail

# install_scripts/n8n.sh
# Instalação não-interativa do n8n (Node.js + n8n) com serviço systemd.
# Executar como root.

REQUIRED_PKGS="curl gnupg ca-certificates build-essential"
NODE_SETUP_URL="https://deb.nodesource.com/setup_18.x"
N8N_USER="n8n"
N8N_HOME="/var/lib/n8n"
SYSTEMD_UNIT_PATH="/etc/systemd/system/n8n.service"

log() { echo "[n8n-install] $*"; }
err() { echo "[n8n-install][ERRO] $*" >&2; }

if [[ "$(id -u)" -ne 0 ]]; then
  err "Este script deve ser executado como root. Use sudo."
  exit 1
fi

log "Atualizando apt e instalando dependências básicas..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y ${REQUIRED_PKGS}

log "Instalando Node.js 18 (NodeSource)..."
curl -fsSL "${NODE_SETUP_URL}" | bash -
apt-get install -y nodejs

log "Instalando n8n globalmente via npm..."
npm install -g n8n

log "Criando usuário e diretório persistente para n8n..."
if ! id -u "${N8N_USER}" &>/dev/null; then
  useradd -r -m -d "${N8N_HOME}" -s /usr/sbin/nologin "${N8N_USER}"
fi
mkdir -p "${N8N_HOME}"
chown -R "${N8N_USER}:${N8N_USER}" "${N8N_HOME}"

log "Criando unidade systemd em ${SYSTEMD_UNIT_PATH}..."
cat > "${SYSTEMD_UNIT_PATH}" <<'UNIT'
[Unit]
Description=n8n automation
After=network.target

[Service]
Type=simple
User=n8n
Environment=NODE_ENV=production
# Porta padrão do n8n
Environment=N8N_PORT=5678
Environment=N8N_HOST=0.0.0.0
# Desabilitado por padrão; habilite e configure N8N_BASIC_AUTH_ACTIVE=true e as credenciais via systemd drop-in ou /etc/environment
Environment=N8N_BASIC_AUTH_ACTIVE=false
WorkingDirectory=/var/lib/n8n
ExecStart=/usr/bin/env n8n
Restart=on-failure
RestartSec=5s
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
UNIT

log "Definindo permissões e recarregando systemd..."
chmod 644 "${SYSTEMD_UNIT_PATH}"
systemctl daemon-reload
systemctl enable --now n8n.service

log "Instalação concluída. Verificando status do serviço..."
systemctl --no-pager status n8n.service || true

cat <<EOF

# Configuração do Nginx como Proxy Reverso para o n8n
# Cria o arquivo de configuração do site em /etc/nginx/sites-available/n8n
cat <<EOF > /etc/nginx/sites-available/n8n
server {
    listen 80;
    server_name _; # Aceita qualquer domínio apontado para este IP

    location / {
        proxy_pass http://localhost:5678;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Configurações para suportar WebSockets (necessário para o n8n)
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_buffering off;
    }
}
EOF

# Ativa o site criando um link simbólico e remove o site padrão
ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Recarrega o Nginx para aplicar as mudanças
systemctl reload nginx

Observações e próximos passos:
- A instalação padrão expõe n8n na porta 5678. Proteja com firewall/ingress ou configure proxy reverso (nginx/traefik).
- Para ativar autenticação básica (recomendado), crie um arquivo drop-in:
  mkdir -p /etc/systemd/system/n8n.service.d
  cat > /etc/systemd/system/n8n.service.d/override.conf <<'CONF'
  [Service]
  Environment="N8N_BASIC_AUTH_ACTIVE=true"
  Environment="N8N_BASIC_AUTH_USER=seu_usuario"
  Environment="N8N_BASIC_AUTH_PASSWORD=sua_senha_segura"
  CONF
  systemctl daemon-reload
  systemctl restart n8n.service

- Para usar banco de dados externo (Postgres) ou outras variáveis, exporte as variáveis N8N_* para o serviço via drop-in.
- Logs: `journalctl -u n8n.service -f`

EOF