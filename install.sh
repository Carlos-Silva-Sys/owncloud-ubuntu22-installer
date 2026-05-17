#!/bin/bash
# ================================================================================
# INSTALADOR DE OWNCLOUD EN UBUNTU 22.04 LTS
# ================================================================================
# Autor: Carlos Silva
# GitHub: Carlos-Silva-Sys
# Licencia: Uso libre para fines educativos y profesionales
# ================================================================================
# ⚠️ IMPORTANTE - CAMBIAR CONTRASEÑAS ANTES DE EJECUTAR
# ================================================================================

# ================================================================================
# CONFIGURACIÓN - CAMBIAR AQUÍ ANTES DE EJECUTAR
# ================================================================================

# Base de datos
DB_ROOT_PASS='CambiarRootPassword123'      # ⚠️ CAMBIAR: Contraseña para root de MySQL
DB_USER='ownclouduser'
DB_USER_PASS='CambiarUserPassword123'      # ⚠️ CAMBIAR: Contraseña para usuario de OwnCloud
DB_NAME='ownclouddb'

# Versión de OwnCloud
OWNCLOUD_VERSION='10.12.1'
OWNCLOUD_URL="https://download.owncloud.com/server/stable/owncloud-${OWNCLOUD_VERSION}.zip"

# Configuración de red (IP ESTÁTICA - OPCIONAL)
# Si quieres IP estática, cambia STATIC_IP_ENABLED a "yes" y completa los datos
STATIC_IP_ENABLED="no"                     # Cambiar a "yes" para configurar IP estática
STATIC_IP="192.168.100.97"                 # IP deseada
STATIC_GATEWAY="192.168.100.1"             # Puerta de enlace
STATIC_DNS="192.168.100.1, 8.8.8.8"       # Servidores DNS

# IP del servidor (se detecta automáticamente si no usas IP estática)
if [ "$STATIC_IP_ENABLED" = "yes" ]; then
    SERVER_IP="$STATIC_IP"
else
    SERVER_IP=$(hostname -I | awk '{print $1}')
fi

# ================================================================================
# COLORES PARA OUTPUT PROFESIONAL
# ================================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ================================================================================
# FUNCIONES
# ================================================================================
print_status() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_header() {
    echo ""
    echo "================================================================================"
    echo -e "${BLUE}$1${NC}"
    echo "================================================================================"
}

# ================================================================================
# VERIFICACIÓN DE PRIVILEGIOS
# ================================================================================
if [[ $EUID -ne 0 ]]; then
    print_error "Este script debe ejecutarse como root (sudo)"
    exit 1
fi

clear
print_header "INSTALADOR DE OWNCLOUD ${OWNCLOUD_VERSION}"

print_warning "Verifica que cambiaste las contraseñas en la sección CONFIGURACIÓN del script"
print_warning "IP detectada/configurada: ${SERVER_IP}"
echo ""
read -p "¿Deseas continuar con la instalación? (s/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    print_error "Instalación cancelada por el usuario"
    exit 1
fi

# ================================================================================
# 0. CONFIGURAR IP ESTÁTICA (SI ESTÁ HABILITADA)
# ================================================================================
if [ "$STATIC_IP_ENABLED" = "yes" ]; then
    print_header "0. CONFIGURANDO IP ESTÁTICA"
    
    print_status "Eliminando cloud-init para evitar cambios automáticos de IP..."
    sudo apt purge cloud-init -y
    sudo rm -rf /etc/cloud/
    print_success "cloud-init eliminado"
    
    print_status "Configurando Netplan para IP estática..."
    NETPLAN_FILE="/etc/netplan/00-installer-config.yaml"
    
    sudo tee ${NETPLAN_FILE} > /dev/null <<EOL
network:
  version: 2
  renderer: networkd
  ethernets:
    ens18:
      dhcp4: no
      addresses: [${STATIC_IP}/24]
      routes:
        - to: default
          via: ${STATIC_GATEWAY}
      nameservers:
        addresses: [${STATIC_DNS}]
EOL
    
    sudo netplan apply
    print_success "IP estática configurada correctamente"
    sleep 3
fi

