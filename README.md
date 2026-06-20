Arquitectura de Monitoreo Inteligente - Registro de Incidentes SOC (Semana 3)
Esta práctica construye el primer proyecto integrador de administración de seguridad e infraestructura en la nube. El objetivo es modernizar los centros de operaciones de seguridad (SOC) mitigando la fragilidad en la cadena de custodia digital. El sistema registra incidentes críticos guardando los datos operativos completos en PostgreSQL y dejando una evidencia forense inmutable y verificable en blockchain mediante el contrato inteligente RegistroIncidentesSOC.

La práctica avanza por etapas:

Crear y probar un contrato inteligente en Solidity con Hardhat y Viem.

Ejecutar el ciclo de vida del contrato y scripts de automatización desde Docker.

Levantar un entorno blockchain de desarrollo local utilizando Docker Compose.

Desplegar el contrato inmutable y guardar su dirección física.

Desarrollar una API de Control SOC con FastAPI y documentación interactiva mediante Swagger.

Asegurar la persistencia de datos relacionales en PostgreSQL.

Realizar el registro cruzado de hashes forenses en blockchain desde la API (Modelo On-Chain/Off-Chain).

Verificar desde Swagger que el incidente está auditado y que la integridad de la evidencia se mantiene intacta.

Problema Que Busca Resolver
En los centros de monitoreo tradicionales (SOC/NOC), las plataformas centralizadas de SIEM/SOAR son vulnerables a la manipulación de registros por parte de atacantes avanzados o amenazas internas que buscan borrar sus huellas.

Para resolver este desafío sin vulnerar las regulaciones de privacidad de datos personales (GDPR a nivel internacional y LOPDP en Ecuador), esta arquitectura implementa un enfoque híbrido:

PostgreSQL (Off-Chain): Guarda la información operativa completa, logs crudos y detalles que pudieran contener datos confidenciales o sensibles expuestos al derecho al olvido.

Blockchain (On-Chain): Registra exclusivamente las huellas digitales inmutables (idIncidenteHash y hashEvidenciaOffChain) junto con el control estricto de estados y SLAs por nivel de gravedad (Crítico, Alto, Medio, Bajo). Si el repositorio externo es purgado, la blockchain no almacena datos residuales, resolviendo el conflicto de inmutabilidad vs privacidad.

Arquitectura
Plaintext
Usuario Operador / Swagger (CISO / Auditores)
              |
              v
     API Control SOC - FastAPI
              |
              +---> [Guarda Ficha Operativa Completa] ----> PostgreSQL (Off-Chain)
              |
              +---> [Registra Hashes Criptográficos] ----> Contrato RegistroIncidentesSOC (On-Chain)
                                                                    |
                                                                    v
                                                            Red Blockchain Local
Servicios orquestados:
blockchain-node: Nodo local de desarrollo expuesto en el puerto 8545.

contract-tools: Contenedor técnico basado en Hardhat para compilar, probar y desplegar los contratos inteligentes de ciberseguridad.

postgres: Base de datos relacional para el almacenamiento persistente de las fichas de incidentes.

api-soc: Microservicio construido en FastAPI que expone la lógica del negocio de seguridad en el puerto 8000.

Estructura del Proyecto
Plaintext
SEMANA_3/
  README.md
  .env.example
  docker-compose.yml
  blockchain/
    Dockerfile
    hardhat.config.ts
    package.json
    tsconfig.json
    contracts/
      RegistroIncidentesSOC.sol
    scripts/
      deploy-soc.ts
  api-soc/
    Dockerfile
    requirements.txt
    main.py
    database.py
    models.py
    schemas.py
    blockchain.py
    contracts/
      RegistroIncidentesSOC.json
Requisitos Previos
Docker Desktop instalado y corriendo.

Node.js 22 o superior (para validaciones locales de Hardhat).

Terminal compatible (Bash, Zsh o PowerShell).

Verificación de dependencias en el entorno:

Bash
docker --version
docker compose version
node --version
npm --version
Variables De Entorno
Crea una instancia de configuración .env en la raíz del proyecto SEMANA_3 tomando como plantilla .env.example:

Bash
cp .env.example .env
Contenido base requerido:

Ini, TOML
GANACHE_RPC_URL=http://blockchain-node:8545
GANACHE_PRIVATE_KEY=0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d
CONTRACT_ADDRESS=0xREEMPLAZAR_CON_LA_DIRECCION_DEL_CONTRATO_DESPLEGADO
POSTGRES_DB=soc_incidentes_db
POSTGRES_USER=admin
POSTGRES_PASSWORD=admin123
1. Configuración de la Capa Blockchain (Hardhat)
Si necesitas inicializar el entorno desde cero en el directorio blockchain:

Bash
mkdir blockchain
cd blockchain
npx hardhat init
Selecciona la opción de configuración para un proyecto TypeScript utilizando Viem.

2. Lógica del Contrato Inteligente
El componente medular reside en blockchain/contracts/RegistroIncidentesSOC.sol. Sus responsabilidades principales son:

