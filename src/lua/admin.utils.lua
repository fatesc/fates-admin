-- todo: rewrite all of misrepresentings code.

local Utils = {}

Utils.Tween = function(Object, Style, Direction, Time, Goal)
    local TInfo = TweenInfo.new(Time, Enum.EasingStyle[Style], Enum.EasingDirection[Direction])
    local Tween = TweenService:Create(Object, TInfo, Goal)

    Tween:Play()

    return Tween
end

Utils.MultColor3 = function(Color, Delta)
    return Color3.new(math.clamp(Color.R * Delta, 0, 1), math.clamp(Color.G * Delta, 0, 1), math.clamp(Color.B * Delta, 0, 1))
end

Utils.Click = function(Object, Goal) -- Utils.Click(Object, "BackgroundColor3")
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

Utils.Blink = function(Object, Goal, Color1, Color2) -- Utils.Click(Object, "BackgroundColor3", NormalColor, OtherColor)
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

Utils.Hover = function(Object, Goal)
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

Utils.Draggable = function(Ui, DragUi)
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
        TweenService:Create(Ui, TweenInfo.new(0.25), {Position = Position}):Play();
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

Utils.SmoothScroll = function(content, SmoothingFactor) -- by Elttob
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

Utils.TweenAllTransToObject = function(Object, Time, BeforeObject) -- max transparency is max object transparency, swutched args bc easier command
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

Utils.SetAllTrans = function(Object)
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

Utils.TweenAllTrans = function(Object, Time)
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

Utils.Notify = function(Caller, Title, Message, Time)
    if (not Caller or Caller == LocalPlayer) then
        local Notification = UI.Notification
        local NotificationBar = UI.NotificationBar

        local Clone = Notification:Clone()

        local function TweenDestroy()
            if (Utils and Clone) then -- fix error when the script is killed and there is still notifications out
                local Tween = Utils.TweenAllTrans(Clone, .25)

                Tween.Completed:Wait()
                Clone:Destroy();
            end
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

        return Clone
    else
        local ChatRemote = ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
        ChatRemote:FireServer(("/w %s [FA] %s: %s"):format(Caller.Name, Title, Message), "All");
    end
end

