*This project has been created as part of the 42 curriculum by habenydi.*

# Inception.1337

## Description

**Inception** is a Docker-based infrastructure project that demonstrates containerization best practices and systems administration concepts. The project involves setting up a multi-container application environment using Docker and Docker Compose, featuring a complete WordPress stack with MariaDB, Nginx, Redis caching, and additional bonus services.

### Project Goal

The primary objective of Inception is to:
- Understand and apply containerization principles using Docker
- Learn Docker Compose for orchestrating multi-container applications
- Implement secure secret management practices
- Configure networking and persistent data storage in containers
- Deploy a production-like WordPress environment with multiple services
- Explore advanced Docker features and best practices

### Brief Overview

The project creates a fully functional web infrastructure consisting of:
- **Nginx**: Reverse proxy and web server with SSL/TLS support
- **WordPress**: Content management system with PHP support
- **MariaDB**: Relational database for WordPress
- **Redis**: In-memory caching layer for performance optimization
- **Adminer**: Database management web interface (bonus)
- **FTP**: File Transfer Protocol server for content management (bonus)

All services run in isolated Docker containers on a custom Docker network, with persistent data stored in named volumes and credentials managed through Docker secrets.

---

## Instructions

### Prerequisites

- Docker and Docker Compose installed on your system
- Linux/Unix-like operating system (tested on Linux)
- Make utility
- SSL/TLS certificate generation capability

### Installation & Compilation

1. **Clone the repository:**
   ```bash
   git clone <repository-url> inception.1337
   cd inception.1337
   ```

2. **Set up environment variables:**
   - Create a `.env` file in the `srcs/` directory with required environment variables
   - Example variables:
     ```
     DOMAIN_NAME=yourdomain.local
     MYSQL_ROOT_PASSWORD_FILE=<secure-password-from-secrets>
     MYSQL_DATABASE=wordpress
     MYSQL_USER=wpuser
     MYSQL_PASSWORD_FILE=<secure-password-file-from-secrets>
     ```

3. **Generate SSL/TLS certificates:**
   ```bash
   make build
   ```
   The Nginx setup script will automatically generate self-signed certificates.

### Execution

**Start the entire infrastructure:**
```bash
make up
```

**Build containers:**
```bash
make build
```

**Stop all services:**
```bash
make down
```

**Rebuild and restart everything:**
```bash
make re
```

**Clean up containers and perform full cleanup:**
```bash
make fclean
```

**Access the services:**
- **WordPress**: https://yourdomain.local (or localhost)
- **Adminer**: http://localhost:8080
- **FTP**: localhost:21

---

## Project Architecture & Design Choices

### Docker Implementation Overview

This project uses Docker to create isolated, lightweight, and reproducible environments for each service. The use of Docker Compose orchestrates these containers, manages their lifecycle, handles networking, and manages persistent data through volumes and secrets.

#### Key Components:

- **Docker Containers**: Each service runs in its own container, ensuring isolation and modularity
- **Docker Compose**: Defines and manages the multi-container application stack
- **Named Volumes**: Persistent storage for databases and website files
- **Docker Network**: Internal communication between containers
- **Docker Secrets**: Secure credential management

### Comparison: Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker Containers |
|--------|------------------|-------------------|
| **Size** | Large (multiple GB) | Small (usually MB) |
| **Boot Time** | Minutes | Seconds |
| **Resource Usage** | Heavy (full OS kernel) | Lightweight (shared kernel) |
| **Portability** | Good | Excellent |
| **Isolation** | Complete (separate OS) | Process-level isolation |
| **Startup Speed** | Slow | Instant |
| **Use Case** | Full OS environments | Application services |

**Why Docker for this project**: Docker provides sufficient isolation for service separation while maintaining minimal resource overhead and enabling rapid deployment. It's ideal for microservices architectures like WordPress stacks.

---

## Secrets vs Environment Variables

### Secrets (Recommended for sensitive data)

**Advantages:**
- Data is never exposed in process environment (`env` output)
- Cannot be accessed from container unless specifically mounted
- Built-in encryption at rest in Docker Swarm
- Follows security best practices

**Implementation in this project:**
```yaml
secrets:
  - db_root_password
  - db_password
  - wp_admin_password
```

