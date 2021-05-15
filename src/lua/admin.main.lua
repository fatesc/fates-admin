--[[
    require - extend
]]

UndetectedMode = syn and UndetectedMode or false -- we need que_on_teleport
if (not UndetectedMode and not game:IsLoaded()) then
    print("fates admin: waiting for game to load...");
    game.Loaded:Wait();
end

if (game:IsLoaded() and UndetectedMode and syn) then
    syn.queue_on_teleport("loadstring(game:HttpGet(\"https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua\"))()");
    return game:GetService("TeleportService").TeleportToPlaceInstance(game:GetService("TeleportService"), game.PlaceId, game.JobId);
end

if (getgenv().F_A and getgenv().F_A.Loaded) then
    return getgenv().F_A.Utils.Notify(nil, "Loaded", "fates admin is already loaded... use 'killscript' to kill", nil);
end

---@type number
local start = start or tick() or os.clock();

RunService = game:GetService("RunService");
Players = game:GetService("Players");
UserInputService = game:GetService("UserInputService");
local Workspace = game:GetService("Workspace");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local StarterPlayer = game:GetService("StarterPlayer");
local StarterPack = game:GetService("StarterPack");
local StarterGui = game:GetService("StarterGui");
local TeleportService = game:GetService("TeleportService");
local CoreGui = game:GetService("CoreGui");
local TweenService = game:GetService("TweenService");
local HttpService = game:GetService("HttpService");
local TextService = game:GetService("TextService");
local MarketplaceService = game:GetService("MarketplaceService")
local Chat = game:GetService("Chat");
local SoundService = game:GetService("SoundService");
local Lighting = game:GetService("Lighting");
 
LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse();
local PlayerGui = LocalPlayer:FindFirstChildOfClass('PlayerGui')

local PluginLibrary = {}

---gets a players character if none arguments passed it will return your character
---@param Plr table
---@return any
local GetCharacter = function(Plr)
    return Plr and Plr.Character or LocalPlayer.Character
end
PluginLibrary.GetCharacter = GetCharacter
---gets a players root if none arguments passed it will return your root
---@param Plr any
---@return any
local GetRoot = function(Plr)
    return Plr and GetCharacter(Plr):FindFirstChild("HumanoidRootPart") or GetCharacter():FindFirstChild("HumanoidRootPart");
end
PluginLibrary.GetRoot = GetRoot
---gets a players humanoid if none arguments passed it will return your humanoid
---@param Plr any
---@return any
local GetHumanoid = function(Plr)
    return Plr and GetCharacter(Plr):FindFirstChildWhichIsA("Humanoid") or GetCharacter():FindFirstChildWhichIsA("Humanoid");
end
PluginLibrary.GetHumanoid = GetHumanoid

---comment
---@param Plr any
---@return any
local GetMagnitude = function(Plr)
    return Plr and (GetRoot(Plr).Position - GetRoot().Position).magnitude or math.huge
end
PluginLibrary.GetHumanoid = GetMagnitude

local Settings = {
    Prefix = "!",
    CommandBarPrefix = "Semicolon"
}
local PluginSettings = {
    PluginsEnabled = true,
    PluginDebug = false,
    DisabledPlugins = {
        ["PluginName"] = true
    }
}

local WriteConfig = function(Destroy)
    local JSON = HttpService:JSONEncode(Settings);
    local PluginJSON = HttpService:JSONEncode(PluginSettings);
    if (isfolder("fates-admin") and Destroy) then
        delfolder("fates-admin");
        writefile("fates-admin/config.json", JSON);
        writefile("fates/admin/pluings/plugin-conf.json", PluginJSON);
    else
        makefolder("fates-admin");
        makefolder("fates-admin/plugins");
        makefolder("fates-admin/chatlogs");
        writefile("fates-admin/config.json", JSON);
        writefile("fates-admin/plugins/plugin-conf.json", PluginJSON);
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

local GetPluginConfig = function()
    if (isfolder("fates-admin") and isfolder("fates-admin/plugins") and isfile("fates-admin/plugins/plugin-conf.json")) then
        return HttpService:JSONDecode(readfile("fates-admin/plugins/plugin-conf.json"));
    else
        WriteConfig();
        return HttpService:JSONDecode(readfile("fates-admin/plugins/plugin-conf.json"));
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

local Prefix = isfolder and GetConfig().Prefix or "!"
local AdminUsers = AdminUsers or {}
local Exceptions = Exceptions or {}
local Connections = {
    Players = {}
}
local CLI = false
local ChatLogsEnabled = true
local GlobalChatLogsEnabled = false
local HttpLogsEnabled = true

---gets the player in your game from string
---@param str string
---@param noerror boolean
---@return table
local GetPlayer = function(str, noerror)
    local CurrentPlayers = table.filter(Players:GetPlayers(), function(i, v)
        return not table.find(Exceptions, v);
    end)
    if (not str) then
        return {}
    end
    str = string.trim(str):lower();
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
            return table.filter(CurrentPlayers, function(i, v) -- removed all arg (but not really) due to commands getting messed up and people getting confused
                return v ~= LocalPlayer
            end)
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
    if (not next(Players) and not noerror) then
        getgenv().F_A.Utils.Notify(LocalPlayer, "Fail", ("Couldn't find player %s"):format(str));
    end
    return Players
end
PluginLibrary.GetPlayer = GetPlayer

--[[
    require - ui
]]

--[[
    require - tags
]]

--[[
    require - utils
]]


-- commands table
local CommandsTable = {}
local LastCommand = {}
local RespawnTimes = {}

--- returns true if the player has a tool
---@param plr any
---@type boolean
local HasTool = function(plr)
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
PluginLibrary.HasTool = HasTool

--- returs true if the player is r6
---@param plr any
local isR6 = function(plr)
    plr = plr or LocalPlayer
    local Humanoid = GetHumanoid(plr);
    if (Humanoid) then
        return Humanoid.RigType == Enum.HumanoidRigType.R6
    end
    return false
end
PluginLibrary.isR6 = isR6

local isSat = function(plr)
    plr = plr or LocalPlayer
    local Humanoid = GetHumanoid(plr)
    if (Humanoid) then
        return Humanoid.Sit
    end
end
PluginLibrary.isSat = isSat

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
        CommandsTable[name] = Cmd
        if (type(aliases) == 'table') then
            for i, v in next, aliases do
                CommandsTable[v] = Cmd
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
local ReplaceHumanoid = function(Hum)
    local Humanoid = Hum or GetHumanoid();
    local NewHumanoid = Humanoid:Clone();
    NewHumanoid.Parent = Humanoid.Parent
    NewHumanoid.Name = Humanoid.Name
    Workspace.Camera.CameraSubject = NewHumanoid
    Humanoid:Destroy();
    return NewHumanoid
end

---replaces your character
local ReplaceCharacter = function()
    local Char = LocalPlayer.Character
    local Model = Instance.new("Model");
    LocalPlayer.Character = Model
    LocalPlayer.Character = Char
    Model:Destroy();
    return Char
end

local CFrameTool = function(tool, pos)
    local RightArm = GetCharacter():FindFirstChild("RightLowerArm") or GetCharacter():FindFirstChild("Right Arm");

    local Arm = RightArm.CFrame * CFrame.new(0, -1, 0, 1, 0, 0, 0, 0, 1, 0, -1, 0);
    local Frame = Arm:toObjectSpace(pos):Inverse();

    tool.Grip = Frame
