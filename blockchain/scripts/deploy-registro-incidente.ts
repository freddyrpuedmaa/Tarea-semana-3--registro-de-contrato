import { network } from "hardhat";

// Crear la instancia de viem a través del entorno de Hardhat
const { viem } = await network.create();

console.log("Desplegando contrato de infraestructura SOC (RegistroIncidentesSOC)...");

// Se cambia "RegistroTitulos" por el nombre del nuevo contrato adaptado
const registroIncidentesSOC = await viem.deployContract("RegistroIncidentesSOC");

console.log("Contrato de auditoría inmutable desplegado correctamente.");
console.log("Dirección del contrato SOC:", registroIncidentesSOC.address);