// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract RegistroIncidentesSOC {
    
    // Definición de gravedades del incidente según los SLAs del documento
    enum Gravedad { BAJO, MEDIO, ALTO, CRITICO }
    
    // Ciclo de vida completo del incidente especificado en el informe
    enum EstadoIncidente { Reportado, Triageado, EnProgreso, Escalado, Resuelto, Cerrado }

    struct Incidente {
        bytes32 idIncidenteHash;       // Identificador único inmutable del incidente (Hash SHA-256)
        bytes32 hashEvidenciaOffChain; // Hash de los artefactos forenses guardados off-chain (Cumplimiento GDPR/LOPDP)
        address operadorSOC;           // Dirección del nodo/operador que registra el evento (SOCOrg)
        uint256 fechaRegistro;         // Timestamp del bloque de la transacción
        Gravedad gravedad;             // Severidad para la medición de SLAs (15m, 1h, 4h, 24h)
        EstadoIncidente estado;        // Estado actual dentro del flujo de atención
        bool existe;                   // Flag de control de existencia
    }

    // Mapeo indexado por el Hash del ID del incidente
    mapping(bytes32 => Incidente) private incidentes;

    // Evento para auditoría inalterable en tiempo real (CISOOrg / AuditOrg)
    event IncidenteRegistrado(
        bytes32 indexed idIncidenteHash,
        bytes32 indexed hashEvidenciaOffChain,
        address indexed operadorSOC,
        Gravedad gravedad
    );

    // Evento para rastrear el cambio de estado y auditoría de SLAs
    event EstadoIncidenteActualizado(
        bytes32 indexed idIncidenteHash,
        EstadoIncidente nuevoEstado,
        uint256 fechaActualizacion
    );

    /**
     * @notice Registra un nuevo incidente de ciberseguridad en la capa Blockchain.
     * @param _idIncidenteHash Hash identificador del ticket del SIEM/SOAR.
     * @param _hashEvidenciaOffChain Hash SHA-256 de los logs o volcados forenses almacenados off-chain.
     * @param _gravedad Severidad del incidente para el cálculo de penalizaciones por SLA.
     */
    function registrarIncidente(
        bytes32 _idIncidenteHash,
        bytes32 _hashEvidenciaOffChain,
        Gravedad _gravedad
    ) public {
        require(!incidentes[_idIncidenteHash].existe, "El incidente ya ha sido registrado previamente");

        incidentes[_idIncidenteHash] = Incidente({
            idIncidenteHash: _idIncidenteHash,
            hashEvidenciaOffChain: _hashEvidenciaOffChain,
            operadorSOC: msg.sender, // Asigna la identidad de la organización emisora (ej. SOCOrg)
            fechaRegistro: block.timestamp,
            gravedad: _gravedad,
            estado: EstadoIncidente.Reportado,
            existe: true
        });

        emit IncidenteRegistrado(_idIncidenteHash, _hashEvidenciaOffChain, msg.sender, _gravedad);
    }

    /**
     * @notice Actualiza el estado del ciclo de vida del incidente para control del SOC.
     */
    function actualizarEstado(bytes32 _idIncidenteHash, EstadoIncidente _nuevoEstado) public {
        require(incidentes[_idIncidenteHash].existe, "El incidente no existe");
        
        incidentes[_idIncidenteHash].estado = _nuevoEstado;
        
        emit EstadoIncidenteActualizado(_idIncidenteHash, _nuevoEstado, block.timestamp);
    }

    /**
     * @notice Verifica la integridad de un artefacto forense contrastándolo con el hash inmutable on-chain.
     */
    function verificarIntegridadEvidencia(
        bytes32 _idIncidenteHash, 
        bytes32 _hashEvidenciaAProbar
    ) public view returns (bool existe, bool integridadValida) {
        Incidente memory incidente = incidentes[_idIncidenteHash];

        existe = incidente.existe;
        integridadValida = (incidente.hashEvidenciaOffChain == _hashEvidenciaAProbar);
    }

    /**
     * @notice Recupera la ficha técnica completa del incidente para auditorías (AuditOrg / CISOOrg).
     */
    function obtenerIncidente(bytes32 _idIncidenteHash) 
        public 
        view 
        returns (
            bytes32, 
            bytes32, 
            address, 
            uint256, 
            Gravedad, 
            EstadoIncidente, 
            bool
        ) 
    {
        Incidente memory incidente = incidentes[_idIncidenteHash];
        require(incidente.existe, "Incidente no encontrado");
        
        return (
            incidente.idIncidenteHash,
            incidente.hashEvidenciaOffChain,
            incidente.operadorSOC,
            incidente.fechaRegistro,
            incidente.gravedad,
            incidente.estado,
            incidente.existe
        );
    }
}