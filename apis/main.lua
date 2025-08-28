--// simple final stand api, suck my dick cocksucker about any issues u got go fuck urself
local mainAPI = {}
_G.mainAPI_outputs = _G.mainAPI_outputs or 0

local cloneref = rawget(_G, "cloneref") or function(obj)
    return obj
end

local services = setmetatable({}, {
    __index = function(_, name)
        return cloneref(game:GetService(name))
    end
})

local Players = services.Players
local HttpService = services.HttpService
local TeleportService = services.TeleportService
local RunService = services.RunService
local Lighting = services.Lighting

local noslow = false
local punching = false
local changingslots = false
local touchfling = false
local noSlowConnection
local touchFlingConnection

local unanchoredparts = {}

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart", 9)
local hum = char:FindFirstChildWhichIsA("Humanoid")
local backpack = plr:FindFirstChildOfClass("Backpack")
local servertraits = backpack and backpack:FindFirstChild("ServerTraits")
local anims = backpack and backpack:FindFirstChild("Anims")
local plrgui = plr:FindFirstChildOfClass("PlayerGui")
local hud = plrgui and plrgui:FindFirstChild("HUD")
local bottom = hud and hud:FindFirstChild("Bottom")
local stats = bottom and bottom:FindFirstChild("Stats")

local Live = workspace:FindFirstChild("Live")
local FriendlyNPCs = workspace:FindFirstChild("FriendlyNPCs")
local Effects = workspace:FindFirstChild("Effects")

--// global funcs

function mainAPI.Load(wat: boolean)
    if wat ~= true then return false end
    if not game:IsLoaded() then
        repeat task.wait() until game:IsLoaded()
        return "loaded"
    end
    return true
end

function mainAPI.Output(thing: string)
    _G.mainAPI_outputs += 1
    warn("[Final-Stand]:", thing, _G.mainAPI_outputs .. "x")
end

function mainAPI.SendNotif(title: string, text: string, time: number)
    title = title or " "
    text = text or " "
    time = time or 5
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = time
    })
end

function mainAPI.GetHudLevel()
    if stats then
        local lvlFrame = stats:FindFirstChild("LVL")
        if lvlFrame then
            local val = lvlFrame:FindFirstChild("Val")
            if val and val:IsA("TextLabel") then
                local text = val.Text
                local num = string.match(text, "%d+")
                return tonumber(num)
            end
        end
    end
    return nil
end

function mainAPI.RealLevel()
    local level = mainAPI.GetHudLevel()
    if not level then return nil end
    local levelName = string.format("Lvl. %s", level)
    return char and char:FindFirstChild(levelName) and level or nil
end

function mainAPI.SetNIL(path: string)
    if char and path then
        path.Parent = nil
    end
end

--// quick bs of everything

function mainAPI:Punch(args: string)
    local punchremote = servertraits:FindFirstChild("Input")

    if punching == true then
        return
    end

    if punchremote and punchremote:IsA("RemoteEvent") then

        if args ~= "md" and args ~= "m2" then
            mainAPI.SendNotif("YOU WERE ABOUT TO GET BANNED")
            return
        end

        punching = true
        punchremote:FireServer({args}, CFrame.new())
        punching = false
    end
end

function mainAPI:ChangeSlot(Slot: number)
    mainAPI.Output("If this doesn't work then final stand snake is a cocksucker")
    servertraits:FindFirstChild("ChatStart"):FireServer(FriendlyNPCs:FindFirstChild("Character Slot Changer"))
    task.wait(.700)
    servertraits:FindFirstChild("ChatAdvance"):FireServer({"Yes"})
    task.wait(.700)
    servertraits:FindFirstChild("ChatAdvance"):FireServer({"k"})
    task.wait(.700)
    servertraits:FindFirstChild("ChatAdvance"):FireServer({"Slot", Slot})
    changingslots = true
    do
        if changingslots == true then
            plr.CharacterAdded:Connect(function()
                repeat
                    task.wait()
                until char:FindFirstChild("PowerOutput")
                changingslots = false

                task.delay(1,function()
                    repeat
                        task.wait(.1)
                    until plr:FindFirstChildOfClass("PlayerGui"):FindFirstChild("HUD")
                    changingslots = false
                end)
            end)
        end
    end
end

function mainAPI:ActivateNoSlow()
    noslow = true
    mainAPI.Output("No Slow Started")

    if noSlowConnection then
        noSlowConnection:Disconnect()
        noSlowConnection = nil
    end

    noSlowConnection = RunService.Heartbeat:Connect(function()
        if not noslow then return end
        local char = plr.Character
        if not char then return end

        local tags = {
            "Block", "Action", "Attacking", "Hyper", "heavy", "KiBlasted"
        }

        for _, tag in ipairs(tags) do
            local obj = char:FindFirstChild(tag)
            if obj then
                pcall(function()
                    if obj:IsA("BoolValue") then
                        obj.Value = false
                    else
                        obj:Destroy()
                    end
                end)
            end
        end

        local level = mainAPI.GetHudLevel()
        if level then
            local lvlFolder = char:FindFirstChild("Lvl. " .. level)
            if lvlFolder then
                local zzxx = lvlFolder:FindFirstChild("ZZXX")
                if zzxx then
                    pcall(function()
                        zzxx:Destroy()
                    end)
                end
            end
        end
    end)
