--- For Support join https://discord.gg/pyKDCByzUk
local radioMenu, onRadio = false, false
local RadioChannel = 0
local RadioVolume = 50

--Function
local function LoadAnimDic(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(0)
        end
    end
end

local function SplitStr(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        t[#t+1] = str
    end
    return t
end
CreateThread(function ()
if Config.Framework == 'esx' then
     ESX = exports["es_extended"]:getSharedObject()
else if Config.Framework == 'qb' then
     QBCore = exports['qb-core']:GetCoreObject()
    end
  end
end)

local function getJob()
   if Config.Framework == 'esx' then
    return ESX.PlayerData.job.name
   else
    if Config.Framework == 'qb' then 
        return QBCore.Functions.GetPlayerData().job.name
     end
   end
end

local function connecttoradio(channel)
    RadioChannel = channel
    if onRadio then
        exports["pma-voice"]:setRadioChannel(0)
    else
        exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
	onRadio = true
    end
    exports["pma-voice"]:setRadioChannel(channel)
    if SplitStr(tostring(channel), ".")[2] ~= nil and SplitStr(tostring(channel), ".")[2] ~= "" then
         lib.notify({
            title = 'Joined Radio',
            description = 'Youre connected to:' ..channel.. ' MHz',
            type = 'success'
         })
    else
         lib.notify({
            title = 'Joined Radio',
            description = 'Youre connected to:'  ..channel.. '.00 MHz',
            type = 'success'
         })
    end
end

local function closeEvent()
	TriggerEvent("InteractSound_CL:PlayOnOne","click",0.6)
end

local function leaveradio()
    closeEvent()
    RadioChannel = 0
    onRadio = false
    exports["pma-voice"]:setRadioChannel(0)
    exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
    lib.notify({
        title = 'Left Channel.',
        description = 'You left the channel.',
        type = 'error'
    })
end

local function toggleRadioAnimation(pState)
	LoadAnimDic("cellphone@")
	if pState then
		TriggerEvent("attachItemRadio","radio01")
		TaskPlayAnim(PlayerPedId(), "cellphone@", "cellphone_text_read_base", 2.0, 3.0, -1, 49, 0, 0, 0, 0)
		radioProp = CreateObject(`prop_cs_hand_radio`, 1.0, 1.0, 1.0, 1, 1, 0)
		AttachEntityToEntity(radioProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.14, 0.01, -0.02, 110.0, 120.0, -15.0, 1, 0, 0, 0, 2, 1)
	else
		StopAnimTask(PlayerPedId(), "cellphone@", "cellphone_text_read_base", 1.0)
		ClearPedTasks(PlayerPedId())
		if radioProp ~= 0 then
			DeleteObject(radioProp)
			radioProp = 0
		end
	end
end

local function toggleRadio(toggle)
    radioMenu = toggle
    SetNuiFocus(radioMenu, radioMenu)
    if radioMenu then
        toggleRadioAnimation(true)
        SendNUIMessage({type = "open"})
    else
        toggleRadioAnimation(false)
        SendNUIMessage({type = "close"})
    end
end

local function IsRadioOn()
    return onRadio
end

--Exports
exports("IsRadioOn", IsRadioOn)

RegisterNetEvent('benzo-radio:use', function()
    toggleRadio(not radioMenu)
end)

RegisterNetEvent('benzo-radio:onRadioDrop', function()
    if RadioChannel ~= 0 then
        leaveradio()
    end
end)



-- NUI
RegisterNUICallback('joinRadio', function(data, cb)
    local rchannel = tonumber(data.channel)
    if rchannel ~= nil then
        if rchannel <= Config.MaxFrequency and rchannel ~= 0 then
            if rchannel ~= RadioChannel then
                if Config.RestrictedChannels[rchannel] ~= nil then
                    if Config.RestrictedChannels[rchannel][getJob()] then
                        connecttoradio(rchannel)
                    else
                        lib.notify({
                            title = 'Restriced Channel',
                            description = 'You can not connect to this signal!',
                            type = 'error'
                        })
                    end
                else
                    connecttoradio(rchannel)
                end
            else
                lib.notify({
                    title = 'Already Connected',
                    description = 'Youre already connected to this channel',
                    type = 'error'
                })
            end
        else
            lib.notify({
                title = 'Frequency not available',
                description = 'This frequency is not available.',
                type = 'error'
            })     
           end
    else
        lib.notify({
            title = 'Frequency not available',
            description = 'This frequency is not available.',
            type = 'error'
        })     
        end
end)

RegisterNUICallback('leaveRadio', function(data, cb)
    if RadioChannel == 0 then
        lib.notify({
            title = 'Not Connected',
            description = 'Youre not connected to a signal',
            type = 'error'
        })     
    else
        leaveradio()
    end
end)

RegisterNUICallback("volumeUp", function()
	if RadioVolume <= 95 then
		RadioVolume = RadioVolume + 5
        lib.notify({
            title = 'Info',
            description = 'New Volume '  .. RadioVolume,
            type = 'success'
        })   
		exports["pma-voice"]:setRadioVolume(RadioVolume)
	else
        lib.notify({
            title = 'Info',
            description = 'The radio is already set to maximum volume',
            type = 'error'
        })   
	end
end)

RegisterNUICallback("volumeDown", function()
	if RadioVolume >= 10 then
		RadioVolume = RadioVolume - 5
        lib.notify({
            title = 'Info',
            description = 'New Volume '  .. RadioVolume,
            type = 'success'
        })   
		exports["pma-voice"]:setRadioVolume(RadioVolume)
	else
        lib.notify({
            title = 'Info',
            description = 'The radio is already set to the lowest volume',
            type = 'error'
        })   
	end
end)

RegisterNUICallback("increaseradiochannel", function(data, cb)
    RadioChannel = RadioChannel + 1
    exports["pma-voice"]:setRadioChannel(RadioChannel)
    lib.notify({
        title = 'Info',
        description = 'New channel ' .. RadioChannel,
        type = 'success'
    })   
end)

RegisterNUICallback("decreaseradiochannel", function(data, cb)
    if not onRadio then return end
    RadioChannel = RadioChannel - 1
    if RadioChannel >= 1 then
        exports["pma-voice"]:setRadioChannel(RadioChannel)
        lib.notify({
            title = 'Info',
            description = 'New channel ' .. RadioChannel,
            type = 'success'
        })   
    end
end)

RegisterNUICallback('poweredOff', function(data, cb)
    leaveradio()
end)

RegisterNUICallback('escape', function(data, cb)
    toggleRadio(false)
end)

--Main Thread
CreateThread(function()
    while Config.Item do
        Wait(1000)
        if cache.ped and onRadio then
               if exports.ox_inventory:Search('count', 'radio') > 1 then
                    if RadioChannel ~= 0 then
                        leaveradio()
                    end
                end    
          end
    end
end)

for i=1, Config.MaxFrequency do
    RegisterNetEvent('benzo-radio:client:JoinRadioChannel'.. i, function(channel)
        exports["pma-voice"]:setRadioChannel(i)
        if SplitStr(tostring(channel), ".")[2] ~= nil and SplitStr(tostring(i), ".")[2] ~= "" then
             lib.notify({
                title = 'Info',
                description = 'Youre connected to: ' ..i.. ' MHz',
                type = 'success'
            })   
        else
             lib.notify({
                title = 'Info',
                description = 'Youre connected to: ' ..i.. '.00 MHz',
                type = 'success'
            })   
        end
    end)
end

-- Command
RegisterCommand("radio", function(source)
    if Config.Item then 
        local amount = exports.ox_inventory:Search('count', 'radio')
        if amount < 1 then
            lib.notify({
                title = 'Info',
                description = 'You dont have a radio',
                type = 'error'
            })
            return
        end
    end
        toggleRadio(not radioMenu)
end)

if Config.KeyMappings.Enabled then
    RegisterKeyMapping("radio", 'Toggle Radio', 'keyboard', Config.KeyMappings.Key)
end
