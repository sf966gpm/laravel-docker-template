#!/bin/bash

# check if .env file exists
if ! [ -f .env ]; then
  cp .env.example .env
fi

source .env

# check if variable is set
if ! [ -n "$LARAVEL_PROJECT_DIR" ]; then
  echo "Variable LARAVEL_PROJECT_DIR is not set. Exiting..."
  exit 1
fi

# check if directory not exists and create it
if [ ! -d "$LARAVEL_PROJECT_DIR" ]; then
  echo "Creating directory $LARAVEL_PROJECT_DIR"
  mkdir "$LARAVEL_PROJECT_DIR"
fi

# check if directory is empty
if [ -z "$(ls -A "$PWD"/"$LARAVEL_PROJECT_DIR")" ]; then

  if docker compose ps -q; then
    echo "Docker container is already running"
    echo "Turning off container"
    docker compose down
  fi

  echo "Directory $LARAVEL_PROJECT_DIR is empty executing docker compose build and docker compose up -d"
  docker-compose build || { echo "Error building docker compose"; exit 1; }
  docker-compose up -d || { echo "Error starting docker compose"; exit 1; }
  echo "Creating Laravel project in $LARAVEL_PROJECT_DIR"
  docker-compose exec php-fpm composer create-project --prefer-dist laravel/laravel . || { echo "Error creating Laravel project"; exit 1; }
  echo "Script finished"
  exit 0
else
  echo "Directory $LARAVEL_PROJECT_DIR is not empty. Exiting script..."
  exit 1
fi