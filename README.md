# Minecraft-Java-Docker
Servidor de Minecraft con docker y copias de seguridad automáticas.

## Requisitos 

- Docker 20.10.5
- Docker Compose 1.25.0

## Instalación

Descargar el repositorio en la carpeta que queramos tener los archivos de Minecraft.

Configurar archivo `.env`

```
SERVER_NAME="Nombre del servidor"
DIFFICULTY="easy"
GAMEMODE="survival"
LEVEL_NAME="Nombre del mundo"
MAX_PLAYERS="3"
BACKUP_FOLDER="Nombre de la carpeta donde van las Backups (Ejemplo:'Backup')"
ROOT_FOLDER="Nombre raíz de la carpeta raíz donde hemos descargado el repositorio (Ejemplo: '/var/www/minecraft')"
VOLUME_NAME="Nombre que le vamos a poner al volumen de docker (En este caso: 'minecraftdata')"
CONTAINER_NAME="Nombre del contenedor (En este caso 'Minecraft')"
```

Para cargar cualquier plugin deberá hacerse en la carpeta `plugins`

Crear el volumen de Docker:
```
docker volume create minecraftdata
```

Ejecutar Docker compose:
```
docker compose up -d
```

## Backups automáticas

Para generar backups automáticas, crear la carpeta Backup dentro de la carpeta donde tenemos los archivos:
```
mkdir Backup
```

Añadir al crontab lo siguiente
```
crontab -e
```

```
0 */8 * * * bash /var/www/minecraft/crear_backup.sh
```

## Restaurar backups

```
bash restaurar_backup.sh -f nombre_del_archivo_backup
```
