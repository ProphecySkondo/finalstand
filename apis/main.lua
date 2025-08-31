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
local fuckall = false
local charging = false
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

--// chat

function mainAPI.SpeakRobloxChat(message: string)
	if typeof(message) ~= "string" or message == "" then
		return
	end

	pcall(function() game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(message) end)
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

function mainAPI:Charge(args: string)
    local inputremote = servertraits:FindFirstChild("Input")

    if true and inputremote:IsA("RemoteEvent") then

		if args ~= "x" or "xoff" then
			mainAPI.SendNotif("dumb hoe")
		end

		if args == "x" then
			charging = true
			inputremote:FireServer({args},CFrame.new())
		elseif args == "xoff" then
			charging = false
			inputremote:FireServer({args},CFrame.new())
		end
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

function mainAPI:SpeedReset(respawntime: number) --// take it or leave it
    if not char then return end
    if not hrp then return end

    local original = hrp.CFrame
    local current = workspace:FindFirstChildWhichIsA("Camera").CFrame
    local chardeletions = gethiddenproperty(workspace, "RejectCharacterDeletions") ~= Enum.RejectCharacterDeletions.Disabled

    do
        local newbody = char:Clone()
        hum.Health = 0
        task.wait(respawntime)
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

function mainAPI:GetPlaceIDs()
    -- fuck everyone for not showing me this shit, go fuck yourself
    if not rconsoleprint then
        replaceclosure(rconsoleprint, print)
    end
    rconsoleprint("Script By 17F7O\n\n")
    local GPlaces = game:GetService("AssetService"):GetGamePlacesAsync()
    while true do
        for _, place in pairs(GPlaces:GetCurrentPage()) do
            rconsoleprint("Name: " .. place.Name .. "\n")
            rconsoleprint("PlaceId: " .. tostring(place.PlaceId) .. "\n")
        end
        if GPlaces.IsFinished then
            break
        end
        GPlaces:AdvanceToNextPageAsync()
    end
end

