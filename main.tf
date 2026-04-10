# --- Configuration Terraform et Provider ---
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# --- 1. Ressource : Base de Données PostgreSQL ---
resource "docker_image" "postgres_image" {
  name         = "postgres:latest"
  keep_locally = true
}

resource "docker_container" "db_container" {
  name  = "tp-db-postgres"
  image = docker_image.postgres_image.name

  ports {
    internal = 5432
    external = 5432
  }

  env = [
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=${var.db_name}",
  ]
}

# --- 2. Ressource : Application Web Nginx ---
resource "docker_image" "app_image" {
  name         = "nginx:alpine"
  keep_locally = true
}

resource "docker_container" "app_container" {
  name  = "tp-app-web"
  image = docker_image.app_image.name

  depends_on = [docker_container.db_container]

  command = [
    "sh",
    "-c",
    "printf '%s\\n' '<h1>Application Web - TP DevOps</h1>' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'",
  ]

  ports {
    internal = 80
    external = var.app_port_external
  }
}
