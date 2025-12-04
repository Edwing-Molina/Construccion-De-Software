# Guía de Deploy en Render

## Requisitos Previos

1. Cuenta en [Render.com](https://render.com)
2. Repositorio en GitHub
3. Git instalado localmente

## Pasos para Deploy

### 1. Generar APP_KEY

Antes de hacer push, genera una clave de aplicación:

```bash
cd backend
php artisan key:generate --show
```

Copia el valor (sin el prefijo "base64:").

### 2. Conectar Repositorio en Render

1. Ve a [Render Dashboard](https://dashboard.render.com)
2. Haz clic en "New +" → "Web Service"
3. Selecciona "Build and deploy from a Git repository"
4. Conecta tu repositorio GitHub
5. Llena los datos:
   - **Name**: `laravel-api` (o el nombre que prefieras)
   - **Environment**: `Docker`
   - **Root Directory**: `backend`
   - **Build Command**: (dejar vacío - usa Dockerfile)
   - **Start Command**: (dejar vacío - usa Dockerfile)

### 3. Configurar Base de Datos PostgreSQL

1. En el mismo dashboard, ve a "Databases"
2. Haz clic en "New Database"
3. Llena los datos:
   - **Name**: `laravel-db`
   - **Database**: `laravel_db`
   - **User**: `laravel_user`
   - **Region**: Ohio (o la que prefieras)
4. Copia la `Internal Database URL` (se usará automáticamente)

### 4. Configurar Variables de Entorno

En tu Web Service de Render, ve a "Environment" y agrega:

```
APP_NAME=PruebasClaseConstruccion
APP_ENV=production
APP_DEBUG=false
APP_URL=https://tu-app.onrender.com
APP_KEY=base64:tu_key_generada_aqui
LOG_CHANNEL=stack
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
```

**Nota**: Las variables `DB_*` se configuran automáticamente desde la base de datos.

### 5. Deploy

1. Haz commit y push a tu rama principal:

```bash
git add .
git commit -m "feat: add Dockerfile and Render config for deployment"
git push origin edwing-molina
```

2. Render automáticamente detectará los cambios y iniciará el build
3. Espera a que termine el deploy (aprox. 5-10 minutos)

## Solución de Problemas

### El deploy falla en `composer install`

- Asegúrate que `composer.lock` esté en el repositorio
- Verifica que `composer.json` tenga todas las dependencias correctas

### Errores de migración

Si ves errores en las migraciones:

1. En el dashboard de Render, abre la consola (Shell)
2. Ejecuta manualmente:
   ```bash
   cd /app
   php artisan migrate --force
   php artisan cache:clear
   ```

### Conexión a base de datos rechazada

1. Verifica que la base de datos PostgreSQL está en estado "Available"
2. Comprueba que las variables `DB_*` están correctas en Environment
3. Asegúrate que el servicio web está vinculado a la base de datos

## URLs Importantes

- **API Base URL**: `https://tu-app.onrender.com/api`
- **Base de Datos**: Acceso desde Render Dashboard → Databases

## Comandos Útiles en Render

Desde la consola del servicio web:

```bash
# Ver logs
tail -f storage/logs/laravel.log

# Limpiar caché
php artisan cache:clear

# Ejecutar migraciones frescas (⚠️ Cuidado en producción)
php artisan migrate:fresh --seed

# Verificar salud
php artisan health
```

## Siguientes Pasos

- Configura un dominio personalizado (si lo deseas)
- Configura CORS para tu frontend
- Implementa email transaccional (recomendado: SendGrid, Mailgun)
- Configura backups automáticos para PostgreSQL
