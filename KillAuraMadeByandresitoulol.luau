-- ⚔️ Configuración inicial
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- 🧠 Variables de habilidad
local habilidadData = workspace:WaitForChild("abilityData"):WaitForChild(LocalPlayer.Name)
local activeData = habilidadData:WaitForChild("activeAbilityExecutionData")
local abilityGUIDValue = activeData:WaitForChild("abilityGUID")

local cachedGUID = nil
local cachedID = nil

-- 📦 IDs y RemoteNames válidos
local habilidades = {
    -- Starter Abilities
    ["Rock Throw"] = {ID = 34, RemoteNames = {"rock-hit"}},
    ["Magic Missile"] = {ID = 1, RemoteNames = {"strike"}},

    -- Mage  
    ["Mana Bomb"] = {ID = 4, RemoteNames = {"explosion1"}},  
    ["Thundercall"] = {ID = 77, RemoteNames = {"strike"}},  
    ["Zap"] = {ID = 32, RemoteNames = {"bolt"}},  

    -- Warrior  
    ["Spin Slash"] = {ID = 26, RemoteNames = {"uppercut"}}, -- actualizado  
    ["Blasting Slash"] = {ID = 80, RemoteNames = {"aftershock-1", "aftershock-2", "aftershock-3", "tombSpike"}},  
    ["Ground Slam"] = {ID = 5, RemoteNames = {"spike", "warlord", "warlord-outer", "divineSlam", "divineSlam-sword", "divineSlam-outer", "shockwave", "shockwave-outer", "slash", "aftershock", "agile-strike", "bee-attack", "ghost-fire", "ghost-explode", "ghost-ring"}},  

    -- Hunter  
    ["Execute"] = {ID = 6, RemoteNames = {"strike", "echo", "strike_aoe", "echo_aoe", "shadowblast", "bleed"}},  
    ["Barrage"] = {ID = 15, RemoteNames = {"arrow-1", "arrow-2", "arrow-3", "holo-direct", "holo-reflect", "jade-dot", "ghost-fire", "boom"}},  
    ["Shunpo"] = {ID = 13, RemoteNames = {"dash-through", "icicle", "icicle-bomb", "ghost-explode", "ghost-fire", "ghost-ring", "mumpo-hit", "mumpo-slice"}},  

    -- Warlock (Mage Subclass)  
    ["Pillage Vitality"] = {ID = 40, RemoteNames = {"bolt", "fireworks"}},  
    ["Dark Pulse"] = {ID = 59, RemoteNames = {"pulse"}},  
    ["Desecrate"] = {ID = 64, RemoteNames = {"pulse"}},  
    ["Blood Plague"] = {ID = 78, RemoteNames = {"dot"}},  
    ["Chain Binding"] = {ID = 69, RemoteNames = {"bolt"}},  

    -- Sorcerer  
    ["Frost Storm"] = {ID = 103, RemoteNames = {"blizzard", "blizzard-burst", "iceExplosion"}},  
    ["Earth Call"] = {ID = 104, RemoteNames = {"boulder", "seismic"}},  
    ["Meteor Storm"] = {ID = 102, RemoteNames = {"explosion", "burn"}},  
    ["Unstable Charge"] = {ID = 100, RemoteNames = {"bolt", "electrified"}},  
    ["Howling Gale"] = {ID = 99, RemoteNames = {"tornado"}},  

    -- Cleric  
    ["Spear of Light"] = {ID = 67, RemoteNames = {"spear", "blast"}},  
    ["Flare"] = {ID = 50, RemoteNames = {"flare"}},  

    -- Songweaver  
    ["Vibrato"] = {ID = 544, RemoteNames = {"note", "note_encore"}},  
    ["Aria Wave"] = {ID = 541, RemoteNames = {"wave"}},  

    -- Paladin  
    ["Rebuke"] = {ID = 56, RemoteNames = {"blast", "blast_dullThud", "jadePulse"}},  
    ["Consecrate"] = {ID = 70, RemoteNames = {"blast", "pulse", "ghost-fire", "ghost-explode", "ghost-link"}},  
    ["Smite"] = {ID = 48, RemoteNames = {"smite", "thunder"}},  

    -- Berserker  
    ["Ferocious Assault"] = {ID = 60, RemoteNames = {"strike"}},  
    ["Blade Spin"] = {ID = 55, RemoteNames = {"spin"}},  
    ["Headlong Dive"] = {ID = 68, RemoteNames = {"impact", "firworks"}},  
    ["Blood Cleave"] = {ID = 131, RemoteNames = {"cleave", "cleave-projectile", "bleed"}},  

    -- Knight  
    ["Shield Bash"] = {ID = 61, RemoteNames = {"chargefire", "strike", "tsunami", "jade", "jadeExplosion"}},  
    ["Cleave"] = {ID = 128, RemoteNames = {"aftershock1", "aftershock2", "aftershock3", "aftershock4", "aftershock5", "wave"}},  
    ["Chain Pull"] = {ID = 127, RemoteNames = {"chain", "ghostflame_tick"}},  
    ["Defensive Stance"] = {ID = 129, RemoteNames = {"explosion", "holo"}},  

    -- Bard  
    ["Crescendo"] = {ID = 92, RemoteNames = {"note", "eighth-note", "burst"}},  
    ["Lullaby"] = {ID = 93, RemoteNames = {"lullaby"}},  

    -- Assassin  
    ["Shadow Flurry"] = {ID = 43, RemoteNames = {"strike", "fireworks"}},  
    ["Ethereal Strike"] = {ID = 79, RemoteNames = {"throw", "teleport"}},  
    ["Shadow Volley"] = {ID = 164, RemoteNames = {"impact"}},  

    -- Trickster  
    ["Prism Trap"] = {ID = 42, RemoteNames = {"trap"}},  
    ["Switch Strike"] = {ID = 41, RemoteNames = {"bolt"}},  
    ["Bubble Burst"] = {ID = 65, RemoteNames = {"bolt1", "bolt2", "bolt3"}},  
    ["Disengage"] = {ID = 51, RemoteNames = {"shot"}},  

    -- Ranger  
    ["Hail of Arrows"] = {ID = 36, RemoteNames = {"quarterSecondDamage"}},  
    ["Ricochet"] = {ID = 31, RemoteNames = {"initial", "bounce"}},
}

