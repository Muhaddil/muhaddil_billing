if Config.FrameWork == "esx" then
    ESX = exports['es_extended']:getSharedObject()
    -- elseif Config.FrameWork == "qb" then
    --     QBCore = exports['qb-core']:GetCoreObject()
else
    ESX = exports['es_extended']:getSharedObject()
end

lib.callback.register('muhaddil_billing:getPresets', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getJob().grade >= 2 then
        return loadPresetsForJob(xPlayer.getJob().name)
    else
        return {}
    end
end)

function loadPresetsForJob(jobName)
    if Config.Presets[jobName] then
        return Config.Presets[jobName]
    else
        return {}
    end
end

local allowedJobs = { 'police', 'ambulance', 'mechanic' }

local function billPlayerByIdentifier(targetIdentifier, senderIdentifier, sharedAccountName, label, amount)
    local xTarget = ESX.GetPlayerFromIdentifier(targetIdentifier)
    amount = ESX.Math.Round(amount)

    if amount <= 0 then return end

    if string.match(sharedAccountName, "society_") then
        return TriggerEvent('esx_addonaccount:getSharedAccount', sharedAccountName, function(account)
            if not account then
                return print(("[^2ERROR^7] Player ^5%s^7 Attempted to Send bill from invalid society - ^5%s^7"):format(
                    senderIdentifier, sharedAccountName))
            end

            MySQL.insert.await(
                'INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (?, ?, ?, ?, ?, ?)',
                { targetIdentifier, senderIdentifier, 'society', sharedAccountName, label, amount })

            if not xTarget then return end

            xTarget.showNotification(TranslateCap('received_invoice'))
        end)
    end

    MySQL.insert.await(
        'INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (?, ?, ?, ?, ?, ?)',
        { targetIdentifier, senderIdentifier, 'player', senderIdentifier, label, amount })

    if not xTarget then return end

    xTarget.showNotification(TranslateCap('received_invoice'))
end

RegisterNetEvent('muhaddil_billing:sendInvoice', function(targetId, amount, label)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetId)

    if not xTarget then
        print("Error: El jugador objetivo no existe (targetId: " .. targetId .. ")")
        return
    end

    local sharedAccountName = 'society_' .. xPlayer.job.name

    billPlayerByIdentifier(xTarget.identifier, xPlayer.identifier, sharedAccountName, label, amount)
end)

function isAllowedJob(job)
    for _, allowedJob in pairs(allowedJobs) do
        if allowedJob == job then
            return true
        end
    end
    return false
end

lib.callback.register('muhaddil_billing:getInvoices', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        return
    end

    local invoices = MySQL.query.await('SELECT amount, id, label FROM billing WHERE identifier = ?',
        { xPlayer.identifier }) or {}

    local origenBills = exports.origen_police:GetUnpayedBills(xPlayer.identifier)
    for _, bill in ipairs(origenBills) do
        table.insert(invoices, {
            amount = bill.price,
            id = 'origen' .. bill.id,
            label = _U('bill_public')
        })
    end

    return invoices
end)


