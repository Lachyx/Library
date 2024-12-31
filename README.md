### ESP Module Documentation

This documentation provides an overview of the functionality, usage, and implementation of the ESP module for Roblox games.

---

### Table of Contents
1. Overview
2. Features
3. API
    - Settings
    - Methods
4. Internal Functions
5. Implementation Details
6. Usage Example

---

### 1. Overview

The ESP module is designed to be a pain in the ass

---

### 2. Features
- **Box Rendering**: Draws a square around the target object.
- **Name Tags**: Displays the name of the object or character.
- **Tracers**: Draws a line from the screen's center to the object.
- **Health Bars**: Visualizes the health of humanoid objects.
- **Distance Display**: Shows the distance between the local player and the target object.
- **Custom Colors**: Allows specifying custom colors for the ESP visuals.
- **Distance Threshold**: Limits rendering to objects within a specific distance.
- **Exclude Local Player**: Optionally excludes the local player from ESP.

---

### 3. API

#### **Settings**

The `ESP.Settings` table controls the appearance and behavior of the ESP visuals:

| Setting               | Type        | Default Value       | Description                                              |
|-----------------------|-------------|---------------------|----------------------------------------------------------|
| `Boxes`               | `boolean`   | `false`             | Enables or disables box rendering.                      |
| `Names`               | `boolean`   | `false`             | Enables or disables name tags.                          |
| `Tracers`             | `boolean`   | `false`             | Enables or disables tracers.                            |
| `ShowHealth`          | `boolean`   | `false`             | Enables or disables health bars.                        |
| `ShowDistance`        | `boolean`   | `false`             | Enables or disables distance display.                   |
| `DefaultColor`        | `Color3`    | `Color3.fromRGB(255, 255, 255)` | Default color for visuals.                    |
| `CustomColorFunction` | `function`  | `nil`               | Custom function to determine object colors.             |
| `IncludeLocalPlayer`  | `boolean`   | `false`             | Includes or excludes the local player.                  |
| `DistanceThreshold`   | `number`    | `300`               | Maximum distance for ESP rendering.                     |

#### **Methods**

| Method               | Description                                                                  |
|----------------------|------------------------------------------------------------------------------|
| `ESP:AddObject(object)`  | Adds an object to the ESP rendering system.                                  |
| `ESP:RemoveObject(object)` | Removes an object from the ESP rendering system.                           |
| `ESP:Destruct()`      | Cleans up all ESP connections and removes visuals.                           |

---

### 4. Internal Functions

| Function                 | Description                                                                 |
|--------------------------|-----------------------------------------------------------------------------|
| `CreateDrawing(type, properties)` | Utility function to create and configure Drawing objects.                 |
| `GetObjectColor(object)` | Determines the color of an object, using `CustomColorFunction` if provided. |
| `IsObjectVisible(object)`| Checks if the object is visible and alive.                                   |
| `ShouldIncludeObject(object)` | Determines if the object should be included based on settings.             |
| `CreateESP(object)`      | Sets up ESP visuals (box, name tag, tracer, health bar, distance display). |

---

### 5. Implementation Details

The module uses Roblox Executors `Drawing` API to render visuals on the screen. The visuals are updated every frame using a `RunService.RenderStepped` connection. Each object tracked by the ESP system is assigned a set of Drawing objects (box, tracer, name tag, etc.), which are updated based on the object's position, health, and visibility.

---

### 6. Usage Example

```lua
-- Initialize ESP module
local ESP = require(path_to_ESP_module)

-- Configure settings
ESP.Settings.Boxes = true
ESP.Settings.Names = true
ESP.Settings.ShowHealth = true
ESP.Settings.DistanceThreshold = 500

-- Add objects to ESP
for _, player in ipairs(game.Players:GetPlayers()) do
    if player.Character then
        ESP:AddObject(player.Character)
    end
end

-- Clean up ESP on shutdown
game:BindToClose(function()
    ESP:Destruct()
end)
```

---

### Notes
- The module assumes objects have a `HumanoidRootPart` and a `Humanoid` for health visualization.
- Objects outside the `DistanceThreshold` are automatically ignored.
- Custom colors can be implemented by assigning a function to `ESP.Settings.CustomColorFunction`.
