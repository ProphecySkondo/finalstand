--// was bored son
local hauntedAPI = hauntedAPI or {}

local cloneref = rawget(_G, "cloneref") or function(obj) return obj end
local services = setmetatable({}, {
    __index = function(_, name) return cloneref(game:GetService(name)) end
})

local Players = services.Players
local RunService = services.RunService
local Lighting = services.Lighting
local Debris = services.Debris
local TweenService = services.TweenService
local SoundService = services.SoundService
local UserInputService = services.UserInputService
local CoreGui = services.CoreGui

local plr = Players.LocalPlayer
local plrgui = plr:WaitForChild("PlayerGui")
local workspaceCam = workspace.CurrentCamera

local char = plr.Character
local hud = plrgui:FindFirstChild("HUD")
local bottom = hud and hud:FindFirstChild("BottomGui")
local stats = bottom and bottom:FindFirstChild("Stats")
local chatgui = bottom and bottom:FindFirstChild("ChatGui")

local V1 = tostring
local V2 = table.insert
local V3 = setmetatable
local V4 = print

local SOUND_IDS = {
    Scream = "rbxassetid://9043345732",
    Heartbeat = "rbxassetid://7188240609",
    Whisper = "rbxassetid://313948389",
    Music = "rbxassetid://1840684529",
}

local assets = {
    ["Main"] = "rbxassetid://1243374078",
    ["Secondary"] = "rbxassetid://10657365540",
    ["Third"] = "rbxassetid://71277064",
    ["Blood"] = "rbxassetid://8228459691",
    ["Khabib"] = "rbxassetid://7399974631",
    ["Mouse"] = "",
    ["Sky"] = {
        Moon = "",
        Rest = "",
    },
}

function hauntedAPI.SolaraDex()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/HummingBird8/HummingRn/main/OptimizedDexForSolara.lua"))()
end

function hauntedAPI:CHANGEMOUSE(assetid: string)
    if assetid and assetid ~= "" then
        UserInputService.MouseIcon = V1(assetid)
    end
end

local currentMusicSound = nil
local function stopAllSystemMusic()
    for _, s in ipairs(SoundService:GetDescendants()) do
        if s:IsA("Sound") then
            pcall(function() s:Stop() end)
        end
    end
    for _, w in ipairs(workspace:GetDescendants()) do
        if w:IsA("Sound") then
            pcall(function() w:Stop() end)
        end
    end
end

function hauntedAPI:PlayMusic(assetid: string)
    stopAllSystemMusic()
    if currentMusicSound then
        pcall(function() currentMusicSound:Stop() end)
        pcall(function() currentMusicSound:Destroy() end)
        currentMusicSound = nil
    end
    local id = assetid or assets.Main or SOUND_IDS.Music
    if not id or id == "" then return end
    local s = Instance.new("Sound")
    s.Name = "Haunted_MainMusic"
    s.SoundId = V1(id)
    s.Looped = true
    s.Volume = 1
    s.Parent = SoundService
    pcall(function() s:Play() end)
    currentMusicSound = s
end

function hauntedAPI:StopMusic()
    if currentMusicSound then
        pcall(function() currentMusicSound:Stop() end)
        pcall(function() currentMusicSound:Destroy() end)
        currentMusicSound = nil
    end
    stopAllSystemMusic()
end

local createdLightingObjects = {}
local renderConn = nil
local shakeState = {
    active = false,
    amplitude = 0,
    frequency = 6,
    timer = 0
}
local flashGui = nil

function hauntedAPI:Setlighting()
    if not plr.Character then return end

    for _, v in ipairs(Lighting:GetChildren()) do
        if (v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("ColorCorrectionEffect")
            or v:IsA("BloomEffect") or v:IsA("BlurEffect")) and v.Name ~= "Water" then
            pcall(function() v:Destroy() end)
        end
    end

    local atmosphere = Instance.new("Atmosphere")
    atmosphere.Density = 0.45
    atmosphere.Offset = 0.25
    atmosphere.Color = Color3.fromRGB(70, 60, 80)
    atmosphere.Decay = Color3.fromRGB(0, 0, 0)
    atmosphere.Glare = 0
    atmosphere.Haze = 3
    atmosphere.Parent = Lighting
    table.insert(createdLightingObjects, atmosphere)

    local sky = Instance.new("Sky")
    sky.SkyboxBk = assets.Sky.Rest ~= "" and assets.Sky.Rest or "rbxassetid://151243259"
    sky.SkyboxDn = assets.Sky.Rest ~= "" and assets.Sky.Rest or "rbxassetid://151243259"
    sky.SkyboxFt = assets.Sky.Rest ~= "" and assets.Sky.Rest or "rbxassetid://151243259"
    sky.SkyboxLf = assets.Sky.Rest ~= "" and assets.Sky.Rest or "rbxassetid://151243259"
    sky.SkyboxRt = assets.Sky.Rest ~= "" and assets.Sky.Rest or "rbxassetid://151243259"
    sky.SkyboxUp = assets.Sky.Rest ~= "" and assets.Sky.Rest or "rbxassetid://151243259"
    sky.MoonTextureId = assets.Sky.Moon ~= "" and assets.Sky.Moon or "rbxassetid://1417494030"
    sky.MoonAngularSize = 11
    sky.StarCount = 3000
    sky.Parent = Lighting
    table.insert(createdLightingObjects, sky)

    local cc = Instance.new("ColorCorrectionEffect")
    cc.TintColor = Color3.fromRGB(160, 150, 200)
    cc.Contrast = 0.2
    cc.Saturation = -0.3
    cc.Brightness = -0.05
    cc.Parent = Lighting
    table.insert(createdLightingObjects, cc)

    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 0.15
    bloom.Threshold = 0.8
    bloom.Size = 56
    bloom.Parent = Lighting
    table.insert(createdLightingObjects, bloom)

    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = Lighting
    table.insert(createdLightingObjects, blur)

    V4("Setting Lighting")
    do

    end
