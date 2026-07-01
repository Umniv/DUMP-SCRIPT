-- SOUL DRONE (MOBILE) - LocalScript in StarterPlayerScripts
-- On-screen button to toggle, dynamic joystick (like Roblox's own thumbstick) to move,
-- up/down buttons for height, drag anywhere else on screen to look around,
-- tap a player to spectate them, tap empty space to stop spectating.
--
-- NEW: "Edit UI" button lets you drag every control (toggle, up/down, speed
-- panel, joystick zone) to wherever you want on screen. Positions persist for
-- the current session (they reset on rejoin unless you add DataStore saving).
-- NEW: Speed control now works like a scroll/drag adjustment - tapping alone
-- does nothing, the value only changes based on how far you drag your finger.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

-- ===== CONFIG =====
local SPEED = 40
local MIN_SPEED = 5
local MAX_SPEED = 150
local LOOK_SENSITIVITY = 0.006
local JOY_RADIUS = 65       -- px, max thumb travel
local JOY_DEADZONE = 0.08   -- ignore tiny drift near center
local JOY_BG_SIZE = 130
local JOY_THUMB_SIZE = 55

local active = false
local editMode = false
local pos = CFrame.new()
local yaw, pitch = 0, 0
local target = nil
local verticalDir = 0
local joyVector = Vector2.new(0, 0)

-- ===== UI =====
local gui = Instance.new("ScreenGui")
gui.Name = "SoulDroneUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 110, 0, 44)
toggleBtn.Position = UDim2.new(1, -120, 0, 20)
toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.Text = "Drone: OFF"
toggleBtn.Active = true
toggleBtn.Parent = gui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)

-- Edit-layout toggle, always visible in the top-left corner
local editBtn = Instance.new("TextButton")
editBtn.Name = "EditBtn"
editBtn.Size = UDim2.new(0, 90, 0, 36)
editBtn.Position = UDim2.new(0, 20, 0, 80)
editBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 68)
editBtn.TextColor3 = Color3.new(1, 1, 1)
editBtn.Font = Enum.Font.GothamBold
editBtn.TextSize = 14
editBtn.Text = "Edit UI"
editBtn.Active = true
editBtn.Parent = gui
Instance.new("UICorner", editBtn).CornerRadius = UDim.new(0, 10)

-- Invisible zone where touches spawn the joystick (bottom-left of screen),
-- like Roblox's own dynamic thumbstick control.
local joyZone = Instance.new("Frame")
joyZone.Name = "JoyZone"
joyZone.BackgroundTransparency = 1
joyZone.Position = UDim2.new(0, 0, 0.35, 0)
joyZone.Size = UDim2.new(0.55, 0, 0.65, 0)
joyZone.Active = true
joyZone.Visible = false
joyZone.ZIndex = 1
joyZone.Parent = gui

local joyZoneStroke = Instance.new("UIStroke")
joyZoneStroke.Color = Color3.fromRGB(90, 170, 255)
joyZoneStroke.Thickness = 2
joyZoneStroke.Transparency = 1 -- only shown in edit mode
joyZoneStroke.Parent = joyZone

local joyBg = Instance.new("Frame")
joyBg.Name = "JoyBg"
joyBg.AnchorPoint = Vector2.new(0.5, 0.5)
joyBg.Size = UDim2.fromOffset(JOY_BG_SIZE, JOY_BG_SIZE)
joyBg.BackgroundColor3 = Color3.new(1, 1, 1)
joyBg.BackgroundTransparency = 0.8
joyBg.BorderSizePixel = 0
joyBg.Visible = false
joyBg.ZIndex = 2
joyBg.Parent = gui
Instance.new("UICorner", joyBg).CornerRadius = UDim.new(1, 0)
local joyBgStroke = Instance.new("UIStroke")
joyBgStroke.Color = Color3.new(1, 1, 1)
joyBgStroke.Transparency = 0.5
joyBgStroke.Thickness = 2
joyBgStroke.Parent = joyBg

