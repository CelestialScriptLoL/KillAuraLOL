--// SERVICIOS
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// BASE DE DATOS DE HABILIDADES
local abilityData = {
    -- Starter Abilities
    ["Rock Throw"] = {ID = 34, RemoteNames = {"rock-hit"}},
    ["Magic Missile"] = {ID = 1, RemoteNames = {"strike", "nightlight", "twilight", "capraBeam", "manaDetonation", "star", "laser", "ghost-explode", "ghost-fire", "mitosis-missile"}},
    -- (continúa con más habilidades...)
}

--// LISTA DE MOBS ACTUALIZADA
local listaDeMobs = {
    "Aevrul", "Baby Scarab", "Baby Shroom", "Baby Slime", "Baby Yeti", "Baby Yeti Tribute",
    "Bamboo Mage", "Bandit", "Bandit Skirmisher", "Battering Shroom", "Batty", "Bear",
    -- (continúa con más mobs...)
}

--// FUNCIONES DE UTILIDAD PARA GUID E ID
local function isValidGUID(guid)
    return typeof(guid) == "string" and #guid == 36 and string.match(guid, "^%x+%-%x+%-%x+%-%x+%-%x+$") ~= nil
end

local function isValidExecutionData(data)
    return typeof(data) == "table" and data["id"] ~= 0 and isValidGUID(data["ability-guid"])
end

local function getAbilityGUIDFromData(dataTable)
    for _, data in pairs(dataTable) do
        if isValidExecutionData(data) then
            return data["ability-guid"], data["id"]
        end
    end
    return nil, nil
end

local function getAbilityGUIDAndID()
    local player = Players.LocalPlayer
    local charModel = workspace.placeFolders.entityManifestCollection:FindFirstChild(player.Name)
    if not charModel then return nil end

    local Hitbox = charModel:FindFirstChild("hitbox")
    if not Hitbox then return nil end

    local ExecutionDataValue = Hitbox:FindFirstChild("activeAbilityExecutionData")
    if not ExecutionDataValue or not ExecutionDataValue.Value then return nil end

    local success, parsed = pcall(function()
        return HttpService:JSONDecode(ExecutionDataValue.Value)
    end)
    if not success or typeof(parsed) ~= "table" then
        return nil
    end

    if isValidExecutionData(parsed) then
        return parsed["ability-guid"], parsed["id"]
    end

    return getAbilityGUIDFromData(parsed)
end

local function getRemoteNamesFromID(id)
    for _, data in pairs(abilityData) do
        if data.ID == id then
            return data.RemoteNames
        end
    end
end

--// FUNCION PARA DETECTAR MOBS PRESENTES EN EL MAPA
local function obtenerMobsActuales()
    local mobs = {}
    for _, mobName in ipairs(listaDeMobs) do
        local mobPart = workspace.placeFolders.entityManifestCollection:FindFirstChild(mobName)
        if mobPart and mobPart:IsA("BasePart") then
            table.insert(mobs, mobPart)
        end
    end
    return mobs
end

--// DATOS CACHEADOS
local cachedGUID = nil
local cachedID = nil
local cachedMobs = {}

--// ACTUALIZAR GUID E ID CADA 0.1s
task.spawn(function()
    while true do
        local nuevoGUID, nuevoID = getAbilityGUIDAndID()
        if nuevoGUID and nuevoGUID ~= cachedGUID then
            cachedGUID = nuevoGUID
            cachedID = nuevoID
        end
        task.wait(0.1)
    end
end)

--// ACTUALIZAR MOBS CADA 0.1s
task.spawn(function()
    while true do
        cachedMobs = obtenerMobsActuales()
        task.wait(0.1)
    end
end)

--// ENVIAR RemoteEvent CADA 0.1s (procesa mobs en lotes de 3, 5 ataques por mob)
task.spawn(function()
    while true do
        local success, err = pcall(function()
            if cachedGUID and cachedID and #cachedMobs > 0 then
                local remoteEvent = ReplicatedStorage:WaitForChild("network"):WaitForChild("RemoteEvent"):WaitForChild("playerRequest_damageEntity_batch")
                local remoteNames = getRemoteNamesFromID(cachedID)

                for i = 1, #cachedMobs, 5 do
                    local batch = {}

                    for j = i, math.min(i + 2, #cachedMobs) do
                        local mobPart = cachedMobs[j]
                        if mobPart then
                            for _, remoteName in ipairs(remoteNames) do
                                for _ = 1, 5 do
                                    table.insert(batch, {
                                        mobPart,
                                        mobPart.Position,
                                        "ability",
                                        cachedID,
                                        remoteName,
                                        cachedGUID
                                    })
                                end
                            end
                        end
                    end

                    if #batch > 0 then
                        remoteEvent:FireServer(batch)
                        print("Lote de ataques enviado. Remote(s):", table.concat(remoteNames, ", "), "| ID:", cachedID)
                        task.wait(0.5)
                    end
                end
            end
        end)

        if not success then
            warn("Error al enviar RemoteEvent:", err)
        end

        task.wait(0.5)
    end
end)
