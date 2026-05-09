task.wait(0.2)
print("Started v1")

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Rendered = workspace:WaitForChild("Rendered")
local Chunker = Rendered:GetChildren()[15]

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Pickups = Remotes:WaitForChild("Pickups")
local CollectPickupRemote = Pickups:WaitForChild("CollectPickup")

local AutoPickup = false
local IsCollecting = false

local function TweenToPickup(Pickup)
    local pickupPosition = Pickup:GetPivot().Position
    local targetCFrame = CFrame.new(pickupPosition)

    local tweenInfo = TweenInfo.new(
        1,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )

    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {
        CFrame = targetCFrame
    })

    tween:Play()
    tween.Completed:Wait()
end

local function CollectPickup()
    if IsCollecting then
        return
    end

    if not Chunker then
        warn("Chunker not found")
        return
    end

    IsCollecting = true

    for i, Pickup in ipairs(Chunker:GetChildren()) do
        if not AutoPickup then
            break
        end

        if Pickup and Pickup.Parent then
            local distance = (Pickup:GetPivot().Position - HumanoidRootPart.Position).Magnitude

            if distance < 200 then
                print(Pickup.Name .. " is most likely close enough")
                TweenToPickup(Pickup)
                CollectPickupRemote:FireServer(Pickup.Name)
                task.wait(0.1)
            end
        end
    end

    IsCollecting = false
end

Player.CharacterAdded:Connect(function(NewCharacter)
    Character = NewCharacter
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end)

local Window = Rayfield:CreateWindow({
    Name = "BGSI script",
    LoadingTitle = "3VX hub",
    LoadingSubtitle = "Made by 3VX",

    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "BGSIhub"
    },

    Discord = {
        Enabled = false,
        Invite = "3vx",
        RememberJoins = true
    },

    KeySystem = false
})

local PickupsTab = Window:CreateTab("Pickups", nil)
local PickupSection = PickupsTab:CreateSection("Pickups")

local AutoPickupToggle = PickupsTab:CreateToggle({
    Name = "Auto Pickup",
    CurrentValue = false,
    Flag = "AutoPickup",

    Callback = function(Value)
        AutoPickup = Value

        if AutoPickup then
            task.spawn(function()
                while AutoPickup do
                    CollectPickup()
                    task.wait(0.5)
                end
            end)
        end
    end
})