local joyThumb = Instance.new("Frame")
joyThumb.Name = "JoyThumb"
joyThumb.AnchorPoint = Vector2.new(0.5, 0.5)
joyThumb.Size = UDim2.fromOffset(JOY_THUMB_SIZE, JOY_THUMB_SIZE)
joyThumb.Position = UDim2.new(0.5, 0, 0.5, 0)
joyThumb.BackgroundColor3 = Color3.new(1, 1, 1)
joyThumb.BackgroundTransparency = 0.25
joyThumb.ZIndex = 3
joyThumb.Parent = joyBg
Instance.new("UICorner", joyThumb).CornerRadius = UDim.new(1, 0)

local function makeVertBtn(text, yOffset)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 60, 0, 60)
	btn.Position = UDim2.new(1, -80, 1, yOffset)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 18
	btn.Text = text
	btn.Active = true
	btn.Visible = false
	btn.Parent = gui
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
	return btn
end

local upBtn = makeVertBtn("UP", -170)
local downBtn = makeVertBtn("DOWN", -100)

-- Speed slider panel (top-left, out of the way of the joystick/look zones)
local speedPanel = Instance.new("Frame")
speedPanel.Name = "SpeedPanel"
speedPanel.BackgroundTransparency = 1
speedPanel.Position = UDim2.new(0, 20, 0, 20)
speedPanel.Size = UDim2.new(0, 200, 0, 50)
speedPanel.Active = true
speedPanel.Visible = false
speedPanel.Parent = gui

local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.BackgroundTransparency = 1
speedLabel.Size = UDim2.new(1, 0, 0, 20)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 14
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Text = "Speed: " .. SPEED
speedLabel.Parent = speedPanel

local speedTrack = Instance.new("Frame")
speedTrack.Name = "SpeedTrack"
speedTrack.Position = UDim2.new(0, 0, 0, 30)
speedTrack.Size = UDim2.new(1, 0, 0, 8)
speedTrack.BackgroundColor3 = Color3.new(1, 1, 1)
speedTrack.BackgroundTransparency = 0.75
speedTrack.BorderSizePixel = 0
speedTrack.Active = true
speedTrack.Parent = speedPanel
Instance.new("UICorner", speedTrack).CornerRadius = UDim.new(1, 0)

local speedFill = Instance.new("Frame")
speedFill.Name = "SpeedFill"
speedFill.BackgroundColor3 = Color3.fromRGB(90, 170, 255)
speedFill.BorderSizePixel = 0
speedFill.Size = UDim2.new(0, 0, 1, 0)
speedFill.Parent = speedTrack
Instance.new("UICorner", speedFill).CornerRadius = UDim.new(1, 0)

local speedHandle = Instance.new("Frame")
speedHandle.Name = "SpeedHandle"
speedHandle.AnchorPoint = Vector2.new(0.5, 0.5)
speedHandle.Position = UDim2.new(0, 0, 0.5, 0)
speedHandle.Size = UDim2.fromOffset(20, 20)
speedHandle.BackgroundColor3 = Color3.new(1, 1, 1)
speedHandle.ZIndex = 2
speedHandle.Parent = speedTrack
Instance.new("UICorner", speedHandle).CornerRadius = UDim.new(1, 0)

-- Initialize the handle/fill to match starting SPEED
do
	local startRatio = (SPEED - MIN_SPEED) / (MAX_SPEED - MIN_SPEED)
	speedHandle.Position = UDim2.new(startRatio, 0, 0.5, 0)
	speedFill.Size = UDim2.new(startRatio, 0, 1, 0)
end

-- ===== DRAGGABLE UI (edit mode) =====
-- Standard "drag GUI" pattern: only active while editMode is true. Preserves
-- each element's existing Scale component so it keeps behaving the same way
-- relative to screen edges/corners, it just moves by the raw pixel delta.
local draggables = {}

