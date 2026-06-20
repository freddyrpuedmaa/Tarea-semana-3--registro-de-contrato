# 🛡️ Arquitectura de Monitoreo Inteligente - Registro de Incidentes SOC (Semana 3)

Este proyecto representa una solución integradora para la administración de seguridad e infraestructura en la nube. El objetivo principal es modernizar los centros de operaciones de seguridad (**SOC / NOC**), mitigando la fragilidad en la cadena de custodia digital y previniendo la manipulación de logs por parte de atacantes o amenazas internas. El sistema registra incidentes críticos guardando los datos operativos completos de forma privada (**Off-Chain**) y dejando una evidencia forense inmutable y verificable en blockchain (**On-Chain**) mediante el contrato inteligente `RegistroIncidentesSOC`.

---

## 🚀 Fases del Proyecto Integrador

1. **Capa Smart Contract:** Diseño e implementación del contrato inteligente en Solidity optimizado para `Hardhat` y `Viem`.
2. **Contenedores de Desarrollo:** Ejecución y automatización del ciclo de vida del contrato y scripts de testing desde entornos Docker localizados.
3. **Ecosistema Blockchain:** Despliegue en un ledger local de desarrollo orquestado mediante Docker Compose.
4. **API Gateway de Control SOC:** Construcción de un backend con **FastAPI** y documentación interactiva mediante **Swagger**.
5. **Persistencia Relacional:** Almacenamiento seguro de metadatos de incidentes en una base de datos **PostgreSQL**.
6. **Validación de Custodia Digital:** Verificación cruzada (Cross-Validation) automatizada desde los endpoints de la API para garantizar que la evidencia mantiene su integridad física.

---

## 🔍 El Problema a Resolver (Enfoque On-Chain / Off-Chain)

En un SOC tradicional, las plataformas de indexación de logs (SIEM / SOAR) centralizadas representan un punto único de falla si un atacante obtiene privilegios elevados, ya que podría borrar los registros para ocultar una intrusión.

Para resolver este desafío sin entrar en conflicto con las normativas internacionales de protección de datos personales (**GDPR** y la **LOPDP** de Ecuador), este proyecto adopta una **arquitectura híbrida**:

* **PostgreSQL (Off-Chain):** Almacena el contenido completo del ticket de soporte, datos del operador, IPs, logs crudos y detalles que pudieran contener información confidencial expuesta al *derecho al olvido* (Artículo 17 GDPR).
* **Blockchain (On-Chain):** Almacena exclusivamente los hashes criptográficos SHA-256 (`idIncidenteHash` y `hashEvidenciaOffChain`) junto con el control estricto de los estados del flujo y el nivel de severidad para auditar automáticamente los Acuerdos de Nivel de Servicio (**SLA**). Si los logs son depurados de la base de datos externa, la blockchain no retiene datos residuales legibles.

---

## 📐 Arquitectura del Sistema