Utils.MatchSearch = function(String1, String2) -- Utils.MatchSearch("pog", "poggers") - true; Utils.MatchSearch("poz", "poggers") - false
    return String1 == string.sub(String2, 1, #String1)
end

Utils.StringFind = function(Table, String)
    for _, v in ipairs(Table) do
        if (Utils.MatchSearch(String, v)) then
            return v
        end
    end
end

Utils.GetPlayerArgs = function(Arg)
    Arg = Arg:lower();
    local SpecialCases = {"all", "others", "random", "me", "nearest", "farthest"}
    if (Utils.StringFind(SpecialCases, Arg)) then
        return Utils.StringFind(SpecialCases, Arg);
    end

    local CurrentPlayers = Players:GetPlayers();
    for i, v in next, CurrentPlayers do
        if (v.Name ~= v.DisplayName and Utils.MatchSearch(Arg, v.DisplayName:lower())) then
            return v.DisplayName:lower();
        end
        if (Utils.MatchSearch(Arg, v.Name:lower())) then
            return v.Name:lower();
        end
    end
end

Utils.ToolTip = function(Object, Message)
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

    if (LocalPlayer) then
        LocalPlayer:GetMouse().Move:Connect(function()
            if (Clone) then
                Clone.Position = UDim2.fromOffset(Mouse.X + 10, Mouse.Y + 10)
            end
        end)
    else
        delay(3, function()
            LocalPlayer = Players.LocalPlayer
            Mouse = LocalPlayer:GetMouse()
            Mouse.Move:Connect(function()
                if (Clone) then
                    Clone.Position = UDim2.fromOffset(Mouse.X + 10, Mouse.Y + 10)
                end
            end)
        end)
    end
end

Utils.ClearAllObjects = function(Object)
    for _, v in ipairs(Object:GetChildren()) do
        if (not v:IsA("UIListLayout")) then
            v:Destroy()
        end
    end
end

Utils.Rainbow = function(TextObject)
    local Text = TextObject.Text
    local Frequency = 1 -- determines how quickly it repeats
    local TotalCharacters = 0
    local Strings = {}

    TextObject.RichText = true

    for Character in string.gmatch(Text, ".") do
        if string.match(Character, "%s") then
            table.insert(Strings, Character)
        else
            TotalCharacters = TotalCharacters + 1
            table.insert(Strings, {'<font color="rgb(%i, %i, %i)">' .. Character .. '</font>'})
        end
    end

    pcall(function() -- no idea why this shit is erroring
        local Connection = AddConnection(RunService.Heartbeat:Connect(function()
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
        end));
        delay(150, function()
            Connection:Disconnect();
        end)
    end)
end

Utils.Locate2 = function(Player, Color)
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

            local ColorLabel = Instance.new("TextLabel", Billboard);
            ColorLabel.Name = HttpService:GenerateGUID();
            ColorLabel.TextStrokeTransparency = 0.6
            ColorLabel.BackgroundTransparency = 1
            ColorLabel.TextColor3 = Color3.new(152, 152, 152);
            ColorLabel.Size = UDim2.new(0, 200, 0, 50);
            ColorLabel.TextScaled = false
            ColorLabel.TextSize = 8

            local EspLoop = RunService.Heartbeat:Connect(function()
                local Humanoid = GetCharacter(Player) and GetHumanoid(Player);
                local HumanoidRootPart = GetCharacter(Player) and GetRoot(Player);
                if (Humanoid and HumanoidRootPart) then
                    local Distance = math.floor((Workspace.CurrentCamera.CFrame.p - HumanoidRootPart.CFrame.p).Magnitude)
                    ColorLabel.Text = ("\n \n \n [%s] [%s/%s]"):format(Distance, math.floor(Humanoid.Health), math.floor(Humanoid.MaxHealth))
                else
                    EspLoop:Disconnect();
                    Billboard:Destroy();
                end
            end)
            AddConnection(EspLoop);
            AddConnection(Players.PlayerRemoving:Connect(function(Plr)
                if (Plr == Player) then
                    Billboard:Destroy();
                end
            end))
        end
    end)()

    return function()
        Billboard:Destroy();
    end
end

Utils.Vector3toVector2 = function(Vector)
    local Tuple = Camera:WorldToViewportPoint(Vector)
    return Vector2.new(Tuple.X, Tuple.Y);
end

local Locating = {}
local Drawings = {}

