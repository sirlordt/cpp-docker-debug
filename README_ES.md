# Depuración de C/C++ en Docker vía SSH

Este proyecto demuestra cómo depurar programas C/C++ dentro de un contenedor Docker utilizando SSH para la comunicación entre VSCode y GDB.

## Visión general

Este enfoque ofrece varias ventajas:
- El código se compila y depura en el mismo entorno (contenedor Docker)
- Comunicación directa entre VSCode y GDB dentro del contenedor
- No es necesario copiar binarios entre el contenedor y el host
- Los puntos de interrupción funcionan de manera confiable en VSCode

## Estructura del proyecto

- `src/`: Directorio de código fuente
  - `main.cpp`: Programa de ejemplo en C++
  - `sample.c`: Programa de ejemplo en C
  - `CMakeLists.txt`: Configuración de CMake para compilar los programas
- `CMakeLists.txt`: Configuración principal de CMake
- `conanfile.txt`: Configuración de Conan para gestionar dependencias
- `Dockerfile`: Configuración de Docker para el entorno de desarrollo
- `docker-compose.yml`: Configuración de Docker Compose
- `.vscode/`: Configuración de VSCode
  - `launch.json`: Configuraciones de depuración
  - `tasks.json`: Tareas de compilación
- Scripts:
  - `setup-ssh-debug.sh`: Script de configuración para depuración SSH
  - `build.sh`: Script para compilar los programas
  - `run.sh`: Script para ejecutar los programas
  - `test-ssh.sh`: Prueba de conexión SSH
  - `test-gdb-ssh.sh`: Prueba de depuración GDB vía SSH
- Documentación:
  - `SSH_DEBUG.md`: Documentación en inglés
  - `SSH_DEBUG_ES.md`: Documentación en español

## Primeros pasos

### Requisitos previos

- Docker y Docker Compose
- Visual Studio Code con extensión C/C++
- sshpass (será instalado automáticamente por el script de configuración si es necesario)

El entorno Docker incluye:
- CMake (última versión 3.28.3)
- Conan (última versión 2.x, instalado con pip)
- GDB y otras herramientas de desarrollo

### Gestión de dependencias con Conan

Este proyecto utiliza Conan 2.x para la gestión de dependencias. El archivo `conanfile.txt` en el directorio raíz define las dependencias del proyecto y los generadores:

```
[requires]
# Añade tus dependencias aquí, por ejemplo:
# boost/1.79.0
# fmt/9.1.0

[generators]
CMakeDeps
CMakeToolchain

[options]
# Especifica opciones para los paquetes aquí
```

Para añadir una nueva dependencia:

1. Añádela a la sección `[requires]` en `conanfile.txt`
2. Actualiza el CMakeLists.txt para encontrar y enlazar el paquete:
   ```cmake
   find_package(NombrePaquete REQUIRED)
   target_link_libraries(tu_objetivo NombrePaquete::NombrePaquete)
   ```

### Sistema de compilación con CMake

El proyecto utiliza CMake como sistema de compilación. El archivo `CMakeLists.txt` principal en el directorio raíz configura el proyecto, y el archivo `src/CMakeLists.txt` define los ejecutables.

El proceso de compilación está integrado con Conan, que genera los archivos CMake necesarios para la gestión de dependencias.

### Configuración

1. Clona este repositorio
2. Ejecuta el script de configuración:
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

### Depuración

1. Establece puntos de interrupción en tu código haciendo clic en el margen izquierdo (gutter)
2. Selecciona la configuración "Debug C++ in Docker via SSH" del menú Run and Debug
3. Inicia la depuración haciendo clic en el botón verde de play o presionando F5

El depurador:
- Compilará automáticamente el código en Docker
- Se conectará al contenedor vía SSH
- Lanzará GDB dentro del contenedor
- Se adjuntará al programa
- Se detendrá en tus puntos de interrupción

## Documentación

Para información más detallada, consulta:
- [Guía de depuración SSH (Inglés)](SSH_DEBUG.md)
- [Guía de depuración SSH (Español)](SSH_DEBUG_ES.md)

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - consulta el archivo LICENSE para más detalles.
