# 🚀 TailAdmin Laravel (Dockerized Setup)

This repository is based on the official TailAdmin Laravel template:

👉 https://github.com/TailAdmin/tailadmin-laravel

We have extended it by adding:

* 🐳 Docker support (PHP 8.3, Nginx, MySQL)
* ⚙️ Automated setup script (`setup.sh`)
* 📦 Auto installation of Composer dependencies
* 🎨 Auto installation & build of frontend assets (Vite)

---

## 📌 Requirements

Make sure you have the following installed:

* Docker Desktop (must be running)
* Git
* Git Bash (Windows) / Terminal (Mac/Linux)

---

## ⚡ Quick Setup

After cloning the repository:

```bash
git clone git@github.com:FerasaSoftwares/TailAdmin-laravel-Docker.git
cd TailAdmin-laravel-Docker
```

Run the setup script:

```bash
bash setup.sh
```

---

## 🧠 What the Setup Script Does

The script will:

1. Create `.env` file from `.env.example`
2. Ask if you want to update database configuration
3. Start Docker containers (App, Nginx, MySQL)
4. Wait until MySQL is ready
5. Install Composer dependencies
6. Generate Laravel app key
7. Install Node modules & build assets
8. Optionally run database migrations

---

## 🗄️ Database Configuration

During setup, you will be asked:

```
Do you wish to update DB settings in .env? (y/n):
```

If yes, you can enter:

* `DB_DATABASE`
* `DB_USERNAME`
* `DB_PASSWORD`
* `DB_ROOT_PASSWORD`

### ⚠️ Important Notes

* Database is automatically created by Docker
* If you change DB credentials later, the database will be reset
* Recommended default:

```env
DB_DATABASE=app_db
DB_USERNAME=app_user
DB_PASSWORD=secret
DB_ROOT_PASSWORD=root
```

---

## 🌐 Access the Application

After setup completes:

👉 http://localhost:8000

---

## 🐳 Docker Services

| Service   | Description       |
| --------- | ----------------- |
| app       | Laravel (PHP 8.3) |
| webserver | Nginx             |
| db        | MySQL 8           |

---

## 🔧 Useful Commands

### Run Laravel commands

```bash
docker exec -it <app_container> php artisan <command>
```

Example:

```bash
docker exec -it <app_container> php artisan migrate
```

---

### Access container shell

```bash
docker exec -it <app_container> bash
```

---

### Restart containers

```bash
docker-compose restart
```

---

### Stop containers

```bash
docker-compose down
```

---

### Reset database (important)

```bash
docker-compose down -v
```

---

### Reset Whole Project (important)

```bash
docker-compose down -v --remove-orphans
rm -rf vendor
rm -rf node_modules
rm -rf public/build
rm .env
```

---

## 🎨 Frontend (Vite)

### Development mode (hot reload)

```bash
docker exec -it <app_container> npm run dev
```

---

### Production build

```bash
docker exec -it <app_container> npm run build
```

---

## ⚠️ Troubleshooting

### 1. Docker not running

Make sure Docker Desktop is open and running.

---

### 2. Port already in use

Change port in `docker-compose.yml`:

```yaml
ports:
  - "8001:80"
```

---

### 3. Database connection issues

Run:

```bash
docker-compose down -v
docker-compose up -d --build
```

---

### 4. Permission issues

```bash
docker exec -it <app_container> chmod -R 775 storage bootstrap/cache
```

---

## 📦 About TailAdmin

TailAdmin is a modern Tailwind CSS-based admin dashboard for Laravel.

This project uses the official TailAdmin Laravel template and enhances it with Docker and automation for faster development and onboarding.

---

## 🙌 Contribution

Feel free to fork, improve, and use this setup for your own projects.

---

## 📄 License

This project follows the same license as the original TailAdmin Laravel template.
