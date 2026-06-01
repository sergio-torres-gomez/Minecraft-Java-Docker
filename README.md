# Minecraft-Java-Docker
Servidor de Minecraft con Docker y backups automáticos con Restic en S3.

## Requisitos 

- Docker 20.10.5
- Docker Compose 1.25.0

## Instalación

Descargar el repositorio en la carpeta que queramos tener los archivos de Minecraft.

Crear el archivo `.env` a partir de `.env.example` y configurarlo:

```
cp .env.example .env
```

```
SERVER_NAME="Nombre del servidor"
LEVEL_NAME="Nombre del mundo"
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
RCON_PASSWORD="REPLACE_WITH_SECURE_PASSWORD"
MODRINTH_PROJECTS="lithium,ferrite-core,krypton,fabric-carpet,geyser,floodgate"

RESTIC_REPOSITORY="s3:s3.amazonaws.com/REPLACE_BUCKET/REPLACE_PATH"
RESTIC_PASSWORD="REPLACE_WITH_RESTIC_PASSWORD"
AWS_ACCESS_KEY_ID="REPLACE_WITH_AWS_ACCESS_KEY"
AWS_SECRET_ACCESS_KEY="REPLACE_WITH_AWS_SECRET_KEY"
AWS_DEFAULT_REGION="eu-west-1"
RESTIC_CRON_SCHEDULE="0 5 * * *"
RESTIC_FORGET_ARGS="--keep-daily 7 --keep-weekly 4 --prune"
RESTIC_RUN_ON_STARTUP="false"
TZ="Europe/Madrid"
```

El servidor usa:
- Puerto Java: `25565/tcp`
- Puerto Bedrock (plugin Geyser): `19132/udp`
- Puerto RCON: `25575/tcp`

⚠️ `RCON_PASSWORD` da acceso administrativo al servidor. Cámbiala siempre por una contraseña fuerte y única antes de exponer el puerto RCON.

Para cargar cualquier mod deberá hacerse en la carpeta `mods`
Los datos del servidor se guardan en la carpeta oculta `.data`

Ejecutar Docker compose:
```
docker compose up -d
```

Esto levanta:
- `minecraft`: servidor de juego.
- `restic-backup`: contenedor independiente con cron interno que hace backup diario a las 05:00.

## Backups automáticos con Restic

- El contenedor `restic-backup` ejecuta `restic backup /data` cada día a las 05:00 (`RESTIC_CRON_SCHEDULE`).
- Si el repositorio de Restic no existe todavía, lo inicializa automáticamente.
- Después de cada backup aplica la política de retención definida en `RESTIC_FORGET_ARGS`.

Para lanzar un backup manual:

```
docker compose exec restic-backup /usr/local/bin/run-backup.sh
```

Para listar snapshots:

```
docker compose exec restic-backup restic snapshots
```

## Restaurar backups desde Restic

1. Parar el servidor:
```
docker compose stop minecraft
```
2. Restaurar el último snapshot sobre `.data`:
```
docker compose run --rm -v "$(pwd)/.data:/restore" restic-backup restic restore latest --target /restore
```
3. Levantar de nuevo el servidor:
```
docker compose start minecraft
```
