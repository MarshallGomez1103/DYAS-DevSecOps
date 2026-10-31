# ADR-004. Aislamiento del entorno de despliegue

**Estado:** aceptada

## Contexto

La máquina del taller ya cuenta con un entorno local de reservas y un volumen de PostgreSQL. El despliegue desde GitHub necesita preservar ese entorno y reducir la exposición de servicios en la red de la máquina.

## Decisión

El job de CD usa el proyecto Compose `reservas-cd`, un volumen de PostgreSQL propio y un directorio de estado separado dentro del espacio de trabajo del runner. La API y PostgreSQL se publican solo en loopback, respectivamente en los puertos 18090 y 15433. El entorno local conserva su proyecto `reservas` y sus datos; no se copian automáticamente al entorno de CD.

El workflow conserva por separado la última imagen verificada y trata de restaurarla si fallan el despliegue o las verificaciones, incluida la descarga de la nueva imagen. Un despliegue automático registra la imagen después de la prueba de humo y el SLO; una reversión manual la registra después de la prueba de humo. En el primer despliegue no existe una referencia verificada: ante un fallo se detiene la aplicación no verificada. La cancelación completa del job o una caída de la máquina pueden impedir incluso esa acción y requieren revisar el estado manualmente.

## Alternativas y consecuencias

Reutilizar el volumen y el estado del entorno local conservaría sus datos en el despliegue, pero los cambios del pipeline también afectarían ese entorno. La separación permite probar CD sin modificar la base local a cambio de iniciar con una base independiente y sin una versión previa de CD. Si se necesitan los datos anteriores, su migración y verificación deben planearse antes de depender del nuevo entorno.

El acceso a la aplicación queda limitado a la propia máquina. Esta restricción y un runner temporal reducen la exposición, pero el runner con acceso a Docker conserva privilegios amplios sobre el anfitrión; una máquina virtual aislada o un servidor dedicado proporcionarían una frontera adicional.

Un contenedor local anterior conserva sus puertos publicados hasta que se detiene o se recrea con la nueva configuración. Los jobs de CD comprueban `reservas-app-1` y se detienen si encuentran un puerto publicado fuera de loopback; no modifican ese contenedor. El procedimiento de actualización del README indica cómo recrear solo la aplicación y comprobar el puerto.