```text
Usuario Operador (SOC / Auditoría)
              |
              v
     [Puerto 8000] API Control SOC - FastAPI
              |
              +---> (Guarda Ficha Operativa Completa) ----> [Puerto 5432] PostgreSQL (Off-Chain)
              |
              +---> (Registra Hashes e Inmutabilidad) ----> Contrato RegistroIncidentesSOC (On-Chain)
                                                                    |
                                                                    v
                                                            [Puerto 8545] Nodo Blockchain

Componentes Orquestados:
blockchain-node: Nodo local de desarrollo expuesto en el puerto 8545.

contract-tools: Contenedor técnico basado en Hardhat para compilar, probar y desplegar los contratos inteligentes.

postgres: Motor de base de datos relacional para el almacenamiento local de fichas operativas.

api-soc: Microservicio backend construido en FastAPI expuesto en el puerto 8000.

# 📂 Estructura del Repositorio

SEMANA_3/
  ├── README.md
  ├── .env.example
  ├── docker-compose.yml
  ├── blockchain/
  │   ├── Dockerfile
  │   ├── .dockerignore
  │   ├── hardhat.config.ts
  │   ├── package.json
  │   ├── tsconfig.json
  │   ├── contracts/
  │   │   └── RegistroIncidentesSOC.sol
  │   └── scripts/
  │       └── deploy-soc.ts
  └── api-soc/
      ├── Dockerfile
      ├── requirements.txt
      ├── main.py
      ├── database.py
      ├── models.py
      ├── schemas.py
      ├── blockchain.py
      └── contracts/
          └── RegistroIncidentesSOC.json


#🛠️ Requisitos Previos
Asegúrate de contar con las siguientes herramientas instaladas en tu estación de trabajo local:

Docker Desktop activo.

Node.js 22+ (opcional, para ejecuciones locales fuera del contenedor).

Terminal compatible (Zsh, Bash o PowerShell).

Comprueba las versiones en tu consola:

docker --version
docker compose version
node --version
npm --version

🔑 Variables de Entorno
Configura las credenciales locales copiando la plantilla base de entorno en la raíz del proyecto SEMANA_3:

cp .env.example .env

Edita el archivo .env garantizando los siguientes parámetros base para desarrollo local:

GANACHE_RPC_URL=http://blockchain-node:8545
GANACHE_PRIVATE_KEY=0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d
CONTRACT_ADDRESS=0xREEMPLAZAR_CON_LA_DIRECCION_DEL_CONTRATO_DESPLEGADO
POSTGRES_DB=soc_incidentes_db
POSTGRES_USER=admin
POSTGRES_PASSWORD=admin123

🧑‍💻 Guía de Despliegue por PasosPaso 1: Compilación del Smart Contract del SOCAccede al directorio del componente blockchain, instala los módulos necesarios y compila el archivo .sol para generar los artefactos (ABIs):Bashcd blockchain
npm install
npx hardhat compile
Si deseas probar el flujo de despliegue completo en la red de pruebas de memoria efímera de Hardhat, ejecuta:Bashnpx hardhat run scripts/deploy-soc.ts
Paso 2: Construcción de la Imagen Docker del ContratoPara empaquetar la capa blockchain y compilar de manera automatizada el código dentro de un entorno aislado de Docker:Bashdocker build -t registro-incidentes-soc-image ./blockchain
Puedes validar la imagen levantando el contenedor con el script de despliegue automatizado:Bashdocker run --rm registro-incidentes-soc-image npx hardhat run scripts/deploy-soc.ts
Paso 3: Levantar el Nodo Ledger LocalRegresa a la raíz de la práctica e inicia el contenedor encargado de simular el entorno de la red blockchain:Bashdocker compose up -d blockchain-node
Inspecciona que el nodo de infraestructura se encuentre corriendo correctamente:Bashdocker compose ps
docker compose logs blockchain-node
Paso 4: Despliegue del Contrato en el Nodo BlockchainUtiliza el contenedor de utilidades (contract-tools) para desplegar de forma persistente tu contrato inteligente de ciberseguridad sobre la red en ejecución:Bashdocker compose run --rm contract-tools npx hardhat run scripts/deploy-soc.ts --network ganache
Resultado esperado en terminal:PlaintextDesplegando contrato de infraestructura SOC (RegistroIncidentesSOC)...
Contrato de auditoría inmutable desplegado correctamente.
Dirección del contrato SOC: 0x742d35Cc6634C0532925a3b844Bc454e4438f44e
[!IMPORTANT]Copia la dirección hexadecimal obtenida (0x...) y actualiza la variable CONTRACT_ADDRESS dentro de tu archivo .env global antes de proceder con el siguiente paso.Paso 5: Despliegue Completo de los ServiciosUna vez configurado el archivo .env con la dirección real del contrato, levanta toda la arquitectura (PostgreSQL y la API de FastAPI):Bashdocker compose up -d --build
Comprueba que todos los microservicios se encuentren en estado de ejecución estable:Bashdocker compose ps
📊 Matriz de Control de Datos y SLAsCiclo de Vida del IncidenteEl Smart Contract restringe las transacciones para que sigan secuencialmente el flujo operativo detallado en la investigación académica:Reportado ➡️ Triageado ➡️ EnProgreso ➡️ Escalado ➡️ Resuelto ➡️ Cerrado.Control de Tiempos Límites (SLA) por GravedadGravedad (Enum ID)Nivel de SeveridadTiempo Máximo de Respuesta (SLA)0BAJO24 Horas1MEDIO4 Horas2ALTO1 Hora3CRITICO15 Minutos🧪 Pruebas e Interacción con la API1. Interfaz Interactiva de SwaggerUna vez que todos los contenedores estén activos, accede a la documentación interactiva provista de forma automática por FastAPI ingresando a:🔗 http://localhost:8000/docsPuedes ejecutar las pruebas funcionales directamente en el navegador siguiendo este orden lógico:GET /health (Estado general del backend).GET /blockchain/contract (Validación de dirección y ABIs expuestas).POST /incidentes (Creación de un registro cruzado).GET /incidentes/{id_ticket}/verificar (Auditoría criptográfica en tiempo real).2. Automatización desde Consola (PowerShell)Para registrar un incidente crítico de ciberseguridad (ej. ataque de Ransomware en servidores AD) mediante comandos de terminal:PowerShell$body = @{
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
Para validar de forma cruzada la inmutabilidad y la cadena de custodia del artefacto forense frente al ledger:PowerShellInvoke-RestMethod -Uri "http://localhost:8000/incidentes/INC-SOC-2026-8942/verificar"
Respuesta Exitosa de Auditoría:JSON{
  "existe_en_blockchain": true,
  "evidencia_mantiene_integridad": true
}
🐳 Distribución e Integración Continua (Docker Hub)Para empaquetar de forma estable tus imágenes corporativas del SOC y distribuirlas a entornos de orquestación avanzados (Staging, Producción o clústeres de Kubernetes):Autentícate desde la línea de comandos:Bashdocker login
Construye y etiqueta tus imágenes (Reemplaza TU_USUARIO_DOCKERHUB por tu identificador real de la plataforma):Bash# Capa de automatización de Smart Contracts
docker build -t TU_USUARIO_DOCKERHUB/soc-blockchain-contract:1.0 ./blockchain
docker tag TU_USUARIO_DOCKERHUB/soc-blockchain-contract:1.0 TU_USUARIO_DOCKERHUB/soc-blockchain-contract:latest

# Backend API de Gestión Operativa
docker build -t TU_USUARIO_DOCKERHUB/soc-control-api:1.0 ./api-soc
docker tag TU_USUARIO_DOCKERHUB/soc-control-api:1.0 TU_USUARIO_DOCKERHUB/soc-control-api:latest
Publica las imágenes en los repositorios de Docker Hub:Bashdocker push TU_USUARIO_DOCKERHUB/soc-blockchain-contract:latest
docker push TU_USUARIO_DOCKERHUB/soc-control-api:latest
🛠️ Comandos Útiles de AdministraciónApagar la infraestructura manteniendo persistencia de datos:Bashdocker compose down
Destruir los contenedores borrando todos los datos (Volúmenes limpios):Bashdocker compose down -v
Monitorear logs específicos de la API del SOC:Bashdocker compose logs api-soc
💻 Proyecto Académico Final desarrollado en el marco de la Especialidad en Sistemas de Información con mención en Blockchain y Arquitectura en la Nube - UTPL 2026.

### Características clave del formato para GitHub:
1. **Badges/Emojis:** Se agregaron iconos estratégicos (`🛡️`, `🚀`, `🔍`, etc.) para dar una apariencia profesional.
2. **Estructura de Directorios Limpia:** El bloque de código de la estructura usa caracteres de caja (`├──`, `│`) que GitHub renderiza de forma óptima.
3. **Alertas de GitHub:** Se utilizó el componente nativo de alertas de GitHub `> [!IMPORTANT]` para destacar el paso crítico de la dirección del contrato inteligente.
4. **Tablas Markdown:** La sección de SLAs se formateó como una tabla Markdown nativa para facilit