function mainAPI:Fling(targetplayer)
	--// i skidded off a nigga, fuck off. suck my dick cock sucker
	if not targetplayer or not targetplayer.Parent then
        return mainAPI.SendNotif("Error Occurred", "Invalid target", 5)
    end

    local tchar = targetplayer.Character
    if not tchar then
        return mainAPI.SendNotif("Error Occurred", "Target missing character", 5)
    end

    local thum = tchar:FindFirstChildOfClass("Humanoid")
    local trp = thum and thum.RootPart
    local thead = tchar:FindFirstChild("Head")
    local accessory = tchar:FindFirstChildOfClass("Accessory")
    local handle = accessory and accessory:FindFirstChild("Handle")

    local myplr = plr
    local mychar = myplr and myplr.Character
    local myhum = mychar and mychar:FindFirstChildWhichIsA("Humanoid")
    local myroot = myhum and myhum.RootPart

    if not (mychar and myhum and myroot) then
        return mainAPI.SendNotif("Error Occurred", "Your character not ready", 5)
    end

    getgenv().FPDH = getgenv().FPDH or workspace.FallenPartsDestroyHeight
    if myroot.Velocity.Magnitude < 50 then
        getgenv().OldPos = myroot.CFrame
    end

    if thum and thum.Sit then
        return mainAPI.SendNotif("Error Occurred", "Targeting is sitting", 5)
    end

    if thead then
        workspace.CurrentCamera.CameraSubject = thead
    elseif handle then
        workspace.CurrentCamera.CameraSubject = handle
    elseif thum then
        workspace.CurrentCamera.CameraSubject = thum
    end

    if not tchar:FindFirstChildWhichIsA("BasePart") then
        return mainAPI.SendNotif("Error Occurred", "Target missing baseparts", 5)
    end

    local function FPos(basePart, posCFrame, angCFrame)
        if not (myroot and mychar) then return end
        local combined = CFrame.new(basePart.Position) * (posCFrame or CFrame.new()) * (angCFrame or CFrame.new())
        pcall(function()
            myroot.CFrame = combined
            if mychar.PrimaryPart then
                mychar:SetPrimaryPartCFrame(combined)
            else
                mychar:TranslateBy(combined.p - myroot.CFrame.p)
            end
            myroot.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            myroot.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end)
    end

    local function SFBasePart(basePart)
        local TimeToWait = 2
        local startTick = tick()
        local angle = 0

        repeat
            if not (myroot and thum and basePart and basePart.Parent == targetplayer.Character and targetplayer.Parent == Players) then
                break
            end

            if basePart.Velocity.Magnitude < 50 then
                angle = angle + 100

                FPos(basePart, CFrame.new(0, 1.5, 0) + (thum.MoveDirection * (basePart.Velocity.Magnitude / 1.25)), CFrame.Angles(math.rad(angle), 0, 0))
                task.wait()

                FPos(basePart, CFrame.new(0, -1.5, 0) + (thum.MoveDirection * (basePart.Velocity.Magnitude / 1.25)), CFrame.Angles(math.rad(angle), 0, 0))
                task.wait()

                FPos(basePart, CFrame.new(2.25, 1.5, -2.25) + (thum.MoveDirection * (basePart.Velocity.Magnitude / 1.25)), CFrame.Angles(math.rad(angle), 0, 0))
                task.wait()

                FPos(basePart, CFrame.new(-2.25, -1.5, 2.25) + (thum.MoveDirection * (basePart.Velocity.Magnitude / 1.25)), CFrame.Angles(math.rad(angle), 0, 0))
                task.wait()

                FPos(basePart, CFrame.new(0, 1.5, 0) + thum.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                task.wait()

                FPos(basePart, CFrame.new(0, -1.5, 0) + thum.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                task.wait()
            else
                FPos(basePart, CFrame.new(0, 1.5, thum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                task.wait()

                FPos(basePart, CFrame.new(0, -1.5, -thum.WalkSpeed), CFrame.Angles(0, 0, 0))
                task.wait()

                FPos(basePart, CFrame.new(0, 1.5, thum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                task.wait()

                FPos(basePart, CFrame.new(0, 1.5, (trp and trp.Velocity.Magnitude or 0) / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                task.wait()

                FPos(basePart, CFrame.new(0, -1.5, - (trp and trp.Velocity.Magnitude or 0) / 1.25), CFrame.Angles(0, 0, 0))
                task.wait()

                FPos(basePart, CFrame.new(0, 1.5, (trp and trp.Velocity.Magnitude or 0) / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                task.wait()

                FPos(basePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                task.wait()

                FPos(basePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                task.wait()

                FPos(basePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
                task.wait()

                FPos(basePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                task.wait()
            end
        until (basePart.Velocity.Magnitude > 500)
            or (basePart.Parent ~= targetplayer.Character)
            or (targetplayer.Parent ~= Players)
            or (tick() > startTick + TimeToWait)
            or (thum and thum.Sit)
            or (myhum and myhum.Health <= 0)
    end

    workspace.FallenPartsDestroyHeight = 0/0

    local BV = Instance.new("BodyVelocity")
    BV.Name = "EpixVel"
    BV.Parent = myroot
    BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
    BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)

    myhum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    if trp and thead then
        if (trp.Position - thead.Position).Magnitude > 5 then
            SFBasePart(thead)
        else
            SFBasePart(trp)
        end
    elseif trp then
        SFBasePart(trp)
    elseif thead then
        SFBasePart(thead)
    elseif handle then
        SFBasePart(handle)
    else
        BV:Destroy()
        myhum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = myhum
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
        return mainAPI.SendNotif("Error Occurred", "Target is missing everything", 5)
    end

    if BV and BV.Parent then
        BV:Destroy()
    end
    myhum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    workspace.CurrentCamera.CameraSubject = myhum

    if getgenv().OldPos then
        repeat
            if not (myroot and getgenv().OldPos) then break end
            pcall(function()
                myroot.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                if mychar.PrimaryPart then
                    mychar:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                end
                myhum:ChangeState("GettingUp")
                for _, part in ipairs(mychar:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Velocity = Vector3.new()
                        part.RotVelocity = Vector3.new()
                    end
                end
            end)
            task.wait()
        until (myroot.Position - getgenv().OldPos.p).Magnitude < 25
    end

    workspace.FallenPartsDestroyHeight = getgenv().FPDH

    return true
end

do
	mainAPI.SpeakRobloxChat("API BY [MARTY]: buvzz on blue")
end

return mainAPI
