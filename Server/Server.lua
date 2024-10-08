AddEventHandler('playerConnecting', function()
    local PlayerName = GetPlayerName(source)
    OnPlayerJoin(PlayerName)
end)

for _, PlayerId in pairs(GetPlayers()) do
    local PlayerName = GetPlayerName(PlayerId)
    OnPlayerJoin(PlayerName)
end

AddEventHandler('playerDropped', function()
    local PlayerName = GetPlayerName(source)
    OnPlayerLeave(PlayerName)
end)

RegisterNetEvent('Toxicity:Breathalyze')
AddEventHandler('Toxicity:Breathalyze', function()
    local ClosestPlayer, ClosestDistance = GetClosestPlayer(source)

    if ClosestPlayer and ClosestDistance < Shared.Range then
        local TargetName = GetPlayerName(source)
        local TargetAttributes = GetPlayerAttributes(TargetName)

        TriggerClientEvent('Toxicity:Breathalyze', source, TargetName, source, TargetAttributes.Alcohol.BAC)
    end
end)

RegisterNetEvent('Toxicity:FieldTest')
AddEventHandler('Toxicity:FieldTest', function()
    local ClosestPlayer, ClosestDistance = GetClosestPlayer(source)

    if ClosestPlayer and ClosestDistance < Shared.Range then
        local TargetName = GetPlayerName(source)
        local TargetAttributes = GetPlayerAttributes(TargetName)

        local Positives = {}

        for Index, Attributes in pairs(TargetAttributes) do
            if Index ~= 'Alcohol' then
                for Attribute, Value in pairs(Attributes) do
                    if Value then
                        table.insert(Positives, Attribute)
                    end
                end
            end
        end

        if #Positives > 0 then
            local PositiveString = table.concat(Positives, ', ')

            TriggerClientEvent('Toxicity:FieldTest', source, {
                PlayerInformation = {
                    TargetName = GetPlayerName(source),
                    TargetId = source
                },
                Positives = PositiveString
            })
        else
            TriggerClientEvent('Toxicity:FieldTest', source, {
                PlayerInformation = {
                    TargetName = GetPlayerName(source),
                    TargetId = source
                },
                Positives = 'No positives found'
            })
        end
    end
end)

--[[
    {
        Type = 'Alcohol',
        Value = 0.06
    }

    {
        Type = 'Smoking',
        Intoxicant = 'Tobacco',
        Value = true
    }
]]

RegisterNetEvent('Toxicity:Change')
AddEventHandler('Toxicity:Change', function(Data)
    local PlayerName = GetPlayerName(source)
    local PlayerAttributes = GetPlayerAttributes(PlayerName)

    if not PlayerAttributes or not PlayerAttributes[Data.Type] then
        return
    end

    if Data.Type == 'Smoking' or Data.Type == 'Drugs' then
        if type(Data.Value) ~= 'boolean' then
            return
        end

        PlayerAttributes[Data.Type][Data.Intoxicant] = Data.Value
        TriggerClientEvent('Toxicity:Communicator', source, {Type = Data.Type, Intoxicant = Data.Intoxicant, Data.Value})
    elseif Data.Type == 'Alcohol' then
        if type(Data.Value) ~= 'number' then
            return
        end

        if PlayerAttributes[Data.Type].BAC ~= 0.0 then
            TriggerClientEvent('Toxicity:Clear', source)
            PlayerAttributes[Data.Type].BAC = Data.Value
            TriggerClientEvent('Toxicity:Communicator', source, {Type = Data.Type, Intoxicant = Data.Intoxicant})
        else
            PlayerAttributes[Data.Type].BAC = Data.Value
            TriggerClientEvent('Toxicity:Communicator', source, {Type = Data.Type, Intoxicant = Data.Intoxicant})
        end
    end
end)

RegisterNetEvent('Toxicity:Clear')
AddEventHandler('Toxicity:Clear', function()
    local PlayerName = GetPlayerName(source)

    ResetTable(PlayerAttributesData[PlayerName], PlayerAttributesData.Preset)
    TriggerClientEvent('Toxicity:Clear', source)
end)