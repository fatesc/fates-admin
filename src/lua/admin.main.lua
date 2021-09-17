local game = game
local GetService = game.GetService
if (not game.IsLoaded(game)) then
    local Loaded = game.Loaded
    Loaded.Wait(Loaded);
end

local start = start or tick();
local Debug = true

do
    local F_A = getgenv().F_A
    if (F_A) then
        local Notify, GetConfig = F_A.Utils.Notify, F_A.GetConfig
        local UserInputService = GetService(game, "UserInputService");
        local CommandBarPrefix = GetConfig().CommandBarPrefix
        local StringKeyCode = UserInputService.GetStringForKeyCode(UserInputService, Enum.KeyCode[CommandBarPrefix]);
        return Notify(nil, "Loaded", "fates admin is already loaded... use 'killscript' to kill", nil),
        Notify(nil, "Your Prefix is", string.format("%s (%s)", StringKeyCode, CommandBarPrefix));
    end
end

--[[
    require - var
]]

do
    local ErrorConnections = getconnections(Services.ScriptContext.Error);
    if (next(ErrorConnections)) then
        getfenv().error = warn
        getgenv().error = warn
    end
end

local GetCharacter = GetCharacter or function(Plr)
    return Plr and Plr.Character or LocalPlayer.Character
end

local Utils = {}

--[[
    require - extend
]]


local GetRoot = function(Plr, Char)
    local LCharacter = GetCharacter();
    local Character = Char or GetCharacter(Plr);
    return Plr and Character and (FindFirstChild(Character, "HumanoidRootPart") or FindFirstChild(Character, "Torso") or FindFirstChild(Character, "UpperTorso")) or LCharacter and (FindFirstChild(LCharacter, "HumanoidRootPart") or FindFirstChild(LCharacter, "Torso") or FindFirstChild(LCharacter, "UpperTorso"));
end

local GetHumanoid = function(Plr, Char)
    local LCharacter = GetCharacter();
    local Character = Char or GetCharacter(Plr);
    return Plr and Character and FindFirstChildWhichIsA(Character, "Humanoid") or LCharacter and FindFirstChildWhichIsA(LCharacter, "Humanoid");
end

local GetMagnitude = function(Plr, Char)
    local LRoot = GetRoot();
    local Root = GetRoot(Plr, Char);
    return Plr and Root and (Root.Position - LRoot.Position).magnitude or math.huge
end

local Settings = {
    Prefix = "!",
    CommandBarPrefix = "Semicolon",
    ChatPrediction = false,
    Macros = {},
    Aliases = {},
}
local PluginSettings = {
    PluginsEnabled = true,
    PluginDebug = false,
    DisabledPlugins = {
        ["PluginName"] = true
    },
    SafePlugins = true
}

local WriteConfig = function(Destroy)
    local JSON = JSONEncode(Services.HttpService, Settings);
    local PluginJSON = JSONEncode(Services.HttpService, PluginSettings);
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
    if (isfolder("fates-admin") and isfile("fates-admin/config.json")) then
        return JSONDecode(Services.HttpService, readfile("fates-admin/config.json"));
    else
        WriteConfig();
        return JSONDecode(Services.HttpService, readfile("fates-admin/config.json"));
    end
end

local GetPluginConfig = function()
    if (isfolder("fates-admin") and isfolder("fates-admin/plugins") and isfile("fates-admin/plugins/plugin-conf.json")) then
        local JSON = JSONDecode(Services.HttpService, readfile("fates-admin/plugins/plugin-conf.json"));
        if (JSON.SafePlugins == nil) then
            WriteConfig();
            JSON.SafePlugins = true
        end
        return JSON
    else
        WriteConfig();
        return JSONDecode(Services.HttpService, readfile("fates-admin/plugins/plugin-conf.json"));
    end
end

local SetPluginConfig = function(conf)
    if (isfolder("fates-admin") and isfolder("fates-admin/plugins") and isfile("fates-admin/plugins/plugin-conf.json")) then
        WriteConfig();
    end
    local NewConfig = GetPluginConfig();
    for i, v in next, conf do
        NewConfig[i] = v
    end
    writefile("fates-admin/plugins/plugin-conf.json", JSONEncode(Services.HttpService, NewConfig));
end

local SetConfig = function(conf)
    if (not isfolder("fates-admin") and isfile("fates-admin/config.json")) then
        WriteConfig();
    end
    local NewConfig = GetConfig();
    for i, v in next, conf do
        NewConfig[i] = v
    end
    writefile("fates-admin/config.json", JSONEncode(Services.HttpService, NewConfig));
end

local CurrentConfig = GetConfig();
local Prefix = isfolder and CurrentConfig.Prefix or "!"
local Macros = CurrentConfig.Macros or {}
local AdminUsers = AdminUsers or {}
local Exceptions = Exceptions or {}
local Connections = {
    Players = {}
}
local CLI = false
local ChatLogsEnabled = true
local GlobalChatLogsEnabled = false
local HttpLogsEnabled = true