# ================================================================================
# 1. PREPARACIÓN DEL SISTEMA Y PHP 7.4
# ================================================================================
print_header "1. PREPARANDO EL SISTEMA E INSTALANDO PHP 7.4"

export DEBIAN_FRONTEND=noninteractive

print_status "Actualizando repositorios..."
sudo apt update && sudo apt upgrade -y

print_status "Agregando repositorio PHP 7.4..."
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

print_status "Instalando Apache y PHP 7.4..."
sudo apt install apache2 unzip -y
sudo apt install php7.4 php7.4-{opcache,gd,curl,mysql,intl,json,ldap,mbstring,xml,zip} -y

print_status "Configurando módulos de Apache..."
sudo a2dismod mpm_event
sudo a2enmod mpm_prefork
sudo a2enmod php7.4
sudo a2enmod mime dir rewrite headers

print_status "Iniciando Apache..."
sudo systemctl enable apache2
sudo systemctl start apache2

print_success "PHP 7.4 (con soporte LDAP) y Apache instalados correctamente"

# ================================================================================
# 2. INSTALACIÓN Y CONFIGURACIÓN DE MYSQL
# ================================================================================
print_header "2. INSTALANDO Y CONFIGURANDO MYSQL"

print_status "Configurando contraseña de root de MySQL..."
echo "mysql-server mysql-server/root_password password ${DB_ROOT_PASS}" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password ${DB_ROOT_PASS}" | sudo debconf-set-selections

print_status "Instalando MySQL Server..."
sudo apt install mysql-server -y
sudo systemctl enable mysql
sudo systemctl start mysql

print_status "Configurando autenticación de root..."
sudo mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_ROOT_PASS}';
FLUSH PRIVILEGES;
EOF

print_status "Creando base de datos y usuario para OwnCloud..."
sudo mysql -u root -p${DB_ROOT_PASS} <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_USER_PASS}';
GRANT ALL ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

print_success "Base de datos configurada correctamente"

# ================================================================================
# 3. INSTALACIÓN DE ARCHIVOS DE OWNCLOUD
# ================================================================================
print_header "3. DESCARGANDO E INSTALANDO OWNCLOUD"

cd /tmp
print_status "Descargando OwnCloud ${OWNCLOUD_VERSION}..."
wget "${OWNCLOUD_URL}"

print_status "Descomprimiendo archivos..."
unzip -q owncloud-${OWNCLOUD_VERSION}.zip

print_status "Moviendo archivos al directorio web..."
sudo mv owncloud /var/www/html/
sudo chown -R www-data:www-data /var/www/html/owncloud
sudo chmod -R 755 /var/www/html/owncloud

print_success "Archivos de OwnCloud instalados correctamente"

# ================================================================================
# 4. CONFIGURACIÓN DE APACHE VIRTUAL HOST
# ================================================================================
print_header "4. CONFIGURANDO APACHE VIRTUAL HOST"

OWNCLOUD_CONF="/etc/apache2/sites-available/owncloud.conf"

sudo tee ${OWNCLOUD_CONF} > /dev/null <<EOL
<VirtualHost *:80>
    ServerAdmin admin@example.com
    DocumentRoot /var/www/html/owncloud
    ServerName ${SERVER_IP}
    
    <Directory /var/www/html/owncloud>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/owncloud_error.log
    CustomLog \${APACHE_LOG_DIR}/owncloud_access.log combined
</VirtualHost>
EOL

print_status "Habilitando sitio y módulos..."
sudo a2dissite 000-default.conf
sudo a2ensite owncloud.conf
sudo a2enmod rewrite mime unique_id headers

print_status "Reiniciando Apache..."
sudo systemctl restart apache2

print_success "Virtual Host configurado correctamente"

# ================================================================================
# 5. CONFIGURACIÓN DE OWNCLOUD (occ)
# ================================================================================
print_header "5. CONFIGURANDO OWNCLOUD"

cd /var/www/html/owncloud

print_status "Configurando trusted domains..."
sudo -u www-data php occ config:system:set trusted_domains 0 --value="${SERVER_IP}"
sudo -u www-data php occ config:system:set trusted_domains 1 --value="localhost"

