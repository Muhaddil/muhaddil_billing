# Muhaddil Billing Script

## Overview

**Muhaddil Billing Script** is a FiveM script that allows players to send and manage invoices within the game. It supports different frameworks, currently ESX, with plans to support QBCore in the future. Players can create preset invoices for various jobs (mechanics, police, ambulance) and pay these invoices through a user-friendly interface.

<div align="center">
    <img src="https://i.ibb.co/RY0w9ws/imagen.png" alt="Muhaddil Billing Script Screenshot" width="300"/>
</div>

## Features

- Send invoices to nearby players.
- Predefined invoice presets for specific jobs.
- Ability to save and reuse invoice presets.
- Manage and pay invoices from a dedicated menu.
- Configurable key mappings for easy access.
- 0.00 resmon 1 values on idle

## Requirements

- **ESX** framework installed.
- **MySQL** database for persistent storage of invoices.

## Installation

1. **Download the Script**: Download the repository.

2. **Add to Server**: Place the script folder in your `resources` directory.

3. **Update `server.cfg`**: Add the resource to your server configuration.

   ```plaintext
   start muhaddil_billing
   ```

4. **Database Setup**: Ensure your database has the necessary tables. The script should handle invoice data.

   Example SQL for the billing table:

   ```sql
   CREATE TABLE `billing` (
   	`id` int NOT NULL AUTO_INCREMENT,
   	`identifier` varchar(60) NOT NULL,
   	`sender` varchar(60) NOT NULL,
   	`target_type` varchar(50) NOT NULL,
   	`target` varchar(60) NOT NULL,
   	`label` varchar(255) NOT NULL,
   	`amount` int NOT NULL,

   	PRIMARY KEY (`id`)
   ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
   ```

## Configuration

The configuration file is located within the script folder. Update the `config` file as needed.

### Config Structure

```lua
Config = {}
Config.Locale = GetConvar('esx:locale', 'en') -- Change the locales of the script
Config.FrameWork = 'esx' -- Only supporting ESX, DO NOT CHANGE THIS

Config.PresetsMechanics = {
    { label = "", amount = 0 },
    { label = "Vehicle Repair", amount = 100 },
    { label = "Tire Replacement", amount = 50 },
}

Config.Presets = {
    mechanic = Config.PresetsMechanics,
    argents = Config.PresetsMechanics,
    police = {
        { label = "", amount = 0 },
        { label = "Speeding Fine", amount = 200 },
        { label = "Reckless Driving Fine", amount = 300 },
    },
    ambulance = {
        { label = "", amount = 0 },
        { label = "Treatment", amount = 1500 },
        { label = "Resuscitation", amount = 3500 },
    },
}
```

- **Locale**: The language setting for the script.
- **Presets**: Customize invoice presets for various jobs by adding or modifying entries in `Config.Presets`.

## Usage

### Key Bindings

- **Open Invoice Menu**: The invoice menu can be opened using the following command:

  - **Command**: `/openinvoice` (Mapped to `F6`)
  - **Command**: `/facturas` (Mapped to `F7`)

### Example of Using the Export

To open the invoice menu from another script, use the following export:

```lua
exports['muhaddil_billing']:OpenInvoiceMenu()
```

## Contributing

If you would like to contribute to this project, please fork the repository and create a pull request. Any contributions or suggestions are welcome!

## License

This project is licensed under the MIT License. See the LICENSE file for more details.
