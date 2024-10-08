local TestingEnabled = false

RegisterNetEvent('Toxicity:Breathalyze')
AddEventHandler('Toxicity:Breathalyze', function(TargetName, TargetId, Level)
    local PlayerInformation = string.format('UserId: %s\nName: %s', TargetId, TargetName)
    local LevelInformation = string.format('Alcohol: %.2f\n', Level)
    
    ShowNotification(PlayerInformation)
    ShowNotification(LevelInformation)
end)

RegisterNetEvent('Toxicity:FieldTest')
AddEventHandler('Toxicity:FieldTest', function(Data)
    local TargetName = Data.PlayerInformation.TargetName
    local TargetId = Data.PlayerInformation.TargetId

    if Data.Positives ~= 'No positives found' then
        local PlayerInformation = string.format('UserId: %s\nName: %s', TargetId, TargetName)
        local PositiveInformation = string.format('Positive for\n%s', Data.Positives)
        
        ShowNotification(PlayerInformation)
        ShowNotification(PositiveInformation)
    else
        local PlayerInformation = string.format('UserId: %s\nName: %s', TargetId, TargetName)
        local PositiveInformation = 'No positives found'

        ShowNotification(PlayerInformation)
        ShowNotification(PositiveInformation)
    end
end)

RegisterNetEvent('Toxicity:Communicator')
AddEventHandler('Toxicity:Communicator', function(Data)
    PlaySequence(Sequences[Data.Intoxicant])
end)

RegisterNetEvent('Toxicity:Clear')
AddEventHandler('Toxicity:Clear', function()
    ClearSequences()
end)