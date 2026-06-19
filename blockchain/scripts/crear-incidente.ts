import { network } from "hardhat";
import { keccak256, stringToHex } from "viem";

const { viem } = await network.create();

console.log("Desplegando contrato de infraestructura SOC (RegistroIncidentesSOC)...");

// 1. Desplegar el contrato adaptado al documento
const registroIncidentesSOC = await viem.deployContract("RegistroIncidentesSOC");

console.log("Contrato de auditoría inmutable desplegado correctamente.");
console.log("Dirección del contrato SOC:", registroIncidentesSOC.address);

// 2. Adaptación de variables al contexto de Ciberseguridad (SOC / NOC)
// ID único del ticket generado por el SIEM/SOAR
const idIncidenteTicket = "INC-SOC-2026-8942"; 
// Datos del artefacto forense (ej. log corrupto, volcado de memoria) guardado Off-Chain (GDPR)
const evidenciaOffChain = "Log de auditoría - Servidor Active Directory comprometido por Ransomware. Hash SHA-256 local.";

// Mapear los enums tal como se definieron en Solidity
// enum Gravedad { BAJO, MEDIO, ALTO, CRITICO } -> CRITICO es la posición 3
const gravedadCritico = 3; 

// Generación de Hashes criptográficos (SHA-256/Keccak256) para inmutabilidad on-chain
const idIncidenteHash = keccak256(stringToHex(idIncidenteTicket));
const hashEvidenciaOffChain = keccak256(stringToHex(evidenciaOffChain));

console.log("\n--- Datos del Incidente de Seguridad ---");
console.log("Ticket del Incidente:", idIncidenteTicket);
console.log("Hash del Identificador (idIncidenteHash):", idIncidenteHash);
console.log("Hash de Evidencia Forense Off-Chain (hashEvidenciaOffChain):", hashEvidenciaOffChain);

console.log("\nRegistrando incidente crítico en la Capa Blockchain...");

// 3. Llamada a la función del contrato adaptado con los nuevos parámetros
const tx = await registroIncidentesSOC.write.registrarIncidente([
  idIncidenteHash,
  hashEvidenciaOffChain,
  gravedadCritico,
]);

console.log("Transacción enviada por el Operador SOC (SOCOrg):", tx);

// 4. Verificación de Integridad Forense
const resultado = await registroIncidentesSOC.read.verificarIntegridadEvidencia([
  idIncidenteHash,
  hashEvidenciaOffChain,
]);

console.log("\n--- Resultado de Verificación de Integridad ---");
console.log("¿El Incidente existe en el ledger?:", resultado[0]);
console.log("¿La evidencia forense mantiene su integridad (coincide el hash)?:", resultado[1]);

// 5. Lectura de la ficha técnica completa guardada en la Blockchain
const incidente = await registroIncidentesSOC.read.obtenerIncidente([idIncidenteHash]);

// Mapeo de retorno de estados de los enums para la visualización en consola
const nombreGravedad = ["BAJO", "MEDIO", "ALTO", "CRITICO"];
const nombreEstado = ["Reportado", "Triageado", "EnProgreso", "Escalado", "Resuelto", "Cerrado"];

console.log("\n--- Ficha Técnica Inmutable recuperada de la Blockchain ---");
console.log("ID Incidente Hash:     ", incidente[0]);
console.log("Hash Evidencia SOC:    ", incidente[1]);
console.log("Dirección Operador SOC:", incidente[2]);
console.log("Fecha de Bloque (Unix):", incidente[3].toString());
console.log("Nivel de Gravedad (SLA):", nombreGravedad[incidente[4]]);
console.log("Estado del Ciclo de Vida:", nombreEstado[incidente[5]]);
console.log("Flag de Control (Existe):", incidente[6]);