end

function mainAPI:DisableNoSlow()
    noslow = false
    mainAPI.Output("No Slow is Disabled")

    if noSlowConnection then
        noSlowConnection:Disconnect()
        noSlowConnection = nil
    end
end

function mainAPI:FreezeGame(pingAmount: number)
    local cce = Lighting:FindFirstChild("FreezeEffect") or Instance.new("ColorCorrectionEffect")
    cce.Name = "FreezeEffect"
    cce.Saturation = -1
    cce.Parent = Lighting

    mainAPI.Output("Game is now 'frozen' (visual effect applied)")
end

function mainAPI:UnfreezeGame()
    local cce = Lighting:FindFirstChild("FreezeEffect") or Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
    if cce then
        pcall(function()
            cce.Saturation = 0
            if cce.Name == "FreezeEffect" then
                cce:Destroy()
            end
        end)
    end

    mainAPI.Output("Game is unfrozen (visual effect removed)")
end

function mainAPI:TweenTo(targetCFrame: CFrame, tweenTime: number)
    local character = plr.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local TweenService = services.TweenService or game:GetService("TweenService")

    do
        mainAPI.Output("Tweening...")
        tweenTime = tweenTime or 1

        local tweenInfo = TweenInfo.new(
            tweenTime,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out
        )

        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
    end
    return tween
end

function mainAPI:SpeedReset() --// take it or leave it
    if not char then return end
    if not hrp then return end

    local original = hrp.CFrame
    local current = workspace:FindFirstChildWhichIsA("Camera").CFrame
    local chardeletions = gethiddenproperty(workspace, "RejectCharacterDeletions") ~= Enum.RejectCharacterDeletions.Disabled

    do
        local newbody = char:Clone()
        hum.Health = 0
        task.wait(0.3)
        mainAPI.Output("Speed Resetting")
        hum:ChangeState(Enum.HumanoidStateType.Dead)
        char:ClearAllChildren()

        newbody = newbody
        newbody.Parent = Live
        plr.Character = newbody
        task.wait()
        plr.Character = plr.Character
        newbody:Destroy()

        task.spawn(function()
            plr.CharacterAdded:Wait():WaitForChild("HumanoidRootPart").CFrame = original
            workspace.CurrentCamera.CFrame = current
        end)
    end
end

function mainAPI:StartTouchFling(flingpower: number)
    if touchfling == true then
        return
    end

    touchfling = true
    flingpower = flingpower or 16.5
    mainAPI.Output("Touch Fling Started")

    if touchFlingConnection then
        touchFlingConnection:Disconnect()
        touchFlingConnection = nil
    end

    local lastFlingTime = {}

    local function flingTarget(targetChar, targetHrp)
        local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
        if not targetPlayer then return end
        
        local currentTime = tick()
        if lastFlingTime[targetPlayer.UserId] and (currentTime - lastFlingTime[targetPlayer.UserId]) < 0.5 then 
            return 
        end
        
        lastFlingTime[targetPlayer.UserId] = currentTime
        
        pcall(function()
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local direction = (targetHrp.Position - hrp.Position).Unit
            local flingVelocity = direction * flingpower * 50 + Vector3.new(0, flingpower * 2, 0)
            
            targetHrp.Velocity = flingVelocity
            targetHrp.AssemblyLinearVelocity = flingVelocity
            targetHrp.AssemblyAngularVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
        end)
    end

    local function onTouched(hit)
        if not touchfling then return end
        local targetChar = hit.Parent
        local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
        
        if targetHumanoid and targetChar ~= char then
            local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
            if targetHrp then
                local hitBelongsToUs = false
                if char then
                    for _, part in pairs(char:GetChildren()) do
                        if part == hit then 
                            hitBelongsToUs = true 
                            break 
                        end
                    end
                end
                if not hitBelongsToUs then
                    flingTarget(targetChar, targetHrp)
                end
            end
        end
    end

    do
        if char then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    pcall(function()
                        part.Touched:Connect(onTouched)
                    end)
                end
            end
        end

        touchFlingConnection = RunService.Heartbeat:Connect(function()
            if not touchfling then return end
            local currentChar = plr.Character
            if currentChar and currentChar.Parent then
                local currentHrp = currentChar:FindFirstChild("HumanoidRootPart")
                if currentHrp then
                    pcall(function()
                        local originalVel = currentHrp.Velocity
                        currentHrp.Velocity = originalVel * 10000 + Vector3.new(0, 10000, 0)
                        RunService.RenderStepped:Wait()
                        currentHrp.Velocity = originalVel
                        RunService.Stepped:Wait()
                        currentHrp.Velocity = originalVel + Vector3.new(0, 0.1, 0)
                    end)
                end
            end
        end)
    end
end

function mainAPI:StopTouchFling()
    touchfling = false
    mainAPI.Output("Touch Fling Stopped")

    if touchFlingConnection then
        touchFlingConnection:Disconnect()
        touchFlingConnection = nil
    end
end

return mainAPI