**Use Case**: Database passwords, wordpress password, private tokens

### Environment Variables

**Advantages:**
- Easy to configure and override
- Visible to all processes in container
- Simple for non-sensitive configuration

**Disadvantages:**
- Visible in `ps` output and Docker inspect
- Exposed to child processes
- Can be captured in logs

**Use Case**: Non-sensitive configuration like database names, domain names, feature flags

**Decision in this project**: Sensitive credentials are stored as Docker secrets, while configuration parameters (DOMAIN_NAME, database names) are stored as environment variables in `.env` files.

---

## Docker Network vs Host Network

### Docker Network (Chosen for this project)

**Advantages:**
- **Isolation**: Services only communicate through defined network
- **Security**: Prevents direct access to host resources
- **Flexibility**: Multiple networks can be created and managed
- **DNS Resolution**: Services can reference each other by container name
- **Port Mapping Control**: Explicit port exposure through mappings

**Example in project:**
```yaml
services:
  wordpress:
    networks:
      - inception_network
  nginx:
    ports:
      - "443:443"
    networks:
      - inception_network
```

### Host Network

**Advantages:**
- Minimal performance overhead
- Direct access to all host ports and network interfaces

**Disadvantages:**
- No isolation between containers
- Port conflicts between services
- Security risks (containers can access host network)
- Cannot use container DNS names

**Decision**: Custom Docker network (`inception_network`) provides security through isolation while enabling service-to-service communication via container names.

---

## Docker Volumes vs Bind Mounts

### Named Volumes (Primary approach in this project)

**Advantages:**
- **Persistence**: Data survives container restarts and removal
- **Driver Support**: Can use different storage drivers
- **Management**: Docker manages the storage location
- **Backups**: Easier to back up volumes
- **Performance**: Better performance on some systems (especially Windows/Mac)
- **Declarative**: Defined in compose file, version controlled

**Usage in this project:**
```yaml
volumes:
  - db_volume:/var/lib/mysql      # MariaDB data
  - wp_volume:/var/www/html       # WordPress files
  - redis_volume:/data            # Redis data
```

### Bind Mounts

**Advantages:**
- Direct filesystem access
- Useful for development
- Full control over mount location

**Disadvantages:**
- Host filesystem dependency
- Platform-specific paths
- Less portable
- Potential permission issues

**Decision**: Named volumes are used for all persistent data in this project because they:
1. Are platform-independent
2. Can be managed by Docker
3. Support automatic backups and migrations
4. Provide better isolation from host filesystem
5. Are more suitable for production environments

**Exception**: Configuration files (nginx.conf, wp-config.php) may be read-only bound from source, ensuring versioning and easy modification.

---

## Resources

### Documentation

- [Docker Official Documentation](https://docs.docker.com/reference/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [WordPress.org Official Documentation](https://wordpress.org/documentation/)
- [MariaDB Official Documentation](https://mariadb.com/kb/en/)

### Tutorials & Guides

- [Docker Crash Course](https://youtu.be/9yoe8dBvAZ0?si=5VHJ7aHgCVoGLyRq)
- [Docker Best Practices](https://youtu.be/t779DVjCKCs?si=75ZSaqhGB4ztRm9f)
- [Production Deployment on VPS using Docker](https://www.youtube.com/watch?v=C7aooGtKq8Y)

---

## AI Usage Disclosure

**AI was utilized for the following aspects of this project:**

1. **README.md Structure and Documentation** - AI assisted in organizing and formatting the README file to meet project requirements and provide comprehensive documentation.

2. **Best Practices and Comparisons** - AI provided technical comparisons between Docker architectural patterns (VMs vs Containers, Volumes vs Bind Mounts, etc.) and security considerations.

3. **Technical Explanations** - AI contributed to articulating complex Docker concepts in clear, understandable language.

**Parts NOT generated by AI**:
- All Docker configuration files (Dockerfiles, docker-compose.yml)
- Shell scripts and entry points (bash scripts)
- Nginx and WordPress configuration
- Makefile targets and build logic
- Project implementation and infrastructure setup

AI served as a reference guide and documentation assistant to improve code clarity and project comprehensibility.