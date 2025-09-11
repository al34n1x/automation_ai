# Guía Completa: Instalar Docker + n8n + Nginx + SSL en Ubuntu

## 1. Preparación Inicial del Servidor

### Actualizar el Sistema
```bash
sudo apt update && sudo apt upgrade -y
```

### Instalar Dependencias Básicas
```bash
sudo apt install -y curl wget gnupg lsb-release software-properties-common apt-transport-https ca-certificates
```

### Configurar Firewall (UFW)
```bash
sudo ufw enable
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw status
```

## 2. Instalación de Docker

### Remover Versiones Anteriores (si existen)
```bash
sudo apt remove docker docker-engine docker.io containerd runc
```

### Agregar Repositorio Oficial de Docker
```bash
# Agregar clave GPG de Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Agregar repositorio
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Instalar Docker Engine
```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

### Configurar Docker (Opcional pero Recomendado)
```bash
# Agregar usuario al grupo docker
sudo usermod -aG docker $USER

# Habilitar Docker al inicio
sudo systemctl enable docker

# Reiniciar sesión para aplicar cambios de grupo
newgrp docker

# Verificar instalación
docker --version
docker compose version
```

## 3. Instalación de Docker Compose (Standalone)
```bash
# Descargar última versión
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Hacer ejecutable
sudo chmod +x /usr/local/bin/docker-compose

# Verificar
docker-compose --version
```

## 4. Configuración de n8n con Docker

### Crear Directorio de Trabajo
```bash
mkdir -p ~/n8n-setup
cd ~/n8n-setup
```

### Crear docker-compose.yml
```yaml
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "127.0.0.1:5678:5678"  # Solo accesible localmente
    environment:
      - N8N_HOST=tu-dominio.com
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - NODE_ENV=production
      - WEBHOOK_URL=https://tu-dominio.com/
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=tu-password-seguro
      - VUE_APP_URL_BASE_API=https://tu-dominio.com/
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=n8n-password
    volumes:
      - n8n_data:/home/node/.n8n
    depends_on:
      - postgres
    networks:
      - n8n-network

  postgres:
    image: postgres:15
    container_name: n8n-postgres
    restart: unless-stopped
    environment:
      - POSTGRES_USER=n8n
      - POSTGRES_PASSWORD=n8n-password
      - POSTGRES_DB=n8n
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - n8n-network

volumes:
  n8n_data:
  postgres_data:

networks:
  n8n-network:
    driver: bridge
```

## 5. Instalación y Configuración de Nginx

### Instalar Nginx
```bash
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
```

### Crear Configuración de Nginx
```bash
sudo nano /etc/nginx/sites-available/n8n
```

```nginx
server {
    listen 80;
    server_name tu-dominio.com www.tu-dominio.com;
    
    # Redirección temporal a HTTPS (se cambiará después del SSL)
    location / {
        return 301 https://$server_name$request_uri;
    }
    
    # Para validación de Certbot
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
}

server {
    listen 443 ssl http2;
    server_name tu-dominio.com www.tu-dominio.com;
    
    # Certificados SSL (se configurarán con Certbot)
    ssl_certificate /etc/letsencrypt/live/tu-dominio.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/tu-dominio.com/privkey.pem;
    
    # Configuración SSL moderna
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Headers de seguridad
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options SAMEORIGIN always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Configuración de proxy para n8n
    location / {
        proxy_pass http://127.0.0.1:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Configuración para WebSockets y streaming
        proxy_buffering off;
        proxy_request_buffering off;
        proxy_set_header Connection "upgrade";
        
        # Timeouts
        proxy_connect_timeout 7d;
        proxy_send_timeout 7d;
        proxy_read_timeout 7d;
    }
    
    # Manejo de archivos estáticos
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        proxy_pass http://127.0.0.1:5678;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### Habilitar el Sitio
```bash
# Crear enlace simbólico
sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/

# Deshabilitar sitio por defecto
sudo rm -f /etc/nginx/sites-enabled/default

# Verificar configuración
sudo nginx -t