end

local function applyAssetsAcrossWorld()
    local img = assets.Main or ""
    local snd = SOUND_IDS.Music or ""
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Decal") or obj:IsA("Texture") then
            pcall(function() obj.Texture = V1(img) end)
        elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            pcall(function() obj.Image = V1(img) end)
        elseif obj:IsA("MeshPart") then
            if img ~= "" then pcall(function() obj.TextureID = V1(img) end) end
        elseif obj:IsA("SpecialMesh") then
            if img ~= "" then pcall(function() obj.TextureId = V1(img) end) end
        elseif obj:IsA("Sound") then
            pcall(function()
                obj:Stop()
                if snd ~= "" then obj.SoundId = V1(snd) end
            end)
        end
    end
    for _, gui in ipairs(plrgui:GetDescendants()) do
        if gui:IsA("ImageLabel") or gui:IsA("ImageButton") then
            pcall(function() gui.Image = V1(img) end)
        elseif gui:IsA("TextLabel") then
            pcall(function() gui.Text = gui.Text end)
        end
    end
end

local function ensureFlashGui()
    if flashGui and flashGui.Parent then return flashGui end
    local sg = Instance.new("ScreenGui")
    sg.Name = "HauntedFlashGui"
    sg.ResetOnSpawn = false
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,1,0)
    f.Position = UDim2.new(0,0,0,0)
    f.BackgroundColor3 = Color3.new(1,1,1)
    f.BackgroundTransparency = 1
    f.Parent = sg
    sg.Parent = plrgui
    flashGui = sg
    return flashGui
end

local function flashOnce(duration)
    local sg = ensureFlashGui()
    local f = sg:FindFirstChildOfClass("Frame")
    if not f then return end
    f.BackgroundTransparency = 0.95
    pcall(function()
        local goal = {}
        goal.BackgroundTransparency = 1
        local t = TweenService:Create(f, TweenInfo.new(duration or 0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
        t:Play()
        t.Completed:Connect(function() end)
    end)
end

local function startRenderLoop()
    if renderConn then return end
    local blur = Lighting:FindFirstChildOfClass("BlurEffect")
    local baseLastPos = workspace.CurrentCamera and workspace.CurrentCamera.CFrame.Position or Vector3.new()
    renderConn = RunService.RenderStepped:Connect(function(dt)
        local cam = workspace.CurrentCamera
        if not cam then return end
        local speed = (cam.CFrame.Position - baseLastPos).Magnitude / math.max(dt, 0.0001)
        baseLastPos = cam.CFrame.Position
        local targetBlur = math.clamp(speed * 0.01 * (1 + (shakeState.amplitude * 0.3)), 0, 18)
        if blur then
            blur.Size = blur.Size + (targetBlur - blur.Size) * math.clamp(dt * 6, 0, 1)
        end
        if shakeState.active then
            shakeState.timer = shakeState.timer + dt * shakeState.frequency
            local sx = math.sin(shakeState.timer * 1.13) * (shakeState.amplitude * 0.01)
            local sy = math.cos(shakeState.timer * 1.41) * (shakeState.amplitude * 0.01)
            local sz = math.sin(shakeState.timer * 0.7) * (shakeState.amplitude * 0.01)
            local offset = Vector3.new(sx, sy, sz)
            local ok, cf = pcall(function() return cam.CFrame end)
            if ok and cf then
                local newCFrame = cf * CFrame.new(offset)
                pcall(function() cam.CFrame = newCFrame end)
            end
        end
    end)
end

local function stopRenderLoop()
    if renderConn then
        pcall(function() renderConn:Disconnect() end)
        renderConn = nil
    end
    local blur = Lighting:FindFirstChildOfClass("BlurEffect")
    if blur then
        pcall(function() blur.Size = 0 end)
    end
end

function hauntedAPI:StartHorror(opts)
    if opts == nil then opts = {} end
    hauntedAPI:Setlighting()
    applyAssetsAcrossWorld()
    hauntedAPI:PlayMusic(opts.music or assets.Main or SOUND_IDS.Music)
    shakeState.active = true
    shakeState.amplitude = opts.shakeAmplitude or 8
    shakeState.frequency = opts.shakeFrequency or 6
    startRenderLoop()
    if opts.flashOnStart then flashOnce(opts.flashDuration or 0.45) end
end

function hauntedAPI:StopHorror()
    hauntedAPI:StopMusic()
    shakeState.active = false
    shakeState.amplitude = 0
    stopRenderLoop()
    if flashGui then
        pcall(function() flashGui:Destroy() end)
        flashGui = nil
    end
    for _, obj in ipairs(createdLightingObjects) do
        pcall(function() if obj and obj.Parent then obj:Destroy() end end)
    end
    createdLightingObjects = {}
end

function hauntedAPI:FlashNow(duration)
    flashOnce(duration)
end

return hauntedAPI
