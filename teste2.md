# 🚀 CRUD Laravel + Next.js + MySQL (Ambiente de Desenvolvimento)

## ⚠️ Aviso Importante
Este projeto está configurado **apenas para ambiente de desenvolvimento**.  

Para rodar em **produção**, será necessário:
- Ajustar variáveis de ambiente (`APP_ENV=production`, `APP_DEBUG=false`, etc.)
- Executar cache/configuração do Laravel (`php artisan config:cache`, `php artisan route:cache`, etc.)
- Criar um `Dockerfile` específico para o frontend (`next build` + `next start`)
- Ajustar segurança (HTTPS, usuários não-root, permissões de arquivos)

> ⚠️ O arquivo **`.env.example`** contém apenas **dados simplificados para dev** (usuário, senha e banco básicos, além de seeds de teste).  
> **Nunca use esse `.env` em produção** — crie um `.env` seguro e sem seeds.

---

## ✅ Requisitos
- [Docker](https://docs.docker.com/get-docker/)  
- [Docker Compose](https://docs.docker.com/compose/install/)  
- Portas livres:
  - **80** → Nginx (API)
  - **3000** → Next.js (Frontend)
  - **3306** → MySQL (Banco de dados)

---

## 🚀 Setup Automático (Recomendado)

Na raiz do projeto, rode:

```bash
./setup.sh
```

Esse script faz automaticamente:
1. Garante que exista `backend/.env` (copiado de `.env.example` apenas em dev)
2. Sobe todos os containers (`backend`, `frontend`, `nginx`, `mysql`)
3. Instala dependências (`composer install` + `npm install`)
4. Gera `APP_KEY` do Laravel (se não existir)
5. Executa migrations + seeds
6. **Roda a suíte de testes (`php artisan test`) usando SQLite em memória**
7. Inicia o **frontend em modo dev**

🔗 Após execução, acesse:
- **Frontend:** [http://localhost:3000](http://localhost:3000)  
- **API Laravel:** [http://localhost/api/vagas](http://localhost/api/vagas)  
- **API Laravel:** [http://localhost/api/candidatos](http://localhost/api/candidatos)  

---

## 🔧 Alternativa: Comandos Manuais

```bash
# 1) Garantir .env do backend (apenas DEV)
[ -f backend/.env ] || cp backend/.env.example backend/.env

# 2) Subir containers (com build)
docker compose up -d --build

# 3) Backend: instalar dependências e APP_KEY
docker compose exec -w /var/www/html backend composer install --no-interaction --prefer-dist
docker compose exec -w /var/www/html backend php artisan key:generate || true

# 4) Garantir que o MySQL está pronto
docker compose exec mysql mysqladmin ping -h 127.0.0.1 -uroot -prootpass --silent || sleep 5

# 5) Limpar configs e rodar migrations + seeds
docker compose exec -w /var/www/html backend php artisan config:clear
docker compose exec -w /var/www/html backend php artisan migrate:fresh --seed

# 6) Rodar os testes do backend (SQLite em memória)
docker compose exec -e APP_ENV=testing -e DB_CONNECTION=sqlite -e DB_DATABASE=":memory:" -w /var/www/html backend php artisan test --ansi

# 7) Frontend: instalar deps e iniciar em modo dev
docker compose exec -w /usr/src/app frontend npm install
docker compose exec -d -w /usr/src/app frontend sh -lc "npm run dev -- -H 0.0.0.0 -p 3000"
```

---

## 🌐 URLs
- **Frontend (Next.js):** [http://localhost:3000](http://localhost:3000)  
- **API (Laravel):** [http://localhost/api](http://localhost/api)  
- **MySQL:** `localhost:3306`  
  - DB: `appdb`  
  - User: `appuser`  
  - Pass: `apppass`

> O frontend consome a API via `NEXT_PUBLIC_API_URL=http://localhost/api`.

---

## 📌 Comandos Úteis

```bash
# Logs de todos os serviços
docker compose logs -f

# Acessar container do backend
docker compose exec backend bash

# Comandos artisan
docker compose exec backend php artisan route:list
docker compose exec backend php artisan migrate
docker compose exec backend php artisan db:seed

# Rodar novamente a suíte de testes (SQLite em memória)
docker compose exec -e APP_ENV=testing -e DB_CONNECTION=sqlite -e DB_DATABASE=":memory:" backend php artisan test --ansi

# MySQL CLI
docker compose exec mysql mysql -uappuser -papppass appdb -e "SHOW TABLES;"

# Resetar completamente (containers + volumes)
docker compose down -v
./setup.sh
```

---

## 📂 Estrutura Resumida

```
/
├─ backend/         # Laravel API (CRUD de Vagas e Candidatos)
├─ frontend/        # Next.js + Tailwind (UI)
├─ docker/          # Dockerfiles e configs (nginx, backend, etc.)
├─ setup.sh         # Script automático de inicialização
└─ docker-compose.yml
```

---

## 🔄 Fluxo Rápido de Desenvolvimento
1. Execute:  
   ```bash
   ./setup.sh
   ```
2. Acesse:  
   - Frontend → [http://localhost:3000](http://localhost:3000)  
   - API → [http://localhost/api/vagas](http://localhost/api/vagas)  
3. Desenvolva frontend/backend normalmente ✨  

<p align="center">
  <img src="https://github.com/user-attachments/assets/517bd7c9-f25c-44a5-a2f2-b74e5bc310a1" width="200"/>
  <img src="https://github.com/user-attachments/assets/d47f46bb-749a-4cb2-8a9b-4971cb3af610" width="200"/>
  <img src="https://github.com/user-attachments/assets/16efdd3b-d7d5-46dd-833d-7d769f11d789" width="200"/>
  <img src="https://github.com/user-attachments/assets/2b334a47-30c6-45fb-bbeb-54174d2c6f10" width="200"/>
  <img src="https://github.com/user-attachments/assets/c4eb697f-15f2-4f08-a5b7-aace7ba7f49c" width="200"/>
  <img src="https://github.com/user-attachments/assets/3ddc056c-ffbf-493c-9843-65f1f49e152b" width="200"/>
  <img src="https://github.com/user-attachments/assets/e2331b23-b3fc-4f8b-a46e-5000742d3c5a" width="200"/>
</p>

