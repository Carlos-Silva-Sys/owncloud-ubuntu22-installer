# ☁️ owncloud-ubuntu22-installer

**¿Instalar OwnCloud? Tú eliges cómo.**

👇 TE MUESTRO AMBAS FORMAS

---

## 🐳 VERSIÓN RÁPIDA (Docker)

**1 comando. 1 minuto. Todo listo.**

```bash
docker run -d \
  --name owncloud \
  -p 80:8080 \
  -e OWNCLOUD_ADMIN_USERNAME=admin \
  -e OWNCLOUD_ADMIN_PASSWORD=TuClaveSegura123 \
  -e OWNCLOUD_TRUSTED_DOMAINS=192.168.1.111 \
  -v owncloud-data:/mnt/data \
  owncloud/server:latest
```

✅ **Portable, limpio, fácil de actualizar.**  
👉 [Repositorio completo con documentación Docker](https://github.com/Carlos-Silva-Sys/owncloud-docker-installer)

---

## 📝 VERSIÓN COMPLETA (Script nativo)

**Apache, MySQL, PHP, LDAP paso a paso. Ideal para entender qué pasa detrás.**

> ⚠️ **ANTES DE EJECUTAR:**  
> Edita el archivo `install.sh` y cambia las siguientes contraseñas por unas seguras:
> - `DB_ROOT_PASS` (root de MySQL)
> - `DB_USER_PASS` (usuario de base de datos)
> - `OC_ADMIN_PASS` (usuario administrador de OwnCloud)

```bash
git clone https://github.com/Carlos-Silva-Sys/owncloud-ubuntu22-installer.git
cd owncloud-ubuntu22-installer
nano install.sh          # ← CAMBIA LAS CONTRASEÑAS AQUÍ
chmod +x install.sh
sudo ./install.sh
```

✅ **Control total, aprendizaje profundo.**

---

## 📸 CAPTURAS DE PANTALLA

### Pantalla de login

![Login OwnCloud](images/Login_owncloud.png)

### Dashboard principal

![Dashboard OwnCloud](images/Dashboard_owncloud.png)

### Vista de archivos

![Vista de archivos OwnCloud](images/Instalacion_web.png)

---

## 📱 APPS MÓVILES Y ESCRITORIO

**Accede a tus archivos desde cualquier dispositivo:**

| Plataforma | Enlace |
|------------|--------|
| 🖥️ **Windows / Linux / Mac** | [owncloud.com/desktop-app/](https://owncloud.com/desktop-app/) |
| 📱 **Android** | [OwnCloud en Google Play](https://play.google.com/store/apps/details?id=com.owncloud.android) |
| 🍏 **iPhone / iPad** | [owncloud.com/mobile-apps/](https://owncloud.com/mobile-apps/) (elige tu tienda) |

---

## 📁 ESTRUCTURA DEL PROYECTO

```
owncloud-ubuntu22-installer/
├── README.md
├── install.sh
└── images/
    ├── Login_owncloud.png
    ├── Dashboard_owncloud.png
    └── Instalacion_web.png
```

---

## 📝 AUTOR

Carlos Silva  
GitHub: [@Carlos-Silva-Sys](https://github.com/Carlos-Silva-Sys)

---

## 📌 NOTA DE SEGURIDAD

Cambia las contraseñas y dominios por los de tu entorno. No uses valores por defecto en producción.
