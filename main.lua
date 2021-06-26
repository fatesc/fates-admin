--[[
	fates admin - 26/6/2021
]]

local game = game
local GetService = game.GetService
local UndetectedMode = UndetectedMode or false
if (not UndetectedMode and not game.IsLoaded(game)) then
    print("fates admin: waiting for game to load...");
    game.Loaded.Wait(game.Loaded);
end

local start = start or tick();

if (game.IsLoaded(game) and UndetectedMode and syn) then
    syn.queue_on_teleport("loadstring(game.HttpGet(game, \"https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua\"))()");
    return GetService(game, "TeleportService").TeleportToPlaceInstance(GetService(game, "TeleportService"), game.PlaceId, game.JobId);
end

if (getgenv().F_A and getgenv().F_A.Loaded) then
    return getgenv().F_A.Utils.Notify(nil, "Loaded", "fates admin is already loaded... use 'killscript' to kill", nil);
end

--IMPORT [var]
local Services = {}
Services.Workspace = GetService(game, "Workspace");
local GetChildren, GetDescendants = game.GetChildren, game.GetDescendants
local IsA = game.IsA
local FindFirstChild, FindFirstChildOfClass, FindFirstChildWhichIsA, WaitForChild = 
    game.FindFirstChild,
    game.FindFirstChildOfClass,
    game.FindFirstChildWhichIsA,
    game.WaitForChild

local GetPropertyChangedSignal, Changed = 
    game.GetPropertyChangedSignal,
    game.Changed
    
local Destroy, Clone = game.Destroy, game.Clone

local RunService = GetService(game, "RunService");
local Heartbeat, Stepped, RenderStepped =
    RunService.Heartbeat,
    RunService.Stepped,
    RunService.RenderStepped

local Players = GetService(game, "Players");
local GetPlayers = Players.GetPlayers

Services.UserInputService = GetService(game, "UserInputService");
Services.ReplicatedStorage = GetService(game, "ReplicatedStorage");
Services.StarterPlayer = GetService(game, "StarterPlayer");
Services.StarterPack = GetService(game, "StarterPack");
Services.StarterGui = GetService(game, "StarterGui");
Services.TeleportService = GetService(game, "TeleportService");
Services.CoreGui = GetService(game, "CoreGui");
Services.TweenService = GetService(game, "TweenService");
Services.HttpService = GetService(game, "HttpService");
Services.TextService = GetService(game, "TextService");
Services.MarketplaceService = GetService(game, "MarketplaceService")
Services.Chat = GetService(game, "Chat");
Services.Teams = GetService(game, "Teams");
Services.SoundService = GetService(game, "SoundService");
Services.Lighting = GetService(game, "Lighting");
Services.ScriptContext = GetService(game, "ScriptContext");
Services.Stats = GetService(game, "Stats");

local JSONEncode, JSONDecode, GenerateGUID = 
    Services.HttpService.JSONEncode, 
    Services.HttpService.JSONDecode,
    Services.HttpService.GenerateGUID

local Camera = Services.Workspace.CurrentCamera

local table = table
local Tfind, sort, concat, pack, unpack, insert, remove = 
    table.find, 
    table.sort,
    table.concat,
    table.pack,
    table.unpack,
    table.insert,
    table.remove

local string = string
local lower, trim, Sfind, split, sub, format, len, match, gmatch, gsub, byte = 
    string.lower, 
    string.trim, 
    string.find, 
    string.split, 
    string.sub,
    string.format,
    string.len,
    string.match,
    string.gmatch,
    string.gsub,
    string.byte

local math = math
local random, floor, round, abs, atan, cos, sin, rad = 
    math.random,
    math.floor,
    math.round,
    math.abs,
    math.atan,
    math.cos,
    math.sin,
    math.rad

local tostring, tonumber = tostring, tonumber

local InstanceNew = Instance.new
local CFrameNew = CFrame.new
local Vector3New = Vector3.new

local CalledCFrameNew = CFrameNew();
local Inverse = CalledCFrameNew.Inverse
local toObjectSpace = CalledCFrameNew.toObjectSpace
local components = CalledCFrameNew.components

local Connection = game.Loaded
local CWait = Connection.Wait
local CConnect = Connection.Connect
local CalledConnection = CConnect(Connection, function() end);
local Disconnect = CalledConnection.Disconnect

local __H = InstanceNew("Humanoid");
local UnequipTools = __H.UnequipTools
local ChangeState = __H.ChangeState
local SetStateEnabled = __H.SetStateEnabled
local GetState = __H.GetState
local GetAccessories = __H.GetAccessories
local MoveTo = __H.MoveTo

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer.GetMouse(LocalPlayer);
--END IMPORT [var]


local GetCharacter = GetCharacter or function(Plr)
    return Plr and Plr.Character or LocalPlayer.Character
end

--IMPORT [extend]
Debug = true
if (getconnections) then
    local ErrorConnections = getconnections(Services.ScriptContext.Error);
    if (next(ErrorConnections)) then
        getfenv().error = warn
        getgenv().error = warn
    end
end

local startsWith = function(str, searchString, rawPos)
    local pos = rawPos or 1
    return searchString == "" and true or sub(str, pos, pos) == searchString
end

local trim = function(str)
    return gsub(str, "^%s*(.-)%s*$", "%1");
end

