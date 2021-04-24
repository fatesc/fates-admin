---@diagnostic disable: undefined-field
Debug = true

if (not game:IsLoaded()) then
    print("fates admin: waiting for game to load...");
    repeat wait() until game:IsLoaded();
end

if (getgenv().F_A and getgenv().F_A.Loaded) then
    return getgenv().F_A.Utils.Notify(nil, "Loaded", "fates admin is already loaded... use 'killscript' to kill", nil);
end

if (setreadonly) then
    setreadonly(string, false);

    ---Returns true if the sequence of elements of searchString converted to a String is the same as the corresponding elements of this object (converted to a String) starting at position. Otherwise returns fals
    ---@param searchString string
    ---@param rawPos number
    ---@return string
    string.startsWith = function(str, searchString, rawPos)
        local pos = rawPos and (rawPos > 0 and rawPos or 0) or 0
        return searchString == "" and true or string.sub(str, pos, pos + #searchString) == searchString
    end

    ---trims the string
    ---@param str any
    ---@return string
    string.trim = function(str)
        return str:gsub("^%s*(.-)%s*$", "%1");
    end

    setreadonly(table, false);

    ---The table.tbl_concat() method concatenates the string arguments to the calling string and returns a new string.
    ---@return table
    table.tbl_concat = function(...)
        local new = {}
        for i, v in next, {...} do
            for i2, v2 in next, v do
                table.insert(new, i, v2);
            end
        end
        return new
    end
    ---The string.indexOf() method returns the index within the calling String object of the first occurrence of the specified value, starting the search at fromIndex. Returns -1 if the value is not found.
    ---@param tbl table
    ---@param val any
    ---@return any
    table.indexOf = function(tbl, val)
        if (type(tbl) == 'table') then
            for i, v in next, tbl do
                if (v == val) then
                    return i
                end
            end
        end
    end

    ---The table.forEach() method executes a provided function once for each array element.
    ---@param tbl table
    ---@param ret function
    table.forEach = function(tbl, ret)
        for i, v in next, tbl do
            ret(i,v);
        end
    end

    ---The table.filter() method creates a new array with all elements that pass the test implemented by the provided function.
    ---@param tbl table
    ---@param ret function
    ---@return table
    table.filter = function(tbl, ret)
        if (type(tbl) == 'table') then
            local new = {}
            for i, v in next, tbl do
                if (ret(i,v)) then
                    table.insert(new, #new + 1, v);     
                end
            end
            return new
        end
    end

    ---The table.map() method creates a new array populated with the results of calling a provided function on every element in the calling array
    ---@param tbl table
    ---@param ret function
    ---@return table
    table.map = function(tbl, ret)
        if (type(tbl) == 'table') then
            local new = {}
            for i, v in next, tbl do
                table.insert(new, #new + 1, ret(i,v));
            end
            return new
        end
    end

    ---deepsearches a table with the callback on each value
    ---@param tbl table
    ---@param ret function
    table.deepsearch = function(tbl, ret)
        if (type(tbl) == 'table') then
            for i, v in next, tbl do
                if (type(v) == 'table') then
                    table.deepsearch(v, ret);
                end
                ret(i,v);
            end
        end
    end

    ---The flat() method creates a new array with all sub-array elements concatenated into it recursively up to the specified depth
    ---@param tbl table
    ---@return table
    table.flat = function(tbl)
        if (type(tbl) == 'table') then
            local new = {}
            table.deepsearch(tbl, function(i, v)
                if (type(v) ~= 'table') then
                    new[#new + 1] = v
                end
            end)
            return new
        end
    end

    ---The flatMap() method returns a new array formed by applying a given callback function to each element of the array, and then flattening the result by one level. It is identical to a map() followed by a flat() of depth 1, but slightly more efficient than calling those two methods separately.
    ---@param tbl table
    ---@param ret function
    ---@return table
    table.flatMap = function(tbl, ret)
        if (type(tbl) == 'table') then
            local new = table.flat(table.map(tbl, ret));
            return new           
        end
    end

    ---The table.shift() method removes the first element from an array and returns that removed element. This method changes the length of the array.
    ---@param tbl any
    table.shift = function(tbl)
        if (type(tbl) == 'table') then
            local firstVal = tbl[1]
            tbl = table.pack(table.unpack(tbl, 2, #tbl));
            tbl.n = nil
            return tbl
        end
    end
end

-- local OldEnv, Mt = getfenv() or function()
--     return _ENV
-- end, {
--     __index = function(self, key)
--         return table[key]
--     end
-- }
-- local NewEnv = setmetatable({}, {
--     __index = function(self, key)
--         return OldEnv[key]
--     end,
--     __newindex = function(self, key, val)
--         if (type(val) == 'table') then
--             setmetatable(val, Mt);
--         end
--         OldEnv[key] = val
--         return val
--     end
-- });
-- if (_ENV) then
--     _ENV = NewEnv
-- else
--     setfenv(1, NewEnv);
-- end

---@type number
local start = start or tick() or os.clock();

Workspace = game:GetService("Workspace");
RunService = game:GetService("RunService");
Players = game:GetService("Players");
ReplicatedStorage = game:GetService("ReplicatedStorage");
StarterPlayer = game:GetService("StarterPlayer");
StarterPack = game:GetService("StarterPack");
StarterGui = game:GetService("StarterGui");
TeleportService = game:GetService("TeleportService");
CoreGui = game:GetService("CoreGui");
TweenService = game:GetService("TweenService");
UserInputService = game:GetService("UserInputService");
HttpService = game:GetService("HttpService");
TextService = game:GetService("TextService");
MarketplaceService = game:GetService("MarketplaceService")
Chat = game:GetService("Chat");
SoundService = game:GetService("SoundService");
Lighting = game:GetService("Lighting");

LocalPlayer = Players.LocalPlayer
Mouse = LocalPlayer:GetMouse();
PlayerGui = LocalPlayer.PlayerGui
---gets a players character if none arguments passed it will return your character
---@param Plr table
---@return any
GetCharacter = function(Plr)
    return Plr and Plr.Character or LocalPlayer.Character
end
---gets a players root if none arguments passed it will return your root
---@param Plr any
---@return any
GetRoot = function(Plr)
    return Plr and GetCharacter(Plr):FindFirstChild("HumanoidRootPart") or GetCharacter():FindFirstChild("HumanoidRootPart");
end
---gets a players humanoid if none arguments passed it will return your humanoid
---@param Plr any
---@return any
GetHumanoid = function(Plr)
    return Plr and GetCharacter(Plr):FindFirstChildWhichIsA("Humanoid") or GetCharacter():FindFirstChildWhichIsA("Humanoid");
end

---comment
---@param Plr any
---@return any
GetMagnitude = function(Plr)
    return Plr and (GetRoot(Plr).Position - GetRoot().Position).magnitude or math.huge
end

local Settings = {
    Prefix = "!",
    CommandBarPrefix = "Semicolon"
}

local WriteConfig = function(Destroy)
    local JSON = HttpService:JSONEncode(Settings);
    if (isfolder("fates-admin") and Destroy) then
        delfolder("fates-admin");
        writefile("fates-admin/config.json", JSON);
    else
        makefolder("fates-admin");
        makefolder("fates-admin/plugins");
        makefolder("fates-admin/chatlogs");
        writefile("fates-admin/config.json", JSON);
    end
end

local GetConfig = function()
    if (isfolder("fates-admin")) then
        return HttpService:JSONDecode(readfile("fates-admin/config.json"));
    else
        WriteConfig();
        return HttpService:JSONDecode(readfile("fates-admin/config.json"));
    end
end

local SetConfig = function(conf)
    if (isfolder("fates-admin") and isfile("fates-admin/config.json")) then
        local NewConfig = GetConfig();
        for i, v in next, conf do
            NewConfig[i] = v
        end
        writefile("fates-admin/config.json", HttpService:JSONEncode(NewConfig));
    else
        WriteConfig();
        local NewConfig = GetConfig();
        for i, v in next, conf do
            NewConfig[i] = v
        end
        writefile("fates-admin/config.json", HttpService:JSONEncode(NewConfig));
    end
end

local Prefix = GetConfig().Prefix or "!"
local AdminUsers = AdminUsers or {}
local Exceptions = Exceptions or {}
local Connections = {
    Players = {}
}
local CLI = false
local ChatLogsEnabled = true

---gets the player in your game from string
---@param str string
---@return table
GetPlayer = function(str)
    local CurrentPlayers = table.filter(Players:GetPlayers(), function(i, v)
        return not table.find(Exceptions, v);
    end)
    if (not str) then
        return {}
    end
    str = str:trim():lower();
    if (str:find(",")) then
        return table.flatMap(str:split(","), function(i, v)
            return GetPlayer(v);
        end)
    end

    local Magnitudes = table.map(CurrentPlayers, function(i, v)
        return {v,(GetRoot(v).CFrame.p - GetRoot().CFrame.p).Magnitude}
    end)

    local PlayerArgs = {
        ["all"] = function()
            return CurrentPlayers
        end,
        ["others"] = function()
            return table.filter(CurrentPlayers, function(i, v)
                return v ~= LocalPlayer
            end)
        end,
        ["nearest"] = function()
            table.sort(Magnitudes, function(a, b)
                return a[2] < b[2]
            end)
            return {Magnitudes[2][1]}
        end,
        ["farthest"] = function()
            table.sort(Magnitudes, function(a, b)
                return a[2] > b[2]
            end)
            return {Magnitudes[2][1]}
        end,
        ["random"] = function()
            return {CurrentPlayers[math.random(2, #CurrentPlayers)]}
        end,
        ["me"] = function()
            return {LocalPlayer}
        end
    }

    if (PlayerArgs[str]) then
        return PlayerArgs[str]();
    end

    local Players = table.filter(CurrentPlayers, function(i, v)
        return (v.Name:lower():sub(1, #str) == str) or (v.DisplayName:lower():sub(1, #str) == str);
    end)
    if (not next(Players)) then
        getgenv().F_A.Utils.Notify(LocalPlayer, "Fail", ("Couldn't find player %s"):format(str));
    end
    return Players
end


UI = game:GetObjects("rbxassetid://6167929302")[1]:Clone()


Guis = {}
local ParentGui
local CommandBarPrefix = GetConfig().CommandBarPrefix and Enum.KeyCode[GetConfig().CommandBarPrefix] or Enum.KeyCode.Semicolon

local CommandBar = UI.CommandBar
local Commands = UI.Commands
local Animations = UI.Commands:Clone()
local ChatLogs = UI.ChatLogs
local AdminChatLogs = UI.ChatLogs:Clone()
local Notification = UI.Notification
local Command = UI.Command
local Animation = UI.Command:Clone()
local ChatLogMessage = UI.Message
local AdminChatLogMessage = UI.Message:Clone()
local NotificationBar = UI.NotificationBar
local Stats = UI.Notification:Clone();
local StatsBar = UI.NotificationBar:Clone();

local RobloxChat = PlayerGui:FindFirstChild("Chat")
if (RobloxChat) then
    local RobloxChatFrame = RobloxChat:WaitForChild("Frame")
    RobloxChatChannelParentFrame = RobloxChatFrame:WaitForChild("ChatChannelParentFrame")
    RobloxChatBarFrame = RobloxChatFrame:WaitForChild("ChatBarParentFrame")
    RobloxFrameMessageLogDisplay = RobloxChatChannelParentFrame:WaitForChild("Frame_MessageLogDisplay")
    RobloxScroller = RobloxFrameMessageLogDisplay:WaitForChild("Scroller")
end

local CommandBarOpen = false
local CommandBarTransparencyClone = CommandBar:Clone()
local ChatLogsTransparencyClone = ChatLogs:Clone()
local AdminChatLogsTransparencyClone = AdminChatLogs:Clone()
local CommandsTransparencyClone
local PredictionText = ""

local UIParent = CommandBar.Parent
AdminChatLogs.Parent = UIParent
AdminChatLogMessage.Parent = UIParent
Animations.Parent = UIParent
Animations.Search.Text = "Search Animations"
Animations.Search.PlaceholderText = "Search Animations"
Animation.Parent = UIParent
AdminChatLogs.Name = "AdminChatLogs"
AdminChatLogMessage.Name = "AdminChatLogMessage"
Animations.Name = "Animations"
Animation.Name = "Animation"
Stats.Name = "Stats"
Stats.Parent = UIParent
StatsBar.Name = "StatsBar"
StatsBar.Parent = UIParent
StatsBar.Position = UDim2.new(0, 600, 0, -150)

if (RobloxChatBarFrame) then
    PredictionClone = RobloxChatBarFrame.Frame.BoxFrame.Frame.TextLabel:Clone();
    PredictionClone.Text = ""
    PredictionClone.TextTransparency = 0.3
    PredictionClone.Name = "Predict"
    PredictionClone.Parent = RobloxChatBarFrame.Frame.BoxFrame.Frame
    
    ChatBar = RobloxChatBarFrame.Frame.BoxFrame.Frame.ChatBar
end


-- position CommandBar
CommandBar.Position = UDim2.new(0.5, -100, 1, 5)

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
                local Humanoid = GetCharacter(Player) and GetHumanoid(Player) or nil
                local HumanoidRootPart = GetCharacter(Player) and GetRoot(Player) or nil
                if (Humanoid and HumanoidRootPart) then
                    local Distance = math.floor((Workspace.CurrentCamera.CFrame.p - HumanoidRootPart.CFrame.p).Magnitude)
                    Color.Text = ("\n \n \n [%s] [%s/%s]"):format(Distance, math.floor(Humanoid.Health), math.floor(Humanoid.MaxHealth))
                else
                    EspLoop:Disconnect();
                    Billboard:Destroy();
                end
            end)
        end
    end)()

    return Billboard
end


-- commands table
local CommandsTable = {}
local LastCommand = {}
local RespawnTimes = {}

--- returns true if the player has a tool
---@param plr any
---@type boolean
HasTool = function(plr)
    plr = plr or LocalPlayer
    local CharChildren, BackpackChildren = GetCharacter(plr):GetChildren(), plr.Backpack:GetChildren()
    local ToolFound = false
    for i, v in next, table.tbl_concat(CharChildren, BackpackChildren) do
        if (v:IsA("Tool")) then
            ToolFound = true
        end
    end

    return ToolFound
end

--- returs true if the player is r6
---@param plr any
isR6 = function(plr)
    plr = plr or LocalPlayer
    local Humanoid = GetHumanoid(plr);
    if (Humanoid) then
        return tostring(Humanoid.RigType):split(".")[3] == 'R6'
    end
    return false
end

isSat = function(plr)
    plr = plr or LocalPlayer
    local Humanoid = GetHumanoid(plr)
    if (Humanoid) then
        return Humanoid.Sit
    end
end

local CommandRequirements = {
    [1] = {
        Func = HasTool,
        Message = "You need a tool for this command"
    },
    [2] = {
        Func = isR6,
        Message = "You need to be R6 for this command"
    },
    [3] = {
        Func = function()
            return GetCharacter() ~= nil
        end,
        Message = "You need to be spawned for this command"
    }
}

--- Adds a command into the handler
---@param name string
---@param aliases table
---@param description string
---@param options table
---@param func function
---@type table
local AddCommand = function(name, aliases, description, options, func)
    local Cmd = {
        Name = name,
        Aliases = aliases,
        Description = description,
        Options = options,
        Function = function()
            for i, v in next, options do
                if (type(v) == 'function' and v() == false) then
                    Utils.Notify(LocalPlayer, "Fail", ("You are missing something that is needed for this command (%s)"):format(debug.getinfo(v).namewhat));
                    return nil
                elseif (type(v) == 'number' and CommandRequirements[v].Func() == false) then
                    Utils.Notify(LocalPlayer, "Fail", CommandRequirements[v].Message);
                    return nil
                end
            end
            return func
        end,
        ArgsNeeded = (function()
            local sorted = table.filter(options, function(i,v)
                return type(v) == "string"
            end)
            return tonumber(sorted and sorted[1]);
        end)() or 0,
        Args = (function()
            local sorted = table.filter(options, function(i, v)
                return type(v) == "table"
            end)
            return sorted[1] and sorted[1] or {}
        end)(),
        CmdExtra = {}
    }
    local Success, Err = pcall(function()
        rawset(CommandsTable, name, Cmd);
        if (type(aliases) == 'table') then
            for i, v in next, aliases do
                rawset(CommandsTable, tostring(v), Cmd);
            end
        end
    end)
    return Success
end

--- gets the function of the command 
---@param name string
local LoadCommand = function(name)
    local Command = rawget(CommandsTable, name);
    if (Command) then
        return Command
    end
end

---replaces your humanoid
---@param Hum any
---@return table
ReplaceHumanoid = function(Hum)
    local Humanoid = Hum or GetHumanoid();
    local NewHumanoid = Humanoid:Clone();
    NewHumanoid.Parent = Humanoid.Parent
    NewHumanoid.Name = Humanoid.Name
    Workspace.Camera.CameraSubject = NewHumanoid
    Humanoid:Destroy();
    return NewHumanoid
end

---replaces your character
ReplaceCharacter = function()
    local Char = LocalPlayer.Character
    local Model = Instance.new("Model");
    LocalPlayer.Character = Model
    LocalPlayer.Character = Char
    Model:Destroy();
    return Char
end

CFrameTool = function(tool, pos)
    local RightArm = GetCharacter():FindFirstChild("RightLowerArm") or GetCharacter():FindFirstChild("Right Arm");

    local Arm = RightArm.CFrame * CFrame.new(0, -1, 0, 1, 0, 0, 0, 0, 1, 0, -1, 0);
    local Frame = Arm:toObjectSpace(pos):Inverse();

    tool.Grip = Frame
end

Sanitize = function(value)
    if typeof(value) == 'CFrame' then
        local components = {value:components()}
        for i,v in pairs(components) do
            components[i] = math.floor(v * 10000 + .5) / 10000
        end
        return 'CFrame.new('..table.concat(components, ', ')..')'
    end
end

---add a connection to the players connection table
---@param Player table
---@param Connection any
---@param Tbl table
AddPlayerConnection = function(Player, Connection, Tbl)
    if (Connections) then
        if (Tbl) then
            Tbl[#Tbl + 1] = Connection
        else
            Connections.Players[Player.Name].Connections[#Connections.Players[Player.Name].Connections + 1] = Connection
        end
    end
end

---add a connection to the connections table
---@param Connection any
---@param Tbl table
AddConnection = function(Connection, Tbl)
    if (Connections) then
        if (Tbl) then
            Tbl[#Tbl + 1] = Connection
        else
            Connections[#Connections + 1] = Connection
        end
    end
end

if (isfolder("fates-admin") and isfolder("fates-admin/plugins") and isfolder("fates-admin/chatlogs")) then
    local Plugins = table.map(table.filter(listfiles("fates-admin/plugins"), function(i, v)
        return v:split(".")[#v:split(".")]:lower() == "lua"
    end), function(i, v)
        return {v:split("\\")[2], loadfile(v)}
    end)

    for i, v in next, Plugins do
        local Executed, Cmd, Error = pcall(v[2]);
        if (Executed and not Err) then
            local Executed, Err = pcall(function()
                AddCommand(Cmd.Name, Cmd.Aliases, Cmd.Description .. ", Plugin made by: " .. Cmd.Author, Cmd.Requirements, Cmd.Func);

                local Clone = Command:Clone()

                Utils.Hover(Clone, "BackgroundColor3");
                Utils.ToolTip(Clone, Cmd.Name .. "\n" .. Cmd.Description);
                Clone.CommandText.Text = Cmd.Name .. (#Cmd.Aliases > 0 and " (" ..table.concat(Cmd.Aliases, ", ") .. ")" or "");
                Clone.Name = Cmd.Name
                Clone.Visible = true
                Clone.Parent = Commands.Frame.List
            end);
            if (Err) then
                warn(("Error in plugin %s: %s"):format(v[1], Err));
            end
        else
            print(Executed)
            print(Err)
            warn(("Error in plugin %s: %s"):format(v[1], Err));
        end
    end
else
    WriteConfig();
end

AddCommand("commandcount", {"cc"}, "shows you how many commands there is in fates admin", {}, function(Caller)
    Utils.Notify(Caller, "Amount of Commands", ("There are currently %s commands."):format(#table.filter(CommandsTable, function(i,v)
        return table.indexOf(CommandsTable, v) == i
    end)))
end)

AddCommand("walkspeed", {"ws"}, "changes your walkspeed to the second argument", {}, function(Caller, Args, Tbl)
    local Humanoid = GetHumanoid();
    Tbl[1] = Humanoid.WalkSpeed
    Humanoid.WalkSpeed = Args[1] or 16
    return "your walkspeed is now " .. Humanoid.WalkSpeed
end)

AddCommand("jumppower", {"jp"}, "changes your jumpower to the second argument", {}, function(Caller, Args, Tbl)
    local Humanoid = GetHumanoid();
    Tbl[1] = Humanoid.JumpPower
    Humanoid.JumpPower = Args[1] or 50
    return "your jumppower is now " .. Humanoid.JumpPower 
end)

AddCommand("hipheight", {"hh"}, "changes your hipheight to the second argument", {}, function(Caller, Args, Tbl)
    local Humanoid = GetHumanoid();
    Tbl[1] = Humanoid.HipHeight
    Humanoid.HipHeight = Args[1] or 0
    return "your hipheight is now " .. Humanoid.HipHeight
end)

AddCommand("kill", {"tkill"}, "kills someone", {"1", 1, 3}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local OldPos = GetRoot().CFrame
    local Humanoid = ReplaceHumanoid();
    local TempRespawnTimes = {}
    for i, v in next, Target do
        TempRespawnTimes[v.Name] = RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name]
    end
    for i, v in next, Target do
        if (#Target == 1 and TempRespawnTimes[v.Name]) then
            LocalPlayer.Character:Destroy();
            LocalPlayer.CharacterAdded:Wait();
            LocalPlayer.Character:WaitForChild("Humanoid");
            wait()
            Humanoid = ReplaceHumanoid();
        end
    end

    coroutine.wrap(function()
        for i, v in next, Target do
            repeat
                if (GetCharacter(v)) then
                    if (isSat(v)) then
                        Utils.Notify(Caller or LocalPlayer, nil, v.Name .. " is sitting down, could not kill");
                        do break end
                    end

                    if (RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name]) then
                        do break end
                    end

                    local TargetRoot = GetRoot(v);
                    local Tool = LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool") or GetCharacter():FindFirstChildWhichIsA("Tool");
                    if (not Tool) then
                        do break end
                    end
                    Tool.CanBeDropped = true
                    Tool.Parent = GetCharacter();
                    Tool.Handle.Size = Vector3.new(4, 4, 4);
                    for i, v in next, Tool:GetDescendants() do
                        if (v:IsA("Sound")) then
                            v:Destroy();
                        end
                    end
                    CFrameTool(Tool, GetRoot(v).CFrame)
                    firetouchinterest(TargetRoot, Tool.Handle, 0);
                    firetouchinterest(TargetRoot, Tool.Handle, 1);
                else
                    Utils.Notify(Caller or LocalPlayer, "Fail", v.Name .. " is dead or does not have a root part, could not kill.");
                end
            until true
        end
    end)()
    Humanoid:ChangeState(15);
    wait(.3);
    LocalPlayer.Character:Destroy();
    LocalPlayer.CharacterAdded:Wait();
    LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = OldPos
end)

AddCommand("kill2", {}, "another variant of kill", {1, "1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local TempRespawnTimes = {}
    for i, v in next, Target do
        TempRespawnTimes[v.Name] = RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name]
    end
    local Humanoid = GetCharacter():FindFirstChildWhichIsA("Humanoid");
    ReplaceCharacter();
    wait(Players.RespawnTime - (#Target == 1 and .03 or .07)); -- this really kinda depends on ping
    local OldPos = GetRoot().CFrame
    Humanoid2 = ReplaceHumanoid(Humanoid);
    for i, v in next, Target do
        if (#Target == 1 and TempRespawnTimes[v.Name]) then
            LocalPlayer.CharacterAdded:Wait();
            LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = OldPos
            wait(.1);
            Humanoid2 = ReplaceHumanoid();
        end
    end

    coroutine.wrap(function()
        for i, v in next, Target do
            repeat
                if (GetCharacter(v)) then
                    if (isSat(v)) then
                        Utils.Notify(Caller or LocalPlayer, nil, v.Name .. " is sitting down, could not kill");
                        do break end
                    end

                    if (TempRespawnTimes[v.Name]) then
                        if (#Target == 1) then
                            Destroy = true
                        else
                            do break end
                        end
                    end

                    local TargetRoot = GetRoot(v);
                    local Tool = LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool") or GetCharacter():FindFirstChildWhichIsA("Tool");
                    if (not Tool) then
                        do break end
                    end
                    Tool.CanBeDropped = true
                    Tool.Parent = GetCharacter();
                    Tool.Handle.Size = Vector3.new(4, 4, 4);
                    CFrameTool(Tool, GetRoot(v).CFrame)
                    firetouchinterest(TargetRoot, Tool.Handle, 0);
                    firetouchinterest(TargetRoot, Tool.Handle, 1);
                else
                    Utils.Notify(Caller or LocalPlayer, "Fail", v.Name .. " is dead or does not have a root part, could not kill.");
                end
            until true
        end
    end)()
    Humanoid2:ChangeState(15);
    if (Destroy) then
        wait(.2);
        ReplaceCharacter();
        Destroy = nil
    end
    LocalPlayer.CharacterAdded:Wait();
    LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = OldPos
end)

AddCommand("loopkill", {"lkill"}, "loopkills a user", {1,3,"1"}, function(Caller, Args, Tbl)
    local Target = GetPlayer(Args[1]);
    repeat
        for i, v in next, Target do
            repeat
                if (RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name]) then
                    Destroy = true
                    do break end
                end
                local Humanoid = GetCharacter():FindFirstChildWhichIsA("Humanoid");
                ReplaceCharacter();
                wait(Players.RespawnTime - (#Target == 1 and 0.01 or .07));
                OldPos = GetRoot().CFrame
                local Humanoid2 = ReplaceHumanoid(Humanoid);
                local TargetRoot = GetRoot(v)
                if (TargetRoot) then
                    local Tool = LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool");
                    if (not Tool) then
                        do break end
                    end
                    Tool.Parent = GetCharacter();
                    Tool.Handle.Size = Vector3.new(4, 4, 4);
                    CFrameTool(Tool, TargetRoot.CFrame);
                    firetouchinterest(TargetRoot, Tool.Handle, 0);
                    firetouchinterest(TargetRoot, Tool.Handle, 1);
                    Humanoid2:ChangeState(15);
                end
            until true
        end
        if (Destroy) then
            wait(.2);
            ReplaceCharacter();
            Destroy = nil
        end
        LocalPlayer.CharacterAdded:Wait();
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = OldPos
    until not next(LoadCommand("loopkill").CmdExtra) or not GetPlayer(Args[1]) 
end)

AddCommand("unloopkill", {"unlkill"}, "unloopkills a user", {3,"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]); -- not really needed but
    LoadCommand("loopkill").CmdExtra = {}
    return "loopkill disabled"
end)

AddCommand("loopkill2", {}, "another variant of loopkill", {3,"1"}, function(Caller, Args, Tbl)
    local Target = GetPlayer(Args[1]);
    repeat
        GetCharacter().Humanoid:UnequipTools();
        local Humanoid = ReplaceHumanoid(Humanoid);
        Humanoid:ChangeState(15);
        for i, v in next, Target do
            local TargetRoot = GetRoot(v)
            for i2, v2 in next, LocalPlayer.Backpack:GetChildren() do
                if (v2:IsA("Tool")) then
                    v2.Parent = GetCharacter();
                    local OldSize = v2.Handle.Size
                    v2.Handle.Size = Vector3.new(0.5, 0.5, 0.5);
                    for i = 1, 3 do
                        if (TargetRoot) then
                            firetouchinterest(TargetRoot, v2.Handle, 0);
                            firetouchinterest(TargetRoot, v2.Handle, 1);
                        end
                    end
                    v2.Handle.Size = OldSize
                end
            end
        end
        wait(.2)
        LocalPlayer.Character:Destroy();
        LocalPlayer.CharacterAdded:Wait();
        LocalPlayer.Character:WaitForChild("HumanoidRootPart");
        wait(1);
    until not GetPlayer(Args[1])
end)

AddCommand("bring", {}, "brings a user", {1}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local OldPos = GetRoot(Caller).CFrame
    if (Caller ~= LocalPlayer and Target[1] == LocalPlayer) then
        GetRoot().CFrame = GetRoot(Caller).CFrame * CFrame.new(-5, 0, 0)
    else
        local TempRespawnTimes = {}
        for i, v in next, Target do
            TempRespawnTimes[v.Name] = RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name]
        end
        ReplaceHumanoid();
        for i, v in next, Target do
            if (#Target == 1 and TempRespawnTimes[v.Name]) then
                LocalPlayer.Character:Destroy();
                LocalPlayer.CharacterAdded:Wait();
                LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = OldPos;
                wait(.1);
                ReplaceHumanoid();
            end
        end
        for i, v in next, Target do
            repeat
                if (GetCharacter(v)) then
                    if (isSat(v)) then
                        Utils.Notify(Caller or LocalPlayer, nil, v.Name .. " is sitting down, could not kill");
                        do break end
                    end
    
                    if (RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name]) then
                        do break end
                    end
    
                    local TargetRoot = GetRoot(v);
                    local Tool = LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool") or GetCharacter():FindFirstChildWhichIsA("Tool");
                    if (not Tool) then
                        do break end
                    end
                    Tool.CanBeDropped = true
                    Tool.Parent = GetCharacter();
                    Tool.Handle.Size = Vector3.new(4, 4, 4);
                    for i, v in next, Tool:GetDescendants() do
                        if (v:IsA("Sound")) then
                            v:Destroy();
                        end
                    end
                    for i = 1, 3 do
                        if (TargetRoot) then
                            firetouchinterest(TargetRoot, Tool.Handle, 0);
                            firetouchinterest(TargetRoot, Tool.Handle, 1);
                            CFrameTool(Tool, OldPos * CFrame.new(-5, 0, 0));	
                        end
                    end
                else
                    Utils.Notify(Caller or LocalPlayer, "Fail", v.Name .. " is dead or does not have a root part, could not bring.");
                end
            until true
        end
        wait(.2);
        LocalPlayer.Character:Destroy();
        LocalPlayer.CharacterAdded:Wait();
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = OldPos
    end
end)

AddCommand("bring2", {}, "another variant of bring", {1, 3, "1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local TempRespawnTimes = {}
    for i, v in next, Target do
        TempRespawnTimes[v.Name] = RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name]
    end
    local Humanoid = GetCharacter():FindFirstChildWhichIsA("Humanoid");
    ReplaceCharacter();
    wait(Players.RespawnTime - (#Target == 1 and .01 or .3));
    local OldPos = GetRoot().CFrame
    Humanoid2 = ReplaceHumanoid(Humanoid);
    for i, v in next, Target do
        if (#Target == 1 and TempRespawnTimes[v.Name]) then
            LocalPlayer.CharacterAdded:Wait();
            LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = OldPos
            wait(.1);
            Humanoid2 = ReplaceHumanoid();
        end
    end

    coroutine.wrap(function()
        for i, v in next, Target do
            repeat
                if (GetCharacter(v)) then
                    if (isSat(v)) then
                        Utils.Notify(Caller or LocalPlayer, nil, v.Name .. " is sitting down, could not bring");
                        do break end
                    end

                    if (TempRespawnTimes[v.Name]) then
                        if (#Target == 1) then
                            Destroy = true
                        else
                            do break end
                        end
                    end

                    local TargetRoot = GetRoot(v);
                    local Tool = LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool") or GetCharacter():FindFirstChildWhichIsA("Tool");
                    if (not Tool) then
                        do break end
                    end
                    Tool.CanBeDropped = true
                    Tool.Parent = GetCharacter();
                    Tool.Handle.Size = Vector3.new(4, 4, 4);
                    CFrameTool(Tool, OldPos * CFrame.new(-5, 0, 0));
                    firetouchinterest(TargetRoot, Tool.Handle, 0);
                    firetouchinterest(TargetRoot, Tool.Handle, 1);
                else
                    Utils.Notify(Caller or LocalPlayer, "Fail", v.Name .. " is dead or does not have a root part, could not bring.");
                end
            until true
        end
    end)()
    if (Destroy) then
        wait(.2);
        LocalPlayer.Character:Destroy();
        Destroy = nil
    end
    LocalPlayer.CharacterAdded:Wait();
    LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = OldPos
end)

AddCommand("void", {}, "voids a player", {"1",1,3}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local TempRespawnTimes = {}
    for i, v in next, Target do
        TempRespawnTimes[v.Name] = RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name]
    end
    local Humanoid = GetCharacter():FindFirstChildWhichIsA("Humanoid");
    ReplaceCharacter();
    wait(Players.RespawnTime - (#Target == 1 and .01 or .3));
    local OldPos = GetRoot().CFrame
    Humanoid2 = ReplaceHumanoid(Humanoid);
    for i, v in next, Target do
        if (#Target == 1 and TempRespawnTimes[v.Name]) then
            LocalPlayer.CharacterAdded:Wait();
            LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = OldPos
            wait(.1);
            Humanoid2 = ReplaceHumanoid();
        end
    end
    coroutine.wrap(function()
        for i, v in next, Target do
            repeat
                if (GetCharacter(v)) then
                    if (isSat(v)) then
                        Utils.Notify(Caller or LocalPlayer, nil, v.Name .. " is sitting down, could not void");
                        do break end
                    end

                    if (TempRespawnTimes[v.Name]) then
                        if (#Target == 1) then
                            Destroy = true
                        else
                            do break end
                        end
                    end

                    local TargetRoot = GetRoot(v);
                    local Tool = LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool") or GetCharacter():FindFirstChildWhichIsA("Tool");
                    if (not Tool) then
                        do break end
                    end
                    Tool.CanBeDropped = true
                    Tool.Parent = GetCharacter();
                    Tool.Handle.Size = Vector3.new(4, 4, 4);
                    firetouchinterest(TargetRoot, Tool.Handle, 0);
                    firetouchinterest(TargetRoot, Tool.Handle, 1);
                    GetRoot().CFrame = CFrame.new(0, 9e9, 0);
                else
                    Utils.Notify(Caller or LocalPlayer, "Fail", v.Name .. " is dead or does not have a root part, could not void.");
                end
            until true
        end
    end)();
    if (Destroy) then
        wait(.2);
        LocalPlayer.Character:Destroy();
        Destroy = nil
    end
    LocalPlayer.CharacterAdded:Wait();
    LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = OldPos
end)

AddCommand("view", {"v"}, "views a user", {3,"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        Workspace.Camera.CameraSubject = GetHumanoid(v) or GetHumanoid();
    end
end)

AddCommand("unview", {"unv"}, "unviews a user", {3}, function(Caller, Args)
    Workspace.Camera.CameraSubject = GetHumanoid();
end)

AddCommand("loopview", {}, "loopviews a user", {3, "1"}, function(Caller, Args, Tbl)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        Workspace.Camera.CameraSubject = GetHumanoid(v) or GetHumanoid();
        local LoopView = Workspace.Camera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
            Workspace.Camera.CameraSubject = GetHumanoid(v) or GetHumanoid();
        end)
        Tbl[v.Name] = LoopView
        AddPlayerConnection(v, LoopView)
    end
end)

AddCommand("unloopview", {}, "unloopviews a user", {3}, function(Caller, Args)
    local LoopViewing = LoadCommand("loopview").CmdExtra
    local Target = GetPlayer(Args[1]);
    for i, v in next, LoopViewing do
        for i2, v2 in next, Target do
            if (i == v2.Name) then
                v:Disconnect();
            end
        end
    end
end)

AddCommand("invisble", {"invis"}, "makes yourself invisible", {}, function()
    local OldPos = GetRoot().CFrame
    GetRoot().CFrame = CFrame.new(9e9, 9e9, 9e9);
    local clone = GetRoot():Clone();
    wait(.2);
    GetRoot():Destroy();
    clone.CFrame = OldPos
    clone.Parent = GetCharacter();
    return "you are now invisible"
end)

AddCommand("dupetools", {"dp"}, "dupes your tools", {"1", 1}, function(Caller, Args, Tbl)
    local Amount = tonumber(Args[1])
    local Speed = tonumber(Args[2]);
    if (not Amount) then
        return "amount must be a number"
    end
    
    GetCharacter().Humanoid:UnequipTools();
    local ToolAmount = #table.filter(LocalPlayer.Backpack:GetChildren(), function(i, v)
        return v:IsA("Tool");
    end)
    local Duped = {}
    Tbl[1] = true
    for i = 1, Amount do
        if (not LoadCommand("dupetools").CmdExtra[1]) then
            do break end;
        end
        GetCharacter().Humanoid:UnequipTools();
        ReplaceCharacter();
        wait(game.Players.RespawnTime - (Speed or .05)); --todo: add the amount of tools divided by 100 or something like that
        local OldPos = GetRoot().CFrame
        ReplaceHumanoid(Humanoid);
        
        local Tools = table.filter(LocalPlayer.Backpack:GetChildren(), function(i, v)
            return v:IsA("Tool");
        end)
        
        for i, v in next, Tools do
            v.CanBeDropped = true
            v.Parent = LocalPlayer.Character
            v.Parent = Workspace
            Duped[#Duped + 1] = v
        end
        LocalPlayer.CharacterAdded:Wait();
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = OldPos;
    
        for i, v in next, Duped do
            if (v.Handle) then
                firetouchinterest(v.Handle, GetRoot(), 1);
                firetouchinterest(v.Handle, GetRoot(), 0);
            end
        end
        repeat wait()
            LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = OldPos
        until GetRoot().CFrame == OldPos
        wait(.4);
        GetCharacter().Humanoid:UnequipTools();
    end
    return ("successfully duped %d tool (s)"):format(#LocalPlayer.Backpack:GetChildren() - ToolAmount);
end)

AddCommand("stopdupe", {}, "stops the dupe", {}, function()
    local Dupe = LoadCommand("dupetools").CmdExtra
    if (not next(Dupe)) then
        return "you are not duping tools"
    end
    LoadCommand("dupetools").CmdExtra[1] = false
    return "dupetools stopped"
end)

AddCommand("savetools", {"st"}, "saves your tools", {1,3}, function(Caller, Args)
    GetHumanoid():UnequipTools();
    local Tools = LocalPlayer.Backpack:GetChildren();
    local Char = GetCharacter();
    for i, v in next, Tools do
        v.Parent = Char
        v.Parent = Workspace
        firetouchinterest(Workspace:WaitForChild(v.Name).Handle, GetRoot(), 1);
        firetouchinterest(v.Handle, GetRoot(), 0);
        Char:WaitForChild(v.Name).Parent = LocalPlayer.Backpack	
    end
    Utils.Notify(Caller, nil, "Tools are now saved");
    GetHumanoid().Died:Wait();
    GetHumanoid():UnequipTools();
    local Tools = LocalPlayer.Backpack:GetChildren();
    wait(Players.RespawnTime - wait()); -- * #Tools);
    for i, v in next, Tools do
        if (v:IsA("Tool") and v:FindFirstChild("Handle")) then
            v.Parent = Char
            v.Parent = Workspace
        end
    end
    LocalPlayer.CharacterAdded:Wait();
    LocalPlayer.Character:WaitForChild("HumanoidRootPart");
    for i, v in next, Tools do
        firetouchinterest(v.Handle, GetRoot(), 1);
        firetouchinterest(v.Handle, GetRoot(), 0);
    end
    return "tools recovered??"
end)

AddCommand("givetools", {}, "gives tools to a player", {"1", 3, 1}, function(Caller, Args) -- i am not re doing this
    local Target = GetPlayer(Args[1]);
    local OldPos = GetRoot().CFrame
    local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid");
    Humanoid.Name = "1"
    local Humanoid2 = Humanoid:Clone()
    Humanoid2.Parent = LocalPlayer.Character
    Humanoid2.Name = "Humanoid"
    Workspace.Camera.CameraSubject = Humanoid2
    wait()
    Humanoid:Destroy();
    for _, v in next, LocalPlayer:GetChildren() do
        if (v:IsA("Tool")) then
            v.Parent = LocalPlayer.Backpack
        end
    end
    Humanoid2:ChangeState(15);
    for i, v in next, Target do
        local char = Players.LocalPlayer.Character
        local target = v.Character
        local THumanoidRootPart = GetRoot(v)
        for i2, v2 in next, LocalPlayer.Backpack:GetChildren() do
            if (v2:IsA("Tool")) then
                v2.Parent = GetCharacter();
                for i = 1, 3 do
                    if (THumanoidRootPart) then
                        firetouchinterest(THumanoidRootPart, v2.Handle, 0);
                        firetouchinterest(THumanoidRootPart, v2.Handle, 1);
                    end
                end
            end
        end
    end
    wait(.2);
    LocalPlayer.Character:Destroy();
    LocalPlayer.CharacterAdded:Wait();
    LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = OldPos
end)


AddCommand("grabtools", {"gt"}, "grabs tools in the workspace", {3}, function(Caller, Args)
    local Tools = table.filter(Workspace:GetDescendants(), function(i,v)
        return v:IsA("Tool") and v:FindFirstChild("Handle");
    end)
    GetHumanoid():UnequipTools();
    local ToolAmount = #LocalPlayer.Backpack:GetChildren();
    for i, v in next, Tools do
        if (v.Handle) then
            firetouchinterest(v.Handle, GetRoot(), 1);
            firetouchinterest(v.Handle, GetRoot(), 0);
        end
    end
    wait(.4);
    GetHumanoid():UnequipTools();
    return ("grabbed %d tool (s)"):format(#LocalPlayer.Backpack:GetChildren() - ToolAmount)
end)

AddCommand("autograbtools", {"agt", "loopgrabtools", "lgt"}, "once a tool is added to workspace it will be grabbed", {3}, function(Caller, Args, Tbl)
    local Connection = Workspace.ChildAdded:Connect(function(child)
        if (child:IsA("Tool") and child:FindFirstChild("Handle")) then
            firetouchinterest(child.Handle, GetRoot(), 1);
            firetouchinterest(child.Handle, GetRoot(), 0);
            GetCharacter().Humanoid:UnequipTools();
        end
    end)
    AddPlayerConnection(LocalPlayer, Connection);
    Tbl[#Tbl + 1] = Connection
    return "tools will be grabbed automatically"
end)

AddCommand("droptools", {"dt"}, "drops all of your tools", {1,3}, function()
    GetHumanoid():UnequipTools();
    local Tools = LocalPlayer.Backpack:GetChildren();
    for i, v in next, Tools do
        if (v:IsA("Tool") and v:FindFirstChild("Handle")) then
            v.Parent = GetCharacter();
            v.Parent = Workspace
        end
    end
    return ("dropped %d tool (s)"):format(#Tools);
end)

AddCommand("nohats", {"nh"}, "removes all the hats from your character", {3}, function()
    local HatAmount = #GetHumanoid():GetAccessories();
    for i, v in next, GetHumanoid():GetAccessories() do
        v:Destroy();
    end
    return ("removed %d hat (s)"):format(HatAmount - #GetHumanoid():GetAccessories());
end)

AddCommand("drophats", {"dh"}, "drops all of your hats in the workspace", {3}, function()
    local HatAmount = #GetHumanoid():GetAccessories();
    for i, v in next, GetHumanoid():GetAccessories() do
        if (v.Handle) then
            v.Parent = Workspace
        end
    end
    return ("dropped %d hat (s)"):format(HatAmount - #GetHumanoid():GetAccessories());
end)

AddCommand("clearhats", {"ch"}, "clears all of the hats in workspace", {3}, function()
    for i, v in next, GetHumanoid():GetAccessories() do
        v:Destroy();
    end
    local Amount = 0
    for i, v in next, Workspace:GetChildren() do
        if (v:IsA("Accessory") and v:FindFirstChild("Handle")) then
            firetouchinterest(v.Handle, GetRoot(), 1);
            firetouchinterest(v.Handle, GetRoot(), 0);
            GetCharacter():WaitForChild(v.Name):Destroy();
            Amount = Amount + 1
        end
    end
    return ("cleared %d hat (s)"):format(Amount);
end)

AddCommand("hatsize", {"hsize"}, "Times to repeat the command", {3}, function(Caller, Args)
    for i = 1, tonumber(Args[1]) do
        local Hat = GetCharacter():FindFirstChildOfClass("Accessory");
        Hat.Handle.OriginalSize:Destroy();
        Hat.Parent = Workspace
        firetouchinterest(GetRoot(), Hat.Handle, 0);
        firetouchinterest(GetRoot(), Hat.Handle, 1);
        GetCharacter():WaitForChild(Hat.Name);
    end
end)

AddCommand("gravity", {"grav"}, "sets the worksapaces gravity", {"1"}, function(Caller, Args)
    Workspace.Gravity = tonumber(Args[1]) or Workspace.Gravity
end)

AddCommand("nogravity", {"nograv", "ungravity"}, "removes the gravity", {}, function()
    Workspace.Gravity = 192
end)

AddCommand("chatmute", {"cmute"}, "mutes a player in your chat", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local MuteRequest = ReplicatedStorage.DefaultChatSystemChatEvents.MutePlayerRequest
    for i, v in next, Target do
        MuteRequest:InvokeServer(v.Name);
        Utils.Notify(Caller, "Command", ("%s is now muted on your chat"):format(v.Name));
    end
end)

AddCommand("unchatmute", {"uncmute"}, "unmutes a player in your chat", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local MuteRequest = ReplicatedStorage.DefaultChatSystemChatEvents.UnMutePlayerRequest
    for i, v in next, Target do
        MuteRequest:InvokeServer(v.Name);
        Utils.Notify(Caller, "Command", ("%s is now unmuted on your chat"):format(v.Name));
    end
end)

AddCommand("delete", {}, "puts a players character in lighting", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        if (v.Character) then
            v.Character.Parent = Lighting
            Utils.Notify(Caller, "Command", v.Name .. "'s character is now parented to lighting");
        end
    end
end)

AddCommand("loopdelete", {"ld"}, "loop of delete command", {"1"}, function(Caller, Args, Tbl)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        if (v.Character) then
            v.Character.Parent = Lighting
        end
        local Connection = v.CharacterAdded:Connect(function()
            v:WaitForChild("HumanoidRootPart").Parent.Parent = Lighting -- wait until the characters hrp is added then parent char to lighting
        end)
        Tbl[v.Name] = Connection
        AddPlayerConnection(v, Connection);
    end
end)

AddCommand("unloopdelete", {"unld"}, "unloop the loopdelete", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local Looping = LoadCommand("loopdelete").CmdExtra
    for i, v in next, Target do
        if (Looping[v.Name]) then
            Looping[v.Name]:Disconnect();
        end
    end
end)

AddCommand("recover", {"undelete"}, "removes a players character parented from lighting", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        if (v.Character and v.Character.Parent == Lighting) then
            v.Character.Parent = Workspace
            Utils.Notify(Caller, "Command", v.Name .. "'s character is now in workspace");
        else
            Utils.Notify(Caller, "Command", v.Name .. "'s character is not removed");
        end
    end
end)

AddCommand("load", {"loadstring"}, "loads whatever you want", {"1"}, function(Caller, Args)
    local Code = table.concat(Args, " ");
    local Success, Err = pcall(function()
        loadstring(("%s\n%s\n%s"):format("local oldprint=print print=function(...)getgenv().F_A.Utils.Notify(game.Players.LocalPlayer,'Command',table.concat({...},' '))return oldprint(...)end", Code, "print = oldprint"))();
    end)
    if (not Success and Err) then
        return Err
    else
        return "executed with no errors"
    end
end)

AddCommand("sit", {}, "makes you sit", {3}, function(Caller, Args, Tbl)
    LocalPlayer.Character.Humanoid.Sit = true
    return "now sitting (obviously)"
end)

AddCommand("infinitejump", {"infjump"}, "infinite jump no cooldown", {3}, function(Caller, Args, Tbl)
    local InfJump = UserInputService.JumpRequest:Connect(function()
        if (GetHumanoid()) then 
            GetHumanoid():ChangeState(3);
        end
    end)
    Tbl[#Tbl + 1] = InfJump
    AddConnection(InfJump);
    return "infinite jump enabled"
end)

AddCommand("noinfinitejump", {"uninfjump", "noinfjump"}, "removes infinite jump", {}, function()
    local InfJump = LoadCommand("infjump").CmdExtra
    if (not next(InjJump)) then
        return "you are not infinite jumping"
    end
    for i, v in next, LoadCommand("infjump").CmdExtra do
        if (type(v) == 'userdata' and v.Disconnect) then
            v:Disconnect();
        end
    end
    return "infinite jump disabled"
end)

AddCommand("headsit", {"hsit"}, "sits on the players head", {"1"}, function(Caller, Args, Tbl)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        LocalPlayer.Character.Humanoid.Sit = true
        local Sit = LocalPlayer.Character.Humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
            LocalPlayer.Character.Humanoid.Sit = true
        end)
        local Root = GetRoot();
        local Loop = RunService.Heartbeat:Connect(function()
            Root.CFrame = v.Character.Head.CFrame * CFrame.new(0, 0, 1);
        end)
        Tbl[#Tbl + 1] = Sit
        Tbl[#Tbl + 1] = Loop
        AddPlayerConnection(LocalPlayer, Loop);
        AddPlayerConnection(LocalPlayer, Sit);
    end
end)

AddCommand("unheadsit", {"noheadsit"}, "unheadsits on the target", {3}, function(Caller, Args)
    local Looped = LoadCommand("headsit").CmdExtra
    for i, v in next, Looped do
        v:Disconnect();
    end
    return "headsit disabled"
end)

AddCommand("headstand", {"hstand"}, "stands on a players head", {"1",3}, function(Caller, Args, Tbl)
    local Target = GetPlayer(Args[1]);
    local Root = GetRoot();
    for i, v in next, Target do
        local Loop = RunService.Heartbeat:Connect(function()
            Root.CFrame = v.Character.Head.CFrame * CFrame.new(0, 1, 0);
        end)
        Tbl[v.Name] = Loop
        AddPlayerConnection(v, Loop);
    end
end)

AddCommand("unheadstand", {"noheadstand"}, "unheadstands on the target", {3}, function(Caller, Args)
    local Looped = LoadCommand("headstand").CmdExtra
    for i, v in next, Looped do
        v:Disconnect();
    end
    return "headstand disabled"
end)

AddCommand("setspawn", {}, "sets your spawn location to the location you are at", {3}, function(Caller, Args, Tbl)
    if (Tbl[1]) then
        Tbl[1]:Disconnect();
    end
    local Position = GetRoot().CFrame
    local Spawn = LocalPlayer.CharacterAdded:Connect(function()
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Position
    end)
    Tbl[1] = Spawn
    AddPlayerConnection(LocalPlayer, Spawn);
    local SpawnLocation = table.pack(table.unpack(tostring(Position):split(", "), 1, 3));
    SpawnLocation.n = nil
    return "spawn successfully set to " .. table.concat(table.map(SpawnLocation, function(i,v)
        return tostring(math.round(tonumber(v)));
    end), ",");
end)

AddCommand("removespawn", {}, "removes your spawn location", {}, function(Caller, Args)
    local Spawn = LoadCommand("setspawn").CmdExtra[1]
    if (Spawn) then
        Spawn:Disconnect();
        return "removed spawn location"
    end
    return "you don't have a spawn location set"
end)

AddCommand("ping", {}, "shows you your ping", {}, function()
    return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString():split(" ")[1] .. "ms"
end)

AddCommand("fps", {"frames"}, "shows you your framerate", {}, function()
    local x = 0	
    local a = tick();
    local fpsget = function()
        x = (1 / (tick() - a));
        a = tick();
        return ("%.3f"):format(x);
    end
    local fps = nil
    local v = RunService.Stepped:Connect(function()
        fps = fpsget();
    end)
    wait(.2);
    v:Disconnect();
    return ("your current fps is %s"):format(fps);
end)

AddCommand("displaynames", {}, "enables/disables display names (on/off)", {{"on","off"}}, function(Caller, Args, Tbl)
    local Option = Args[1]
    if (Option:lower() == "off") then
        for i, v in next, Players:GetPlayers() do
            if (v.Name ~= v.DisplayName) then
                -- v.DisplayName = v.Name
                if (v.Character) then
                    v.Character.Humanoid.DisplayName = v.Name
                end
                local Connection = v.CharacterAdded:Connect(function()
                    v.Character:WaitForChild("Humanoid").DisplayName = v.Name
                end)
                Tbl[v.Name] = {v.DisplayName, Connection}
                AddPlayerConnection(v, Connection);
            end
        end
        return "people with a displayname displaynames will be shown"
    elseif (Option:lower() == "on") then
        for i, v in next, LoadCommand("displaynames").CmdExtra do
            if (i.Character) then
                i.Character.Humanoid.DisplayName = v[1]
            end
            v[2]:Disconnect();
            v = nil
        end
        return "people with a displayname displaynames will be removed"
    end
end)

AddCommand("time", {"settime"}, "sets the games time", {}, function(Caller, Args)
    local Time = Args[1] and Args[1]:lower() or 14
    local Times = {["night"]=0,["day"]=14,["dawn"]=6}
    Lighting.ClockTime = Times[Time] or Time
end)

AddCommand("toolfling", {}, "touch a player with your tool out to fling then", {1,3}, function()
    GetHumanoid():UnequipTools();
    local Tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool");
    Tool.GripPos = Vector3.new(math.huge, math.huge, math.huge);
    Tool.Parent = GetCharacter();
    return "touch a player with your tool out"
end)

AddCommand("fling", {}, "flings a player", {}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local Root = GetRoot()
    local OldPos, OldVelocity = Root.CFrame, Root.Velocity

    for i, v in next, Target do
        local TargetRoot = GetRoot(v);
        local TargetPos = TargetRoot.Position
        local Stepped = RunService.Stepped:Connect(function(step)
            step = step - Workspace.DistributedGameTime
        
            Root.CFrame = (TargetRoot.CFrame - (Vector3.new(0, 1e6, 0) * step)) + (TargetRoot.Velocity * (step * 30))
            Root.Velocity = Vector3.new(0, 1e6, 0)
        end)
        local start = tick();
        repeat
            wait();
        until (TargetPos - TargetRoot.Position).magnitude >= 60 or tick() - start >= 3.5
        Stepped:Disconnect();
    end
    wait();
    local Stepped = RunService.Stepped:Connect(function()
        Root.Velocity = OldVelocity
        Root.CFrame = OldPos
    end)
    wait(2);
    Root.Anchored = true
    Stepped:Disconnect();
    Root.Anchored = false
    Root.Velocity = OldVelocity
    Root.CFrame = OldPos
end)

AddCommand("antitkill", {}, "anti tkill :troll:", {3}, function(Caller, Args)
    GetCharacter()["Right Arm"]:Destroy();
    return "lol"
end)

AddCommand("skill", {"swordkill"}, "swordkills the user auto", {1, {"player", "manual"}}, function(Caller, Args)
    local Target, Option = GetPlayer(Args[1]), Args[2] or "" 
    local Backpack, Character = LocalPlayer.Backpack, GetCharacter();
    local Tool = Character:FindFirstChild("ClassicSword") or Backpack:FindFirstChild("ClassicSword") or Backpack:FindFirstChildOfClass("Tool") or Character:FindFirstChildOfClass("Tool")
    Tool.Parent = Character
    local OldPos = GetRoot().CFrame
    for i, v in next, Target do
        coroutine.wrap(function()
            if (v.Character:FindFirstChild("ForceField")) then
                repeat wait() until not v.Character:FindFirstChild("ForceField");
            end
            for i = 1, 5 do
                if (Option:lower() == "manual") then
                    GetRoot().CFrame = GetRoot(v).CFrame * CFrame.new(0, -3, 0);
                    Tool:Activate();
                    Tool:Activate();
                    wait();
                else
                    Tool:Activate();
                    firetouchinterest(Tool.Hitbox or Tool.Handle, GetRoot(v), 0);
                    wait();
                    firetouchinterest(Tool.Hitbox or Tool.Handle, GetRoot(v), 1);
                    wait();
                end
            end
            wait();
            if (Option:lower() == "manual") then
                LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = OldPos
            end
        end)()
    end
end)

AddCommand("reach", {"swordreach"}, "changes handle size of your tool", {1, 3}, function(Caller, Args, Tbl)
	local Amount = Args[1] or 2
	local Tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool");
    Tbl[Tool] = Tool.Size
	Tool.Handle.Size = Vector3.new(Tool.Handle.Size.X, Tool.Handle.Size.Y, tonumber(Amount or 30));
    Tool.Handle.Massless = true;
    return "reach on"
end)

AddCommand("noreach", {"noswordreach"}, "removes sword reach", {}, function()
    local ReachedTools = LoadCommand("reach").CmdExtra
    if (not next(ReachedTools)) then
        return "reach isn't enabled"
    end
    for i, v in next, ReachedTools do
        i.Size = v
    end
    LoadCommand("reach").CmdExtra = {}
    return "reach disabled"
end)

AddCommand("swordaura", {"saura"}, "sword aura", {3}, function(Caller, Args, Tbl)
    for i, v in next, LoadCommand("swordaura").CmdExtra do
        if (type(v) == 'userdata' and v.Disconnect) then
            v:Disconnect();
        end
    end
    
    local SwordDistance = tonumber(Args[1]) or 10
    local Tool = GetCharacter():FindFirstChildWhichIsA("Tool") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool");
    local PlayersTbl = table.filter(Players:GetPlayers(), function(i, v)
        return v ~= LocalPlayer
    end)

    local AuraConnection = RunService.Heartbeat:Connect(function()
        for i, v in next, PlayersTbl do
            if (GetRoot(v) and GetHumanoid(v) and GetHumanoid(v).Health ~= 0 and GetMagnitude(v) <= SwordDistance) then
                Tool.Parent = GetCharacter();
                local BaseParts = table.filter(GetCharacter(v):GetChildren(), function(i, v)
                    return v:IsA("BasePart");
                end)
                table.forEach(BaseParts, function(i, v)
                    Tool:Activate();
                    firetouchinterest(Tool.Handle, v, 1);
                    firetouchinterest(Tool.Handle, v, 0);
                end)
            end
        end
    end)

    local PlayerAddedConnection = Players.PlayerAdded:Connect(function(Plr)
        PlayersTbl[#PlayersTbl + 1] = Plr
    end)
    local PlayerRemovingConnection = Players.PlayerRemoving:Connect(function(Plr)
        table.remove(PlayersTbl, table.indexOf(PlayersTbl, Plr))
    end)

    AddConnection(PlayerAddedConnection);
    AddConnection(PlayerRemovingConnection);
    Tbl[#Tbl + 1] = AuraConnection
    Tbl[#Tbl + 1] = PlayerAddedConnection
    Tbl[#Tbl + 1] = PlayerRemovingConnection
    return "sword aura enabled with distance " .. SwordDistance
end)


AddCommand("noswordaura", {"noaura"}, "stops the sword aura", {}, function()
    local Aura = LoadCommand("swordaura").CmdExtra
    if (not next(Aura)) then
        return "sword aura is not enabled"
    end
    for i, v in next, Aura do
        if (type(v) == 'userdata' and v.Disconnect) then
            v:Disconnect();
        end
    end
end)

AddCommand("freeze", {}, "freezes your character", {3}, function(Caller, Args)
    local BaseParts = table.filter(GetCharacter(v):GetChildren(), function(i, v)
        return v:IsA("BasePart");
    end)
    for i, v in next, BaseParts do
        v.Anchored = true
    end
    return "freeze enabled (client)"
end)

AddCommand("unfreeze", {}, "unfreezes your character", {3}, function(Caller, Args)
    local BaseParts = table.filter(GetCharacter(v):GetChildren(), function(i, v)
        return v:IsA("BasePart");
    end)
    for i, v in next, BaseParts do
        v.Anchored = false
    end
    return "freeze disabled"
end)

AddCommand("streamermode", {}, "changes names of everyone to something random", {}, function(Caller, Args, Tbl) 
    local Rand = function(len) return HttpService:GenerateGUID():sub(2, len):gsub("-", "") end
    local Hide = function(a, v)
        if (v and v:IsA("TextLabel") or v:IsA("TextButton")) then
            if (Players:FindFirstChild(v.Text)) then
                Tbl[v.Name] = v.Text
                local NewName = Rand(v.Text:len());
                if (Players:FindFirstChild(v.Text) and GetCharacter(Players[v.Text])) then
                    Players[v.Text].Character.Humanoid.DisplayName = NewName
                end
                v.Text = NewName
            end
        end	
    end

    table.forEach(game:GetDescendants(), Hide);

    local Hide = game.DescendantAdded:Connect(function(x)
        Hide(nil, x);
    end)
    Tbl[#Tbl + 1] = Hide
    
    return "streamer mode enabled"
end)

AddCommand("nostreamermode", {"unstreamermode"}, "removes all the changed names", {}, function(Caller, Args, Tbl)
    local changed = LoadCommand("streamermode").CmdExtra
    for i, v in next, changed do
        if (type(v) == 'userdata') then
            v:Disconnect();
        else
            i.Text = v
        end
    end
end)

AddCommand("fireclickdetectors", {}, "fires all the click detectors", {3}, function(Caller, Args)
    local amount = 0
    local howmany = Args[1]
    for i, v in next, Workspace:GetDescendants() do
        if (v:IsA("ClickDetector")) then
            fireclickdetector(v);
            amount = amount + 1
            if (howmany and amount == tonumber(howmany)) then break; end
        end
    end
    return ("fired %d amount of clickdetectors"):format(amount);
end)

AddCommand("firetouchinterests", {}, "touches all touch transmitters", {3}, function(Caller, Args)
    local amount = 0
    local howmany = Args[1]
    for i, v in next, Workspace:GetDescendants() do
        if (v:IsA("TouchTransmitter")) then
            firetouchinterest(Utils.GetRoot(LocalPlayer.Character), v.Parent, 0);
            wait();
            firetouchinterest(Utils.GetRoot(LocalPlayer.Character), v.Parent, 1);
            amount = amount + 1
            if (howmany and amount == tonumber(howmany)) then break; end
        end
    end
    return ("fired %d amount of touchtransmitters"):format(amount);
end)

SoundService.RespectFilteringEnabled = false

AddCommand("muteboombox", {}, "mutes a users boombox", {}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        for i2, v2 in next, v.Character:GetDescendants() do
            if (v2:IsA("Sound")) then
                v2.Playing = false
            end
        end
    end
end)

AddCommand("loopmuteboombox", {}, "loop mutes a users boombox", {}, function(Caller, Args, Tbl)
    local Target = GetPlayer(Args[1]);
    local filterBoomboxes = function(i,v)
        return v:FindFirstChild("Handle") and v.Handle:FindFirstChildWhichIsA("Sound");
    end
    for i, v in next, Target do
        local Tools = table.tbl_concat(table.filter(v.Character:GetDescendants(), filterBoomboxes), table.filter(v.Backpack:GetChildren(), filterBoomboxes));
        for i2, v2 in next, Tools do
            Tbl[v.Name] = true
            v2.Handle.Sound.Playing = false
            coroutine.wrap(function()
                while (LoadCommand("loopmuteboombox").CmdExtra[v.Name]) do
                    v2.Handle.Sound.Playing = false
                    RunService.Heartbeat:Wait();
                    if (not Players:FindFirstChild(v.Name) or not v2) then
                        Tbl[v.Name] = nil
                        break
                    end
                end
            end)()
            Tbl[v.Name] = Connection
            AddPlayerConnection(v, Connection);
        end
    end
end)

AddCommand("unloopmuteboobmox", {}, "unloopmutes a persons boombox", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1])
    local Looped = LoadCommand("loopmuteboombox").CmdExtra
    for i, v in next, Target do
        if (Looped[v.Name]) then
            Looped[v.Name] = nil
        end
    end
    LoadCommand("loopmuteboombox").CmdExtra = Looped
end)

AddCommand("forceplay", {}, "forcesplays an audio", {1,3,"1"}, function(Caller, Args, Tbl)
    local Id = Args[1]
    local filterBoomboxes = function(i,v)
        return v:IsA("Tool") and v:FindFirstChild("Handle") and v.Handle:FindFirstChildWhichIsA("Sound");
    end
    GetHumanoid():UnequipTools();
    local Boombox = table.filter(LocalPlayer.Backpack:GetChildren(), filterBoomboxes)
    if (not next(Boombox)) then
        return "you need a boombox to forceplay"
    end
    Boombox = Boombox[1]
    Boombox.Parent = GetCharacter();
    local Sound = Boombox.Handle.Sound
    Sound.SoundId = "http://roblox.com/asset/?id=" .. Id
    Boombox:FindFirstChildWhichIsA("RemoteEvent"):FireServer("PlaySong", tonumber(Id));
    Boombox.Parent = LocalPlayer.Backpack
    Tbl[Boombox] = true
    coroutine.wrap(function()
        while (LoadCommand("forceplay").CmdExtra[Boombox]) do
            Boombox.Handle.Sound.Playing = true
            RunService.Heartbeat:Wait();
        end
    end)()
    return "now forceplaying ".. Id
end)

AddCommand("unforceplay", {}, "stops forceplay", {}, function()
    local Playing = LoadCommand("forceplay").CmdExtra
    for i, v in next, Playing do
        i:FindFirstChild("Sound", true).Playing = false
        LoadCommand("forceplay").CmdExtra[i] = false
    end
    return "stopped forceplay"
end)

AddCommand("audiotime", {"audiotimeposition"}, "changes audio timeposition", {"1",1}, function(Caller, Args)
    local Time = Args[1]
    if (not tonumber(Time)) then
        return "time must be a number"
    end
    local filterplayingboomboxes = function(i,v)
        return v:IsA("Tool") and v:FindFirstChild("Handle") and v.Handle:FindFirstChildWhichIsA("Sound") and v.Handle:FindFirstChildWhichIsA("Sound").Playing == true
    end
    local OtherPlayingBoomboxes = LoadCommand("forceplay").CmdExtra
    local Boombox = table.filter(table.tbl_concat(LocalPlayer.Backpack:GetChildren(), GetCharacter():GetChildren()), filterplayingboomboxes)
    if (not next(Boombox) and not next(OtherPlayingBoomboxes)) then
        return "you need a boombox to change the timeposition"
    end
    Boombox = Boombox[1]
    if (Boombox) then
        Boombox:FindFirstChild("Sound", true).TimePosition = math.floor(tonumber(Time));
    else
        for i, v in next, OtherPlayingBoomboxes do
            i:FindFirstChild("Sound", true).TimePosition = math.floor(tonumber(Time));
        end
    end
    return "changed time position to " .. Time
end)

AddCommand("audiolog", {}, "audio logs someone", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        for i2, v2 in next, v.Character:GetDescendants() do
            if (v2:IsA("Sound") and v2.Parent.Parent:IsA("Tool")) then
                local AudioId = v2.SoundId:split("=")[2]
                setclipboard(AudioId);
                Utils.Notify(Caller, "Command", ("Audio Id (%s) copied to clipboard"):format(AudioId));
            end
        end
    end
end)

AddCommand("position", {"pos"}, "shows you a player's current (cframe) position", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1])[1]
    local Root = GetRoot(Target)
    local Pos = Sanitize(Root.CFrame)
    if setclipboard then
        setclipboard(Pos)
    end
    return ("%s's position: %s"):format(Target.Name, Pos);
end)

AddCommand("grippos", {}, "changes grippos of your tool", {"3"}, function(Caller, Args, Tbl)
    local Tool = GetCharacter():FindFirstChildWhichIsA("Tool") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool");
    Tool.GripPos = Vector3.new(tonumber(Args[1]), tonumber(Args[2]), tonumber(Args[3]));
    Tool.Parent = GetCharacter();
    return "grippos set"
end)

AddCommand("truesightguis", {"tsg"}, "true sight on all guis", {}, function(Caller, Args, Tbl)
    for i, v in next, game:GetDescendants() do
        if (v:IsA("Frame") or v:IsA("ScrollingFrame") and not v.Visible) then
            Tbl[v] = v.Visible
            v.Visible = true
        end
    end
    return "truesight for guis are now on"
end)

AddCommand("notruesightguis", {"untruesightguis", "notsg"}, "removes truesight on guis", {}, function(Caller, Args)
    local Guis = LoadCommand("truesightguis").CmdExtra
    for i, v in next, Guis do
        i.Visible = v
    end
    return "truesight for guis are now off"
end)

AddCommand("locate", {}, "locates a player", {"1"}, function(Caller, Args, Tbl)
    local Player = GetPlayer(Args[1]);
    for i, v in next, Player do
        Tbl[v.Name] = Utils.Locate(v);
    end
end)

AddCommand("unlocate", {"nolocate"}, "disables location for a player", {"1"}, function(Caller, Args)
    local Locating = LoadCommand("locate").CmdExtra
    local Target = GetPlayer(Args[1]);
    for i, v in next, Locating do
        for i2, v2 in next, Target do
            if (i == v2.Name) then
                v:Destroy();
                Utils.Notify(Caller, "Command", v2.Name .. " is no longer being located");
            else
                Utils.Notify(Caller, "Command", v2.Name .. " isn't being located");
            end
        end
    end
end)

AddCommand("esp", {}, "turns on player esp", {}, function(Caller, Args, Tbl)
    Tbl.Billboards = {}
    table.forEach(Players:GetPlayers(), function(i,v)
        Tbl.Billboards[#Tbl.Billboards + 1] = Utils.Locate(v);
        local Esp = v.CharacterAdded:Connect(function()
            v.Character:WaitForChild("HumanoidRootPart");
            v.Character:WaitForChild("Head");
            Tbl.Billboards[#Tbl.Billboards + 1] = Utils.Locate(v);
        end)
        Tbl[#Tbl + 1] = Esp
    end);

    PlayerAddedConnection = Players.PlayerAdded:Connect(function(Player)
        Player.Character:WaitForChild("HumanoidRootPart");
        Player.Character:WaitForChild("Head");
        Tbl.Billboards[#Tbl.Billboards + 1] = Utils.Locate(v);
        local Esp = Player.CharacterAdded:Connect(function()
            Player.Character:WaitForChild("HumanoidRootPart");
            Player.Character:WaitForChild("Head");
            Tbl.Billboards[#Tbl.Billboards + 1] = Utils.Locate(Player);
        end)
        Tbl[#Tbl + 1] = Esp
    end);

    AddConnection(PlayerAddedConnection);
    Tbl[#Tbl + 1] = PlayerAddedConnection
    
    return "esp enabled"
end)

AddCommand("noesp", {"unesp"}, "turns off esp", {}, function(Caller, Args)
    local Esp = LoadCommand("esp").CmdExtra
    for i, v in next, Esp.Billboards do
        v:Destroy();
    end
    if PlayerAddedConnection then
        PlayerAddedConnection:Disconnect()
        PlayerAddedConnection = nil
    end
    return "esp disabled"
end)

AddCommand("walkto", {}, "walks to a player", {"1", 3}, function(Caller, Args)
    local Target = GetPlayer(Args[1])[1];
    GetHumanoid():MoveTo(GetRoot(Target).Position);
    return "walking to " .. Target.Name
end)

AddCommand("follow", {}, "follows a player", {"1", 3}, function(Caller, Args, Tbl)
    local Target = GetPlayer(Args[1])[1]
    Tbl[Target.Name] = true
    coroutine.wrap(function()
        repeat
            GetHumanoid():MoveTo(GetRoot(Target).Position);
            wait(.2);
        until not LoadCommand("follow").CmdExtra[Target.Name]
    end)()
    return "now following " .. Target.Name
end)

AddCommand("unfollow", {}, "unfollows a player", {}, function()
    local Following = LoadCommand("follow").CmdExtra
    if (not next(Following)) then
        return "you are not following anyone"
    end
    LoadCommand("follow").CmdExtra = {}
    return "stopped following"
end)

AddCommand("age", {}, "ages a player", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        local AccountAge = v.AccountAge
        local t = os.date("*t", os.time());
        t.day = t.day - tonumber(AccountAge);
        local CreatedAt = os.date("%d/%m/%y", os.time(t));
        Utils.Notify(Caller, "Command", ("%s's age is %s (%s)"):format(v.Name, AccountAge, CreatedAt));
    end
end)

AddCommand("nosales", {}, "no purchase prompt notifications will be shown", {}, function()
    CoreGui.PurchasePromptApp.PurchasePromptUI.Visible = false
    return "You'll no longer recive sale prompts"
end)

AddCommand("volume", {"vol"}, "changes your game volume", {}, function(Caller, Args)
    local Volume = tonumber(Args[1]);
    if (not Volume or Volume > 10 or Volume < 0) then
        return "volume must be a number between 0-10";
    end
    UserSettings():GetService("UserGameSettings").MasterVolume = Volume / 10
    return "volume set to " .. Volume
end)

AddCommand("antikick", {}, "client sided bypasses to kicks", {}, function()
    local mt = getrawmetatable(game);
    local oldnc = mt.__namecall
    setreadonly(mt, false);
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod():lower();
        if (method == "kick") then
            Utils.Notify(Caller or LocalPlayer, "Attempt to kick", ("attempt to kick with message \"%s\""):format(tostring(args[1])));
            return wait(9e9);
        end
        return oldnc(self, ...);
    end)
end)

AddCommand("respawn", {}, "respawns your character", {3}, function()
    local OldPos = GetRoot().CFrame
    GetCharacter():BreakJoints();
    LocalPlayer.CharacterAdded:Wait();
    LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = OldPos
    return "successfully respawned?"
end)

AddCommand("reset", {}, "resets your character", {3}, function()
    GetCharacter():BreakJoints();
end)

AddCommand("refresh", {"re"}, "refreshes your character", {3}, function(Caller)
    ReplaceCharacter();
    wait(Players.RespawnTime - 0.03);
    local OldPos = GetRoot().CFrame
    ReplaceHumanoid()
    LocalPlayer.CharacterAdded:Wait()
    LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = OldPos
    return "character refreshed"
end)

AddCommand("addalias", {}, "adds an alias to a command", {}, function(Caller, Args)
    local Command = Args[1]
    local Alias = Args[2]
    if (CommandsTable[Command]) then
        local Add = CommandsTable[Command]
        Add.Name = Alias
        CommandsTable[Alias] = Add
        return ("%s is now an alias of %s"):format(Alias, Command);
    else
        return Command .. " is not a valid command"
    end
end)

AddCommand("removealias", {}, "removes an alias from a command", {}, function(Caller, Args) -- todo: fix it removing actual commands when doing so
    local Command = Args[1]
    local Alias = Args[2]
    if (not CommandsTable[Command]) then
        return Command .. " is not a valid command"
    end
    if (not CommandsTable[Alias]) then
        return Alias .. " is not an alias"
    end
    
    if (CommandsTable[Alias].Name ~= Alias) then
        local Cmd = CommandsTable[Alias]
        CommandsTable[Alias] = nil
        return ("removed alias %s from %s"):format(Alias, Cmd.Name);
    end
    return "you can't remove commands"
end)

AddCommand("chatlogs", {"clogs"}, "enables chatlogs", {}, function()
    local MessageClone = ChatLogs.Frame.List:Clone()

    Utils.ClearAllObjects(ChatLogs.Frame.List)
    ChatLogs.Visible = true

    local Tween = Utils.TweenAllTransToObject(ChatLogs, .25, ChatLogsTransparencyClone)

    ChatLogs.Frame.List:Destroy()
    MessageClone.Parent = ChatLogs.Frame

    for i, v in next, ChatLogs.Frame.List:GetChildren() do
        if (not v:IsA("UIListLayout")) then
            Utils.Tween(v, "Sine", "Out", .25, {
                TextTransparency = 0
            })
        end
    end

    local ChatLogsListLayout = ChatLogs.Frame.List.UIListLayout

    ChatLogsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ChatLogs.Frame.List.CanvasPosition = Vector2.new(0, ChatLogsListLayout.AbsoluteContentSize.Y);
    end)

    Utils.Tween(ChatLogs.Frame.List, "Sine", "Out", .25, {
        ScrollBarImageTransparency = 0
    })

end)

AddCommand("btools", {}, "gives you btools", {3}, function(Caller, Args)
    local BP = LocalPlayer.Backpack
    for i = 1, 4 do
        Instance.new("HopperBin", BP).BinType = i
    end
    return "client sided btools loaded"
end)

AddCommand("spin", {}, "spins your character (optional: speed)", {}, function(Caller, Args, Tbl)
    local Speed = Args[1] or 5
    local Spin = Instance.new("BodyAngularVelocity");
    Spin.Parent = GetRoot();
    Spin.MaxTorque = Vector3.new(0, math.huge, 0);
    Spin.AngularVelocity = Vector3.new(0, Speed, 0);
    Tbl[#Tbl + 1] = Spin
    return "started spinning"
end)

AddCommand("unspin", {}, "unspins your character", {}, function(Caller, Args)
    local Spinning = LoadCommand("spin").CmdExtra
    for i, v in next, Spinning do
        v:Destroy();
    end
    return "stopped spinning"
end)

AddCommand("goto", {"to"}, "teleports yourself to the other character", {3, "1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        GetRoot().CFrame = GetRoot(v).CFrame * CFrame.new(-5, 0, 0);
    end
end)

AddCommand("loopgoto", {"loopto"}, "loop teleports yourself to the other character", {3, "1"}, function(Caller, Args, Tbl)
    local Target = GetPlayer(Args[1])[1]
    local Connection = RunService.Heartbeat:Connect(function()
        GetRoot().CFrame = GetRoot(Target).CFrame * CFrame.new(0, 0, 2);
    end)
    
    Tbl[Target.Name] = Connection
    AddPlayerConnection(LocalPlayer, Connection);
    AddConnection(Connection);
    return "now looping to " .. Target.name
end)

AddCommand("unloopgoto", {"unloopto"}, "removes loop teleportation to the other character", {}, function(Caller)
    local Looping = LoadCommand("loopgoto").CmdExtra;
    if (not next(Looping)) then
        return "you aren't loop teleporting to anyone"
    end
    for i, v in next, Looping do
        if (type(v) == 'userdata' and v.Disconnect) then
            v:Disconnect();
        end
    end
    return "loopgoto disabled"
end)

AddCommand("tweento", {"tweengoto"}, "tweens yourself to the other person", {3, "1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        TweenService:Create(GetRoot(), TweenInfo.new(2), {CFrame = GetRoot(v).CFrame}):Play();
    end
end)

AddCommand("truesight", {"ts"}, "shows all the transparent stuff", {}, function(Caller, Args, Tbl)
    local amount = 0
    local time = tick() or os.clock();
    for i, v in next, Workspace:GetDescendants() do
        if (v:IsA("Part") and v.Transparency >= 0.3) then
            Tbl[v] = v.Transparency
            v.Transparency = 0
            amount = amount + 1
        end
    end

    return ("%d items shown in %.3f (s)"):format(amount, (tick() or os.clock()) - time);
end)

AddCommand("notruesight", {"nots"}, "removes truesight", {}, function(Caller, Args)
    local showing = LoadCommand("truesight").CmdExtra
    local time = tick() or os.clock();
    for i, v in next, showing do
        i.Transparency = v
    end
    
    return ("%d items hidden in %.3f (s)"):format(#showing, (tick() or os.clock()) - time);
end)

AddCommand("xray", {}, "see through wallks", {}, function(Caller, Args, Tbl)
    for i, v in next, Workspace:GetDescendants() do
        if v:IsA("Part") and v.Transparency <= 0.3 then
            Tbl[v] = v.Transparency
            v.Transparency = 0.3
        end
    end
    return "xray is now on"
end)

AddCommand("noxray", {"unxray"}, "stops xray", {}, function(Caller, Args)
    local showing = LoadCommand("xray").CmdExtra
    local time = tick() or os.clock();
    for i, v in next, showing do
        i.Transparency = v
    end
    return "xray is now off"
end)

AddCommand("nolights", {}, "removes all lights", {}, function(Caller, Args, Tbl)
    for i, v in next, game:GetDescendants() do
        if (v:IsA("PointLight") or v:IsA("SurfaceLight") or v:IsA("SpotLight")) then
            Tbl[v] = v.Parent
            v.Parent = nil
        end
    end
    Lighting.GlobalShadows = true
    return "removed all lights"
end)

AddCommand("revertnolights", {"lights"}, "reverts nolights", {}, function()
    local Lights = LoadCommand("nolights").CmdExtra
    for i, v in next, Lights do
        i.Parent = v
    end
    return "fullbright disabled"
end)


AddCommand("fullbright", {"fb"}, "turns on fullbright", {}, function(Caller, Args, Tbl)
    for i, v in next, game:GetDescendants() do
        if (v:IsA("PointLight") or v:IsA("SurfaceLight") or v:IsA("SpotLight")) then
            Tbl[v] = v.Range
            v.Enabled = true
            v.Shadows = false
            v.Range = math.huge
        end
    end
    Lighting.GlobalShadows = false
    return "fullbright enabled"
end)

AddCommand("nofullbright", {"revertlights", "unfullbright", "nofb"}, "reverts fullbright", {}, function()
    local Lights = LoadCommand("fullbright").CmdExtra
    for i, v in next, Lights do
        i.Range = v
    end
    Lighting.GlobalShadows = false
    return "fullbright disabled"
end)

AddCommand("swim", {}, "allows you to use the swim state", {3}, function(Caller, Args, Tbl)
    local Humanoid = GetHumanoid();
    for i, v in next, Enum.HumanoidStateType:GetEnumItems() do
        Humanoid:SetStateEnabled(v, false);
    end
    Tbl[1] = Humanoid:GetState();
    Humanoid:ChangeState(Enum.HumanoidStateType.Swimming);
    Workspace.Gravity = 0
    coroutine.wrap(function()
        Humanoid.Died:Wait();
        Workspace.Gravity = 198
    end)()
    return "swimming enabled"
end)

AddCommand("unswim", {"noswim"}, "removes swim", {}, function(Caller, Args)
    local Humanoid = GetHumanoid();
    for i, v in next, Enum.HumanoidStateType:GetEnumItems() do
        Humanoid:SetStateEnabled(v, true);
    end
    Humanoid:ChangeState(LoadCommand("swim").CmdExtra[1]);
    Workspace.Gravity = 198
    return "swimming disabled"
end)

AddCommand("disableanims", {"noanims"}, "disables character animations", {3}, function(Caller, Args)
    GetCharacter():FindFirstChild("Animate").Disabled = true
    return "animations disabled"
end)

AddCommand("enableanims", {"anims"}, "enables character animations", {3}, function(Caller, Args)
    GetCharacter():FindFirstChild("Animate").Disabled = false
    return "animations enabled"
end)

-- this fly is not mine as you can tell
AddCommand("fly", {}, "flies your character", {3}, function(Caller, Args, Tbl)
    local hrp = GetRoot();
    flying = true
    flyspeed = tonumber(Args[1]) or 0.3
    local keys = {
        a = false,
        d = false,
        w = false,
        s = false
    } 
    local function start()
        local pos = Instance.new("BodyPosition", hrp)
        local gyro = Instance.new("BodyGyro", hrp)
        pos.maxForce = Vector3.new(math.huge, math.huge, math.huge)
        pos.position = hrp.Position
        gyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        gyro.cframe = hrp.CFrame
        repeat
            wait();
            GetHumanoid().PlatformStand = true
            local new = gyro.cframe - gyro.cframe.p + pos.position
            if not keys.w and not keys.s and not keys.a and not keys.d then
                speed = 1
            end
            if (keys.w or keys.s) then 
                new = keys.w and (new+Workspace.CurrentCamera.CoordinateFrame.lookVector*speed) or (new-Workspace.CurrentCamera.CoordinateFrame.lookVector*speed) 
                speed = speed + (0.01 * (flyspeed or 0.3))
            end
            if (keys.d or keys.a) then 
                new = new * CFrame.new(keys.d and speed or -speed,0,0)
                speed = speed + (0.01 * (flyspeed or 0.3))
            end
            if (speed > 5 * flyspeed or 0.3) then
                speed = 5 * (flyspeed or 0.3)
            end
            pos.position = new.p
            if (keys.w or keys.s) then
                gyro.cframe = Workspace.CurrentCamera.CoordinateFrame*CFrame.Angles(-math.rad(speed*15),0,0)
            else
                gyro.cframe = Workspace.CurrentCamera.CoordinateFrame
            end
        until not flying
        
        if gyro then gyro:Destroy() end
        if pos then pos:Destroy() end
        flying = false
        GetHumanoid().PlatformStand = false
        speed = 0
    end
    e1 = Mouse.KeyDown:connect(function(key)
        if not hrp or not hrp.Parent then flying=false e1:disconnect() e2:disconnect() return end
        if key=="w" then
            keys.w=true
        elseif key=="s" then
            keys.s=true
        elseif key=="a" then
            keys.a=true
        elseif key=="d" then
            keys.d=true
        end
    end)
    e2 = Mouse.KeyUp:connect(function(key)
        if key=="w" then
            keys.w=false
        elseif key=="s" then
            keys.s=false
        elseif key=="a" then
            keys.a=false
        elseif key=="d" then
            keys.d=false
        end
    end)
    Tbl[#Tbl + 1] = flying	 
    start();
end)

AddCommand("flyspeed", {"fs"}, "changes the fly speed", {3, "1"}, function(Caller, Args)
    local Speed = tonumber(Args[1]);
    flyspeed = Speed or flyspeed
    return Speed and "your fly speed is now " .. Speed or "flyspeed must be a number"
end)

AddCommand("unfly", {}, "unflies your character", {3}, function()
    flying = false
    return "stopped flying"
end)

AddCommand("fov", {}, "sets your fov", {}, function(Caller, Args)
    local Amount = tonumber(Args[1]) or 70
    Workspace.CurrentCamera.FieldOfView = Amount
end)

AddCommand("noclip", {}, "noclips your character", {3}, function(Caller, Args, Tbl)
    local Char = GetCharacter()
    local Noclipping = RunService.Stepped:Connect(function()
        for i, v in next, Char:GetChildren() do
            if (v:IsA("BasePart") and v.CanCollide) then
                v.CanCollide = false
            end
        end
    end)
    Tbl[1] = Noclipping
    Utils.Notify(Caller, "Command", "noclip enabled");
    GetHumanoid().Died:Wait();
    Noclipping:Disconnect();
    return "noclip disabled"
end)

AddCommand("clip", {}, "disables noclip", {}, function(Caller, Args)
    local Noclip = LoadCommand("noclip").CmdExtra[1]
    if (not Noclip) then
        return "you aren't in noclip"
    else
        Noclip:Disconnect();
        return "noclip disabled"
    end
end)

AddCommand("lastcommand", {"lastcmd"}, "executes the last command", {}, function(Caller)
    local Command = LastCommand
    LoadCommand(Command[1]).Function()(Command[2], Command[3], Command[4]);
    return ("command %s executed"):format(laCommandst[1]);
end)

AddCommand("whisper", {}, "whispers something to another user", {"2"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local Message = table.concat(table.shift(Args), " ");
    local ChatRemote = ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
    for i, v in next, Target do
        ChatRemote:FireServer(("/w %s %s"):format(v.Name, Message), "All");
        Utils.Notify(Caller or LocalPlayer, "Command", "Message sent to " .. v.Name);
    end
end)

AddCommand("rejoin", {"rj"}, "rejoins the game you're currently in", {}, function(Caller)
    if (Caller == LocalPlayer) then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId);
        return "Rejoining..."
    end
end)

AddCommand("serverhop", {"sh"}, "switches servers (optional: min or max)", {{"min", "max"}}, function(Caller, Args)
    if (Caller == LocalPlayer) then
        Utils.Notify(Caller or LocalPlayer, nil, "Looking for servers...");

        local Servers = HttpService:JSONDecode(game:HttpGetAsync(("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId))).data
        if (#Servers >= 1) then
            Servers = table.filter(Servers, function(i,v)
                return v.playing ~= v.maxPlayers and v.id ~= game.JobId
            end)
            local Server
            local Option = Args[1] or ""
            if (Option:lower() == "min") then
                Server = Servers[#Servers]
            elseif (Option:lower() == "max") then
                Server = Servers[1]
            else
                Server = Servers[math.random(1, #Servers)]
            end
            TeleportService:TeleportToPlaceInstance(game.PlaceId, Server.id);
            return ("joining server (%d/%d players)"):format(Server.playing, Server.maxPlayers);
        else
            return "no servers foudn"
        end
    end
end)

AddCommand("whitelist", {"wl"}, "whitelists a user so they can use commands", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        AdminUsers[#AdminUsers + 1] = v
        Utils.Notify(v, "Whitelisted", ("You (%s) are whitelisted to use commands"):format(v.Name));
    end
end)

AddCommand("whitelisted", {"whitelistedusers"}, "shows all the users whitelisted to use commands", {}, function(Caller)
    return next(AdminUsers) and table.concat(table.map(AdminUsers, function(i,v) return v.Name end), ", ") or "no users whitelisted"
end)

AddCommand("blacklist", {"bl"}, "blacklists a whitelisted user", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        if (table.find(AdminUsers, v)) then
            table.remove(AdminUsers, table.indexOf(AdminUsers, v));
        end
    end
end)

AddCommand("exceptions", {}, "blocks user from being used in stuff like kill all", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        Exceptions[#Exceptions + 1] = v
        Utils.Notify(Caller, "Command", v.Name .. " is added to the exceptions list");
    end
end)

AddCommand("noexception", {}, "removes user from exceptions list", {"1"}, function(Caller, Args)
    for i2, v2 in next, Exceptions do
        if (v2.Name == Args[1]) then
            v2 = nil
        end
        Utils.Notify(Caller, "Command", Args[1] .. " is removed from the exceptions list");
    end
end)

AddCommand("clearexceptions", {}, "removes users from exceptions list", {}, function(Caller, Args)
    Exceptions = {}
    return "exceptions list cleared"
end)

AddCommand("commands", {"cmds"}, "shows you all the commands listed in fates admin", {}, function()
    Commands.Visible = true
    Utils.TweenAllTransToObject(Commands, .25, CommandsTransparencyClone);
    return "Commands Loaded"
end)

AddCommand("killscript", {}, "kills the script", {}, function(Caller)
    if (Caller == LocalPlayer) then
        table.deepsearch(Connections, function(i,v)
            if (type(v) == 'userdata') then
                v:Disconnect();
                v = nil
            end
        end)
        
        UI:Destroy();
        getgenv().F_A = nil
        for i, v in next, getfenv() do
            getfenv()[i] = nil
        end
    end
end)

AddCommand("commandline", {"cmd", "cli"}, "brings up a cli, can be useful for when games detect by textbox", {}, function()
    if (not CLI) then
        CLI = true
        while true do
            rconsoleprint("@@WHITE@@");
            rconsoleprint("CMD >");
            local Input = rconsoleinput("");
            local CommandArgs = Input:split(" ");
            local Command = LoadCommand(CommandArgs[1]);
            local Args = table.shift(CommandArgs);
            if (Command and CommandArgs[1] ~= "") then
                if (Command.ArgsNeeded > #Args) then
                    rconsoleprint("@@YELLOW@@");
                    return rconsoleprint(("Insuficient Args (you need %d)\n"):format(Command.ArgsNeeded));
                end

                local Success, Err = pcall(function()
                    local Executed = Command.Function()(LocalPlayer, Args, Command.CmdExtra);
                    if (Executed) then
                        rconsoleprint("@@GREEN@@");
                        rconsoleprint(Executed .. "\n");
                    end
                    LastCommand = {Command, plr, Args, Command.CmdExtra}
                end);
                if (not Success and Debug) then
                    rconsoleerr(Err);
                end
            else
                rconsolewarn("couldn't find the command " .. CommandArgs[1] .. "\n");
            end
        end
    end
end)

AddCommand("setprefix", {}, "changes your prefix", {"1"}, function(Caller, Args)
    local PrefixToSet = Args[1]
    if (PrefixToSet:match("%A")) then
        Prefix = PrefixToSet
        Utils.Notify(Caller, "Command", ("your new prefix is now '%s'"):format(PrefixToSet));
        return "use command saveprefix to save your prefix"
    else
        return "prefix must be a symbol"
    end
end)

AddCommand("saveprefix", {}, "saves your prefix", {}, function(Caller, Args)
    if (GetConfig().Prefix == Prefix) then
        return "nothing to save, prefix is the same"
    else
        SetConfig({["Prefix"]=Prefix});
        return "saved prefix " .. Prefix
    end
end)

AddCommand("clear", {"clearcli", "cls"}, "clears the commandline (if open)", {}, function()
    if (CLI) then
        rconsoleclear();
        rconsolename("Admin Command Line");
        rconsoleprint("\nCommand Line:\n");
        return "cleared console"
    end
    return "cli is not open"
end)

AddCommand("widebar", {}, "widens the command bar (toggle)", {}, function(Caller, Args)
    WideBar = not WideBar
    Utils.Tween(CommandBar, "Quint", "Out", .5, {
        Position = UDim2.new(0.5, WideBar and -200 or -100, 1, 5) -- tween -110
    })
    Utils.Tween(CommandBar, "Quint", "Out", .5, {
        Size = UDim2.new(0, WideBar and 400 or 200, 0, 35) -- tween -110
    })
    return ("widebar %s"):format(WideBar and "enabled" or "disabled")
end)

---@param i any
---@param plr any
PlrChat = function(i, plr)
    if (not Connections.Players[plr.Name]) then
        Connections.Players[plr.Name] = {}
        Connections.Players[plr.Name].Connections = {}
    end
    Connections.Players[plr.Name].ChatCon = plr.Chatted:Connect(function(raw)
        
        local message = raw:lower();

        if (ChatLogsEnabled) then
            local time = os.date("%X");
            local Text = ("%s - [%s]: %s"):format(time, plr.Name, raw);
            local Clone = ChatLogMessage:Clone();

            Clone.Text = Text
            Clone.Visible = true
            Clone.TextTransparency = 1
            Clone.Parent = ChatLogs.Frame.List
            
            Utils.Tween(Clone, "Sine", "Out", .25, {
                TextTransparency = 0
            })

            ChatLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, ChatLogs.Frame.List.UIListLayout.AbsoluteContentSize.Y);
        end

        if (raw:startsWith("/e")) then
            raw = raw:sub(4, #raw);
        elseif (raw:startsWith(Prefix)) then
            raw = raw:sub(#Prefix + 1, #raw);
        else
            return
        end

        message = raw:trim():lower();
        
        if (table.find(AdminUsers, plr) or plr == LocalPlayer) then
            local CommandArgs = message:split(" ");
            local Command, LoadedCommand = CommandArgs[1], LoadCommand(CommandArgs[1]);
            local Args = table.shift(CommandArgs);

            if (LoadedCommand) then
                if (LoadedCommand.ArgsNeeded > #Args) then
                    return Utils.Notify(plr, "Error", ("Insuficient Args (you need %d)"):format(LoadedCommand.ArgsNeeded))
                end

                local Success, Err = pcall(function()
                    local Executed = LoadedCommand.Function()(plr, Args, LoadedCommand.CmdExtra);
                    if (Executed) then
                        Utils.Notify(plr, "Command", Executed);
                    end
                    LastCommand = {Command, plr, Args, LoadedCommand.CmdExtra}
                end);
                if (not Success and Debug) then
                    warn(Err);
                end
            else
                Utils.Notify(plr, "Error", ("couldn't find the command %s"):format(Command));
            end
        end
    end)
end

-- parent ui function
ParentGui = function(Gui)
    Gui.Name = HttpService:GenerateGUID(false):gsub('-', ''):sub(1, math.random(25, 30))

    if ((not is_sirhurt_closure) and (syn and syn.protect_gui)) then
        syn.protect_gui(Gui);
        Gui.Parent = CoreGui
    elseif (CoreGui:FindFirstChild("RobloxGui")) then
        Gui.Parent = CoreGui.RobloxGui
    else
        Gui.Parent = CoreGui
    end
    Guis[#Guis + 1] = Gui 
    return Gui
end

-- make all elements not visible
Notification.Visible = false
Stats.Visible = false
Utils.SetAllTrans(CommandBar)
Utils.SetAllTrans(ChatLogs)
Utils.SetAllTrans(AdminChatLogs)
Commands.Visible = false
Animations.Visible = false
ChatLogs.Visible = false
AdminChatLogs.Visible = false

-- make the ui draggable
Utils.Draggable(Commands)
Utils.Draggable(Animations)
Utils.Draggable(ChatLogs)
Utils.Draggable(AdminChatLogs)

-- parent ui
ParentGui(UI)
Connections.UI = {}
-- tweencommand bar on prefix
Connections.UI.CommandBarInput = UserInputService.InputBegan:Connect(function(Input, GameProccesed)
    if (Input.KeyCode == CommandBarPrefix and (not GameProccesed)) then
        CommandBarOpen = not CommandBarOpen

        local TransparencyTween = CommandBarOpen and Utils.TweenAllTransToObject or Utils.TweenAllTrans
        local Tween = TransparencyTween(CommandBar, .5, CommandBarTransparencyClone)

        -- tween position
        if (CommandBarOpen) then
            Utils.Tween(CommandBar, "Quint", "Out", .5, {
                Position = UDim2.new(0.5, WideBar and -200 or -100, 1, -110) -- tween -110
            })

            CommandBar.Input:CaptureFocus()
            coroutine.wrap(function()
                wait()
                CommandBar.Input.Text = ""
            end)()
        else
            Utils.Tween(CommandBar, "Quint", "Out", .5, {
                Position = UDim2.new(0.5, WideBar and -200 or -100, 1, 5) -- tween 5
            })
        end
    end
end)

-- smooth scroll commands
Utils.SmoothScroll(Commands.Frame.List, .14)
Utils.SmoothScroll(Animations.Frame.List, .14)

-- fill commands with commands!
for _, v in next, CommandsTable do -- auto size
    if (not Commands.Frame.List:FindFirstChild(v.Name)) then
        local Clone = Command:Clone()

        Utils.Hover(Clone, "BackgroundColor3") -- add tooltip
        Utils.ToolTip(Clone, v.Name .. "\n" .. v.Description)
        Clone.CommandText.Text = v.Name .. (#v.Aliases > 0 and " (" ..table.concat(v.Aliases, ", ") .. ")" or "")
        Clone.Name = v.Name
        Clone.Visible = true
        Clone.Parent = Commands.Frame.List
    end
end



Utils.Click(Commands.Close, "TextColor3")
Commands.Frame.List.CanvasSize = UDim2.fromOffset(0, Commands.Frame.List.UIListLayout.AbsoluteContentSize.Y)
Animations.Frame.List.CanvasSize = UDim2.fromOffset(0, Animations.Frame.List.UIListLayout.AbsoluteContentSize.Y)
CommandsTransparencyClone = Commands:Clone()
AnimationsTransparencyClone = Animations:Clone()
Utils.SetAllTrans(Commands)
Utils.SetAllTrans(Animations)
Utils.Click(ChatLogs.Clear, "BackgroundColor3")
Utils.Click(ChatLogs.Save, "BackgroundColor3")
Utils.Click(ChatLogs.Toggle, "BackgroundColor3")
Utils.Click(ChatLogs.Close, "TextColor3")

Utils.Click(AdminChatLogs.Clear, "BackgroundColor3")
Utils.Click(AdminChatLogs.Save, "BackgroundColor3")
Utils.Click(AdminChatLogs.Toggle, "BackgroundColor3")
Utils.Click(AdminChatLogs.Close, "TextColor3")

-- close tween commands
Connections.CommandsClose = Commands.Close.MouseButton1Click:Connect(function()
    local Tween = Utils.TweenAllTrans(Commands, .25)

    Tween.Completed:Wait()
    Commands.Visible = false
end)

-- command search
Connections.UI.CommandsSearch = Commands.Search:GetPropertyChangedSignal("Text"):Connect(function()
    local Text = Commands.Search.Text
    for _, v in next, Commands.Frame.List:GetChildren() do
        if (v:IsA("Frame")) then
            local Command = v.CommandText.Text

            v.Visible = string.find(string.lower(Command), Text, 1, true)
        end
    end

    Commands.Frame.List.CanvasSize = UDim2.fromOffset(0, Commands.Frame.List.UIListLayout.AbsoluteContentSize.Y)
end)

-- close chatlogs
Connections.UI.ChatLogsClose = ChatLogs.Close.MouseButton1Click:Connect(function()
    local Tween = Utils.TweenAllTrans(ChatLogs, .25)

    Tween.Completed:Wait()
    ChatLogs.Visible = false
end)
Connections.UI.AdminChatLogsClose = AdminChatLogs.Close.MouseButton1Click:Connect(function()
    local Tween = Utils.TweenAllTrans(AdminChatLogs, .25)

    Tween.Completed:Wait()
    AdminChatLogs.Visible = false
end)

ChatLogs.Toggle.Text = ChatLogsEnabled and "Enabled" or "Disabled"
-- enable chat logs
Connections.UI.ChatLogsToggle = ChatLogs.Toggle.MouseButton1Click:Connect(function()
    ChatLogsEnabled = not ChatLogsEnabled
    ChatLogs.Toggle.Text = ChatLogsEnabled and "Enabled" or "Disabled"
end)
Connections.UI.AdminChatLogsToggle = AdminChatLogs.Toggle.MouseButton1Click:Connect(function()
    AdminChatLogsEnabled = AdminChatLogsEnabled
    AdminChatLogs.Toggle.Text = AdminChatLogsEnabled and "Enabled" or "Disabled"
end)

-- clear chat logs
Connections.UI.ChatLogsClear = ChatLogs.Clear.MouseButton1Click:Connect(function()
    Utils.ClearAllObjects(ChatLogs.Frame.List)
    ChatLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, 0)
end)
Connections.UI.AdminChatLogsClear = AdminChatLogs.Clear.MouseButton1Click:Connect(function()
    Utils.ClearAllObjects(AdminChatLogs.Frame.List)
    AdminChatLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, 0)
end)

-- chat logs search
Connections.UI.ChatLogs = ChatLogs.Search:GetPropertyChangedSignal("Text"):Connect(function()
    local Text = ChatLogs.Search.Text

    for _, v in next, ChatLogs.Frame.List:GetChildren() do
        if (not v:IsA("UIListLayout")) then
            local Message = v.Text:split(": ")[2]
            v.Visible = string.find(string.lower(Message), Text, 1, true)
        end
    end

    ChatLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, ChatLogs.Frame.List.UIListLayout.AbsoluteContentSize.Y)
end)

Connections.UI.AdminChatLogs = AdminChatLogs.Search:GetPropertyChangedSignal("Text"):Connect(function()
    local Text = AdminChatLogs.Search.Text

    for _, v in next, AdminChatLogs.Frame.List:GetChildren() do
        if (not v:IsA("UIListLayout")) then
            local Message = v.Text

            v.Visible = string.find(string.lower(Message), Text, 1, true)
        end
    end

    -- AdminChatLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, AdminChatLogs.Frame.List.UIListLayout.AbsoluteContentSize.Y)
end)

Connections.UI.ChatLogsSave = ChatLogs.Save.MouseButton1Click:Connect(function()
    local GameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
    local String =  ("Fates Admin Chatlogs for %s (%s)\n\n"):format(GameName, os.date());
    local TimeSaved = tostring(os.date("%x")):gsub("/","-") .. " " .. tostring(os.date("%X")):gsub(":","-");
    local Name = ("fates-admin/chatlogs/%s (%s).txt"):format(GameName, TimeSaved);
    for i, v in next, ChatLogs.Frame.List:GetChildren() do
        if (not v:IsA("UIListLayout")) then
            String = ("%s%s\n"):format(String, v.Text);
        end
    end
    writefile(Name, String);
    Utils.Notify(LocalPlayer, "Saved", "Chat logs saved!");
end)
WideBar = false
Connections.CommandBar = CommandBar.Input.FocusLost:Connect(function()
    local Text = CommandBar.Input.Text:trim();
    local CommandArgs = Text:split(" ");

    CommandBarOpen = false 

    Utils.TweenAllTrans(CommandBar, .5)
    Utils.Tween(CommandBar, "Quint", "Out", .5, {
        Position = UDim2.new(0.5, WideBar and -200 or -100, 1, 5); -- tween 5
    })

    local Command, LoadedCommand = CommandArgs[1], LoadCommand(CommandArgs[1]);
    local Args = table.shift(CommandArgs);

    if (LoadedCommand and Command ~= "") then
        if (LoadedCommand.ArgsNeeded > #Args) then
            return Utils.Notify(plr, "Error", ("Insuficient Args (you need %d)"):format(LoadedCommand.ArgsNeeded))
        end

        local Success, Err = pcall(function()
            local Executed = LoadedCommand.Function()(LocalPlayer, Args, LoadedCommand.CmdExtra);
            if (Executed) then
                Utils.Notify(plr, "Command", Executed);
            end
            LastCommand = {Command, LocalPlayer, Args, LoadedCommand.CmdExtra}
        end);
        if (not Success and Debug) then
            warn(Err);
        end
    else
        Utils.Notify(plr, "Error", ("couldn't find the command %s"):format(Command));
    end
end)

-- auto correct
Connections.CommandBarChanged = CommandBar.Input:GetPropertyChangedSignal("Text"):Connect(function() -- make it so that every space a players name will appear
    local Text = string.lower(CommandBar.Input.Text)
    local Prediction = CommandBar.Input.Predict
    local PredictionText = Prediction.Text

    local Args = string.split(Text, " ")

    Prediction.Text = ""
    if (Text == "") then
        return
    end

    local FoundCommand = false
    local FoundAlias = false
    CommandArgs = CommandArgs or {}
    if (not CommandsTable[Args[1]]) then
        for _, v in next, CommandsTable do
            local CommandName = v.Name
            local Aliases = v.Aliases
            local FoundAlias
    
            if (Utils.MatchSearch(Args[1], CommandName)) then -- better search
                Prediction.Text = CommandName
                CommandArgs = v.Args or {}
                break
            end
    
            for _, v2 in next, Aliases do
                if (Utils.MatchSearch(Args[1], v2)) then
                    FoundAlias = true
                    Prediction.Text = v2
                    CommandArgs = v2.Args or {}
                    break
                end
    
                if (FoundAlias) then
                    break
                end
            end
        end
    end

    for i, v in next, Args do -- make it get more players after i space out
        if (i > 1 and v ~= "") then
            local Predict = ""
            if (#CommandArgs >= 1) then
                for i2, v2 in next, CommandArgs do
                    if (v2:lower() == "player") then
                        Predict = Utils.GetPlayerArgs(v) or Predict;
                    else
                        Predict = Utils.MatchSearch(v, v2) and v2 or Predict
                    end
                end
            else
                Predict = Utils.GetPlayerArgs(v) or Predict;
            end
            Prediction.Text = string.sub(Text, 1, #Text - #Args[#Args]) .. Predict
            local split = v:split(",");
            if (next(split)) then
                for i2, v2 in next, split do
                    if (i2 > 1 and v2 ~= "") then
                        local PlayerName = Utils.GetPlayerArgs(v2)
                        Prediction.Text = string.sub(Text, 1, #Text - #split[#split]) .. (PlayerName or "")
                    end
                end
            end
        end
    end

    if (string.find(Text, "\t")) then -- remove tab from preditction text also
        CommandBar.Input.Text = PredictionText
        CommandBar.Input.CursorPosition = #CommandBar.Input.Text + 1
    end
end)

if (ChatBar) then
    Connections.ChatBarChanged = ChatBar:GetPropertyChangedSignal("Text"):Connect(function() -- todo: add detection for /e
        local Text = string.lower(ChatBar.Text)
        local Prediction = PredictionClone
        local PredictionText = PredictionClone.Text
    
        local Args = string.split(table.concat(table.shift(Text:split(""))), " ");
    
        Prediction.Text = ""
        if (not Text:startsWith(Prefix)) then
            return
        end
    
        local FoundCommand = false
        local FoundAlias = false
        CommandArgs = CommandArgs or {}
        if (not rawget(CommandsTable, Args[1])) then
            for _, v in next, CommandsTable do
                local CommandName = v.Name
                local Aliases = v.Aliases
                local FoundAlias
        
                if (Utils.MatchSearch(Args[1], CommandName)) then -- better search
                    Prediction.Text = Prefix .. CommandName
                    FoundCommand = true
                    CommandArgs = v.Args or {}
                    break
                end
        
                for _, v2 in next, Aliases do
                    if (Utils.MatchSearch(Args[1], v2)) then
                        FoundAlias = true
                        Prediction.Text = v2
                        CommandArgs = v.Args or {}
                        break
                    end
        
                    if (FoundAlias) then
                        break
                    end
                end
            end
        end
    
        for i, v in next, Args do -- make it get more players after i space out
            if (i > 1 and v ~= "") then
                local Predict = ""
                if (#CommandArgs >= 1) then
                    for i2, v2 in next, CommandArgs do
                        if (v2:lower() == "player") then
                            Predict = Utils.GetPlayerArgs(v) or Predict;
                        else
                            Predict = Utils.MatchSearch(v, v2) and v2 or Predict
                        end
                    end
                else
                    Predict = Utils.GetPlayerArgs(v) or Predict;
                end
                Prediction.Text = string.sub(Text, 1, #Text - #Args[#Args]) .. Predict
                local split = v:split(",");
                if (next(split)) then
                    for i2, v2 in next, split do
                        if (i2 > 1 and v2 ~= "") then
                            local PlayerName = Utils.GetPlayerArgs(v2)
                            Prediction.Text = string.sub(Text, 1, #Text - #split[#split]) .. (PlayerName or "")
                        end
                    end
                end
            end
        end
    
        if (string.find(Text, "\t")) then -- remove tab from preditction text also
            ChatBar.Text = PredictionText
            ChatBar.CursorPosition = #ChatBar.Text + 2
        end
    end)
end

CurrentPlayers = Players:GetPlayers();

table.forEach(CurrentPlayers, function(i,v)
    PlrChat(i,v);
    RespawnTimes[v.Name] = tick();
    v.CharacterAdded:Connect(function()
        RespawnTimes[v.Name] = tick()
    end)
end);

Connections.PlayerAdded = Players.PlayerAdded:Connect(function(plr)
    PlrChat(#Connections.Players + 1, plr);
    RespawnTimes[plr.Name] = tick();
    plr.CharacterAdded:Connect(function()
        RespawnTimes[plr.Name] = tick();
    end)
end)

Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(plr)
    if (Connections.Players[plr.Name]) then
        if (Connections.Players[plr.Name].ChatCon) then
            Connections.Players[plr.Name].ChatCon:Disconnect();
        end
        Connections.Players[plr.Name] = nil
    end
    if (RespawnTimes[plr.Name]) then
        RespawnTimes[plr.Name] = nil
    end
end)

getgenv().F_A = {
    Loaded = true,
    Utils = Utils
}

Utils.Notify(LocalPlayer, "Loaded", ("script loaded in %.3f seconds"):format((tick() or os.clock()) - start));
Utils.Notify(LocalPlayer, "Welcome", "'cmds' to see all of the commands");