local function makeDraggable(obj)
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil

	table.insert(draggables, obj)

	obj.InputBegan:Connect(function(input)
		if not editMode then return end
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragInput = input
			dragStart = input.Position
			startPos = obj.Position

			local conn
			conn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					conn:Disconnect()
				end
			end)
		end
	end)

	obj.InputChanged:Connect(function(input)
		if not editMode then return end
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			obj.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

makeDraggable(toggleBtn)
makeDraggable(upBtn)
makeDraggable(downBtn)
makeDraggable(speedPanel)
makeDraggable(joyZone)

local function setEditMode(on)
	editMode = on
	editBtn.Text = editMode and "Done" or "Edit UI"
	editBtn.BackgroundColor3 = editMode and Color3.fromRGB(90, 170, 255) or Color3.fromRGB(60, 60, 68)

	-- Highlight draggable elements and make the joystick zone visible/grabbable
	joyZoneStroke.Transparency = editMode and 0.3 or 1
	if editMode then
		joyZone.Visible = true
	else
		joyZone.Visible = active
	end

	for _, obj in ipairs(draggables) do
		local stroke = obj:FindFirstChildOfClass("UIStroke")
		if not stroke and obj ~= joyZone then
			stroke = Instance.new("UIStroke")
			stroke.Name = "EditStroke"
			stroke.Color = Color3.fromRGB(90, 170, 255)
			stroke.Thickness = 2
			stroke.Parent = obj
		end
		if stroke and stroke.Name == "EditStroke" then
			stroke.Transparency = editMode and 0.2 or 1
		end
	end
end

editBtn.Activated:Connect(function()
	setEditMode(not editMode)
end)

-- ===== TOGGLE =====
local function toggle()
	if editMode then return end -- don't toggle the drone while repositioning UI
	active = not active
	local char = player.Character

	if active then
		if char and char:FindFirstChild("HumanoidRootPart") then
			pos = char.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
		end
		camera.CameraType = Enum.CameraType.Scriptable
		toggleBtn.Text = "Drone: ON"
	else
		camera.CameraType = Enum.CameraType.Custom
		toggleBtn.Text = "Drone: OFF"
		target = nil
	end

	joyZone.Visible = active
	upBtn.Visible = active
	downBtn.Visible = active
	speedPanel.Visible = active
end

toggleBtn.Activated:Connect(toggle)

-- ===== JOYSTICK (dynamic, spawns where you touch down) =====
local joyDragging = false
local joyTouchObject = nil -- the specific InputObject driving the joystick, for multi-touch safety
local joyCenter = Vector2.new()

local function showJoystickAt(screenPos)
	joyCenter = screenPos
	joyBg.Position = UDim2.fromOffset(screenPos.X, screenPos.Y)
	joyThumb.Position = UDim2.new(0.5, 0, 0.5, 0)
	joyBg.Visible = true
end

local function updateJoystick(screenPos)
	local delta = screenPos - joyCenter
	local dist = math.min(delta.Magnitude, JOY_RADIUS)
	local dir = delta.Magnitude > 0 and delta.Unit or Vector2.new(0, 0)
	local clamped = dir * dist

	joyThumb.Position = UDim2.new(0.5, clamped.X, 0.5, clamped.Y)

	local normalized = clamped / JOY_RADIUS
	if normalized.Magnitude < JOY_DEADZONE then
		joyVector = Vector2.new(0, 0)
	else
		joyVector = normalized
	end
end

local function hideJoystick()
	joyDragging = false
	joyTouchObject = nil
	joyVector = Vector2.new(0, 0)
	joyBg.Visible = false

	local tween = TweenService:Create(joyThumb, TweenInfo.new(0.1), {
		Position = UDim2.new(0.5, 0, 0.5, 0),
	})
	tween:Play()
end

joyZone.InputBegan:Connect(function(input)
	if editMode then return end -- dragging the zone itself, not spawning a joystick
	if joyDragging then return end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		joyDragging = true
		joyTouchObject = input
		showJoystickAt(Vector2.new(input.Position.X, input.Position.Y))
	end
end)

joyZone.InputChanged:Connect(function(input)
	if editMode then return end
	if not joyDragging or input ~= joyTouchObject then return end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
		updateJoystick(Vector2.new(input.Position.X, input.Position.Y))
	end
end)

joyZone.InputEnded:Connect(function(input)
	if input == joyTouchObject then
		hideJoystick()
	end
end)

-- ===== SPEED CONTROL (scroll-style: value only changes as you drag) =====
local speedDragging = false
local speedTouchObject = nil
local speedDragStartX = 0
local speedDragStartRatio = 0

local function applySpeedRatio(ratio)
	ratio = math.clamp(ratio, 0, 1)
	SPEED = MIN_SPEED + (MAX_SPEED - MIN_SPEED) * ratio
	speedHandle.Position = UDim2.new(ratio, 0, 0.5, 0)
	speedFill.Size = UDim2.new(ratio, 0, 1, 0)
	speedLabel.Text = "Speed: " .. math.floor(SPEED + 0.5)
end

local function currentSpeedRatio()
	return (SPEED - MIN_SPEED) / (MAX_SPEED - MIN_SPEED)
end

speedTrack.InputBegan:Connect(function(input)
	if editMode then return end -- let the panel-level drag handle repositioning instead
	if speedDragging then return end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		speedDragging = true
		speedTouchObject = input
		speedDragStartX = input.Position.X
		speedDragStartRatio = currentSpeedRatio()
		-- NOTE: no value change here on purpose - just registers the drag start,
		-- like grabbing a scroll handle. The value only moves once you drag.
	end
end)

speedTrack.InputChanged:Connect(function(input)
	if editMode then return end
	if not speedDragging or input ~= speedTouchObject then return end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
		local trackWidth = speedTrack.AbsoluteSize.X
		local deltaRatio = (input.Position.X - speedDragStartX) / trackWidth
		applySpeedRatio(speedDragStartRatio + deltaRatio)
	end
end)

speedTrack.InputEnded:Connect(function(input)
	if input == speedTouchObject then
		speedDragging = false
		speedTouchObject = nil
	end
end)

-- ===== UP / DOWN BUTTONS =====
upBtn.InputBegan:Connect(function(input)
	if editMode then return end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		verticalDir = 1
	end
end)
upBtn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		verticalDir = 0
	end
end)
downBtn.InputBegan:Connect(function(input)
	if editMode then return end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		verticalDir = -1
	end
end)
downBtn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		verticalDir = 0
	end
