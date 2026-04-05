#!/bin/bash

set -e

echo "🚀 Setting up project..."

# Step 1: Ensure .env exists
if [ ! -f .env ]; then
  cp .env.example .env
  echo "✅ .env file created from template"
else
  echo "⚠️ .env already exists"
fi

# Step 2: Ask for DB config BEFORE docker
echo ""
read -p "Do you wish to update DB settings in .env? (y/n): " confirm

if [ "$confirm" = "y" ]; then

  read -p "Enter DB_DATABASE: " DB_DATABASE
  read -p "Enter DB_USERNAME: " DB_USERNAME
  read -p "Enter DB_PASSWORD: " DB_PASSWORD

  echo "🔧 Updating .env..."

  sed -i.bak "s|^DB_DATABASE=.*|DB_DATABASE=$DB_DATABASE|" .env
  sed -i.bak "s|^DB_USERNAME=.*|DB_USERNAME=$DB_USERNAME|" .env
  sed -i.bak "s|^DB_PASSWORD=.*|DB_PASSWORD=\"$DB_PASSWORD\"|" .env

  echo "⚠️ Resetting database (required for new credentials)..."
  docker-compose down -v
fi

# 🔥 IMPORTANT FIX: Load .env into shell for docker-compose
echo ""
echo "📄 Loading environment variables..."

set -o allexport
source .env
set +o allexport

# Debug (optional)
echo "🔍 DB Config:"
echo "DB_DATABASE=$DB_DATABASE"
echo "DB_USERNAME=$DB_USERNAME"

# Step 3: Start Docker
docker-compose up -d --build

# Step 4: Wait for MySQL to be healthy
echo ""
echo "⏳ Waiting for MySQL to be ready..."

DB_CONTAINER=$(docker ps -a --filter "name=db" --format "{{.Names}}" | head -n 1)

if [ -z "$DB_CONTAINER" ]; then
  echo "❌ DB container not found!"
  docker-compose logs db
  exit 1
fi

while true; do
  STATUS=$(docker inspect --format='{{.State.Health.Status}}' $DB_CONTAINER 2>/dev/null || echo "starting")

  if [ "$STATUS" = "healthy" ]; then
    echo "✅ MySQL is ready!"
    break
  elif [ "$STATUS" = "unhealthy" ]; then
    echo "❌ MySQL failed to start!"
    docker-compose logs db
    exit 1
  else
    echo "⏳ Waiting for DB..."
    sleep 3
  fi
done

# Step 5: Get app container
APP_CONTAINER=$(docker ps --filter "status=running" --filter "name=app" --format "{{.Names}}" | head -n 1)

if [ -z "$APP_CONTAINER" ]; then
  echo "❌ App container not running!"
  docker-compose logs app
  exit 1
fi

echo "📦 App container: $APP_CONTAINER"

# Step 6: Install Composer dependencies
echo ""
echo "📦 Installing PHP dependencies..."
docker exec -it $APP_CONTAINER composer install \
  --no-interaction \
  --prefer-dist \
  --optimize-autoloader \
  --no-scripts \
  --no-progress

# Step 7: Generate app key
echo ""
echo "🔑 Generating app key..."
docker exec -it $APP_CONTAINER php artisan key:generate

# Step 8: Clear config cache
docker exec -it $APP_CONTAINER php artisan config:clear

# Step 9: Build frontend
echo ""
echo "📦 Installing frontend..."
docker exec -it $APP_CONTAINER npm install
docker exec -it $APP_CONTAINER npm run build

# Step 10: Run migrations
echo ""
read -p "Run migrations now? (y/n): " migrate_confirm

if [ "$migrate_confirm" = "y" ]; then
  docker exec -it $APP_CONTAINER php artisan migrate
else
  echo "👉 Skipping migration. Run manually when ready."
fi

echo ""
echo "🎉 Setup completed successfully!"