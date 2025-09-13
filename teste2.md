# Instruções Rápidas para Rodar o Projeto

## Requisitos
- Docker e Docker Compose
- Portas livres: 80, 3000, 3306

## Subir o ambiente
```bash
# Build e sobe todos os containers
docker compose up -d --build

# Preparar banco (migrations + seeders)
docker compose exec backend php artisan migrate:fresh --seed
```

> Caso haja problema de permissão no Laravel:
```bash
docker compose exec -u 0 backend sh -c "
  mkdir -p /var/www/html/storage/logs /var/www/html/bootstrap/cache &&
  chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap &&
  chmod -R ug+rwX /var/www/html/storage /var/www/html/bootstrap &&
  touch /var/www/html/storage/logs/laravel.log &&
  chown www-data:www-data /var/www/html/storage/logs/laravel.log
"
```

## URLs
- Frontend (Next.js): http://localhost:3000  
- API (Laravel): http://localhost/api  
- MySQL: `localhost:3306` (DB: `appdb`, user: `appuser`, pass: `apppass`)

> O frontend consome a API via `NEXT_PUBLIC_API_URL=http://localhost/api`.

## Comandos úteis
```bash
# Logs de todos os serviços
docker compose logs -f

# Acessar container backend
docker compose exec backend bash

# Rodar comandos artisan
docker compose exec backend php artisan route:list

docker compose exec backend php artisan migrate

docker compose exec backend php artisan db:seed

# MySQL CLI
docker compose exec mysql mysql -uappuser -papppass appdb -e "SHOW TABLES;"

# Reconstruir e reiniciar
docker compose down -v
docker compose up -d --build
```

## Estrutura resumida
```
/
├─ backend/         # Laravel
├─ frontend/        # Next.js
└─ docker/          # Dockerfiles e configs
```

## Fluxo rápido de desenvolvimento
1. Subir containers: `docker compose up -d --build`  
2. Migrar + seed: `docker compose exec backend php artisan migrate:fresh --seed`  
3. Acessar frontend e API  
4. Editar telas e backend conforme necessário