# Portfolio personal en AWS

Este repositorio contiene un portfolio web estático en español y los recursos necesarios para publicarlo en AWS. El sitio presenta el perfil profesional de Romina Alejandra Tulli, con secciones de presentación, información personal, habilidades, formación, experiencia, portfolio y contacto.

## Arquitectura

La infraestructura se define con AWS CloudFormation en `front-end-infrastructure.yml`:

- **Amazon S3** almacena los archivos del sitio en un bucket privado, con bloqueo de acceso público y cifrado del lado del servidor.
- **Amazon CloudFront** entrega el contenido por HTTPS. Su Origin Access Control (OAC) es el único autorizado a leer el bucket.
- La distribución usa `index.html` como documento raíz y permite solicitudes de lectura (`GET` y `HEAD`).

El contenido web está en `site/`. El punto de entrada es `site/index.html`, con estilos en `site/estilo.css`, comportamiento en `site/script.js` e imágenes en `site/img/`.

## Requisitos

- AWS CLI instalado y configurado con credenciales para la cuenta de destino.
- Permisos para crear y administrar recursos de CloudFormation, S3 y CloudFront.
- Bash para ejecutar los scripts.

Los scripts y la plantilla usan la región `us-east-1`. El nombre del proyecto se configura en `parameters.json`.

## Publicar el sitio

Desde la raíz del repositorio, ejecuta:

```bash
./create-infrastructure.sh
```

El script crea el stack de CloudFormation `mi-portfolio-web`, espera a que termine y publica el contenido de `site/`. La primera creación puede tardar varios minutos mientras CloudFront aprovisiona la distribución. Al finalizar, la URL del sitio se muestra en la salida del script.

Para volver a publicar cambios después de crear la infraestructura:

```bash
./upload-site.sh mi-portfolio-web ./site
```

La sincronización elimina del bucket los archivos que ya no estén en la carpeta local e invalida la caché de CloudFront para que los cambios se reflejen en el sitio.

## Eliminar la infraestructura

```bash
./delete-infrastructure.sh
```

Este comando vacía el bucket y elimina el stack `mi-portfolio-web`. **La operación borra el contenido almacenado en S3**; guarda cualquier archivo que quieras conservar antes de ejecutarla.

## Archivos principales

- `front-end-infrastructure.yml`: definición de los recursos de AWS.
- `parameters.json`: parámetros de CloudFormation, incluido el nombre del proyecto.
- `create-infrastructure.sh`: crea la infraestructura y publica el sitio.
- `upload-site.sh`: sincroniza el sitio con S3 e invalida la caché de CloudFront.
- `delete-infrastructure.sh`: vacía el bucket y solicita la eliminación del stack.
