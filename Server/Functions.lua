function OnPlayerJoin(PlayerName)
    if not PlayerAttributesData[PlayerName] then
        local PlayerAttribute = CopyTable(PlayerAttributesData.Preset)
        PlayerAttributesData[PlayerName] = PlayerAttribute
    end
end

function OnPlayerLeave(PlayerName)
    PlayerAttributesData[PlayerName] = nil
end

function GetClosestPlayer(SourcePlayerId)
    local ClosestPlayer = nil
    local ClosestDistance = math.huge
    local SourcePlayerPed = GetPlayerPed(tonumber(SourcePlayerId))
    local SourceCoords = GetEntityCoords(SourcePlayerPed)

    for _, PlayerId in pairs(GetPlayers()) do
        local PlayerIdNum = tonumber(PlayerId)
        
        if PlayerIdNum and PlayerIdNum ~= tonumber(SourcePlayerId) then
            local TargetPlayerPed = GetPlayerPed(PlayerIdNum)
            local TargetCoords = GetEntityCoords(TargetPlayerPed)
            local Distance = #(SourceCoords - TargetCoords)

            if Distance <= ClosestDistance then
                ClosestDistance = Distance
                ClosestPlayer = PlayerIdNum
            end
        end
    end

    return ClosestPlayer, ClosestDistance
end

function GetPlayerAttributes(PlayerName)
    return PlayerAttributesData[PlayerName]
end

function CopyTable(Table)
    local Copy = {}

    for Index, Value in pairs(Table) do
        if type(Value) == 'table' then
            Copy[Index] = CopyTable(Value)
        else
            Copy[Index] = Value
        end
    end

    return Copy
end

function ResetTable(CurrentTable, PresetTable)
    for Index, Value in pairs(PresetTable) do
        if type(Value) == 'table' then
            if type(CurrentTable[Index]) ~= 'table' then
                CurrentTable[Index] = {}
            end

            ResetTable(CurrentTable[Index], Value)
        else
            CurrentTable[Index] = Value
        end
    end
end