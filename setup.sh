#!/usr/bin/env bash
set -euo pipefail

echo "==> [1/10] Verificando Docker Compose..."
docker compose version >/dev/null

echo "==> [2/10] Garantindo .env do backend..."
if [ ! -f backend/.env ]; then
  cp backend/.env.example backend/.env
  echo "    - backend/.env criado a partir do .env.example"
else
  echo "    - backend/.env já existe"
fi

echo "==> [3/10] Garantindo .env.testing do backend (para rodar testes) ..."
if [ ! -f backend/.env.testing ]; then
  cat > backend/.env.testing <<'EOF'
APP_NAME=Laravel
APP_ENV=testing
APP_KEY=base64:dummyKeyForTestsOnly000000000000000000000000000=
APP_DEBUG=true
APP_URL=http://localhost

DB_CONNECTION=sqlite
DB_DATABASE=:memory:

LOG_CHANNEL=stderr
LOG_LEVEL=warning

CACHE_DRIVER=array
SESSION_DRIVER=array
QUEUE_CONNECTION=sync
MAIL_MAILER=array

SANCTUM_STATEFUL_DOMAINS=localhost:3000
EOF
  echo "    - backend/.env.testing criado"
else
  echo "    - backend/.env.testing já existe"
fi

echo "==> [4/10] Subindo containers (build se necessário)..."
docker compose up -d --build

echo "==> [5/10] Instalando dependências do backend (composer)..."
docker compose exec -w /var/www/html backend composer install --no-interaction --prefer-dist

echo "==> [6/10] Fixando permissões de storage/bootstrap (evitar erros de log em dev)..."
docker compose exec -w /var/www/html backend sh -lc '
  mkdir -p storage/logs bootstrap/cache &&
  touch storage/logs/laravel.log &&
  chown -R www-data:www-data storage bootstrap/cache &&
  chmod -R ug+rwX storage bootstrap/cache
'

echo "==> [7/10] Gerando APP_KEY (se necessário)..."
if ! docker compose exec -w /var/www/html backend sh -lc "grep -q '^APP_KEY=base64:' .env"; then
  docker compose exec -w /var/www/html backend php artisan key:generate
  echo "    - APP_KEY gerado"
else
  echo "    - APP_KEY já definido"
fi

echo "==> [8/10] Rodando migrations + seeds (ambiente dev: MySQL)..."
docker compose exec -w /var/www/html backend php artisan migrate:fresh --seed

echo "==> [9/10] Rodando TESTES do backend (usa .env.testing: SQLite em memória + log stderr)..."
# Limpa quaisquer caches para não “vazar” config do env normal
docker compose exec -w /var/www/html backend sh -lc "rm -f bootstrap/cache/config.php || true"
docker compose exec -w /var/www/html backend php artisan config:clear
docker compose exec -w /var/www/html backend php artisan cache:clear
# Executa testes (falha interrompe o setup por causa do 'set -e')
docker compose exec -w /var/www/html backend php artisan test --colors

echo "==> [10/10] Instalando dependências do frontend e iniciando dev server..."
docker compose exec -w /usr/src/app frontend npm install
docker compose exec -d -w /usr/src/app frontend sh -lc "npm run dev -- -H 0.0.0.0 -p 3000"

echo ""
echo "✅ Projeto pronto!"
echo "   Backend (Laravel API): http://localhost/api/vagas  |  http://localhost/api/candidatos"
echo "   Frontend (Next.js):    http://localhost:3000"
echo ""
echo "👉 Logs do frontend: docker compose logs -f frontend"
echo "👉 Re-rodar testes:  docker compose exec backend php artisan test"