tbl_concat = function(...)
    local new = {}
    for i, v in next, {...} do
        for i2, v2 in next, v do
            -- insert(new, #new + 1, v2);
            new[#new + 1] = v2
        end
    end
    return new
end

local indexOf = function(tbl, val)
    if (type(tbl) == 'table') then
        for i, v in next, tbl do
            if (v == val) then
                return i
            end
        end
    end
end

local forEach = function(tbl, ret)
    for i, v in next, tbl do
        ret(i, v);
    end
end

local filter = function(tbl, ret)
    if (type(tbl) == 'table') then
        local new = {}
        for i, v in next, tbl do
            if (ret(i, v)) then
                new[#new + 1] = v
            end
        end
        return new
    end
end

local map = function(tbl, ret)
    if (type(tbl) == 'table') then
        local new = {}
        for i, v in next, tbl do
            new[#new + 1] = ret(i, v);
        end
        return new
    end
end

local deepsearch;
deepsearch = function(tbl, ret)
    if (type(tbl) == 'table') then
        for i, v in next, tbl do
            if (type(v) == 'table') then
                deepsearch(v, ret);
            end
            ret(i, v);
        end
    end
end

local flat = function(tbl)
    if (type(tbl) == 'table') then
        local new = {}
        deepsearch(tbl, function(i, v)
            if (type(v) ~= 'table') then
                new[#new + 1] = v
            end
        end)
        return new
    end
end

local flatMap = function(tbl, ret)
    if (type(tbl) == 'table') then
        local new = flat(map(tbl, ret));
        return new
    end
end

local shift = function(tbl)
    if (type(tbl) == 'table') then
        local firstVal = tbl[1]
        tbl = pack(unpack(tbl, 2, #tbl));
        tbl.n = nil
        return tbl
    end
end

local keys = function(tbl)
    if (type(tbl) == 'table') then
        local new = {}
        for i, v in next, tbl do
            new[#new + 1] = i	
        end
        return new
    end
end

local firetouchinterest = firetouchinterest or function(part1, part2, toggle)
    if (part1 and part2) then
        if (toggle == 0) then
            touched[1] = part1.CFrame
            part1.CFrame = part2.CFrame
        else
            part1.CFrame = touched[1]
            touched[1] = nil
        end
    end
end

local hookfunction = hookfunction or function(func, newfunc)
    if (replaceclosure) then
        replaceclosure(func, newfunc);
        return newfunc
    end

    func = newcclosure and newcclosure(newfunc) or newfunc
    return newfunc
end

local getconnections = function(...)
    if (not getconnections or identifyexecutor and identifyexecutor() == "Krnl") then
        return {}
    end
    return getconnections(...);
end

local getrawmetatable = getrawmetatable or function()
    return setmetatable({}, {});
end

local getnamecallmethod = getnamecallmethod or function()
    return ""
end

local checkcaller = checkcaller or function()
    return false
end

local getgc = getgc or function()
    return {}
end

if (game.PlaceId == 292439477) then
    local GetBodyParts;
    for i, v in next, getgc(true) do
        if (type(v) == "table") then
            if (rawget(v, "getbodyparts")) then
                GetBodyParts = rawget(v, "getbodyparts");
                break;
            end
        end
    end
    GetCharacter = function(Plr)
        if (Plr == LocalPlayer or not Plr) then
            return LocalPlayer.Character
        end
        local Char = GetBodyParts(Plr);
        if (type(Char) == "table") then
            if (rawget(Char, "rootpart")) then
                Plr.Character = rawget(Char, "rootpart").Parent
            end
        end
        return Plr and Plr.Character or nil
    end
end

local ProtectedInstances = {}
local SpoofedInstances = {}
local SpoofedProperties = {}
local Methods = {
    "FindFirstChild",
    "FindFirstChildWhichIsA",
    "FindFirstChildOfClass",
    "IsA"
}
local AllowedIndexes = {
    "RootPart",
    "Parent"
}
local AllowedNewIndexes = {
    "Jump"
}
local AntiKick = false
local AntiTeleport = false

local OldMemoryTags = {}
for i, v in next, Enum.DeveloperMemoryTag.GetEnumItems(Enum.DeveloperMemoryTag) do
    OldMemoryTags[v] = Services.Stats.GetMemoryUsageMbForTag(Services.Stats, v);
end

local mt = getrawmetatable(game);
local OldMetaMethods = {}
setreadonly(mt, false);
for i, v in next, mt do
    OldMetaMethods[i] = v
end

mt.__namecall = newcclosure(function(self, ...)
    local __Namecall = OldMetaMethods.__namecall;

    if (checkcaller()) then
        return __Namecall(self, ...);
    end
    local Args = {...}
    local Method = getnamecallmethod();
    local Protected = ProtectedInstances[self]

    if (Protected) then
        if (Tfind(Methods, Method)) then
            return Method == "IsA" and false or nil
        end
    end

    if (Method == "GetChildren" or Method == "GetDescendants") then
        return filter(__Namecall(self, ...), function(i, v)
            return not Tfind(ProtectedInstances, v);
        end)
    end

    if (Method == "GetFocusedTextBox") then
        if (Tfind(ProtectedInstances, __Namecall(self, ...))) then
            return nil
        end
    end

    if (AntiKick and lower(Method) == "kick") then
        getgenv().F_A.Utils.Notify(nil, "Attempt to kick", format("attempt to kick with message \"%s\"", Args[1]));
        return
    end

    if (AntiTeleport and Method == "Teleport" or Method == "TeleportToPlaceInstance") then
        getgenv().F_A.Utils.Notify(nil, "Attempt to teleport", format("attempt to teleport to place \"%s\"", Args[1]));
        return
    end

    return __Namecall(self, ...);
end)

mt.__index = newcclosure(function(Instance_, Index)
    local __Index = OldMetaMethods.__index;

    if (checkcaller()) then
        return __Index(Instance_, Index);
    end

    local SanitisedIndex = type(Index) == 'string' and gsub(Index, "%z.*", "") or Index

    local ProtectedInstance = ProtectedInstances[Instance_]
    local SpoofedInstance = SpoofedInstances[Instance_]
    local SpoofedPropertiesForInstance = SpoofedProperties[Instance_]

    if (SpoofedInstance) then
        if (Tfind(AllowedIndexes, SanitisedIndex)) then
            return __Index(Instance_, Index);
        end
        return __Index(SpoofedInstance, Index);
    end

    if (SpoofedPropertiesForInstance) then
        for i, SpoofedProperty in next, SpoofedPropertiesForInstance do
            if (SanitisedIndex == SpoofedProperty.Property) then
                return __Index(SpoofedProperty.SpoofedProperty, Index);
            end
        end
    end

    if (ProtectedInstance) then
        if (Tfind(Methods, SanitisedIndex)) then
            return newcclosure(function()
                return SanitisedIndex == "IsA" and false or nil
            end);
        end
    end
    
    return __Index(Instance_, Index);
end)

mt.__newindex = newcclosure(function(Instance_, Index, Value)
    local __NewIndex = OldMetaMethods.__newindex;
    local __Index = OldMetaMethods.__index;

    local SpoofedInstance = SpoofedInstances[Instance_]
    local SpoofedPropertiesForInstance = SpoofedProperties[Instance_]

    if (checkcaller()) then
        if (SpoofedInstance or SpoofedPropertiesForInstance) then
            local Connections = getconnections(GetPropertyChangedSignal(Instance_, SpoofedPropertiesForInstance and SpoofedPropertiesForInstance.Property or Index));
            if (not next(Connections)) then
                return __NewIndex(Instance_, Index, Value);
            end
            for i, v in next, Connections do
                v.Disable(v);
            end
            local Suc, Ret = pcall(function()
                return __NewIndex(Instance_, Index, Value);
            end)
            for i, v in next, Connections do
                v.Enable(v);
            end
            return Ret
        end
        return __NewIndex(Instance_, Index, Value);
    end

    local SanitisedIndex = type(Index) == 'string' and gsub(Index, "%z.*", "") or Index

    if (SpoofedInstance) then
        if (Tfind(AllowedNewIndexes, SanitisedIndex)) then
            return __NewIndex(Instance_, Index, Value);
        end
        return __NewIndex(SpoofedInstance, Index, __Index(SpoofedInstance, Index));
    end

    if (SpoofedPropertiesForInstance) then
        for i, SpoofedProperty in next, SpoofedPropertiesForInstance do
            if (SpoofedProperty.Property == SanitisedIndex and not Tfind(AllowedIndexes, SanitisedIndex)) then
                return __NewIndex(SpoofedProperty.SpoofedProperty, Index, __Index(SpoofedProperty.SpoofedProperty, Index));
            end
        end
    end

    return __NewIndex(Instance_, Index, Value);
end)

setreadonly(mt, true);

local Hooks = {}

Hooks.OldGetChildren = nil
Hooks.OldGetChildren = hookfunction(game.GetChildren, function(...)
    if (not checkcaller()) then
        local Children = Hooks.OldGetChildren(...);
        if (Tfind(Children, ProtectedInstances)) then
            return filter(Children, function(i, v)
                return not Tfind(ProtectedInstances, v);
            end)
        end
    end
    return Hooks.OldGetChildren(...);
end)

Hooks.OldGetDescendants = nil
Hooks.OldGetDescendants = hookfunction(game.GetDescendants, newcclosure(function(...)
    if (not checkcaller()) then
        local Descendants = Hooks.OldGetDescendants(...);
        if (Tfind(Descendants, ProtectedInstances)) then
            return filter(Descendants, function(i, v)
                return not Tfind(ProtectedInstances, v);
            end)
        end
    end
    return Hooks.OldGetDescendants(...);
end))

Hooks.OldGetFocusedTextBox = nil
Hooks.OldGetFocusedTextBox = hookfunction(Services.UserInputService.GetFocusedTextBox, newcclosure(function(...)
    if (not checkcaller()) then
        local FocusedTextBox = Hooks.OldGetFocusedTextBox(...);
        if (FocusedTextBox and Tfind(ProtectedInstances, FocusedTextBox)) then
            return nil
        end
    end
    return Hooks.OldGetFocusedTextBox(...);
end))

Hooks.OldKick = nil
Hooks.OldKick = hookfunction(InstanceNew("Player").Kick, newcclosure(function(self, ...)
    if (AntiKick) then
        local Args = {...}
        getgenv().F_A.Utils.Notify(nil, "Attempt to kick", format("attempt to kick with message \"%s\"", Args[1]));
        return
    end

    return Hooks.OldKick(self, ...);
end))

Hooks.OldTeleportToPlaceInstance = nil
Hooks.OldTeleportToPlaceInstance = hookfunction(Services.TeleportService.TeleportToPlaceInstance, newcclosure(function(self, ...)
    if (AntiTeleport) then
        getgenv().F_A.Utils.Notify(nil, "Attempt to teleport", format("attempt to teleport to place \"%s\"", Args[1]));
        return
    end
    return Hooks.OldTeleportToPlaceInstance(self, ...);
end))
Hooks.OldTeleport = nil
Hooks.OldTeleport = hookfunction(Services.TeleportService.Teleport, newcclosure(function(self, ...)
    if (AntiTeleport) then
        getgenv().F_A.Utils.Notify(nil, "Attempt to teleport", format("attempt to teleport to place \"%s\"", Args[1]));
        return
    end
    return Hooks.OldTeleport(self, ...);
end))

Hooks.OldGetMemoryUsageMbForTag = nil
Hooks.OldGetMemoryUsageMbForTag = hookfunction(Services.Stats.GetMemoryUsageMbForTag, newcclosure(function(self, ...)
    if (game.PlaceId == 6650331930) then
        local Args = {...}
        if (Args[1] == Enum.DeveloperMemoryTag.Gui) then
            return Hooks.OldGetMemoryUsageMbForTag(Args[1]) - 1
        end
    end
    return Hooks.OldGetMemoryUsageMbForTag(self, ...);
end))

local ProtectInstance = function(Instance_, disallow)
    if (not ProtectedInstances[Instance_]) then
        ProtectedInstances[#ProtectedInstances + 1] = Instance_
        if (syn and syn.protect_gui and not disallow) then
            syn.protect_gui(Instance_);
        end
    end
end

local SpoofInstance = function(Instance_, Instance2)
    if (not SpoofedInstances[Instance_]) then
        SpoofedInstances[Instance_] = Instance2 and Instance2 or Clone(Instance_);
    end
end

local SpoofProperty = function(Instance_, Property)
    if (SpoofedProperties[Instance_]) then
        local Properties = map(SpoofedProperties[Instance_], function(i, v)
            return v.Property
        end)
        if (not Tfind(Properties, Property)) then
            insert(SpoofedProperties[Instance_], {
                SpoofedProperty = SpoofedProperties[Instance_].SpoofedProperty,
                Property = Property,
            });
        end
    else
        SpoofedProperties[Instance_] = {{
            SpoofedProperty = Clone(Instance_),
            Property = Property,
        }}
    end
end

-- local UnProtectInstance = function(Instance_)
--     for i, v in next, ProtectedInstances do
--         if (v == Instance_) then
--             ProtectedInstances[i] = nil
--             if (syn and syn.unprotect_gui) then
--                 pcall(function()
--                     syn.unprotect_gui(Instance_);
--                 end)
--             end
--         end
--     end
-- end

local UnSpoofInstance = function(Instance_)
    if (SpoofedInstances[Instance_]) then
        SpoofedInstances[Instance_] = nil
    end
end
-- local UnSpoofProperty = function(Instance_, Property)
--     local SpoofedProperty = SpoofedProperties[Instance_]
--     if (SpoofedProperty and SpoofedProperty.Property == Property) then
--         Destroy(SpoofedProperty.SpoofedProperty);
--         SpoofedInstances[Instance_] = nil
--     end
-- end
--END IMPORT [extend]


local PluginLibrary = {}


PluginLibrary.GetCharacter = GetCharacter

local GetRoot = function(Plr)
    return Plr and GetCharacter(Plr) and FindFirstChild(GetCharacter(Plr), "HumanoidRootPart") or GetCharacter() and FindFirstChild(GetCharacter(), "HumanoidRootPart");
end
PluginLibrary.GetRoot = GetRoot

local GetHumanoid = function(Plr)
    return Plr and GetCharacter(Plr) and FindFirstChildWhichIsA(GetCharacter(Plr), "Humanoid") or GetCharacter() and FindFirstChildWhichIsA(GetCharacter(), "Humanoid");
end
PluginLibrary.GetHumanoid = GetHumanoid

local GetMagnitude = function(Plr)
    return Plr and GetRoot(Plr) and (GetRoot(Plr).Position - GetRoot().Position).magnitude or math.huge
end
PluginLibrary.GetMagnitude = GetMagnitude

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
    if (isfolder("fates-admin")) then
        return JSONDecode(Services.HttpService, readfile("fates-admin/config.json"));
    else
        WriteConfig();
        return JSONDecode(Services.HttpService, readfile("fates-admin/config.json"));
    end
end

local GetPluginConfig = function()
    if (isfolder("fates-admin") and isfolder("fates-admin/plugins") and isfile("fates-admin/plugins/plugin-conf.json")) then
        return JSONDecode(Services.HttpService, readfile("fates-admin/plugins/plugin-conf.json"));
    else
        WriteConfig();
        return JSONDecode(Services.HttpService, readfile("fates-admin/plugins/plugin-conf.json"));
    end
end

local SetConfig = function(conf)
    if (isfolder("fates-admin") and isfile("fates-admin/config.json")) then
        local NewConfig = GetConfig();
        for i, v in next, conf do
            NewConfig[i] = v
        end
        writefile("fates-admin/config.json", JSONEncode(Services.HttpService, NewConfig));
    else
        WriteConfig();
        local NewConfig = GetConfig();
        for i, v in next, conf do
            NewConfig[i] = v
        end
        writefile("fates-admin/config.json", JSONEncode(Services.HttpService, NewConfig));
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
            return GetPlayer(v);
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
                return v ~= LocalPlayer
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
        getgenv().F_A.Utils.Notify(LocalPlayer, "Fail", format("Couldn't find player %s", str));
    end
    return Players
end
PluginLibrary.GetPlayer = GetPlayer
local LastCommand = {}


--IMPORT [ui]
Guis = {}
ParentGui = function(Gui, Parent)
    Gui.Name = sub(gsub(GenerateGUID(Services.HttpService, false), '-', ''), 1, random(25, 30))
    ProtectInstance(Gui);
    Gui.Parent = Parent or Services.CoreGui
    Guis[#Guis + 1] = Gui
    return Gui
end
UI = Clone(game.GetObjects(game, "rbxassetid://6167929302")[1]);

local CommandBarPrefix = isfolder and (GetConfig().CommandBarPrefix and Enum.KeyCode[GetConfig().CommandBarPrefix] or Enum.KeyCode.Semicolon) or Enum.KeyCode.Semicolon

local CommandBar = UI.CommandBar
local Commands = UI.Commands
local ChatLogs = UI.ChatLogs
local GlobalChatLogs = Clone(UI.ChatLogs);
local HttpLogs = Clone(UI.ChatLogs);
local Notification = UI.Notification
local Command = UI.Command
local ChatLogMessage = UI.Message
local GlobalChatLogMessage = Clone(UI.Message);
local NotificationBar = UI.NotificationBar
local Stats = Clone(UI.Notification);
local StatsBar = Clone(UI.NotificationBar);

local RobloxChat = PlayerGui and FindFirstChild(PlayerGui, "Chat");
if (RobloxChat) then
    local RobloxChatFrame = WaitForChild(RobloxChat, "Frame", .1);
    if RobloxChatFrame then
        RobloxChatChannelParentFrame = WaitForChild(RobloxChatFrame, "ChatChannelParentFrame", .1);
        RobloxChatBarFrame = WaitForChild(RobloxChatFrame, "ChatBarParentFrame", .1);
        if RobloxChatChannelParentFrame then
            RobloxFrameMessageLogDisplay = WaitForChild(RobloxChatChannelParentFrame, "Frame_MessageLogDisplay", .1);
            if RobloxFrameMessageLogDisplay then
                RobloxScroller = WaitForChild(RobloxFrameMessageLogDisplay, "Scroller", .1);
            end
        end
    end
end

local CommandBarOpen = false
local CommandBarTransparencyClone = Clone(CommandBar);
local ChatLogsTransparencyClone = Clone(ChatLogs);
local GlobalChatLogsTransparencyClone = Clone(GlobalChatLogs);
local HttpLogsTransparencyClone = Clone(HttpLogs);
local CommandsTransparencyClone
local PredictionText = ""

local UIParent = CommandBar.Parent
GlobalChatLogs.Parent = UIParent
GlobalChatLogMessage.Parent = UIParent
GlobalChatLogs.Name = "GlobalChatLogs"
GlobalChatLogMessage.Name = "GlobalChatLogMessage"

HttpLogs.Parent = UIParent
HttpLogs.Name = "HttpLogs"
HttpLogs.Size = UDim2.new(0, 421, 0, 260);
HttpLogs.Search.PlaceholderText = "Search"

local Frame2;
local PredictionClone;
if (RobloxChatBarFrame) then
    local Frame1 = WaitForChild(RobloxChatBarFrame, 'Frame', .1);
    if Frame1 then
        local BoxFrame = WaitForChild(Frame1, 'BoxFrame', .1);
        if BoxFrame then
            Frame2 = WaitForChild(BoxFrame, 'Frame', .1);
            if Frame2 then
                local TextLabel = WaitForChild(Frame2, 'TextLabel', .1);
                ChatBar = WaitForChild(Frame2, 'ChatBar', .1);
                if TextLabel and ChatBar then
                    PredictionClone = InstanceNew('TextLabel');
                    PredictionClone.Font = TextLabel.Font
                    PredictionClone.LineHeight = TextLabel.LineHeight
                    PredictionClone.MaxVisibleGraphemes = TextLabel.MaxVisibleGraphemes
                    PredictionClone.RichText = TextLabel.RichText
                    PredictionClone.Text = ''
                    PredictionClone.TextColor3 = TextLabel.TextColor3
                    PredictionClone.TextScaled = TextLabel.TextScaled
                    PredictionClone.TextSize = TextLabel.TextSize
                    PredictionClone.TextStrokeColor3 = TextLabel.TextStrokeColor3
                    PredictionClone.TextStrokeTransparency = TextLabel.TextStrokeTransparency
                    PredictionClone.TextTransparency = 0.3
                    PredictionClone.TextTruncate = TextLabel.TextTruncate
                    PredictionClone.TextWrapped = TextLabel.TextWrapped
                    PredictionClone.TextXAlignment = TextLabel.TextXAlignment
                    PredictionClone.TextYAlignment = TextLabel.TextYAlignment
                    PredictionClone.Name = "Predict"
                    PredictionClone.Size = UDim2.new(1, 0, 1, 0);
                    PredictionClone.BackgroundTransparency = 1
                end
            end
        end
    end
end

-- position CommandBar
CommandBar.Position = UDim2.new(0.5, -100, 1, 5);
ProtectInstance(CommandBar.Input, true);
ProtectInstance(Commands.Search, true);
--END IMPORT [ui]


--IMPORT [tags]
PlayerTags = {
    ["505156575355565455"] = {
        ["Tag"] = "Developer",
        ["Name"] = "fate",
        ["Rainbow"] = true,
    },
    ["555352544955574849"] = {
        ["Tag"] = "Developer",
        ["Name"] = "misrepresenting",
        ["Rainbow"] = true,
    },
    ["495656525454515248"] = {
        ["Tag"] = "Cool",
        ["Name"] = "David",
        ["Rainbow"] = true,
    },
    ["49565649565652"] = {
        ["Tag"] = "Developer",
        ["Name"] = "Owner",
        ["Rainbow"] = true
    },
    ["495357485451505151"] = {
        ["Tag"] = "Contributor",
        ["Name"] = "Tes",
        ["Colour"] = {134,0,125} -- more accurate colour for tes.
    }
}

--END IMPORT [tags]


--IMPORT [utils]
local Utils = {}

Utils.Tween = function(Object, Style, Direction, Time, Goal)
    local TInfo = TweenInfo.new(Time, Enum.EasingStyle[Style], Enum.EasingDirection[Direction])
    local Tween = Services.TweenService.Create(Services.TweenService, Object, TInfo, Goal)

    Tween.Play(Tween)

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

    Connections["ObjectMouseEnter" .. #Connections] = CConnect(Object.MouseEnter, function()
        Utils.Tween(Object, "Sine", "Out", .5, Hover)
    end)

    Connections["ObjectMouseLeave" .. #Connections] = CConnect(Object.MouseLeave, function()
        Utils.Tween(Object, "Sine", "Out", .5, Origin)
    end)

    Connections["ObjectMouseButton1Down" .. #Connections] = CConnect(Object.MouseButton1Down, function()
        Utils.Tween(Object, "Sine", "Out", .3, Press)
    end)

    Connections["ObjectMouseButton1Up" .. #Connections] = CConnect(Object.MouseButton1Up, function()
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
    CWait(Tween.Completed);

    local Tween = Utils.Tween(Object, "Sine", "Out", .5, Normal)
    CWait(Tween.Completed);
end

Utils.Hover = function(Object, Goal)
    local Hover = {
        [Goal] = Utils.MultColor3(Object[Goal], 0.9)
    }

    local Origin = {
        [Goal] = Object[Goal]
    }

    Connections["ObjectMouseEnter" .. #Connections] = CConnect(Object.MouseEnter, function()
        Utils.Tween(Object, "Sine", "Out", .5, Hover)
    end)

    Connections["ObjectMouseLeave" .. #Connections] = CConnect(Object.MouseLeave, function()
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
        local Tween = Services.TweenService.Create(Services.TweenService, Ui, TweenInfo.new(0.25), {Position = Position});
        Tween.Play(Tween);
    end

    Connections["UIInputBegan" .. #Connections] = CConnect(Ui.InputBegan, function(Input)
        if ((Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and Services.UserInputService.GetFocusedTextBox(Services.UserInputService) == nil) then
            DragToggle = true
            DragStart = Input.Position
            StartPos = Ui.Position

            Connections["InputChanged" .. #Connections] = CConnect(Input.Changed, function()
                if (Input.UserInputState == Enum.UserInputState.End) then
                    DragToggle = false
                end
            end)
        end
    end)

    Connections["UiInputChanged" .. #Connections] = CConnect(Ui.InputChanged, function(Input)
        if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            DragInput = Input
        end
    end)

    Connections["Services.UserInputServiceInputChanged" .. #Connections] = CConnect(Services.UserInputService.InputChanged, function(Input)
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
    local input = Clone(content)

    input.ClearAllChildren(input);
    input.BackgroundTransparency = 1
    input.ScrollBarImageTransparency = 1
    input.ZIndex = content.ZIndex + 1
    input.Name = "_smoothinputframe"
    input.ScrollingEnabled = true
    input.Parent = content.Parent

    -- keep input frame in sync with content frame
    local function syncProperty(prop)
        Connections["content" .. #Connections] = CConnect(GetPropertyChangedSignal(content, prop), function()
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
    local smoothConnection = CConnect(RenderStepped, function()
        local a = content.CanvasPosition
        local b = input.CanvasPosition
        local c = SmoothingFactor
        local d = (b - a) * c + a

        content.CanvasPosition = d
    end)

    Connections["smoothConnection" .. #Connections] = smoothConnection

    -- destroy everything when the frame is destroyed
    Connections["contentAncestryChanged" .. #Connections] = CConnect(content.AncestryChanged, function()
        if content.Parent == nil then
            Destroy(input);
            Disconnect(smoothConnection);
        end
    end)
end

Utils.TweenAllTransToObject = function(Object, Time, BeforeObject) -- max transparency is max object transparency, swutched args bc easier command
    local Descendants = GetDescendants(Object);
    local OldDescentants = GetDescendants(BeforeObject);
    local Tween -- to use to wait

    Tween = Utils.Tween(Object, "Sine", "Out", Time, {
        BackgroundTransparency = BeforeObject.BackgroundTransparency
    })

    for i, v in next, Descendants do
        local IsText = IsA(v, "TextBox") or IsA(v, "TextLabel") or IsA(v, "TextButton")
        local IsImage = IsA(v, "ImageLabel") or IsA(v, "ImageButton")
        local IsScrollingFrame = IsA(v, "ScrollingFrame")

        if (not IsA(v, "UIListLayout")) then
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

    for _, v in ipairs(GetDescendants(Object)) do
        local IsText = IsA(v, "TextBox") or IsA(v, "TextLabel") or IsA(v, "TextButton")
        local IsImage = IsA(v, "ImageLabel") or IsA(v, "ImageButton")
        local IsScrollingFrame = IsA(v, "ScrollingFrame")

        if (not IsA(v, "UIListLayout")) then
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

    for _, v in ipairs(GetDescendants(Object)) do
        local IsText = IsA(v, "TextBox") or IsA(v, "TextLabel") or IsA(v, "TextButton")
        local IsImage = IsA(v, "ImageLabel") or IsA(v, "ImageButton")
        local IsScrollingFrame = IsA(v, "ScrollingFrame")

        if (not IsA(v, "UIListLayout")) then
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

        local Clone = Clone(Notification)

        local function TweenDestroy()
            if (Utils and Clone) then -- fix error when the script is killed and there is still notifications out
                local Tween = Utils.TweenAllTrans(Clone, .25)

                CWait(Tween.Completed)
                Destroy(Clone);
            end
        end

        Clone.Message.Text = Message
        Clone.Title.Text = Title or "Notification"
        Utils.SetAllTrans(Clone)
        Utils.Click(Clone.Close, "TextColor3")
        Clone.Visible = true -- tween

        if (len(Message) >= 35) then
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

            CWait(Tween.Completed);
            wait(Time or 5);

            if (Clone) then
                TweenDestroy();
            end
        end)()

        Connections["CloneClose" .. #Connections] = CConnect(Clone.Close.MouseButton1Click, function()
            TweenDestroy()
        end)

        return Clone
    else
        local ChatRemote = Services.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
        ChatRemote.FireServer(ChatRemote, format("/w %s [FA] %s: %s", Caller.Name, Title, Message), "All");
    end
end

Utils.MatchSearch = function(String1, String2) -- Utils.MatchSearch("pog", "poggers") - true; Utils.MatchSearch("poz", "poggers") - false
    return String1 == sub(String2, 1, #String1);
end

Utils.StringFind = function(Table, String)
    for _, v in ipairs(Table) do
        if (Utils.MatchSearch(String, v)) then
            return v
        end
    end
end

Utils.GetPlayerArgs = function(Arg)
    Arg = lower(Arg);
    local SpecialCases = {"all", "others", "random", "me", "nearest", "farthest"}
    if (Utils.StringFind(SpecialCases, Arg)) then
        return Utils.StringFind(SpecialCases, Arg);
    end

    local CurrentPlayers = GetPlayers(Players);
    for i, v in next, CurrentPlayers do
        if (v.Name ~= v.DisplayName and Utils.MatchSearch(Arg, lower(v.DisplayName))) then
            return lower(v.DisplayName);
        end
        if (Utils.MatchSearch(Arg, lower(v.Name))) then
            return lower(v.Name);
        end
    end
end

Utils.ToolTip = function(Object, Message)
    local CloneToolTip

    CConnect(Object.MouseEnter, function()
        if (Object.BackgroundTransparency < 1 and not CloneToolTip) then
            local TextSize = Services.TextService.GetTextSize(Services.TextService, Message, 12, Enum.Font.Gotham, Vector2.new(200, math.huge)).Y > 24 and true or false

            CloneToolTip = Clone(UI.ToolTip)
            CloneToolTip.Text = Message
            CloneToolTip.TextScaled = TextSize
            CloneToolTip.Visible = true
            CloneToolTip.Parent = UI
        end
    end)

    CConnect(Object.MouseLeave, function()
        if (CloneToolTip) then
            Destroy(CloneToolTip);
            CloneToolTip = nil
        end
    end)

    if (LocalPlayer) then
        CConnect(Mouse.Move, function()
            if (CloneToolTip) then
                CloneToolTip.Position = UDim2.fromOffset(Mouse.X + 10, Mouse.Y + 10)
            end
        end)
    else
        delay(3, function()
            LocalPlayer = Players.LocalPlayer
            CConnect(Mouse.Move, function()
                if (CloneToolTip) then
                    CloneToolTip.Position = UDim2.fromOffset(Mouse.X + 10, Mouse.Y + 10)
                end
            end)
        end)
    end
end

Utils.ClearAllObjects = function(Object)
    for _, v in ipairs(GetChildren(Object)) do
        if (not IsA(v, "UIListLayout")) then
            Destroy(v);
        end
    end
end

Utils.Rainbow = function(TextObject)
    local Text = TextObject.Text
    local Frequency = 1 -- determines how quickly it repeats
    local TotalCharacters = 0
    local Strings = {}

    TextObject.RichText = true

    for Character in gmatch(Text, ".") do
        if match(Character, "%s") then
            insert(Strings, Character)
        else
            TotalCharacters = TotalCharacters + 1
            insert(Strings, {'<font color="rgb(%i, %i, %i)">' .. Character .. '</font>'})
        end
    end

    pcall(function() -- no idea why this shit is erroring
        local Connection = AddConnection(CConnect(Heartbeat, function()
            local String = ""
            local Counter = TotalCharacters
    
            for _, CharacterTable in ipairs(Strings) do
                local Concat = ""
    
                if (type(CharacterTable) == "table") then
                    Counter = Counter - 1
                    local Color = Color3.fromHSV(-atan(math.tan((tick() + Counter/math.pi)/Frequency))/math.pi + 0.5, 1, 1)
    
                    CharacterTable = format(CharacterTable[1], floor(Color.R * 255), floor(Color.G * 255), floor(Color.B * 255))
                end
    
                String = String .. CharacterTable
            end
    
            TextObject.Text = String .. " " -- roblox bug w (textobjects in billboardguis wont render richtext without space)
        end));
        delay(150, function()
            Disconnect(Connection);
        end)
    end)
end

Utils.Vector3toVector2 = function(Vector)
    local Tuple = WorldToViewportPoint(Camera, Vector);
    return Vector2.new(Tuple.X, Tuple.Y);
end

Utils.CheckTag = function(Plr)
    if (not Plr or not IsA(Plr, "Player")) then
        return nil
    end
    local UserId = tostring(Plr.UserId);
    local Tag = PlayerTags[gsub(UserId, ".", function(x)
        return byte(x);
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
    local Billboard = InstanceNew("BillboardGui");
    Billboard.Parent = UI
    Billboard.Name = GenerateGUID(Services.HttpService);
    Billboard.AlwaysOnTop = true
    Billboard.Adornee = FindFirstChild(PlrCharacter, "Head") or nil
    Billboard.Enabled = FindFirstChild(PlrCharacter, "Head") and true or false
    Billboard.Size = UDim2.new(0, 200, 0, 50)
    Billboard.StudsOffset = Vector3New(0, 4, 0);

    local TextLabel = InstanceNew("TextLabel", Billboard);
    TextLabel.Name = GenerateGUID(Services.HttpService);
    TextLabel.TextStrokeTransparency = 0.6
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextColor3 = Color3.new(0, 255, 0);
    TextLabel.Size = UDim2.new(0, 200, 0, 50);
    TextLabel.TextScaled = false
    TextLabel.TextSize = 15
    TextLabel.Text = format("%s (%s)", Tag.Name, Tag.Tag);

    if (Tag.Rainbow) then
        Utils.Rainbow(TextLabel)
    end
    if (Tag.Colour) then
        local TColour = Tag.Colour
        TextLabel.TextColor3 = Color3.fromRGB(TColour[1], TColour[2], TColour[3]);
    end

    local Added = CConnect(Tag.Player.CharacterAdded, function()
        Billboard.Adornee = WaitForChild(Tag.Player.Character, "Head");
    end)

    AddConnection(Added)

    AddConnection(CConnect(Players.PlayerRemoving, function(plr)
        if (plr == Tag.Player) then
            Disconnect(Added);
            Destroy(Billboard);
        end
    end))
end

Utils.TextFont = function(Text, RGB)
    RGB = concat(RGB, ",")
    local New = {}
    gsub(Text, ".", function(x)
        New[#New + 1] = x
    end)
    return concat(map(New, function(i, letter)
        return format('<font color="rgb(%s)">%s</font>', RGB, letter)
    end)) .. " "
end
--END IMPORT [utils]



-- commands table
local CommandsTable = {}
local RespawnTimes = {}

local HasTool = function(plr)
    plr = plr or LocalPlayer
    local CharChildren, BackpackChildren = GetChildren(GetCharacter(plr)), GetChildren(plr.Backpack);
    local ToolFound = false
    for i, v in next, tbl_concat(CharChildren, BackpackChildren) do
        if (IsA(v, "Tool")) then
            ToolFound = true
        end
    end
    return ToolFound
end
PluginLibrary.HasTool = HasTool

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

local DisableAnimate = function()
    local Animate = GetCharacter().Animate
    Animate = IsA(Animate, "LocalScript") and Animate or nil
    if (Animate) then
        SpoofProperty(Animate, "Disabled");
        Animate.Disabled = true
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

local AddCommand = function(name, aliases, description, options, func)
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
        ArgsNeeded = (function()
            local sorted = filter(options, function(i,v)
                return type(v) == "string"
            end)
            return tonumber(sorted and sorted[1]);
        end)() or 0,
        Args = (function()
            local sorted = filter(options, function(i, v)
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

local LoadCommand = function(name)
    local Command = rawget(CommandsTable, name);
    if (Command) then
        return Command
    end
end

local ReplaceHumanoid = function(Hum)
    local Humanoid = Hum or GetHumanoid();
    local NewHumanoid = Clone(Humanoid);
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

local AddPlayerConnection = function(Player, Connection, Tbl)
    if (Tbl) then
        Tbl[#Tbl + 1] = Connection
    else
        Connections.Players[Player.Name].Connections[#Connections.Players[Player.Name].Connections + 1] = Connection
    end
    return Connection
end

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

local DisableAllCmdConnections = function(Cmd)
    local Command = LoadCommand(Cmd)
    if (Command and Command.CmdExtra) then
        for i, v in next, flat(Command.CmdExtra) do
            if (type(v) == 'userdata' and v.Disconnect) then
                Disconnect(v);
            end
        end
    end
    return Command
end

local Keys = {}

AddConnection(CConnect(Services.UserInputService.InputBegan, function(Input, GameProccesed)
    if (GameProccesed) then return end
    local KeyCode = split(tostring(Input.KeyCode), ".")[3]
    Keys[KeyCode] = true
end));

AddConnection(CConnect(Services.UserInputService.InputEnded, function(Input, GameProccesed)
    if (GameProccesed) then return end
    local KeyCode = split(tostring(Input.KeyCode), ".")[3]
    if (Keys[KeyCode]) then
        Keys[KeyCode] = false
    end
end));

--IMPORT [plugin]
local IsSupportedExploit = isfile and isfolder and writefile and readfile
local PluginConf = IsSupportedExploit and GetPluginConfig();
local IsDebug = IsSupportedExploit and PluginConf.PluginDebug

local LoadPlugin = function(Plugin)
    if (not IsSupportedExploit) then
        return 
    end
    if (Plugin and PluginConf.DisabledPlugins[Plugin.Name]) then
        return Utils.Notify(LocalPlayer, "Plugin not loaded.", format("Plugin %s was not loaded as it is on the disabled list.", Plugin.Name));
    end
    if (#keys(Plugin) < 3) then
        return IsDebug and Utils.Notify(LocalPlayer, "Plugin Fail", "One of your plugins is missing information.") or nil
    end
    if (IsDebug) then
        Utils.Notify(LocalPlayer, "Plugin loading", format("Plugin %s is being loaded.", Plugin.Name));
    end

    local Ran, Return = pcall(Plugin.Init);
    if (not Ran and Return and IsDebug) then
        return Utils.Notify(LocalPlayer, "Plugin Fail", format("there is an error in plugin Init %s: %s", Plugin.Name, Return));
    end
    
    for i, command in next, Plugin.Commands or {} do -- adding the "or" because some people might have outdated plugins in the dir
        if (#keys(command) < 3) then
            Utils.Notify(LocalPlayer, "Plugin Command Fail", format("Command %s is missing information", command.Name));
            continue
        end
        AddCommand(command.Name, command.Aliases or {}, command.Description .. " - " .. Plugin.Author, command.Requirements or {}, command.Func);

        if (FindFirstChild(Commands.Frame.List, command.Name)) then
            Destroy(FindFirstChild(Commands.Frame.List, command.Name));
        end
        local Clone = Clone(Command);
        Utils.Hover(Clone, "BackgroundColor3");
        Utils.ToolTip(Clone, command.Name .. "\n" .. command.Description .. " - " .. Plugin.Author);
        Clone.CommandText.RichText = true
        Clone.CommandText.Text = format("%s %s %s", command.Name, next(command.Aliases or {}) and format("(%s)", concat(command.Aliases, ", ")) or "", Utils.TextFont("[PLUGIN]", {77, 255, 255}));
        Clone.Name = command.Name
        Clone.Visible = true
        Clone.Parent = Commands.Frame.List
        if (IsDebug) then
            Utils.Notify(LocalPlayer, "Plugin Command Loaded", format("Command %s loaded successfully", command.Name));
        end
    end
end

if (IsSupportedExploit) then
    if (not isfolder("fates-admin") and not isfolder("fates-admin/plugins") and not isfolder("fates-admin/plugin-conf.json") or not isfolder("fates-admin/chatlogs")) then
        WriteConfig();
    end
end

local Plugins = IsSupportedExploit and map(filter(listfiles("fates-admin/plugins"), function(i, v)
    return lower(split(v, ".")[#split(v, ".")]) == "lua"
end), function(i, v)
    return {split(v, "\\")[2], loadfile(v)}
end) or {}

for i, Plugin in next, Plugins do
    LoadPlugin(Plugin[2]());
end

AddCommand("refreshplugins", {"rfp", "refresh", "reload"}, "Loads all new plugins.", {}, function()
    if (not IsSupportedExploit) then
        return "your exploit does not support plugins"
    end
    PluginConf = GetPluginConfig();
    IsDebug = PluginConf.PluginDebug
    
    Plugins = map(filter(listfiles("fates-admin/plugins"), function(i, v)
        return lower(split(v, ".")[#split(v, ".")]) == "lua"
    end), function(i, v)
        return {split(v, "\\")[2], loadfile(v)}
    end)
    
    for i, Plugin in next, Plugins do
        LoadPlugin(Plugin[2]());
    end
end)
--END IMPORT [plugin]


AddCommand("commandcount", {"cc"}, "shows you how many commands there is in fates admin", {}, function(Caller)
    Utils.Notify(Caller, "Amount of Commands", format("There are currently %s commands.", #filter(CommandsTable, function(i,v)
        return indexOf(CommandsTable, v) == i
    end)))
end)

AddCommand("walkspeed", {"ws"}, "changes your walkspeed to the second argument", {}, function(Caller, Args, Tbl)
    local Humanoid = GetHumanoid();
    Tbl[1] = Humanoid.WalkSpeed
    SpoofProperty(Humanoid, "WalkSpeed");
    Humanoid.WalkSpeed = Args[1] or 16
    return "your walkspeed is now " .. Humanoid.WalkSpeed
end)

AddCommand("jumppower", {"jp"}, "changes your jumpower to the second argument", {}, function(Caller, Args, Tbl)
    local Humanoid = GetHumanoid();
    Tbl[1] = Humanoid.JumpPower
    SpoofProperty(Humanoid, "JumpPower");
    Humanoid.JumpPower = Args[1] or 50
    return "your jumppower is now " .. Humanoid.JumpPower
end)

AddCommand("hipheight", {"hh"}, "changes your hipheight to the second argument", {}, function(Caller, Args, Tbl)
    local Humanoid = GetHumanoid();
    Tbl[1] = Humanoid.HipHeight
    SpoofProperty(Humanoid, "HipHeight");
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
            Destroy(LocalPlayer.Character);
            CWait(LocalPlayer.CharacterAdded);
            WaitForChild(LocalPlayer.Character, "Humanoid");
            wait();
            Humanoid = ReplaceHumanoid();
        end
    end
    DisableAnimate();
    coroutine.wrap(function()
        for i, v in next, Target do
            if (GetCharacter(v)) then
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

                local Tool = FindFirstChildWhichIsA(LocalPlayer.Backpack, "Tool") or FindFirstChildWhichIsA(GetCharacter(), "Tool");
                if (not Tool) then
                    continue
                end
                ProtectInstance(Tool);
                SpoofProperty(Tool.Handle, "Size");
                Tool.Parent = GetCharacter();
                if (not FindFirstChild(Tool, "Handle")) then
                    continue
                end
                Tool.Handle.Size = Vector3New(4, 4, 4);
                for i2, v2 in next, GetDescendants(Tool) do
                    if (IsA(v2, "Sound")) then
                        Destroy(v2);
                    end
                end

                pcall(function()
                    CFrameTool(Tool, TargetRoot.CFrame * CFrameNew(0, 3, 0));
                    firetouchinterest(TargetRoot, Tool.Handle, 0);
                    wait();
                    if (FindFirstChild(Tool, "Handle")) then
                        firetouchinterest(TargetRoot, Tool.Handle, 1);
                    end
                end)
            else
                Utils.Notify(Caller or LocalPlayer, "Fail", v.Name .. " is dead or does not have a root part, could not kill.");
            end
        end
    end)()
    ChangeState(Humanoid, 15);
    wait(.3);
    Destroy(LocalPlayer.Character);
    CWait(LocalPlayer.CharacterAdded);
    WaitForChild(LocalPlayer.Character, "HumanoidRootPart").CFrame = OldPos
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

    DisableAnimate();
    local Destroy_;
    coroutine.wrap(function()
        for i = 1, #Target do
            local v = Target[i]
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
                local Tool = FindFirstChildWhichIsA(LocalPlayer.Backpack, "Tool") or FindFirstChildWhichIsA(GetCharacter(), "Tool");
                if (not Tool) then
                    continue
                end
                if (not FindFirstChild(Tool, "Handle")) then
                    continue
                end
                SpoofInstance(Tool);
                Tool.Parent = GetCharacter();
                Tool.Handle.Size = Vector3New(4, 4, 4);
                CFrameTool(Tool, GetRoot(v).CFrame * CFrameNew(0, 6, 0));
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

AddCommand("loopkill", {}, "loopkill loopkills a character", {3,"1"}, function(Caller, Args, Tbl)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        Tbl[#Tbl + 1] = v
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
    until not next(LoadCommand("loopkill").CmdExtra) or not GetPlayer(Args[1])
end)

AddCommand("unloopkill", {"unlkill"}, "unloopkills a user", {3,"1"}, function(Caller, Args)
    LoadCommand("loopkill").CmdExtra = {}
    return "loopkill disabled"
end)

AddCommand("bring", {}, "brings a user", {1}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
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
        for i = 1, #Target do
            local v = Target[i]
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
                
                local Tool = FindFirstChildWhichIsA(LocalPlayer.Backpack, "Tool") or FindFirstChildWhichIsA(GetCharacter(), "Tool");
                if (not Tool) then
                    continue
                end
                SpoofInstance(Tool);
                if (not FindFirstChild(Tool, "Handle")) then
                    continue
                end
                Tool.Parent = GetCharacter();
                Tool.Handle.Size = Vector3New(4, 4, 4);
                for i2, v2 in next, GetDescendants(Tool) do
                    if (IsA(v2, "Sound")) then
                        Destroy(v2);
                    end
                end
                for i2 = 1, 3 do
                    if (TargetRoot) then
                        firetouchinterest(TargetRoot, Tool.Handle, 0);
                        wait();
                        if (not FindFirstChild(Tool, "Handle")) then
                            continue
                        end
                        firetouchinterest(TargetRoot, Tool.Handle, 1);
                        CFrameTool(Tool, OldPos * CFrameNew(-5, 0, 0));
                    end
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
    local TempRespawnTimes = {}
    for i, v in next, Target do
        TempRespawnTimes[v.Name] = RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name]
    end
    local Humanoid = FindFirstChildWhichIsA(GetCharacter(), "Humanoid");
    ReplaceCharacter();
    wait(Players.RespawnTime - (#Target == 1 and .01 or .3));
    local OldPos = GetRoot().CFrame
    DisableAnimate();
    Humanoid2 = ReplaceHumanoid(Humanoid);
    for i, v in next, Target do
        if (#Target == 1 and TempRespawnTimes[v.Name] and isR6(v)) then
            CWait(LocalPlayer.CharacterAdded);
            WaitForChild(LocalPlayer.Character, "HumanoidRootPart").CFrame = OldPos
            wait(.1);
            Humanoid2 = ReplaceHumanoid();
        end
    end
    local Destroy_;
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
                            Destroy_ = true
                        else
                            do break end
                        end
                    end

                    local TargetRoot = GetRoot(v);
                    local Tool = FindFirstChildWhichIsA(LocalPlayer.Backpack, "Tool") or FindFirstChildWhichIsA(GetCharacter(), "Tool");
                    if (not Tool) then
                        do break end
                    end
                    SpoofInstance(Tool);
                    Tool.Parent = GetCharacter();
                    if (not FindFirstChild(Tool, "Handle")) then
                        continue
                    end
                    Tool.Handle.Size = Vector3New(4, 4, 4);
                    CFrameTool(Tool, OldPos * CFrameNew(-5, 0, 0));
                    firetouchinterest(TargetRoot, Tool.Handle, 0);
                    wait();
                    if (not FindFirstChild(Tool, "Handle")) then
                        continue
                    end
                    firetouchinterest(TargetRoot, Tool.Handle, 1);
                else
                    Utils.Notify(Caller or LocalPlayer, "Fail", v.Name .. " is dead or does not have a root part, could not bring.");
                end
            until true
        end
    end)()
    if (Destroy_) then
        wait(.2);
        Destroy(LocalPlayer.Character);
    end
    CWait(LocalPlayer.CharacterAdded);
    WaitForChild(LocalPlayer.Character, "HumanoidRootPart").CFrame = OldPos
end)

AddCommand("void", {"punish"}, "voids a player", {"1",1,3}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local TempRespawnTimes = {}
    for i, v in next, Target do
        TempRespawnTimes[v.Name] = RespawnTimes[LocalPlayer.Name] <= RespawnTimes[v.Name]
    end
    local Humanoid = FindFirstChildWhichIsA(GetCharacter(), "Humanoid");
    ReplaceCharacter();
    wait(Players.RespawnTime - (#Target == 1 and .01 or .3));
    local OldPos = GetRoot().CFrame
    DisableAnimate();
    Humanoid2 = ReplaceHumanoid(Humanoid);
    for i, v in next, Target do
        if (#Target == 1 and TempRespawnTimes[v.Name] and isR6(v)) then
            CWait(LocalPlayer.CharacterAdded);
            WaitForChild(LocalPlayer.Character, "HumanoidRootPart").CFrame = OldPos
            wait(.1);
            Humanoid2 = ReplaceHumanoid();
        end
    end
    local Destroy_;
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
                            Destroy_ = true
                        else
                            do break end
                        end
                    end

                    local TargetRoot = GetRoot(v);
                    local Tool = FindFirstChildWhichIsA(LocalPlayer.Backpack, "Tool") or FindFirstChildWhichIsA(GetCharacter(), "Tool");
                    if (not Tool) then
                        do break end
                    end
                    SpoofInstance(Tool);
                    Tool.Parent = GetCharacter();
                    Tool.Handle.Size = Vector3New(4, 4, 4);
                    if (not FindFirstChild(Tool, "Handle")) then
                        continue
                    end
                    firetouchinterest(TargetRoot, Tool.Handle, 0);
                    wait();
                    if (not FindFirstChild(Tool, "Handle")) then
                        continue
                    end
                    firetouchinterest(TargetRoot, Tool.Handle, 1);
                    GetRoot().CFrame = CFrameNew(0, 9e9, 0);
                else
                    Utils.Notify(Caller or LocalPlayer, "Fail", v.Name .. " is dead or does not have a root part, could not void.");
                end
            until true
        end
    end)();
    if (Destroy_) then
        wait(.2);
        Destroy(LocalPlayer.Character);
    end
    CWait(LocalPlayer.CharacterAdded);
    WaitForChild(LocalPlayer.Character, "HumanoidRootPart").CFrame = OldPos
end)

AddCommand("view", {"v"}, "views a user", {3,"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        Camera.CameraSubject = GetHumanoid(v) or GetHumanoid();
    end
end)

AddCommand("unview", {"unv"}, "unviews a user", {3}, function(Caller, Args)
    Camera.CameraSubject = GetHumanoid();
    return "unviewing"
end)

AddCommand("loopview", {}, "loopviews a user", {3, "1"}, function(Caller, Args, Tbl)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        Camera.CameraSubject = GetHumanoid(v) or GetHumanoid();
        local LoopView = CConnect(GetPropertyChangedSignal(Camera, "CameraSubject"), function()
            Camera.CameraSubject = GetHumanoid(v) or GetHumanoid();
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
                Disconnect(v);
            end
        end
    end
end)

AddCommand("invisble", {"invis"}, "makes yourself invisible", {}, function()
    local OldPos = GetRoot().CFrame
    GetRoot().CFrame = CFrameNew(9e9, 9e9, 9e9);
    local Clone = Clone(GetRoot());
    wait(.2);
    Destroy(GetRoot());
    Clone.CFrame = OldPos
    Clone.Parent = GetCharacter();
    return "you are now invisible"
end)

AddCommand("dupetools", {"dp"}, "dupes your tools", {"1", 1, {"protect"}}, function(Caller, Args, Tbl)
    local Amount = tonumber(Args[1])
    local Protected = Args[2] == "protect"
    if (not Amount) then
        return "amount must be a number"
    end

    UnequipTools(GetHumanoid());
    local ToolAmount = #filter(GetChildren(LocalPlayer.Backpack), function(i, v)
        return IsA(v, "Tool");
    end)
    local Duped = {}
    Tbl[1] = true
    for i = 1, Amount do
        if (not LoadCommand("dupetools").CmdExtra[1]) then
            do break end;
        end
        UnequipTools(GetHumanoid());
        ReplaceCharacter();
        local OldPos
        if (Protected) then
            local OldFallen = Services.Workspace.FallenPartsDestroyHeight
            delay(Services.Players.RespawnTime - .3, function()
                Services.Workspace.FallenPartsDestroyHeight = -math.huge
                OldPos = GetRoot().CFrame
                SpoofProperty(GetRoot(), "Anchored");
                GetRoot().CFrame = CFrameNew(0, 1e9, 0);
                GetRoot().Anchored = true
            end)
        end
        wait(Players.RespawnTime - .05); --todo: add the amount of tools divided by 100 or something like that
        OldPos = OldPos or GetRoot().CFrame
        ReplaceHumanoid(Humanoid);

        local Tools = filter(GetChildren(LocalPlayer.Backpack), function(i, v)
            return IsA(v, "Tool");
        end)

        for i2, v in next, Tools do
            v.Parent = LocalPlayer.Character
            v.Parent = Services.Workspace
            Duped[#Duped + 1] = v
        end
        CWait(LocalPlayer.CharacterAdded);
        WaitForChild(LocalPlayer.Character, "HumanoidRootPart").CFrame = OldPos;

        for i2, v in next, Duped do
            if (v.Handle) then
                firetouchinterest(v.Handle, GetRoot(), 0);
                firetouchinterest(v.Handle, GetRoot(), 1);
            end
        end
        repeat wait()
            FindFirstChild(LocalPlayer.Character, "HumanoidRootPart").CFrame = OldPos
        until GetRoot().CFrame == OldPos
        wait(.4);
        UnequipTools(GetHumanoid());
    end
    return format("successfully duped %d tool (s)", #GetChildren(LocalPlayer.Backpack) - ToolAmount);
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

AddCommand("givetools", {}, "gives tools to a player", {"1", 3, 1}, function(Caller, Args) -- i am not re doing this
    local Target = GetPlayer(Args[1]);
    local OldPos = GetRoot().CFrame
    local Humanoid = FindFirstChildOfClass(LocalPlayer.Character, "Humanoid");
    Humanoid.Name = "1"
    local Humanoid2 = Clone(Humanoid);
    Humanoid2.Parent = LocalPlayer.Character
    Humanoid2.Name = "Humanoid"
    Services.Workspace.Camera.CameraSubject = Humanoid2
    wait()
    Destroy(Humanoid);
    for _, v in next, GetChildren(LocalPlayer) do
        if (IsA(v, "Tool")) then
            v.Parent = LocalPlayer.Backpack
        end
    end
    ChangeState(Humanoid2, 15);
    for i, v in next, Target do
        local THumanoidRootPart = GetRoot(v);
        for i2, v2 in next, GetChildren(LocalPlayer.Backpack) do
            if (IsA(v2, "Tool")) then
                v2.Parent = GetCharacter();
                for i3 = 1, 3 do
                    if (THumanoidRootPart) then
                        firetouchinterest(THumanoidRootPart, v2.Handle, 0);
                        firetouchinterest(THumanoidRootPart, v2.Handle, 1);
                    end
                end
            end
        end
    end
    wait(.2);
    Destroy(LocalPlayer.Character);
    CWait(LocalPlayer.CharacterAdded);
    WaitForChild(LocalPlayer.Character, "HumanoidRootPart").CFrame = OldPos
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

AddCommand("autograbtools", {"agt", "loopgrabtools", "lgt"}, "once a tool is added to workspace it will be grabbed", {3}, function(Caller, Args, Tbl)
    AddConnection(CConnect(Services.Workspace.ChildAdded, function(Child)
        if (IsA(Child, "Tool") and FindFirstChild(Child, "Handle")) then
            firetouchinterest(Child.Handle, GetRoot(), 0);
            wait();
            firetouchinterest(Child.Handle, GetRoot(), 1);
            UnequipTools(GetHumanoid());
        end
    end), Tbl)
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
    local HatAmount = #GetAccessories(GetHumanoid);
    for i, v in next, GetAccessories(GetHumanoid) do
        Destroy(v);
    end
    return format(("removed %d hat (s)"), HatAmount - #GetAccessories(GetHumanoid));
end)

AddCommand("clearhats", {"ch"}, "clears all of the hats in workspace", {3}, function()
    for i, v in next, GetAccessories(GetHumanoid) do
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
    local MuteRequest = ReplicatedStorage.DefaultChatSystemChatEvents.MutePlayerRequest
    for i, v in next, Target do
        MuteRequest.InvokeServer(MuteRequest, v.Name);
        Utils.Notify(Caller, "Command", format("%s is now muted on your chat", v.Name));
    end
end)

AddCommand("unchatmute", {"uncmute"}, "unmutes a player in your chat", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local MuteRequest = ReplicatedStorage.DefaultChatSystemChatEvents.UnMutePlayerRequest
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

AddCommand("loopdelete", {"ld"}, "loop of delete command", {"1"}, function(Caller, Args, Tbl)
    local Target = GetPlayer(Args[1]);
    for i, v in next, Target do
        if (v.Character) then
            SpoofProperty(v.Character, "Parent");
            v.Character.Parent = Lighting
        end
        local Connection = CConnect(v.CharacterAdded, function()
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
        loadstring(format("%s\nprint(%s);\n%s", "local oldprint=print print=function(...)getgenv().F_A.Utils.Notify(game.Players.LocalPlayer,'Command',table.concat({...},' '))return oldprint(...)end", Code, "print = oldprint"))();
    end)
    if (not Success and Err) then
        return Err
    else
        return "executed with no errors"
    end
end)

AddCommand("sit", {}, "makes you sit", {3}, function(Caller, Args, Tbl)
    SpoofProperty(GetHumanoid(), "Sit", false);
    GetHumanoid().Sit = true
    return "now sitting (obviously)"
end)

AddCommand("infinitejump", {"infjump"}, "infinite jump no cooldown", {3}, function(Caller, Args, Tbl)
    AddConnection(CConnect(Services.UserInputService.JumpRequest, function()
        local Humanoid = GetHumanoid();
        if (Humanoid) then
            SpoofInstance(Humanoid);
            ChangeState(Humanoid, 3);
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
        local Humanoid = GetHumanoid();
        SpoofProperty(Humanoid, "Sit");
        Humanoid.Sit = true
        AddConnection(CConnect(GetPropertyChangedSignal(Humanoid, "Sit"), function()
            Humanoid.Sit = true
        end), Tbl);
        local Root = GetRoot();
        AddConnection(CConnect(Heartbeat, function()
            Root.CFrame = v.Character.Head.CFrame * CFrameNew(0, 0, 1);
        end), Tbl);
    end
end)

AddCommand("unheadsit", {"noheadsit"}, "unheadsits on the target", {3}, function(Caller, Args)
    local Looped = LoadCommand("headsit").CmdExtra
    for i, v in next, Looped do
        Disconnect(v);
    end
    return "headsit disabled"
end)

AddCommand("headstand", {"hstand"}, "stands on a players head", {"1",3}, function(Caller, Args, Tbl)
    local Target = GetPlayer(Args[1]);
    local Root = GetRoot();
    for i, v in next, Target do
        local Loop = CConnect(Heartbeat, function()
            Root.CFrame = v.Character.Head.CFrame * CFrameNew(0, 1, 0);
        end)
        Tbl[v.Name] = Loop
        AddPlayerConnection(v, Loop);
    end
end)

AddCommand("unheadstand", {"noheadstand"}, "unheadstands on the target", {3}, function(Caller, Args)
    local Looped = LoadCommand("headstand").CmdExtra
    for i, v in next, Looped do
        Disconnect(v);
    end
    return "headstand disabled"
end)

AddCommand("setspawn", {}, "sets your spawn location to the location you are at", {3}, function(Caller, Args, Tbl)
    if (Tbl[1]) then
        Disconnect(Tbl[1]);
    end
    local Position = GetRoot().CFrame
    local Spawn = CConnect(LocalPlayer.CharacterAdded, function()
        WaitForChild(LocalPlayer.Character, "HumanoidRootPart").CFrame = Position
    end)
    Tbl[1] = Spawn
    AddPlayerConnection(LocalPlayer, Spawn);
    local SpawnLocation = pack(unpack(split(tostring(Position), ", "), 1, 3));
    SpawnLocation.n = nil
    return "spawn successfully set to " .. concat(map(SpawnLocation, function(i,v)
        return tostring(round(tonumber(v)));
    end), ",");
end)

AddCommand("removespawn", {}, "removes your spawn location", {}, function(Caller, Args)
    local Spawn = LoadCommand("setspawn").CmdExtra[1]
    if (Spawn) then
        Disconnect(Spawn);
        return "removed spawn location"
    end
    return "you don't have a spawn location set"
end)

AddCommand("ping", {}, "shows you your ping", {}, function()
    local DataPing = Stats.Network.ServerStatsItem["Data Ping"]
    return split(DataPing.GetValueString(DataPing), " ")[1] .. "ms"
end)

AddCommand("memory", {"mem"}, "shows you your memory usage", {}, function()
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
    Running = CConnect(Heartbeat, fpsget);
end)

AddCommand("displaynames", {}, "enables/disables display names (on/off)", {{"on","off"}}, function(Caller, Args, Tbl)
    local Option = Args[1]
    local ShowName = function(v)
        if (v.Name ~= v.DisplayName) then
            if (v.Character) then
                v.Character.Humanoid.DisplayName = v.Name
            end
            local Connection = CConnect(CharacterAdded, function()
                WaitForChild(v.Character, "Humanoid").DisplayName = v.Name
            end)
            Tbl[v.Name] = {v.DisplayName, Connection}
            AddPlayerConnection(v, Connection);
        end
    end
    if (lower(Option) == "off") then
        for i, v in next, GetPlayers(Players) do
            ShowName(v)
        end
        AddConnection(CConnect(Players.PlayerAdded, ShowName));
        return "people with a displayname displaynames will be shown"
    elseif (lower(Option) == "on") then
        for i, v in next, LoadCommand("displaynames").CmdExtra do
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
    local Time = Args[1] and lower(Args[1]) or 14
    local Times = {["night"]=0,["day"]=14,["dawn"]=6}
    SpoofProperty(Lighting, "ClockTime");
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
        if not (Tfind(Tools, x)) then
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
        coroutine.wrap(function()
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

AddCommand("reach", {"swordreach"}, "changes handle size of your tool", {1, 3}, function(Caller, Args, Tbl)
    local Amount = Args[1] or 2
    local Tool = FindFirstChildWhichIsA(LocalPlayer.Character, "Tool") or FindFirstChildWhichIsA(LocalPlayer.Backpack, "Tool");
    Tbl[Tool] = Tool.Size
    SpoofProperty(Tool.Handle, "Size");
    SpoofProperty(Tool.Handle, "Massless");
    Tool.Handle.Size = Vector3New(Tool.Handle.Size.X, Tool.Handle.Size.Y, tonumber(Amount or 30));
    Tool.Handle.Massless = true
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
    local Tool = FindFirstChildWhichIsA(GetCharacter(), "Tool") or FindFirstChildWhichIsA(LocalPlayer.Backpack, "Tool");
    local PlayersTbl = filter(GetPlayers(Players), function(i, v)
        return v ~= LocalPlayer
    end)

    AddConnection(CConnect(Heartbeat, function()
        Tool = FindFirstChildWhichIsA(GetCharacter(), "Tool") or FindFirstChildWhichIsA(LocalPlayer.Backpack, "Tool");
        if (Tool and Tool.Handle) then
            for i, v in next, PlayersTbl do
                if (GetRoot(v) and GetHumanoid(v) and GetHumanoid(v).Health ~= 0 and GetMagnitude(v) <= SwordDistance) then
                    if (GetHumanoid().Health ~= 0) then
                        Tool.Parent = GetCharacter();
                        local BaseParts = filter(GetChildren(GetCharacter(v)), function(i, v)
                            return IsA(v, "BasePart");
                        end)
                        forEach(BaseParts, function(i, v)
                            Tool.Activate(Tool);
                            firetouchinterest(Tool.Handle, v, 0);
                            wait();
                            firetouchinterest(Tool.Handle, v, 1);
                        end)
                    end
                end
            end
        end
    end), Tbl);

    AddConnection(CConnect(Players.PlayerAdded, function(Plr)
        PlayersTbl[#PlayersTbl + 1] = Plr
    end), Tbl);
    AddConnection(CConnect(Players.PlayerRemoving, function(Plr)
        remove(PlayersTbl, indexOf(PlayersTbl, Plr))
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
    local BaseParts = filter(GetChildren(GetCharacter(v)), function(i, v)
        return IsA(v, "BasePart");
    end)
    for i, v in next, BaseParts do
        SpoofProperty(v, "Anchored");
        v.Anchored = true
    end
    return "freeze enabled (client)"
end)

AddCommand("unfreeze", {}, "unfreezes your character", {3}, function(Caller, Args)
    local BaseParts = filter(GetChildren(GetCharacter(v)), function(i, v)
        return IsA(v, "BasePart");
    end)
    for i, v in next, BaseParts do
        v.Anchored = false
    end
    return "freeze disabled"
end)

AddCommand("streamermode", {}, "changes names of everyone to something random", {}, function(Caller, Args, Tbl)
    local Rand = function(len) return gsub(sub(GenerateGUID(Services.HttpService), 2, len), "-", "") end
    local Hide = function(a, v)
        if (v and IsA(v, "TextLabel") or IsA(v, "TextButton")) then
            local Player = GetPlayer(v.Text, true);
            if (not Player[1]) then
                Player = GetPlayer(sub(v.Text, 2, #v.Text - 2), true);
            end
            v.Text = Player[1] and Player[1].Name or v.Text
            if (Player and FindFirstChild(Players, v.Text)) then
                Tbl[v.Name] = v.Text
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
    end), Tbl);
    return "streamer mode enabled"
end)

AddCommand("nostreamermode", {"unstreamermode"}, "removes all the changed names", {}, function(Caller, Args, Tbl)
    local changed = LoadCommand("streamermode").CmdExtra
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

AddCommand("loopmuteboombox", {"loopmute"}, "loop mutes a users boombox", {}, function(Caller, Args, Tbl)
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
                for i, v2 in next, GetDescendants(Char) do
                    if (IsA(v2, "Sound")) then
                        v2.Playing = false
                    end
                end
            end
        end
    end));
    Tbl[Target] = Con
end)

AddCommand("unloopmuteboombox", {}, "unloopmutes a persons boombox", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1])
    local Muting = LoadCommand("loopmuteboombox").CmdExtra
    for i, v in next, Muting do
        for i2, v2 in next, Target do
            if (v2 == i) then
                v:Disconnect();
                Muting[i] = nil
            end
        end
    end
end)

AddCommand("forceplay", {}, "forcesplays an audio", {1,3,"1"}, function(Caller, Args, Tbl)
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
    Tbl[Boombox] = true
    coroutine.wrap(function()
        while (LoadCommand("forceplay").CmdExtra[Boombox]) do
            Boombox.Handle.Sound.Playing = true
            CWait(RunService.Heartbeat);
        end
        Services.SoundService.RespectFilteringEnabled = true
    end)()
    return "now forceplaying ".. Id
end)

AddCommand("unforceplay", {}, "stops forceplay", {}, function()
    local Playing = LoadCommand("forceplay").CmdExtra
    for i, v in next, Playing do
        FindFirstChild(i, "Sound", true).Playing = false
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
        return IsA(v, "Tool") and FindFirstChild(v, "Handle") and FindFirstChildWhichIsA(v.Handle, "Sound") and FindFirstChildWhichIsA(v.Handle, "Sound").Playing == true
    end
    local OtherPlayingBoomboxes = LoadCommand("forceplay").CmdExtra
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

AddCommand("grippos", {}, "changes grippos of your tool", {"3"}, function(Caller, Args, Tbl)
    local Tool = FindFirstChildWhichIsA(GetCharacter(), "Tool") or FindFirstChildWhichIsA(LocalPlayer.Backpack, "Tool");
    SpoofProperty(Tool, "GripPos");
    Tool.GripPos = Vector3New(tonumber(Args[1]), tonumber(Args[2]), tonumber(Args[3]));
    Tool.Parent = GetCharacter();
    return "grippos set"
end)

AddCommand("truesightguis", {"tsg"}, "true sight on all guis", {}, function(Caller, Args, Tbl)
    for i, v in next, GetDescendants(game) do
        if (IsA(v, "Frame") or IsA(v, "ScrollingFrame") and not v.Visible) then
            Tbl[v] = v.Visible
            SpoofProperty(v, "Visible");
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

AddCommand("esp", {"aimbot", "cameralock", "locate", "silentaim", "aimlock", "tracers", "trace"}, "loads fates esp", {}, function(Caller, Args, Tbl)
    loadstring(game.HttpGet(game, "https://raw.githubusercontent.com/fatesc/fates-esp/main/main.lua"))();
    return "esp enabled"
end)


AddCommand("crosshair", {}, "enables a crosshair", {function()
    return Drawing ~= nil
end}, function(Caller, Args, Tbl)
    if (Tbl[1] and Tbl[2] and Tbl[1].Transparency ~= 0) then
        Tbl[1].Remove(Tbl[1]);
        Tbl[2].Remove(Tbl[2]);
        Tbl[1] = nil
        Tbl[2] = nil
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
    Tbl[1] = Y
    Tbl[2] = X
    return "crosshair enabled"
end)

AddCommand("walkto", {}, "walks to a player", {"1", 3}, function(Caller, Args)
    local Target = GetPlayer(Args[1])[1];
    MoveTo(GetHumanoid(), GetRoot(Target).Position);
    return "walking to " .. Target.Name
end)

AddCommand("follow", {}, "follows a player", {"1", 3}, function(Caller, Args, Tbl)
    local Target = GetPlayer(Args[1])[1]
    Tbl[Target.Name] = true
    coroutine.wrap(function()
        repeat
            MoveTo(GetHumanoid(), GetRoot(Target).Position);
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
        Utils.Notify(Caller, "Command", format("%s's age is %s (%s)", v.Name, AccountAge, CreatedAt));
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
    local UserSettings = UserSettings()
    UserSettings.GetService(UserSettings, "UserGameSettings").MasterVolume = Volume / 10
    return "volume set to " .. Volume
end)

AddCommand("antikick", {}, "client sided bypasses to kicks", {}, function()
    AntiKick = not AntiKick
    return "client sided antikick " .. (AntiKick and "enabled" or "disabled")
end)

AddCommand("antiteleport", {}, "client sided bypasses to teleports", {}, function()
    AntiTeleport = not AntiTeleport
    return "client sided antiteleport " .. (AntiTeleport and "enabled" or "disabled")
end)

AddCommand("autorejoin", {}, "auto rejoins the game when you get kicked", {}, function(Caller, Args, Tbl)
    local RejoinConnection = CConnect(FindFirstChildWhichIsA(FindFirstChild(CoreGui, "RobloxPromptGui"), "Frame").DescendantAdded, function(Prompt)
        if (Prompt.Name == "ErrorTitle") then
            CWait(GetPropertyChangedSignal(Prompt, "Text"));
            if (Prompt.Text == "Disconnected") then
                syn.queue_on_teleport("loadstring(game.HttpGet(game, \"https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua\"))()")
                TeleportToPlaceInstance(Services.TeleportService, game.PlaceId, game.JobId);
            end
        end
    end)
    AddConnection(RejoinConnection);
    Tbl[#Tbl + 1] = RejoinConnection
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
        CConnect(Socket.OnMessage, function(msg)
            if (GlobalChatLogsEnabled) then
                msg = JSONDecode(Services.HttpService, msg);
                local Clone = Clone(GlobalChatLogMessage);
                Clone.Text = format("%s - [%s]: %s", msg.fromDiscord and "from discord" or tostring(os.date("%X")), msg.username, msg.message);
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

    if (hookfunction and syn) then
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
    end
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

AddCommand("spin", {}, "spins your character (optional: speed)", {}, function(Caller, Args, Tbl)
    local Speed = Args[1] or 5
    local Spin = InstanceNew("BodyAngularVelocity");
    ProtectInstance(Spin);
    Spin.Parent = GetRoot();
    Spin.MaxTorque = Vector3New(0, math.huge, 0);
    Spin.AngularVelocity = Vector3New(0, Speed, 0);
    Tbl[#Tbl + 1] = Spin
    return "started spinning"
end)

AddCommand("unspin", {}, "unspins your character", {}, function(Caller, Args)
    local Spinning = LoadCommand("spin").CmdExtra
    for i, v in next, Spinning do
        Destroy(v);
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
        GetRoot().CFrame = GetRoot(v).CFrame * CFrameNew(-5, 0, 0);
    end
end)

AddCommand("loopgoto", {"loopto"}, "loop teleports yourself to the other character", {3, "1"}, function(Caller, Args, Tbl)
    local Target = GetPlayer(Args[1])[1]
    local Connection = CConnect(Heartbeat, function()
        GetRoot().CFrame = GetRoot(Target).CFrame * CFrameNew(0, 0, 2);
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
        local Tween = Create(TweenService, GetRoot(), TweenInfo.new(2), {CFrame = GetRoot(v).CFrame})
        Tween.Play(Tween);
    end
end)

AddCommand("truesight", {"ts"}, "shows all the transparent stuff", {}, function(Caller, Args, Tbl)
    local amount = 0
    local time = tick();
    for i, v in next, GetDescendants(Services.Workspace) do
        if (IsA(v, "Part") and v.Transparency >= 0.3) then
            Tbl[v] = v.Transparency
            SpoofProperty(v, "Transparency");
            v.Transparency = 0
            amount = amount + 1
        end
    end

    return format("%d items shown in %.3f (s)", amount, (tick()) - time);
end)

AddCommand("notruesight", {"nots"}, "removes truesight", {}, function(Caller, Args)
    local showing = LoadCommand("truesight").CmdExtra
    local time = tick();
    for i, v in next, showing do
        i.Transparency = v
    end
    return format("%d items hidden in %.3f (s)", #showing, (tick()) - time);
end)

AddCommand("xray", {}, "see through wallks", {}, function(Caller, Args, Tbl)
    for i, v in next, GetDescendants(Services.Workspace) do
        if IsA(v, "Part") and v.Transparency <= 0.3 then
            Tbl[v] = v.Transparency
            SpoofProperty(v, "Transparency");
            v.Transparency = 0.3
        end
    end
    return "xray is now on"
end)

AddCommand("noxray", {"unxray"}, "stops xray", {}, function(Caller, Args)
    local showing = LoadCommand("xray").CmdExtra
    local time = tick();
    for i, v in next, showing do
        i.Transparency = v
    end
    return "xray is now off"
end)

AddCommand("nolights", {}, "removes all lights", {}, function(Caller, Args, Tbl)
    SpoofProperty(Lighting, "GlobalShadows");
    for i, v in next, GetDescendants(game) do
        if (IsA(v, "PointLight") or IsA(v, "SurfaceLight") or IsA(v, "SpotLight")) then
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
    for i, v in next, GetDescendants(game) do
        if (IsA(v, "PointLight") or IsA(v, "SurfaceLight") or IsA(v, "SpotLight")) then
            Tbl[v] = v.Range
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
    local Lights = LoadCommand("fullbright").CmdExtra
    for i, v in next, Lights do
        i.Range = v
    end
    Lighting.GlobalShadows = true
    return "fullbright disabled"
end)

AddCommand("swim", {}, "allows you to use the swim state", {3}, function(Caller, Args, Tbl)
    local Humanoid = GetHumanoid();
    SpoofInstance(Humanoid);
    for i, v in next, Enum.HumanoidStateType.GetEnumItems(Enum.HumanoidStateType) do
        SetStateEnabled(Humanoid, v, false);
    end
    Tbl[1] = GetState(Humanoid);
    ChangeState(Humanoid, Enum.HumanoidStateType.Swimming);
    SpoofProperty(Services.Workspace, "Gravity");
    Services.Workspace.Gravity = 0
    coroutine.wrap(function()
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
    ChangeState(Humanoid, LoadCommand("swim").CmdExtra[1]);
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

AddCommand("fly", {}, "fly your character", {3}, function(Caller, Args, Tbl)
    Tbl[1] = tonumber(Args[1]) or 2
    local Speed = LoadCommand("fly").CmdExtra[1]
    local Root = GetRoot()
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
    end), Tbl)

    local Table1 = { ['W'] = 0; ['A'] = 0; ['S'] = 0; ['D'] = 0 }

    coroutine.wrap(function()
        while (next(LoadCommand("fly").CmdExtra) and wait()) do
            Speed = LoadCommand("fly").CmdExtra[1]
            
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

AddCommand("fly2", {}, "fly your character", {3}, function(Caller, Args, Tbl)
    LoadCommand("fly").CmdExtra[1] = tonumber(Args[1]) or 3
    local Speed = LoadCommand("fly").CmdExtra[1]
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
    coroutine.wrap(function()
        BodyPos.Position = GetRoot().Position
        while (next(LoadCommand("fly").CmdExtra) and wait()) do
            Speed = LoadCommand("fly").CmdExtra[1]
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
    LoadCommand("fly").CmdExtra[1] = Speed or LoadCommand("fly2").CmdExtra[1]
    return Speed and "your fly speed is now " .. Speed or "flyspeed must be a number"
end)

AddCommand("unfly", {}, "unflies your character", {3}, function()
    DisableAllCmdConnections("fly");
    LoadCommand("fly").CmdExtra = {}
    LoadCommand("fly2").CmdExtra = {}
    for i, v in next, GetChildren(GetRoot()) do
        if (IsA(v, "BodyPosition") or IsA(v, "BodyGyro") or IsA(v, "BodyVelocity")) then
            Destroy(v);
        end
    end
    UnSpoofInstance(GetRoot());
    GetHumanoid().PlatformStand = false
    return "stopped flying"
end)

AddCommand("float", {}, "floats your character (uses grass to bypass some ac's)", {}, function(Caller, Args, Tbl)
    if (not Tbl[1]) then
        local Part = InstanceNew("Part");
        Part.CFrame = CFrameNew(0, -10000, 0);
        Part.Size = Vector3New(2, .2, 1.5);
        Part.Material = "Grass"
        ProtectInstance(Part);
        Part.Parent = Services.Workspace
        Part.Anchored = true

        AddConnection(CConnect(RenderStepped, function()
            if (LoadCommand("float").CmdExtra[1] and GetRoot()) then
                Part.CFrame = GetRoot().CFrame * CFrameNew(0, -3.1, 0);
            else
                Part.CFrame = CFrameNew(0, -10000, 0);
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
    SpoofProperty(Camera, "FieldOfView");
    Camera.FieldOfView = Amount
end)

AddCommand("noclip", {}, "noclips your character", {3}, function(Caller, Args, Tbl)
    local Char = GetCharacter()
    local Noclipping = AddConnection(CConnect(Stepped, function()
        for i, v in next, GetChildren(Char) do
            if (IsA(v, "BasePart") and v.CanCollide) then
                SpoofProperty(v, "CanCollide");
                v.CanCollide = false
            end
        end
    end), Tbl);
    local Noclipping2 = AddConnection(CConnect(GetRoot().Touched, function(Part)
        if (Part.CanCollide) then
            local OldTransparency = Part.Transparency
            Part.CanCollide = false
            Part.Transparency = Part.Transparency <= 0.5 and 0.6 or Part.Transparency
            wait(2);
            Part.CanCollide = true
            Part.Transparency = OldTransparency
        end
    end), Tbl);
    Utils.Notify(Caller, "Command", "noclip enabled");
    CWait(GetHumanoid().Died);
    DisableAllCmdConnections("noclip");
    return "noclip disabled"
end)

AddCommand("clip", {}, "disables noclip", {}, function(Caller, Args)
    if (not next(LoadCommand("noclip").CmdExtra)) then
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
    LoadCommand(Command[1]).Function()(Command[2], Command[3], Command[4]);
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

AddCommand("silentchat", {"chatsilent"}, "sends a message but will not show in the chat (fires .Chatted signals)", {"1"}, function(Caller, Args)
    local toChat = concat(Args, " ");
    Services.Players.Chat(Services.Players, toChat);
    return "silent chatted " .. toChat
end)

AddCommand("spamsilentchat", {"spamchatlogs"}, "spams sending messages with what you want", {"1"}, function(Caller, Args, Tbl)
    local toChat = concat(Args, " ");
    local ChatMsg = Services.Players.Chat
    for i = 1, 100 do
        ChatMsg(Services.Players, toChat);
    end
    AddConnection(CConnect(Players.Chatted, function()
        for i = 1, 30 do
            ChatMsg(Players, toChat);
        end
    end), Tbl);
    return "spamming chat sliently"
end)

AddCommand("unspamsilentchat", {"nospamsilentchat", "unspamchatlogs", "nospamchatlogs"}, "stops the spam of chat", {}, function()
    local Spamming = LoadCommand("spamsilentchat").CmdExtra
    if (not next(Spamming)) then
        return "you are not spamming slient chat"
    end
    DisableAllCmdConnections("spamsilentchat");
    return "stopped spamming slient chat"
end)

AddCommand("advertise", {}, "advertises the script", {}, function()
    local ChatRemote = Services.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
    ChatRemote.FireServer(ChatRemote, "I am using fates admin, join the server 5epGRYR", "All");
end)

AddCommand("joinserver", {"discord"}, "joins the fates admin discord server", {}, function()
    local Request = syn and syn.request or request
    if (Request({
        Url = "http://127.0.0.1:6463/rpc?v=1",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Origin"] = "https://discord.com"
        },
        Body = JSONEncode(Services.HttpService, {
            cmd = "INVITE_BROWSER",
            args = {
                code = "5epGRYR"
            },
            nonce = GenerateGUID(Services.HttpService, false)
        }),
    }).StatusCode == 200) then
        return "joined fates admin discord server"
    else
        return "discord isn't open"
    end
end)

AddCommand("rejoin", {"rj"}, "rejoins the game you're currently in", {}, function(Caller)
    if (Caller == LocalPlayer) then
        Services.TeleportService.TeleportToPlaceInstance(Services.TeleportService, game.PlaceId, game.JobId);
        return "Rejoining..."
    end
end)

AddCommand("serverhop", {"sh"}, "switches servers (optional: min or max)", {{"min", "max"}}, function(Caller, Args)
    if (Caller == LocalPlayer) then
        Utils.Notify(Caller or LocalPlayer, nil, "Looking for servers...");

        local Servers = JSONDecode(Services.HttpService, game.HttpGetAsync(game, format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", game.PlaceId))).data
        if (#Servers >= 1) then
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
            if (syn) then
                syn.queue_on_teleport("loadstring(game.HttpGet(game, \"https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua\"))()");
            end
            Services.TeleportService.TeleportToPlaceInstance(Services.TeleportService, game.PlaceId, Server.id);
            return format("joining server (%d/%d players)", Server.playing, Server.maxPlayers);
        else
            return "no servers foudn"
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
            remove(AdminUsers, indexOf(AdminUsers, v));
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
        for i, v in next, SpoofedProperties do
            for i2, v2 in next, v do
                i[v2.Property] = v2.SpoofedProperty[v2.Property]
                Destroy(v2.SpoofedProperty);
            end
        end
        for i, v in next, SpoofedInstances do
            Destroy(v);
        end
        SpoofedInstances = {}
        SpoofedProperties = {}
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
                    local Executed = Command.Function()(LocalPlayer, Args, Command.CmdExtra);
                    if (Executed) then
                        rconsoleprint("@@GREEN@@");
                        rconsoleprint(Executed .. "\n");
                    end
                    if (#LastCommand == 3) then
                        LastCommand = shift(LastCommand);
                    end
                    LastCommand[#LastCommand + 1] = {Command, plr, Args, Command.CmdExtra}
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

AddCommand("chatprediction", {}, "enables command prediction on the chatbar", {}, function()
    ParentGui(PredictionClone, Frame2);
    local ChatBar = WaitForChild(Frame2, 'ChatBar', .1);
    ChatBar.CaptureFocus(ChatBar);
    wait();
    ChatBar.Text = Prefix
    return "chat prediction enabled"
end)

AddCommand("blink", {"blinkws"}, "cframe speed", {}, function(Caller, Args, Tbl)
    local Speed = tonumber(Args[1]) or 5
    local Time = tonumber(Args[2]) or .05
    LoadCommand("blink").CmdExtra[1] = Speed
    coroutine.wrap(function()
        while (next(LoadCommand("blink").CmdExtra) and wait(Time)) do
            Speed = LoadCommand("blink").CmdExtra[1]
            if (Keys["W"] or Keys["A"] or Keys["S"] or Keys["D"]) then
                GetRoot().CFrame = GetRoot().CFrame + GetHumanoid().MoveDirection * Speed
            end
        end
    end)();
    return "blink speed enabled"
end)

AddCommand("unblink", {"noblinkws", "unblink", "noblink"}, "stops cframe speed", {}, function()
    local Blink = LoadCommand("blink").CmdExtra
    if (not next(Blink)) then
        return "blink is already disabled"
    end
    LoadCommand("blink").CmdExtra = {}
    return "blink speed disabled"
end)

AddCommand("orbit", {}, "orbits a yourself around another player", {3, "1"}, function(Caller, Args, Tbl)
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

AddCommand("bypass", {"clientbypass"}, "client sided bypass", {3}, function()
    AddConnection(CConnect(LocalPlayer.CharacterAdded, function()
        WaitForChild(GetCharacter(), "Humanoid");
        wait(.4);
        SpoofInstance(GetHumanoid());
        SpoofInstance(GetRoot(), isR6() and GetCharacter().Torso or GetCharacter().UpperTorso);
        ProtectInstance(GetRoot());
        ProtectInstance(GetHumanoid());
    end));
    local Char = GetCharacter();
    Char.BreakJoints(Char);
    CommandsTable["goto"].Function = CommandsTable["tweento"].Function
    CommandsTable["to"].Function = CommandsTable["tweento"].Function
    return "clientsided bypass enabled"
end)

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

local Activated = false
AddCommand("freecam", {"fc"}, "enables/disables freecam", {}, function(Caller, Args)
    if (not Activated) then
        loadstring(game.HttpGet(game, "https://raw.githubusercontent.com/fatesc/fates-admin/main/src/lua/freecam.lua"))();
        Activated = true
        return "freecam enabled"
    end
    return "freecam is already enabled (shift + p to toggle)";
end)

AddCommand("plastic", {"fpsboost"}, "changes everything to a plastic material", {}, function(Caller, Args, Tbl)
    local time = tick();
    local Plasticc = 0
    for i, v in next, GetDescendants(Workspace) do
        if (IsA(v, "Part") and v.Material ~= Enum.Material.Plastic) then
            Tbl[v] = v.Material
            v.Material = Enum.Material.Plastic
            Plasticc = Plasticc + 1
        end
    end
    return format("%d items made plastic in %.3f (s)", Plasticc, (tick()) - time);    
end)

AddCommand("unplastic", {"unfpsboost"}, "changes everything back from a plastic material", {}, function(Caller, Args, Tbl)
    local Plastics = LoadCommand("plastic").CmdExtra
    local time = tick();
    local Amount = 0
    for i, v in next, Plastics do
        i.Material = v
        Amount = Amount + 1
    end
    return format("removed %d plastic in %.3f (s)", Amount, (tick()) - time);
end)

AddCommand("antiafk", {"antiidle"}, "prevents kicks from when you're afk", {}, function(Caller, Args, Tbl)
    local IsEnabled = Tbl[1]
    for i, v in next, getconnections(LocalPlayer.Idled) do
        if (IsEnabled) then
            v.Enable(v);
            Tbl[1] = nil
        else
            v.Disable(v);
            Tbl[1] = true
        end
    end
    return "antiafk " .. (IsEnabled and " disabled" or "enabled");
end)

AddCommand("clicktp", {}, "tps you to where your mouse is when you click", {}, function(Caller, Args, Tbl)
    local HasTool_ = Tbl[1] ~= nil
    if (HasTool_) then
        Destroy(Tbl[1]);
        Destroy(Tbl[2]);
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

    Tbl[1] = Tool
    Tbl[2] = Tool2
    return "click to teleport"
end)

AddCommand("annoy", {}, "annoys a player", {3, "1"}, function(Caller, Args, Tbl)
    local Target = GetPlayer(Args[1]);
    if (#Target > 1) then
        Utils.Notify(Caller, "Notification", "You can only annoy one player");
    end
    Target = Target[1]
    local TargetRoot = GetRoot(Target);
    local Root = GetRoot();
    local Humanoid = GetHumanoid();
    local Char = GetCharacter();
    local Tool;
    AddConnection(CConnect(Heartbeat, function()
        if (Root and TargetRoot) then
            Root.CFrame = TargetRoot.CFrame
            if (Tool) then
                TargetRoot.CFrame = Tool.Handle.CFrame
            end
        else
            TargetRoot = GetRoot(Target);
            Root = GetRoot();
        end
    end))
    UnequipTools(Humanoid);
    local Tool = FindFirstChildWhichIsA(LocalPlayer.Backpack, "Tool");
    if (Tool) then
        for i, v in next, GetChildren(LocalPlayer.Backpack) do
            if (IsA(v, "Tool")) then
                v.Parent = Char
                Tool = v
            end
        end
        ReplaceHumanoid();
        AddConnection(CConnect(LocalPlayer.CharacterAdded, function()
            local Char = GetCharacter();
            WaitForChild(Char, "Humanoid");
            Tool.Parent = GetCharacter();
            ReplaceHumanoid();
            for i, v in next, GetChildren(LocalPlayer.Backpack) do
                if (IsA(v, "Tool")) then
                    v.Parent = Char
                    Tool = v
                end
            end
        end))
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

        if (GlobalChatLogsEnabled and plr == LocalPlayer) then
            local Message = {
                username = LocalPlayer.Name,
                userid = LocalPlayer.UserId,
                message = message
            }
            Socket.Send(Socket, JSONEncode(Services.HttpService, Message));
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
            local Command, LoadedCommand = CommandArgs[1], LoadCommand(CommandArgs[1]);
            local Args = shift(CommandArgs);

            if (LoadedCommand) then
                if (LoadedCommand.ArgsNeeded > #Args) then
                    return Utils.Notify(plr, "Error", format("Insuficient Args (you need %d)", LoadedCommand.ArgsNeeded))
                end

                local Success, Err = pcall(function()
                    local Executed = LoadedCommand.Function()(plr, Args, LoadedCommand.CmdExtra);
                    if (Executed) then
                        Utils.Notify(plr, "Command", Executed);
                    end
                    if (#LastCommand == 3) then
                        LastCommand = shift(LastCommand);
                    end
                    LastCommand[#LastCommand + 1] = {Command, plr, Args, LoadedCommand.CmdExtra}
                end);
                if (not Success and Debug) then
                    warn(Err);
                end
            else
                Utils.Notify(plr, "Error", format("couldn't find the command %s", Command));
            end
        end
    end)
end

--IMPORT [uimore]
-- make all elements not visible
Notification.Visible = false
Stats.Visible = false
Utils.SetAllTrans(CommandBar)
Utils.SetAllTrans(ChatLogs)
Utils.SetAllTrans(GlobalChatLogs)
Utils.SetAllTrans(HttpLogs);
Commands.Visible = false
ChatLogs.Visible = false
GlobalChatLogs.Visible = false
HttpLogs.Visible = false

-- make the ui draggable
Utils.Draggable(Commands)
Utils.Draggable(ChatLogs)
Utils.Draggable(GlobalChatLogs)
Utils.Draggable(HttpLogs);

-- parent ui
ParentGui(UI);
Connections.UI = {}
-- tweencommand bar on prefix
local Times = #LastCommand
AddConnection(CConnect(Services.UserInputService.InputBegan, function(Input, GameProccesed)
    if (Input.KeyCode == CommandBarPrefix and (not GameProccesed)) then
        CommandBarOpen = not CommandBarOpen

        local TransparencyTween = CommandBarOpen and Utils.TweenAllTransToObject or Utils.TweenAllTrans
        local Tween = TransparencyTween(CommandBar, .5, CommandBarTransparencyClone)

        -- tween position
        if (CommandBarOpen) then
            if (not Draggable) then
                Utils.Tween(CommandBar, "Quint", "Out", .5, {
                    Position = UDim2.new(0.5, WideBar and -200 or -100, 1, -110) -- tween -110
                })
            end

            local Connections = getconnections(Services.UserInputService.TextBoxFocused);
            for i, v in next, Connections do
                v.Disable(v);
            end
            for i, v in next, getconnections(Services.UserInputService.TextBoxFocusReleased) do
                v.Disable(v);
            end

            CommandBar.Input.CaptureFocus(CommandBar.Input);
            coroutine.wrap(function()
                wait()
                CommandBar.Input.Text = ""
            end)()

            
            for i, v in next, Connections do
                v.Enable(v);
            end
        else
            if (not Draggable) then
                Utils.Tween(CommandBar, "Quint", "Out", .5, {
                    Position = UDim2.new(0.5, WideBar and -200 or -100, 1, 5) -- tween 5
                })
            end
        end
    elseif (not GameProccesed and ChooseNewPrefix) then
        CommandBarPrefix = Input.KeyCode
        Utils.Notify(LocalPlayer, "New Prefix", "Your new prefix is: " .. split(tostring(Input.KeyCode), ".")[3]);
        ChooseNewPrefix = false
        if (writefile) then
            Utils.Notify(LocalPlayer, nil, "use command saveprefix to save your prefix");
        end
    elseif (GameProccesed and CommandBarOpen) then
        if (Input.KeyCode == Enum.KeyCode.Up) then
            Times = Times >= 3 and Times or Times + 1
            CommandBar.Input.Text = LastCommand[Times][1] .. " "
            CommandBar.Input.CursorPosition = #CommandBar.Input.Text + 2
        end
        if (Input.KeyCode == Enum.KeyCode.Down) then
            Times = Times <= 1 and 1 or Times - 1
            CommandBar.Input.Text = LastCommand[Times][1] .. " "
            CommandBar.Input.CursorPosition = #CommandBar.Input.Text + 2
        end
    end
end), Connections.UI, true);

Utils.Click(Commands.Close, "TextColor3")
Utils.Click(ChatLogs.Clear, "BackgroundColor3")
Utils.Click(ChatLogs.Save, "BackgroundColor3")
Utils.Click(ChatLogs.Toggle, "BackgroundColor3")
Utils.Click(ChatLogs.Close, "TextColor3")

Utils.Click(GlobalChatLogs.Clear, "BackgroundColor3")
Utils.Click(GlobalChatLogs.Save, "BackgroundColor3")
Utils.Click(GlobalChatLogs.Toggle, "BackgroundColor3")
Utils.Click(GlobalChatLogs.Close, "TextColor3")

Utils.Click(HttpLogs.Clear, "BackgroundColor3")
Utils.Click(HttpLogs.Save, "BackgroundColor3")
Utils.Click(HttpLogs.Toggle, "BackgroundColor3")
Utils.Click(HttpLogs.Close, "TextColor3")

-- close tween commands
AddConnection(CConnect(Commands.Close.MouseButton1Click, function()
    local Tween = Utils.TweenAllTrans(Commands, .25)

    CWait(Tween.Completed);
    Commands.Visible = false
end), Connections.UI, true);

-- command search
AddConnection(CConnect(GetPropertyChangedSignal(Commands.Search, "Text"), function()
    local Text = Commands.Search.Text
    for _, v in next, GetChildren(Commands.Frame.List) do
        if (IsA(v, "Frame")) then
            local Command = v.CommandText.Text

            v.Visible = Sfind(lower(Command), Text, 1, true)
        end
    end

    Commands.Frame.List.CanvasSize = UDim2.fromOffset(0, Commands.Frame.List.UIListLayout.AbsoluteContentSize.Y)
end), Connections.UI, true);

-- close chatlogs
AddConnection(CConnect(ChatLogs.Close.MouseButton1Click, function()
    local Tween = Utils.TweenAllTrans(ChatLogs, .25)
    
    CWait(Tween.Completed);
    ChatLogs.Visible = false
end), Connections.UI, true);
AddConnection(CConnect(GlobalChatLogs.Close.MouseButton1Click, function()
    local Tween = Utils.TweenAllTrans(GlobalChatLogs, .25)

    CWait(Tween.Completed);
    GlobalChatLogs.Visible = false
end), Connections.UI, true);
AddConnection(CConnect(HttpLogs.Close.MouseButton1Click, function()
    local Tween = Utils.TweenAllTrans(HttpLogs, .25)

    CWait(Tween.Completed);
    HttpLogs.Visible = false
end), Connections.UI, true);

ChatLogs.Toggle.Text = ChatLogsEnabled and "Enabled" or "Disabled"
GlobalChatLogs.Toggle.Text = ChatLogsEnabled and "Enabled" or "Disabled"
HttpLogs.Toggle.Text = HttpLogsEnabled and "Enabled" or "Disabled"


-- enable chat logs
AddConnection(CConnect(ChatLogs.Toggle.MouseButton1Click, function()
    ChatLogsEnabled = not ChatLogsEnabled
    ChatLogs.Toggle.Text = ChatLogsEnabled and "Enabled" or "Disabled"
end), Connections.UI, true);
AddConnection(CConnect(GlobalChatLogs.Toggle.MouseButton1Click, function()
    GlobalChatLogsEnabled = not GlobalChatLogsEnabled
    GlobalChatLogs.Toggle.Text = GlobalChatLogsEnabled and "Enabled" or "Disabled"
end), Connections.UI, true);
AddConnection(CConnect(HttpLogs.Toggle.MouseButton1Click, function()
    HttpLogsEnabled = not HttpLogsEnabled
    HttpLogs.Toggle.Text = HttpLogsEnabled and "Enabled" or "Disabled"
end), Connections.UI, true);

-- clear chat logs
AddConnection(CConnect(ChatLogs.Clear.MouseButton1Click, function()
    Utils.ClearAllObjects(ChatLogs.Frame.List)
    ChatLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, 0)
end), Connections.UI, true);
AddConnection(CConnect(GlobalChatLogs.Clear.MouseButton1Click, function()
    Utils.ClearAllObjects(GlobalChatLogs.Frame.List)
    GlobalChatLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, 0)
end), Connections.UI, true);
AddConnection(CConnect(HttpLogs.Clear.MouseButton1Click, function()
    Utils.ClearAllObjects(HttpLogs.Frame.List)
    HttpLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, 0)
end), Connections.UI, true);

-- chat logs search
AddConnection(CConnect(GetPropertyChangedSignal(ChatLogs.Search, "Text"), function()
    local Text = ChatLogs.Search.Text

    for _, v in next, GetChildren(ChatLogs.Frame.List) do
        if (not IsA(v, "UIListLayout")) then
            local Message = split(v.Text, ": ")[2]
            v.Visible = Sfind(lower(Message), Text, 1, true)
        end
    end

    ChatLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, ChatLogs.Frame.List.UIListLayout.AbsoluteContentSize.Y)
end), Connections.UI, true);

AddConnection(CConnect(GetPropertyChangedSignal(GlobalChatLogs.Search, "Text"), function()
    local Text = GlobalChatLogs.Search.Text

    for _, v in next, GetChildren(GlobalChatLogs.Frame.List) do
        if (not IsA(v, "UIListLayout")) then
            local Message = v.Text

            v.Visible = Sfind(lower(Message), Text, 1, true)
        end
    end
end), Connections.UI, true);

AddConnection(CConnect(GetPropertyChangedSignal(HttpLogs.Search, "Text"), function()
    local Text = HttpLogs.Search.Text

    for _, v in next, GetChildren(HttpLogs.Frame.List) do
        if (not IsA(v, "UIListLayout")) then
            local Message = v.Text
            v.Visible = Sfind(lower(Message), Text, 1, true)
        end
    end
end), Connections.UI, true);

AddConnection(CConnect(ChatLogs.Save.MouseButton1Click, function()
    local GameName = Services.MarketplaceService.GetProductInfo(Services.MarketplaceService, game.PlaceId).Name
    local String =  format("Fates Admin Chatlogs for %s (%s)\n\n", GameName, os.date());
    local TimeSaved = gsub(tostring(os.date("%x")), "/", "-") .. " " .. gsub(tostring(os.date("%X")), ":", "-");
    local Name = format("fates-admin/chatlogs/%s (%s).txt", GameName, TimeSaved);
    for i, v in next, GetChildren(ChatLogs.Frame.List) do
        if (not IsA(v, "UIListLayout")) then
            String = format("%s%s\n", String, v.Text);
        end
    end
    writefile(Name, String);
    Utils.Notify(LocalPlayer, "Saved", "Chat logs saved!");
end), Connections.UI, true);

AddConnection(CConnect(HttpLogs.Save.MouseButton1Click, function()
    print("saved");
end), Connections.UI, true);

-- auto correct
AddConnection(CConnect(GetPropertyChangedSignal(CommandBar.Input, "Text"), function() -- make it so that every space a players name will appear
    CommandBar.Input.Text = CommandBar.Input.Text
    local Text = CommandBar.Input.Text
    local Prediction = CommandBar.Input.Predict
    local PredictionText = Prediction.Text

    local Args = split(Text, " ")

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
                    if (lower(v2) == "player") then
                        Predict = Utils.GetPlayerArgs(v) or Predict;
                    else
                        Predict = Utils.MatchSearch(v, v2) and v2 or Predict
                    end
                end
            else
                Predict = Utils.GetPlayerArgs(v) or Predict;
            end
            Prediction.Text = sub(Text, 1, #Text - #Args[#Args]) .. Predict
            local split = split(v, ",");
            if (next(split)) then
                for i2, v2 in next, split do
                    if (i2 > 1 and v2 ~= "") then
                        local PlayerName = Utils.GetPlayerArgs(v2)
                        Prediction.Text = sub(Text, 1, #Text - #split[#split]) .. (PlayerName or "")
                    end
                end
            end
        end
    end

    if (Sfind(Text, "\t")) then -- remove tab from preditction text also
        CommandBar.Input.Text = PredictionText
        CommandBar.Input.CursorPosition = #CommandBar.Input.Text + 1
    end
end))

if (ChatBar) then
    AddConnection(CConnect(GetPropertyChangedSignal(ChatBar, "Text"), function() -- todo: add detection for /e
        local Text = ChatBar.Text
        local Prediction = PredictionClone
        local PredictionText = PredictionClone.Text
    
        local Args = split(concat(shift(split(Text, ""))), " ");
    
        Prediction.Text = ""
        if (not startsWith(Text, Prefix)) then
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
                        if (lower(v2) == "player") then
                            Predict = Utils.GetPlayerArgs(v) or Predict;
                        else
                            Predict = Utils.MatchSearch(v, v2) and v2 or Predict
                        end
                    end
                else
                    Predict = Utils.GetPlayerArgs(v) or Predict;
                end
                Prediction.Text = sub(Text, 1, #Text - #Args[#Args]) .. Predict
                local split = split(v, ",");
                if (next(split)) then
                    for i2, v2 in next, split do
                        if (i2 > 1 and v2 ~= "") then
                            local PlayerName = Utils.GetPlayerArgs(v2)
                            Prediction.Text = sub(Text, 1, #Text - #split[#split]) .. (PlayerName or "")
                        end
                    end
                end
            end
        end
    
        if (Sfind(Text, "\t")) then -- remove tab from preditction text also
            ChatBar.Text = PredictionText
            ChatBar.CursorPosition = #ChatBar.Text + 2
        end
    end))
end
--END IMPORT [uimore]

WideBar = false
Draggable = false
AddConnection(CConnect(CommandBar.Input.FocusLost, function()
    for i, v in next, getconnections(Services.UserInputService.TextBoxFocusReleased) do
        v.Enable(v);
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

    local Command, LoadedCommand = CommandArgs[1], LoadCommand(CommandArgs[1]);
    local Args = shift(CommandArgs);

    if (LoadedCommand and Command ~= "") then
        if (LoadedCommand.ArgsNeeded > #Args) then
            return Utils.Notify(plr, "Error", format("Insuficient Args (you need %d)", LoadedCommand.ArgsNeeded))
        end

        local Success, Err = pcall(function()
            local Executed = LoadedCommand.Function()(LocalPlayer, Args, LoadedCommand.CmdExtra);
            if (Executed) then
                Utils.Notify(plr, "Command", Executed);
            end
            if (#LastCommand == 3) then
                LastCommand = shift(LastCommand);
            end
            LastCommand[#LastCommand + 1] = {Command, LocalPlayer, Args, LoadedCommand.CmdExtra}
        end);
        if (not Success and Debug) then
            warn(Err);
        end
    else
        Utils.Notify(plr, "Error", format("couldn't find the command %s", Command));
    end

end), Connections.UI, true);

local CurrentPlayers = GetPlayers(Players);

local PlayerAdded = function(plr)
    RespawnTimes[plr.Name] = tick();
    CConnect(plr.CharacterAdded, function()
        RespawnTimes[plr.Name] = tick();
    end)
    local Tag = Utils.CheckTag(plr);
    if (Tag and plr ~= LocalPlayer) then
        Tag.Player = plr
        Utils.Notify(LocalPlayer, "Admin", format("%s (%s) has joined", Tag.Name, Tag.Tag));
        Utils.AddTag(Tag);
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
    Loaded = true,
    Utils = Utils,
    PluginLibrary = PluginLibrary
}

Utils.Notify(LocalPlayer, "Loaded", format("script loaded in %.3f seconds", (tick()) - start));
Utils.Notify(LocalPlayer, "Welcome", "'cmds' to see all of the commands");