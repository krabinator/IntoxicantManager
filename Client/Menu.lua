_MenuPool = NativeUI.CreatePool()
MainMenu = NativeUI.CreateMenu('Intoxicant Manager', 'Main', 1400, 40)

_MenuPool:Add(MainMenu)

local IntoxicantSubMenu = _MenuPool:AddSubMenu(MainMenu, 'Intoxicants', 'Intoxicant Related Menu', true)

--// Alcohol stuff

local AlcoholSubMenu = _MenuPool:AddSubMenu(IntoxicantSubMenu, 'Alcohol', 'Alcohol Related Menu', true)
local AlcoholItems = {
    NativeUI.CreateItem('Buzzed', 'Makes your character buzzed (0.04)'),
    NativeUI.CreateItem('Moderate', 'Makes your character moderately drunk (0.09)'),
    NativeUI.CreateItem('Drunk', 'Makes your character drunk (0.14)'),
    -- NativeUI.CreateItem('Custom', 'Enter a Custom BAC level (0.01 - 0.25)')
}

AlcoholItems[1].Activated = function() -- Buzzed
    TriggerToxicEvent({'Toxicity:Change', {Type = 'Alcohol', Intoxicant = 'AlcoholBuzzed', Value = 0.04}})
end

AlcoholItems[2].Activated = function() -- Moderate
    TriggerToxicEvent({'Toxicity:Change', {Type = 'Alcohol', Intoxicant = 'AlcoholModerate', Value = 0.09}})
end

AlcoholItems[3].Activated = function() -- Drunk
    TriggerToxicEvent({'Toxicity:Change', {Type = 'Alcohol', Intoxicant = 'AlcoholDrunk', Value = 0.14}})
end

for _, Item in ipairs(AlcoholItems) do
    AlcoholSubMenu:AddItem(Item)
end

--// Smoking stuff

local SmokingSubMenu = _MenuPool:AddSubMenu(IntoxicantSubMenu, 'Smoking', 'Smoking Related Menu', true)
local SmokingItems = {
    NativeUI.CreateItem('Tobacco', 'Makes your character buzzed'),
    NativeUI.CreateItem('Weed', 'Makes your character high'),
    -- NativeUI.CreateItem('Crack Cocaine', 'Makes your character high'),
}

SmokingItems[1].Activated = function() -- Tobacco
    TriggerToxicEvent({'Toxicity:Change', {Type = 'Smoking', Intoxicant = 'Tobacco', Value = true}})
end

SmokingItems[2].Activated = function() -- Weed
    TriggerToxicEvent({'Toxicity:Change', {Type = 'Smoking', Intoxicant = 'Weed', Value = true}})
end

for _, Item in ipairs(SmokingItems) do
    SmokingSubMenu:AddItem(Item)
end

--// Drug stuff

local DrugSubMenu = _MenuPool:AddSubMenu(IntoxicantSubMenu, 'Drugs', 'Drug Related Menu', true)
local DrugItems = {
    NativeUI.CreateItem('Cocaine', 'Makes your character high'),
    NativeUI.CreateItem('Heroin', 'Makes your character high'),
    NativeUI.CreateItem('LSD', 'Makes your character high')
}

DrugItems[1].Activated = function() -- Cocaine
    TriggerToxicEvent({'Toxicity:Change', {Type = 'Drugs', Intoxicant = 'Cocaine', Value = true}})
end

DrugItems[2].Activated = function() -- Heroin
    TriggerToxicEvent({'Toxicity:Change', {Type = 'Drugs', Intoxicant = 'Heroin', Value = true}})
end

DrugItems[3].Activated = function() -- LSD
    TriggerToxicEvent({'Toxicity:Change', {Type = 'Drugs', Intoxicant = 'LSD', Value = true}})
end

for _, Item in ipairs(DrugItems) do
    DrugSubMenu:AddItem(Item)
end

--// Clear Toxicity

local ClearToxicity = NativeUI.CreateItem('Clear Toxicity', 'Clears system')

ClearToxicity.Activated = function() -- Clear
    TriggerServerEvent('Toxicity:Clear')
end

IntoxicantSubMenu:AddItem(ClearToxicity)

--// Testing stuff

local IntoxicantTestSubMenu = _MenuPool:AddSubMenu(MainMenu, 'Intoxicant Tests', 'Intoxicant Test Related Menu', true)
local TestItems = {
    NativeUI.CreateItem('Breathalyzer', 'Breathalyzes a character'),
    NativeUI.CreateItem('Field Test', 'Breathalyzes a character')
}

TestItems[1].Activated = function() -- Breathalyzer
    TriggerServerEvent('Toxicity:Breathalyze')
end

TestItems[2].Activated = function() -- FieldTest
    TriggerServerEvent('Toxicity:FieldTest')
end

for _, Item in ipairs(TestItems) do
    IntoxicantTestSubMenu:AddItem(Item)
end

--// NativeUI Init

RegisterCommand('toxicmenu', function()
    if _MenuPool:IsAnyMenuOpen() then
        _MenuPool:CloseAllMenus()
    else
        MainMenu:Visible(true)
    end
end, false)

RegisterKeyMapping('toxicmenu', 'Intoxicant Menu', 'keyboard', Shared.Keybind)

_MenuPool:RefreshIndex()

Citizen.CreateThread(function()
	while true do
		_MenuPool:ProcessMenus()	
		_MenuPool:ControlDisablingEnabled(false)
		_MenuPool:MouseControlsEnabled(false)

        Citizen.Wait(0)
    end
end)