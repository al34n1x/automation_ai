#!/bin/bash
# ================================================================
# User Data Script for n8n + PostgreSQL + Nginx + SSL Setup
# ================================================================

set -e

# Variables from Terraform
DOMAIN_NAME="${domain_name}"
N8N_AUTH_USER="${n8n_auth_user}"
N8N_AUTH_PASSWORD="${n8n_auth_password}"
POSTGRES_PASSWORD="${postgres_password}"
EBS_DEVICE="${ebs_device}"

# Logging
LOG_FILE="/var/log/n8n-setup.log"
exec > >(tee -a $LOG_FILE)
exec 2>&1

echo "=== Starting n8n setup at $(date) ==="

# ================================================================
# System Updates and Basic Setup
# ================================================================

echo "Updating system packages..."
apt-get update
apt-get upgrade -y
apt-get install -y \
    curl \
    wget \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    unzip \
    htop \
    fail2ban \
    ufw

# Configure timezone
timedatectl set-timezone UTC

# ================================================================
# Configure Firewall
# ================================================================

echo "Configuring UFW firewall..."
ufw --force enable
ufw allow 22/tcp   # SSH
ufw allow 80/tcp   # HTTP
ufw allow 443/tcp  # HTTPS

# ================================================================
# Mount EBS Volume for Data Persistence
# ================================================================

echo "Setting up EBS volume for data persistence..."

# Wait for EBS volume to be attached
while [ ! -e $EBS_DEVICE ]; do
  echo "Waiting for EBS volume to be attached..."
  sleep 5
done

# Check if volume is already formatted
if ! blkid $EBS_DEVICE; then
  echo "Formatting EBS volume..."
  mkfs.ext4 $EBS_DEVICE
fi

# Create mount point and mount
mkdir -p /data
mount $EBS_DEVICE /data

# Add to fstab for persistent mounting
echo "$EBS_DEVICE /data ext4 defaults,nofail 0 2" >> /etc/fstab

# Create directories for n8n and postgres data
mkdir -p /data/n8n
mkdir -p /data/postgres
chmod 755 /data/n8n
chmod 755 /data/postgres

# ================================================================
# Install Docker
# ================================================================

echo "Installing Docker..."

# Remove old versions
apt-get remove -y docker docker-engine docker.io containerd runc || true

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# Install Docker
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Install Docker Compose standalone
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# ================================================================
# Install Nginx
# ================================================================

echo "Installing Nginx..."
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx

# Remove default site
rm -f /etc/nginx/sites-enabled/default

# ================================================================
# Install Certbot
# ================================================================

echo "Installing Certbot..."
apt-get install -y certbot python3-certbot-nginx

# ================================================================
# Create n8n Docker Configuration
# ================================================================

echo "Creating n8n Docker configuration..."

# Create n8n directory
mkdir -p /opt/n8n

# Create docker-compose.yml
cat > /opt/n8n/docker-compose.yml << EOF
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "127.0.0.1:5678:5678"
    environment:
      - N8N_HOST=$DOMAIN_NAME
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - NODE_ENV=production
      - WEBHOOK_URL=https://$DOMAIN_NAME/
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=$N8N_AUTH_USER
      - N8N_BASIC_AUTH_PASSWORD=$N8N_AUTH_PASSWORD
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=$POSTGRES_PASSWORD
      - N8N_LOG_LEVEL=info
      - N8N_LOG_OUTPUT=console
    volumes:
      - /data/n8n:/home/node/.n8n
    depends_on:
      - postgres
    networks:
      - n8n-network
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:5678/healthz || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3

  postgres:
    image: postgres:15-alpine
    container_name: n8n-postgres
    restart: unless-stopped
    environment:
      - POSTGRES_USER=n8n
      - POSTGRES_PASSWORD=$POSTGRES_PASSWORD
      - POSTGRES_DB=n8n
      - PGDATA=/var/lib/postgresql/data/pgdata
    volumes:
      - /data/postgres:/var/lib/postgresql/data
    networks:
      - n8n-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U n8n -d n8n"]
      interval: 30s
      timeout: 5s
      retries: 3

networks:
  n8n-network:
    driver: bridge

volumes:
  n8n_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /data/n8n
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /data/postgres
EOF

# ================================================================
# Create Initial Nginx Configuration (HTTP only)
# ================================================================

echo "Creating initial Nginx configuration..."

