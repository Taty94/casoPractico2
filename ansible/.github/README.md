2. Instalación y configuración. 
Ahora es donde entra en juego Ansible como herramienta de instalación y 
configuración de la infraestructura que hemos creado en Azure. 
Tiene que estar instalado en una máquina Linux (nodo principal) y es recomendable 
para el desarrollo y las pruebas tener otra máquina Linux (virtual con VirtualBox, 
VMWare, HyperV…) que simule la que tendremos creada en Azure. 
     2.1 Instalar Ansible (para la segunda parte) 
        Descargar e instalar en Linux:
        https://docs.ansible.com/ansible/latest/installation_guide/index.html 
     2.2 Creación del fichero de inventario 
        Tenemos que crear un fichero inventory, (o hosts) donde indiquemos los nodos a 
        gestionar. (puede ser IP o hostnames y también agrupación de nodos. En nuestro 
        caso, por ejemplo: 

        [vm] 
        IP de la máquina virtual Linux generada en Azure 
        89.23.25.14 ansible_ssh_private_key_file=private_key.pem 
        [acr] 
        localhost 
        [all:vars] 
        acr_name=demoacrjoaquinsosa 
        [localhost] 
        127.0.0.1 ansible_connection=local

Este último valor porque es desde donde vamos a lanzar los playbooks de 
Ansible. 
Recordemos que podemos crear un inventario dinámico usando en terraform un 
recurso de tipo local_file y que a partir de un template (inventory.tmpl) cree el 
fichero. Lo hemos visto en clase.  
NOTA: esto no es requerido, se pueden establecer los valores en el 
inventario de forma manual para este caso práctico 2. 
Por ejemplo: 
[defaults] 
host_key_checking=False 
[vm] 
${vm_ip} ansible_ssh_private_key_file=private_key.pem 
[acr] 
localhost 
[all:vars] 
acr_name=${acr_username} 
[localhost] 
127.0.0.1 ansible_connection=local 

Explicación: 
localhost: se empleará para los roles de ACR y AKS, ya que tiene instalado 
podman y el cliente de Azure (Az-CLI). 
Importante también tener en cuenta que esta máquina también tenemos la 
clave privada de la máquina virtual de Azure para poder hace login por SSH 
contra ella. Esto es posible siguiendo el mismo procedimiento que con la 
configuración del clúster: leyendo la salida de Terraform y mandando está a un 
fichero. 
terraform output -raw ssh_private_key_file > ruta_a_la_clave 
webserver: este host es el que se declara en el inventario dinámico de Ansible, y 
es donde se instalará Podman y se realizarán los pasos del rol VM 
     2.3 Creación del fichero del playbook. 
        Creamos un fichero playbook.yml y en él tenemos que definir el nombre del 
        playbook, dónde se va a ejecutar (en qué nodos del inventario), si tiene variables 
        o un fichero de variables (vars_files:), la tarea o tareas a ejecutar.  
        Un solo fichero playbook.yml puede contener la definición de todos los 
        playbooks

        --- - name: Setup ACR and images  
        hosts: localhost 
        vars_files:  - secrets.yml 
        tasks: - name: Pull, build, tag and push images to ACR 
        include_role: 
        name: acr
        - name: Setup Webserver 
        hosts: webapp 
        vars_files:  - secrets.yml 
        tasks: - name: Configure VM with Podman and deploy web server 
        include_role: 
        name: vm 
        - name: Setup AKS 
        hosts: localhost 
        vars_files:  - secrets.yml 
        tasks: - name: Deploy app to AKS 
        include_role: 
        name: aks 

En este caso hemos definido 3 playbooks cada uno con sus propiedades y vemos 
que se ha hecho uso de roles para agrupar las tareas y hacer reutilizable ese 
componente.

Por ejemplo, podríamos tener esta estructura de ficheros: 
    ansible
    |___roles
        |___ acr/tasks
        |   |___ main.yml
        |___ aks/tasks
        |   |___ main.yml
        |___ vm/tasks
        |___ azure_rm.yml
        |___ hosts.ini
        |___ playbook.yml

En el cual vemos que tenemos el fichero del playbook, el del inventario (hosts) y 
tenemos 3 roles: acr, aks, vm en los cuales, en cada fichero main.yml dentro de 
una carpeta tasks, tenemos lo que hace cada uno de ellos. Además, vemos que 
tenemos un azure_rm.yaml que nos ayuda a configurar ansible con el proveedor 
Azure. () 

Otra posible estructura es:

    ansible
    |___roles
        |___ app
        |   |___ vars
        |       |___ main.yml
        |___ webserver
        |   |___ defaults
        |       |___ main.yml
        |       |___ tasks
        |           |___ main.yml
        |___ credentials.yml
        |___ inventory
        |___ playbook.yml

En el cual vemos que se ha distribuido en tres roles, uno para el ACR, otro para el 
despliegue de los objetos de K8s en AKS (Deployment, Service…) y otro para el 
webserver.  
1.- En este último, las tareas son instalar Podman, hacer el login contra el ACR y 
ejecutar un nginx (o apache) web server como un contenedor usando podman. 
Recordar el módulo apt de ansible y los módulos de ansible-galaxy: 
    containers.podman.podman_container 
    containers.podman.podman_login

NOTA: Si se necesitan instalar estos módulos: ansible-galaxy collection install 
<nombre del módulo> 
2.- En el rol acr es donde se bajan las imágenes que vamos a utilizar (un servidor 
web y una aplicación con persistencia) de un repositorio público (dockerhub), se 
etiquetan (tag images) y se suben a nuestro ACR de Azure. 

3.- En el del despliegue de la aplicación en AKS, tendríamos que crear un 
namespace y hacer el deploy de la aplicación, usando el nodo k8s, por ejemplo: 

- name: Create namespace 
  k8s: 
    definition: 
      kind: Namespace 
      apiVersion: v1 
      metadata: 
        name: "{{ app_namespace }}" 
 - name: Deploy App 
  k8s: 
    definition: "{{ lookup('template', 'app_template.yml.j2') }}" 
    namespace: "{{ app_namespace }}" 

Aquí se hace uso de una template que se rellena con unas variables definidas en 
un fichero main.yml. Ejemplo: 

    app: 
  backend: 
    name: backend  
    image: redis:6.0.8 
    replicas: 1 
    requests: 
      cpu: 100m 
      memory: 128Mi 
    limits: 
      cpu: 250m 
      memory: 256Mi 
    port: 6379 
    pv: redis-data 

La template, o lo ficheros si no usan templates, tendrían: - Deployment del backend:
    apiVersion: apps/v1 
    kind: Deployment 
    metadata:   
        name: "{{ app.backend.name }}" 
        namespace: "{{ app_namespace }}" 
    spec: 
        replicas: {{ app.backend.replicas }}


Se especifica el volume a usar (usando el PersistentVolumeClaim), la imagen de 
la que va a crear el contenedor, variables de entorno si las usa…


- - - - 
El PersistentVolumeClaim 
El Service que conecta el backend con el frontend. 
El deployment del frontend 
El Service de tipo LoadBalancer que permite acceder desde el exterior 
mediante una IP pública al frontend. 
Se puede utilizar un fichero secrets.yaml. En este fichero se guardarán los datos 
sensibles, ya que se securizarán con Ansible-Vault, estableciendo una contraseña 
para este, que se le pasará por comando en el momento de despliegue del 
playbook. (Opcional) 
La descripción de lo que hace cada uno de los roles podría ser como la 
siguiente:

 Rol ACR  
 - Se conecta en primera instancia al ACR creado por Terraform, usando como 
variables la URL, el usuario y la contraseña.  
- Se descarga las imágenes necesarias de un repositorio público. 
- “Tag” de las imágenes. - Hace “push” de las imágenes al ACR. 

Rol VM  
- Actualiza los repositorios (con permisos de administrador)  
- Instala Podman (con permisos de administrador)  
- “Pull” de la imagen desde ACR  
- Arranca el servicio con la imagen descargada y un volume montado para 
acceso desde el Host  
- Crea el usuario con autenticación básica  
- Reinicia el servicio

Rol AKS  
- Crea el secreto para poder conectar con el ACR.  
- Crea el template para desplegar la aplicación.  
- Crea el Volumen Persistente que se conectará al pod  
- Crea el Servicio de Load Balancer que escuchará las peticiones desde el 
exterior al pod  

Con estos pasos ya tendríamos desplegados nuestro servidor web por un lado y 
nuestra aplicación con persistencia por otro.

2.4  Ejecución del playbook de Ansible: 
Lanzaríamos el playbook con un comando del tipo: 
ansible-playbook -i hosts podman-playbook.yml --ask-vault
pass 
siendo -i hosts el inventario y el fichero yaml del playbook. --ask-vault-pass: en caso de que necesitemos que el playbook use algún valor 
almacenado en el vault. 