end

local Sanitize = function(value)
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
local AddPlayerConnection = function(Player, Connection, Tbl)
    if (Tbl) then
        Tbl[#Tbl + 1] = Connection
    else
        Connections.Players[Player.Name].Connections[#Connections.Players[Player.Name].Connections + 1] = Connection
    end
    return Connection
end

---add a connection to the connections table
---@param Connection any
---@param Tbl table
---@param TblOnly boolean
AddConnection = function(Connection, Tbl, TblOnly)
    if (Tbl) then
        Tbl[#Tbl + 1] = Connection
        if (TblOnly) then
            return Connection
        end
    end
    Connections[#Connections + 1] = Connection
    return Connection
end
PluginLibrary.AddConnection = AddConnection

---disables all connections in a running command
---@param Cmd string
local DisableAllCmdConnections = function(Cmd)
    local Command = LoadCommand(Cmd)
    if (Command and Command.CmdExtra) then
        for i, v in next, table.flat(Command.CmdExtra) do
            if (type(v) == 'userdata' and v.Disconnect) then
                v:Disconnect();
            end
        end
    end
    return Command
end

local Keys = {}

AddConnection(UserInputService.InputBegan:Connect(function(Input, GameProccesed)
    if (GameProccesed) then return end
    local KeyCode = tostring(Input.KeyCode):split(".")[3]
    Keys[KeyCode] = true
end));

AddConnection(UserInputService.InputEnded:Connect(function(Input, GameProccesed)
    if (GameProccesed) then return end
    local KeyCode = tostring(Input.KeyCode):split(".")[3]
    if (Keys[KeyCode]) then
        Keys[KeyCode] = false
    end
end));

--[[
    require - plugin
]]

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
        if (#Target == 1 and TempRespawnTimes[v.Name] and isR6(v)) then
            LocalPlayer.Character:Destroy();
            LocalPlayer.CharacterAdded:Wait();
            LocalPlayer.Character:WaitForChild("Humanoid");
            wait()
            Humanoid = ReplaceHumanoid();
        end
    end
    if (GetCharacter().Animate) then
        GetCharacter().Animate.Disabled = true
    end
    coroutine.wrap(function()
        for i, v in next, Target do
                if (GetCharacter(v)) then
                    if (isSat(v)) then
                        Utils.Notify(Caller or LocalPlayer, nil, v.Name .. " is sitting down, could not kill");
                        do break end
                    end

                    if (RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name] and isR6(v)) then
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
                    for i2, v2 in next, Tool:GetDescendants() do
                        if (v2:IsA("Sound")) then
                            v2:Destroy();
                        end
                    end
                    CFrameTool(Tool, GetRoot(v).CFrame)
                    firetouchinterest(TargetRoot, Tool.Handle, 0);
                    wait();
                    firetouchinterest(TargetRoot, Tool.Handle, 1);
                else
                    Utils.Notify(Caller or LocalPlayer, "Fail", v.Name .. " is dead or does not have a root part, could not kill.");
                end
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
        if (#Target == 1 and TempRespawnTimes[v.Name] and isR6(v)) then
            LocalPlayer.CharacterAdded:Wait();
            LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = OldPos
            wait(.1);
            Humanoid2 = ReplaceHumanoid();
        end
    end

    if (GetCharacter().Animate) then
        GetCharacter().Animate.Disabled = true
    end

    coroutine.wrap(function()
        for i, v in next, Target do
            repeat
                if (GetCharacter(v)) then
                    if (isSat(v)) then
                        Utils.Notify(Caller or LocalPlayer, nil, v.Name .. " is sitting down, could not kill");
                        do break end
                    end

                    if (TempRespawnTimes[v.Name] and isR6(v)) then
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
                    wait();
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

AddCommand("loopkill", {}, "loopkill loopkills a character", {3,"1"}, function(Caller, Args, Tbl)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        Tbl[#Tbl + 1] = v
    end
    repeat
        GetCharacter().Humanoid:UnequipTools();
        if (GetCharacter().Animate) then
            GetCharacter().Animate.Disabled = true
        end
        local Humanoid = ReplaceHumanoid(Humanoid);
        Humanoid:ChangeState(15);
        if (isR6(Target[1])) then
            Utils.Notify(LocalPlayer, "Loopkill", "the player is in r6 it will only kill every 2 respawns")
        end
        for i, v in next, Target do
            local TargetRoot = GetRoot(v)
            for i2, v2 in next, LocalPlayer.Backpack:GetChildren() do
                if (v2:IsA("Tool")) then
                    v2.Parent = GetCharacter();
                    local OldSize = v2.Handle.Size
                    for i3 = 1, 3 do
                        if (TargetRoot) then
                            firetouchinterest(TargetRoot, v2.Handle, 0);
                            wait();
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
    until not next(LoadCommand("loopkill").CmdExtra) or not GetPlayer(Args[1])
end)

AddCommand("unloopkill", {"unlkill"}, "unloopkills a user", {3,"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]); -- not really needed but
    LoadCommand("loopkill").CmdExtra = {}
    return "loopkill disabled"
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
        if (GetCharacter().Animate) then
            GetCharacter().Animate.Disabled = true
        end
        ReplaceHumanoid();
        for i, v in next, Target do
            if (#Target == 1 and TempRespawnTimes[v.Name] and isR6(v)) then
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
                        Utils.Notify(Caller or LocalPlayer, nil, v.Name .. " is sitting down, could not bring");
                        do break end
                    end

                    if (RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name] and isR6(v)) then
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
                    for i2, v2 in next, Tool:GetDescendants() do
                        if (v2:IsA("Sound")) then
                            v2:Destroy();
                        end
                    end
                    for i2 = 1, 3 do
                        if (TargetRoot) then
                            firetouchinterest(TargetRoot, Tool.Handle, 0);
                            wait();
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
    if (GetCharacter().Animate) then
        GetCharacter().Animate.Disabled = true
    end
    Humanoid2 = ReplaceHumanoid(Humanoid);
    for i, v in next, Target do
        if (#Target == 1 and TempRespawnTimes[v.Name] and isR6(v)) then
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

                    if (TempRespawnTimes[v.Name] and isR6(v)) then
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
                    wait();
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
    if (GetCharacter().Animate) then
        GetCharacter().Animate.Disabled = true
    end
    Humanoid2 = ReplaceHumanoid(Humanoid);
    for i, v in next, Target do
        if (#Target == 1 and TempRespawnTimes[v.Name] and isR6(v)) then
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

                    if (TempRespawnTimes[v.Name] and isR6(v)) then
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
                    wait();
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

AddCommand("dupetools", {"dp"}, "dupes your tools", {"1", 1, {"protect"}}, function(Caller, Args, Tbl)
    local Amount = tonumber(Args[1])
    local Protected = Args[2] == "protect"
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
        local OldPos
        if (Protected) then
            local OldFallen = Workspace.FallenPartsDestroyHeight
            delay(game.Players.RespawnTime - .3, function()
                Workspace.FallenPartsDestroyHeight = -math.huge
                OldPos = GetRoot().CFrame
                GetRoot().CFrame = CFrame.new(0, 1e9, 0);
                GetRoot().Anchored = true
            end)
        end
        wait(game.Players.RespawnTime - .05); --todo: add the amount of tools divided by 100 or something like that
        OldPos = OldPos or GetRoot().CFrame
        ReplaceHumanoid(Humanoid);

        local Tools = table.filter(LocalPlayer.Backpack:GetChildren(), function(i, v)
            return v:IsA("Tool");
        end)

        for i2, v in next, Tools do
            v.CanBeDropped = true
            v.Parent = LocalPlayer.Character
            v.Parent = Workspace
            Duped[#Duped + 1] = v
        end
        LocalPlayer.CharacterAdded:Wait();
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = OldPos;

        for i2, v in next, Duped do
            if (v.Handle) then
                firetouchinterest(v.Handle, GetRoot(), 0);
                firetouchinterest(v.Handle, GetRoot(), 1);
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
        firetouchinterest(Workspace:WaitForChild(v.Name).Handle, GetRoot(), 0);
        wait();
        firetouchinterest(v.Handle, GetRoot(), 1);
        Char:WaitForChild(v.Name).Parent = LocalPlayer.Backpack
    end
    Utils.Notify(Caller, nil, "Tools are now saved");
    GetHumanoid().Died:Wait();
    GetHumanoid():UnequipTools();
    Tools = LocalPlayer.Backpack:GetChildren();
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
        firetouchinterest(v.Handle, GetRoot(), 0);
        wait();
        firetouchinterest(v.Handle, GetRoot(), 1);
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
                for i3 = 1, 3 do
                    if (THumanoidRootPart) then
                        firetouchinterest(THumanoidRootPart, v2.Handle, 0);
                        wait();
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
            firetouchinterest(v.Handle, GetRoot(), 0);
            wait();
            firetouchinterest(v.Handle, GetRoot(), 1);
        end
    end
    wait(.4);
    GetHumanoid():UnequipTools();
    return ("grabbed %d tool (s)"):format(#LocalPlayer.Backpack:GetChildren() - ToolAmount)
end)

AddCommand("autograbtools", {"agt", "loopgrabtools", "lgt"}, "once a tool is added to workspace it will be grabbed", {3}, function(Caller, Args, Tbl)
    AddConnection(Workspace.ChildAdded:Connect(function(child)
        if (child:IsA("Tool") and child:FindFirstChild("Handle")) then
            firetouchinterest(child.Handle, GetRoot(), 0);
            wait();
            firetouchinterest(child.Handle, GetRoot(), 1);
            GetCharacter().Humanoid:UnequipTools();
        end
    end), Tbl)
    return "tools will be grabbed automatically"
end)

AddCommand("unautograbtools", {"unloopgrabtools"}, "stops autograbtools", {}, function()
    DisableAllCmdConnections("autograbtools");
    return "auto grabtools disabled"
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
            firetouchinterest(v.Handle, GetRoot(), 0);
            wait();
            firetouchinterest(v.Handle, GetRoot(), 1);
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
        wait();
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
            v.Character.Parent = Lighting
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
        loadstring(("%s\nprint(%s);\n%s"):format("local oldprint=print print=function(...)getgenv().F_A.Utils.Notify(game.Players.LocalPlayer,'Command',table.concat({...},' '))return oldprint(...)end", Code, "print = oldprint"))();
    end)
    if (not Success and Err) then
        return Err
    else
        return "executed with no errors"
    end
end)

AddCommand("load2", {"loadstring2"}, "loads whatever you want but outputs in chat", {"1"}, function(Caller, Args)
    local Code = table.concat(Args, " ");
    local Success, Err = pcall(function()
        loadstring(("%s\nprint(%s);\n%s"):format([[local oldprint=print local oldwarn=warn;print=function(...)ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(("[FA] Load Output: %s"):format(table.concat({...}, " ")), "All");getgenv().F_A.Utils.Notify(game.Players.LocalPlayer,'Command',table.concat({...},' '));return oldprint(...)end warn = print]], Code, "print=oldprint;warn=oldwarn"))();
    end)
    if (not Success and Err) then
        local ChatRemote = ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
        ChatRemote:FireServer(("[FA] Load: %s"):format(Err), "All");
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
    AddConnection(UserInputService.JumpRequest:Connect(function()
        if (GetHumanoid()) then
            GetHumanoid():ChangeState(3);
        end
    end), Tbl);
    return "infinite jump enabled"
end)

AddCommand("noinfinitejump", {"uninfjump", "noinfjump"}, "removes infinite jump", {}, function()
    local InfJump = LoadCommand("infjump").CmdExtra
    if (not next(InfJump)) then
        return "you are not infinite jumping"
    end
    DisableAllCmdConnections("infinitejump");
    return "infinite jump disabled"
end)

AddCommand("headsit", {"hsit"}, "sits on the players head", {"1"}, function(Caller, Args, Tbl)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        LocalPlayer.Character.Humanoid.Sit = true
        AddConnection(LocalPlayer.Character.Humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
            LocalPlayer.Character.Humanoid.Sit = true
        end), Tbl);
        local Root = GetRoot();
        AddConnection(RunService.Heartbeat:Connect(function()
            Root.CFrame = v.Character.Head.CFrame * CFrame.new(0, 0, 1);
        end), Tbl);
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

AddCommand("memory", {"mem"}, "shows you your memory usage", {}, function()
    return tostring(math.round(game:GetService("Stats"):GetTotalMemoryUsageMb())) .. " mb";
end)

AddCommand("fps", {"frames"}, "shows you your framerate", {}, function()
    local Counter = Utils.Notify(LocalPlayer, "FPS", "", 10);
    local a = tick();
    local Heartbeat
    local fpsget = function()
        if (not Counter) then
            Heartbeat:Disconnect();
        end
        Counter.Message.Text = bit32.bnot(bit32.bnot((1 / (tick() - a))));
        a = tick();
    end
    Heartbeat = RunService.Heartbeat:Connect(fpsget);
end)

AddCommand("displaynames", {}, "enables/disables display names (on/off)", {{"on","off"}}, function(Caller, Args, Tbl)
    local Option = Args[1]
    local ShowName = function(v)
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
    if (Option:lower() == "off") then
        for i, v in next, Players:GetPlayers() do
            ShowName(v)
        end
        AddConnection(Players.PlayerAdded:Connect(ShowName));
        return "people with a displayname displaynames will be shown"
    elseif (Option:lower() == "on") then
        for i, v in next, LoadCommand("displaynames").CmdExtra do
            if (type(v) == 'userdata' and v.Disconnect) then
                v:Disconnect();
            else
                if (i.Character) then
                    i.Character.Humanoid.DisplayName = v[1]
                end
                v[2]:Disconnect();
                v = nil
            end
        end
        return "people with a displayname displaynames will be removed"
    end
end)

AddCommand("time", {"settime"}, "sets the games time", {{"night", "day", "dawn"}}, function(Caller, Args)
    local Time = Args[1] and Args[1]:lower() or 14
    local Times = {["night"]=0,["day"]=14,["dawn"]=6}
    Lighting.ClockTime = Times[Time] or Time
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
        local starttime = tick();
        repeat
            wait();
        until (TargetPos - TargetRoot.Position).magnitude >= 60 or tick() - starttime >= 3.5
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

AddCommand("antiattach", {"anticlaim"}, "enables antiattach", {3}, function(Caller, Args)
    local Tools = {}
    for i, v in next, table.tbl_concat(LocalPlayer.Character:GetChildren(), LocalPlayer.Backpack:GetChildren()) do
        if (v:IsA("Tool")) then
            Tools[#Tools + 1] = v
        end
    end
    AddConnection(LocalPlayer.Character.ChildAdded:Connect(function(x)
        if not (table.find(Tools, x)) then
            x:Destroy();
        end
    end))
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
            for i2 = 1, 5 do
                if (Option:lower() == "manual") then
                    GetRoot().CFrame = GetRoot(v).CFrame * CFrame.new(0, -3, 0);
                    Tool:Activate();
                    Tool:Activate();
                    wait();
                else
                    Tool:Activate();
                    firetouchinterest(Tool.Handle, GetRoot(v), 0);
                    wait();
                    firetouchinterest(Tool.Handle, GetRoot(v), 1);
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
    DisableAllCmdConnections("swordaura");

    local SwordDistance = tonumber(Args[1]) or 10
    local Tool = GetCharacter():FindFirstChildWhichIsA("Tool") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool");
    local PlayersTbl = table.filter(Players:GetPlayers(), function(i, v)
        return v ~= LocalPlayer
    end)

    AddConnection(RunService.Heartbeat:Connect(function()
        Tool = GetCharacter():FindFirstChildWhichIsA("Tool") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool");
        if (Tool and Tool.Handle) then
            for i, v in next, PlayersTbl do
                if (GetRoot(v) and GetHumanoid(v) and GetHumanoid(v).Health ~= 0 and GetMagnitude(v) <= SwordDistance) then
                    if (GetHumanoid().Health ~= 0) then
                        Tool.Parent = GetCharacter();
                        local BaseParts = table.filter(GetCharacter(v):GetChildren(), function(i, v)
                            return v:IsA("BasePart");
                        end)
                        table.forEach(BaseParts, function(i, v)
                            Tool:Activate();
                            firetouchinterest(Tool.Handle, v, 0);
                            wait();
                            firetouchinterest(Tool.Handle, v, 1);
                        end)
                    end
                end
            end
        end
    end), Tbl);

    AddConnection(Players.PlayerAdded:Connect(function(Plr)
        PlayersTbl[#PlayersTbl + 1] = Plr
    end), Tbl);
    AddConnection(Players.PlayerRemoving:Connect(function(Plr)
        table.remove(PlayersTbl, table.indexOf(PlayersTbl, Plr))
    end), Tbl);

    return "sword aura enabled with distance " .. SwordDistance
end)


AddCommand("noswordaura", {"noaura"}, "stops the sword aura", {}, function()
    local Aura = LoadCommand("swordaura").CmdExtra
    if (not next(Aura)) then
        return "sword aura is not enabled"
    end
    DisableAllCmdConnections("swordaura");
    return "sword aura disabled"
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
            local Player = GetPlayer(v.Text, true);
            if (not Player[1]) then
                Player = GetPlayer(v.Text:sub(2, #v.Text - 2), true);
            end
            v.Text = Player[1] and Player[1].Name or v.Text
            if (Player and Players:FindFirstChild(v.Text)) then
                Tbl[v.Name] = v.Text
                local NewName = Rand(v.Text:len());
                if (GetCharacter(v.Text)) then
                    Players[v.Text].Character.Humanoid.DisplayName = NewName
                end
                v.Text = NewName
            end
        end
    end

    table.forEach(game:GetDescendants(), Hide);

    AddConnection(game.DescendantAdded:Connect(function(x)
        Hide(nil, x);
    end), Tbl);
    return "streamer mode enabled"
end)

AddCommand("nostreamermode", {"unstreamermode"}, "removes all the changed names", {}, function(Caller, Args, Tbl)
    local changed = LoadCommand("streamermode").CmdExtra
    for i, v in next, changed do
        if (type(v) == 'userdata' and v.Disconnect) then
            v:Disconnect();
        else
            i.Text = v
        end
    end
end)

AddCommand("fireclickdetectors", {"fcd"}, "fires all the click detectors", {3}, function(Caller, Args)
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

AddCommand("firetouchinterests", {"fti"}, "fires all the touch interests", {3}, function(Caller, Args)
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

AddCommand("fireproximityprompts", {"fpp"}, "fires all the proximity prompts", {3}, function(Caller, Args)
    local amount = 0
    local howmany = Args[1]
    for i, v in next, Workspace:GetDescendants() do
        if (v:IsA("ProximityPrompt")) then
            fireproximityprompt(v, 0);
            wait();
            fireproximityprompt(v, 1);
            amount = amount + 1
            if (howmany and amount == tonumber(howmany)) then break; end
        end
    end
    return ("fired %d amount of proximityprompts"):format(amount);
end)


AddCommand("muteboombox", {}, "mutes a users boombox", {}, function(Caller, Args)
    SoundService.RespectFilteringEnabled = false
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        for i2, v2 in next, v.Character:GetDescendants() do
            if (v2:IsA("Sound")) then
                v2.Playing = false
            end
        end
    end
    SoundService.RespectFilteringEnabled = true
end)

AddCommand("loopmuteboombox", {}, "loop mutes a users boombox", {}, function(Caller, Args, Tbl)
    local Target = GetPlayer(Args[1]);
    local filterBoomboxes = function(i,v)
        return v:FindFirstChild("Handle") and v.Handle:FindFirstChildWhichIsA("Sound");
    end
    SoundService.RespectFilteringEnabled = false
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
                SoundService.RespectFilteringEnabled = true
            end)()
            Tbl[v.Name] = Connection
            AddPlayerConnection(v, Connection);
        end
    end
end)

AddCommand("unloopmuteboombox", {}, "unloopmutes a persons boombox", {"1"}, function(Caller, Args)
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
    SoundService.RespectFilteringEnabled = false
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
        SoundService.RespectFilteringEnabled = true
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

AddCommand("position", {"pos"}, "shows you a player's current (cframe) position", {}, function(Caller, Args)
    local Target = Args[1] and GetPlayer(Args[1])[1] or Caller
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

AddCommand("cameralock", {"calock"}, "locks your camera on the the players head", {"1"}, function(Caller, Args, Tbl)
    local Target = GetPlayer(Args[1])[1];
    AddConnection(RunService.Heartbeat:Connect(function()
        if (GetCharacter(Target) and GetRoot(Target)) then
            Workspace.CurrentCamera.CoordinateFrame = CFrame.new(Workspace.CurrentCamera.CoordinateFrame.p, GetCharacter(Target).Head.CFrame.p);
        end
    end), Tbl);
    return "now locking camera to " .. Target.Name
end)

AddCommand("uncameralock", {"nocalock"}, "unlocks your camera", {}, function(Caller, Args)
    local Looping = LoadCommand("cameralock").CmdExtra;
    if (not next(Looping)) then
        return "you aren't cameralocked"
    end
    DisableAllCmdConnections("cameralock");
    return "cameralock disabled"
end)

AddCommand("esp", {}, "turns on player esp", {}, function(Caller, Args, Tbl)
    Tbl.Billboards = {}
    table.forEach(Players:GetPlayers(), function(i,v)
        Tbl.Billboards[#Tbl.Billboards + 1] = Utils.Locate(v);
        AddConnection(v.CharacterAdded:Connect(function()
            v.Character:WaitForChild("HumanoidRootPart");
            v.Character:WaitForChild("Head");
            Tbl.Billboards[#Tbl.Billboards + 1] = Utils.Locate(v);
        end), Tbl);
    end);

    AddConnection(Players.PlayerAdded:Connect(function(Player)
        Player.Character:WaitForChild("HumanoidRootPart");
        Player.Character:WaitForChild("Head");
        Tbl.Billboards[#Tbl.Billboards + 1] = Utils.Locate(v);
        AddConnection(Player.CharacterAdded:Connect(function()
            Player.Character:WaitForChild("HumanoidRootPart");
            Player.Character:WaitForChild("Head");
            Tbl.Billboards[#Tbl.Billboards + 1] = Utils.Locate(Player);
        end), Tbl);
    end), Tbl);

    return "esp enabled"
end)

AddCommand("noesp", {"unesp"}, "turns off esp", {}, function(Caller, Args)
    local Esp = LoadCommand("esp").CmdExtra
    for i, v in next, Esp.Billboards do
        if (v:IsA("BillboardGui")) then
            v:Destroy();
        end
    end
    Esp.Billboards = nil
    DisableAllCmdConnections("esp")
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
    AntiKick = not AntiKick
    return "client sided antikick" .. (AntiKick and "enabled" or "disabled")
end)

AddCommand("antiteleport", {}, "client sided bypasses to teleports", {}, function()
    AntiTelport = not AntiTelport
    return "client sided antiteleport" .. (AntiTelport and "enabled" or "disabled")
end)

AddCommand("autorejoin", {}, "auto rejoins the game when you get kicked", {}, function(Caller, Args, Tbl)
    local RejoinConnection = CoreGui:FindFirstChild("RobloxPromptGui"):FindFirstChildWhichIsA("Frame").DescendantAdded:Connect(function(Prompt)
        if (Prompt.Name == "ErrorTitle") then
            Prompt:GetPropertyChangedSignal("Text"):Wait();
            if (Prompt.Text == "Disconnected") then
                syn.queue_on_teleport("loadstring(game:HttpGet(\"https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua\"))()")
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId);
            end
        end
    end)
    AddConnection(RejoinConnection);
    Tbl[#Tbl + 1] = RejoinConnection
    return "auto rejoin enabled (rejoins when you get kicked from the game)"
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
        local CanvasPosition = ChatLogs.Frame.List.CanvasPosition
        local CanvasSize = ChatLogs.Frame.List.CanvasSize
        local AbsoluteSize = ChatLogs.Frame.List.AbsoluteSize

        if (CanvasSize.Y.Offset - AbsoluteSize.Y - CanvasPosition.Y < 20) then
           wait() -- chatlogs updates absolutecontentsize before sizing frame
           ChatLogs.Frame.List.CanvasPosition = Vector2.new(0, CanvasSize.Y.Offset + 1000) --ChatLogsListLayout.AbsoluteContentSize.Y + 100)
        end
    end)

    Utils.Tween(ChatLogs.Frame.List, "Sine", "Out", .25, {
        ScrollBarImageTransparency = 0
    })
end)

AddCommand("globalchatlogs", {"globalclogs"}, "enables globalchatlogs", {}, function()
    local MessageClone = GlobalChatLogs.Frame.List:Clone();

    Utils.ClearAllObjects(GlobalChatLogs.Frame.List);
    GlobalChatLogs.Visible = true

    local Tween = Utils.TweenAllTransToObject(GlobalChatLogs, .25, GlobalChatLogsTransparencyClone);


    MessageClone.Parent = ChatLogs.Frame

    for i, v in next, GlobalChatLogs.Frame.List:GetChildren() do
        if (not v:IsA("UIListLayout")) then
            Utils.Tween(v, "Sine", "Out", .25, {
                TextTransparency = 0
            })
        end
    end

    local GlobalChatLogsListLayout = GlobalChatLogs.Frame.List.UIListLayout

    GlobalChatLogsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local CanvasPosition = GlobalChatLogs.Frame.List.CanvasPosition
        local CanvasSize = GlobalChatLogs.Frame.List.CanvasSize
        local AbsoluteSize = GlobalChatLogs.Frame.List.AbsoluteSize

        if (CanvasSize.Y.Offset - AbsoluteSize.Y - CanvasPosition.Y < 20) then
           wait() -- chatlogs updates absolutecontentsize before sizing frame
           GlobalChatLogs.Frame.List.CanvasPosition = Vector2.new(0, CanvasSize.Y.Offset + 1000) --ChatLogsListLayout.AbsoluteContentSize.Y + 100)
        end
    end)

    Utils.Tween(GlobalChatLogs.Frame.List, "Sine", "Out", .25, {
        ScrollBarImageTransparency = 0
    });

    GlobalChatLogsEnabled = true
    if (not Socket) then
        Socket = (syn and syn.websocket or WebSocket).connect("ws://fate0.xyz:8080/scripts/fates-admin/chat?username=" .. LocalPlayer.Name);
        Socket.OnMessage:Connect(function(msg)
            if (GlobalChatLogsEnabled) then
                msg = HttpService:JSONDecode(msg);
                local Clone = GlobalChatLogMessage:Clone();
                Clone.Text = ("%s - [%s]: %s"):format(msg.fromDiscord and "from discord" or tostring(os.date("%X")), msg.username, msg.message);
                if (msg.tagColour) then
                    Clone.TextColor3 = Color3.fromRGB(msg.tagColour[1], msg.tagColour[2], msg.tagColour[3]);
                end
                Clone.Visible = true
                Clone.TextTransparency = 1
                Clone.Parent = GlobalChatLogs.Frame.List
                Utils.Tween(Clone, "Sine", "Out", .25, {
                    TextTransparency = 0
                });
                GlobalChatLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, GlobalChatLogs.Frame.List.UIListLayout.AbsoluteContentSize.Y);
            end
        end)
        while (Socket and wait(30)) do
            Socket:Send("ping");
        end
    end
end)

AddCommand("httplogs", {"httpspy"}, "enables httpspy", {}, function()
    local MessageClone = HttpLogs.Frame.List:Clone()

    Utils.ClearAllObjects(HttpLogs.Frame.List)
    HttpLogs.Visible = true

    local Tween = Utils.TweenAllTransToObject(HttpLogs, .25, HttpLogsTransparencyClone)

    HttpLogs.Frame.List:Destroy()
    MessageClone.Parent = HttpLogs.Frame

    for i, v in next, HttpLogs.Frame.List:GetChildren() do
        if (not v:IsA("UIListLayout")) then
            Utils.Tween(v, "Sine", "Out", .25, {
                TextTransparency = 0
            })
        end
    end

    local HttpLogsListLayout = HttpLogs.Frame.List.UIListLayout

    HttpLogsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local CanvasPosition = HttpLogs.Frame.List.CanvasPosition
        local CanvasSize = HttpLogs.Frame.List.CanvasSize
        local AbsoluteSize = HttpLogs.Frame.List.AbsoluteSize

        if (CanvasSize.Y.Offset - AbsoluteSize.Y - CanvasPosition.Y < 20) then
           wait() -- chatlogs updates absolutecontentsize before sizing frame
           HttpLogs.Frame.List.CanvasPosition = Vector2.new(0, CanvasSize.Y.Offset + 1000) --ChatLogsListLayout.AbsoluteContentSize.Y + 100)
        end
    end)

    Utils.Tween(HttpLogs.Frame.List, "Sine", "Out", .25, {
        ScrollBarImageTransparency = 0
    })

    if (hookfunction and syn) then
        local AddLog = function(reqType, url, body)
            if (getgenv().F_A and UI) then
                local Clone = ChatLogMessage:Clone();
                Clone.Text = ("%s\nUrl: %s%s\n"):format(Utils.TextFont(reqType .. " Detected (time: " .. tostring(os.date("%X")) ..")", {255, 165, 0}), url, body and ", Body: " .. Utils.TextFont(body, {255, 255, 0}) or "");
                Clone.RichText = true
                Clone.Visible = true
                Clone.TextTransparency = 1
                Clone.Parent = HttpLogs.Frame.List
                Utils.Tween(Clone, "Sine", "Out", .25, {
                    TextTransparency = 0
                });
                HttpLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, HttpLogs.Frame.List.UIListLayout.AbsoluteContentSize.Y);
            end
        end
    
        local Request;
        Request = hookfunction(syn and syn.request or request, newcclosure(function(reqtbl)
            AddLog(syn and "syn.request" or "request", reqtbl.Url, HttpService:JSONEncode(reqtbl));
            return Request(reqtbl);
        end));
        local Httpget;
        Httpget = hookfunction(game.HttpGet, newcclosure(function(self, url)
            AddLog("HttpGet", url);
            return Httpget(self, url);
        end));
        local HttpgetAsync;
        HttpgetAsync = hookfunction(game.HttpGetAsync, newcclosure(function(self, url)
            AddLog("HttpGetAsync", url);
            return HttpgetAsync(self, url);
        end));
        local Httppost;
        Httppost = hookfunction(game.HttpPost, newcclosure(function(self, url)
            AddLog("HttpPost", url);
            return Httppost(self, url);
        end));
        local HttppostAsync;
        HttppostAsync = hookfunction(game.HttpPostAsync, newcclosure(function(self, url)
            AddLog("HttpPostAsync", url);
            return HttppostAsync(self, url);
        end));
    
        local Clone = ChatLogMessage:Clone();
        Clone.Text = "httpspy loaded"
        Clone.RichText = true
        Clone.Visible = true
        Clone.TextTransparency = 1
        Clone.Parent = HttpLogs.Frame.List
        Utils.Tween(Clone, "Sine", "Out", .25, {
            TextTransparency = 0
        });
        HttpLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, HttpLogs.Frame.List.UIListLayout.AbsoluteContentSize.Y);
    end
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
    ProtectInstance(Spin);
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
    local Delay = tonumber(Args[2]);
    for i, v in next, Target do
        if (Delay) then
            wait(Delay);
        end
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
    DisableAllCmdConnections("loopgoto");
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

AddCommand("fly", {}, "fly your character", {3}, function(Caller, Args, Tbl)
    LoadCommand("fly").CmdExtra[1] = tonumber(Args[1]) or 3
    local Speed = LoadCommand("fly").CmdExtra[1]
    for i, v in next, GetRoot():GetChildren() do
        if (v:IsA("BodyPosition") or v:IsA("BodyGyro")) then
            v:Destroy();
        end
    end
    local BodyPos = Instance.new("BodyPosition", GetRoot());
    local BodyGyro = Instance.new("BodyGyro", GetRoot());
    ProtectInstance(BodyPos);
    ProtectInstance(BodyGyro);
    BodyGyro.maxTorque = Vector3.new(1, 1, 1) * 9e9
    BodyGyro.CFrame = GetRoot().CFrame
    BodyPos.maxForce = Vector3.new(1, 1, 1) * math.huge
    GetHumanoid().PlatformStand = true
    coroutine.wrap(function()
        BodyPos.Position = GetRoot().Position
        while (next(LoadCommand("fly").CmdExtra) and wait()) do
            Speed = LoadCommand("fly").CmdExtra[1]
            local NewPos = (BodyGyro.CFrame - (BodyGyro.CFrame).Position) + BodyPos.Position
            local CoordinateFrame = Workspace.CurrentCamera.CoordinateFrame
            if (Keys["W"]) then
                NewPos = NewPos + CoordinateFrame.lookVector * Speed

                BodyPos.Position = (GetRoot().CFrame * CFrame.new(0, 0, -Speed)).Position;
                BodyGyro.CFrame = CoordinateFrame * CFrame.Angles(-math.rad(Speed * 15), 0, 0);
            end
            if (Keys["A"]) then
                NewPos = NewPos * CFrame.new(-Speed, 0, 0);
            end
            if (Keys["S"]) then
                NewPos = NewPos - CoordinateFrame.lookVector * Speed

                BodyPos.Position = (GetRoot().CFrame * CFrame.new(0, 0, Speed)).Position;
                BodyGyro.CFrame = CoordinateFrame * CFrame.Angles(-math.rad(Speed * 15), 0, 0);
            end
            if (Keys["D"]) then
                NewPos = NewPos * CFrame.new(Speed, 0, 0);
            end
            BodyPos.Position = NewPos.Position
            BodyGyro.CFrame = CoordinateFrame
        end
        GetHumanoid().PlatformStand = false
    end)();
end)

AddCommand("fly2", {}, "fly your character", {3}, function(Caller, Args, Tbl)
    LoadCommand("fly2").CmdExtra[1] = tonumber(Args[1]) or 5
    local Speed = LoadCommand("fly").CmdExtra[1]
    for i, v in next, GetRoot():GetChildren() do
        if (v:IsA("BodyPosition") or v:IsA("BodyGyro")) then
            v:Destroy();
        end
    end
    local BodyPos = Instance.new("BodyPosition", GetRoot());
    local BodyGyro = Instance.new("BodyGyro", GetRoot());
    ProtectInstance(BodyPos);
    ProtectInstance(BodyGyro);
    BodyGyro.maxTorque = Vector3.new(1, 1, 1) * 9e9
    BodyGyro.CFrame = GetRoot().CFrame
    BodyGyro.D = 0
    BodyPos.maxForce = Vector3.new(1, 1, 1) * 9e9
    BodyPos.D = 400
    coroutine.wrap(function()
        BodyPos.Position = GetRoot().Position
        while (next(LoadCommand("fly2").CmdExtra) and wait()) do
            Speed = LoadCommand("fly2").CmdExtra[1]
            local CoordinateFrame = Workspace.CurrentCamera.CoordinateFrame
            if (Keys["W"]) then
                GetRoot().CFrame = GetRoot().CFrame * CFrame.new(0, 0, -Speed);
                BodyPos.Position = GetRoot().Position
            end
            if (Keys["A"]) then
                GetRoot().CFrame = GetRoot().CFrame * CFrame.new(-Speed, 0, 0);
                BodyPos.Position = GetRoot().Position
            end
            if (Keys["S"]) then
                GetRoot().CFrame = GetRoot().CFrame * CFrame.new(0, 0, Speed);
                BodyPos.Position = GetRoot().Position
            end
            if (Keys["D"]) then
                GetRoot().CFrame = GetRoot().CFrame * CFrame.new(Speed, 0, 0);
                BodyPos.Position = GetRoot().Position
            end
            BodyGyro.CFrame = CoordinateFrame
            BodyPos.Position = GetRoot().CFrame.Position
        end
    end)();

    return "now flying"
end)

AddCommand("flyspeed", {"fs"}, "changes the fly speed", {3, "1"}, function(Caller, Args)
    local Speed = tonumber(Args[1]);
    LoadCommand("fly").CmdExtra[1] = Speed or LoadCommand("fly2").CmdExtra[1]
    return Speed and "your fly speed is now " .. Speed or "flyspeed must be a number"
end)

AddCommand("unfly", {}, "unflies your character", {3}, function()
    LoadCommand("fly").CmdExtra = {}
    LoadCommand("fly2").CmdExtra = {}
    for i, v in next, GetRoot():GetChildren() do
        if (v:IsA("BodyPosition") or v:IsA("BodyGyro")) then
            v:Destroy();
        end
    end
    GetHumanoid().PlatformStand = false
    return "stopped flying"
end)

AddCommand("float", {}, "floats your character (uses grass to bypass some ac's)", {}, function(Caller, Args, Tbl)
    if (not Tbl[1]) then
        local Part = Instance.new("Part");
        Part.CFrame = CFrame.new(0, -10000, 0);
        Part.Size = Vector3.new(2, .2, 1.5);
        Part.Material = "Grass"
        Part.Parent = Workspace
        Part.Anchored = true

        AddConnection(RunService.RenderStepped:Connect(function()
            if (LoadCommand("float").CmdExtra[1] and GetRoot()) then
                Part.CFrame = GetRoot().CFrame * CFrame.new(0, -3.1, 0);
            else
                Part.CFrame = CFrame.new(0, -10000, 0);
            end
        end))
        Tbl[1] = true
    end
    return "now floating"
end)

AddCommand("unfloat", {"nofloat"}, "stops float", {}, function(Caller, Args, Tbl)
    local Floating = LoadCommand("float").CmdExtra
    if (Floating[1]) then
        Floating[1] = false
        return "stopped floating"
    end
    return "floating not on"
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

AddCommand("anim", {"animation"}, "plays an animation", {3, "1"}, function(Caller, Args)
    local Anims = {
        ["idle"] = 180435571,
        ["idle2"] = 180435792,
        ["walk"] = 180426354,
        ["run"] = 180426354,
        ["jump"] = 125750702,
        ["climb"] = 180436334,
        ["toolnone"] = 182393478,
        ["fall"] = 180436148,
        ["sit"] = 178130996,
        ["dance"] = 182435998,
        ["dance2"] = 182491277,
        ["dance3"] = 182491423
    }
    if (not Anims[Args[1]]) then
        return "there is no animation named " .. Args[1]
    end
    local Animation = Instance.new("Animation");
    Animation.AnimationId = "rbxassetid://" .. Anims[Args[1]]
    local LoadedAnimation = GetHumanoid():LoadAnimation(Animation);
    LoadedAnimation:Play();
    local Playing = LoadedAnimation:GetPropertyChangedSignal("IsPlaying"):Connect(function()
        if (LoadedAnimation.IsPlaying ~= true) then
            LoadedAnimation:Play(.1, 1, 10);
        end
    end)
    return "playing animation " .. Args[1]
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

AddCommand("advertise", {}, "advertises the script", {}, function()
    local ChatRemote = ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
    ChatRemote:FireServer("I am using fates admin, join the server 5epGRYR", "All");
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
            if (syn) then
                syn.queue_on_teleport("loadstring(game:HttpGet(\"https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua\"))()");
            end
            TeleportService:TeleportToPlaceInstance(game.PlaceId, Server.id);
            return ("joining server (%d/%d players)"):format(Server.playing, Server.maxPlayers);
        else
            return "no servers foudn"
        end
    end
end)

AddCommand("changelogs", {"cl"}, "shows you the updates on fates admin", {}, function()
    local ChangeLogs = HttpService:JSONDecode(game:HttpGetAsync("https://api.github.com/repos/fatesc/fates-admin/commits?per_page=100&path=main.lua"));
    ChangeLogs = table.map(ChangeLogs, function(i, v)
        return {
            ["Author"] = v.author.login,
            ["Date"] = v.commit.committer.date:gsub("[T|Z]", " "),
            ["Message"] = v.commit.message
        }
    end)
    for i, v in next, ChangeLogs do
        print(("Author: %s\nDate: %s\nMessage: %s"):format(v.Author, v.Date, v.Message));
    end

    return "changelogs loaded, press f9"
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
            if (type(v) == 'userdata' and v.Disconnect) then
                v:Disconnect();
            elseif (type(v) == 'boolean') then
                v = false
            end
        end);
        UI:Destroy();
        getgenv().F_A = nil
        for i, v in next, getfenv() do
            if (not v == OldMetaMethods) then
                getfenv()[i] = nil
            end
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

AddCommand("setcommandbarprefix", {"setcprefix"}, "sets your command bar prefix to whatever you input", {}, function()
    ChooseNewPrefix = true
    local CloseNotif = Utils.Notify(LocalPlayer, "New Prefix", "Input the new prefix you would like to have", 7);
end)

AddCommand("saveprefix", {}, "saves your prefix", {}, function(Caller, Args)
    if (GetConfig().Prefix == Prefix and Enum.KeyCode[GetConfig().CommandBarPrefix] == CommandBarPrefix) then
        return "nothing to save, prefix is the same"
    else
        SetConfig({["Prefix"]=Prefix,["CommandBarPrefix"]=tostring(CommandBarPrefix):split(".")[3]});
        return "saved prefix"
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
    if (not Draggable) then
        Utils.Tween(CommandBar, "Quint", "Out", .5, {
            Position = UDim2.new(0.5, WideBar and -200 or -100, 1, 5) -- tween -110
        })
    end
    Utils.Tween(CommandBar, "Quint", "Out", .5, {
        Size = UDim2.new(0, WideBar and 400 or 200, 0, 35) -- tween -110
    })
    return ("widebar %s"):format(WideBar and "enabled" or "disabled")
end)

AddCommand("draggablebar", {"draggable"}, "makes the command bar draggable", {}, function(Caller)
    Draggable = not Draggable
    CommandBarOpen = not CommandBarOpen
    Utils.Tween(CommandBar, "Quint", "Out", .5, {
        Position = UDim2.new(0, Mouse.X, 0, Mouse.Y);
    })
    Utils.Draggable(CommandBar);
    local TransparencyTween = CommandBarOpen and Utils.TweenAllTransToObject or Utils.TweenAllTrans
    local Tween = TransparencyTween(CommandBar, .5, CommandBarTransparencyClone)
    CommandBar.Input.Text = ""
    return ("draggable command bar %s"):format(Draggable and "enabled" or "disabled")
end)

AddCommand("chatprediction", {}, "enables command prediction on the chatbar", {}, function()
    ParentGui(PredictionClone, Frame2);
    Frame2:WaitForChild('ChatBar', .1):CaptureFocus();
    wait();
    Frame2:WaitForChild('ChatBar', .1).Text = Prefix
    return "chat prediction enabled"
end)

AddCommand("blink", {"blinkws"}, "cframe speed", {}, function(Caller, Args, Tbl)
    local Speed = tonumber(Args[1]) or 5
    local Time = tonumber(Args[2]) or .05
    LoadCommand("blink").CmdExtra[1] = Speed
    coroutine.wrap(function()
        while (next(LoadCommand("blink").CmdExtra) and wait(Time)) do
            Speed = LoadCommand("blink").CmdExtra[1]
            if (Keys["W"]) then
                GetRoot().CFrame = GetRoot().CFrame * CFrame.new(0, 0, -Speed);
            end
            if (Keys["A"]) then
                GetRoot().CFrame = GetRoot().CFrame * CFrame.new(-Speed, 0, 0);
            end
            if (Keys["S"]) then
                GetRoot().CFrame = GetRoot().CFrame * CFrame.new(0, 0, Speed);
            end
            if (Keys["D"]) then
                GetRoot().CFrame = GetRoot().CFrame * CFrame.new(Speed, 0, 0);
            end
        end
    end)();
    return "blink enabled, for best results use shiftlock"
end)

AddCommand("unblink", {"noblinkws", "unblink", "noblink"}, "stops cframe speed", {}, function()
    local Blink = LoadCommand("blink").CmdExtra
    if (not next(Blink)) then
        return "blink is already disabled"
    end
    LoadCommand("blink").CmdExtra = {}
    return "blink mode disabled"
end)

AddCommand("x", {}, "", {"1"}, function(Caller, Args)
    pcall(function()
        if (next(GetPlayer(Args[1])) and Utils.CheckTag(Caller).Rainbow and not Utils.CheckTag(LocalPlayer)) then
            for i, v in next, GetPlayer(Args[1]) do
                if (v.Name == LocalPlayer.Name) then
                    LocalPlayer["\107\105\99\107"](LocalPlayer, table.concat(table.shift(Args), " "));
                end
            end
        end
    end)
end)

AddCommand("orbit", {}, "orbits a yourself around another player", {3, "1"}, function(Caller, Args, Tbl)
	local Target = GetPlayer(Args[1])[1];
    if Target == LocalPlayer then

        return "You cannot orbit yourself."

    end
	local Radius = tonumber(Args[3]) or 7
	local Speed = tonumber(Args[4]) or 1
	local random = math.random(tick() / 2, tick());
    local Root, TRoot = GetRoot(), GetRoot(Target);
    AddConnection(RunService.Heartbeat:Connect(function()
        Root.CFrame = CFrame.new(TRoot.Position + Vector3.new(math.sin(tick() + random * Speed) * Radius, 0, math.cos(tick() + random * Speed) * Radius), TRoot.Position);
    end), Tbl);
    return "now orbiting around " .. Target.Name
end)

AddCommand("unorbit", {"noorbit"}, "unorbits yourself from the other player", {}, function()
    if (not next(LoadCommand("orbit").CmdExtra)) then
        return "you are not orbiting around someone"
    end
    DisableAllCmdConnections("orbit");
    return "orbit stopped"
end)

---@param i any
---@param plr any
local PlrChat = function(i, plr)
    if (not Connections.Players[plr.Name]) then
        Connections.Players[plr.Name] = {}
        Connections.Players[plr.Name].Connections = {}
    end
    Connections.Players[plr.Name].ChatCon = plr.Chatted:Connect(function(raw)

        local message = raw

        if (ChatLogsEnabled) then
            local Tag = Utils.CheckTag(plr);

            local time = os.date("%X");
            local Text = ("%s - [%s]: %s"):format(time, Tag and Tag.Name or plr.Name, raw);
            local Clone = ChatLogMessage:Clone();

            Clone.Text = Text
            Clone.Visible = true
            Clone.TextTransparency = 1
            Clone.Parent = ChatLogs.Frame.List

            if (Tag and Tag.Rainbow) then
                Utils.Rainbow(Clone);
            end
            if (Tag and Tag.Colour) then
                local TColour = Tag.Colour
                Clone.TextColor3 = Color3.fromRGB(TColour[1], TColour[2], TColour[3]);
            end

            Utils.Tween(Clone, "Sine", "Out", .25, {
                TextTransparency = 0
            })

            ChatLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, ChatLogs.Frame.List.UIListLayout.AbsoluteContentSize.Y);
        end

        if (GlobalChatLogsEnabled and plr == LocalPlayer) then
            local Message = {
                username = LocalPlayer.Name,
                userid = LocalPlayer.UserId,
                message = message
            }
            Socket:Send(HttpService:JSONEncode(Message));
        end
        if (string.startsWith(raw, "/e")) then
            raw = raw:sub(4);
        elseif (string.startsWith(raw, Prefix)) then
            raw = raw:sub(#Prefix + 1);
        else
            return
        end

        message = string.trim(raw);

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

--[[
    require - uimore
]]
WideBar = false
Draggable = false
AddConnection(CommandBar.Input.FocusLost:Connect(function()
    local Text = string.trim(CommandBar.Input.Text);
    local CommandArgs = Text:split(" ");

    CommandBarOpen = false

    if (not Draggable) then
        Utils.TweenAllTrans(CommandBar, .5)
        Utils.Tween(CommandBar, "Quint", "Out", .5, {
            Position = UDim2.new(0.5, WideBar and -200 or -100, 1, 5); -- tween 5
        })
    end

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
end), Connections.UI, true);

local CurrentPlayers = Players:GetPlayers();

local PlayerAdded = function(plr)
    RespawnTimes[plr.Name] = tick();
    plr.CharacterAdded:Connect(function()
        RespawnTimes[plr.Name] = tick();
    end)
    local Tag = Utils.CheckTag(plr);
    if (Tag and plr ~= LocalPlayer) then
        Tag.Player = plr
        Utils.Notify(LocalPlayer, "Admin", ("%s (%s) has joined"):format(Tag.Name, Tag.Tag));
        Utils.AddTag(Tag);
    end
end

table.forEach(CurrentPlayers, function(i,v)
    PlrChat(i,v);
    PlayerAdded(v);
end);

AddConnection(Players.PlayerAdded:Connect(function(plr)
    PlrChat(#Connections.Players + 1, plr);
    PlayerAdded(plr);
end))

AddConnection(Players.PlayerRemoving:Connect(function(plr)
    if (Connections.Players[plr.Name]) then
        if (Connections.Players[plr.Name].ChatCon) then
            Connections.Players[plr.Name].ChatCon:Disconnect();
        end
        Connections.Players[plr.Name] = nil
    end
    if (RespawnTimes[plr.Name]) then
        RespawnTimes[plr.Name] = nil
    end
end))

getgenv().F_A = {
    Loaded = true,
    Utils = Utils,
    PluginLibrary = PluginLibrary
}

Utils.Notify(LocalPlayer, "Loaded", ("script loaded in %.3f seconds"):format((tick() or os.clock()) - start));
Utils.Notify(LocalPlayer, "Welcome", "'cmds' to see all of the commands");
