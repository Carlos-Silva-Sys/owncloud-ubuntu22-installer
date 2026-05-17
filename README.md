# ☁️ owncloud-ubuntu22-installer

Instalación automática de OwnCloud en Ubuntu 22.04 LTS. Script que despliega Apache, MySQL, PHP 7.4, OwnCloud y aplicación LDAP en un solo paso.

---

## ⚠️ IMPORTANTE - ANTES DE EJECUTAR

### 1. CAMBIAR CONTRASEÑAS POR DEFECTO

Edita el archivo `install.sh` y **cambia estas variables** antes de ejecutarlo:

```bash
DB_ROOT_PASS='CambiarRootPassword123'   # ⚠️ CAMBIAR: Contraseña para root de MySQL
DB_USER_PASS='CambiarUserPassword123'   # ⚠️ CAMBIAR: Contraseña para usuario de OwnCloud
```

### 2. REQUISITOS DEL SISTEMA

- Ubuntu 22.04 LTS **limpio** (sin Apache/MySQL preinstalado)
- Conexión a Internet activa
- Ejecutar como root o con sudo
- Puertos 80 disponibles

### 3. IP ESTÁTICA (OPCIONAL)

Si necesitas IP fija, edita el script y cambia:

```bash
STATIC_IP_ENABLED="yes"
STATIC_IP="192.168.1.97"
STATIC_GATEWAY="192.168.1.1"
STATIC_DNS="192.168.1.1, 8.8.8.8"
```

---

## 📋 Descripción

**Problema que resuelve:**  
Las instalaciones tradicionales de OwnCloud requieren múltiples pasos manuales (Apache, MySQL, PHP, configuración de LDAP y trusted domains). Este proceso puede tomar horas y es propenso a errores.

**Solución:**  
Este script automatiza la instalación completa de OwnCloud en Ubuntu 22.04, incluyendo:
- Apache2 + PHP 7.4 con todas las extensiones necesarias (incluyendo LDAP)
- MySQL con base de datos y usuario optimizados
- Descarga y configuración automática de OwnCloud
- Instalación y habilitación de la aplicación `user_ldap`
- Configuración opcional de IP estática
- Trusted domains configuradas automáticamente

---

## 🚀 Tecnologías

| Tecnología | Versión | Puerto |
|------------|---------|--------|
| Ubuntu | 22.04 LTS | - |
| OwnCloud | 10.12.1 | 80 / 443 |
| Apache2 | 2.4 | 80 / 443 |
| MySQL | 8.0 | 3306 |
| PHP | 7.4 | - |
| LDAP | user_ldap app | - |

---

## ⚙️ INSTALACIÓN

### 1. Clonar repositorio

```bash
git clone https://github.com/Carlos-Silva-Sys/owncloud-ubuntu22-installer.git
cd owncloud-ubuntu22-installer
```

### 2. Dar permisos al script

```bash
chmod +x install.sh
```

### 3. Editar contraseñas (OBLIGATORIO)

```bash
nano install.sh
# Buscar las variables DB_ROOT_PASS y DB_USER_PASS
```

### 4. Ejecutar como root

```bash
sudo ./install.sh
```

### 5. Esperar la instalación

El proceso tomará **5-10 minutos**.

### 6. Acceder a OwnCloud

```
http://IP_DEL_SERVIDOR
```

---

## 🔧 PASOS DESPUÉS DE EJECUTAR

### Configuración inicial web

1. Abre tu navegador y ve a `http://IP_DEL_SERVIDOR`
2. Crea tu usuario administrador
3. Ingresa los datos de la base de datos:
   - Usuario DB: `ownclouduser`
   - Contraseña DB: `[la que definiste]`
   - Nombre DB: `ownclouddb`
4. Completa la instalación

### Captura del dashboard

![Dashboard OwnCloud](images/dashboard-owncloud.png)

### Captura de la pantalla de login

![Login OwnCloud](images/login-owncloud.png)

### Captura del asistente de instalación web

![Asistente de instalación web](images/instalacion-web.png)

---

## 🔗 CONFIGURAR LDAP / ACTIVE DIRECTORY

La aplicación `user_ldap` ya está instalada y habilitada automáticamente.

### Pasos para configurar LDAP:

1. Ve a **Ajustes** → **Administración** → **LDAP / Active Directory**
2. Configura la conexión a tu servidor LDAP/AD
3. Prueba la conexión y guarda la configuración

### Captura de configuración LDAP (opcional)

![Configuración LDAP](images/ldap-config.png)

---

## 🛠️ COMANDOS ÚTILES

```bash
# Verificar servicios
sudo systemctl status apache2 mysql

# Ver logs de OwnCloud
sudo tail -f /var/www/html/owncloud/data/owncloud.log

# Verificar aplicación LDAP instalada
sudo -u www-data php /var/www/html/owncloud/occ app:list | grep ldap

# Reiniciar servicios
sudo systemctl restart apache2 mysql

# Actualizar trusted domains si cambia la IP
sudo -u www-data php /var/www/html/owncloud/occ config:system:set trusted_domains 0 --value="NUEVA_IP"
```

---

## 📁 Estructura del proyecto

```
owncloud-ubuntu22-installer/
├── install.sh
├── README.md
└── images/
    ├── dashboard-owncloud.png
    ├── login-owncloud.png
    ├── instalacion-web.png
    └── ldap-config.png (opcional)
```

---

## 📝 Autor

Carlos Silva  
GitHub: [@Carlos-Silva-Sys](https://github.com/Carlos-Silva-Sys)

---

## 📌 Nota de seguridad

Todas las credenciales mostradas son ejemplos. En producción, use contraseñas seguras.