print_status "Instalando aplicación LDAP desde el mercado de OwnCloud..."
sudo -u www-data php occ market:install user_ldap

print_status "Habilitando aplicación LDAP..."
sudo -u www-data php occ app:enable user_ldap

print_success "Aplicación LDAP instalada y habilitada correctamente"

# ================================================================================
# 6. CONFIGURACIÓN DE FIREWALL
# ================================================================================
print_header "6. CONFIGURANDO FIREWALL"

print_status "Permitiendo puerto HTTP (80)..."
sudo ufw allow http
sudo ufw reload

print_success "Firewall configurado correctamente"

# ================================================================================
# 7. ACTUALIZAR APACHE Y TRUSTED DOMAINS SI CAMBIÓ LA IP
# ================================================================================
if [ "$STATIC_IP_ENABLED" = "yes" ]; then
    print_header "7. ACTUALIZANDO CONFIGURACIÓN PARA NUEVA IP"
    
    print_status "Actualizando ServerName en Apache..."
    sudo sed -i "s/ServerName .*/ServerName ${STATIC_IP}/" /etc/apache2/sites-available/owncloud.conf
    sudo systemctl restart apache2
    
    print_status "Actualizando trusted domains en OwnCloud..."
    sudo -u www-data php occ config:system:set trusted_domains 0 --value="${STATIC_IP}"
    
    SERVER_IP="$STATIC_IP"
    print_success "Configuración actualizada para IP: ${SERVER_IP}"
fi

# ================================================================================
# 8. RESUMEN FINAL
# ================================================================================
clear
print_header "INSTALACIÓN COMPLETADA EXITOSAMENTE"

echo -e "${GREEN}✅ OwnCloud ${OWNCLOUD_VERSION} instalado correctamente${NC}"
echo ""
echo "================================================================================"
echo "📊 ACCESO A OWNCLOUD"
echo "================================================================================"
echo -e "   URL: ${GREEN}http://${SERVER_IP}/${NC}"
echo "   Usuario: (crear en el primer acceso web)"
echo ""
echo "================================================================================"
echo "📁 DATOS DE BASE DE DATOS (para el setup web)"
echo "================================================================================"
echo "   Usuario DB: ${DB_USER}"
echo "   Contraseña DB: ${DB_USER_PASS}"
echo "   Nombre DB: ${DB_NAME}"
echo ""
echo "================================================================================"
echo "🔧 APLICACIÓN LDAP"
echo "================================================================================"
echo "   ✅ Paquete PHP-LDAP instalado"
echo "   ✅ App user_ldap instalada desde el mercado"
echo "   ✅ App user_ldap habilitada"
echo "   Configuración: Ajustes → Administración → LDAP/AD integration"
echo ""
echo "================================================================================"
echo "🔧 COMANDOS ÚTILES"
echo "================================================================================"
echo "   Ver logs: sudo tail -f /var/www/html/owncloud/data/owncloud.log"
echo "   Verificar app LDAP: sudo -u www-data php occ app:list | grep ldap"
echo "   Reiniciar Apache: sudo systemctl restart apache2"
echo "   Reiniciar MySQL: sudo systemctl restart mysql"
echo ""
if [ "$STATIC_IP_ENABLED" = "yes" ]; then
    echo "================================================================================"
    echo "⚠️  IP ESTÁTICA CONFIGURADA"
    echo "================================================================================"
    echo "   IP asignada: ${STATIC_IP}"
    echo "   Gateway: ${STATIC_GATEWAY}"
    echo "   DNS: ${STATIC_DNS}"
    echo "   cloud-init ha sido eliminado para evitar cambios automáticos"
    echo ""
fi
echo "================================================================================"
echo "⚠️  PRÓXIMOS PASOS"
echo "================================================================================"
echo "   1. Abre http://${SERVER_IP}/ en tu navegador"
echo "   2. Crea tu usuario administrador"
echo "   3. Ingresa los datos de la base de datos (usuario y contraseña de arriba)"
echo "   4. Ve a Ajustes → Administración → LDAP/AD integration para configurar LDAP"
echo ""
echo "================================================================================"
echo -e "${GREEN}¡Instalación completada!${NC}"
echo "================================================================================"
