Config = {}
Config.Locale = GetConvar('esx:locale', 'en')
Config.FrameWork = 'esx' -- Only supporting ESX, DO NOT CHANGE THIS

Config.MenuPosition = 'right' -- Options: 'left', 'right', 'top', 'bottom'

Config.PresetsMechanics = {
    { label = "", amount = 0 },
    { label = "Reparación de vehículo", amount = 100 },
    { label = "Reemplazo de neumáticos", amount = 50 },
}

Config.Presets = {
    mechanic = Config.PresetsMechanics,
    argents = Config.PresetsMechanics,
    police = {
        { label = "", amount = 0 },
        { label = "Multa por exceso de velocidad", amount = 200 },
        { label = "Multa por conducción imprudente", amount = 300 },
    },
    ambulance = {
        { label = "", amount = 0 },
        { label = "Tratamiento", amount = 1500 },
        { label = "Reanimación", amount = 3500 },
    },
}

function openInvoiceMenu()
    local options = {}

    lib.callback('muhaddil_billing:getInvoices', false, function(invoices)
        for _, invoice in ipairs(invoices) do
            table.insert(options, {
                title = 'Factura: ' .. invoice.label,
                description = 'Monto: $' .. invoice.amount .. '\nPresiona para pagar esta factura.',
                icon = 'file-invoice',
                onSelect = function()
                    lib.callback('muhaddil_billing:payInvoice', false, function(success)
                    end, invoice.id)
                end,
            })
        end

        lib.registerContext({
            id = 'billing_menu',
            title = 'Facturas Pendientes',
            options = options
        })

        lib.showContext('billing_menu')
    end)
end

Config.AutoVersionChecker = true
Config.AutoRunSQL = true