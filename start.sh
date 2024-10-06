#!/bin/bash

create_env_file() {
  if ! [ -f .env ]; then
    cp .env.example .env || { echo "Error copying .env.example to .env"; exit 1; }
  fi
}

check_laravel_project_dir() {
  if ! [ -n "$LARAVEL_PROJECT_DIR" ]; then
    echo "Variable LARAVEL_PROJECT_DIR is not set. Exiting..."
    exit 1
  fi
}

create_laravel_project_dir() {
  check_laravel_project_dir
  if [ ! -d "$LARAVEL_PROJECT_DIR" ]; then
    echo "Creating directory $LARAVEL_PROJECT_DIR"
    mkdir "$LARAVEL_PROJECT_DIR"
  fi
}

check_dir_owner() {
  OWNER=$(stat -c "%U" "$1")
  if ! [ "$OWNER" = "$USER" ]; then
    echo "$USER does not own $LARAVEL_PROJECT_DIR. Please change owner of $LARAVEL_PROJECT_DIR to $USER. Exiting..."
    exit 1
  fi
}

run_docker_compose() {
  if docker compose ps -q; then
    echo "Docker container is already running"
    echo "Turning off container"
    docker compose down
  fi

  echo "Directory $LARAVEL_PROJECT_DIR is empty executing docker compose build and docker compose up -d"
  docker-compose build || { echo "Error building docker compose"; exit 1; }
  docker-compose up -d || { echo "Error starting docker compose"; exit 1; }
}

composer_create_laravel_project() {
    echo "Creating Laravel project in $LARAVEL_PROJECT_DIR"
    docker-compose exec php-fpm composer create-project --prefer-dist laravel/laravel . || { echo "Error creating Laravel project"; exit 1; }
}

create_env_file
source .env
create_laravel_project_dir

FOLDER_PATH="$PWD"/"$LARAVEL_PROJECT_DIR"
if ! [ -z "$(ls -A "$FOLDER_PATH")" ]; then
  echo "Directory $LARAVEL_PROJECT_DIR is not empty."
  echo "Starting docker compose"
  run_docker_compose
  exit 0
else
  check_dir_owner "$FOLDER_PATH"
  run_docker_compose
  composer_create_laravel_project
  echo echo "Script finished"
  exit 0
fi
