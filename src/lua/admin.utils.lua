Utils = {}

function Utils.Tween(Object, Style, Direction, Time, Goal)
    local TInfo = TweenInfo.new(Time, Enum.EasingStyle[Style], Enum.EasingDirection[Direction])
    local Tween = TweenService:Create(Object, TInfo, Goal)

    Tween:Play()

    return Tween
end

function Utils.MultColor3(Color, Delta)
    return Color3.new(math.clamp(Color.R * Delta, 0, 1), math.clamp(Color.G * Delta, 0, 1), math.clamp(Color.B * Delta, 0, 1))
end

function Utils.Click(Object, Goal) -- Utils.Click(Object, "BackgroundColor3")
    local Hover = {
        [Goal] = Utils.MultColor3(Object[Goal], 0.9)
    }

    local Press = {
        [Goal] = Utils.MultColor3(Object[Goal], 1.2)
    }

    local Origin = {
        [Goal] = Object[Goal]
    }

    Connections["ObjectMouseEnter" .. #Connections] = Object.MouseEnter:Connect(function()
        Utils.Tween(Object, "Sine", "Out", .5, Hover)
    end)

    Connections["ObjectMouseLeave" .. #Connections] = Object.MouseLeave:Connect(function()
        Utils.Tween(Object, "Sine", "Out", .5, Origin)
    end)

    Connections["ObjectMouseButton1Down" .. #Connections] = Object.MouseButton1Down:Connect(function()
        Utils.Tween(Object, "Sine", "Out", .3, Press)
    end)

    Connections["ObjectMouseButton1Up" .. #Connections] = Object.MouseButton1Up:Connect(function()
        Utils.Tween(Object, "Sine", "Out", .4, Hover)
    end)
end

function Utils.Blink(Object, Goal, Color1, Color2) -- Utils.Click(Object, "BackgroundColor3", NormalColor, OtherColor)
    local Normal = {
        [Goal] = Color1
    }

    local Blink = {
        [Goal] = Color2
    }

    local Tween = Utils.Tween(Object, "Sine", "Out", .5, Blink)
    Tween.Completed:Wait()

    local Tween = Utils.Tween(Object, "Sine", "Out", .5, Normal)
    Tween.Completed:Wait()
end

function Utils.Hover(Object, Goal)
    local Hover = {
        [Goal] = Utils.MultColor3(Object[Goal], 0.9)
    }

    local Origin = {
        [Goal] = Object[Goal]
    }

    Connections["ObjectMouseEnter" .. #Connections] = Object.MouseEnter:Connect(function()
        Utils.Tween(Object, "Sine", "Out", .5, Hover)
    end)

    Connections["ObjectMouseLeave" .. #Connections] = Object.MouseLeave:Connect(function()
        Utils.Tween(Object, "Sine", "Out", .5, Origin)
    end)
end