end)

-- ===== SCREEN DRAG TO LOOK + TAP TO SPECTATE =====
local lookActive = false
local lookTouchObject = nil
local touchStart = nil
local touchMoved = false

UIS.InputBegan:Connect(function(input, gp)
	if gp or not active or editMode then return end
	if input.UserInputType ~= Enum.UserInputType.Touch then return end
	if input == joyTouchObject then return end -- ignore the finger already driving the joystick
	if input == speedTouchObject then return end -- ignore the finger already dragging the speed slider
	if lookActive then return end -- already tracking a look touch

	lookActive = true
	lookTouchObject = input
	touchStart = input.Position
	touchMoved = false
end)

UIS.InputChanged:Connect(function(input, gp)
	if not active or editMode or not lookActive or input ~= lookTouchObject then return end
	if input.UserInputType ~= Enum.UserInputType.Touch then return end

	if (input.Position - touchStart).Magnitude > 5 then
		touchMoved = true
	end
	yaw = yaw - input.Delta.X * LOOK_SENSITIVITY
	pitch = math.clamp(pitch - input.Delta.Y * LOOK_SENSITIVITY, -1.5, 1.5)
end)

UIS.InputEnded:Connect(function(input)
	if not active or input ~= lookTouchObject then return end

	if not touchMoved then
		local ray = camera:ViewportPointToRay(input.Position.X, input.Position.Y)
		local hit = Workspace:Raycast(ray.Origin, ray.Direction * 1000)
		local newTarget = nil
		if hit and hit.Instance then
			local model = hit.Instance:FindFirstAncestorOfClass("Model")
			if model and model:FindFirstChildOfClass("Humanoid") and model ~= player.Character then
				newTarget = model
			end
		end
		target = newTarget -- tapping empty space (or re-tapping) clears/changes spectate target
	end

	lookActive = false
	lookTouchObject = nil
end)

-- ===== MAIN LOOP =====
RunService.RenderStepped:Connect(function(dt)
	if not active then return end

	if target and target.Parent then
		local part = target:FindFirstChild("HumanoidRootPart")
		if part then
			local desired = CFrame.new(part.Position + Vector3.new(0, 5, 10), part.Position)
			camera.CFrame = camera.CFrame:Lerp(desired, 0.1)
			pos = camera.CFrame
		end
		return
	end

	local rot = CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)
	local move = Vector3.new(joyVector.X, 0, joyVector.Y) + Vector3.new(0, verticalDir, 0)
	if move.Magnitude > 1 then
		move = move.Unit
	end

	pos = CFrame.new(pos.Position + rot:VectorToWorldSpace(move) * SPEED * dt) * rot
	camera.CFrame = pos
end)