cat > /etc/nginx/sites-available/n8n << EOF
server {
    listen 80;
    server_name $DOMAIN_NAME www.$DOMAIN_NAME;
    
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    location / {
        proxy_pass http://127.0.0.1:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 7d;
        proxy_send_timeout 7d;
        proxy_read_timeout 7d;
    }
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/

# Test and reload nginx
nginx -t
systemctl reload nginx

# ================================================================
# Start n8n Services
# ================================================================

echo "Starting n8n services..."

cd /opt/n8n

# Pull images first
docker-compose pull

# Start services
docker-compose up -d

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 30

# Check if services are running
docker-compose ps

# ================================================================
# Configure SSL with Certbot
# ================================================================

echo "Configuring SSL with Certbot..."

# Wait a bit more for n8n to be fully ready
sleep 60

# Get SSL certificate
certbot --nginx --non-interactive --agree-tos --email admin@$DOMAIN_NAME -d $DOMAIN_NAME -d www.$DOMAIN_NAME || {
    echo "Certbot failed, will retry in 60 seconds..."
    sleep 60
    certbot --nginx --non-interactive --agree-tos --email admin@$DOMAIN_NAME -d $DOMAIN_NAME -d www.$DOMAIN_NAME
}

# ================================================================
# Configure Automatic Certificate Renewal
# ================================================================

echo "Setting up automatic certificate renewal..."

# Create renewal cron job
cat > /etc/cron.d/certbot-renew << EOF
# Renew certificates twice daily
0 12 * * * root /usr/bin/certbot renew --quiet --post-hook "/usr/bin/systemctl reload nginx"
0 0 * * * root /usr/bin/certbot renew --quiet --post-hook "/usr/bin/systemctl reload nginx"
EOF

# ================================================================
# Configure Fail2Ban
# ================================================================

echo "Configuring Fail2Ban..."

cat > /etc/fail2ban/jail.local << EOF
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

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 3
EOF

systemctl enable fail2ban
systemctl start fail2ban

# ================================================================
# Create Backup Script
# ================================================================

echo "Creating backup script..."

cat > /opt/backup-n8n.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/data/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

echo "Starting backup at $(date)"

# Stop services for consistent backup
cd /opt/n8n
docker-compose stop

# Backup n8n data
tar -czf $BACKUP_DIR/n8n_data_$DATE.tar.gz -C /data/n8n .

# Backup postgres data
tar -czf $BACKUP_DIR/postgres_data_$DATE.tar.gz -C /data/postgres .

# Start services again
docker-compose start

# Keep only last 7 days of backups
find $BACKUP_DIR -name "*.tar.gz" -type f -mtime +7 -delete

echo "Backup completed at $(date)"
EOF

chmod +x /opt/backup-n8n.sh

# Create daily backup cron job
echo "0 3 * * * root /opt/backup-n8n.sh >> /var/log/n8n-backup.log 2>&1" > /etc/cron.d/n8n-backup

# ================================================================
# Create System Monitoring Script
# ================================================================

cat > /opt/n8n-health-check.sh << 'EOF'
#!/bin/bash

# Check if n8n container is running
if ! docker ps | grep -q n8n; then
    echo "n8n container is not running, attempting to restart..."
    cd /opt/n8n
    docker-compose restart n8n
fi

# Check if postgres container is running
if ! docker ps | grep -q n8n-postgres; then
    echo "PostgreSQL container is not running, attempting to restart..."
    cd /opt/n8n
    docker-compose restart postgres
fi

# Check if nginx is running
if ! systemctl is-active --quiet nginx; then
    echo "Nginx is not running, attempting to restart..."
    systemctl restart nginx
fi
EOF

chmod +x /opt/n8n-health-check.sh

# Run health check every 5 minutes
echo "*/5 * * * * root /opt/n8n-health-check.sh >> /var/log/n8n-health.log 2>&1" > /etc/cron.d/n8n-health-check

# ================================================================
# Final Setup Steps
# ================================================================

echo "Performing final setup steps..."

# Create log rotation for our custom logs
cat > /etc/logrotate.d/n8n << EOF
/var/log/n8n-*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 root root
}
EOF

# Set proper ownership for data directories
chown -R 1000:1000 /data/n8n
chown -R 999:999 /data/postgres

# ================================================================
# Install CloudWatch Agent (Optional)
# ================================================================

echo "Installing CloudWatch agent..."

wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb

# Create basic CloudWatch config
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/n8n-setup.log",
                        "log_group_name": "/aws/ec2/n8n",
                        "log_stream_name": "setup"
                    },
                    {
                        "file_path": "/var/log/nginx/access.log",
                        "log_group_name": "/aws/ec2/n8n",
                        "log_stream_name": "nginx-access"
                    },
                    {
                        "file_path": "/var/log/nginx/error.log",
                        "log_group_name": "/aws/ec2/n8n",
                        "log_stream_name": "nginx-error"
                    }
                ]
            }
        }
    }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s

# ================================================================
# Create Status Check Script
# ================================================================

cat > /opt/n8n-status.sh << 'EOF'
#!/bin/bash

echo "=== n8n System Status ==="
echo "Date: $(date)"
echo ""

echo "=== Docker Containers ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "=== System Resources ==="
free -h
echo ""
df -h /data
echo ""

echo "=== Service Status ==="
systemctl status nginx --no-pager -l
echo ""
systemctl status docker --no-pager -l
echo ""

echo "=== Recent Logs ==="
echo "Last 10 lines from n8n container:"
docker logs n8n --tail 10
echo ""

echo "=== SSL Certificate Status ==="
certbot certificates
echo ""

echo "=== Firewall Status ==="
ufw status
echo ""
EOF

chmod +x /opt/n8n-status.sh

# ================================================================
# Final System Restart and Verification
# ================================================================

echo "Setup complete! Restarting services for final verification..."

# Restart all services to ensure everything works after reboot
systemctl restart docker
sleep 10

cd /opt/n8n
docker-compose restart

# Wait for services to start
sleep 30

# Final status check
echo "=== Final Status Check ==="
docker-compose ps
curl -I http://localhost:5678 || echo "n8n not responding on localhost"

echo "=== Setup completed successfully at $(date) ==="
echo "n8n should be available at: https://$DOMAIN_NAME"
echo "SSH to check status: /opt/n8n-status.sh"
echo "View logs: tail -f /var/log/n8n-setup.log"
echo ""
echo "Next steps:"
echo "1. Point your domain $DOMAIN_NAME to this server's IP"
echo "2. Wait for DNS propagation"
echo "3. Access https://$DOMAIN_NAME"
echo "4. Login with user: $N8N_AUTH_USER"
echo ""
echo "=== Setup script finished ==="