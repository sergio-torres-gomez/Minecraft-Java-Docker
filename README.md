# Minecraft-Java-Docker
Servidor de Minecraft con Docker y backups automáticos con Restic en S3.

## Requisitos 

- Docker 20.10.5
- Docker Compose 1.25.0

## Instalación

Descargar el repositorio en la carpeta que queramos tener los archivos de Minecraft.

Crear el archivo `.env` a partir de `.env.example` y configurarlo con los valores requeridos:

```
cp .env.example .env
```

Editar `.env` y completar **obligatoriamente** estos campos:
- `SERVER_NAME`: Nombre del servidor Minecraft
- `LEVEL_NAME`: Nombre del mundo/nivel
- `RCON_PASSWORD`: Contraseña fuerte para RCON (acceso administrativo)
- Credenciales de AWS S3 para backups: `RESTIC_REPOSITORY`, `RESTIC_PASSWORD`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION`

Ejemplo de configuración:

```
SERVER_NAME="Mi Servidor"
LEVEL_NAME="Mi Mundo"
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
MODRINTH_PROJECTS="fabric-api,lithium,ferrite-core,krypton,fabric-carpet"

# Restic/S3 backup configuration (requires AWS credentials)
RESTIC_REPOSITORY="s3:s3.amazonaws.com/REPLACE_BUCKET/REPLACE_PATH"
RESTIC_PASSWORD="REPLACE_WITH_RESTIC_PASSWORD"
AWS_ACCESS_KEY_ID="REPLACE_WITH_AWS_ACCESS_KEY"
AWS_SECRET_ACCESS_KEY="REPLACE_WITH_AWS_SECRET_KEY"
AWS_DEFAULT_REGION="eu-west-1"
```

**Configuración de backups (automática)**:
- Schedule: Diariamente a las 05:00 Europe/Madrid
- Retención: 3 backups diarios + 3 backups mensuales
- Destino: S3 configurado en `RESTIC_REPOSITORY`

El servidor usa:
- Puerto Java: `25565/tcp`
- Puerto Bedrock (plugin Geyser): `19132/udp`
- Puerto RCON: `25575/tcp`

⚠️ `RCON_PASSWORD` da acceso administrativo al servidor. Cámbiala siempre por una contraseña fuerte y única antes de exponer el puerto RCON.

Para cargar cualquier mod deberá hacerse en la carpeta `mods`.
Los datos del servidor se guardan en la carpeta oculta `.data`.

Ejecutar Docker compose:
```
docker compose up -d
```

Esto levanta:
- `minecraft`: Servidor de juego Minecraft.
- `Minecraft-Backup`: Servicio de backups automáticos con Restic/S3 que ejecuta backups diarios a las 05:00 UTC.

## Backups automáticos con Restic

El contenedor `Minecraft-Backup` ejecuta automáticamente:
- **Backup diario**: Cada día a las 05:00 Europe/Madrid (`RESTIC_CRON_SCHEDULE: "0 5 * * *"`)
- **Inicialización automática**: Si el repositorio de Restic en S3 no existe, se crea automáticamente
- **Política de retención**: Mantiene 3 backups diarios y 3 backups mensuales (`RESTIC_FORGET_ARGS: "--keep-daily 3 --keep-monthly 3 --prune"`)

### Crear un backup manual

Si necesitas hacer un backup en cualquier momento (sin esperar al backup programado):

```
docker compose run --rm minecraft-restic /usr/local/bin/run-backup.sh
```

Este comando ejecutará inmediatamente:
1. Un backup completo de los datos del servidor
2. Aplicará la política de retención
3. Subirá los cambios a S3

### Listar snapshots (backups existentes)

Para ver todos los backups que tienes almacenados en S3:

```
docker compose run --rm minecraft-restic restic snapshots
```

Esto mostrará una lista con fechas, horas y IDs de cada backup disponible.

## Restaurar backups desde Restic

⚠️ **Importante**: Siempre restaura a una carpeta temporal primero para validar el contenido.

### Procedimiento de restauración segura:

1. **Parar el servidor de Minecraft**:
```
docker compose stop minecraft
```

2. **Restaurar el backup a una carpeta temporal** (puedes cambiar `latest` por un snapshot ID específico):
```
mkdir -p .restore
docker compose run --rm -v "$(pwd)/.restore:/restore" minecraft-restic restic restore latest --target /restore
```

3. **Validar el contenido** de `.restore` para asegurar que es el backup correcto.

4. **Hacer backup del estado actual** y reemplazar los datos:
```
mv .data .data.old
mkdir -p .data
cp -a .restore/. .data/
```

5. **Levantar el servidor nuevamente**:
```
docker compose start minecraft
```

6. **Si todo funciona correctamente**, puedes eliminar el backup antiguo:
```
rm -rf .data.old .restore
```

### Restaurar un backup específico (no el más reciente)

Si quieres restaurar un snapshot específico en lugar del más reciente:

```
# Primero lista todos los snapshots
docker compose run --rm minecraft-restic restic snapshots

# Luego restaura usando el ID del snapshot
docker compose run --rm -v "$(pwd)/.restore:/restore" minecraft-restic restic restore <SNAPSHOT_ID> --target /restore
```