# Reiniciar nginx
sudo systemctl restart nginx
```

## 6. Configuración de Certbot para SSL

### Instalar Certbot
```bash
sudo apt install -y certbot python3-certbot-nginx
```

### Configuración Temporal de Nginx (para obtener certificado)
```bash
sudo nano /etc/nginx/sites-available/n8n-temp
```

```nginx
server {
    listen 80;
    server_name tu-dominio.com www.tu-dominio.com;
    
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    location / {
        proxy_pass http://127.0.0.1:5678;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Obtener Certificado SSL
```bash
# Parar nginx temporalmente
sudo systemctl stop nginx

# Obtener certificado (modo standalone)
sudo certbot certonly --standalone -d tu-dominio.com -d www.tu-dominio.com

# O usar nginx plugin (recomendado)
sudo systemctl start nginx
sudo certbot --nginx -d tu-dominio.com -d www.tu-dominio.com
```

### Configurar Renovación Automática
```bash
# Agregar tarea cron para renovación
sudo crontab -e

# Agregar esta línea al final del archivo:
0 12 * * * /usr/bin/certbot renew --quiet && /usr/bin/systemctl reload nginx
```

### Verificar Configuración SSL
```bash
# Probar renovación
sudo certbot renew --dry-run

# Verificar certificados
sudo certbot certificates
```

## 7. Iniciar n8n

### Reemplazar Configuración Final de Nginx
```bash
sudo rm /etc/nginx/sites-enabled/n8n-temp
sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Iniciar Contenedores
```bash
cd ~/n8n-setup

# Iniciar en segundo plano
docker-compose up -d

# Ver logs
docker-compose logs -f n8n

# Verificar estado
docker-compose ps
```

## 8. Configuraciones Adicionales de Seguridad

### Configurar Fail2Ban (Protección contra ataques)
```bash
sudo apt install -y fail2ban

# Crear configuración personalizada
sudo nano /etc/fail2ban/jail.local
```

```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log

[nginx-noscript]
enabled = true
port = http,https
logpath = /var/log/nginx/access.log
maxretry = 6

[nginx-badbots]
enabled = true
port = http,https
logpath = /var/log/nginx/access.log
maxretry = 2
```

```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### Configurar Backup Automático
```bash
# Crear script de backup
sudo nano /opt/n8n-backup.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/backups/n8n"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup de volúmenes Docker
docker run --rm -v n8n-setup_n8n_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/n8n_data_$DATE.tar.gz -C /data .
docker run --rm -v n8n-setup_postgres_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/postgres_data_$DATE.tar.gz -C /data .

# Mantener solo últimos 7 backups
find $BACKUP_DIR -name "*.tar.gz" -type f -mtime +7 -delete
```

```bash
sudo chmod +x /opt/n8n-backup.sh

# Agregar a cron (diario a las 2 AM)
sudo crontab -e
# Agregar: 0 2 * * * /opt/n8n-backup.sh
```

## 9. Monitoreo y Mantenimiento

### Verificar Estado de Servicios
```bash
# Estado de Docker
sudo systemctl status docker

# Estado de Nginx
sudo systemctl status nginx

# Estado de contenedores
docker-compose ps

# Logs de n8n
docker-compose logs -f n8n

# Uso de recursos
docker stats
```

### Comandos Útiles de Mantenimiento
```bash
# Actualizar n8n
cd ~/n8n-setup
docker-compose pull
docker-compose up -d

# Limpiar Docker
docker system prune -a

# Ver certificados SSL
sudo certbot certificates

# Renovar certificados manualmente
sudo certbot renew
```

## 10. Acceso y Verificación Final

Una vez completada la instalación:

1. **Accede a tu dominio**: `https://tu-dominio.com`
2. **Credenciales iniciales**: admin / tu-password-seguro
3. **Verifica SSL**: El navegador debe mostrar el candado verde
4. **Prueba funcionalidades**: Crea un workflow simple para verificar

### URLs de Verificación:
- **Aplicación**: https://tu-dominio.com
- **Webhooks**: https://tu-dominio.com/webhook/...
- **SSL Test**: https://www.ssllabs.com/ssltest/

¡Tu instalación de n8n con Docker, Nginx y SSL está lista para producción!

---
[⬅ Back to Course Overview](../../README.md)