Registrar de forma única un incidente utilizando el hash del ticket (idIncidenteHash) e impidiendo duplicidades.

Almacenar de forma inalterable la huella criptográfica de los artefactos forenses (hashEvidenciaOffChain).

Registrar la firma/dirección criptográfica del operador o nodo del SOC que reportó la alerta.

Proveer un flujo controlado para cambiar el estado del ciclo de vida del incidente (Reportado, Triageado, En Progreso, Escalado, Resuelto, Cerrado).

Indexar niveles de gravedad (Bajo, Medio, Alto, Crítico) para auditorías automatizadas de Acuerdos de Nivel de Servicio (SLA).

3. Pruebas y Compilación Local
Desde la carpeta blockchain, instala las dependencias y compila el código fuente para generar las interfaces binarias de aplicación (ABI):

Bash
npm install
npx hardhat compile
Para validar el despliegue funcional en una red efímera local de pruebas de Hardhat:

Bash
npx hardhat run scripts/deploy-soc.ts
Este script inicializa el entorno de ejecución, despliega de forma simulada el contrato de seguridad, procesa hashes de prueba y valida las funciones de consulta, destruyendo la red temporal al concluir de forma exitosa.

4. Construcción y Ejecución de Imágenes con Docker
El archivo Dockerfile optimizado en la raíz del componente blockchain compila de forma automatizada los contratos inteligentes durante la fase de construcción.

Construcción de la imagen:

Bash
docker build -t registro-incidentes-soc-image ./blockchain
Ejecutar la compilación por defecto integrada:

Bash
docker run --rm registro-incidentes-soc-image
Ejecutar de forma explícita el script de despliegue sobreescribiendo el comando por defecto del contenedor:

Bash
docker run --rm registro-incidentes-soc-image npx hardhat run scripts/deploy-soc.ts
5. Orquestación del Nodo Blockchain de Seguridad
Para aprovisionar y levantar el ledger local de la infraestructura blockchain:

Bash
docker compose up -d blockchain-node
Inspección técnica del estado del nodo y visualización de logs transaccionales en tiempo real:

Bash
docker compose ps
docker compose logs blockchain-node
El nodo quedará expuesto de manera externa para herramientas de inspección en http://localhost:8545.

6. Despliegue del Contrato Inmutable en la Infraestructura
Ejecuta las herramientas de despliegue (contract-tools) apuntando de manera directa hacia la red del nodo blockchain localmente orquestado:

Bash
docker compose run --rm contract-tools npx hardhat run scripts/deploy-soc.ts --network ganache
Salida esperada por consola:

Plaintext
Desplegando contrato de infraestructura SOC (RegistroIncidentesSOC)...
Contrato de auditoría inmutable deployed exitosamente.
Dirección del contrato SOC: 0x742d35Cc6634C0532925a3b844Bc454e4438f44e
Paso Crítico: Copia la dirección hexadecimal devuelta por la consola y actualiza de inmediato el archivo .env en la raíz del proyecto integrador:

Ini, TOML
CONTRACT_ADDRESS=0x742d35Cc6634C0532925a3b844Bc454e4438f44e
7. Verificación de Bytecode Transaccional
Puedes ingresar de forma directa a la terminal de comandos interactiva de Hardhat conectada a la red activa para auditar que el código del Smart Contract se ha guardado correctamente:

Bash
docker compose run --rm contract-tools npx hardhat console --network ganache
Dentro de la consola interactiva, ejecuta el siguiente código:

JavaScript
const { viem } = await network.create()
const publicClient = await viem.getPublicClient()
await publicClient.getCode({ address: "0xTU_DIRECCION_DE_CONTRATO_AQUI" })
Si la consola retorna el bytecode hexadecimal del contrato (0x608060...), el despliegue es válido. Para salir, escribe .exit.

8. Persistencia Forense de la Red
La base de datos del nodo blockchain se mapea hacia un volumen persistente de Docker de la siguiente forma:

YAML
volumes:
  - ganache_data:/data
Esto garantiza que aunque los contenedores sufran un reinicio o apagado planeado mediante un comando docker compose down, los bloques, registros de incidentes previos y hashes forenses persistan en la infraestructura de almacenamiento.
Nota: Evita utilizar la bandera -v (docker compose down -v) a menos que requieras realizar una purga total de la cadena forense para iniciar las pruebas desde cero.

9. Despliegue Completo del Entorno Integrado
Una vez configuradas las variables de entorno, construye y levanta todos los microservicios, la base de datos relacional y la API de control:

Bash
docker compose up -d --build
Verifica la correcta orquestación y mapeo de los puertos del SOC:

Bash
docker compose ps
Puertos Activos del Centro de Operaciones:
Blockchain Ledger (blockchain-node): Puerto 8545

Almacenamiento Off-Chain (postgres): Puerto 5432

API Gateway de Control SOC (api-soc): Puerto 8000 -> Interfaz Swagger en http://localhost:8000/docs

