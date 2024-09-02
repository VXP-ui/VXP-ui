local runService = game:GetService("RunService")
local players = game:GetService("Players")
local player = players.LocalPlayer
local camera = workspace.CurrentCamera

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = camera

local lastCameraPosition = camera.CFrame.Position
local lastCameraRotation = camera.CFrame.LookVector

local targetBlurSize = 0
local currentBlurSize = 0
local blurSpeed = 0.2
local positionSensitivity = 20 -- adjust for sensitivty 🤑
local rotationSensitivity = 10 -- adjust rotation sensitivity (less important)

runService.RenderStepped:Connect(function()
    local currentPosition = camera.CFrame.Position
    local currentRotation = camera.CFrame.LookVector

    local positionDelta = (currentPosition - lastCameraPosition).Magnitude
    local rotationDelta = (currentRotation - lastCameraRotation).Magnitude

    lastCameraPosition = currentPosition
    lastCameraRotation = currentRotation

    local blurAmount = (positionDelta * positionSensitivity) + (rotationDelta * rotationSensitivity)
    targetBlurSize = math.clamp(blurAmount, 0, 56)

    currentBlurSize = currentBlurSize + (targetBlurSize - currentBlurSize) * blurSpeed

    blur.Size = math.max(currentBlurSize, 0)
end)
