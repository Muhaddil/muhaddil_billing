if Config.FrameWork == "esx" then
    ESX = exports['es_extended']:getSharedObject()
    -- elseif Config.FrameWork == "qb" then
    --     QBCore = exports['qb-core']:GetCoreObject()
else
    ESX = exports['es_extended']:getSharedObject()
end

local isInvoiceOpen = false

function OpenInvoiceMenu()
    if not isInvoiceOpen then
        local playerJob = ESX.GetPlayerData().job.name
        local playersNearby = GetNearbyPlayers()
        local presets = Config.Presets[playerJob] or (Config.AllowAllJobs and { { label = "", amount = 0 } } or nil)
        local position = Config.MenuPosition

        if presets == nil or #presets == 0 then
            ESX.ShowNotification(_U('no_perms'))
            return
        end

        SetNuiFocus(true, true)
        isInvoiceOpen = true
        SendNUIMessage({
            action = 'open',
            locale = Locales[Config.Locale],
            players = playersNearby,
            presets = presets,
            position = position,
        })
    end
end

RegisterNetEvent('muhaddil_billing:openInvoiceMenu')
AddEventHandler('muhaddil_billing:openInvoiceMenu', OpenInvoiceMenu)

exports('OpenInvoiceMenu', OpenInvoiceMenu)
-- Example of use
-- exports['muhaddil_billing']:OpenInvoiceMenu()

RegisterNUICallback('savePreset', function(data, cb)
    local amount = tonumber(data.amount)

    if amount then
        TriggerServerEvent('muhaddil_billing:savePreset', amount)
        cb('ok')
    else
        cb('error')
    end
end)

RegisterNUICallback('sendInvoice', function(data, cb)
    local targetId = data.playerId
    local amount = tonumber(data.amount)
    local label = data.label

    if targetId and amount and label then
        TriggerServerEvent('muhaddil_billing:sendInvoice', targetId, amount, label)
        SetNuiFocus(false, false)
        isInvoiceOpen = false
        cb('ok')
    else
        cb('error')
    end
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    isInvoiceOpen = false
    cb('ok')
end)

if Config.EnableCommands then
    RegisterKeyMapping('openinvoice', _U('command_title_open'), 'keyboard', 'F6')

    RegisterCommand(Config.Command, function()
        TriggerEvent('muhaddil_billing:openInvoiceMenu')
    end, false)
end

function GetNearbyPlayers()
    local coords = GetEntityCoords(PlayerPedId())
    local radius = 5.0

    local players = ESX.Game.GetPlayersInArea(coords, radius)
    local playersData = {}

    local localPlayerId = PlayerId()
    local localPlayerServerId = GetPlayerServerId(localPlayerId)
    local localPlayerNameData = lib.callback.await('getPlayerNameInGame', localPlayerServerId)
    local localPlayerName = localPlayerNameData.firstname .. " " .. localPlayerNameData.lastname
    table.insert(playersData, { id = localPlayerServerId, name = localPlayerName })

    for _, player in ipairs(players) do
        if player ~= localPlayerId then
            local playerServerId = GetPlayerServerId(player)
            local playerNameData = lib.callback.await('getPlayerNameInGame', playerServerId)
            local playerName = playerNameData.firstname .. " " .. playerNameData.lastname
            table.insert(playersData, { id = playerServerId, name = playerName })
        end
    end

    return playersData
end

RegisterKeyMapping('facturas', _U('command_title_open_pay'), 'keyboard', 'F7')

RegisterCommand('facturas', function()
    openInvoiceMenu()
end, false)