Utils.Locate = function(Plr, Color, OutlineColor)
    if (not Drawing) then
        return Utils.Locate2(Plr, Color);
    end
    local Head = GetCharacter(Plr) and GetCharacter(Plr).Head
    if (not Head) then
        return
    end

    local Text = Drawing.new("Text");
    Drawings[#Drawings + 1] = Text

    Text.Position = Utils.Vector3toVector2(Head.Position) + Vector2.new(0, -100, 0);
    Text.Color = Color or Color3.fromRGB(255, 255, 255);
    Text.OutlineColor = OutlineColor or Color3.new();
    Text.Text = ("%s\n[%s] [%s/%s]"):format(Plr.Name, math.floor(GetMagnitude(Plr)), math.floor(GetHumanoid(Plr).Health), math.floor(GetHumanoid(Plr).MaxHealth));
    Text.Size = 16
    Text.Transparency = 1
    Text.Center = true
    Text.Outline = true
    Text.Visible = true
    Locating[Text] = Plr
    return function()
        Text:Remove();
        Locating[Text] = nil
    end
end

local UpdatingLocations = false
Utils.UpdateLocations = function(Toggle)
    if (not UpdatingLocations) then
        UpdatingLocations = AddConnection(RunService.RenderStepped:Connect(function()
            for i, v in next, Locating do
                if (GetCharacter(v) and GetCharacter(v).Head) then
                    local Tuple, Viewable = Camera:WorldToViewportPoint(GetCharacter(v).Head.Position);
                    if (Viewable) then
                        i.Visible = true
                        i.Position = Utils.Vector3toVector2(GetCharacter(v).Head.Position) + Vector2.new(0, -100, 0);           
                        i.Text = ("%s\n[%s] [%s/%s]"):format(v.Name, math.floor(GetMagnitude(v)), math.floor(GetHumanoid(v).Health), math.floor(GetHumanoid(v).MaxHealth));    
                        continue
                    end
                end
                i.Visible = false
            end
        end))
    end
end

Utils.CheckTag = function(Plr)
    if (not Plr or not Plr:IsA("Player")) then
        return nil
    end
    local UserId = tostring(Plr.UserId);
    local Tag = PlayerTags[UserId:gsub(".", function(x)
        return x:byte();
    end)]
    return Tag or nil
end

Utils.AddTag = function(Tag)
    if (not Tag) then
        return
    end
    local PlrCharacter = GetCharacter(Tag.Player)
    if (not PlrCharacter) then
        return
    end
    local Billboard = Instance.new("BillboardGui");
    Billboard.Parent = UI
    Billboard.Name = HttpService:GenerateGUID();
    Billboard.AlwaysOnTop = true
    Billboard.Adornee = PlrCharacter.Head or nil
    Billboard.Enabled = PlrCharacter.Head and true or false
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
    if (Tag.Colour) then
        local TColour = Tag.Colour
        TextLabel.TextColor3 = Color3.fromRGB(TColour[1], TColour[2], TColour[3]);
    end

    local Added = Tag.Player.CharacterAdded:Connect(function()
        Billboard.Adornee = Tag.Player.Character:WaitForChild("Head");
    end)

    AddConnection(Added)

    AddConnection(Players.PlayerRemoving:Connect(function(plr)
        if (plr == Tag.Player) then
            Added:Disconnect();
            Billboard:Destroy();
        end
    end))
end

Utils.TextFont = function(Text, RGB)
    RGB = table.concat(RGB, ",")
    local New = {}
    Text:gsub(".", function(x)
        New[#New + 1] = x
    end)
    return table.concat(table.map(New, function(i, letter)
        return ('<font color="rgb(%s)">%s</font>'):format(RGB, letter)
    end)) .. " "
end

local Tracing = {}
Utils.Trace = function(Player, Color)
    if (not Drawing) then
        return
    end
    local Head = GetCharacter(Player) and GetCharacter(Player).Head
    if (not Head) then
        return
    end
    local Camera = Workspace.Camera

    local Tracer = Drawing.new("Line");
    Drawings[#Drawings + 1] = Tracer

    local Tuple = Camera:WorldToViewportPoint(Head.Position);
    Tracer.To = Vector2.new(Tuple.X, Tuple.Y);
    Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y);
    Tracer.Color = Color or Color3.fromRGB(255, 255, 255);
    Tracer.Thickness = .1
    Tracer.Transparency = 1
    Tracer.Visible = true
    Tracing[Player] = Tracer
    return function()
        Tracer:Remove();
        Tracing[Player] = nil
    end
end

local UpdatingTracers = false
Utils.UpdateTracers = function()
    if (not Updating) then
        UpdatingTracers = AddConnection(RunService.RenderStepped:Connect(function()
            for i, Tracer in next, Tracing do
                local Head = GetCharacter(i) and GetCharacter(i).Head
                if (not Head) then
                    continue
                end
                local Tuple, Viewable = Workspace.Camera:WorldToViewportPoint(Head.Position);
                if (Viewable) then
                    Tracer.Visible = true
                    Tracer.To = Vector2.new(Tuple.X, Tuple.Y);
                else
                    Tracer.Visible = false
                end
            end
        end))
    end
end

Utils.DestroyTracers = function()
    for i, Tracer in next, Tracers do
        Tracer:Remove();
    end
    if (UpdatingTracers) then
        UpdatingTracers:Disconnect();
    end
end

Utils.DestroyDrawings = function()
    for i, Drawing in next, Drawings do
        Drawing:Remove();
    end
    if (UpdatingTracers) then
        UpdatingTracers:Disconnect();
    end
    if (UpdatingLocations) then
        UpdatingLocations:Disconnect();
    end
end