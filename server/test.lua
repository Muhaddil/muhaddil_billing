-- local presetsFilePath = "presets.json"

-- local function loadPresets()
--     local file = LoadResourceFile(GetCurrentResourceName(), presetsFilePath)
--     if file then
--         return json.decode(file) or {}
--     end
--     return {}
-- end

-- local function savePresets(presets)
--     local jsonData = json.encode(presets)
--     SaveResourceFile(GetCurrentResourceName(), presetsFilePath, jsonData, -1)
-- end

-- lib.callback.register('muhaddil_billing:getPresets', function(source)
--     local xPlayer = ESX.GetPlayerFromId(source)

--     if xPlayer.getJob().grade >= 2 then
--         return loadPresets()
--     else
--         return {}
--     end
-- end)

-- RegisterNetEvent('muhaddil_billing:savePreset')
-- AddEventHandler('muhaddil_billing:savePreset', function(amount)
--     local xPlayer = ESX.GetPlayerFromId(source)
--     local presets = loadPresets()

--     table.insert(presets, amount)
--     savePresets(presets)
-- end)

-- -- Función para eliminar un preset
-- local function deletePreset(presetAmount)
--     local presets = loadPresets()
--     for i, amount in ipairs(presets) do
--         if tostring(amount) == tostring(presetAmount) then
--             table.remove(presets, i) -- Elimina el preset encontrado
--             savePresets(presets) -- Guarda los cambios
--             return true -- Indica que se eliminó exitosamente
--         end
--     end
--     return false -- Indica que no se encontró el preset
-- end

-- -- Registra el evento para eliminar presets
-- RegisterNetEvent('muhaddil_billing:deletePreset')
-- AddEventHandler('muhaddil_billing:deletePreset', function(amount)
--     local xPlayer = ESX.GetPlayerFromId(source)

--     -- Verifica si el jugador tiene permiso
--     if xPlayer then
--         local success = deletePreset(amount)
--         if success then
--             TriggerClientEvent('esx:showNotification', source, 'Preset eliminado exitosamente')
--         else
--             TriggerClientEvent('esx:showNotification', source, 'Preset no encontrado')
--         end
--     else
--         TriggerClientEvent('esx:showNotification', source, 'No tienes permiso para realizar esta acción')
--     end
-- end)
