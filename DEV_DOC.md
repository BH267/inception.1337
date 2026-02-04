# Developer Documentation - Inception.1337

## Table of Contents

1. [Environment Setup](#environment-setup)
2. [Prerequisites](#prerequisites)
3. [Configuration Files](#configuration-files)
4. [Building and Launching](#building-and-launching)
5. [Container Management](#container-management)
6. [Volume Management](#volume-management)
7. [Data Storage and Persistence](#data-storage-and-persistence)
8. [Development Workflow](#development-workflow)
9. [Debugging](#debugging)
10. [Architecture Overview](#architecture-overview)

---

## Environment Setup

### Initial Setup from Scratch

Follow these steps to set up the Inception.1337 development environment from scratch:

#### Step 1: Clone Repository
```bash
git clone https://github.com/BH267/inception.1337.git
cd inception.1337
```

#### Step 2: Verify Prerequisites
```bash
# Check Docker installation
docker --version
docker-compose --version

# Check Make installation
make --version

# Verify Docker daemon is running
docker ps
```

#### Step 3: Create Directory Structure
```bash
# Create data directories for persistent volumes
mkdir -p /home/habenydi/data/db
mkdir -p /home/habenydi/data/wp
mkdir -p /home/habenydi/data/redis

# Set proper permissions
chmod 755 /home/habenydi/data/*
```

#### Step 4: Create Configuration Files
See the [Configuration Files](#configuration-files) section below.

#### Step 5: Create Secrets Directory and Files
See the [Secrets Management](#secrets-management) section below.

#### Step 6: Verify All Files Exist
```bash
# Check project structure
tree -L 2 srcs/
ls -la secrets/
ls -la srcs/.env
```

---

## Prerequisites

### System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| Docker | 20.10+ | 24.0+ |
| Docker Compose | 1.29+ | 2.20+ |
| RAM | 2GB | 4GB+ |
| Disk Space | 5GB | 20GB+ |
| OS | Linux/Mac | Linux (tested) |

### Required Software Installation

#### Ubuntu/Debian
```bash
# Update package manager
sudo apt update

# Install Docker
sudo apt install docker.io

# Install Docker Compose
sudo apt install docker-compose

# Install Make
sudo apt install make

# Install Git
sudo apt install git

# Start Docker daemon
sudo systemctl start docker
sudo usermod -aG docker $USER
```

#### macOS
```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Docker Desktop (includes Docker and Docker Compose)
brew install --cask docker

# Install Make
brew install make

# Start Docker (open Docker Desktop app)
open /Applications/Docker.app
```

### Verify Installation
```bash
docker version
docker-compose version
make --version
docker ps  # Should show no containers or existing ones
```

---

## Configuration Files

### .env File (Required)

Located at: `srcs/.env`

Create this file with your environment configuration:

```bash
# Domain and network configuration
DOMAIN_NAME=yourdomain.local

# MariaDB Configuration
MYSQL_ROOT_PASSWORD_FILE=root_password_file_in_secrets
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress
MYSQL_PASSWORD_FILE=wordpress_secure_password_file_in_secrets

# WordPress Configuration
WP_TITLE=My WordPress Site
WP_ADMIN_USER=wpadmin
WP_ADMIN_EMAIL=admin@yourdomain.local

# Optional: FTP Configuration
FTP_USER=ftpuser
FTP_PASS=ftp_secure_password
```

### Example .env Setup
```bash
# From project root
cd srcs

# Create .env file
cat > .env << 'EOF'
DOMAIN_NAME=habenydi.42.fr
MYSQL_ROOT_PASSWORD_FILE=/run/secrets/root_password
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD_FILE=/run/secrets/mysql_password
WP_TITLE=Inception
WP_ADMIN_USER=admin
WP_ADMIN_EMAIL=admin@inception.local
FTP_USER=ftpuser
FTP_PASS=ftppass123!
EOF

# Verify file was created
cat .env
```

### Important Notes
- ✅ Add `.env` to `.gitignore` (never commit environment variables)
- ✅ Use strong passwords (min 12 characters, mixed case, numbers, symbols)
- ✅ Keep development `.env` separate from production
- ❌ Do NOT commit `.env` to version control
- ❌ Do NOT store secrets in `.env` in production (use Docker secrets instead)

---

## Secrets Management

### Secrets Directory Structure

Located at: `secrets/`

Create the following files in the secrets directory:

```
secrets/
├── db_root_password.txt         # MariaDB root password
├── db_password.txt              # WordPress database user password
├── wp_admin_password.txt        # WordPress admin user password
└── wp_security_keys.txt         # WordPress security keys
```

### Creating Secrets Files

#### 1. Database Root Password
```bash
# Generate secure password
openssl rand -base64 32 > secrets/db_root_password.txt

# Verify
cat secrets/db_root_password.txt
```

#### 2. WordPress Database Password
```bash
# Generate secure password
openssl rand -base64 32 > secrets/db_password.txt

# Verify
cat secrets/db_password.txt
```

#### 3. WordPress Admin Password
```bash
# Generate secure password
openssl rand -base64 32 > secrets/wp_admin_password.txt

# Verify
cat secrets/wp_admin_password.txt
```

#### 4. WordPress Security Keys
```bash
# Generate WordPress security keys from official API
curl https://api.wordpress.org/secret-key/1.1/salt/ > secrets/wp_security_keys.txt

# Or manually create if curl not available
cat > secrets/wp_security_keys.txt << 'EOF'
define('AUTH_KEY',         'put your unique phrase here');
define('SECURE_AUTH_KEY',  'put your unique phrase here');
define('LOGGED_IN_KEY',    'put your unique phrase here');
define('NONCE_KEY',        'put your unique phrase here');
define('AUTH_SALT',        'put your unique phrase here');
define('SECURE_AUTH_SALT', 'put your unique phrase here');
define('LOGGED_IN_SALT',   'put your unique phrase here');
define('NONCE_SALT',       'put your unique phrase here');
EOF
```

### Security Notes
- ✅ Keep `secrets/` directory out of version control
- ✅ Use `.gitignore` to exclude secrets directory:
  ```
  secrets/
  ```
- ✅ Never commit credential files to Git
- ✅ Use strong random values for all secrets
- ✅ Rotate secrets regularly in production

---

## Building and Launching

### Using the Makefile

The project includes a Makefile for managing common tasks.

#### Available Make Commands

```bash
# Build all Docker images
make build

# Build and start all services
make up

# Stop all services
make down

# Stop, rebuild, and start
make re

# Clean up containers and temporary files
make clean

# Remove volumes (WARNING: data loss)
make fclean

# Full clean (stop, clean, remove volumes) (WARNING: data loss)
make whole-clean

# Hot restart (full clean + rebuild + start)  (WARNING: data loss)
make hot-restart
```

### Step-by-Step Launch

```bash
# 1. Navigate to project root
cd /path/to/inception.1337

# 2. Build all images (first time only, or after code changes)
make build
```

**Output example:**
```
[+] Building 124.5s (50/50) FINISHED
 => [mariadb base] FROM docker.io/library/debian:bookworm-slim
 => [mariadb builder] RUN apt-get update && apt-get install -y mariadb-server...
 ...
 => [nginx final] COPY conf/nginx.conf /etc/nginx/nginx.conf
 => [wordpress 1/3] FROM docker.io/library/debian:bookworm-slim
 ...
```

```bash
# 3. Start all services
make up
```

**Output example:**
```
[+] Running 6/6
 ✔ Network inception_network  Created
 ✔ Container mariadb          Started
 ✔ Container redis            Started
 ✔ Container wordpress         Started
 ✔ Container nginx             Started
 ✔ Container adminer           Started
 ✔ Container ftp               Started
 ✔ Container portainer         Started
 ✔ Container website           Started
```

```bash
# 4. Wait for services to initialize (30-60 seconds)
sleep 30

# 5. Verify all containers are running
docker ps
```

### Access Points After Launch

Once services are running:
- **WordPress**: https://localhost
- **WordPress Admin**: https://localhost/wp-admin
- **Adminer**: http://localhost:8080
- **Portainer**: https://localhost:9443
- **Static Website**: http://localhost:1337
- **FTP**: localhost:21

---

## Container Management

### Docker Compose Commands

#### View Running Containers
```bash
# List all running containers for this project
docker-compose -f srcs/docker-compose.yml ps

# List all containers (including stopped)
docker ps -a

# Show only running containers
docker ps

# Show container details
docker inspect mariadb
docker inspect wordpress
```

#### Managing Individual Containers

```bash
# Stop a specific container
docker-compose -f srcs/docker-compose.yml stop wordpress

# Start a specific container
docker-compose -f srcs/docker-compose.yml start wordpress

# Restart a specific container
docker-compose -f srcs/docker-compose.yml restart wordpress

# Remove a stopped container
docker-compose -f srcs/docker-compose.yml rm wordpress

# Recreate a container (pull fresh, rebuild)
docker-compose -f srcs/docker-compose.yml up -d --force-recreate wordpress
```

#### View Container Logs

```bash
# View logs for a specific service
docker logs mariadb
docker logs wordpress
docker logs nginx

# Follow logs in real-time (tail)
docker logs -f wordpress

# View last N lines
docker logs --tail 50 wordpress

# View logs with timestamps
docker logs -t wordpress

# View logs from the last hour
docker logs --since 1h wordpress

# Exit following logs
# Press Ctrl+C
```

#### Execute Commands Inside Containers

```bash
# Open interactive bash shell in container
docker exec -it wordpress bash

# Run a specific command in container
docker exec wordpress ls -la /var/www/html

# Run command in MariaDB container
docker exec mariadb mysql -u root -p$(cat secrets/db_root_password.txt) -e "SHOW DATABASES;"

# Check Redis connection
docker exec redis redis-cli ping

# Check if WordPress is configured correctly
docker exec wordpress cat /var/www/html/wp-config.php | head -20
```

#### Container Resource Usage

```bash
# View real-time resource usage
docker stats

# View resource usage for specific container
docker stats wordpress

# View container history
docker history wordpress:latest
```

---

## Volume Management

### Understanding Volumes

The project uses Docker named volumes to persist data across container restarts.

#### Volume Configuration (in docker-compose.yml)

```yaml
volumes:
  db_volume:
    driver: local
    driver_opts:
      type: none
      device: /home/habenydi/data/db
      o: bind
  wp_volume:
    driver: local
    driver_opts:
      type: none
      device: /home/habenydi/data/wp
      o: bind
  redis_volume:
    driver: local
    driver_opts:
      type: none
      device: /home/habenydi/data/redis
      o: bind
```

### Managing Volumes

#### List Volumes
```bash
# List all Docker volumes
docker volume ls

# List volumes for this project
docker volume ls | grep inception

# Inspect a specific volume
docker volume inspect inception_db_volume
docker volume inspect inception_wp_volume
```

#### Volume Information

```bash
# Get volume mount point
docker volume inspect inception_db_volume | grep Mountpoint

# Show volume size
du -sh /home/habenydi/data/db
du -sh /home/habenydi/data/wp
du -sh /home/habenydi/data/redis

# Show total project data size
du -sh /home/habenydi/data/
```

#### Creating Backups

```bash
# Backup database volume
docker run --rm \
  -v inception_db_volume:/source \
  -v /home/backups:/backup \
  alpine tar czf /backup/db_backup_$(date +%Y%m%d_%H%M%S).tar.gz -C /source .

# Backup WordPress volume
docker run --rm \
  -v inception_wp_volume:/source \
  -v /home/backups:/backup \
  alpine tar czf /backup/wp_backup_$(date +%Y%m%d_%H%M%S).tar.gz -C /source .
```

#### Restoring from Backups

```bash
# Restore database volume
docker run --rm \
  -v inception_db_volume:/target \
  -v /home/backups:/backup \
  alpine tar xzf /backup/db_backup_YYYYMMDD_HHMMSS.tar.gz -C /target

# Restore WordPress volume
docker run --rm \
  -v inception_wp_volume:/target \
  -v /home/backups:/backup \
  alpine tar xzf /backup/wp_backup_YYYYMMDD_HHMMSS.tar.gz -C /target

# Restart containers to use restored data
docker-compose -f srcs/docker-compose.yml restart
```

#### Removing Volumes

```bash
# Remove a specific volume (⚠️ DATA LOSS)
docker volume rm inception_db_volume

# Remove all unused volumes
docker volume prune

# Remove project volumes (⚠️ DATA LOSS)
make fclean
```

---

## Data Storage and Persistence

### Where Data is Stored

#### Database (MariaDB)

**Volume**: `inception_db_volume`
**Host path**: `/home/habenydi/data/db`
**Container path**: `/var/lib/mysql`
**Contains**: All WordPress database files (posts, users, settings, etc.)

```bash
# Check database files
ls -la /home/habenydi/data/db

# Example structure:
# mysql/
# performance_schema/
# wordpress/           # WordPress database
# wordpress.service
# ib_logfile0, ib_logfile1
# ibdata1              # InnoDB data files
```

#### WordPress Files

**Volume**: `inception_wp_volume`
**Host path**: `/home/habenydi/data/wp`
**Container path**: `/var/www/html` (WordPress)
**Contains**: All WordPress site files, uploads, plugins, themes

```bash
# Check WordPress files
ls -la /home/habenydi/data/wp

# Example structure:
# wp-admin/            # WordPress core admin files
# wp-content/          # Themes, plugins, uploads
#   ├── plugins/
#   ├── themes/
#   └── uploads/
# wp-includes/         # WordPress core files
# wp-config.php        # WordPress configuration
# index.php
# .htaccess
```

#### Redis Cache

**Volume**: `inception_redis_volume`
**Host path**: `/home/habenydi/data/redis`
**Container path**: `/data`
**Contains**: In-memory cache data (temporary, can be regenerated)

```bash
# Check Redis data
ls -la /home/habenydi/data/redis

# Example:
# dump.rdb              # Redis persistence file
```

### Persistence Mechanism

#### How Data Persists

1. **Named Volumes**: Docker volumes are managed by Docker daemon
2. **Bind Mounts**: Host directories are mounted into containers
3. **Data written to volumes** survives container restarts and removal
4. **Volume drivers** ensure data is stored on host filesystem

#### Flow of Data Persistence

```
Container (WordPress)
    ↓
Writes to /var/www/html
    ↓
Mapped to inception_wp_volume
    ↓
Stored on host at /home/habenydi/data/wp
    ↓
Data persists even if container is deleted
    ↓
New container instance can mount same volume
    ↓
Data is available again
```

### Verifying Data Persistence

```bash
# 1. Start services
make up

# 2. Create WordPress post/page (creates data in database)
# Access WordPress at https://localhost, login, create post

# 3. Check data on host filesystem
ls -la /home/habenydi/data/wp/wp-content/

# 4. Stop container (doesn't delete volume)
docker-compose -f srcs/docker-compose.yml stop wordpress

# 5. Verify data still exists
ls -la /home/habenydi/data/wp/wp-content/

# 6. Restart container
docker-compose -f srcs/docker-compose.yml start wordpress

# 7. Access WordPress - data is still there!
# https://localhost
```

### Data Lifecycle

#### Creation
```
1. Container starts
2. Mounts volume to container path
3. Application writes data
4. Data stored in volume (host filesystem)
```

#### Persistence
```
1. Container stops
2. Volume data remains on host
3. No data loss
4. Volume can be attached to different container
```

#### Backup
```
1. Stop containers (optional but recommended)
2. Copy data from host directory
3. Store in safe location
4. Can restore later if needed
```

#### Cleanup
```
# Remove volume (⚠️ DATA LOSS)
make fclean

# Or specific volume
docker volume rm inception_db_volume

# Data is permanently deleted
```

---

## Development Workflow

### Daily Development Cycle

#### 1. Start Development Session
```bash
cd /path/to/inception.1337

# Start all services (if not running)
make up

# Verify all containers running
docker ps
```

#### 2. Make Code Changes

**Modify Dockerfiles:**
```bash
# Edit any Dockerfile
nano srcs/requirements/wordpress/Dockerfile

# Rebuild affected container
docker-compose -f srcs/docker-compose.yml build wordpress

# Restart container
docker-compose -f srcs/docker-compose.yml restart wordpress
```

**Modify Configuration:**
```bash
# Edit Nginx configuration
nano srcs/requirements/nginx/conf/nginx.conf

# Rebuild and restart Nginx
docker-compose -f srcs/docker-compose.yml build nginx
docker-compose -f srcs/docker-compose.yml restart nginx
```

**Modify Scripts:**
```bash
# Edit setup script
nano srcs/requirements/mariadb/tools/setup.sh

# Rebuild and restart service
docker-compose -f srcs/docker-compose.yml build mariadb
docker-compose -f srcs/docker-compose.yml restart mariadb
```

#### 3. Test Changes

```bash
# View logs to verify changes took effect
docker logs wordpress

# Access service to test
curl -k https://localhost

# For database changes
docker exec mariadb mysql -u root -p$(cat secrets/db_root_password.txt) -e "SHOW TABLES FROM wordpress;"
```

#### 4. Iterate

```bash
# Make more changes
# Rebuild
# Restart
# Test
# Repeat until satisfied
```

#### 5. End Development Session

```bash
# Stop services (data persists)
make down

# Or keep running if developing further
```

### Common Development Tasks

#### Add a WordPress Plugin

```bash
# Copy plugin to WordPress volume
cp -r plugin-name /home/habenydi/data/wp/wp-content/plugins/

# Or add to Dockerfile and rebuild
# Then restart WordPress to see plugin
docker-compose -f srcs/docker-compose.yml restart wordpress
```

#### Modify WordPress Configuration

```bash
# Edit wp-config.php
nano /home/habenydi/data/wp/wp-config.php

# Changes take effect immediately
```

#### Execute Database Migrations

```bash
# Run SQL commands in database
docker exec mariadb mysql -u wordpress -p$(cat secrets/db_password.txt) wordpress < migration.sql

# Or connect with Adminer
# http://localhost:8080
```

#### Monitor Real-time Activity

```bash
# Watch container logs live
docker logs -f wordpress

# In another terminal, make requests to site
curl -k https://localhost/wp-admin

# See requests logged in real-time
```

---

## Debugging

### Debugging Containers

#### Basic Debugging

```bash
# 1. Check if container is running
docker ps | grep wordpress

# 2. View container logs
docker logs wordpress

# 3. Check container status
docker inspect wordpress | grep Status

# 4. View container resource usage
docker stats wordpress
```

#### Accessing Container Shell

```bash
# Open interactive bash shell
docker exec -it wordpress bash

# Inside container, check filesystem
ls -la /var/www/html

# Check environment variables
env | grep MYSQL

# Check network connectivity
ping mariadb

# Check running processes
ps aux

# Exit shell
exit
```

#### Common Issues and Solutions

##### Container Won't Start

```bash
# Check container logs
docker logs wordpress

# Look for error messages

# If configuration issue:
# 1. Stop container
docker-compose -f srcs/docker-compose.yml stop wordpress

# 2. Fix configuration file
# 3. Rebuild
docker-compose -f srcs/docker-compose.yml build wordpress

# 4. Start again
docker-compose -f srcs/docker-compose.yml start wordpress
```

##### Network Connectivity Issues

```bash
# Check network exists
docker network ls | grep inception

# Check if containers are connected
docker network inspect inception_network

# Test container-to-container communication
docker exec wordpress ping mariadb

# Check DNS resolution
docker exec wordpress nslookup mariadb

# If fails, restart network
docker-compose -f srcs/docker-compose.yml restart
```

##### Database Connection Failed

```bash
# Check if MariaDB is running
docker ps | grep mariadb

# Check MariaDB logs
docker logs mariadb

# Test database connection
docker exec mariadb mysql -u root -p$(cat secrets/db_root_password.txt) -e "SELECT 1;"

# Check database password
cat secrets/db_password.txt

# Verify WordPress config has correct password
docker exec wordpress cat /var/www/html/wp-config.php | grep DB_PASSWORD
```

##### Storage/Disk Space Issues

```bash
# Check available disk space
df -h

# Check volume sizes
du -sh /home/habenydi/data/*

# Check Docker storage usage
docker system df

# Clean up unused images/containers
docker system prune -f

# For significant space issues
docker system prune -a --volumes
```

### Logging Strategies

#### Structured Debugging

```bash
# 1. Enable debug logging in Docker Compose
COMPOSE_DEBUG_STACK=true docker-compose -f srcs/docker-compose.yml up

# 2. Capture logs to file
docker logs wordpress > debug_logs.txt 2>&1

# 3. Search logs for errors
docker logs wordpress 2>&1 | grep -i error

# 4. Get logs with timestamps
docker logs -t wordpress | grep "2026-02"
```

#### Performance Debugging

```bash
# Monitor container performance
docker stats --no-stream

# Check for memory leaks
watch docker stats

# Analyze slow queries (MySQL)
docker exec mariadb mysql -u root -p$(cat secrets/db_root_password.txt) -e "SHOW PROCESSLIST;"
```

---

## Architecture Overview

### Service Dependencies

```
nginx (Port 443)
  └── depends_on: wordpress

wordpress (No exposed port)
  ├── depends_on: mariadb, redis
  └── connects_to: mariadb, redis

mariadb (Internal port 3306)
  └── no dependencies (first to start)

redis (Internal port 6379)
  └── no dependencies

adminer (Port 8080)
  └── depends_on: mariadb

ftp (Port 21, 21100-21110)
  └── depends_on: wordpress

portainer (Port 9443)
  └── mounts: /var/run/docker.sock

website (Port 1337)
  └── no dependencies
```

### Network Architecture

```
┌─────────────────────────────────────────────────┐
│           inception_network (bridge)            │
├─────────────────────────────────────────────────┤
│                                                 │
│  mariadb ─────────── wordpress ─────────── nginx│
│  (db)               (app)                 (web) │
│     │                  │                    │   │
│     └──── redis ───────┘                    │   │
│     (cache)                                 │   │
│                                             │   │
│  adminer ──────────────┼────────────────────┘   │
│  (DB UI)               │                        │
│                        │                        │
│  ftp ──────────────────┘                        │
│  (file transfer)                                │
│                        portainer                │
│                        (container mgmt)         │
│                                                 │
│                        website                  │
│                        (static files)           │
│                                                 │
└─────────────────────────────────────────────────┘

All services can communicate by container name
All services share the same Docker network
```

### Volume Mounting

```
Host Machine                    Container
/home/habenydi/data/db    ←→    mariadb:/var/lib/mysql
/home/habenydi/data/wp    ←→    wordpress:/var/www/html
/home/habenydi/data/wp    ←→    nginx:/var/www/html
/home/habenydi/data/wp    ←→    ftp:/var/www/html
/home/habenydi/data/redis ←→    redis:/data
```

### Build Process

```
1. Read docker-compose.yml
   ↓
2. For each service:
   - Read Dockerfile
   - Execute build commands
   - Create image layer by layer
   ↓
3. After build complete:
   - Create containers from images
   - Mount volumes
   - Connect to network
   - Start services
```

---

## Quick Reference

### Essential Commands

```bash
# Project lifecycle
make build          # Build all images
make up             # Start all services
make down           # Stop all services
make re             # Restart everything
make whole-clean    # Full reset

# Container operations
docker ps           # List running containers
docker logs -f svc  # Follow service logs
docker exec -it svc bash  # Enter container shell

# Volume management
docker volume ls    # List volumes
docker volume inspect vol  # Inspect volume

# Troubleshooting
docker inspect svc  # Get container details
docker stats        # View resource usage
docker system df    # Check disk usage
```

### Important Paths

```
/home/habenydi/inception.1337/        # Project root
├── srcs/
│   ├── docker-compose.yml             # Service definitions
│   ├── .env                           # Configuration
│   └── requirements/                  # Dockerfiles & scripts
├── secrets/                           # Credentials (not versioned)
└── data/                              # Persistent volumes (not versioned)
    ├── db/
    ├── wp/
    └── redis/
```

---

**Last Updated**: February 2026
