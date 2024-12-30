local ESP = {
    Objects = {},
    Settings = {
        Boxes = false,
        Names = false,
        Tracers = false,
        ShowHealth = false,
        ShowDistance = false, 
        DefaultColor = Color3.fromRGB(255, 255, 255),
        CustomColorFunction = nil,
        IncludeLocalPlayer = false
    },
    Connections = {}
}

getgenv().ESP = ESP

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = game.Players.LocalPlayer

local function CreateDrawing(type, properties)
    local drawing = Drawing.new(type)
    for prop, value in pairs(properties) do
        drawing[prop] = value
    end
    return drawing
end

local function GetObjectColor(object)
    if ESP.Settings.CustomColorFunction then
        return ESP.Settings.CustomColorFunction(object)
    end
    return ESP.Settings.DefaultColor
end

local function IsObjectVisible(object)
    local root = object:FindFirstChild("HumanoidRootPart")
    local humanoid = object:FindFirstChild("Humanoid")
    return root and humanoid and humanoid.Health > 0
end

local function ShouldIncludeObject(object)
    if object == LocalPlayer.Character and not ESP.Settings.IncludeLocalPlayer then
        return false
    end
    return true
end

local function CreateESP(object)
    local box = CreateDrawing("Square", {
        Color = ESP.Settings.DefaultColor,
        Thickness = 1,
        Filled = false
    })

    local nameTag = CreateDrawing("Text", {
        Text = "",
        Size = 20,
        Font = Drawing.Fonts.System,
        Center = false,
        Outline = false,
        OutlineColor = ESP.Settings.DefaultColor,
        Position = Vector2.new(0, 0),
        Visible = true,
        ZIndex = 1,
        Transparency = 1,
        Color = ESP.Settings.DefaultColor
    })

    local healthBar = CreateDrawing("Square", {
        Color = Color3.fromRGB(0, 255, 0),
        Thickness = 1,
        Filled = true,
        Visible = false
    })

    local distanceTag = CreateDrawing("Text", {
        Text = "",
        Size = 16,
        Font = Drawing.Fonts.System,
        Center = false,
        Outline = false,
        OutlineColor = ESP.Settings.DefaultColor,
        Position = Vector2.new(0, 0),
        Visible = true,
        ZIndex = 1,
        Transparency = 1,
        Color = ESP.Settings.DefaultColor
    })

    local tracer = CreateDrawing("Line", {
        Color = ESP.Settings.DefaultColor,
        Thickness = 1
    })

    local connection = RunService.RenderStepped:Connect(function()
        if IsObjectVisible(object) and ShouldIncludeObject(object) then
            local root = object:FindFirstChild("HumanoidRootPart")
            local humanoid = object:FindFirstChild("Humanoid")
            if root and humanoid then
                local position, onScreen = Camera:WorldToViewportPoint(root.Position)
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                local size = Vector2.new(300 / distance, 300 / distance)

                if onScreen then
                    box.Visible = ESP.Settings.Boxes
                    nameTag.Visible = ESP.Settings.Names
                    tracer.Visible = ESP.Settings.Tracers
                    distanceTag.Visible = ESP.Settings.ShowDistance
                    healthBar.Visible = ESP.Settings.ShowHealth

                    box.Position = Vector2.new(position.X - size.X / 2, position.Y - size.Y / 2)
                    box.Size = size
                    box.Color = GetObjectColor(object)

                    nameTag.Text = object.Name or "Unknown"
                    nameTag.Position = Vector2.new(position.X, position.Y - size.Y / 2 - 5)
                    nameTag.Color = GetObjectColor(object)

                    distanceTag.Text = string.format("%.1f m", distance)
                    distanceTag.Position = Vector2.new(position.X, position.Y + size.Y / 2 + 5)
                    distanceTag.Color = GetObjectColor(object)

                    tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    tracer.To = Vector2.new(position.X, position.Y)
                    tracer.Color = GetObjectColor(object)

                    local healthRatio = humanoid.Health / humanoid.MaxHealth
                    healthBar.Size = Vector2.new(size.X * healthRatio, 4)
                    healthBar.Position = Vector2.new(position.X - size.X / 2, position.Y + size.Y / 2 + 10)
                    healthBar.Color = Color3.fromRGB(255 * (1 - healthRatio), 255 * healthRatio, 0)
                else
                    box.Visible = false
                    nameTag.Visible = false
                    tracer.Visible = false
                    distanceTag.Visible = false
                    healthBar.Visible = false
                end
            end
        else
            box.Visible = false
            nameTag.Visible = false
            tracer.Visible = false
            distanceTag.Visible = false
            healthBar.Visible = false
        end
    end)

    table.insert(ESP.Connections, connection)
end

function ESP:AddObject(object)
    if not ESP.Objects[object] then
        ESP.Objects[object] = true
        CreateESP(object)
    end
end

function ESP:RemoveObject(object)
    ESP.Objects[object] = nil
end

function ESP:Destruct()
    for _, connection in ipairs(ESP.Connections) do
        connection:Disconnect()
    end
    ESP.Connections = {}

    for _, object in pairs(ESP.Objects) do
        for _, drawing in ipairs({box, nameTag, tracer, healthBar, distanceTag}) do
            if drawing then
                drawing:Remove()
            end
        end
    end

    ESP.Objects = {}
end

return ESP
