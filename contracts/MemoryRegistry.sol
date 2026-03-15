// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MemoryRegistry {

    // ─────────────────────────────────────
    // ESTRUTURAS
    // ─────────────────────────────────────

    struct MemoryRecord {
        bytes32 contentHash;
        address owner;
        uint256 createdAt;
    }

    // ─────────────────────────────────────
    // ESTADO
    // ─────────────────────────────────────

    uint256 private _nextId = 1;

    mapping(uint256 => MemoryRecord)            public records;
    mapping(uint256 => mapping(address => bool)) public authorizedAgents;
    mapping(address => uint256[])               public ownerRecords; // IDs por dono

    uint256[] public allIds; // todos os IDs já criados

    // ─────────────────────────────────────
    // EVENTOS
    // ─────────────────────────────────────

    event MemoryRegistered(uint256 indexed memoryId, address indexed owner, bytes32 contentHash);
    event AccessGranted(uint256 indexed memoryId, address indexed agent);
    event AccessRevoked(uint256 indexed memoryId, address indexed agent);

    // ─────────────────────────────────────
    // ESCRITA
    // ─────────────────────────────────────

    function registerMemory(bytes32 contentHash) external returns (uint256 memoryId) {

        records[memoryId] = MemoryRecord({
            contentHash: contentHash,
            owner:       msg.sender,
            createdAt:   block.timestamp
        });

        allIds.push(memoryId);
        ownerRecords[msg.sender].push(memoryId);

        memoryId = _nextId++;

        emit MemoryRegistered(memoryId, msg.sender, contentHash);
    }

    function grantAccess(uint256 memoryId, address agent) external {
        require(msg.sender == records[memoryId].owner, "Apenas o dono pode autorizar");
        authorizedAgents[memoryId][agent] = true;
        emit AccessGranted(memoryId, agent);
    }

    function revokeAccess(uint256 memoryId, address agent) external {
        require(msg.sender == records[memoryId].owner, "Apenas o dono pode revogar");
        authorizedAgents[memoryId][agent] = false;
        emit AccessRevoked(memoryId, agent);
    }

    // ─────────────────────────────────────
    // LEITURA — view, sem gás
    // ─────────────────────────────────────

    // Ler um registro específico
    function getRecord(uint256 memoryId) external view returns (
        bytes32 contentHash,
        address owner,
        uint256 createdAt
    ) {
        MemoryRecord memory r = records[memoryId];
        return (r.contentHash, r.owner, r.createdAt);
    }

    // Ler todos os IDs existentes
    function getAllIds() external view returns (uint256[] memory) {
        return allIds;
    }

    // Ler todos os registros do dono
    function getRecordsByOwner(address owner) external view returns (uint256[] memory) {
        return ownerRecords[owner];
    }

    // Verificar acesso do agente
    function hasAccess(uint256 memoryId, address agent) external view returns (bool) {
        return authorizedAgents[memoryId][agent];
    }

    // Total de registros
    function totalRecords() external view returns (uint256) {
        return allIds.length;
    }
}