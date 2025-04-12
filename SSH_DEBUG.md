# Debugging C/C++ Programs in Docker via SSH

Esta guía explica cómo depurar programas C/C++ directamente dentro del contenedor Docker utilizando SSH para la comunicación entre VSCode y GDB.

## Visión general

Este enfoque ofrece varias ventajas:
- El código se compila y depura en el mismo entorno (contenedor Docker)
- Comunicación directa entre VSCode y GDB dentro del contenedor
- No es necesario copiar binarios entre el contenedor y el host
- Los puntos de interrupción funcionan de manera confiable en VSCode

## Requisitos previos

El contenedor Docker ya está configurado con:
- Servidor SSH instalado y configurado
- Puerto 22 en el contenedor mapeado al puerto 2222 en el host
- Un usuario llamado 'developer' con contraseña 'password'

## Configuración inicial

### Opción 1: Configuración automática (recomendada)

Usa el script `setup-ssh-debug.sh` para configurar automáticamente todo lo necesario:

```bash
./setup-ssh-debug.sh
```

Este script:
- Crea el directorio ~/.ssh y establece los permisos adecuados
- Añade la clave del host del contenedor Docker a known_hosts
- Instala sshpass si no está instalado
- Verifica que el contenedor Docker está en ejecución
- Comprueba que el servidor SSH está funcionando en el contenedor
- Prueba la conexión SSH
- Compila el programa C++

### Opción 2: Configuración manual

Si prefieres configurar todo manualmente, sigue estos pasos:

#### 1. Preparar el entorno SSH en el host

Para que la depuración vía SSH funcione correctamente, necesitamos configurar algunas cosas en el sistema host:

```bash
# Crear el directorio ~/.ssh si no existe y establecer permisos adecuados
mkdir -p ~/.ssh && chmod 700 ~/.ssh

# Añadir la clave del host del contenedor Docker a known_hosts
ssh-keyscan -p 2222 localhost >> ~/.ssh/known_hosts
```

#### 2. Instalar sshpass

Para la autenticación automática por contraseña, necesitamos instalar `sshpass`:

```bash
sudo apt-get update && sudo apt-get install -y sshpass
```

### Scripts de ayuda

El proyecto incluye varios scripts para facilitar este flujo de trabajo:

- `setup-ssh-debug.sh`: Configura automáticamente todo lo necesario para la depuración vía SSH
- `test-ssh.sh`: Verifica que la conexión SSH al contenedor funciona correctamente
- `test-gdb-ssh.sh`: Prueba la depuración con GDB a través de SSH
- Otros scripts de las aproximaciones anteriores siguen disponibles si los necesitas

## Flujo de trabajo

### 1. Verificar la conexión SSH

Usa el script `test-ssh.sh` para verificar que SSH está funcionando en el contenedor:

```bash
./test-ssh.sh
```

Este script:
- Crea el directorio ~/.ssh si no existe
- Añade la clave del host del contenedor a known_hosts
- Instala sshpass si no está instalado
- Verifica que el contenedor Docker está en ejecución
- Comprueba que el servidor SSH está funcionando en el contenedor
- Proporciona información de conexión

También puedes probar la conexión SSH manualmente:

```bash
sshpass -p "password" ssh developer@localhost -p 2222
```

### 2. Depurar el programa vía SSH

En VSCode:

1. Establece puntos de interrupción en tu código haciendo clic en el margen izquierdo (gutter)
2. Selecciona la configuración "Debug C++ in Docker via SSH" del menú Run and Debug
3. Inicia la depuración haciendo clic en el botón verde de play o presionando F5

El depurador:
- Compilará automáticamente el código en Docker
- Se conectará al contenedor vía SSH
- Lanzará GDB dentro del contenedor
- Se adjuntará al programa
- Se detendrá en tus puntos de interrupción

### 3. Editar y repetir

Después de hacer cambios en tu código:

1. El depurador reconstruirá automáticamente el código en Docker cuando inicies la depuración nuevamente
2. También puedes compilar manualmente el código usando la tarea "Build C++ in Docker"

## Cómo funciona

Este enfoque utiliza la característica "pipe transport" de VSCode para comunicarse con GDB a través de SSH:

1. VSCode lanza una conexión SSH al contenedor usando sshpass para la autenticación automática
2. Los comandos se envían a GDB dentro del contenedor a través de la conexión SSH
3. GDB dentro del contenedor tiene acceso directo al programa y sus símbolos
4. Los puntos de interrupción y otras características de depuración funcionan de manera confiable porque no hay una capa intermedia como gdbserver

### Configuración técnica en launch.json

La configuración en `launch.json` utiliza `sshpass` para la autenticación automática:

```json
"pipeTransport": {
    "pipeCwd": "${workspaceFolder}",
    "pipeProgram": "sshpass",
    "pipeArgs": [
        "-p",
        "password",
        "ssh",
        "-p", 
        "2222", 
        "-o", 
        "StrictHostKeyChecking=no",
        "-o",
        "UserKnownHostsFile=/dev/null",
        "developer@localhost"
    ],
    "debuggerPath": "/usr/bin/gdb"
}
```

## Solución de problemas

Si encuentras problemas:

1. Asegúrate de que el contenedor Docker está en ejecución:
   ```bash
   docker ps | grep cpp-dev-container
   ```

2. Si el contenedor no está en ejecución, inícialo:
   ```bash
   docker-compose up -d
   ```

3. Verifica que SSH está funcionando:
   ```bash
   ./test-ssh.sh
   ```

4. Prueba la depuración con GDB vía SSH:
   ```bash
   ./test-gdb-ssh.sh
   ```

5. Si no puedes conectarte vía SSH, verifica los logs de Docker:
   ```bash
   docker logs cpp-dev-container
   ```

6. Asegúrate de que el servidor SSH está en ejecución en el contenedor:
   ```bash
   docker exec cpp-dev-container pgrep sshd
   ```

7. Si el servidor SSH no está en ejecución, inícialo:
   ```bash
   docker exec cpp-dev-container /usr/sbin/sshd
   ```

8. Si tienes problemas con la autenticación SSH, asegúrate de que:
   - El directorio ~/.ssh existe y tiene los permisos correctos
   - La clave del host del contenedor está en known_hosts
   - sshpass está instalado

## Comparación con otros enfoques

Este proyecto ahora soporta tres enfoques diferentes de depuración:

1. **Enfoque SSH (esta guía)**:
   - Depurar directamente dentro del contenedor vía SSH
   - Pros: Comunicación directa con GDB, puntos de interrupción confiables
   - Cons: Requiere configuración SSH

2. **Enfoque de binario local**:
   - Compilar en Docker, copiar el binario al host, depurar localmente
   - Pros: Simple, puntos de interrupción confiables
   - Cons: El binario se ejecuta en un entorno diferente al de compilación

3. **Enfoque gdbserver**:
   - Usar gdbserver dentro del contenedor
   - Pros: Depurar en el mismo entorno que la compilación
   - Cons: Puntos de interrupción menos confiables debido a la comunicación indirecta

Elige el enfoque que mejor se adapte a tus necesidades y flujo de trabajo.
