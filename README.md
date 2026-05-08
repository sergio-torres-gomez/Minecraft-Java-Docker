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
TYPE="FABRIC"
VERSION="1.21.1"
INIT_MEMORY="1G"
MAX_MEMORY="1500M"
DIFFICULTY="normal"
GAMEMODE="survival"
MAX_PLAYERS="5"
ENABLE_WHITELIST="TRUE"
VIEW_DISTANCE="8"
SIMULATION_DISTANCE="4"
ONLINE_MODE="TRUE"
ENABLE_RCON="true"
RCON_PASSWORD="Cambia esta contraseña"
MODRINTH_PROJECTS="lithium,ferrite-core,krypton,fabric-carpet,geyser,floodgate"
BACKUP_FOLDER="Nombre de la carpeta donde van las backups (Ejemplo:'Backup')"
ROOT_FOLDER="Nombre raíz de la carpeta raíz donde hemos descargado el repositorio (Ejemplo: '/var/www/minecraft')"
DATA_FOLDER="Carpeta de datos bind mount usada por backup/restauración (Ejemplo: '.data')"
CONTAINER_NAME="Nombre del contenedor (En este caso 'Minecraft')"
```

El servidor usa:
- Puerto Java: `25565/tcp`
- Puerto Bedrock (plugin Geyser): `19132/udp`
- Puerto RCON: `25575/tcp`

Para cargar cualquier mod deberá hacerse en la carpeta `mods`
Los datos del servidor se guardan en la carpeta oculta `.data`

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