-- 🧠 Lista de mobs del mapa
local listaDeMobs = {
    "Aevrul", "Baby Scarab", "Baby Shroom", "Baby Slime", "Baby Yeti", "Baby Yeti Tribute",
    "Bamboo Mage", "Bandit", "Bandit Skirmisher", "Battering Shroom", "Batty", "Bear",
    "Big Slime", "Birthday Mage", "Boar", "Book", "Bushi", "Chad", "Chicken", "Crabby",
    "Crow", "Cultist", "Dark Cleric", "Deathsting", "Dragon Boss", "Dragon Monk", "Dummy",
    "Dustwurm", "Eldering Shroom", "Elder Shroom", "Enchanted Slime", "Enchiridion",
    "Ent Sapling", "Ethera", "Ethereal Monarch", "Frightcrow", "Fish", "First Mate",
    "Fly Trap", "Gauntlet Gate", "Gecko", "Goblin", "Gorgog Guardian", "Guardian",
    "Guardian Dummy", "Hag", "Hermit Crabby", "Hitbox", "Hog", "Horseshoe Crab", "Humanoid",
    "Jellyfish", "Kobra", "Lil Shroomie Cage", "Lobster", "Lost Spirit", "Mama Hermit Crabby",
    "Master Miyamoto", "Mimic Jester", "Miner Prisoner", "Mo Ko Tu Aa", "Mogloko", "Moglo",
    "Monster", "Mosquito Parasite", "Mummy", "Orc", "Parasite", "Parasite Host",
    "Pirate", "Pirate Captain", "Pirate Summon", "Pit Ratty", "Possum the Devourer",
    "Prisoner", "Ram", "Ratty", "Reanimated Slime", "Reaper", "Redwood Bandit",
    "Redwood Bandit Leader", "Rock Slime", "Rootbeard", "Rubee", "Runic Titan",
    "Samurai", "Scarab", "Scarecrow", "Sensei", "Shade", "Shaman", "Shinobi", "Shroom",
    "Skeleton", "Skull Boss", "Slime", "Snel", "Soulcage", "Spider", "Spider Queen",
    "Spiderling", "Stingtail", "Sunken Savage", "Terror of the Deep", "The Yeti",
    "Toni", "Tortoise", "Treemuk", "Tribute Gate", "Trickster Spirit", "Tumbleweed",
    "Undead", "Wisp", "Ronin"
}

-- 🧠 Buscar el ID que corresponde al GUID
local function buscarIDDesdeGUID(guid)
    for id, remoteNames in pairs(habilidades) do
        for _, remoteName in ipairs(remoteNames) do
            if guid:lower():find(remoteName:lower()) then
                return id
            end
        end
    end
    return nil
end

-- 🔍 Obtener todos los mobs del mapa
local function obtenerMobs()
    local mobs = {}
    for _, mobName in ipairs(listaDeMobs) do
        local mobPart = workspace.placeFolders.entityManifestCollection:FindFirstChild(mobName)
        if mobPart and mobPart:IsA("BasePart") then
            table.insert(mobs, mobPart)
        end
    end
    return mobs
end

-- 🔄 Loop principal de ataque
task.spawn(function()
    while true do
        local currentGUID = abilityGUIDValue.Value
        if currentGUID ~= "" and currentGUID ~= cachedGUID then
            cachedGUID = currentGUID
            cachedID = buscarIDDesdeGUID(currentGUID)
        end

        if cachedGUID and cachedID then
            local remoteNames = habilidades[cachedID]
            local remoteEvent = ReplicatedStorage:WaitForChild("network"):WaitForChild("RemoteEvent"):WaitForChild("playerRequest_damageEntity_batch")
            local mobs = obtenerMobs()

            if mobs and #mobs > 0 then
                -- Procesar los mobs en lotes de 3
                for i = 1, #mobs, 3 do
                    local batch = {}
                    local ataqueCount = 0

                    -- Crear ataques para el lote de 3 mobs
                    for j = i, math.min(i + 2, #mobs) do
                        local mob = mobs[j]
                        if mob then
                            for _, remoteName in ipairs(remoteNames) do
                                for k = 1, 5 do -- 5 ataques por mob
                                    table.insert(batch, {
                                        mob,
                                        mob.Position,
                                        "ability",
                                        cachedID,
                                        remoteName,
                                        cachedGUID
                                    })
                                end
                            end
                        end
                    end

                    -- Enviar los ataques en batch
                    if #batch > 0 then
                        remoteEvent:FireServer(batch)
                    end
                end
            end
        end

        task.wait(0.2) -- Intervalo de ataque
    end
end)