function Utils.Draggable(Ui, DragUi)
    local DragSpeed = 0
    local StartPos
    local DragToggle, DragInput, DragStart, DragPos

    if not DragUi then DragUi = Ui end

    local function UpdateInput(Input)
        local Delta = Input.Position - DragStart
        local Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)

        Utils.Tween(Ui, "Linear", "Out", .25, {
            Position = Position
        })
        --TweenService:Create(Ui, TweenInfo.new(0.25), {Position = Position}):Play()
    end

    Connections["UIInputBegan" .. #Connections] = Ui.InputBegan:Connect(function(Input)
        if ((Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and UserInputService:GetFocusedTextBox() == nil) then
            DragToggle = true
            DragStart = Input.Position
            StartPos = Ui.Position

            Connections["InputChanged" .. #Connections] = Input.Changed:Connect(function()
                if (Input.UserInputState == Enum.UserInputState.End) then
                    DragToggle = false
                end
            end)
        end
    end)

    Connections["UiInputChanged" .. #Connections] = Ui.InputChanged:Connect(function(Input)
        if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            DragInput = Input
        end
    end)

    Connections["UserInputServiceInputChanged" .. #Connections] = UserInputService.InputChanged:Connect(function(Input)
        if (Input == DragInput and DragToggle) then
            UpdateInput(Input)
        end
    end)
end

function Utils.SmoothScroll(content, SmoothingFactor) -- by Elttob
    -- get the 'content' scrolling frame, aka the scrolling frame with all the content inside
    -- if smoothing is enabled, disable scrolling
    content.ScrollingEnabled = false

    -- create the 'input' scrolling frame, aka the scrolling frame which receives user input
    -- if smoothing is enabled, enable scrolling
    local input = content:Clone()

    input:ClearAllChildren()
    input.BackgroundTransparency = 1
    input.ScrollBarImageTransparency = 1
    input.ZIndex = content.ZIndex + 1
    input.Name = "_smoothinputframe"
    input.ScrollingEnabled = true
    input.Parent = content.Parent

    -- keep input frame in sync with content frame
    local function syncProperty(prop)
        Connections["content" .. #Connections] = content:GetPropertyChangedSignal(prop):Connect(function()
            if prop == "ZIndex" then
                -- keep the input frame on top!
                input[prop] = content[prop] + 1
            else
                input[prop] = content[prop]
            end
        end)
    end

    syncProperty "CanvasSize"
    syncProperty "Position"
    syncProperty "Rotation"
    syncProperty "ScrollingDirection"
    syncProperty "ScrollBarThickness"
    syncProperty "BorderSizePixel"
    syncProperty "ElasticBehavior"
    syncProperty "SizeConstraint"
    syncProperty "ZIndex"
    syncProperty "BorderColor3"
    syncProperty "Size"
    syncProperty "AnchorPoint"
    syncProperty "Visible"

    -- create a render stepped connection to interpolate the content frame position to the input frame position
    local smoothConnection = RunService.RenderStepped:Connect(function()
        local a = content.CanvasPosition
        local b = input.CanvasPosition
        local c = SmoothingFactor
        local d = (b - a) * c + a

        content.CanvasPosition = d
    end)

    Connections["smoothConnection" .. #Connections] = smoothConnection

    -- destroy everything when the frame is destroyed
    Connections["contentAncestryChanged" .. #Connections] = content.AncestryChanged:Connect(function()
        if content.Parent == nil then
            input:Destroy()
            smoothConnection:Disconnect()
        end
    end)
end

function Utils.TweenAllTransToObject(Object, Time, BeforeObject) -- max transparency is max object transparency, swutched args bc easier command
    local Descendants = Object:GetDescendants()
    local OldDescentants = BeforeObject:GetDescendants()
    local Tween -- to use to wait

    Tween = Utils.Tween(Object, "Sine", "Out", Time, {
        BackgroundTransparency = BeforeObject.BackgroundTransparency
    })

    for i, v in next, Descendants do
        local IsText = v:IsA("TextBox") or v:IsA("TextLabel") or v:IsA("TextButton")
        local IsImage = v:IsA("ImageLabel") or v:IsA("ImageButton")
        local IsScrollingFrame = v:IsA("ScrollingFrame")

        if (not v:IsA("UIListLayout")) then
            if (IsText) then
                Utils.Tween(v, "Sine", "Out", Time, {
                    TextTransparency = OldDescentants[i].TextTransparency,
                    TextStrokeTransparency = OldDescentants[i].TextStrokeTransparency,
                    BackgroundTransparency = OldDescentants[i].BackgroundTransparency
                })
            elseif (IsImage) then
                Utils.Tween(v, "Sine", "Out", Time, {
                    ImageTransparency = OldDescentants[i].ImageTransparency,
                    BackgroundTransparency = OldDescentants[i].BackgroundTransparency
                })
            elseif (IsScrollingFrame) then
                Utils.Tween(v, "Sine", "Out", Time, {
                    ScrollBarImageTransparency = OldDescentants[i].ScrollBarImageTransparency,
                    BackgroundTransparency = OldDescentants[i].BackgroundTransparency
                })
            else
                Utils.Tween(v, "Sine", "Out", Time, {
                    BackgroundTransparency = OldDescentants[i].BackgroundTransparency
                })
            end
        end
    end

    return Tween
end

function Utils.SetAllTrans(Object)
    Object.BackgroundTransparency = 1

    for _, v in ipairs(Object:GetDescendants()) do
        local IsText = v:IsA("TextBox") or v:IsA("TextLabel") or v:IsA("TextButton")
        local IsImage = v:IsA("ImageLabel") or v:IsA("ImageButton")
        local IsScrollingFrame = v:IsA("ScrollingFrame")

        if (not v:IsA("UIListLayout")) then	
            v.BackgroundTransparency = 1

            if (IsText) then
                v.TextTransparency = 1
            elseif (IsImage) then
                v.ImageTransparency = 1
            elseif (IsScrollingFrame) then
                v.ScrollBarImageTransparency = 1
            end
        end
    end
end

function Utils.TweenAllTrans(Object, Time)
    local Tween -- to use to wait

    Tween = Utils.Tween(Object, "Sine", "Out", Time, {
        BackgroundTransparency = 1
    })

    for _, v in ipairs(Object:GetDescendants()) do
        local IsText = v:IsA("TextBox") or v:IsA("TextLabel") or v:IsA("TextButton")
        local IsImage = v:IsA("ImageLabel") or v:IsA("ImageButton")
        local IsScrollingFrame = v:IsA("ScrollingFrame")

        if (not v:IsA("UIListLayout")) then
            if (IsText) then
                Utils.Tween(v, "Sine", "Out", Time, {
                    TextTransparency = 1,
                    BackgroundTransparency = 1
                })
            elseif (IsImage) then
                Utils.Tween(v, "Sine", "Out", Time, {
                    ImageTransparency = 1,
                    BackgroundTransparency = 1
                })
            elseif (IsScrollingFrame) then
                Utils.Tween(v, "Sine", "Out", Time, {
                    ScrollBarImageTransparency = 1,
                    BackgroundTransparency = 1
                })
            else
                Utils.Tween(v, "Sine", "Out", Time, {
                    BackgroundTransparency = 1
                })
            end
        end
    end

    return Tween
end

function Utils.Notify(Caller, Title, Message, Time)
    if (not Caller or Caller == LocalPlayer) then
        local Notification = UI.Notification
        local NotificationBar = UI.NotificationBar
    
        local Clone = Notification:Clone()
    
        local function TweenDestroy()
            local Tween = Utils.TweenAllTrans(Clone, .25)
    
            Tween.Completed:Wait()
            Clone:Destroy() -- tween out then destroy
        end
    
        Clone.Message.Text = Message
        Clone.Title.Text = Title or "Notification"
        Utils.SetAllTrans(Clone)
        Utils.Click(Clone.Close, "TextColor3")
        Clone.Visible = true -- tween
    
        if (Message:len() >= 35) then
            Clone.AutomaticSize = Enum.AutomaticSize.Y
            Clone.Message.AutomaticSize = Enum.AutomaticSize.Y
            Clone.Message.RichText = true
            Clone.Message.TextScaled = false
            Clone.Message.TextYAlignment = Enum.TextYAlignment.Top
            Clone.DropShadow.AutomaticSize = Enum.AutomaticSize.Y
        end
    
        Clone.Parent = NotificationBar
    
        coroutine.wrap(function()
            local Tween = Utils.TweenAllTransToObject(Clone, .5, Notification)
    
            Tween.Completed:Wait();
            wait(Time or 5);
    
            if (Clone) then
                TweenDestroy();
            end
        end)()
    
        Connections["CloneClose" .. #Connections] = Clone.Close.MouseButton1Click:Connect(function()
            TweenDestroy()
        end)
    else
        local ChatRemote = ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
        ChatRemote:FireServer(("/w %s [FA] %s: %s"):format(Caller.Name, Title, Message), "All");
    end
end

function Utils.MatchSearch(String1, String2) -- Utils.MatchSearch("pog", "poggers") - true; Utils.MatchSearch("poz", "poggers") - false
    return String1 == string.sub(String2, 1, #String1)
end

function Utils.StringFind(Table, String)
    for _, v in ipairs(Table) do
        if (Utils.MatchSearch(String, v)) then
            return v
        end
    end
end

function Utils.GetPlayerArgs(Arg)
    Arg = Arg:lower()
    local SpecialCases = {"all", "others", "claimed", "random", "me", "nearest", "farthest"}

    return Utils.StringFind(SpecialCases, Arg) or (function()
        for _, v in ipairs(Players:GetPlayers()) do
            local Name = string.lower(v.Name)

            if (Utils.MatchSearch(Arg, Name)) then
                return Name
            end
        end
    end)()	
end

function Utils.ToolTip(Object, Message)
    local Clone

    Object.MouseEnter:Connect(function()
        if (Object.BackgroundTransparency < 1 and not Clone) then
            local TextSize = TextService:GetTextSize(Message, 12, Enum.Font.Gotham, Vector2.new(200, math.huge)).Y > 24 and true or false

            Clone = UI.ToolTip:Clone()
            Clone.Text = Message
            Clone.TextScaled = TextSize
            Clone.Visible = true
            Clone.Parent = UI
        end
    end)

    Object.MouseLeave:Connect(function()
        if (Clone) then
            Clone:Destroy()
            Clone = nil
        end
    end)

    game.Players.LocalPlayer:GetMouse().Move:Connect(function()
        if (Clone) then
            Clone.Position = UDim2.fromOffset(Mouse.X + 10, Mouse.Y + 10)
        end
    end)
end

function Utils.ClearAllObjects(Object)
    for _, v in ipairs(Object:GetChildren()) do
        if (not v:IsA("UIListLayout")) then
            v:Destroy()
        end
    end
end

function Utils.Rainbow(TextObject)
	local Text = TextObject.Text
	local Frequency = 1 -- determines how quickly it repeats
	local TotalCharacters = 0
	local Strings = {}
	local Destroyed = false

	TextObject.RichText = true

	for Character in string.gmatch(Text, ".") do
		if string.match(Character, "%s") then
			table.insert(Strings, Character)
		else
			TotalCharacters = TotalCharacters + 1
			table.insert(Strings, {'<font color="rgb(%i, %i, %i)">' .. Character .. '</font>'})
		end
	end

	coroutine.wrap(function()
		while RunService.Heartbeat:Wait() do
            if (not getgenv().F_A) then break end
			if (Destroyed) then break end

			local String = ""
			local Counter = TotalCharacters

			for _, CharacterTable in ipairs(Strings) do
				local Concat = "" 

				if (type(CharacterTable) == "table") then
					Counter = Counter - 1
					local Color = Color3.fromHSV(-math.atan(math.tan((tick() + Counter/math.pi)/Frequency))/math.pi + 0.5, 1, 1)

					CharacterTable = string.format(CharacterTable[1], math.floor(Color.R * 255), math.floor(Color.G * 255), math.floor(Color.B * 255))
				end

				String = String .. CharacterTable
			end

			TextObject.Text = String .. " " -- roblox bug w (textobjects in billboardguis wont render richtext without space)
		end
	end)()

    RobloxScroller.DescendantRemoving:Connect(function(v)
		if (v == TextObject) then
			Destroyed = true
		end
	end)
end

function Utils.Locate(Player, Color)
    local Billboard = Instance.new("BillboardGui");
    coroutine.wrap(function()
        if (GetCharacter(Player)) then
            Billboard.Parent = UI
            Billboard.Name = HttpService:GenerateGUID();
            Billboard.AlwaysOnTop = true
            Billboard.Adornee = Player.Character.Head
            Billboard.Size = UDim2.new(0, 200, 0, 50)
            Billboard.StudsOffset = Vector3.new(0, 4, 0);

            local TextLabel = Instance.new("TextLabel", Billboard);
            TextLabel.Name = HttpService:GenerateGUID();
            TextLabel.TextStrokeTransparency = 0.6
            TextLabel.BackgroundTransparency = 1
            TextLabel.TextColor3 = Color3.new(0, 255, 0);
            TextLabel.Size = UDim2.new(0, 200, 0, 50);
            TextLabel.TextScaled = false
            TextLabel.TextSize = 10
            TextLabel.Text = Player.Name

            local Color = Instance.new("TextLabel", Billboard);
            Color.Name = HttpService:GenerateGUID();
            Color.TextStrokeTransparency = 0.6
            Color.BackgroundTransparency = 1
            Color.TextColor3 = Color3.new(152, 152, 152);
            Color.Size = UDim2.new(0, 200, 0, 50);
            Color.TextScaled = false
            Color.TextSize = 8

            local EspLoop = RunService.Heartbeat:Connect(function()
                local Humanoid = GetCharacter(Player) and GetHumanoid(Player);
                local HumanoidRootPart = GetCharacter(Player) and GetRoot(Player);
                if (Humanoid and HumanoidRootPart) then
                    local Distance = math.floor((Workspace.CurrentCamera.CFrame.p - HumanoidRootPart.CFrame.p).Magnitude)
                    Color.Text = ("\n \n \n [%s] [%s/%s]"):format(Distance, math.floor(Humanoid.Health), math.floor(Humanoid.MaxHealth))
                else
                    EspLoop:Disconnect();
                    Billboard:Destroy();
                end
            end)
            AddConnection(EspLoop);
        end
    end)()

    return Billboard
end

function Utils.AddTag(Tag)
    local PlrCharacter = GetCharacter(Tag.Player)
    if (not PlrCharacter) then
        return
    end
    local Billboard = Instance.new("BillboardGui");
    Billboard.Parent = UI
    Billboard.Name = HttpService:GenerateGUID();
    Billboard.AlwaysOnTop = true
    Billboard.Adornee = PlrCharacter.Head
    Billboard.Size = UDim2.new(0, 200, 0, 50)
    Billboard.StudsOffset = Vector3.new(0, 4, 0);

    local TextLabel = Instance.new("TextLabel", Billboard);
    TextLabel.Name = HttpService:GenerateGUID();
    TextLabel.TextStrokeTransparency = 0.6
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextColor3 = Color3.new(0, 255, 0);
    TextLabel.Size = UDim2.new(0, 200, 0, 50);
    TextLabel.TextScaled = false
    TextLabel.TextSize = 15
    TextLabel.Text = ("%s (%s)"):format(Tag.Name, Tag.Tag);

    if (Tag.Rainbow) then
        Utils.Rainbow(TextLabel)
    end

    Tag.Player.CharacterAdded:Connect(function()
        Billboard.Adornee = Tag.Player.Character:WaitForChild("Head");
    end)
end