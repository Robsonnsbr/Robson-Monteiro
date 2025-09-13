#!/usr/bin/env bash
set -euo pipefail

echo "==> [1/8] Verificando Docker Compose..."
docker compose version >/dev/null

echo "==> [2/8] Garantindo .env do backend..."
if [ ! -f backend/.env ]; then
  cp backend/.env.example backend/.env
  echo "    - backend/.env criado a partir do .env.example"
else
  echo "    - backend/.env já existe"
fi

echo "==> [3/8] Subindo containers (build se necessário)..."
docker compose up -d --build

echo "==> [4/8] Instalando dependências do backend (composer)..."
docker compose exec -w /var/www/html backend composer install --no-interaction --prefer-dist

echo "==> [5/8] Gerando APP_KEY (se necessário)..."
if ! docker compose exec -w /var/www/html backend sh -lc "grep -q '^APP_KEY=base64:' .env"; then
  docker compose exec -w /var/www/html backend php artisan key:generate
  echo "    - APP_KEY gerado"
else
  echo "    - APP_KEY já definido"
fi

echo "==> [6/8] Rodando migrations + seeds..."
docker compose exec -w /var/www/html backend php artisan migrate:fresh --seed

echo "==> [7/8] Instalando dependências do frontend (npm)..."
docker compose exec -w /usr/src/app frontend npm install

echo "==> [8/8] Iniciando frontend em modo dev..."
docker compose exec -d -w /usr/src/app frontend sh -lc "npm run dev -- -H 0.0.0.0 -p 3000"

echo ""
echo "✅ Projeto pronto!"
echo "   Backend (Laravel API): http://localhost/api/vagas  |  http://localhost/api/candidatos"
echo "   Frontend (Next.js):    http://localhost:3000"
echo ""
echo "👉 Logs do frontend: docker compose logs -f frontend"