lib.callback.register('muhaddil_billing:payInvoice', function(source, billId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local isOrigenPoliceBill = string.find(billId, "origen") ~= nil

    if not xPlayer then
        return false
    end

    if isOrigenPoliceBill then
        billId = billId:gsub('origen', '')
        local result = MySQL.single.await('SELECT price, job FROM origen_police_bills WHERE id = ?', { billId })

        if not result then
            return false
        end

        local amount = result.price
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. result.job, function(account)
            if xPlayer.getMoney() >= amount then
                exports.origen_police:PayBill(billId)
                xPlayer.removeMoney(amount)
                account.addMoney(amount)
                xPlayer.showNotification(_U('paid_invoice', ESX.Math.GroupDigits(amount)))
                return true
            elseif xPlayer.getAccount('bank').money >= amount then
                exports.origen_police:PayBill(billId)
                xPlayer.removeAccountMoney('bank', amount)
                account.addMoney(amount)
                xPlayer.showNotification(_U('paid_invoice', ESX.Math.GroupDigits(amount)))
                return true
            else
                xPlayer.showNotification(_U('no_money'))
                return false
            end
        end)
    end

    MySQL.single('SELECT sender, target_type, target, amount FROM billing WHERE id = ?', { billId },
        function(result)
            if not result then
                return false
            end

            local amount = result.amount
            local xTarget = ESX.GetPlayerFromIdentifier(result.sender)

            if result.target_type == 'player' then
                if xTarget then
                    if xPlayer.getMoney() >= amount then
                        MySQL.update('DELETE FROM billing WHERE id = ?', { billId },
                            function(rowsChanged)
                                if rowsChanged == 1 then
                                    xPlayer.removeMoney(amount)
                                    xTarget.addMoney(amount)

                                    xPlayer.showNotification(_U('paid_invoice', ESX.Math.GroupDigits(amount)))
                                    xTarget.showNotification(_U('received_payment', ESX.Math.GroupDigits(amount)))
                                    return true
                                end
                                return false
                            end)
                    elseif xPlayer.getAccount('bank').money >= amount then
                        MySQL.update('DELETE FROM billing WHERE id = ?', { billId },
                            function(rowsChanged)
                                if rowsChanged == 1 then
                                    xPlayer.removeAccountMoney('bank', amount)
                                    xTarget.addAccountMoney('bank', amount)

                                    xPlayer.showNotification(_U('paid_invoice', ESX.Math.GroupDigits(amount)))
                                    xTarget.showNotification(_U('received_payment', ESX.Math.GroupDigits(amount)))
                                    return true
                                end
                                return false
                            end)
                    else
                        xTarget.showNotification(_U('target_no_money'))
                        xPlayer.showNotification(_U('no_money'))
                        return false
                    end
                else
                    xPlayer.showNotification(_U('player_not_online'))
                    return false
                end
            else
                TriggerEvent('esx_addonaccount:getSharedAccount', result.target, function(account)
                    if xPlayer.getMoney() >= amount then
                        MySQL.update('DELETE FROM billing WHERE id = ?', { billId },
                            function(rowsChanged)
                                if rowsChanged == 1 then
                                    xPlayer.removeMoney(amount)
                                    account.addMoney(amount)

                                    xPlayer.showNotification(_U('paid_invoice', ESX.Math.GroupDigits(amount)))
                                    if xTarget then
                                        xTarget.showNotification(_U('received_payment', ESX.Math.GroupDigits(amount)))
                                    end
                                    return true
                                end
                                return false
                            end)
                    elseif xPlayer.getAccount('bank').money >= amount then
                        MySQL.update('DELETE FROM billing WHERE id = ?', { billId },
                            function(rowsChanged)
                                if rowsChanged == 1 then
                                    xPlayer.removeAccountMoney('bank', amount)
                                    account.addMoney(amount)
                                    xPlayer.showNotification(_U('paid_invoice', ESX.Math.GroupDigits(amount)))

                                    if xTarget then
                                        xTarget.showNotification(_U('received_payment', ESX.Math.GroupDigits(amount)))
                                    end
                                    return true
                                end
                                return false
                            end)
                    else
                        if xTarget then
                            xTarget.showNotification(_U('target_no_money'))
                        end

                        xPlayer.showNotification(_U('no_money'))
                        return false
                    end
                end)
            end
        end)
end)

lib.callback.register('getPlayerNameInGame', function(targetPlayerServerId)
    local xPlayer = ESX.GetPlayerFromId(targetPlayerServerId)
    if not xPlayer then
        return { firstname = "Desconocido", lastname = "" }
    end

    while not xPlayer.identifier do
        Citizen.Wait(100)
    end
    local result = MySQL.Sync.fetchAll('SELECT firstname, lastname FROM `users` WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    })
    if result[1] and result[1].firstname and result[1].lastname then
        return { firstname = result[1].firstname, lastname = result[1].lastname }
    end
end)