10. Endpoints de la API del SOC
La aplicación backend desarrollada con FastAPI (api-soc/) expone los siguientes controladores y rutas de control:

GET /health: Verifica el estado operativo de los servicios.

GET /blockchain/contract: Retorna la configuración base del contrato e identidades PKI asociadas.

POST /incidentes: Registra una nueva alerta de ciberseguridad en PostgreSQL y calcula los hashes correspondientes.

GET /incidentes/{id_ticket}: Recupera la información operativa e histórica off-chain de la base de datos relacional.

GET /incidentes/{id_ticket}/verificar: Realiza la verificación criptográfica cruzada comparando la base relacional contra la inmutabilidad del bloque en la blockchain.

11. Automatización y Pruebas desde PowerShell
Prueba de salud de la API:

PowerShell
Invoke-RestMethod -Uri "http://localhost:8000/health"
Inyección y registro de un incidente crítico (Simulación de ataque de Ransomware):

PowerShell
$body = @{
  codigo_titulo = "INC-SOC-2026-8942"
  nombre_estudiante = "Servidor Active Directory"
  identificacion_estudiante = "10.0.4.15"
  carrera = "Infraestructura Central"
  titulo_obtenido = "Compromiso de Credenciales e Infección Extorsionadora"
  universidad = "SOCOrg_Node_01"
  fecha_emision = "2026-06-19"
  contenido_documento = "Log de auditoría - Servidor Active Directory comprometido por Ransomware. Hash SHA-256 local."
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8000/incidentes" -Method Post -ContentType "application/json" -Body $body
Validación cruzada de integridad forense contra Blockchain:

PowerShell
Invoke-RestMethod -Uri "http://localhost:8000/incidentes/INC-SOC-2026-8942/verificar"
Respuesta Esperada de Custodia Digital:
JSON
{
  "existe_en_blockchain": true,
  "evidencia_mantiene_integridad": true
}
12. Estructura de Datos Almacenados (Esquema Corporativo)
Base de Datos Relacional PostgreSQL (Off-Chain)
Al ingresar al motor mediante docker compose exec postgres psql -U admin -d soc_incidentes_db, la tabla del SOC almacena la siguiente metadata:

Identificador de Ticket Único Operativo.

Servidor, Sistema o Activo Afectado.

Dirección IP / Identificador Técnico del Host.

Tipo de Incidente / Vector de Ataque.

Descripción detallada del hallazgo y logs de auditoría sin procesar.

Organización u Operador Emisor de la Alerta.

Fecha y hora del evento.

idIncidenteHash: Huella criptográfica SHA-256 del ticket.

hashEvidenciaOffChain: Huella inmutable de los archivos adjuntos o logs forenses.

Hash de la transacción blockchain (tx_hash) generada para auditoría rápida.

Ledger Blockchain (On-Chain)
El Smart Contract restringe los datos públicos almacenados exclusivamente a:

idIncidenteHash (Identificador único anonimizado).

hashEvidenciaOffChain (Firma digital de verificación de logs).

operadorSOC (Dirección pública de la organización responsable).

fechaRegistro (Marca de tiempo inmutable provista por el bloque).

gravedad y estado (Enumerados para control estricto del cumplimiento de los tiempos de SLA de respuesta).

13. Publicación de Contenedores en Docker Hub
Para empaquetar, versionar y distribuir las imágenes de la arquitectura a entornos de producción o staging:

Autentícate en el registro oficial:

Bash
docker login
Construye y etiqueta las imágenes del ecosistema del SOC (reemplaza TU_USUARIO_DOCKERHUB por tus credenciales reales):

Bash
# Imagen de las herramientas del contrato inteligente
docker build -t TU_USUARIO_DOCKERHUB/soc-blockchain-contract:1.0 ./blockchain
docker tag TU_USUARIO_DOCKERHUB/soc-blockchain-contract:1.0 TU_USUARIO_DOCKERHUB/soc-blockchain-contract:latest

# Imagen del microservicio de la API del SOC
docker build -t TU_USUARIO_DOCKERHUB/soc-control-api:1.0 ./api-soc
docker tag TU_USUARIO_DOCKERHUB/soc-control-api:1.0 TU_USUARIO_DOCKERHUB/soc-control-api:latest
Sube las imágenes a tu repositorio de Docker Hub:

Bash
docker push TU_USUARIO_DOCKERHUB/soc-blockchain-contract:latest
docker push TU_USUARIO_DOCKERHUB/soc-control-api:latest
Una vez publicadas, puedes actualizar conceptualmente el archivo de orquestación docker-compose.yml para utilizar las imágenes del registro público en lugar de realizar construcciones locales compartidas, facilitando la portabilidad del entorno:

YAML
contract-tools:
  image: TU_USUARIO_DOCKERHUB/soc-blockchain-contract:1.0

api-soc:
  image: TU_USUARIO_DOCKERHUB/soc-control-api:1.0
