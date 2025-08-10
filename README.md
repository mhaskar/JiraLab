# Atlassian Jira Lab

A Docker-based laboratory environment focused on testing and comparing multiple versions of Atlassian Jira Software, mainly focus security researching purposes.

This setup provides isolated instances of different Jira versions running simultaneously, each with its own PostgreSQL database and accessible through a Traefik reverse proxy.

This repo also has a bash utility to dump all JAR files from the containers, good for reversing the core software code as well as the installed plugins.


## Overview

This lab environment consists of five different Jira versions running in parallel:
- Jira 7.13.18
- Jira 8.5.0
- Jira 8.13.22
- Jira 9.4.21
- Jira 9.12.10

## Architecture

### Services

**Reverse Proxy:**
- Traefik v3.0 - Handles routing and load balancing for all Jira instances

**Jira Instances:**
- Each Jira version runs in its own container with dedicated resources
- JVM memory allocation scales with version requirements
- Isolated PostgreSQL databases for each instance

**Database Layer:**
- PostgreSQL 10 (Jira 7.13)
- PostgreSQL 12 (Jira 8.x)
- PostgreSQL 15 (Jira 9.x)

### Network Configuration

All services run on a custom bridge network called `traefik`, ensuring proper isolation and communication between containers.

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- At least 16GB RAM available
- 50GB+ free disk space

## Quick Start

1. Clone or download this repository
2. Navigate to the project directory
3. Start all services:

```bash
docker-compose up -d
```

4. Wait for all containers to start (may take 5-10 minutes for initial startup)
5. Access the services through your browser

## Access URLs

Once running, access each Jira instance at:

- **Jira 7.13.18**: http://jira-7-13.jira-lab.local
- **Jira 8.5.0**: http://jira-8-5.jira-lab.local
- **Jira 8.13.22**: http://jira-8-13.jira-lab.local
- **Jira 9.4.21**: http://jira-9-4.jira-lab.local
- **Jira 9.12.10**: http://jira-9-12.jira-lab.local

**Traefik Dashboard**: http://localhost:8080

## Local Development Setup

To use these URLs locally, add the following entries to your `/etc/hosts` file:

```
127.0.0.1 jira-7-13.jira-lab.local
127.0.0.1 jira-8-5.jira-lab.local
127.0.0.1 jira-8-13.jira-lab.local
127.0.0.1 jira-9-4.jira-lab.local
127.0.0.1 jira-9-12.jira-lab.local
```

## Resource Allocation

### Memory Requirements

- **Jira 7.13**: 1GB min / 2GB max
- **Jira 8.5**: 1GB min / 3GB max
- **Jira 8.13**: 1GB min / 3GB max
- **Jira 9.4**: 1GB min / 4GB max
- **Jira 9.12**: 1GB min / 4GB max

### Database Versions

- **Jira 7.13**: PostgreSQL 10
- **Jira 8.x**: PostgreSQL 12
- **Jira 9.x**: PostgreSQL 15

## Database Credentials

All databases use the same credentials for simplicity:
- **Username**: jira
- **Password**: jira
- **Database Names**: jira713, jira850, jira813, jira94, jira912

## Management Commands

### Start Services
```bash
docker-compose up -d
```

### Stop Services
```bash
docker-compose down
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f jira-713
```

### Restart Specific Service
```bash
docker-compose restart jira-713
```

### Scale Down (for development)
```bash
# Run only specific versions
docker-compose up -d jira-713 jira-850
```

## JAR Extraction Tool

The included `dump-jars.sh` script allows you to extract JAR files from running Jira containers for analysis:

```bash
./dump-jars.sh
```

This will:
- Scan each running Jira container for JAR files
- Extract them to organized directories under `extracted-jars/`
- Provide a summary of extracted files per container

## Data Persistence

All data is persisted using Docker volumes:
- **Jira Data**: `jira_data_[version]` - Application data and configurations
- **Database Data**: `pgdata_[version]` - PostgreSQL data files

To completely reset the environment:
```bash
docker-compose down -v
docker-compose up -d
```

## Troubleshooting

### Common Issues

1. **Port Conflicts**: Ensure ports 80 and 8080 are available
2. **Memory Issues**: Increase Docker memory allocation if containers fail to start
3. **Slow Startup**: First startup may take 10-15 minutes as databases initialize

### Container Health Checks

Monitor container status:
```bash
docker-compose ps
```

### Database Connectivity

Test database connections:
```bash
docker exec -it pg-713 psql -U jira -d jira713
```

## Use Cases

This lab environment is ideal for:

- **Version Migration Testing**: Test upgrade paths between Jira versions
- **Plugin Compatibility**: Verify plugin compatibility across versions
- **Performance Testing**: Compare performance characteristics
- **Development**: Develop and test against multiple Jira versions
- **Training**: Provide hands-on experience with different versions
- **Security Testing**: Test security configurations across versions

## Security Notes

- Default credentials are used for demonstration purposes
- Do not use in production without proper security hardening
- Consider changing default passwords for extended use
- Network isolation is provided through Docker networking

## Contributing

To add new Jira versions or modify configurations:

1. Add new service definitions to `docker-compose.yml`
2. Update the `dump-jars.sh` script if needed
3. Test the new configuration thoroughly
4. Update this README with new information

## License

This project is provided as-is for educational and development purposes.
