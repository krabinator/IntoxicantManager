function KeyboardInput(Title, PlaceHolder, MaxLength)
    AddTextEntry('FMMC_KEY_TIP1', Title)
    DisplayOnscreenKeyboard(1, 'FMMC_KEY_TIP1', '', PlaceHolder, '', '', '', MaxLength)

    while UpdateOnscreenKeyboard() == 0 do
        Citizen.Wait(0)
    end

    local Result = GetOnscreenKeyboardResult()
    return Result or nil
end

function ShowNotification(String)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(String)
    DrawNotification(false, false)
end

function PlayAnimation(ped, animDict, animName, blendInSpeed, blendOutSpeed, duration, flag, playbackRate, lockX, lockY, lockZ)
    RequestAnimDict(animDict)

    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end

    TaskPlayAnim(ped, animDict, animName, blendInSpeed, blendOutSpeed, duration, flag, playbackRate, lockX, lockY, lockZ)
end

function PlayWalk(animDict)
    local playerPed = PlayerPedId()

    RequestAnimSet(animDict)
    
    while not HasAnimSetLoaded(animDict) do
        Wait(100)
    end

    SetPedMovementClipset(playerPed, animDict, 0.25)
end

function GetClosestPlayer(SourcePlayerId)
    local ClosestPlayer = nil
    local ClosestDistance = math.huge
    local SourcePlayerPed = GetPlayerPed(SourcePlayerId)
    local SourceCoords = GetEntityCoords(SourcePlayerPed)

    for _, PlayerId in ipairs(GetActivePlayers()) do
        if PlayerId ~= SourcePlayerId then
            local TargetPlayerPed = GetPlayerPed(PlayerId)
            local TargetCoords = GetEntityCoords(TargetPlayerPed)
            local Distance = #(SourceCoords - TargetCoords)

            if Distance < ClosestDistance then
                ClosestDistance = Distance
                ClosestPlayer = PlayerId
            end
        end
    end

    return ClosestPlayer
end

function TriggerToxicEvent(Data)
    if not Playing then
        TriggerServerEvent(table.unpack(Data))
    end
end

--// Effects

ActiveEffects = {}
ActiveProps = {}
BreakSequence = false
Playing = false

function PlaySequence(Sequence)
    if Sequence then
        BreakSequence = false
        for _, Step in ipairs(Sequence) do
            if BreakSequence then
                break
            end

            if Step.Type == 'Playing' then
                if Playing then
                    Playing = false
                else
                    Playing = true
                end
            end

            if Step.Type == 'Prop' then
                local HashName = GetHashKey(Step.Model)

                if Step.Stop then
                    if ActiveProps[HashName] then
                        if DoesEntityExist(ActiveProps[HashName]) then
                            DeleteObject(ActiveProps[HashName])
                        end

                        ActiveProps[HashName] = nil
                    end
                else
                    if not ActiveProps[HashName] then
                        local Prop = CreateObject(HashName, 0, 0, 0, true, true, true)
                        ActiveProps[HashName] = Prop
                        AttachEntityToEntity(Prop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), Step.Bone), Step.Offset, Step.Rotation, true, true, false, true, 1, true)
                    end
                end
            elseif Step.Type == 'Animation' then
                PlayAnimation(PlayerPedId(), Step.Dict, Step.Anim, 8.0, -8.0, Step.Duration, Step.Flag, 0, false, false, false)
                Citizen.Wait(Step.Duration)
            elseif Step.Type == 'Walk' then
                if Step.Stop then
                    ResetPedMovementClipset(PlayerPedId(), 0.25)
                else
                    PlayWalk(Step.Style)
                end
            elseif Step.Type == 'ScreenEffect' then
                if Step.Stop then
                    if ActiveEffects[Sequence] then
                        for Effect in pairs(ActiveEffects[Sequence]) do
                            StopScreenEffect(Effect)
                        end
    
                        ActiveEffects[Sequence] = nil
                    end
                else
                    if not ActiveEffects[Sequence] then
                        ActiveEffects[Sequence] = {}
                    end
                    
                    ActiveEffects[Sequence][Step.Effect] = true
                    StartScreenEffect(Step.Effect, 0, true)
                    Citizen.Wait(Step.Duration)
                end
            elseif Step.Type == 'TimeCycle' then
                if Step.Stop then
                    ClearTimecycleModifier()
                else
                    SetTimecycleModifier(Step.Effect)
                end
            elseif Step.Type == 'ShakeCamera' then
                if Step.Stop then
                    ShakeGameplayCam(Step.Effect, 0)
                else
                    ShakeGameplayCam(Step.Effect, Step.Intensity or 1.0)
                end
            elseif Step.Type == 'Wait' then
                Citizen.Wait(Step.Duration)
            end
        end
    end
end

function ClearSequences()
    BreakSequence = true

    for Sequence, Effects in pairs(ActiveEffects) do
        for Effect in pairs(Effects) do
            StopScreenEffect(Effect)
        end
    end

    ActiveEffects = {}

    for _, Prop in pairs(ActiveProps) do
        if DoesEntityExist(Prop) then
            DeleteObject(Prop)
        end
    end

    ActiveProps = {}

    ShakeGameplayCam('DRUNK_SHAKE', 0)
    ClearTimecycleModifier()
    ResetPedMovementClipset(PlayerPedId(), 0.25)
    ClearPedTasks(PlayerPedId())

    Playing = false
end