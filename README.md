# PRÁCTICA DEL MÓDULO CI/CD
### Autor: Óscar Montes

## El despliegue

El objetivo de este proyecto es integrar un Pipeline de Jenkins con un despliegue de Web Estática en un Bucket de AWS mediante Terraform. La Web se compone de dos ficheros: index.html y error.html

## Jenkins

Versión 2.387.1 

### Plugins 

Instalamos los siguientes plugins:
- Docker
- Job DSL
- Docker commons
- Docker API
- docker-build-step
- Docker Slaves
- blue ocean
- green balls
- maven integration
- Docker pipeline
- MapDB api
- Config File Provider
- Parameterized Trigger
- Run Condition
- Conditional BuildStep
- Publish over SSH
- Environment Injector
- SSH Agent
- Git Parameter
- Pipeline Utility Steps
- Copy Artifact
- Rebuilder
- AnsiColor
- Monitoring

### Configuración

Configuración de Jenkins standard, con la URL 'http://localhost:8080/' 

Tenemos que añadir los valores en modo "Secret Text" de las variables de AWS AWS_ACCESS_KEY_ID y AWS_SECRET_ACCESS_KEY.

### Nodos/Agentes

Para este proyecto utilizaremos dos nodos/agentes externos. Para desplegarlos, entraremos en la carpeta Jenkins y, dentro de ésta, a cada una de las subcarpetas, ejecutando respectivamente:

```
docker build -t aws-jenkins ./
docker build -t test-jenkins ./
```

Lo cual generará las imagenes de los docker a desplegar mediante el fichero de docker-compose que hay en la carpeta Jenkins
```
docker-compose -f docker-compose.yaml up --build -d
```
nota: habrá previamente que exportar la siguiente variable JENKINS_AGENT_SSH_PUBKEY="$(cat ruta/fichero.pub" y modificar el fichero docker-compose.yaml del mismo modo, con el fichero de clave pública que se desee:

```
host_ssh_key:
        file:  ruta/fichero.pub
```

## El Proyecto

El proyecto consta de un pipeline de 'entrega continua' (continuous delivery), para cuyo desarrollo y testeo utilizaremos el plugin 'Blue Ocean' de Jenkins, el cual permite crear y editar el pipeline en un entorno gŕafico, sincronizando los cambios con el repositorio.

### Pipeline

El pipeline de este proyecto es un ejemplo de 'Continuous Delivery' y consta de los siguientes pasos:

- Init (terraform init): Inicializa el directorio de trabajo que contiene los ficheros de configuración
- Plan (terraform init): Crea un plan de ejecución, el cual permite previsualizar los cambios en la infraestructura que implica el despliegue. 
- Apply (terraform init): Despliega la infraestructura con "Manual approval", la cual tendrá que ser autorizada o, en su defecto, cancelada  (Continuous Delivery). 
- Test: Comprueba si la página Web desplegada responde (esta acción se realiza en el nodo "test").

Para que revise cada cada 5m si ha habido cambios en el repositorio, iremos a la configuración del pipeline y en `Scan Repository Triggers` activamos `Periodically if not otherwise run`, seleccionando el intervalo que hemos indicado.

#### Rama dev (Continuous Deploy)

En la rama `dev` omitimos el paso de `Manual approval` para que el despliegue sea completamente automático.

## Testing cada 30 minutos

Necesitamos que se ejecuten los test en la rama main cada 30 minutos, para ello utilizaremos un Job DSL.

Desde el Dashboard de Jenkins, crear nuevo item `Freestyle project`.

Seleccionamos en apartado Git en `Source Code Management` y añadimos la URL del repositorio. Tambien especificar la rama del repositorio, hay que poner 'main' como rama.

En `Build step` seleccionamos `Process Job DSLs`, y activamos la opción `Use the provided DSL script` para introducir nuestro script:
```
job('Test-App') {
  scm {
    github('KeepCodingCloudDevops7/practica-cicd-oscarmontes', 'main')
  }
  triggers {
    scm('*/30 * * * *')
  }
  steps {
    shell('''
    curl terraform-20230419064922196900000001.s3-website-eu-west-1.amazonaws.com
    ''')
  }
}
```
Con este código especificamos el scm (Source Code Management), cada que período se ejecuta (cada 30 minutos en este caso) y la tarea a ejecutar (en este caso utilizamos maven para realizar los test).

Tambien hay que tener en cuenta que detecta los cambios en scm y la tarea se ejecutará automáticamente en ese momento.

Una vez creado en Job DSL será necesario aprovar el scrip. Para ello, en `Manage Jenkins` entraremos en `In-process Script Approval` y clicaremos en `Approve` sobre nuestro script.

Ahora podremos ejecutar el cronjob creado y esto creará otro elemento en el dashboard que será la tarea que se ejecutará cada 30 minutos, y podremos consultar sus logs.

El resultado de dicho test es el siguinte:

```
First time build. Skipping changelog.
[Test-App] $ /bin/sh -xe /tmp/jenkins12543986186664983474.sh
+ curl terraform-20230419064922196900000001.s3-website-eu-west-1.amazonaws.com
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed

  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100    88  100    88    0     0    303      0 --:--:-- --:--:-- --:--:--   303
<!doctype html>
<html>
<body>
<h1>Practica Keepcoding Oscar Montes</h1>
</body>
</html>
Finished: SUCCESS
```

