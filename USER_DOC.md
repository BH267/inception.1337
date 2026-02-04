# User Documentation - Inception.1337

## Table of Contents

1. [Services Overview](#services-overview)
2. [Getting Started](#getting-started)
3. [Starting and Stopping the Project](#starting-and-stopping-the-project)
4. [Accessing the Website and Administration](#accessing-the-website-and-administration)
5. [Managing Credentials](#managing-credentials)
6. [Monitoring Service Health](#monitoring-service-health)
7. [Troubleshooting](#troubleshooting)

---

## Services Overview

The Inception.1337 stack provides a complete web infrastructure for running and managing a WordPress website. Here's what each service does:

### Core Services

#### 🌐 **Nginx (Web Server)**
- **Purpose**: Serves your website to the internet using the HTTPS protocol (secure connection)
- **What it does**: Handles all incoming web requests and directs them to WordPress
- **Access point**: https://yourdomain.local or https://localhost
- **Port**: 443 (secure web traffic)

#### 📝 **WordPress**
- **Purpose**: Content Management System (CMS) for creating and managing website content
- **What it does**: Allows you to create pages, posts, manage users, and customize your website
- **Access point**: Through the Nginx web server
- **Admin panel**: https://yourdomain.local/wp-admin

#### 🗄️ **MariaDB (Database)**
- **Purpose**: Stores all website data (posts, pages, users, settings, comments, etc.)
- **What it does**: Acts as the "memory" of your WordPress site
- **Access point**: Internal only (not directly accessible from the internet)
- **Port**: 3306 (internal container communication)

### Bonus Services

#### ⚡ **Redis (Cache)**
- **Purpose**: Speeds up your website by storing frequently accessed data in memory
- **What it does**: Reduces database queries and improves page load times
- **Access point**: Internal only (used automatically by WordPress)
- **Port**: 6379 (internal container communication)
- **Status**: Optional bonus service

#### 🔧 **Adminer (Database Management)**
- **Purpose**: Web interface to view and manage the database
- **What it does**: Allows administrators to inspect database contents, run queries, and manage data
- **Access point**: http://localhost:8080
- **Note**: Useful for advanced users and troubleshooting

#### 📂 **FTP (File Transfer Protocol)**
- **Purpose**: Upload and manage website files directly from your computer
- **What it does**: Allows file transfers between your computer and the server
- **Access point**: localhost:21 (port 21)
- **Note**: For advanced users managing website files

#### 🎛️ **Portainer (Container Management)**
- **Purpose**: Web interface for managing and monitoring Docker containers
- **What it does**: Provides a visual dashboard to view, manage, and debug all containers in the stack
- **Access point**: https://localhost:9443
- **Note**: Useful for administrators monitoring infrastructure health

#### 🌐 **Website (Static Files)**
- **Purpose**: Serves additional static content (HTML, CSS, JavaScript, media files)
- **What it does**: Hosts supplementary website files separate from WordPress
- **Access point**: http://localhost:1337
- **Note**: Can be used for static pages, documentation, or additional content

---

## Getting Started

### Initial Setup

Before running the project for the first time:

1. **Ensure Docker is installed and running**
   ```bash
   docker --version
   docker-compose --version
   ```

2. **Navigate to the project directory**
   ```bash
   cd /path/to/inception.1337
   ```

3. **Verify configuration files exist**
   - Check that `srcs/.env` file is present with your configuration
   - Check that `secrets/` directory contains password files

---

## Starting and Stopping the Project

### Starting the Infrastructure

**To start all services:**
```bash
make up
```

This command will:
- Build all Docker images (if not already built)
- Create and start all containers
- Set up the Docker network
- Initialize volumes for persistent data
- **Estimated time**: 2-5 minutes on first run

**Example output:**
```
[+] Building 45.2s (50/50) FINISHED
[+] Running 6/6
 ✔ Network inception_network Created
 ✔ Container mariadb Created
 ✔ Container redis Created
 ✔ Container wordpress Created
 ✔ Container nginx Created
 ✔ Container adminer Created
 ✔ Container ftp Created
```

### Stopping the Infrastructure

**To stop all services gracefully:**
```bash
make down
```

This will:
- Stop all running containers
- Preserve all data in volumes (safe to stop)
- Keep Docker images for faster restart
- **Estimated time**: 10-30 seconds

### Restarting the Infrastructure

**To restart everything (stop and start):**
```bash
make re
```

### Checking Service Status

**View running containers:**
```bash
docker ps
```

You should see output showing these containers running:
- mariadb
- redis
- wordpress
- nginx
- adminer
- ftp

---

## Accessing the Website and Administration

### Accessing the Website

**Step 1: Open your web browser**

**Step 2: Navigate to your site**
- Default URL: `https://yourdomain.local`
- Or: `https://localhost`
- You may see a security warning (self-signed certificate) - this is normal for development. Click "Proceed" or "Continue"

**Step 3: You should see your WordPress homepage**

### Accessing the WordPress Administration Panel

**Step 1: Go to the admin login page**
- URL: `https://yourdomain.local/wp-admin`

**Step 2: Log in with your credentials**
- Username: Default admin user (set during installation)
- Password: See [Managing Credentials](#managing-credentials) section

**Step 3: You're now in the WordPress Dashboard**

From here you can:
- Create and edit posts and pages
- Manage users and permissions
- Install and activate themes
- Manage plugins
- Configure site settings

### Accessing the Database Manager (Adminer)

**Step 1: Open web browser**

**Step 2: Navigate to Adminer**
- URL: `http://localhost:8080`

**Step 3: Log in with database credentials**
- Server: `mariadb` (the container name)
- Username: Database user (from credentials)
- Password: Database password (from credentials)
- Database: `wordpress` (or leave empty to see all databases)

**This is useful for:**
- Viewing database structure
- Running custom SQL queries
- Backing up database
- Advanced troubleshooting

### Accessing Portainer (Container Management)

**Step 1: Open web browser**

**Step 2: Navigate to Portainer**
- URL: `https://localhost:9443`

**Step 3: Set up initial access**
- First time access requires creating an admin account
- Follow the on-screen setup wizard

**Step 4: You can now manage containers**

**This is useful for:**
- Monitoring container status and resource usage
- Viewing container logs
- Stopping/starting containers
- Managing volumes and networks
- Inspecting container details

### Accessing Static Website

**Step 1: Open web browser**

**Step 2: Navigate to the static website**
- URL: `http://localhost:1337`

**Step 3: Browse static content**

**This is useful for:**
- Hosting static HTML pages
- Serving additional content
- Supplementary documentation
- Testing static site configurations

---

## Managing Credentials

### Where Credentials Are Stored

Credentials are stored in the `secrets/` directory at the root of the project:

```
secrets/
├── db_root_password.txt         # MySQL root password
├── db_password.txt              # WordPress database user password
├── wp_admin_password.txt        # WordPress admin user password
└── wp_security_keys.txt         # WordPress security keys
```

### Accessing Credentials

**To view any credential:**
```bash
cat secrets/db_password.txt
cat secrets/wp_admin_password.txt
```

### Credential Usage Guide

| Credential | Used For | Where to Use |
|-----------|----------|-------------|
| `db_root_password.txt` | MySQL root access | Database administration, emergency access |
| `db_password.txt` | WordPress database connection | Adminer login (username: `wordpress`) |
| `wp_admin_password.txt` | WordPress admin login | WordPress dashboard (`/wp-admin`) |
| `wp_security_keys.txt` | WordPress encryption | Automatically used by WordPress |

### Changing Credentials

⚠️ **Important**: Credentials are generated at first startup. To change them:

1. **Stop the project:**
   ```bash
   make down
   ```

2. **Delete the current data and secrets:**
   ```bash
   make whole-clean
   ```

3. **Update the secret files** with new passwords

4. **Restart the project:**
   ```bash
   make up
   ```

### Security Best Practices

- ✅ **DO**: Keep secrets in the `secrets/` directory (not in git)
- ✅ **DO**: Use strong passwords (mix of uppercase, lowercase, numbers, symbols)
- ✅ **DO**: Regularly back up your database
- ✅ **DO**: Change default WordPress username and password from the admin panel
- ❌ **DON'T**: Share credentials via email or messaging apps
- ❌ **DON'T**: Commit secret files to version control
- ❌ **DON'T**: Use simple passwords like "123456" or "password"

---

## Monitoring Service Health

### Quick Health Check

**View all running containers:**
```bash
docker ps
```

All of these should show status `Up`:
```
CONTAINER ID   IMAGE                      STATUS
abc123def456   inception-mariadb          Up 5 minutes
def456ghi789   inception-wordpress        Up 5 minutes
ghi789jkl012   inception-nginx            Up 5 minutes
jkl012mno345   inception-redis            Up 5 minutes
mno345pqr678   inception-adminer          Up 5 minutes
pqr678stu901   inception-ftp              Up 5 minutes
```

### Viewing Service Logs

**View logs for a specific service:**
```bash
docker logs mariadb
docker logs wordpress
docker logs nginx
```

**Follow live logs (real-time):**
```bash
docker logs -f nginx
```

**Exit live logs**: Press `Ctrl+C`

### Testing Service Connectivity

**Test if website is accessible:**
```bash
curl -k https://localhost
```

**Test if database is responding:**
```bash
docker exec mariadb mysql -u root -p$(cat secrets/db_root_password.txt) -e "SELECT 1;"
```

**Check if Redis is working:**
```bash
docker exec redis redis-cli ping
```

### Checking Disk Space and Volumes

**View Docker volumes:**
```bash
docker volume ls
```

**Inspect a specific volume:**
```bash
docker volume inspect inception_db_volume
```

**Check volume disk usage:**
```bash
du -sh /var/lib/docker/volumes/inception*
```

---

## Troubleshooting

### Issue: Website not accessible (Connection refused)

**Solution:**
1. Check if services are running:
   ```bash
   docker ps
   ```
2. If containers are down, start them:
   ```bash
   make up
   ```
3. Wait 30-60 seconds for WordPress to initialize
4. Try accessing again

### Issue: "Connection timeout" or "ERR_INVALID_AUTH_CREDENTIALS"

**Solution:**
1. Check Nginx logs:
   ```bash
   docker logs nginx
   ```
2. Verify WordPress is healthy:
   ```bash
   docker logs wordpress
   ```
3. If WordPress is stuck, restart it:
   ```bash
   docker restart wordpress
   ```

### Issue: WordPress database connection error

**Solution:**
1. Check MariaDB is running:
   ```bash
   docker logs mariadb
   ```
2. Verify database password is correct:
   ```bash
   docker exec mariadb mysql -u wordpress -p $(cat secrets/db_password.txt) wordpress -e "SELECT 1;"
   ```
3. If database won't start, check disk space:
   ```bash
   df -h
   ```

### Issue: Admin panel shows "Error establishing a database connection"

**Solution:**
1. Verify WordPress container can reach MariaDB:
   ```bash
   docker exec wordpress ping mariadb
   ```
2. Check WordPress configuration:
   ```bash
   docker exec wordpress cat /var/www/html/wp-config.php | grep DB_
   ```
3. Restart WordPress:
   ```bash
   docker restart wordpress
   ```

### Issue: Adminer won't load

**Solution:**
1. Check if Adminer container is running:
   ```bash
   docker ps | grep adminer
   ```
2. View Adminer logs:
   ```bash
   docker logs adminer
   ```
3. Try accessing from a different browser or incognito window (clear cache)

### Issue: FTP connection failed

**Solution:**
1. Check FTP container is running:
   ```bash
   docker ps | grep ftp
   ```
2. View FTP logs:
   ```bash
   docker logs ftp
   ```
3. Verify FTP port is exposed:
   ```bash
   netstat -an | grep 21
   ```

### Issue: Services restart repeatedly (crash loop)

**Solution:**
1. Check logs for errors:
   ```bash
   docker logs <container-name>
   ```
2. Common causes:
   - Missing environment variables: verify `srcs/.env` exists and is complete
   - Missing secrets: verify `secrets/` directory has all required files
   - Disk space full: run `df -h` to check
3. Perform a clean restart:
   ```bash
   make whole-clean
   make up
   ```

### Issue: Forgot WordPress admin password

**Solution:**
1. Access the database via Adminer or MySQL CLI
2. Reset via WordPress CLI inside container:
   ```bash
   docker exec wordpress wp user list
   docker exec wordpress wp user update <user_id> --prompt=user_pass
   ```
3. Or reset from WordPress admin panel if you have another admin account

### Emergency: Complete reset

**If something is completely broken:**
```bash
# Stop everything
make down

# Clean everything
make whole-clean

# Start fresh
make up
```

This will:
- Stop all containers
- Remove all containers and images
- Delete all volumes (WARNING: data loss)
- Delete all temporary files

---

## Quick Reference Commands

| Task | Command |
|------|---------|
| Start project | `make up` |
| Stop project | `make down` |
| Restart project | `make re` |
| Full clean restart | `make hot-restart` |
| View running services | `docker ps` |
| View service logs | `docker logs <service-name>` |
| Access WordPress | https://yourdomain.local |
| Access WordPress Admin | https://yourdomain.local/wp-admin |
| Access Adminer | http://localhost:8080 |
| Access Portainer | https://localhost:9443 |
| Access Static Website | http://localhost:1337 |
| Access FTP | localhost:21 |
| View credentials | `cat secrets/<filename>` |
| Enter WordPress container | `docker exec -it wordpress bash` |
| Enter Database container | `docker exec -it mariadb bash` |

---

## Getting Help

If you encounter issues:

1. **Check the logs** - Most errors are described in container logs
2. **Review this documentation** - Check the Troubleshooting section
3. **Check project README** - Technical details and architecture information
4. **Contact project administrator** - For infrastructure-level issues

---

**Last Updated**: February 2026