local GetPlayer;
GetPlayer = function(str, noerror)
    local CurrentPlayers = filter(GetPlayers(Players), function(i, v)
        return not Tfind(Exceptions, v);
    end)
    if (not str) then
        return {}
    end
    str = lower(trim(str));
    if (Sfind(str, ",")) then
        return flatMap(split(str, ","), function(i, v)
            return GetPlayer(v, noerror);
        end)
    end

    local Magnitudes = map(CurrentPlayers, function(i, v)
        return {v,(GetRoot(v).CFrame.p - GetRoot().CFrame.p).Magnitude}
    end)

    local PlayerArgs = {
        ["all"] = function()
            return filter(CurrentPlayers, function(i, v) -- removed all arg (but not really) due to commands getting messed up and people getting confused
                return v ~= LocalPlayer
            end)
        end,
        ["others"] = function()
            return filter(CurrentPlayers, function(i, v)
                return v ~= LocalPlayerw
            end)
        end,
        ["nearest"] = function()
            sort(Magnitudes, function(a, b)
                return a[2] < b[2]
            end)
            return {Magnitudes[2][1]}
        end,
        ["farthest"] = function()
            sort(Magnitudes, function(a, b)
                return a[2] > b[2]
            end)
            return {Magnitudes[2][1]}
        end,
        ["random"] = function()
            return {CurrentPlayers[random(2, #CurrentPlayers)]}
        end,
        ["allies"] = function()
            local LTeam = LocalPlayer.Team
            return filter(CurrentPlayers, function(i, v)
                return v.Team == LTeam
            end)
        end,
        ["enemies"] = function()
            local LTeam = LocalPlayer.Team
            return filter(CurrentPlayers, function(i, v)
                return v.Team ~= LTeam
            end)
        end,
        ["npcs"] = function()
            local NPCs = {}
            local Descendants = GetDescendants(Workspace);
            local GetPlayerFromCharacter = Players.GetPlayerFromCharacter
            for i = 1, #Descendants do
                local Descendant = Descendants[i]
                local DParent = Descendant.Parent
                if (IsA(Descendant, "Humanoid") and IsA(DParent, "Model") and (FindFirstChild(DParent, "HumanoidRootPart") or FindFirstChild(DParent, "Head")) and GetPlayerFromCharacter(Players, DParent) == nil) then
                    local FakePlr = InstanceNew("Player"); -- so it can be compatible with commands
                    FakePlr.Character = DParent
                    FakePlr.Name = format("%s %s", DParent.Name, "- " .. Descendant.DisplayName);
                    NPCs[#NPCs + 1] = FakePlr
                end
            end
            return NPCs
        end,
        ["me"] = function()
            return {LocalPlayer}
        end
    }

    if (PlayerArgs[str]) then
        return PlayerArgs[str]();
    end

    local Players = filter(CurrentPlayers, function(i, v)
        return (sub(lower(v.Name), 1, #str) == str) or (sub(lower(v.DisplayName), 1, #str) == str);
    end)
    if (not next(Players) and not noerror) then
        Utils.Notify(LocalPlayer, "Fail", format("Couldn't find player %s", str));
    end
    return Players
end

local AddConnection = function(Connection, CEnv, TblOnly)
    if (CEnv) then
        CEnv[#CEnv + 1] = Connection
        if (TblOnly) then
            return Connection
        end
    end
    Connections[#Connections + 1] = Connection
    return Connection
end

local LastCommand = {}

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
local RespawnTimes = {}

local HasTool = function(plr)
    plr = plr or LocalPlayer
    local CharChildren, BackpackChildren = GetChildren(GetCharacter(plr)), GetChildren(plr.Backpack);
    local ToolFound = false
    local tbl = tbl_concat(CharChildren, BackpackChildren);
    for i = 1, #tbl do
        local v = tbl[i]
        if (IsA(v, "Tool")) then
            ToolFound = true
            break;
        end
    end
    return ToolFound
end

local isR6 = function(plr)
    plr = plr or LocalPlayer
    local Humanoid = GetHumanoid(plr);
    if (Humanoid) then
        return Humanoid.RigType == Enum.HumanoidRigType.R6
    end
    return false
end

local isSat = function(plr)
    plr = plr or LocalPlayer
    local Humanoid = GetHumanoid(plr)
    if (Humanoid) then
        return Humanoid.Sit
    end
end

local DisableAnimate = function()
    local Animate = GetCharacter().Animate
    Animate = IsA(Animate, "LocalScript") and Animate or nil
    if (Animate) then
        SpoofProperty(Animate, "Disabled");
        Animate.Disabled = true
    end
end

local GetCorrectToolWithHandle = function()
    local Tools = filter(tbl_concat(GetChildren(LocalPlayer.Backpack), GetChildren(LocalPlayer.Character)), function(i, Tool)
        local Correct = IsA(Tool, "Tool");
        if (Correct and (Tool.RequiresHandle or FindFirstChild(Tool, "Handle"))) then
            local Descendants = GetDescendants(Tool);
            for i = 1, #Descendants do
                local Descendant = Descendants[i]
                if (IsA(Descendant, "Sound") or IsA(Descendant, "Camera") or IsA(Descendant, "LocalScript")) then
                    Destroy(Descendant);
                end
            end
            return true
        end
        return false
    end)

    return Tools[1]
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

local AddCommand = function(name, aliases, description, options, func, isplugin)
    local Cmd = {
        Name = name,
        Aliases = aliases,
        Description = description,
        Options = options,
        Function = function()
            for i, v in next, options do
                if (type(v) == 'function' and v() == false) then
                    Utils.Notify(LocalPlayer, "Fail", ("You are missing something that is needed for this command"));
                    return nil
                elseif (type(v) == 'number' and CommandRequirements[v].Func() == false) then
                    Utils.Notify(LocalPlayer, "Fail", CommandRequirements[v].Message);
                    return nil
                end
            end
            return func
        end,
        ArgsNeeded = tonumber(filter(options, function(i,v)
            return type(v) == "string"
        end)[1]) or 0,
        Args = filter(options, function(i, v)
            return type(v) == "table"
        end)[1] or {},
        CmdEnv = {},
        IsPlugin = isplugin == true
    }

    CommandsTable[name] = Cmd
    if (type(aliases) == 'table') then
        for i, v in next, aliases do
            CommandsTable[v] = Cmd
        end
    end
    return Success
end

local RemoveCommand = function(Name)
    local Command = LoadCommand(Name);
    if (Command) then
        CommandsTable[Name] = nil
        local CommandsList = Commands.Frame.List
        local CommandLabel = FindFirstChild(CommandsList, Name);
        if (CommandLabel) then
            Destroy(CommandLabel);
        end
        return true
    end
    return false
end

local LoadCommand = function(Name)
    return rawget(CommandsTable, Name);
end

local PluginConf;
local ExecuteCommand = function(Name, Args, Caller)
    local Command = LoadCommand(Name);
    if (Command) then
        if (Command.ArgsNeeded > #Args) then
            return Utils.Notify(plr, "Error", format("Insuficient Args (you need %d)", Command.ArgsNeeded));
        end

        local Context;
        local sett, gett = syn and syn_context_set or setidentity, syn and syn_context_get or getidentity
        if (Command.IsPlugin and sett and gett and PluginConf.SafePlugins) then
            Context = gett();
            sett(2);
        end
        local Success, Ret = xpcall(function()
            local Func = Command.Function();
            if (Func) then
                local Executed = Func(Caller, Args, Command.CmdEnv);
                if (Executed) then
                    Utils.Notify(Caller, "Command", Executed);
                end
                if (Command.Name ~= "lastcommand") then
                    if (#LastCommand == 3) then
                        LastCommand = shift(LastCommand);
                    end
                    LastCommand[#LastCommand + 1] = {Command.Name, Args, Caller, Command.CmdEnv}
                end
            end
            Success = true
        end, function(Err)
            if (Debug) then
                local UndetectedMessageOut = Hooks.UndetectedMessageOut
                Hooks.UndetectedMessageOut = true
                warn("[FA Error]: " .. debug.traceback(Err));
                Hooks.UndetectedMessageOut = UndetectedMessageOut
                Utils.Notify(Caller, "Error", Err);
            end
        end);
        if (Command.IsPlugin and sett and PluginConf.SafePlugins and Context) then
            sett(Context);
        end
    else
        local UndetectedMessageOut = Hooks.UndetectedMessageOut
        Hooks.UndetectedMessageOut = true
        warn("couldn't find the command ".. Name);
        Hooks.UndetectedMessageOut = UndetectedMessageOut
        Utils.Notify(plr, "Error", "couldn't find the command " .. Name);
    end
end

local ReplaceHumanoid = function(Hum, R)
    local Humanoid = Hum or GetHumanoid();
    local NewHumanoid = Clone(Humanoid);
    if (R) then
        NewHumanoid.Name = "1"
    end
    NewHumanoid.Parent = Humanoid.Parent
    NewHumanoid.Name = Humanoid.Name
    Services.Workspace.Camera.CameraSubject = NewHumanoid
    Destroy(Humanoid);
    SpoofInstance(NewHumanoid);
    return NewHumanoid
end

local ReplaceCharacter = function()
    local Char = LocalPlayer.Character
    local Model = InstanceNew("Model");
    LocalPlayer.Character = Model
    LocalPlayer.Character = Char
    Destroy(Model);
    return Char
end

local CFrameTool = function(tool, pos)
    local RightArm = FindFirstChild(GetCharacter(), "RightLowerArm") or FindFirstChild(GetCharacter(), "Right Arm");
    local Arm = RightArm.CFrame * CFrameNew(0, -1, 0, 1, 0, 0, 0, 0, 1, 0, -1, 0);
    local Frame = Inverse(toObjectSpace(Arm, pos));

    tool.Grip = Frame
end

local Sanitize = function(value)
    if typeof(value) == 'CFrame' then
        local components = {components(value)}
        for i,v in pairs(components) do
            components[i] = floor(v * 10000 + .5) / 10000
        end
        return 'CFrameNew('..concat(components, ', ')..')'
    end
end

local AddPlayerConnection = function(Player, Connection, CEnv)
    if (CEnv) then
        CEnv[#CEnv + 1] = Connection
    else
        Connections.Players[Player.Name].Connections[#Connections.Players[Player.Name].Connections + 1] = Connection
    end
    return Connection
end


local DisableAllCmdConnections = function(Cmd)
    local Command = LoadCommand(Cmd)
    if (Command and Command.CmdEnv) then
        for i, v in next, flat(Command.CmdEnv) do
            if (type(v) == 'userdata' and v.Disconnect) then
                Disconnect(v);
            end
        end
    end
    return Command
end

local Keys = {}

do
    local UserInputService = Services.UserInputService
    local IsKeyDown = UserInputService.IsKeyDown
    AddConnection(CConnect(UserInputService.InputBegan, function(Input, GameProccesed)
        if (GameProccesed) then return end
        local KeyCode = split(tostring(Input.KeyCode), ".")[3]
        Keys[KeyCode] = true
        for i = 1, #Macros do
            local Macro = Macros[i]
            if (Tfind(Macro.Keys, Input.KeyCode)) then
                if (#Macro.Keys == 2) then
                    if (IsKeyDown(UserInputService, Macro.Keys[1]) and IsKeyDown(UserInputService, Macro.Keys[2]) --[[and Macro.Keys[1] == Input.KeyCode]]) then
                        ExecuteCommand(Macro.Command, Macro.Args);
                    end
                else
                    ExecuteCommand(Macro.Command, Macro.Args);
                end
            end
        end
    end));
    AddConnection(CConnect(UserInputService.InputEnded, function(Input, GameProccesed)
        if (GameProccesed) then return end
        local KeyCode = split(tostring(Input.KeyCode), ".")[3]
        if (Keys[KeyCode] or Keys[Input.KeyCode]) then
            Keys[KeyCode] = false
        end
    end));
end

AddCommand("commandcount", {"cc"}, "shows you how many commands there is in fates admin", {}, function(Caller)
    Utils.Notify(Caller, "Amount of Commands", format("There are currently %s commands.", #filter(CommandsTable, function(i,v)
        return indexOf(CommandsTable, v) == i
    end)))
end)

AddCommand("walkspeed", {"ws"}, "changes your walkspeed to the second argument", {}, function(Caller, Args, CEnv)
    local Humanoid = GetHumanoid();
    CEnv[1] = Humanoid.WalkSpeed
    SpoofProperty(Humanoid, "WalkSpeed");
    Humanoid.WalkSpeed = tonumber(Args[1]) or 16
    return "your walkspeed is now " .. Humanoid.WalkSpeed
end)

AddCommand("jumppower", {"jp"}, "changes your jumpower to the second argument", {}, function(Caller, Args, CEnv)
    local Humanoid = GetHumanoid();
    CEnv[1] = Humanoid.JumpPower
    SpoofProperty(Humanoid, "JumpPower");
    Humanoid.JumpPower = tonumber(Args[1]) or 50
    return "your jumppower is now " .. Humanoid.JumpPower
end)

AddCommand("hipheight", {"hh"}, "changes your hipheight to the second argument", {}, function(Caller, Args, CEnv)
    local Humanoid = GetHumanoid();
    CEnv[1] = Humanoid.HipHeight
    SpoofProperty(Humanoid, "HipHeight");
    Humanoid.HipHeight = tonumber(Args[1]) or 0
    return "your hipheight is now " .. Humanoid.HipHeight
end)

local AntiFeList = {}

local KillCam;
AddCommand("kill", {"tkill"}, "kills someone", {"1", 1, 3}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local OldPos = GetRoot().CFrame
    local Humanoid = ReplaceHumanoid();
    local TempRespawnTimes = {}
    for i, v in next, Target do
        TempRespawnTimes[v.Name] = RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name]
    end
    local Character = GetCharacter();
    for i, v in next, Target do
        if (#Target == 1 and TempRespawnTimes[v.Name] and isR6(v)) then
            Destroy(Character);
            Character = CWait(LocalPlayer.CharacterAdded);
            WaitForChild(Character, "Humanoid");
            wait()
            Humanoid = ReplaceHumanoid();
        end
    end
    if (Character.Animate) then
        Character.Animate.Disabled = true
    end
    UnequipTools(Humanoid);

    local TChar;
    CThread(function()
        for i = 1, #Target do
            local v = Target[i]
            if (Tfind(AntiFeList, v.UserId)) then
                continue
            end
            TChar = GetCharacter(v);
            if (TChar) then
                if (isSat(v)) then
                    if (#Target == 1) then
                        Utils.Notify(Caller or LocalPlayer, nil, v.Name .. " is sitting down, could not kill");
                    end
                    continue
                end
                local TargetRoot = GetRoot(v);
                if (not TargetRoot) then
                    continue
                end
                if (RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name] and isR6(v)) then
                    continue
                end

                local Tool = GetCorrectToolWithHandle();
                if (not Tool) then
                    continue
                end
                Tool.Parent = Character
                Tool.Handle.Size = Vector3New(4, 4, 4);
                CFrameTool(Tool, TargetRoot.CFrame);
                firetouchinterest(TargetRoot, Tool.Handle, 0);
                firetouchinterest(TargetRoot, Tool.Handle, 1);
            else
                Utils.Notify(Caller or LocalPlayer, "Fail", v.Name .. " is dead or does not have a root part, could not kill.");
            end
        end
    end)()
    ChangeState(Humanoid, 15);
    if (KillCam and #Target == 1 and TChar) then
        Camera.CameraSubject = TChar
    end
    wait(.3);
    Destroy(Character);
    Character = CWait(LocalPlayer.CharacterAdded);
    WaitForChild(Character, "HumanoidRootPart").CFrame = OldPos
end)

AddCommand("kill2", {}, "another variant of kill", {1, "1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local TempRespawnTimes = {}
    for i, v in next, Target do
        TempRespawnTimes[v.Name] = RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name]
    end
    local Humanoid = FindFirstChildWhichIsA(GetCharacter(), "Humanoid");
    ReplaceCharacter();
    wait(Players.RespawnTime - (#Target == 1 and .05 or .09)); -- this really kinda depends on ping
    local OldPos = GetRoot().CFrame
    Humanoid2 = ReplaceHumanoid(Humanoid);
    for i, v in next, Target do
        if (#Target == 1 and TempRespawnTimes[v.Name] and isR6(v)) then
            CWait(LocalPlayer.CharacterAdded);
            WaitForChild(LocalPlayer.Character, "HumanoidRootPart").CFrame = OldPos
            wait(.1);
            Humanoid2 = ReplaceHumanoid();
        end
    end

    UnequipTools(Humanoid);
    local Destroy_;
    CThread(function()
        for i = 1, #Target do
            local v = Target[i]
            if (Tfind(AntiFeList, v.UserId)) then
                continue
            end
            if (GetCharacter(v)) then
                if (isSat(v)) then
                    Utils.Notify(Caller or LocalPlayer, nil, v.Name .. " is sitting down, could not kill");
                    continue
                end
                if (TempRespawnTimes[v.Name] and isR6(v)) then
                    if (#Target == 1) then
                        Destroy_ = true
                    else
                        continue
                    end
                end
                local TargetRoot = GetRoot(v);
                if (not TargetRoot) then
                    continue
                end
                local Tool = GetCorrectToolWithHandle();
                if (not Tool) then
                    continue
                end
                Tool.Parent = GetCharacter();
                Tool.Handle.Size = Vector3New(4, 4, 4);
                CFrameTool(Tool, TargetRoot.CFrame * CFrameNew(0, 3, 0));
                firetouchinterest(TargetRoot, Tool.Handle, 0);
                wait();
                if (not FindFirstChild(Tool, "Handle")) then
                    continue
                end
                firetouchinterest(TargetRoot, Tool.Handle, 1);
            else
                Utils.Notify(Caller or LocalPlayer, "Fail", v.Name .. " is dead or does not have a root part, could not kill.");
            end
        end
    end)()
    ChangeState(Humanoid2, 15);
    if (Destroy_) then
        wait(.2);
        ReplaceCharacter();
    end
    CWait(LocalPlayer.CharacterAdded);
    WaitForChild(LocalPlayer.Character, "HumanoidRootPart").CFrame = OldPos
end)

AddCommand("loopkill", {}, "loopkill loopkills a character", {3,"1"}, function(Caller, Args, CEnv)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        CEnv[#CEnv + 1] = v
    end
    repeat
        local Character, Humanoid = GetCharacter(), GetHumanoid();
        UnequipTools(Humanoid);
        DisableAnimate();
        Humanoid = ReplaceHumanoid(Humanoid);
        ChangeState(Humanoid, 15);
        if (isR6(Target[1])) then
            Utils.Notify(LocalPlayer, "Loopkill", "the player is in r6 it will only kill every 2 respawns")
        end
        for i = 1, #Target do
            local v = Target[i]
            if (Tfind(AntiFeList, v.UserId)) then
                continue
            end
            local TargetRoot = GetRoot(v)
            local Children = GetChildren(LocalPlayer.Backpack);
            for i2 = 1, #Children do
                local v2 = Children[i2]
                if (IsA(v2, "Tool")) then
                    SpoofInstance(v);
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
        wait(.2);
        Destroy(LocalPlayer.Character);
        CWait(LocalPlayer.CharacterAdded);
        WaitForChild(LocalPlayer.Character, "HumanoidRootPart");
        wait(1);
    until not next(LoadCommand("loopkill").CmdEnv) or not GetPlayer(Args[1])
end)

AddCommand("unloopkill", {"unlkill"}, "unloopkills a user", {3,"1"}, function(Caller, Args)
    LoadCommand("loopkill").CmdEnv = {}
    return "loopkill disabled"
end)

AddCommand("bring", {}, "brings a user", {1}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local Target2 = Args[2] and GetPlayer(Args[2]);
    local OldPos = GetRoot(Caller).CFrame
    if (Caller ~= LocalPlayer and Target[1] == LocalPlayer) then
        GetRoot().CFrame = GetRoot(Caller).CFrame * CFrameNew(-5, 0, 0);
    else
        local TempRespawnTimes = {}
        for i = 1, #Target do
            local v = Target[i]
            TempRespawnTimes[v.Name] = RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name]
        end
        DisableAnimate();
        ReplaceHumanoid();
        for i, v in next, Target do
            if (#Target == 1 and TempRespawnTimes[v.Name] and isR6(v)) then
                Destroy(LocalPlayer.Character);
                CWait(LocalPlayer.CharacterAdded);
                WaitForChild(LocalPlayer.Character, "HumanoidRootPart").CFrame = OldPos;
                wait(.1);
                ReplaceHumanoid();
            end
        end
        local Target2Root = Target2 and GetRoot(Target2 and Target2[1] or nil);
        for i = 1, #Target do
            local v = Target[i]
            if (Tfind(AntiFeList, v.UserId)) then
                continue
            end
            if (GetCharacter(v)) then
                if (isSat(v)) then
                    if (#Target == 1) then
                        Utils.Notify(Caller or LocalPlayer, nil, v.Name .. " is sitting down, could not bring");
                    end
                    continue
                end
                if (RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name] and isR6(v)) then
                    continue
                end

                local TargetRoot = GetRoot(v);
                if (not TargetRoot) then
                    continue
                end

                local Tool = GetCorrectToolWithHandle();
                if (not Tool) then
                    continue
                end
                Tool.Parent = GetCharacter();
                Tool.Handle.Size = Vector3New(4, 4, 4);
                CFrameTool(Tool, (Target2 and Target2Root.CFrame or OldPos) * CFrameNew(-5, 0, 0));
                if (not syn) then
                    wait(.1);
                end
                for i2 = 1, 3 do
                    firetouchinterest(TargetRoot, Tool.Handle, 0);
                    wait();
                    firetouchinterest(TargetRoot, Tool.Handle, 1);
                end
            else
                Utils.Notify(Caller or LocalPlayer, "Fail", v.Name .. " is dead or does not have a root part, could not bring.");
            end
        end
        wait(.2);
        Destroy(LocalPlayer.Character);
        CWait(LocalPlayer.CharacterAdded);
        WaitForChild(LocalPlayer.Character, "HumanoidRootPart").CFrame = OldPos
    end
end)

AddCommand("bring2", {}, "another variant of bring", {1, 3, "1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local Target2 = Args[2] and GetPlayer(Args[2]);
    local TempRespawnTimes = {}
    for i, v in next, Target do
        TempRespawnTimes[v.Name] = RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name]
    end
    local Humanoid = FindFirstChildWhichIsA(GetCharacter(), "Humanoid");
    local Character = ReplaceCharacter();
    wait(Players.RespawnTime - (#Target == 1 and .2 or .3));
    local OldPos = GetRoot().CFrame
    DisableAnimate();
    local Humanoid2 = ReplaceHumanoid(Humanoid);
    for i, v in next, Target do
        if (#Target == 1 and TempRespawnTimes[v.Name]) then
            Character = CWait(LocalPlayer.CharacterAdded);
            WaitForChild(Character, "HumanoidRootPart").CFrame = OldPos
            wait(.1);
            Humanoid2 = ReplaceHumanoid();
        end
    end
    local Target2Root = Target2 and GetRoot(Target2 and Target2[1] or nil);
    local Destroy_;
    CThread(function()
        for i, v in next, Target do
            if (Tfind(AntiFeList, v.UserId)) then
                continue
            end
            if (GetCharacter(v)) then
                if (isSat(v)) then
                    Utils.Notify(Caller or LocalPlayer, nil, v.Name .. " is sitting down, could not bring");
                    continue
                end

                if (TempRespawnTimes[v.Name]) then
                    if (#Target == 1) then
                        Destroy_ = true
                    else
                        continue
                    end
                end
                local TargetRoot = GetRoot(v);
                local Tool = GetCorrectToolWithHandle();
                if (not Tool) then
                    continue
                end
                Tool.Parent = Character
                Tool.Handle.Size = Vector3New(4, 4, 4);
                CFrameTool(Tool, (Target2 and Target2Root.CFrame or OldPos) * CFrameNew(-5, 0, 0));
                if (not syn) then
                    wait(.1);
                end
                for i2 = 1, 3 do
                    firetouchinterest(TargetRoot, Tool.Handle, 0);
                    wait()
                    firetouchinterest(TargetRoot, Tool.Handle, 1);
                end
            else
                Utils.Notify(Caller or LocalPlayer, "Fail", v.Name .. " is dead or does not have a root part, could not bring.");
            end
        end
    end)()
    if (Destroy_) then
        wait(.2);
        GetRoot().CFrame = CFrameNew(0, Services.Workspace.FallenPartsDestroyHeight + 50, 0);
        Destroy(Character);
    end
    Character = CWait(LocalPlayer.CharacterAdded);
    WaitForChild(Character, "HumanoidRootPart").CFrame = OldPos
end)

AddCommand("void", {"kill3"}, "voids a user", {1,"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local Target2 = Args[2] and GetPlayer(Args[2]);
    local OldPos = GetRoot(Caller).CFrame

    local TempRespawnTimes = {}
    for i = 1, #Target do
        local v = Target[i]
        TempRespawnTimes[v.Name] = RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name]
    end
    DisableAnimate();
    ReplaceHumanoid();
    for i, v in next, Target do
        if (#Target == 1 and TempRespawnTimes[v.Name] and isR6(v)) then
            Destroy(LocalPlayer.Character);
            CWait(LocalPlayer.CharacterAdded);
            WaitForChild(LocalPlayer.Character, "HumanoidRootPart").CFrame = OldPos;
            wait(.1);
            ReplaceHumanoid();
        end
    end
    local Target2Root = Target2 and GetRoot(Target2 and Target2[1] or nil);
    for i = 1, #Target do
        local v = Target[i]
        if (Tfind(AntiFeList, v.UserId)) then
            continue
        end
        if (GetCharacter(v)) then
            if (isSat(v)) then
                if (#Target == 1) then
                    Utils.Notify(Caller or LocalPlayer, nil, v.Name .. " is sitting down, could not bring");
                end
                continue
            end
            if (RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name] and isR6(v)) then
                continue
            end

            local TargetRoot = GetRoot(v);
            if (not TargetRoot) then
                continue
            end

            local Tool = GetCorrectToolWithHandle();
            if (not Tool) then
                continue
            end
            Tool.Parent = GetCharacter();
            Tool.Handle.Size = Vector3New(4, 4, 4);
            CFrameTool(Tool, (Target2 and Target2Root.CFrame or OldPos) * CFrameNew(-5, 0, 0));
            if (not syn) then
                wait(.1);
            end
            for i2 = 1, 3 do
                firetouchinterest(TargetRoot, Tool.Handle, 0);
                wait();
                firetouchinterest(TargetRoot, Tool.Handle, 1);
            end
        else
            Utils.Notify(Caller or LocalPlayer, "Fail", v.Name .. " is dead or does not have a root part, could not bring.");
        end
    end
    for i = 1, 3 do
        GetRoot().CFrame = CFrameNew(0, Services.Workspace.FallenPartsDestroyHeight + 50, 0);
        wait();
    end
    wait(.2);
    Destroy(LocalPlayer.Character);
    CWait(LocalPlayer.CharacterAdded);
    WaitForChild(LocalPlayer.Character, "HumanoidRootPart").CFrame = OldPos
end)

AddCommand("freefall", {}, "freefalls a user", {1,"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local Target2 = Args[2] and GetPlayer(Args[2]);
    local OldPos = GetRoot(Caller).CFrame

    local TempRespawnTimes = {}
    for i = 1, #Target do
        local v = Target[i]
        TempRespawnTimes[v.Name] = RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name]
    end
    DisableAnimate();
    ReplaceHumanoid();
    for i, v in next, Target do
        if (#Target == 1 and TempRespawnTimes[v.Name] and isR6(v)) then
            Destroy(LocalPlayer.Character);
            CWait(LocalPlayer.CharacterAdded);
            WaitForChild(LocalPlayer.Character, "HumanoidRootPart").CFrame = OldPos;
            wait(.1);
            ReplaceHumanoid();
        end
    end
    local Target2Root = Target2 and GetRoot(Target2 and Target2[1] or nil);
    for i = 1, #Target do
        local v = Target[i]
        if (Tfind(AntiFeList, v.UserId)) then
            continue
        end
        if (GetCharacter(v)) then
            if (isSat(v)) then
                if (#Target == 1) then
                    Utils.Notify(Caller or LocalPlayer, nil, v.Name .. " is sitting down, could not bring");
                end
                continue
            end
            if (RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name] and isR6(v)) then
                continue
            end

            local TargetRoot = GetRoot(v);
            if (not TargetRoot) then
                continue
            end

            local Tool = GetCorrectToolWithHandle();
            if (not Tool) then
                continue
            end
            Tool.Parent = GetCharacter();
            Tool.Handle.Size = Vector3New(4, 4, 4);
            CFrameTool(Tool, (Target2 and Target2Root.CFrame or OldPos) * CFrameNew(-5, 0, 0));
            if (not syn) then
                wait(.1);
            end
            for i2 = 1, 3 do
                firetouchinterest(TargetRoot, Tool.Handle, 0);
                wait();
                firetouchinterest(TargetRoot, Tool.Handle, 1);
            end
        else
            Utils.Notify(Caller or LocalPlayer, "Fail", v.Name .. " is dead or does not have a root part, could not bring.");
        end
    end
    local Root = GetRoot();
    local RootPos = Root.Position
    for i = 1, 3 do
        Root.Position = Vector3New(RootPos.X, RootPos.Y + 1000, RootPos.Z);
        wait();
    end
    wait(.2);
    Destroy(LocalPlayer.Character);
    CWait(LocalPlayer.CharacterAdded);
    WaitForChild(LocalPlayer.Character, "HumanoidRootPart").CFrame = OldPos
end)

AddCommand("view", {"v"}, "views a user", {3,"1"}, function(Caller, Args, CEnv)
    local Target = GetPlayer(Args[1]);
    if (#Target ~= 1) then
        return "you can only view 1 person"
    end
    Target = Target[1]
    Camera.CameraSubject = GetCharacter(Target) or GetCharacter();
    AddConnection(CConnect(Target.CharacterAdded, function()
        CWait(Heartbeat);
        Camera.CameraSubject = Target.Character
    end), CEnv);
    AddConnection(CConnect(LocalPlayer.CharacterAdded, function()
        WaitForChild(LocalPlayer.Character, "Humanoid");
        CWait(Camera.CameraSubject.Changed);
        CWait(Heartbeat);
        Camera.CameraSubject = Target.Character
    end), CEnv);
    return "viewing " .. Target.Name
end)

AddCommand("unview", {"unv"}, "unviews a user", {3}, function(Caller, Args)
    DisableAllCmdConnections("view");
    Camera.CameraSubject = GetCharacter();
    return "unviewing"
end)

AddCommand("invisible", {"invis"}, "makes yourself invisible", {3}, function()
    local OldPos = GetRoot().CFrame
    GetRoot().CFrame = CFrameNew(9e9, 9e9, 9e9);
    local Clone = Clone(GetRoot());
    wait(.2);
    Destroy(GetRoot());
    Clone.CFrame = OldPos
    Clone.Parent = GetCharacter();
    return "you are now invisible"
end)

AddCommand("dupetools", {"dp"}, "dupes your tools", {"1", 1, {"protect"}}, function(Caller, Args, CEnv)
    local Amount = tonumber(Args[1])
    local Protected = Args[2] == "protect"
    if (not Amount) then
        return "amount must be a number"
    end

    CEnv[1] = true
    local AmountDuped = 0
    local Timer = (Players.RespawnTime * Amount) + (Amount * .4) + 1
    local Notification = Utils.Notify(Caller, "Duping Tools", format("%d/%d tools duped. %d seconds left", AmountDuped, Amount, Timer), Timer);
    CThread(function()
        for i = 1, Timer do
            if (not LoadCommand("dupetools").CmdEnv[1]) then
                do break end;
            end
            wait(1);
            Timer = Timer - 1
            Notification.Message.Text = format("%d/%d tools duped. %d seconds left", AmountDuped, Amount, Timer)
        end
    end)()


    local ToolAmount = #filter(GetChildren(LocalPlayer.Backpack), function(i, v)
        return IsA(v, "Tool");
    end)
    local Duped = {}
    local Humanoid = GetHumanoid();
    UnequipTools(Humanoid);
    local Connection = AddConnection(CConnect(GetCharacter().ChildAdded, function(Added)
        wait(.4);
        if (IsA(Added, "Tool")) then
            Added.Parent = LocalPlayer.Backpack
        end
    end), CEnv);
    for i = 1, Amount do
        if (not LoadCommand("dupetools").CmdEnv[1]) then
            do break end;
        end
        ReplaceCharacter();
        local OldPos
        if (Protected) then
            local OldFallen = Services.Workspace.FallenPartsDestroyHeight
            delay(Players.RespawnTime - .3, function()
                Services.Workspace.FallenPartsDestroyHeight = -math.huge
                OldPos = GetRoot().CFrame
                GetRoot().CFrame = CFrameNew(0, 1e9, 0);
                GetRoot().Anchored = true
            end)
        end
        UnequipTools(Humanoid);
        wait(Players.RespawnTime - .05);
        OldPos = OldPos or GetRoot().CFrame
        Humanoid = ReplaceHumanoid(Humanoid);
        local Tools = filter(GetChildren(LocalPlayer.Backpack), function(i, v)
            return IsA(v, "Tool");
        end)

        for i2, v in next, Tools do
            v.Parent = LocalPlayer.Character
            v.Parent = Services.Workspace
            Duped[#Duped + 1] = v
        end
        local Char = CWait(LocalPlayer.CharacterAdded);
        WaitForChild(Char, "HumanoidRootPart").CFrame = OldPos;

        for i2, v in next, Duped do
            if (v.Handle) then
                firetouchinterest(v.Handle, GetRoot(), 0);
                firetouchinterest(v.Handle, GetRoot(), 1);
            end
        end
        repeat CWait(RenderStepped);
            FindFirstChild(Char, "HumanoidRootPart").CFrame = OldPos
        until GetRoot().CFrame == OldPos

        repeat CWait(RenderStepped);
            Humanoid = FindFirstChild(Char, "Humanoid")
        until Humanoid
        wait(.4);
        UnequipTools(Humanoid);
        AmountDuped = AmountDuped + 1
    end
    Disconnect(Connection);
    return format("successfully duped %d tool (s)", #GetChildren(LocalPlayer.Backpack) - ToolAmount);
end)

AddCommand("dupetools2", {"rejoindupe"}, "sometimes a faster dupetools", {1,"1"}, function(Caller, Args)
    local Amount = tonumber(Args[1])
    if (not Amount) then
        return "amount must be a number"
    end
    local queue_on_teleport = syn and syn.queue_on_teleport or queue_on_teleport
    if (not queue_on_teleport) then
        return "exploit not supported"
    end
    local Root, Humanoid = GetRoot(), GetHumanoid();
    local OldPos = Root.CFrame
    Root.CFrame = CFrameNew(0, 2e5, 0);
    UnequipTools(Humanoid);

    local Tools = filter(GetChildren(LocalPlayer.Backpack), function(i, v)
        return IsA(v, "Tool");
    end)

    local Char, Workspace, ReplicatedStorage = GetCharacter(), Services.Workspace, Services.ReplicatedStorage
    for i, v in next, Tools do
        v.Parent = Char
        v.Parent = Workspace
    end
    writefile("fates-admin/tooldupe.txt", tostring(Amount - 1));
    writefile("fates-admin/tooldupe.lua", format([[
        local OldPos = CFrame.new(%s);
        local DupeAmount = tonumber(readfile("fates-admin/tooldupe.txt"));
        local game = game
        local GetService = game.GetService
        local Players = GetService(game, "Players");
        local Workspace = GetService(game, "Workspace");
        local ReplicatedFirst = GetService(game, "ReplicatedFirst");
        local TeleportService = GetService(game, "TeleportService");
        ReplicatedFirst.SetDefaultLoadingGuiRemoved(ReplicatedFirst);
        local WaitForChild, GetChildren, IsA = game.WaitForChild, game.GetChildren, game.IsA
        local LocalPlayer = Players.LocalPlayer
        if (not LocalPlayer) then
            repeat wait(); LocalPlayer = Players.LocalPlayer until LocalPlayer
        end
        local Char = LocalPlayer.CharacterAdded.Wait(LocalPlayer.CharacterAdded);
        local RootPart = WaitForChild(Char, "HumanoidRootPart");
        if (DupeAmount <= 1) then
            for i, v in next, GetChildren(Workspace) do
                if (IsA(v, "Tool")) then
                    firetouchinterest(v.Handle, RootPart, 0);
                    firetouchinterest(v.Handle, RootPart, 1);
                end
            end
            delfile("fates-admin/tooldupe.txt");
            delfile("fates-admin/tooldupe.lua");
            loadstring(game.HttpGet(game, "https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua"))();
            RootPart.CFrame = OldPos
            repeat wait() RootPart.CFrame = OldPos until RootPart.CFrame == OldPos
            getgenv().F_A.PluginLibrary.Execute("dp", {"1"}, LocalPlayer);
        else
            RootPart.CFrame = CFrame.new(0, 2e5, 0);
            wait(.3);
            for i, v in next, GetChildren(LocalPlayer.Backpack) do
                v.Parent = Char
                v.Parent = Workspace
            end
            writefile("fates-admin/tooldupe.txt", tostring(DupeAmount - 1));
            local queue_on_teleport = syn and syn.queue_on_teleport or queue_on_teleport
            queue_on_teleport(readfile("fates-admin/tooldupe.lua"));
            TeleportService.TeleportToPlaceInstance(TeleportService, game.PlaceId, game.JobId);
        end
    ]], tostring(OldPos)));
    local TeleportService = Services.TeleportService
    queue_on_teleport(readfile("fates-admin/tooldupe.lua"));
    TeleportService.TeleportToPlaceInstance(TeleportService, game.PlaceId, game.JobId);
end)

AddCommand("stopdupe", {}, "stops the dupe", {}, function()
    local Dupe = LoadCommand("dupetools").CmdEnv
    if (not next(Dupe)) then
        return "you are not duping tools"
    end
    LoadCommand("dupetools").CmdEnv[1] = false
    DisableAllCmdConnections("dupetools");
    return "dupetools stopped"
end)

AddCommand("savetools", {"st"}, "saves your tools", {1,3}, function(Caller, Args)
    UnequipTools(GetHumanoid());
    local Tools = GetChildren(LocalPlayer.Backpack);
    local Char = GetCharacter();
    for i, v in next, Tools do
        SpoofProperty(v, "Parent");
        v.Parent = Char
        v.Parent = Services.Workspace
        firetouchinterest(WaitForChild(Services.Workspace, v.Name).Handle, GetRoot(), 0);
        wait();
        firetouchinterest(v.Handle, GetRoot(), 1);
        WaitForChild(Char, v.Name).Parent = LocalPlayer.Backpack
    end
    Utils.Notify(Caller, nil, "Tools are now saved");
    CWait(GetHumanoid().Died);
    UnequipTools(GetHumanoid());
    Tools = GetChildren(LocalPlayer.Backpack);
    wait(Players.RespawnTime - wait()); -- * #Tools);
    for i, v in next, Tools do
        if (IsA(v, "Tool") and FindFirstChild(v, "Handle")) then
            v.Parent = Char
            v.Parent = Services.Workspace
        end
    end
    CWait(LocalPlayer.CharacterAdded);
    WaitForChild(LocalPlayer.Character, "HumanoidRootPart");
    for i, v in next, Tools do
        firetouchinterest(v.Handle, GetRoot(), 0);
        wait();
        firetouchinterest(v.Handle, GetRoot(), 1);
    end
    return "tools recovered??"
end)

AddCommand("givetools", {}, "gives all of your tools to a player", {3,1,"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local Root = GetRoot();
    local OldPos = Root.CFrame
    local Humanoid = FindFirstChildOfClass(LocalPlayer.Character, "Humanoid");
    Humanoid.Name = "1"
    local Humanoid2 = Clone(Humanoid);
    Humanoid2.Parent = LocalPlayer.Character
    Humanoid2.Name = "Humanoid"
    Services.Workspace.Camera.CameraSubject = Humanoid2
    wait()
    Destroy(Humanoid);
    local Char = GetCharacter();
    for i, v in next, Target do
        local TRoot = GetRoot(v);
        for i2, v2 in next, GetChildren(LocalPlayer.Backpack) do
            if (IsA(v2, "Tool")) then
                v2.Parent = GetCharacter();
                CFrameTool(v2, TRoot.CFrame);
                local Handle = v2.Handle
                for i3 = 1, 3 do
                    if (TRoot and Handle) then
                        firetouchinterest(TRoot, Handle, 1);
                        firetouchinterest(TRoot, Handle, 1);
                    end
                end
            end
        end
    end
    wait(.2);
    Destroy(Char);
    Char = CWait(LocalPlayer.CharacterAdded);
    WaitForChild(Char, "HumanoidRootPart").CFrame = OldPos
end)

AddCommand("givetool", {}, "gives your tool(s) to a player", {3,1,"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local ToolAmount = tonumber(Args[2]) or 1
    local Root = GetRoot();
    local OldPos = Root.CFrame
    local Humanoid = FindFirstChildOfClass(LocalPlayer.Character, "Humanoid");
    Humanoid.Name = "1"
    local Humanoid2 = Clone(Humanoid);
    Humanoid2.Parent = LocalPlayer.Character
    Humanoid2.Name = "Humanoid"
    Services.Workspace.Camera.CameraSubject = Humanoid2
    wait()
    Destroy(Humanoid);
    UnequipTools(Humanoid2);
    local Char = GetCharacter();
    for i, v in next, Target do
        local TRoot = GetRoot(v);
        local Tools = GetChildren(LocalPlayer.Backpack);
        for i2, v2 in next, Tools do
            if (IsA(v2, "Tool")) then
                v2.Parent = GetCharacter();
                CFrameTool(v2, TRoot.CFrame);
                local Handle = v2.Handle
                for i3 = 1, 3 do
                    if (TRoot and Handle) then
                        firetouchinterest(TRoot, Handle, 1);
                        firetouchinterest(TRoot, Handle, 1);
                    end
                end
            end
            if (i2 == ToolAmount) then
                break
            end
        end
    end
    wait(.2);
    Destroy(Char);
    Char = CWait(LocalPlayer.CharacterAdded);
    WaitForChild(Char, "HumanoidRootPart").CFrame = OldPos
end)

AddCommand("grabtools", {"gt"}, "grabs tools in the workspace", {3}, function(Caller, Args)
    local Tools = filter(GetDescendants(Services.Workspace), function(i,v)
        return IsA(v, "Tool") and FindFirstChild(v, "Handle");
    end)
    UnequipTools(GetHumanoid());
    local ToolAmount = #GetChildren(LocalPlayer.Backpack);
    for i, v in next, Tools do
        if (v.Handle) then
            firetouchinterest(v.Handle, GetRoot(), 0);
            wait();
            firetouchinterest(v.Handle, GetRoot(), 1);
        end
    end
    wait(.4);
    UnequipTools(GetHumanoid());
    return format(("grabbed %d tool (s)"), #GetChildren(LocalPlayer.Backpack) - ToolAmount)
end)

AddCommand("autograbtools", {"agt", "loopgrabtools", "lgt"}, "once a tool is added to workspace it will be grabbed", {3}, function(Caller, Args, CEnv)
    AddConnection(CConnect(Services.Workspace.ChildAdded, function(Child)
        if (IsA(Child, "Tool") and FindFirstChild(Child, "Handle")) then
            firetouchinterest(Child.Handle, GetRoot(), 0);
            wait();
            firetouchinterest(Child.Handle, GetRoot(), 1);
            UnequipTools(GetHumanoid());
        end
    end), CEnv)
    return "tools will be grabbed automatically"
end)

AddCommand("unautograbtools", {"unloopgrabtools"}, "stops autograbtools", {}, function()
    DisableAllCmdConnections("autograbtools");
    return "auto grabtools disabled"
end)

AddCommand("droptools", {"dt"}, "drops all of your tools", {1,3}, function()
    UnequipTools(GetHumanoid());
    local Tools = GetChildren(LocalPlayer.Backpack);
    for i, v in next, Tools do
        if (IsA(v, "Tool") and FindFirstChild(v, "Handle")) then
            SpoofProperty(v, "Parent");
            v.Parent = GetCharacter();
            v.Parent = Services.Workspace
        end
    end
    return format(("dropped %d tool (s)"), #Tools);
end)

AddCommand("nohats", {"nh"}, "removes all the hats from your character", {3}, function()
    local Humanoid = GetHumanoid();
    local HatAmount = #GetAccessories(Humanoid);
    for i, v in next, GetAccessories(Humanoid) do
        Destroy(v);
    end
    return format(("removed %d hat (s)"), HatAmount - #GetAccessories(Humanoid));
end)

AddCommand("clearhats", {"ch"}, "clears all of the hats in workspace", {3}, function()
    local Humanoid = GetHumanoid();
    for i, v in next, GetAccessories(Humanoid) do
        Destroy(v);
    end
    local Amount = 0
    for i, v in next, GetChildren(Services.Workspace) do
        if (IsA(v, "Accessory") and FindFirstChild(v, "Handle")) then
            firetouchinterest(v.Handle, GetRoot(), 0);
            wait();
            firetouchinterest(v.Handle, GetRoot(), 1);
            Destroy(WaitForChild(GetCharacter(), v.Name));
            Amount = Amount + 1
        end
    end
    return format(("cleared %d hat (s)"), Amount);
end)

AddCommand("gravity", {"grav"}, "sets the worksapaces gravity", {"1"}, function(Caller, Args)
    SpoofProperty(Services.Workspace, "Gravity");
    Services.Workspace.Gravity = tonumber(Args[1]) or Services.Workspace.Gravity
end)

AddCommand("nogravity", {"nograv", "ungravity"}, "removes the gravity", {}, function()
    Services.Workspace.Gravity = 192
end)

AddCommand("chatmute", {"cmute"}, "mutes a player in your chat", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local MuteRequest = Services.ReplicatedStorage.DefaultChatSystemChatEvents.MutePlayerRequest
    for i, v in next, Target do
        MuteRequest.InvokeServer(MuteRequest, v.Name);
        Utils.Notify(Caller, "Command", format("%s is now muted on your chat", v.Name));
    end
end)

AddCommand("unchatmute", {"uncmute"}, "unmutes a player in your chat", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local MuteRequest = Services.ReplicatedStorage.DefaultChatSystemChatEvents.UnMutePlayerRequest
    for i, v in next, Target do
        MuteRequest.InvokeServer(MuteRequest, v.Name);
        Utils.Notify(Caller, "Command", format("%s is now unmuted on your chat", v.Name));
    end
end)

AddCommand("delete", {}, "puts a players character in lighting", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        if (v.Character) then
            SpoofProperty(v.Character, "Parent");
            v.Character.Parent = Lighting
            Utils.Notify(Caller, "Command", v.Name .. "'s character is now parented to lighting");
        end
    end
end)

AddCommand("loopdelete", {"ld"}, "loop of delete command", {"1"}, function(Caller, Args, CEnv)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        if (v.Character) then
            SpoofProperty(v.Character, "Parent");
            v.Character.Parent = Lighting
        end
        local Connection = CConnect(v.CharacterAdded, function()
            v.Character.Parent = Lighting
        end)
        CEnv[v.Name] = Connection
        AddPlayerConnection(v, Connection);
    end
end)

AddCommand("unloopdelete", {"unld"}, "unloop the loopdelete", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local Looping = LoadCommand("loopdelete").CmdEnv
    for i, v in next, Target do
        if (Looping[v.Name]) then
            Disconnect(Looping[v.Name]);
        end
    end
end)

AddCommand("recover", {"undelete"}, "removes a players character parented from lighting", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        if (v.Character and v.Character.Parent == Lighting) then
            v.Character.Parent = Services.Workspace
            Utils.Notify(Caller, "Command", v.Name .. "'s character is now in workspace");
        else
            Utils.Notify(Caller, "Command", v.Name .. "'s character is not removed");
        end
    end
end)

AddCommand("load", {"loadstring"}, "loads whatever you want", {"1"}, function(Caller, Args)
    local Code = concat(Args, " ");
    local Success, Err = pcall(function()
        local Func = loadstring(Code);
        setfenv(Func, getrenv());
        local Context;
        local sett, gett = syn and syn_context_set or setidentity, syn and syn_context_get or getidentity
        if (sett and gett) then
            Context = gett();
            sett(2);
        end
        Func();
        if (Context and sett) then
            sett(Context);
        end
    end)
    if (not Success and Err) then
        return Err
    else
        return Func ~= nil and tostring(Func) or "executed with no errors"
    end
end)

AddCommand("sit", {}, "makes you sit", {3}, function(Caller, Args, CEnv)
    local Humanoid = GetHumanoid();
    SpoofProperty(Humanoid, "Sit", false);
    Humanoid.Sit = true
    return "now sitting (obviously)"
end)

AddCommand("infinitejump", {"infjump"}, "infinite jump no cooldown", {3}, function(Caller, Args, CEnv)
    AddConnection(CConnect(Services.UserInputService.JumpRequest, function()
        local Humanoid = GetHumanoid();
        if (Humanoid) then
            ChangeState(Humanoid, 3);
        end
    end), CEnv);
    return "infinite jump enabled"
end)

AddCommand("noinfinitejump", {"uninfjump", "noinfjump"}, "removes infinite jump", {}, function()
    local InfJump = LoadCommand("infjump").CmdEnv
    if (not next(InfJump)) then
        return "you are not infinite jumping"
    end
    DisableAllCmdConnections("infinitejump");
    return "infinite jump disabled"
end)

AddCommand("headsit", {"hsit"}, "sits on the players head", {"1"}, function(Caller, Args, CEnv)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        local Humanoid = GetHumanoid();
        SpoofProperty(Humanoid, "Sit");
        Humanoid.Sit = true
        AddConnection(CConnect(GetPropertyChangedSignal(Humanoid, "Sit"), function()
            Humanoid.Sit = true
        end), CEnv);
        local Root = GetRoot();
        AddConnection(CConnect(Heartbeat, function()
            Root.CFrame = v.Character.Head.CFrame * CFrameNew(0, 0, 1);
        end), CEnv);
    end
end)

AddCommand("unheadsit", {"noheadsit"}, "unheadsits on the target", {3}, function(Caller, Args)
    local Looped = LoadCommand("headsit").CmdEnv
    for i, v in next, Looped do
        Disconnect(v);
    end
    return "headsit disabled"
end)

AddCommand("headstand", {"hstand"}, "stands on a players head", {"1",3}, function(Caller, Args, CEnv)
    local Target = GetPlayer(Args[1]);
    local Root = GetRoot();
    for i, v in next, Target do
        local Loop = CConnect(Heartbeat, function()
            Root.CFrame = v.Character.Head.CFrame * CFrameNew(0, 1, 0);
        end)
        CEnv[v.Name] = Loop
        AddPlayerConnection(v, Loop);
    end
end)

AddCommand("unheadstand", {"noheadstand"}, "unheadstands on the target", {3}, function(Caller, Args)
    local Looped = LoadCommand("headstand").CmdEnv
    for i, v in next, Looped do
        Disconnect(v);
    end
    return "headstand disabled"
end)

AddCommand("setspawn", {}, "sets your spawn location to the location you are at", {3}, function(Caller, Args, CEnv)
    if (CEnv[1]) then
        Disconnect(CEnv[1]);
    end
    local Position = GetRoot().CFrame
    local Spawn = CConnect(LocalPlayer.CharacterAdded, function()
        WaitForChild(LocalPlayer.Character, "HumanoidRootPart").CFrame = Position
    end)
    CEnv[1] = Spawn
    AddPlayerConnection(LocalPlayer, Spawn);
    local SpawnLocation = pack(unpack(split(tostring(Position), ", "), 1, 3));
    SpawnLocation.n = nil
    return "spawn successfully set to " .. concat(map(SpawnLocation, function(i,v)
        return tostring(round(tonumber(v)));
    end), ",");
end)

AddCommand("removespawn", {}, "removes your spawn location", {}, function(Caller, Args)
    local Spawn = LoadCommand("setspawn").CmdEnv[1]
    if (Spawn) then
        Disconnect(Spawn);
        return "removed spawn location"
    end
    return "you don't have a spawn location set"
end)

AddCommand("ping", {}, "shows you your ping", {}, function()
    local Stats = Services.Stats
    local DataPing = Stats.Network.ServerStatsItem["Data Ping"]
    return split(DataPing.GetValueString(DataPing), " ")[1] .. " ms"
end)

AddCommand("memory", {"mem"}, "shows you your memory usage", {}, function()
    local Stats = Services.Stats
    return tostring(round(Stats.GetTotalMemoryUsageMb(Stats))) .. " mb";
end)

AddCommand("fps", {"frames"}, "shows you your framerate", {}, function()
    local Counter = Utils.Notify(LocalPlayer, "FPS", "", 10);
    local a = tick();
    local Running
    local fpsget = function()
        if (not Counter or not Counter.Message) then
            Disconnect(Running);
        end
        Counter.Message.Text = bit32.bnot(bit32.bnot((1 / (tick() - a))));
        a = tick();
    end
    delay(3, function()
        Disconnect(Running);
    end);
    Running = CConnect(Heartbeat, fpsget);
end)

AddCommand("displaynames", {}, "enables/disables display names (on/off)", {{"on","off"}}, function(Caller, Args, CEnv)
    local Option = Args[1]
    local Players = Services.Players

    local ShowName = function(v)
        if (v.Name ~= v.DisplayName) then
            if (v.Character) then
                v.Character.Humanoid.DisplayName = v.Name
            end
            local Connection = CConnect(v.CharacterAdded, function()
                WaitForChild(v.Character, "Humanoid").DisplayName = v.Name
            end)
            CEnv[v.Name] = {v.DisplayName, Connection}
            AddPlayerConnection(v, Connection);
        end
    end
    if (lower(Option) == "off") then
        for i, v in next, GetPlayers(Players) do
            ShowName(v);
        end
        AddConnection(CConnect(Players.PlayerAdded, ShowName));
        return "people with a displayname displaynames will be shown"
    elseif (lower(Option) == "on") then
        for i, v in next, LoadCommand("displaynames").CmdEnv do
            if (type(v) == 'userdata' and v.Disconnect) then
                Disconnect(v);
            else
                if (i.Character) then
                    i.Character.Humanoid.DisplayName = v[1]
                end
                Disconnect(v[2]);
                v = nil
            end
        end
        return "people with a displayname displaynames will be removed"
    end
end)

AddCommand("time", {"settime"}, "sets the games time", {{"night", "day", "dawn"}}, function(Caller, Args)
    local Lighting = Services.Lighting
    local Time = Args[1] and lower(Args[1]) or 14
    local Times = {["night"]=0,["day"]=14,["dawn"]=6}
    SpoofProperty(Lighting, "ClockTime", true);
    Lighting.ClockTime = Times[Time] or Time
end)

AddCommand("fling", {}, "flings a player", {}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local Root = GetRoot()
    SpoofProperty(Root, "Velocity");
    SpoofProperty(Root, "Anchored");
    local OldPos, OldVelocity = Root.CFrame, Root.Velocity

    for i, v in next, Target do
        local TargetRoot = GetRoot(v);
        local TargetPos = TargetRoot.Position
        local Running = CConnect(Stepped, function(step)
            step = step - Services.Workspace.DistributedGameTime

            Root.CFrame = (TargetRoot.CFrame - (Vector3New(0, 1e6, 0) * step)) + (TargetRoot.Velocity * (step * 30))
            Root.Velocity = Vector3New(0, 1e6, 0)
        end)
        local starttime = tick();
        repeat
            wait();
        until (TargetPos - TargetRoot.Position).magnitude >= 60 or tick() - starttime >= 3.5
        Disconnect(Running);
    end
    wait();
    local Running = CConnect(Stepped, function()
        Root.Velocity = OldVelocity
        Root.CFrame = OldPos
    end)
    wait(2);
    Root.Anchored = true
    Disconnect(Running);
    Root.Anchored = false
    Root.Velocity = OldVelocity
    Root.CFrame = OldPos
end)

AddCommand("fling2", {}, "another variant of fling", {}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local Root = GetRoot();
    local OldPos = Root.CFrame
    local OldVelocity = Root.Velocity
    local BodyVelocity = InstanceNew("BodyAngularVelocity");
    ProtectInstance(BodyVelocity);
    BodyVelocity.MaxTorque = Vector3New(1, 1, 1) * math.huge
    BodyVelocity.P = math.huge
    BodyVelocity.AngularVelocity = Vector3New(0, 9e5, 0);
    BodyVelocity.Parent = Root

    local Char = GetChildren(GetCharacter());
    for i, v in next, Char do
        if (IsA(v, "BasePart")) then
            v.CanCollide = false
            v.Massless = true
            v.Velocity = Vector3New(0, 0, 0);
        end
    end
    local Noclipping = CConnect(Stepped, function()
        for i, v in next, Char do
            if (IsA(v, "BasePart")) then
                v.CanCollide = false
            end
        end
    end)
    for i, v in next, Target do
        local Fling
        Fling = CConnect(Stepped, function()
            Root.CFrame = GetRoot(v).CFrame
        end)
        local Continue = false
        delay(2, function()
            Continue = true
        end)
        repeat wait() until GetMagnitude(v) >= 60 or Continue
        Disconnect(Fling);
    end
    Destroy(BodyVelocity);
    Disconnect(Noclipping);
    for i, v in next, Char do
        if (IsA(v, "BasePart")) then
            v.CanCollide = true
            v.Massless = false
        end
    end
    local Running = CConnect(Stepped, function()
        Root.CFrame = OldPos
        Root.Velocity = OldVelocity
    end)
    wait(2);
    Root.Anchored = true
    Disconnect(Running);
    Root.Anchored = false
    Root.Velocity = OldVelocity
    Root.CFrame = OldPos
end)

AddCommand("antitkill", {}, "anti tkill :troll:", {3}, function(Caller, Args)
    Destroy(GetCharacter()["Right Arm"]);
    return "lol"
end)

AddCommand("antiattach", {"anticlaim"}, "enables antiattach", {3}, function(Caller, Args)
    local Tools = {}
    for i, v in next, tbl_concat(GetChildren(LocalPlayer.Character), GetChildren(LocalPlayer.Backpack)) do
        if (IsA(v, "Tool")) then
            Tools[#Tools + 1] = v
        end
    end
    AddConnection(CConnect(LocalPlayer.Character.ChildAdded, function(x)
        if (not Tfind(Tools, x) and IsA(x, "Tool")) then
            x.Parent = LocalPlayer.Backpack
        end
    end))
end)

AddCommand("attach", {}, "attaches you to another player", {3,1}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local Humanoid = ReplaceHumanoid();
    local Char = GetCharacter();
    for i, v in next, Target do
        local Tool = FindFirstChildWhichIsA(Char, "Tool") or FindFirstChildWhichIsA(LocalPlayer.Backpack, "Tool");
        Tool.Parent = Char
        local TargetRoot = GetRoot(v);
        if (TargetRoot and Tool) then
            firetouchinterest(TargetRoot, Tool.Handle, 0);
            firetouchinterest(TargetRoot, Tool.Handle, 1);
        end
    end
end)

AddCommand("skill", {"swordkill"}, "swordkills the user auto", {1, {"player", "manual"}}, function(Caller, Args)
    local Target, Option = GetPlayer(Args[1]), Args[2] or ""
    local Backpack, Character = LocalPlayer.Backpack, GetCharacter();
    local Tool = FindFirstChild(Character, "ClassicSword") or FindFirstChild(Backpack, "ClassicSword") or FindFirstChildOfClass(Backpack, "Tool") or FindFirstChildOfClass(Character, "Tool");
    Tool.Parent = Character
    local OldPos = GetRoot().CFrame
    for i, v in next, Target do
        CThread(function()
            if (FindFirstChild(v.Character, "ForceField")) then
                repeat wait() until not FindFirstChild(v.Character, "ForceField");
            end
            for i2 = 1, 5 do
                if (lower(Option) == "manual") then
                    GetRoot().CFrame = GetRoot(v).CFrame * CFrameNew(0, -3, 0);
                    Tool.Activate(Tool);
                    Tool.Activate(Tool);
                    wait();
                else
                    Tool.Activate(Tool);
                    firetouchinterest(Tool.Handle, GetRoot(v), 0);
                    wait();
                    firetouchinterest(Tool.Handle, GetRoot(v), 1);
                    wait();
                end
            end
            wait();
            if (lower(Option) == "manual") then
                WaitForChild(LocalPlayer.Character, "HumanoidRootPart").CFrame = OldPos
            end
        end)()
    end
end)

AddCommand("reach", {"swordreach"}, "changes handle size of your tool", {1, 3}, function(Caller, Args, CEnv)
    local Amount = Args[1] or 2
    local Tool = FindFirstChildWhichIsA(LocalPlayer.Character, "Tool") or FindFirstChildWhichIsA(LocalPlayer.Backpack, "Tool");
    local Handle = Tool.Handle
    local Size = Handle.Size
    CEnv[Tool] = Size
    SpoofProperty(Handle, "Size");
    SpoofProperty(Handle, "Massless");
    Handle.Size = Vector3New(Size.X, Size.Y, tonumber(Amount or 30));
    Handle.Massless = true
    return "reach on"
end)

AddCommand("noreach", {"noswordreach"}, "removes sword reach", {}, function()
    local ReachedTools = LoadCommand("reach").CmdEnv
    if (not next(ReachedTools)) then
        return "reach isn't enabled"
    end
    for i, v in next, ReachedTools do
        i.Size = v
    end
    LoadCommand("reach").CmdEnv = {}
    return "reach disabled"
end)

AddCommand("swordaura", {"saura"}, "sword aura", {3}, function(Caller, Args, CEnv)
    DisableAllCmdConnections("swordaura");

    local SwordDistance = tonumber(Args[1]) or 10
    local Tool = FindFirstChildWhichIsA(GetCharacter(), "Tool") or FindFirstChildWhichIsA(LocalPlayer.Backpack, "Tool");
    local PlayersTbl = filter(GetPlayers(Players), function(i, v)
        return v ~= LocalPlayer
    end)
    PlayersTbl = map(PlayersTbl, function(i, Player)
        AddConnection(CConnect(Player.CharacterAdded, function()
            PlayersTbl[i] = {Player, Player.Character}
        end), CEnv);
        return {Player, Player.Character}
    end)

    local Hit = function(i, v)
        Tool.Activate(Tool);
        if (FindFirstChild(Tool, "Handle")) then
            firetouchinterest(Tool.Handle, v, 0);
            wait();
            firetouchinterest(Tool.Handle, v, 1);
        elseif (FindFirstChild(Tool, "HitBox")) then
            firetouchinterest(Tool.HitBox, v, 0);
            wait();
            firetouchinterest(Tool.HitBox, v, 1);
        else 
            local Part = FindFirstChildOfClass(Tool, "Part")
            if (Part) then
                firetouchinterest(Tool.HitBox, v, 0);
                wait();
                firetouchinterest(Tool.HitBox, v, 1);
            end
        end
    end
    local Character = GetCharacter();
    AddConnection(CConnect(Heartbeat, function()
        Character = Character or GetCharacter();
        Tool = FindFirstChildWhichIsA(Character, "Tool") or FindFirstChildWhichIsA(LocalPlayer.Backpack, "Tool");
        if (Tool and Tool.Handle) then
            for i, v in next, PlayersTbl do
                if (GetRoot(v[1], v[2]) and GetHumanoid(v[1], v[2]) and GetHumanoid(v[1], v[2]).Health ~= 0 and GetMagnitude(v[1], v[2]) <= SwordDistance) then
                    if (GetHumanoid().Health ~= 0) then
                        Tool.Parent = Character
                        local BaseParts = filter(GetChildren(GetCharacter(v[1], v[2])), function(i, v)
                            return IsA(v, "BasePart");
                        end)
                        forEach(BaseParts, Hit);
                    end
                end
            end
        end
    end), CEnv);

    AddConnection(CConnect(Players.PlayerAdded, function(Plr)
        PlayersTbl[#PlayersTbl + 1] = Plr
    end), CEnv);
    AddConnection(CConnect(Players.PlayerRemoving, function(Plr)
        PlayersTbl[indexOf(PlayersTbl, Plr)] = nil
    end), CEnv);

    return "sword aura enabled with distance " .. SwordDistance
end)

AddCommand("noswordaura", {"noaura"}, "stops the sword aura", {}, function()
    local Aura = LoadCommand("swordaura").CmdEnv
    if (not next(Aura)) then
        return "sword aura is not enabled"
    end
    DisableAllCmdConnections("swordaura");
    return "sword aura disabled"
end)

AddCommand("freeze", {}, "freezes your character", {3}, function(Caller, Args)
    local BaseParts = filter(GetChildren(GetCharacter(v)), function(i, v)
        return IsA(v, "BasePart");
    end)
    for i, v in next, BaseParts do
        SpoofProperty(v, "Anchored");
        v.Anchored = true
    end
    return "freeze enabled (client)"
end)

AddCommand("unfreeze", {"thaw"}, "unfreezes your character", {3}, function(Caller, Args)
    local BaseParts = filter(GetChildren(GetCharacter(v)), function(i, v)
        return IsA(v, "BasePart");
    end)
    for i, v in next, BaseParts do
        v.Anchored = false
    end
    return "freeze disabled"
end)

AddCommand("streamermode", {}, "changes names of everyone to something random", {}, function(Caller, Args, CEnv)
    local Rand = function(len) return gsub(sub(GenerateGUID(Services.HttpService), 2, len), "-", "") end
    local Players = Services.Players
    local Hide = function(a, v)
        if (v and IsA(v, "TextLabel") or IsA(v, "TextButton")) then
            local Player = GetPlayer(v.Text, true);
            if (not Player[1]) then
                Player = GetPlayer(sub(v.Text, 2, #v.Text - 2), true);
            end
            v.Text = Player[1] and Player[1].Name or v.Text
            if (Player and FindFirstChild(Players, v.Text)) then
                CEnv[v.Name] = v.Text
                local NewName = Rand(len(v.Text));
                if (GetCharacter(v.Text)) then
                    Players[v.Text].Character.Humanoid.DisplayName = NewName
                end
                v.Text = NewName
            end
        end
    end

    forEach(GetDescendants(game), Hide);

    AddConnection(CConnect(game.DescendantAdded, function(x)
        Hide(nil, x);
    end), CEnv);
    return "streamer mode enabled"
end)

AddCommand("nostreamermode", {"unstreamermode"}, "removes all the changed names", {}, function(Caller, Args, CEnv)
    local changed = LoadCommand("streamermode").CmdEnv
    for i, v in next, changed do
        if (type(v) == 'userdata' and v.Disconnect) then
            Disconnect(v);
        else
            i.Text = v
        end
    end
end)

AddCommand("fireclickdetectors", {"fcd"}, "fires all the click detectors", {3}, function(Caller, Args)
    local amount = 0
    local howmany = Args[1]
    for i, v in next, GetDescendants(Services.Workspace) do
        if (IsA(v, "ClickDetector")) then
            fireclickdetector(v);
            amount = amount + 1
            if (howmany and amount == tonumber(howmany)) then break; end
        end
    end
    return format("fired %d amount of clickdetectors", amount);
end)

AddCommand("firetouchinterests", {"fti"}, "fires all the touch interests", {3}, function(Caller, Args)
    local amount = 0
    local howmany = Args[1]
    for i, v in next, GetDescendants(Services.Workspace) do
        if (IsA(v, "TouchTransmitter")) then
            firetouchinterest(GetRoot(), v.Parent, 0);
            wait();
            firetouchinterest(GetRoot(), v.Parent, 1);
            amount = amount + 1
            if (howmany and amount == tonumber(howmany)) then break; end
        end
    end
    return format("fired %d amount of touchtransmitters", amount);
end)

AddCommand("fireproximityprompts", {"fpp"}, "fires all the proximity prompts", {3}, function(Caller, Args)
    local amount = 0
    local howmany = Args[1]
    for i, v in next, GetDescendants(Services.Workspace) do
        if (IsA(v, "ProximityPrompt")) then
            fireproximityprompt(v, 0);
            wait();
            fireproximityprompt(v, 1);
            amount = amount + 1
            if (howmany and amount == tonumber(howmany)) then break; end
        end
    end
    return format("fired %d amount of proximityprompts", amount);
end)

AddCommand("muteboombox", {}, "mutes a users boombox", {}, function(Caller, Args)
    Services.SoundService.RespectFilteringEnabled = false
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        for i2, v2 in next, GetDescendants(v.Character) do
            if (IsA(v2, "Sound")) then
                v2.Playing = false
            end
        end
    end
    Services.SoundService.RespectFilteringEnabled = true
end)

AddCommand("loopmuteboombox", {"loopmute"}, "loop mutes a users boombox", {}, function(Caller, Args, CEnv)
    local Target = GetPlayer(Args[1]);
    local filterBoomboxes = function(i,v)
        return FindFirstChild(v, "Handle") and FindFirstChildWhichIsA(v.Handle, "Sound");
    end
    Services.SoundService.RespectFilteringEnabled = false
    local Con = AddConnection(CConnect(Heartbeat, function()
        for i, v in next, Target do
            for i2, v2 in next, GetDescendants(v.Backpack) do
                if (IsA(v2, "Sound")) then
                    v2.Playing = false
                end
            end
            local Char = GetCharacter(v)
            if (Char) then
                for i22, v2 in next, GetDescendants(Char) do
                    if (IsA(v2, "Sound")) then
                        v2.Playing = false
                    end
                end
            end
        end
    end));
    CEnv[Target] = Con
end)

AddCommand("unloopmuteboombox", {}, "unloopmutes a persons boombox", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1])
    local Muting = LoadCommand("loopmuteboombox").CmdEnv
    for i, v in next, Muting do
        for i2, v2 in next, Target do
            if (v2 == i) then
                Disconnect(v);
                Muting[i] = nil
            end
        end
    end
end)

AddCommand("forceplay", {}, "forcesplays an audio", {1,3,"1"}, function(Caller, Args, CEnv)
    local Id = Args[1]
    local filterBoomboxes = function(i,v)
        return IsA(v, "Tool") and FindFirstChild(v, "Handle") and FindFirstChildWhichIsA(v.Handle, "Sound");
    end
    UnequipTools(GetHumanoid());
    local Boombox = filter(GetChildren(LocalPlayer.Backpack), filterBoomboxes)
    if (not next(Boombox)) then
        return "you need a boombox to forceplay"
    end
    Services.SoundService.RespectFilteringEnabled = false
    Boombox = Boombox[1]
    Boombox.Parent = GetCharacter();
    local Sound = Boombox.Handle.Sound
    Sound.SoundId = "http://roblox.com/asset/?id=" .. Id
    local RemoteEvent = FindFirstChildWhichIsA(Boombox, "RemoteEvent")
    RemoteEvent.FireServer(RemoteEvent, "PlaySong", tonumber(Id));
    Boombox.Parent = LocalPlayer.Backpack
    CEnv[Boombox] = true
    CThread(function()
        while (LoadCommand("forceplay").CmdEnv[Boombox]) do
            Boombox.Handle.Sound.Playing = true
            CWait(Heartbeat);
        end
        Services.SoundService.RespectFilteringEnabled = true
    end)()
    return "now forceplaying ".. Id
end)

AddCommand("unforceplay", {}, "stops forceplay", {}, function()
    local Playing = LoadCommand("forceplay").CmdEnv
    for i, v in next, Playing do
        FindFirstChild(i, "Sound", true).Playing = false
        LoadCommand("forceplay").CmdEnv[i] = false
    end
    return "stopped forceplay"
end)

AddCommand("audiotime", {"audiotimeposition"}, "changes audio timeposition", {"1",1}, function(Caller, Args)
    local Time = Args[1]
    if (not tonumber(Time)) then
        return "time must be a number"
    end
    local filterplayingboomboxes = function(i,v)
        return IsA(v, "Tool") and FindFirstChild(v, "Handle") and FindFirstChildWhichIsA(v.Handle, "Sound") and FindFirstChildWhichIsA(v.Handle, "Sound").Playing == true
    end
    local OtherPlayingBoomboxes = LoadCommand("forceplay").CmdEnv
    local Boombox = filter(tbl_concat(GetChildren(LocalPlayer.Backpack), GetChildren(GetCharacter())), filterplayingboomboxes)
    if (not next(Boombox) and not next(OtherPlayingBoomboxes)) then
        return "you need a boombox to change the timeposition"
    end
    Boombox = Boombox[1]
    if (Boombox) then
        FindFirstChild(Boombox, "Sound", true).TimePosition = floor(tonumber(Time));
    else
        for i, v in next, OtherPlayingBoomboxes do
            FindFirstChild(i, "Sound", true).TimePosition = floor(tonumber(Time));
        end
    end
    return "changed time position to " .. Time
end)

AddCommand("audiolog", {}, "audio logs someone", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        for i2, v2 in next, GetDescendants(v.Character) do
            if (IsA(v2, "Sound") and IsA(v2.Parent.Parent, "Tool")) then
                local AudioId = split(v2.SoundId, "=")[2]
                setclipboard(AudioId);
                Utils.Notify(Caller, "Command", format("Audio Id (%s) copied to clipboard", AudioId));
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
    return format("%s's position: %s", Target.Name, Pos);
end)

AddCommand("grippos", {}, "changes grippos of your tool", {"3"}, function(Caller, Args, CEnv)
    local Tool = FindFirstChildWhichIsA(GetCharacter(), "Tool") or FindFirstChildWhichIsA(LocalPlayer.Backpack, "Tool");
    SpoofProperty(Tool, "GripPos");
    Tool.GripPos = Vector3New(tonumber(Args[1]), tonumber(Args[2]), tonumber(Args[3]));
    Tool.Parent = GetCharacter();
    return "grippos set"
end)

AddCommand("truesightguis", {"tsg"}, "true sight on all guis", {}, function(Caller, Args, CEnv)
    for i, v in next, GetDescendants(game) do
        if (IsA(v, "Frame") or IsA(v, "ScrollingFrame") and not v.Visible) then
            CEnv[v] = v.Visible
            SpoofProperty(v, "Visible");
            v.Visible = true
        end
    end
    return "truesight for guis are now on"
end)

AddCommand("notruesightguis", {"untruesightguis", "notsg"}, "removes truesight on guis", {}, function(Caller, Args)
    local Guis = LoadCommand("truesightguis").CmdEnv
    for i, v in next, Guis do
        i.Visible = v
    end
    return "truesight for guis are now off"
end)

AddCommand("esp", {"aimbot", "cameralock", "silentaim", "aimlock", "tracers"}, "loads fates esp", {}, function(Caller, Args, CEnv)
    CEnv.KillEsp = loadstring(game.HttpGet(game, "https://raw.githubusercontent.com/fatesc/fates-esp/main/main.lua"))();
    return "esp enabled"
end)

AddCommand("unesp", {"noesp"}, "removes esp", {}, function()
    local Kill = LoadCommand("esp").CmdEnv.KillEsp
    if (Kill) then
        Kill()
    end
    return "esp removed"
end)

local EspLib;
AddCommand("trace", {"locate"}, "traces a player", {"1"}, function(Caller, Args, CEnv)
    if (not EspLib) then
        EspLib = loadstring(game.HttpGet(game, "https://raw.githubusercontent.com/fatesc/fates-esp/main/esp-lib/esplibmain.lua"))();
    end
    local Target = GetPlayer(Args[1]);
    local New = EspLib.new
    for i, v in next, Target do
        New("Tracer", {
            Target = v
        });
        New("Text", {
            Target = v,
            ShowHealth = true,
            ShowDistance = true
        });
    end
    AddConnection(CConnect(Services.Players.PlayerRemoving, function(Plr)
        if (Tfind(Target, Plr)) then
            EspLib.Remove(v);
        end
    end), CEnv);
    return format("now tracing %s", #Target == 1 and Target[1].Name or #Target .. " players");
end)
AddCommand("untrace", {"unlocate"}, "untraces a player", {"1"}, function(Caller, Args)
    if (not EspLib) then
        EspLib = loadstring(game.HttpGet(game, "https://raw.githubusercontent.com/fatesc/fates-esp/main/esp-lib/esplibmain.lua"))();
    end
    local Target = GetPlayer(Args[1]);
    local Remove = EspLib.Remove
    for i, v in next, Target do
        Remove(v);
    end
    return format("now stopped tracing %s", #Target == 1 and Target[1].Name or #Target .. " players");
end)


AddCommand("crosshair", {}, "enables a crosshair", {function()
    return Drawing ~= nil
end}, function(Caller, Args, CEnv)
    if (CEnv[1] and CEnv[2] and CEnv[1].Transparency ~= 0) then
        CEnv[1].Remove(CEnv[1]);
        CEnv[2].Remove(CEnv[2]);
        CEnv[1] = nil
        CEnv[2] = nil
        return "crosshair disabled"
    end
    local Viewport = Camera.ViewportSize
    local Y = Drawing.new("Line");
    local X = Drawing.new("Line");
    Y.Thickness = 1
    X.Thickness = 1
    Y.Transparency = 1
    X.Transparency = 1
    Y.Visible = true
    X.Visible = true
    Y.To = Vector2.new(Viewport.X / 2, Viewport.Y / 2 - 10);
    X.To = Vector2.new(Viewport.X / 2 - 10, Viewport.Y / 2);
    Y.From = Vector2.new(Viewport.X / 2, Viewport.Y / 2 + 10);
    X.From = Vector2.new(Viewport.X / 2 + 10, Viewport.Y / 2);
    CEnv[1] = Y
    CEnv[2] = X
    return "crosshair enabled"
end)

AddCommand("walkto", {}, "walks to a player", {"1", 3}, function(Caller, Args)
    local Target = GetPlayer(Args[1])[1];
    local Humanoid = GetHumanoid();
    Humanoid.MoveTo(Humanoid, GetRoot(Target).Position);
    return "walking to " .. Target.Name
end)

AddCommand("follow", {}, "follows a player", {"1", 3}, function(Caller, Args, CEnv)
    local Target = GetPlayer(Args[1])[1]
    CEnv[Target.Name] = true
    CThread(function()
        repeat
            local Humanoid = GetHumanoid();
            Humanoid.MoveTo(Humanoid, GetRoot(Target).Position);
            wait(.2);
        until not LoadCommand("follow").CmdEnv[Target.Name]
    end)()
    return "now following " .. Target.Name
end)

AddCommand("unfollow", {}, "unfollows a player", {}, function()
    local Following = LoadCommand("follow").CmdEnv
    if (not next(Following)) then
        return "you are not following anyone"
    end
    LoadCommand("follow").CmdEnv = {}
    return "stopped following"
end)

AddCommand("age", {}, "ages a player", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        local AccountAge = v.AccountAge
        local t = os.date("*t", os.time());
        t.day = t.day - tonumber(AccountAge);
        local CreatedAt = os.date("%d/%m/%y", os.time(t));
        Utils.Notify(Caller, "Command", format("%s's age is %s (%s)", v.Name, AccountAge, CreatedAt));
    end
end)

AddCommand("nosales", {}, "no purchase prompt notifications will be shown", {}, function()
    Services.CoreGui.PurchasePromptApp.Enabled = false
    return "You'll no longer recive sale prompts"
end)

AddCommand("volume", {"vol"}, "changes your game volume", {}, function(Caller, Args)
    local Volume = tonumber(Args[1]);
    if (not Volume or Volume > 10 or Volume < 0) then
        return "volume must be a number between 0-10";
    end
    local UserSettings = UserSettings()
    UserSettings.GetService(UserSettings, "UserGameSettings").MasterVolume = Volume / 10
    return "volume set to " .. Volume
end)

AddCommand("antikick", {}, "client sided bypasses to kicks", {}, function()
    Hooks.AntiKick = not Hooks.AntiKick
    return "client sided antikick " .. (Hooks.AntiKick and "enabled" or "disabled")
end)

AddCommand("antiteleport", {}, "client sided bypasses to teleports", {}, function()
    AntiTeleport = not AntiTeleport
    return "client sided antiteleport " .. (AntiTeleport and "enabled" or "disabled")
end)

AddCommand("autorejoin", {}, "auto rejoins the game when you get kicked", {}, function(Caller, Args, CEnv)
    local GuiService = Services.GuiService
    CThread(function()
        CWait(GuiService.ErrorMessageChanged);
        CWait(GuiService.ErrorMessageChanged);
        if (GuiService.GetErrorCode(GuiService) == Enum.ConnectionError.DisconnectLuaKick) then
            if (#GetPlayers(Players) == 1) then
                Services.TeleportService.Teleport(Services.TeleportService, game.PlaceId);
            else
                Services.TeleportService.TeleportToPlaceInstance(Services.TeleportService, game.PlaceId, game.JobId);
            end
        end
    end)()
    return "auto rejoin enabled (rejoins when you get kicked from the game)"
end)

AddCommand("respawn", {}, "respawns your character", {3}, function()
    local OldPos = GetRoot().CFrame
    local Char = GetCharacter();
    Char.BreakJoints(Char);
    CWait(LocalPlayer.CharacterAdded);
    WaitForChild(LocalPlayer.Character, "HumanoidRootPart").CFrame = OldPos
    return "respawned"
end)

AddCommand("reset", {}, "resets your character", {3}, function()
    local Char = GetCharacter();
    Char.BreakJoints(Char);
end)

AddCommand("refresh", {"re"}, "refreshes your character", {3}, function(Caller)
    ReplaceCharacter();
    wait(Players.RespawnTime - 0.03);
    local OldPos = GetRoot().CFrame
    ReplaceHumanoid()
    CWait(LocalPlayer.CharacterAdded)
    WaitForChild(LocalPlayer.Character, "HumanoidRootPart").CFrame = OldPos
    return "character refreshed"
end)

AddCommand("addalias", {}, "adds an alias to a command", {}, function(Caller, Args)
    local Command = Args[1]
    local Alias = Args[2]
    if (CommandsTable[Command]) then
        local Add = CommandsTable[Command]
        Add.Name = Alias
        CommandsTable[Alias] = Add
        local CurrentAliases = GetConfig().Aliases or {}
        CurrentAliases[Command] = CurrentAliases[Command] or {}
        local AliasesForCommand = CurrentAliases[Command]
        AliasesForCommand[#AliasesForCommand + 1] = Alias
        SetConfig({Aliases=CurrentAliases});
        return format("%s is now an alias of %s", Alias, Command);
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
        return format("removed alias %s from %s", Alias, Cmd.Name);
    end
    return "you can't remove commands"
end)

AddCommand("chatlogs", {"clogs"}, "enables chatlogs", {}, function()
    local MessageClone = Clone(ChatLogs.Frame.List);

    Utils.ClearAllObjects(ChatLogs.Frame.List)
    ChatLogs.Visible = true

    local Tween = Utils.TweenAllTransToObject(ChatLogs, .25, ChatLogsTransparencyClone)

    Destroy(ChatLogs.Frame.List)
    MessageClone.Parent = ChatLogs.Frame

    for i, v in next, GetChildren(ChatLogs.Frame.List) do
        if (not IsA(v, "UIListLayout")) then
            Utils.Tween(v, "Sine", "Out", .25, {
                TextTransparency = 0
            })
        end
    end

    local ChatLogsListLayout = ChatLogs.Frame.List.UIListLayout

    CConnect(GetPropertyChangedSignal(ChatLogsListLayout, "AbsoluteContentSize"), function()
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
    do return "Command Disabled" end

    local MessageClone = Clone(GlobalChatLogs.Frame.List);

    Utils.ClearAllObjects(GlobalChatLogs.Frame.List);
    GlobalChatLogs.Visible = true

    local Tween = Utils.TweenAllTransToObject(GlobalChatLogs, .25, GlobalChatLogsTransparencyClone);


    MessageClone.Parent = ChatLogs.Frame

    for i, v in next, GetChildren(GlobalChatLogs.Frame.List) do
        if (not IsA(v, "UIListLayout")) then
            Utils.Tween(v, "Sine", "Out", .25, {
                TextTransparency = 0
            })
        end
    end

    local GlobalChatLogsListLayout = GlobalChatLogs.Frame.List.UIListLayout

    CConnect(GetPropertyChangedSignal(GlobalChatLogsListLayout, "AbsoluteContentSize"), function()
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

        local MakeMessage = function(Message, Color)
            Clone.Text = Message
            if (Color) then
                Clone.TextColor3 = Color
            end
            Clone.Visible = true
            Clone.TextTransparency = 1
            Clone.Parent = GlobalChatLogs.Frame.List
            Utils.Tween(Clone, "Sine", "Out", .25, {
                TextTransparency = 0
            });
            GlobalChatLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, GlobalChatLogs.Frame.List.UIListLayout.AbsoluteContentSize.Y);

        end

        CConnect(Socket.OnMessage, function(msg)
            if (GlobalChatLogsEnabled) then
                local OP, DATA = unpack(JSONDecode(Services.HttpService, msg));
                local Clone = Clone(GlobalChatLogMessage);
                local CurrentTime = tostring(os.date("%X"));
                if (OP == "received_message") then
                    MakeMessage(format("%s - [%s]: %s", CurrentTime, DATA.username, msg.message));
                elseif (OP == "admin_message") then
                    MakeMessage(format("%s - [%s]: %s", CurrentTime, DATA.username, msg.message), Color3.fromRGB(DATA.Color.R, DATA.Color.G, DATA.Color.B));
                elseif (OP == "verification_needed") then
                    MakeMessage(format("[%s] - [C-LOG]: You need to visit http://whatever/chat/verify", CurrentTime), Color3.fromRGB(255, 0, 0));
                elseif (OP == "error") then
                    MakeMessage(format("[%s] - [C-LOG]: %s", CurrentTime, DATA.message));
                end

            end
        end)
        local MessageSender = require(LocalPlayer.PlayerScripts.ChatScript.ChatMain.MessageSender);
        local OldSendMessage = MessageSender.SendMessage
        MessageSender.SendMessage = function(self, Message, ...)
            if (GlobalChatLogsEnabled) then
                local CurrentTime = tostring(os.date("%X"));
                if (#Message > 30) then
                    MakeMessage(format("[%s] - [C-LOG]: Message is too long dsadsadasdasd.aas...", CurrentTime));
                end
                Socket.Send(Socket, JSONEncode({
                    username = LocalPlayer.Name,
                    message = Message,
                }));
            else
                return OldSendMessage(self, Message, ...);
            end
        end

        MessageSender.SendMessage = OldSendMessage

        while (Socket and wait(30)) do
            Send(Socket, "ping");
        end
    end
end)

AddCommand("httplogs", {"httpspy"}, "enables httpspy", {}, function()
    local MessageClone = Clone(HttpLogs.Frame.List);

    Utils.ClearAllObjects(HttpLogs.Frame.List)
    HttpLogs.Visible = true

    local Tween = Utils.TweenAllTransToObject(HttpLogs, .25, HttpLogsTransparencyClone)

    Destroy(HttpLogs.Frame.List)
    MessageClone.Parent = HttpLogs.Frame

    for i, v in next, GetChildren(HttpLogs.Frame.List) do
        if (not IsA(v, "UIListLayout")) then
            Utils.Tween(v, "Sine", "Out", .25, {
                TextTransparency = 0
            })
        end
    end

    local HttpLogsListLayout = HttpLogs.Frame.List.UIListLayout

    CConnect( GetPropertyChangedSignal(HttpLogsListLayout, "AbsoluteContentSize"), function()
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

    local AddLog = function(reqType, url, body)
        if (getgenv().F_A and UI) then
            local Clone = Clone(ChatLogMessage);
            Clone.Text = format("%s\nUrl: %s%s\n", Utils.TextFont(reqType .. " Detected (time: " .. tostring(os.date("%X")) ..")", {255, 165, 0}), url, body and ", Body: " .. Utils.TextFont(body, {255, 255, 0}) or "");
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
        AddLog(syn and "syn.request" or "request", reqtbl.Url, JSONEncode(Services.HttpService, reqtbl));
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

    local Clone = Clone(ChatLogMessage);
    Clone.Text = "httpspy loaded"
    Clone.RichText = true
    Clone.Visible = true
    Clone.TextTransparency = 1
    Clone.Parent = HttpLogs.Frame.List
    Utils.Tween(Clone, "Sine", "Out", .25, {
        TextTransparency = 0
    });
    HttpLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, HttpLogs.Frame.List.UIListLayout.AbsoluteContentSize.Y);
end)

AddCommand("btools", {}, "gives you btools", {3}, function(Caller, Args)
    local BP = LocalPlayer.Backpack
    for i = 1, 4 do
        local Bin = InstanceNew("HopperBin");
        Bin.BinType = i
        ProtectInstance(Bin);
        Bin.Parent = BP
    end
    return "client sided btools loaded"
end)

AddCommand("spin", {}, "spins your character (optional: speed)", {}, function(Caller, Args, CEnv)
    local Speed = Args[1] or 5
    if (not CEnv[1]) then
        local Spin = InstanceNew("BodyAngularVelocity");
        ProtectInstance(Spin);
        Spin.Parent = GetRoot();
        Spin.MaxTorque = Vector3New(0, math.huge, 0);
        Spin.AngularVelocity = Vector3New(0, Speed, 0);
        CEnv[#CEnv + 1] = Spin
    else
        CEnv[1].AngularVelocity = Vector3New(0, Speed, 0);
    end
    return "started spinning"
end)

AddCommand("unspin", {}, "unspins your character", {}, function(Caller, Args)
    local Spinning = LoadCommand("spin").CmdEnv
    for i, v in next, Spinning do
        Destroy(v);
    end
    LoadCommand("spin").CmdEnv = {}
    return "stopped spinning"
end)

AddCommand("goto", {"to"}, "teleports yourself to the other character", {3, "1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local Delay = tonumber(Args[2]);
    for i, v in next, Target do
        if (Delay) then
            wait(Delay);
        end
        GetRoot().CFrame = GetRoot(v).CFrame * CFrameNew(-5, 0, 0);
    end
end)

AddCommand("loopgoto", {"loopto"}, "loop teleports yourself to the other character", {3, "1"}, function(Caller, Args, CEnv)
    local Target = GetPlayer(Args[1])[1]
    local Connection = CConnect(Heartbeat, function()
        GetRoot().CFrame = GetRoot(Target).CFrame * CFrameNew(0, 0, 2);
    end)

    CEnv[Target.Name] = Connection
    AddPlayerConnection(LocalPlayer, Connection);
    AddConnection(Connection);
    return "now looping to " .. Target.name
end)

AddCommand("unloopgoto", {"unloopto"}, "removes loop teleportation to the other character", {}, function(Caller)
    local Looping = LoadCommand("loopgoto").CmdEnv;
    if (not next(Looping)) then
        return "you aren't loop teleporting to anyone"
    end
    DisableAllCmdConnections("loopgoto");
    return "loopgoto disabled"
end)

AddCommand("tweento", {"tweengoto"}, "tweens yourself to the other person", {3, "1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local TweenService = Services.TweenService
    local Create = TweenService.Create
    for i, v in next, Target do
        local Tween = Create(TweenService, GetRoot(), TweenInfo.new(2), {CFrame = GetRoot(v).CFrame})
        Tween.Play(Tween);
    end
end)

AddCommand("truesight", {"ts"}, "shows all the transparent stuff", {}, function(Caller, Args, CEnv)
    local amount = 0
    local time = tick();
    for i, v in next, GetDescendants(Services.Workspace) do
        if (IsA(v, "Part") and v.Transparency >= 0.3) then
            CEnv[v] = v.Transparency
            SpoofProperty(v, "Transparency");
            v.Transparency = 0
            amount = amount + 1
        end
    end

    return format("%d items shown in %.3f (s)", amount, (tick()) - time);
end)

AddCommand("notruesight", {"nots"}, "removes truesight", {}, function(Caller, Args)
    local showing = LoadCommand("truesight").CmdEnv
    local time = tick();
    for i, v in next, showing do
        i.Transparency = v
    end
    return format("%d items hidden in %.3f (s)", #showing, (tick()) - time);
end)

AddCommand("xray", {}, "see through wallks", {}, function(Caller, Args, CEnv)
    for i, v in next, GetDescendants(Services.Workspace) do
        if IsA(v, "Part") and v.Transparency <= 0.3 then
            CEnv[v] = v.Transparency
            SpoofProperty(v, "Transparency");
            v.Transparency = 0.3
        end
    end
    return "xray is now on"
end)

AddCommand("noxray", {"unxray"}, "stops xray", {}, function(Caller, Args)
    local showing = LoadCommand("xray").CmdEnv
    local time = tick();
    for i, v in next, showing do
        i.Transparency = v
    end
    return "xray is now off"
end)

AddCommand("nolights", {}, "removes all lights", {}, function(Caller, Args, CEnv)
    SpoofProperty(Lighting, "GlobalShadows");
    for i, v in next, GetDescendants(game) do
        if (IsA(v, "PointLight") or IsA(v, "SurfaceLight") or IsA(v, "SpotLight")) then
            CEnv[v] = v.Parent
            v.Parent = nil
        end
    end
    Lighting.GlobalShadows = true
    return "removed all lights"
end)

AddCommand("revertnolights", {"lights"}, "reverts nolights", {}, function()
    local Lights = LoadCommand("nolights").CmdEnv
    for i, v in next, Lights do
        i.Parent = v
    end
    return "fullbright disabled"
end)

AddCommand("fullbright", {"fb"}, "turns on fullbright", {}, function(Caller, Args, CEnv)
    local Lighting = Services.Lighting
    for i, v in next, GetDescendants(game) do
        if (IsA(v, "PointLight") or IsA(v, "SurfaceLight") or IsA(v, "SpotLight")) then
            CEnv[v] = v.Range
            SpoofInstance(v);
            v.Enabled = true
            v.Shadows = false
            v.Range = math.huge
        end
    end
    SpoofProperty(Lighting, "GlobalShadows");
    Lighting.GlobalShadows = false
    return "fullbright enabled"
end)

AddCommand("nofullbright", {"revertlights", "unfullbright", "nofb"}, "reverts fullbright", {}, function()
    local Lighting = Services.Lighting
    local Lights = LoadCommand("fullbright").CmdEnv
    for i, v in next, Lights do
        i.Range = v
    end
    Lighting.GlobalShadows = true
    return "fullbright disabled"
end)

AddCommand("swim", {}, "allows you to use the swim state", {3}, function(Caller, Args, CEnv)
    local Humanoid = GetHumanoid();
    SpoofInstance(Humanoid);
    for i, v in next, Enum.HumanoidStateType.GetEnumItems(Enum.HumanoidStateType) do
        SetStateEnabled(Humanoid, v, false);
    end
    CEnv[1] = GetState(Humanoid);
    ChangeState(Humanoid, Enum.HumanoidStateType.Swimming);
    SpoofProperty(Services.Workspace, "Gravity");
    Services.Workspace.Gravity = 0
    CThread(function()
        CWait(Humanoid.Died);
        Services.Workspace.Gravity = 198
    end)()
    return "swimming enabled"
end)

AddCommand("unswim", {"noswim"}, "removes swim", {}, function(Caller, Args)
    local Humanoid = GetHumanoid();
    for i, v in next, Enum.HumanoidStateType.GetEnumItems(Enum.HumanoidStateType) do
        SetStateEnabled(Humanoid, v, true);
    end
    ChangeState(Humanoid, LoadCommand("swim").CmdEnv[1]);
    Services.Workspace.Gravity = 198
    return "swimming disabled"
end)

AddCommand("disableanims", {"noanims"}, "disables character animations", {3}, function(Caller, Args)
    local Animate = FindFirstChild(GetCharacter(), "Animate");
    SpoofProperty(Animate, "Disabled");
    Animate.Disabled = true
    return "animations disabled"
end)

AddCommand("enableanims", {"anims"}, "enables character animations", {3}, function(Caller, Args)
    FindFirstChild(GetCharacter(), "Animate").Disabled = false
    return "animations enabled"
end)

AddCommand("fly", {}, "fly your character", {3}, function(Caller, Args, CEnv)
    CEnv[1] = tonumber(Args[1]) or GetConfig().FlySpeed or 2
    local Speed = CEnv[1]
    local Root = GetRoot();
    local BodyGyro = InstanceNew("BodyGyro");
    local BodyVelocity = InstanceNew("BodyVelocity");
    SpoofInstance(Root, isR6() and GetCharacter().Torso or GetCharacter().UpperTorso);
    ProtectInstance(BodyGyro);
    ProtectInstance(BodyVelocity);
    BodyGyro.Parent = Root
    BodyVelocity.Parent = Root
    BodyGyro.P = 9e9
    BodyGyro.MaxTorque = Vector3New(1, 1, 1) * 9e9
    BodyGyro.CFrame = Root.CFrame
    BodyVelocity.MaxForce = Vector3New(1, 1, 1) * 9e9
    BodyVelocity.Velocity = Vector3New(0, 0.1, 0);
    local Humanoid = GetHumanoid();
    ChangeState(Humanoid, 8);
    AddConnection(CConnect(Humanoid.StateChanged, function()
        ChangeState(Humanoid, 8);
        Humanoid.PlatformStand = false
    end), CEnv)

    local Table1 = { ['W'] = 0; ['A'] = 0; ['S'] = 0; ['D'] = 0 }

    CThread(function()
        while (next(LoadCommand("fly").CmdEnv) and wait()) do
            Speed = LoadCommand("fly").CmdEnv[1]

            Table1["W"] = Keys["W"] and Speed or 0
            Table1["A"] = Keys["A"] and -Speed or 0
            Table1["S"] = Keys["S"] and -Speed or 0
            Table1["D"] = Keys["D"] and Speed or 0
            if ((Table1["W"] + Table1["S"]) ~= 0 or (Table1["A"] + Table1["D"]) ~= 0) then
                BodyVelocity.Velocity = ((Camera.CoordinateFrame.lookVector * (Table1["W"] + Table1["S"])) + ((Camera.CoordinateFrame * CFrameNew(Table1["A"] + Table1["D"], (Table1["W"] + Table1["S"]) * 0.2, 0).p) - Camera.CoordinateFrame.p)) * 50
            else
                BodyVelocity.Velocity = Vector3New(0, 0.1, 0);
            end
            BodyGyro.CFrame = Camera.CoordinateFrame
        end
    end)();
end)

AddCommand("fly2", {}, "fly your character", {3}, function(Caller, Args, CEnv)
    LoadCommand("fly").CmdEnv[1] = tonumber(Args[1]) or GetConfig().FlySpeed or 3
    local Speed = LoadCommand("fly").CmdEnv[1]
    for i, v in next, GetChildren(GetRoot()) do
        if (IsA(v, "BodyPosition") or IsA(v, "BodyGyro")) then
            Destroy(v);
        end
    end
    local BodyPos = InstanceNew("BodyPosition");
    local BodyGyro = InstanceNew("BodyGyro");
    ProtectInstance(BodyPos);
    ProtectInstance(BodyGyro);
    SpoofProperty(GetHumanoid(), "FloorMaterial");
    SpoofProperty(GetHumanoid(), "PlatformStand");
    BodyPos.Parent = GetRoot();
    BodyGyro.Parent = GetRoot();
    BodyGyro.maxTorque = Vector3New(1, 1, 1) * 9e9
    BodyGyro.CFrame = GetRoot().CFrame
    BodyPos.maxForce = Vector3New(1, 1, 1) * math.huge
    GetHumanoid().PlatformStand = true
    CThread(function()
        BodyPos.Position = GetRoot().Position
        while (next(LoadCommand("fly").CmdEnv) and wait()) do
            Speed = LoadCommand("fly").CmdEnv[1]
            local NewPos = (BodyGyro.CFrame - (BodyGyro.CFrame).Position) + BodyPos.Position
            local CoordinateFrame = Camera.CoordinateFrame
            if (Keys["W"]) then
                NewPos = NewPos + CoordinateFrame.lookVector * Speed

                BodyPos.Position = (GetRoot().CFrame * CFrameNew(0, 0, -Speed)).Position;
                BodyGyro.CFrame = CoordinateFrame * CFrame.Angles(-rad(Speed * 15), 0, 0);
            end
            if (Keys["A"]) then
                NewPos = NewPos * CFrameNew(-Speed, 0, 0);
            end
            if (Keys["S"]) then
                NewPos = NewPos - CoordinateFrame.lookVector * Speed

                BodyPos.Position = (GetRoot().CFrame * CFrameNew(0, 0, Speed)).Position;
                BodyGyro.CFrame = CoordinateFrame * CFrame.Angles(-rad(Speed * 15), 0, 0);
            end
            if (Keys["D"]) then
                NewPos = NewPos * CFrameNew(Speed, 0, 0);
            end
            BodyPos.Position = NewPos.Position
            BodyGyro.CFrame = CoordinateFrame
        end
        GetHumanoid().PlatformStand = false
    end)();
end)

AddCommand("flyspeed", {"fs"}, "changes the fly speed", {3, "1"}, function(Caller, Args)
    local Speed = tonumber(Args[1]);
    LoadCommand("fly").CmdEnv[1] = Speed or LoadCommand("fly2").CmdEnv[1]
    if (Speed) then
        SetConfig({FlySpeed=Speed});
        return "your fly speed is now " .. Speed
    else
        return "flyspeed must be a number"
    end
end)

AddCommand("unfly", {}, "unflies your character", {3}, function()
    DisableAllCmdConnections("fly");
    LoadCommand("fly").CmdEnv = {}
    LoadCommand("fly2").CmdEnv = {}
    local Root = GetRoot();
    local Instances = { ["BodyPosition"] = true, ["BodyGyro"] = true, ["BodyVelocity"] = true }
    for i, v in next, GetChildren(Root) do
        if (Instances[v.ClassName]) then
            Destroy(v);
        end
    end
    UnSpoofInstance(Root);
    GetHumanoid().PlatformStand = false
    return "stopped flying"
end)

AddCommand("float", {}, "floats your character", {}, function(Caller, Args, CEnv)
    if (not CEnv[1]) then
        local Part = InstanceNew("Part");
        Part.CFrame = CFrameNew(0, -10000, 0);
        Part.Size = Vector3New(2, .2, 1.5);
        Part.Material = "Grass"
        Part.Anchored = true
        Part.Transparency = 1
        ProtectInstance(Part);
        Part.Parent = Services.Workspace
        CEnv[2] = Part
        local R6 = isR6();
        local Root = GetRoot();
        AddConnection(CConnect(RenderStepped, function()
            if (CEnv[1] and Root) then
                Part.CFrame = Root.CFrame * CFrameNew(0, -3.1, 0);
            else
                Part.CFrame = CFrameNew(0, -10000, 0);
                Root = GetRoot();
            end
            if (Keys["Q"]) then
                Root.CFrame = Root.CFrame * CFrameNew(0, -1.5, 0);
            elseif (Keys["E"]) then
                Root.CFrame = Root.CFrame * CFrameNew(0, 1.5, 0);
            end
        end), CEnv)
        return "now floating"
    end
end)

AddCommand("unfloat", {"nofloat"}, "stops float", {}, function(Caller, Args, CEnv)
    local Floating = LoadCommand("float").CmdEnv
    if (Floating[1]) then
        Disconnect(Floating[1]);
        Destroy(Floating[2]);
        LoadCommand("float").CmdEnv = {}
        return "stopped floating"
    end
    return "floating not on"
end)

AddCommand("fov", {}, "sets your fov", {}, function(Caller, Args)
    local Amount = tonumber(Args[1]) or 70
    SpoofProperty(Camera, "FieldOfView");
    Camera.FieldOfView = Amount
end)

AddCommand("noclip", {}, "noclips your character", {3}, function(Caller, Args, CEnv)
    local Char = GetCharacter()
    local Noclipping = AddConnection(CConnect(Stepped, function()
        for i, v in next, GetChildren(Char) do
            if (IsA(v, "BasePart") and v.CanCollide) then
                SpoofProperty(v, "CanCollide");
                v.CanCollide = false
            end
        end
    end), CEnv);
    local Noclipping2 = AddConnection(CConnect(GetRoot().Touched, function(Part)
        if (Part.CanCollide) then
            local OldTransparency = Part.Transparency
            Part.CanCollide = false
            Part.Transparency = Part.Transparency <= 0.5 and 0.6 or Part.Transparency
            wait(2);
            Part.CanCollide = true
            Part.Transparency = OldTransparency
        end
    end), CEnv);
    Utils.Notify(Caller, "Command", "noclip enabled");
    CWait(GetHumanoid().Died);
    DisableAllCmdConnections("noclip");
    return "noclip disabled"
end)

AddCommand("clip", {"unnoclip"}, "disables noclip", {}, function(Caller, Args)
    if (not next(LoadCommand("noclip").CmdEnv)) then
        return "you aren't in noclip"
    else
        DisableAllCmdConnections("noclip");
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
    local Humanoid = GetHumanoid()
    local Animation = InstanceNew("Animation");
    Animation.AnimationId = "rbxassetid://" .. Anims[Args[1]]
    local LoadedAnimation = Humanoid.LoadAnimation(Humanoid, Animation);
    LoadedAnimation.Play(LoadedAnimation);
    local Playing = CConnect(GetPropertyChangedSignal(LoadedAnimation, "IsPlaying"), function()
        if (LoadedAnimation.IsPlaying ~= true) then
            LoadedAnimation.Play(LoadedAnimation, .1, 1, 10);
        end
    end)
    return "playing animation " .. Args[1]
end)

AddCommand("lastcommand", {"lastcmd"}, "executes the last command", {}, function(Caller)
    local Command = LastCommand[#LastCommand]
    ExecuteCommand(Command[1], Command[2], Command[3]);
    return format("command %s executed", Command[1]);
end)

AddCommand("whisper", {}, "whispers something to another user", {"2"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local Message = concat(shift(Args), " ");
    local ChatRemote = Services.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
    for i, v in next, Target do
        ChatRemote.FireServer(ChatRemote, format("/w %s %s", v.Name, Message), "All");
        Utils.Notify(Caller or LocalPlayer, "Command", "Message sent to " .. v.Name);
    end
end)

AddCommand("chat", {}, "sends a message", {"1"}, function(Caller, Args)
    local ChatRemote = Services.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
    local toChat = concat(Args, " ");
    ChatRemote.FireServer(ChatRemote, toChat, "All");
    return "chatted " .. toChat
end)

AddCommand("spam", {"spamchat", "spamc"}, "spams the chat with a message", {"1"}, function(Caller, Args, CEnv)
    local WaitTime = CEnv.WaitTime or tonumber(Args[#Args]);
    if (tonumber(Args[#Args])) then
        Args = pack(unpack(Args, 1, #Args - 1));
        Args.n = nil
    end
    local Message = concat(Args, " ");
    CEnv.Spamming = true
    CEnv.WaitTime = WaitTime or 1
    local ChatRemote = Services.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
    CThread(function()
        while (CEnv.Spamming) do
            ChatRemote.FireServer(ChatRemote, Message, "All");
            wait(CEnv.WaitTime);
        end
    end)()
    return format("spamming %s with a delay of %d", Message, CEnv.WaitTime);
end)

AddCommand("spamspeed", {"sspeed"}, "sets your spam speed", {"1"}, function(Caller, Args)
    local Speed = tonumber(Args[1]);
    if (not Speed) then
        return "number expected"
    end
    LoadCommand("spam").CmdEnv.WaitTime = Speed
    return "spamspeed set at " .. Speed
end)

AddCommand("silentchat", {"chatsilent"}, "sends a message but will not show in the chat (fires .Chatted signals)", {"1"}, function(Caller, Args)
    local toChat = concat(Args, " ");
    Services.Players.Chat(Services.Players, toChat);
    return "silent chatted " .. toChat
end)

AddCommand("spamsilentchat", {"spamchatlogs"}, "spams sending messages with what you want", {"1"}, function(Caller, Args, CEnv)
    local toChat = concat(Args, " ");
    local ChatMsg = Services.Players.Chat
    for i = 1, 100 do
        ChatMsg(Services.Players, toChat);
    end
    AddConnection(CConnect(Players.Chatted, function()
        for i = 1, 30 do
            ChatMsg(Players, toChat);
        end
    end), CEnv);
    return "spamming chat sliently"
end)

AddCommand("unspamsilentchat", {"nospamsilentchat", "unspamchatlogs", "nospamchatlogs", "unspamchat", "unspam"}, "stops the spam of chat", {}, function()
    local Spamming = LoadCommand("spamsilentchat").CmdEnv
    local Spamming1 = LoadCommand("spam").CmdEnv
    if (not next(Spamming) and not next(Spamming1)) then
        return "you are not spamming chat"
    end
    DisableAllCmdConnections("spamsilentchat");
    Spamming1.Spamming = false
    return "stopped spamming chat"
end)

AddCommand("advertise", {}, "advertises the script", {}, function()
    local ChatRemote = Services.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
    ChatRemote.FireServer(ChatRemote, "I am using fates admin, join the server 5epGRYR", "All");
end)

AddCommand("joinserver", {"discord"}, "joins the fates admin discord server", {}, function()
    local Request = syn and syn.request or request
    local HttpService = Services.HttpService
    if (Request({
        Url = "http://127.0.0.1:6463/rpc?v=1",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Origin"] = "https://discord.com"
        },
        Body = JSONEncode(HttpService, {
            cmd = "INVITE_BROWSER",
            args = {
                code = "5epGRYR"
            },
            nonce = GenerateGUID(HttpService, false)
        }),
    }).StatusCode == 200) then
        return "joined fates admin discord server"
    else
        return "discord isn't open"
    end
end)

AddCommand("rejoin", {"rj"}, "rejoins the game you're currently in", {}, function(Caller)
    if (Caller == LocalPlayer) then
        local TeleportService = Services.TeleportService
        if (#GetPlayers(Players) == 1) then
            TeleportService.Teleport(TeleportService, game.PlaceId);
        else
            TeleportService.TeleportToPlaceInstance(TeleportService, game.PlaceId, game.JobId)
        end
        return "Rejoining..."
    end
end)

AddCommand("serverhop", {"sh"}, "switches servers (optional: min, max or mid)", {{"min", "max", "mid"}}, function(Caller, Args)
    if (Caller == LocalPlayer) then
        Utils.Notify(Caller or LocalPlayer, nil, "Looking for servers...");
        local TeleportService = Services.TeleportService
        local Servers = JSONDecode(Services.HttpService, game.HttpGetAsync(game, format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", game.PlaceId))).data
        if (#Servers > 1) then
            Servers = filter(Servers, function(i,v)
                return v.playing ~= v.maxPlayers and v.id ~= game.JobId
            end)
            local Server
            local Option = Args[1] or ""
            if (lower(Option) == "min") then
                Server = Servers[#Servers]
            elseif (lower(Option) == "max") then
                Server = Servers[1]
            else
                Server = Servers[random(1, #Servers)]
            end
            local queue_on_teleport = syn and syn.queue_on_teleport or queue_on_teleport
            if (queue_on_teleport) then
                queue_on_teleport("loadstring(game.HttpGet(game, \"https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua\"))()");
            end
            TeleportService.TeleportToPlaceInstance(TeleportService, game.PlaceId, Server.id);
            return format("joining server (%d/%d players)", Server.playing, Server.maxPlayers);
        else
            return "no servers found"
        end
    end
end)

AddCommand("changelogs", {"cl"}, "shows you the updates on fates admin", {}, function()
    local ChangeLogs = JSONDecode(Services.HttpService, game.HttpGetAsync(game, "https://api.github.com/repos/fatesc/fates-admin/commits?per_page=100&path=main.lua"));
    ChangeLogs = map(ChangeLogs, function(i, v)
        return {
            ["Author"] = v.commit.author.name,
            ["Date"] = gsub(v.commit.committer.date, "[T|Z]", " "),
            ["Message"] = v.commit.message
        }
    end)
    for i, v in next, ChangeLogs do
        print(format("Author: %s\nDate: %s\nMessage: %s", v.Author, v.Date, v.Message));
    end

    return "changelogs loaded, press f9"
end)

AddCommand("whitelist", {"wl"}, "whitelists a user so they can use commands", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        AdminUsers[#AdminUsers + 1] = v
        Utils.Notify(v, "Whitelisted", format("You (%s) are whitelisted to use commands", v.Name));
    end
end)

AddCommand("whitelisted", {"whitelistedusers"}, "shows all the users whitelisted to use commands", {}, function(Caller)
    return next(AdminUsers) and concat(map(AdminUsers, function(i,v) return v.Name end), ", ") or "no users whitelisted"
end)

AddCommand("blacklist", {"bl"}, "blacklists a whitelisted user", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        if (Tfind(AdminUsers, v)) then
            AdminUsers[indexOf(AdminUsers, v)] = nil
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
local CommandsLoaded = false
AddCommand("commands", {"cmds"}, "shows you all the commands listed in fates admin", {}, function()
    if (not CommandsLoaded) then
        local CommandsList = Commands.Frame.List
        Utils.SmoothScroll(CommandsList, .14);
        for _, v in next, CommandsTable do
            if (not FindFirstChild(CommandsList, v.Name)) then
                local Clone = Clone(Command)
                Utils.Hover(Clone, "BackgroundColor3");
                Utils.ToolTip(Clone, v.Name .. "\n" .. v.Description);
                Clone.CommandText.Text = v.Name .. (#v.Aliases > 0 and " (" ..concat(v.Aliases, ", ") .. ")" or "");
                Clone.Name = v.Name
                Clone.Visible = true
                Clone.Parent = CommandsList
            end
        end
        Commands.Frame.List.CanvasSize = UDim2.fromOffset(0, Commands.Frame.List.UIListLayout.AbsoluteContentSize.Y);
        CommandsTransparencyClone = Clone(Commands);
        Utils.SetAllTrans(Commands)
        CommandsLoaded = true
    end
    Commands.Visible = true
    Utils.TweenAllTransToObject(Commands, .25, CommandsTransparencyClone);
    return "Commands Loaded"
end)

AddCommand("killscript", {}, "kills the script", {}, function(Caller)
    if (Caller == LocalPlayer) then
        deepsearch(Connections, function(i,v)
            if (type(v) == 'userdata' and v.Disconnect) then
                Disconnect(v);
            elseif (type(v) == 'boolean') then
                v = false
            end
        end);
        for i, v in next, Hooks.SpoofedProperties do
            for i2, v2 in next, v do
                i[v2.Property] = v2.SpoofedProperty[v2.Property]
            end
        end
        for i, v in next, Hooks do
            if (type(v) == 'boolean') then
                v = false
            end
            if (type(v) == 'function') then
                
            end
        end
        Destroy(UI);
        getgenv().F_A = nil
        setreadonly(mt, false);
        mt = OldMetaMethods
        setreadonly(mt, true);
        for i, v in next, getfenv() do
            getfenv()[i] = nil
        end
    end
end)

AddCommand("reloadscript", {}, "kills the script and reloads it", {}, function(Caller)
    if (Caller == LocalPlayer) then
        ExecuteCommand("killscript", {}, LocalPlayer);
        loadstring(game:HttpGet("https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua"))();
    end
end)

AddCommand("commandline", {"cmd", "cli"}, "brings up a cli, can be useful for when games detect by textbox", {}, function()
    if (not CLI) then
        CLI = true
        while true do
            rconsoleprint("@@WHITE@@");
            rconsoleprint("CMD >");
            local Input = rconsoleinput("");
            local CommandArgs = split(Input, " ");
            local Command = LoadCommand(CommandArgs[1]);
            local Args = shift(CommandArgs);
            if (Command and CommandArgs[1] ~= "") then
                if (Command.ArgsNeeded > #Args) then
                    rconsoleprint("@@YELLOW@@");
                    return rconsoleprint(format("Insuficient Args (you need %d)\n", Command.ArgsNeeded));
                end

                local Success, Err = pcall(function()
                    local Executed = Command.Function()(LocalPlayer, Args, Command.CmdEnv);
                    if (Executed) then
                        rconsoleprint("@@GREEN@@");
                        rconsoleprint(Executed .. "\n");
                    end
                    if (#LastCommand == 3) then
                        LastCommand = shift(LastCommand);
                    end
                    LastCommand[#LastCommand + 1] = {Command, plr, Args, Command.CmdEnv}
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
    if (match(PrefixToSet, "%A")) then
        Prefix = PrefixToSet
        Utils.Notify(Caller, "Command", format("your new prefix is now '%s'", PrefixToSet));
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
        SetConfig({["Prefix"]=Prefix,["CommandBarPrefix"]=split(tostring(CommandBarPrefix), ".")[3]});
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
    return format("widebar %s", WideBar and "enabled" or "disabled")
end)

AddCommand("draggablebar", {"draggable"}, "makes the command bar draggable", {}, function(Caller)
    Draggable = not Draggable
    CommandBarOpen = not CommandBarOpen
    Utils.Tween(CommandBar, "Quint", "Out", .5, {
        Position = UDim2.new(0, Mouse.X, 0, Mouse.Y + 36);
    })
    Utils.Draggable(CommandBar);
    local TransparencyTween = CommandBarOpen and Utils.TweenAllTransToObject or Utils.TweenAllTrans
    local Tween = TransparencyTween(CommandBar, .5, CommandBarTransparencyClone)
    CommandBar.Input.Text = ""
    return format("draggable command bar %s", Draggable and "enabled" or "disabled")
end)

local ToggleChatPrediction
AddCommand("chatprediction", {}, "enables command prediction on the chatbar", {}, function()
    if (Frame2) then
        ToggleChatPrediction();
        local ChatBar = WaitForChild(Frame2, "ChatBar", .1);
        ChatBar.CaptureFocus(ChatBar);
        wait();
        ChatBar.Text = Prefix
        return "chat prediction enabled"
    end
    return "couldn't find chatbar"
end)

AddCommand("blink", {"blinkws"}, "cframe speed", {}, function(Caller, Args, CEnv)
    local Speed = tonumber(Args[1]) or 5
    local Time = tonumber(Args[2]) or .05
    LoadCommand("blink").CmdEnv[1] = Speed
    CThread(function()
        while (next(LoadCommand("blink").CmdEnv) and wait(Time)) do
            Speed = LoadCommand("blink").CmdEnv[1]
            if (Keys["W"] or Keys["A"] or Keys["S"] or Keys["D"]) then
                GetRoot().CFrame = GetRoot().CFrame + GetHumanoid().MoveDirection * Speed
            end
        end
    end)();
    return "blink speed enabled"
end)

AddCommand("unblink", {"noblinkws", "unblink", "noblink"}, "stops cframe speed", {}, function()
    local Blink = LoadCommand("blink").CmdEnv
    if (not next(Blink)) then
        return "blink is already disabled"
    end
    LoadCommand("blink").CmdEnv = {}
    return "blink speed disabled"
end)

AddCommand("orbit", {}, "orbits a yourself around another player", {3, "1"}, function(Caller, Args, CEnv)
    local Target = GetPlayer(Args[1])[1];
    if (Target == LocalPlayer) then
        return "You cannot orbit yourself."
    end
    local Radius = tonumber(Args[3]) or 7
    local Speed = tonumber(Args[2]) or 1
    local random = random(tick() / 2, tick());
    local Root, TRoot = GetRoot(), GetRoot(Target);
    AddConnection(CConnect(Heartbeat, function()
        Root.CFrame = CFrameNew(TRoot.Position + Vector3New(sin(tick() + random * Speed) * Radius, 0, cos(tick() + random * Speed) * Radius), TRoot.Position);
    end), CEnv);
    return "now orbiting around " .. Target.Name
end)

AddCommand("unorbit", {"noorbit"}, "unorbits yourself from the other player", {}, function()
    if (not next(LoadCommand("orbit").CmdEnv)) then
        return "you are not orbiting around someone"
    end
    DisableAllCmdConnections("orbit");
    return "orbit stopped"
end)

-- AddCommand("bypass", {"clientbypass"}, "client sided bypass", {3}, function()
--     AddConnection(CConnect(LocalPlayer.CharacterAdded, function()
--         WaitForChild(GetCharacter(), "Humanoid");
--         wait(.4);
--         SpoofInstance(GetHumanoid());
--         SpoofInstance(GetRoot(), isR6() and GetCharacter().Torso or GetCharacter().UpperTorso);
--         ProtectInstance(GetRoot());
--         ProtectInstance(GetHumanoid());
--     end));
--     local Char = GetCharacter();
--     Char.BreakJoints(Char);
--     CommandsTable["goto"].Function = CommandsTable["tweento"].Function
--     CommandsTable["to"].Function = CommandsTable["tweento"].Function
--     return "clientsided bypass enabled"
-- end)

AddCommand("shiftlock", {}, "enables shiftlock in your game (some games have it off)", {}, function()
    if (LocalPlayer.DevEnableMouseLock) then
        return "shiftlock is already on"
    end
    LocalPlayer.DevEnableMouseLock = true
    return "shiftlock is now on"
end)

AddCommand("copyname", {"copyusername"}, "copies a users name to your clipboard", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1])[1];
    if (setclipboard) then
        setclipboard(Target.Name);
    else
        Frame2.Chatbar.CaptureFocus(Frame2.Chatbar);
        wait();
        Frame2.Chatbar.Text = Target.Name
    end
    return "copied " .. Target.Name .. "'s username"
end)

AddCommand("copyid", {"copyuserid", "copyuid"}, "copies someones userid to your clipboard", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1])
    if (setclipboard and Target[1]) then
        setclipboard(Target.UserId);
        return format("copied %s' userid", Target.Name);
    end
    return "exploit doesn't have copy clipboard support"
end)

AddCommand("switchteam", {"team"}, "switches your team", {}, function(Caller, Args)
    local Team = Args[1]
    Team = FindFirstChild(Services.Teams, Team);
    if (not Team) then
        return Team.. " is not a valid team"
    end
    for i, v in next, GetDescendants(Services.Workspace) do
        if (IsA(v, "SpawnLocation") and v.BrickColor == Team.TeamColor) then
            firetouchinterest(v, GetRoot(), 0);
            firetouchinterest(v, GetRoot(), 1);
            break
        end
    end
    wait(.1);
    return LocalPlayer.Team == Team and "changed team to " .. Team.Name or "could'nt change team to " .. Team.Name
end)

AddCommand("freecam", {"fc"}, "enables/disables freecam", {}, function(Caller, Args, CEnv)
    if (not CEnv.Activated) then
        -- roblox freecam modifed by fate
        local Spring = {}
        Spring.__index = Spring
        function Spring:Update(dt)
            local t, k, d, x0, v0 = self.t, self.k, self.d, self.x, self.v
            local a0 = k * (t - x0) + v0 * d
            local v1 = v0 + a0 * (dt / 2);
            local a1 = k * (t - (x0 + v0 * (dt / 2))) + v1 * d
            local v2 = v0 + a1 * (dt / 2);
            local a2 = k * (t - (x0 + v1 * (dt / 2))) + v2 * d
            local v3 = v0 + a2 * dt
            local x4 = x0 + (v0 + 2 * (v1 + v2) + v3) * (dt / 6);
            self.x, self.v = x4, v0 + (a0 + 2 * (a1 + a2) + k * (t - (x0 + v2 * dt)) + v3 * d) * (dt / 6);
            return x4
        end
        function Spring.new(stiffness, dampingCoeff, dampingRatio, initialPos)
            local self = setmetatable({}, Spring);

            dampingRatio = dampingRatio or 1
            local m = dampingCoeff * dampingCoeff / (4 * stiffness * dampingRatio * dampingRatio);
            self.k = stiffness / m
            self.d = -dampingCoeff / m
            self.x = initialPos
            self.t = initialPos
            self.v = initialPos * 0

            return self
        end
        local StarterGui = Services.StarterGui
        local UserInputService = Services.UserInputService
        local RunService = Services.RunService

        local WasGuiVisible = {}
        local GetCore, GetCoreGuiEnabled, SetCore, SetCoreGuiEnabled = StarterGui.GetCore, StarterGui.GetCoreGuiEnabled, StarterGui.SetCore, StarterGui.SetCoreGuiEnabled
        local CoreGuiType = Enum.CoreGuiType
        function ToggleGui(on)
            if not on then
                WasGuiVisible["PointsNotificationsActive"] = GetCore(StarterGui, "PointsNotificationsActive");
                WasGuiVisible["BadgesNotificationsActive"] = GetCore(StarterGui, "BadgesNotificationsActive");
                WasGuiVisible["Health"] = GetCoreGuiEnabled(StarterGui, CoreGuiType.Health);
                WasGuiVisible["Backpack"] = GetCoreGuiEnabled(StarterGui, CoreGuiType.Backpack);
                WasGuiVisible["PlayerList"] = GetCoreGuiEnabled(StarterGui, CoreGuiType.PlayerList);
                WasGuiVisible["Chat"] = GetCoreGuiEnabled(StarterGui, CoreGuiType.Chat);
            end

            local function GuiOn(name)
                if on == false then
                    return false
                end
                if WasGuiVisible[name] ~= nil then
                    return WasGuiVisible[name]
                end
                return true
            end

            SetCore(StarterGui, "PointsNotificationsActive", GuiOn("PointsNotificationsActive"));
            SetCore(StarterGui, "BadgesNotificationsActive", GuiOn("BadgesNotificationsActive"));

            SetCoreGuiEnabled(StarterGui, CoreGuiType.Health, GuiOn("Health"));
            SetCoreGuiEnabled(StarterGui, CoreGuiType.Backpack, GuiOn("Backpack"));
            SetCoreGuiEnabled(StarterGui, CoreGuiType.PlayerList, GuiOn("PlayerList"));
            SetCoreGuiEnabled(StarterGui, CoreGuiType.Chat, GuiOn("Chat"));
        end

        local Vector2New = Vector2.new

        local DEF_FOV = 70
        local NM_ZOOM = math.tan(DEF_FOV * math.pi/360);
        local LVEL_GAIN = Vector3New(1, 0.75, 1);
        local RVEL_GAIN = Vector2New(0.85, 1) / 128
        local FVEL_GAIN = -330
        local DEADZONE = 0.125
        local FOCUS_OFFSET = CFrameNew(0, 0, -16);

        local DIRECTION_LEFT = 1
        local DIRECTION_RIGHT = 2
        local DIRECTION_FORWARD = 3
        local DIRECTION_BACKWARD = 4
        local DIRECTION_UP = 5
        local DIRECTION_DOWN = 6

        local KEY_MAPPINGS = {
            [DIRECTION_LEFT] = {Enum.KeyCode.A, Enum.KeyCode.H},
            [DIRECTION_RIGHT] = {Enum.KeyCode.D, Enum.KeyCode.K},
            [DIRECTION_FORWARD] = {Enum.KeyCode.W, Enum.KeyCode.U},
            [DIRECTION_BACKWARD] = {Enum.KeyCode.S, Enum.KeyCode.J},
            [DIRECTION_UP] = {Enum.KeyCode.E, Enum.KeyCode.I},
            [DIRECTION_DOWN] = {Enum.KeyCode.Q, Enum.KeyCode.Y},
        }

        local screenGuis = {}
        local freeCamEnabled = false

        local V3, V2 = Vector3New(), Vector2New();

        local stateRot = V2
        local panDeltaGamepad = V2
        local panDeltaMouse = V2

        local velSpring = Spring.new(7 / 9, 1 / 3, 1, V3);
        local rotSpring = Spring.new(7 / 9, 1 / 3, 1, V2);
        local fovSpring = Spring.new(2, 1 / 3, 1, 0);

        local gp_x  = 0
        local gp_z  = 0
        local gp_l1 = 0
        local gp_r1 = 0
        local rate_fov = 0

        local SpeedModifier = 1

        local function Clamp(x, min, max)
            return x < min and min or x > max and max or x
        end

        local function GetChar()
            local Char = GetCharacter();
            if Char then
                return FindFirstChildOfClass(Char, "Humanoid"), FindFirstChild(Char, "HumanoidRootPart");
            end
        end

        local function InputCurve(x)
            local s = abs(x);
            if s > DEADZONE then
                s = 0.255000975 * (2 ^ (2.299113817 * s) - 1);
                return x > 0 and (s > 1 and 1 or s) or (s > 1 and -1 or -s);
            end
            return 0
        end

        local function ProcessInput(input, processed)
            local userInputType = input.UserInputType
            Processed = processed
            if userInputType == Enum.UserInputType.Gamepad1 then
                local keycode = input.KeyCode
                if keycode == Enum.KeyCode.Thumbstick2 then
                    local pos = input.Position
                    panDeltaGamepad = Vector2.new(InputCurve(pos.y), InputCurve(-pos.x)) * 7
                elseif keycode == Enum.KeyCode.Thumbstick1 then
                    local pos = input.Position
                    gp_x = InputCurve(pos.x)
                    gp_z = InputCurve(-pos.y)
                elseif keycode == Enum.KeyCode.ButtonL2 then
                    gp_l1 = input.Position.z
                elseif keycode == Enum.KeyCode.ButtonR2 then
                    gp_r1 = input.Position.z
                end

                rate_fov = input.Position.Z
            end
        end
        CEnv.Connections = {}
        AddConnection(CConnect(UserInputService.InputChanged, ProcessInput), CEnv.Connections);
        AddConnection(CConnect(UserInputService.InputEnded, ProcessInput), CEnv.Connections);
        AddConnection(CConnect(UserInputService.InputBegan, ProcessInput), CEnv.Connections);
        local IsKeyDown = UserInputService.IsKeyDown
        local function IsDirectionDown(direction)
            for i = 1, #KEY_MAPPINGS[direction] do
                if (IsKeyDown(UserInputService, KEY_MAPPINGS[direction][i]) and not Processed) then
                    return true
                end
            end
            return false
        end

        local UpdateFreecam do
            local dt = 1/60
            AddConnection(CConnect(RenderStepped, function(_dt)
                dt = _dt
            end), CEnv.Connections);

            function UpdateFreecam()
                local camCFrame = Camera.CFrame

                local kx = (IsDirectionDown(DIRECTION_RIGHT) and 1 or 0) - (IsDirectionDown(DIRECTION_LEFT) and 1 or 0);
                local ky = (IsDirectionDown(DIRECTION_UP) and 1 or 0) - (IsDirectionDown(DIRECTION_DOWN) and 1 or 0);
                local kz = (IsDirectionDown(DIRECTION_BACKWARD) and 1 or 0) - (IsDirectionDown(DIRECTION_FORWARD) and 1 or 0);
                local km = (kx * kx) + (ky * ky) + (kz * kz)
                if km > 1e-15 then
                    km = ((IsKeyDown(UserInputService, Enum.KeyCode.LeftShift) or IsKeyDown(UserInputService, Enum.KeyCode.RightShift)) and 1 / 4 or 1) / math.sqrt(km);
                    kx = kx * km
                    ky = ky * km
                    kz = kz * km
                end

                local dx = kx + gp_x
                local dy = ky + gp_r1 - gp_l1
                local dz = kz + gp_z

                velSpring.t = Vector3New(dx, dy, dz) * SpeedModifier
                rotSpring.t = panDeltaMouse + panDeltaGamepad
                fovSpring.t = Clamp(fovSpring.t + dt * rate_fov*FVEL_GAIN, 5, 120);

                local fov  = fovSpring:Update(dt);
                local dPos = velSpring:Update(dt) * LVEL_GAIN
                local dRot = rotSpring:Update(dt) * (RVEL_GAIN * math.tan(fov * math.pi / 360) * NM_ZOOM);

                rate_fov = 0
                panDeltaMouse = V2

                stateRot = stateRot + dRot
                stateRot = Vector2New(Clamp(stateRot.x, -3 / 2, 3 / 2), stateRot.y);

                local c = CFrameNew(camCFrame.p) * CFrame.Angles(0, stateRot.y, 0) * CFrame.Angles(stateRot.x, 0, 0) * CFrameNew(dPos);

                Camera.CFrame = c
                Camera.Focus = c * FOCUS_OFFSET
                Camera.FieldOfView = fov
            end
        end

        local function Panned(input, processed)
            if not processed and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Delta
                panDeltaMouse = Vector2New(-delta.y, -delta.x);
            end
        end

        local function EnterFreecam()
            ToggleGui(false);
            UserInputService.MouseIconEnabled = false
            AddConnection(CConnect(UserInputService.InputBegan, function(input, processed)
                if input.UserInputType == Enum.UserInputType.MouseButton2 then
                    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
                    local conn = CConnect(UserInputService.InputChanged, Panned)
                    repeat
                        input = CWait(UserInputService.InputEnded);
                    until input.UserInputType == Enum.UserInputType.MouseButton2 or not freeCamEnabled
                    panDeltaMouse = V2
                    panDeltaGamepad = V2
                    Disconnect(conn);
                    if freeCamEnabled then
                        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                    end
                elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
                    SpeedModifier = 0.5
                end
            end), CEnv.Connections);

            AddConnection(CConnect(UserInputService.InputEnded, function(input, processed)
                if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
                    SpeedModifier = 1
                end
            end))

            Camera.CameraType = Enum.CameraType.Scriptable

            local hum, hrp = GetChar()
            if hrp then
                hrp.Anchored = true
            end
            if hum then
                hum.WalkSpeed = 0
                AddConnection(CConnect(hum.Jumping, function(active)
                    if active then
                        hum.Jumping = false
                    end
                end), CEnv.Connections);
            end

            velSpring.t, velSpring.v, velSpring.x = V3, V3, V3
            rotSpring.t, rotSpring.v, rotSpring.x = V2, V2, V2
            fovSpring.t, fovSpring.v, fovSpring.x = Camera.FieldOfView, 0, Camera.FieldOfView

            local camCFrame = Camera.CFrame
            local lookVector = camCFrame.lookVector.unit

            stateRot = Vector2.new(
                math.asin(lookVector.y),
                math.atan2(-lookVector.z, lookVector.x) - math.pi/2
            )
            panDeltaMouse = Vector2New();
            for _, obj in next, GetChildren(PlayerGui) do
                if IsA(obj, "ScreenGui") and obj.Enabled then
                    obj.Enabled = false
                    screenGuis[obj] = true
                end
            end

            AddConnection(CConnect(LocalPlayer.CharacterAdded, function()
                local Hrp = WaitForChild(LocalPlayer.Character, "HumanoidRootPart");
                Hrp.Anchored = true
            end), CEnv.Connections);
            RunService.BindToRenderStep(RunService, "Freecam", Enum.RenderPriority.Camera.Value, UpdateFreecam);
            CEnv.Enabled = true
        end

        local function ExitFreecam()
            CEnv.Enabled = false
            UserInputService.MouseIconEnabled = true
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default

            RunService.UnbindFromRenderStep(RunService, "Freecam")
            local hum, hrp = GetChar()
            if hum then
                hum.WalkSpeed = 16
            end
            if hrp then
                hrp.Anchored = false
            end
            Camera.FieldOfView = DEF_FOV
            Camera.CameraType = Enum.CameraType.Custom
            for i, Connection in next, CEnv.Connections do
                Disconnect(Connection);
            end
            for obj in next, screenGuis do
                obj.Enabled = true
            end
            screenGuis = {}
            ToggleGui(true)
        end

        EnterFreecam()
        CEnv.Activated = true
        CEnv.Enabled = true
        CEnv.EnterFreecam = EnterFreecam
        CEnv.ExitFreecam = ExitFreecam
        return "freecam enabled"
    end
    if (CEnv.Enabled) then
        CEnv.ExitFreecam();
        return "freecam disabled"
    else
        CEnv.EnterFreecam();
        return "freecam enabled"
    end
end)

AddCommand("plastic", {"fpsboost"}, "changes everything to a plastic material", {}, function(Caller, Args, CEnv)
    local time = tick();
    local Plasticc = 0
    for i, v in next, GetDescendants(Workspace) do
        if (IsA(v, "Part") and v.Material ~= Enum.Material.Plastic) then
            CEnv[v] = v.Material
            v.Material = Enum.Material.Plastic
            Plasticc = Plasticc + 1
        end
    end
    return format("%d items made plastic in %.3f (s)", Plasticc, (tick()) - time);
end)

AddCommand("unplastic", {"unfpsboost"}, "changes everything back from a plastic material", {}, function(Caller, Args, CEnv)
    local Plastics = LoadCommand("plastic").CmdEnv
    local time = tick();
    local Amount = 0
    for i, v in next, Plastics do
        i.Material = v
        Amount = Amount + 1
    end
    return format("removed %d plastic in %.3f (s)", Amount, (tick()) - time);
end)

AddCommand("antiafk", {"antiidle"}, "prevents kicks from when you're afk", {}, function(Caller, Args, CEnv)
    local IsEnabled = CEnv[1]
    for i, v in next, getconnections(LocalPlayer.Idled) do
        if (IsEnabled) then
            v.Enable(v);
            CEnv[1] = nil
        else
            v.Disable(v);
            CEnv[1] = true
        end
    end
    return "antiafk " .. (IsEnabled and " disabled" or "enabled");
end)

AddCommand("clicktp", {}, "tps you to where your mouse is when you click", {}, function(Caller, Args, CEnv)
    local HasTool_ = CEnv[1] ~= nil
    if (HasTool_) then
        Destroy(CEnv[1]);
        Destroy(CEnv[2]);
    end
    local Tool = InstanceNew("Tool");
    Tool.RequiresHandle = false
    Tool.Name = "Click TP"
    ProtectInstance(Tool);
    Tool.Parent = GetCharacter();
    AddConnection(CConnect(Tool.Activated, function()
        local Hit = Mouse.Hit
        GetRoot().CFrame = Hit * CFrame.new(0, 3, 0);
    end))

    local Tool2 = InstanceNew("Tool");
    Tool2.RequiresHandle = false
    Tool2.Name = "Click TweenTP"
    ProtectInstance(Tool2);
    Tool2.Parent = LocalPlayer.Backpack
    AddConnection(CConnect(Tool2.Activated, function()
        local Hit = Mouse.Hit
        Utils.Tween(GetRoot(), "Sine", "Out", .5, {CFrame = Hit * CFrame.new(0, 3, 0)});
    end))

    CEnv[1] = Tool
    CEnv[2] = Tool2
    return "click to teleport"
end)

AddCommand("help", {"info"}, "gives you the description of the command", {"1"}, function(Caller, Args)
    local Command = Args[1]
    local Loaded = LoadCommand(Command);
    if (Loaded) then
        Utils.Notify(Caller, Loaded.Name, Loaded.Description, 8);
    end
end)

AddCommand("friend", {"fr"}, "sends a friend request to the player", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local RequestFriendship = LocalPlayer.RequestFriendship
    for i, v in next, Target do
        RequestFriendship(LocalPlayer, v);
    end
    return #Target == 1 and "sent a friend request to " .. Target[1].Name or format("sent a friend request to %d players", #Target);
end)

AddCommand("unfriend", {"unfr"}, "unfriends a player that you're friends with", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local RevokeFriendship = LocalPlayer.RevokeFriendship
    for i, v in next, Target do
        RevokeFriendship(LocalPlayer, v);
    end
    return #Target == 1 and "unfriended " .. Target[1].Name or format("unfriended %d players", #Target);
end)

AddCommand("setzoomdistance", {"szd"}, "sets your cameras zoom distance so you can zoom out", {}, function(Caller, Args)
    local ZoomDistance = tonumber(Args[1]) or 1000
    LocalPlayer.CameraMaxZoomDistance = ZoomDistance
    return "set zoom distance to " .. ZoomDistance
end)

AddCommand("equiptools", {}, "equips all of your tools", {1}, function()
    UnequipTools(GetHumanoid());
    local Char = GetCharacter();
    local Tools = filter(GetChildren(LocalPlayer.Backpack), function(i, Child)
        return IsA(Child, "Tool");
    end);
    for i, v in next, Tools do
        v.Parent = Char
    end
    return format("equipped %d tools", #Tools);
end)

AddCommand("activatetools", {}, "equips and activates all of your tools", {1}, function()
    local VirtualInputManager = Services.VirtualInputManager
    local SendMouseButtonEvent = VirtualInputManager.SendMouseButtonEvent
    UnequipTools(GetHumanoid());
    local Char = GetCharacter();
    local Tools = filter(GetChildren(LocalPlayer.Backpack), function(i, Child)
        return IsA(Child, "Tool");
    end);
    for i, v in next, Tools do
        v.Parent = Char
    end
    wait();
    for i, v in next, Tools do
        v.Activate(v);
    end
    SendMouseButtonEvent(VirtualInputManager, 0, 0, 0, true, nil, #Tools);
    -- return format("equipped and activated %d tools", #Tools);
end)

AddCommand("hidename", {"hidetag"}, "hides your nametag (billboardgui)", {3}, function(Caller, Args, CEnv)
    local Char = GetCharacter();
    local Billboard = FindFirstChildWhichIsA(Char, "BillboardGui", true);
    if (not Billboard) then
        return "you don't have a player tag to use this command"
    end
    for i, v in next, GetDescendants(Char) do
        if (IsA(v, "BillboardGui")) then
            CEnv[v] = v.Parent
            Destroy(v);
        end
    end
    return "name hidden, use showname to show it again"
end)

AddCommand("showname", {"showtag"}, "shows your player tag", {3}, function()
    local Char = GetCharacter();
    local Billboards = LoadCommand("hidename").CmdEnv
    if (not next(Billboards)) then
        return "your name is already shown"
    end
    return "you have to reset to show your nametag"
end)

AddCommand("nojumpcooldown", {}, "removes a jumpcooldown if any in games", {}, function()
    local UserInputService = Services.UserInputService
    local Humanoid = GetHumanoid();
    local connections = tbl_concat(getconnections(UserInputService.JumpRequest), getconnections(GetPropertyChangedSignal(Humanoid, "FloorMaterial")), getconnections(Humanoid.Jumping));
    for i, v in next, connections do
        if (v.Func and not is_synapse_function(v.Func)) then
            if (Hooks.NoJumpCooldown) then
                v.Enable(v);
            else
                v.Disable(v);
            end
        end
    end
    Hooks.NoJumpCooldown = not Hooks.NoJumpCooldown
    return "nojumpcooldown " .. (Hooks.NoJumpCooldown and "Enabled" or "Disabled")
end)

local LoadConfig, ConfigLoaded;
AddCommand("config", {"conf"}, "shows fates admin config", {}, function(Caller, Args, CEnv)
    if (not ConfigLoaded) then
        if (not CEnv[1]) then
            LoadConfig();
        end
        Utils.SetAllTrans(ConfigUI);
        ConfigUI.Visible = true
        Utils.TweenAllTransToObject(ConfigUI, .25, ConfigUIClone);
        ConfigLoaded = true
        CEnv[1] = true
        return "config loaded"
    end
end)

AddCommand("deletetool", {"deltool"}, "deletes your equipped tool", {1}, function()
    local Tool = FindFirstChildWhichIsA(GetCharacter(), "Tool");
    if (Tool) then
        Destroy(Tool);
        return "deleted tool"
    else
        return "no tool equipped"
    end
end)

AddCommand("deletetools", {"deltools"}, "delets all of your tools in your inventory", {1}, function()
    UnequipTools(GetHumanoid());
    local Tools = GetChildren(LocalPlayer.Backpack);
    for i = 1, #Tools do
        Destroy(Tools[i]);
    end
    return "deleted all tools"
end)

AddCommand("rejoinre", {"rje"}, "rejoins and tps you to your old position", {3}, function()
    local Pos = GetRoot().CFrame
    local queue_on_teleport = syn and syn.queue_on_teleport or queue_on_teleport
    if (queue_on_teleport) then
        queue_on_teleport(format("game.Loaded:Wait();game:GetService('ReplicatedFirst'):SetDefaultLoadingGuiRemoved();local LocalPlayer = game:GetService('Players').LocalPlayer;LocalPlayer.CharacterAdded:Wait():WaitForChild('HumanoidRootPart').CFrame = CFrame.new(%s);loadstring(game.HttpGet(game, \"https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua\"))()", tostring(Pos)));
    end
    ExecuteCommand("rejoin", {}, LocalPlayer);
end)

AddCommand("toggle", {"togglecommand", "togglecmd"}, "toggles a command with an 'un' command", {"1"}, function(Caller, Args, CEnv)
    local Command = Args[1]
    if (LoadCommand(Command)) then
        CEnv.Command = (CEnv.Command and CEnv.Command ~= true) and true or not CEnv.Command
        local NewArgs = shift(Args);
        if (CEnv.Command) then
            ExecuteCommand(Command, NewArgs, Caller);
        else
            ExecuteCommand("un" .. Command, NewArgs, Caller);
        end
    else
        return Command .. " is not a valid command"
    end
end)

AddCommand("inviscam", {"inviscamera"}, "makes you see through walls more better", {}, function(Caller, Args, CEnv)
    CEnv.OldCameraMaxZoomDistance = LocalPlayer.CameraMaxZoomDistance
    CEnv.OldDevCameraOcclusionMode = LocalPlayer.DevCameraOcclusionMode
    LocalPlayer.CameraMaxZoomDistance = 600
    LocalPlayer.DevCameraOcclusionMode = "Invisicam"
    return "inviscam enabled"
end)

AddCommand("uninviscam", {"uninviscamera"}, "disables inviscam", {}, function()
    local CmdEnv = LoadCommand("inviscam").CmdEnv
    LocalPlayer.CameraMaxZoomDistance = CmdEnv.OldCameraMaxZoomDistance
    LocalPlayer.DevCameraOcclusionMode = CmdEnv.OldDevCameraOcclusionMode
    return "inviscam disabled"
end)

AddCommand("snipe", {"streamsnipe"}, "stream snipes a user", {"2"}, function(Caller, Args)
    local PlaceId = tonumber(Args[1]);
    local UserId = tonumber(Args[2]);
    if (not PlaceId) then
        return "placeid expected"
    end
    if (not UserId) then
        return "userid expected"
    end
    local Ret = game.HttpGet(game, format("https://fate123.000webhostapp.com/sniper.php?uid=%s&placeId=%s", UserId, PlaceId));
    local Success, JSON = pcall(JSONDecode, Services.HttpService, Ret);
    if (not Success) then
        return "error occured"
    end
    if (JSON.error) then
        return "error: " .. JSON.error
    end
    local GameInfo = JSON.game
    local UserInfo = JSON.userinfo
    local TeleportService = Services.TeleportService
    TeleportService.TeleportToPlaceInstance(TeleportService, GameInfo.gameid, GameInfo.guid);
    return format("joining %s on game %s (%d/%d)", UserInfo.username, GameInfo.gamename, GameInfo.playing, GameInfo.capacity);
end)

AddCommand("loop", {"loopcommand"}, "loops a command", {"1"}, function(Caller, Args, CEnv)
    local Command = Args[1]
    local LoadedCommand = LoadCommand(Command);
    if (not LoadedCommand) then
        return format("command %s not found", Command);
    end
    local LoopSpeed = 3
    Args = shift(Args);
    CEnv.Looping = true
    CThread(function()
        while (CEnv.Looping) do
            ExecuteCommand(Command, Args, Caller);
            wait(Args[2] or 1);
        end
    end)();
    return format("now looping the %s command", Command);
end)

AddCommand("disablesit", {"neversit", "nosit"}, "disables you from being sat", {}, function(Caller, Args, CEnv)
    local Humanoid = GetHumanoid();
    AddConnection(CConnect(GetPropertyChangedSignal(Humanoid, "Sit"), function()
        CWait(Heartbeat);
        Humanoid.Sit = false
    end), CEnv);
    AddConnection(CConnect(LocalPlayer.CharacterAdded, function(Char)
        Humanoid = WaitForChild(Char, "Humanoid");
        AddConnection(CConnect(GetPropertyChangedSignal(Humanoid, "Sit"), function()
            CWait(RunService.Heartbeat);
            Humanoid.Sit = false
        end), CEnv);
    end), CEnv)
    return "disabled sit"
end)

AddCommand("enablesit", {"undisablesit"}, "enables disablesit", {}, function()
    DisableAllCmdConnections("disablesit");
    return "enabled sit"
end)

AddCommand("massplay", {}, "massplays all of your boomboxes", {3,1,"1"}, function(Caller, Args)
    local Audio = tonumber(Args[1]);
    if (not Audio and not match(Audio, "rbxassetid://%d+")) then
        return "number expected for audio"
    end
    Audio = Audio or Args[1]
    local Character = GetCharacter();
    local Humanoid = GetHumanoid();
    UnequipTools(Humanoid);
    local Boomboxes = filter(GetChildren(LocalPlayer.Backpack), function(i, v)
        if (Sfind(lower(v.Name), "boombox") or FindFirstChildOfClass(v.Handle, "Sound", true)) then
           v.Parent = Character
           return true
        end
        return false
    end)
    for i = 1, #Boomboxes do
        local Boombox = Boomboxes[i]
        local RemoteEvent = FindFirstChildWhichIsA(Boombox, "RemoteEvent")
        RemoteEvent.FireServer(RemoteEvent, "PlaySong", Audio);
    end
    delay(2, function()
        ExecuteCommand("sync", {}, Caller);
    end)
    return "now massplaying"
end)

AddCommand("sync", {"syncaudios"}, "syncs audios playing", {3}, function()
    local Humanoid = GetHumanoid();
    local Playing = filter(GetChildren(GetCharacter()), function(i,v)
        return IsA(v, "Tool") and FindFirstChildOfClass(v.Handle, "Sound");
    end)
    Playing = map(Playing, function(i, v)
        return FindFirstChildOfClass(v.Handle, "Sound");
    end)
    local Sound = Playing[1]
    Services.SoundService.RespectFilteringEnabled = false
    for i = 1, #Playing do
        Playing[i].TimePosition = Sound.TimePosition
    end
    Services.SoundService.RespectFilteringEnabled = true
    return format("synced %d sounds", #Playing);
end)

AddCommand("pathfind", {"follow2"}, "finds a user with pathfinding", {"1",3}, function(Caller, Args)
    local PathfindingService = Services.PathfindingService
    local CreatePath = PathfindingService.CreatePath
    local Target = GetPlayer(Args[1]);
    local LRoot = GetRoot();
    local LHumanoid = GetHumanoid();
    local PSSuccess = Enum.PathStatus.Success
    local Delay = tonumber(Args[2]);
    for i, v in next, Target do
        local TRoot = GetRoot(v);
        if (not TRoot) then
            continue;
        end
        local Path = CreatePath(PathfindingService);
        Path.ComputeAsync(Path, LRoot.Position, TRoot.Position);
        if (LHumanoid.Sit) then
            ChangeState(LHumanoid, 3);
        end
        LHumanoid.WalkSpeed = 16
        LHumanoid.MoveTo(LHumanoid, TRoot.Position);
        wait(2);
        local WayPoints = Path.GetWaypoints(Path);
        for i = 1, #WayPoints do
            local WayPoint = WayPoints[i]
            if (Path.Status == PSSuccess) then
                LHumanoid.WalkToPoint = WayPoint.Position
                if (WayPoint.Action == Enum.PathWaypointAction.Jump) then
                    LHumanoid.WalkSpeed = 0
                    wait();
                    LHumanoid.WalkSpeed = 16
                    ChangeState(LHumanoid, 3);
                end
                CWait(LHumanoid.MoveToFinished);
            else
                repeat Path.ComputeAsync(Path, LRoot.Position, TRoot.Position) until Path.Status == PSSuccess;
            end
        end
        if (Delay) then
            wait(Delay);
        end
    end
end)


local PlrChat = function(i, plr)
    if (not Connections.Players[plr.Name]) then
        Connections.Players[plr.Name] = {}
        Connections.Players[plr.Name].Connections = {}
    end
    Connections.Players[plr.Name].ChatCon = CConnect(plr.Chatted, function(raw)
        local message = raw

        if (ChatLogsEnabled) then
            local Tag = Utils.CheckTag(plr);

            local time = os.date("%X");
            local Text = format("%s - [%s]: %s", time, Tag and Tag.Name or plr.Name, raw);
            local Clone = Clone(ChatLogMessage);

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

        if (startsWith(raw, "/e")) then
            raw = sub(raw, 4);
        elseif (startsWith(raw, Prefix)) then
            raw = sub(raw, #Prefix + 1);
        else
            return
        end

        message = trim(raw);

        if (Tfind(AdminUsers, plr) or plr == LocalPlayer) then
            local CommandArgs = split(message, " ");
            local Command = CommandArgs[1]
            local Args = shift(CommandArgs);

            ExecuteCommand(Command, Args, plr);
        end
    end)
end

--[[
    require - uimore
]]

--[[
    require - plugin
]]

WideBar = false
Draggable = false

--[[
    require - config
]]

AddConnection(CConnect(CommandBar.Input.FocusLost, function()
    if (UndetectedCmdBar) then
        CThread(function()
            wait(.3);
            for i, v in next, getconnections(Services.UserInputService.TextBoxFocusReleased) do
                v.Enable(v);
            end
        end)()
    end

    local Text = trim(CommandBar.Input.Text);
    local CommandArgs = split(Text, " ");

    CommandBarOpen = false

    if (not Draggable) then
        Utils.TweenAllTrans(CommandBar, .5)
        Utils.Tween(CommandBar, "Quint", "Out", .5, {
            Position = UDim2.new(0.5, WideBar and -200 or -100, 1, 5); -- tween 5
        })
    end

    local Command = CommandArgs[1]
    local Args = shift(CommandArgs);

    if (Command ~= "") then
        ExecuteCommand(Command, Args, LocalPlayer);
    end
end), Connections.UI, true);

local CurrentPlayers = GetPlayers(Players);

local PlayerAdded = function(plr)
    RespawnTimes[plr.Name] = tick();
    AddConnection(CConnect(plr.CharacterAdded, function()
        RespawnTimes[plr.Name] = tick();
    end));
    local Tag = Utils.CheckTag(plr);
    if (Tag and plr ~= LocalPlayer) then
        Tag.Player = plr
        Utils.AddTag(Tag);
        if (Tag.Rainbow) then
            Utils.Notify(LocalPlayer, Tag.Name, format("%s (%s) has joined", Tag.Name, Tag.Tag));
        end
        if (Tag.AntiFeList) then
            AntiFeList[#AntiFeList + 1] = plr.UserId
        end
    end
end

forEach(CurrentPlayers, function(i,v)
    PlrChat(i,v);
    PlayerAdded(v);
end);

AddConnection(CConnect(Players.PlayerAdded, function(plr)
    PlrChat(#Connections.Players + 1, plr);
    PlayerAdded(plr);
end))

AddConnection(CConnect(Players.PlayerRemoving, function(plr)
    if (Connections.Players[plr.Name]) then
        if (Connections.Players[plr.Name].ChatCon) then
            Disconnect(Connections.Players[plr.Name].ChatCon);
        end
        Connections.Players[plr.Name] = nil
    end
    if (RespawnTimes[plr.Name]) then
        RespawnTimes[plr.Name] = nil
    end
end))

getgenv().F_A = {
    Utils = Utils,
    PluginLibrary = PluginLibrary,
    GetConfig = GetConfig
}

Utils.Notify(LocalPlayer, "Loaded", format("script loaded in %.3f seconds", (tick()) - start));
Utils.Notify(LocalPlayer, "Welcome", "'cmds' to see all of the commands");
if (debug.info(2, "f") == nil) then
	Utils.Notify(LocalPlayer, "Outdated Script", "use the loadstring to get latest updates (https://fatesc/fates-admin)", 10);
end
local LatestCommit = JSONDecode(Services.HttpService, game.HttpGetAsync(game, "https://api.github.com/repos/fatesc/fates-admin/commits?per_page=1&path=main.lua"))[1]
wait(1);
Utils.Notify(LocalPlayer, "Newest Update", format("%s - %s", LatestCommit.commit.message, LatestCommit.commit.author.name));