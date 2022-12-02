--[[
	fates admin - 16/11/2022
]]

local game = game
local GetService = game.GetService
if (not game.IsLoaded(game)) then
    local Loaded = game.Loaded
    Loaded.Wait(Loaded);
end

local _L = {}

_L.start = start or tick();
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

--IMPORT [var]
local Services = {
    Workspace = GetService(game, "Workspace");
    UserInputService = GetService(game, "UserInputService");
    ReplicatedStorage = GetService(game, "ReplicatedStorage");
    StarterPlayer = GetService(game, "StarterPlayer");
    StarterPack = GetService(game, "StarterPack");
    StarterGui = GetService(game, "StarterGui");
    TeleportService = GetService(game, "TeleportService");
    CoreGui = GetService(game, "CoreGui");
    TweenService = GetService(game, "TweenService");
    HttpService = GetService(game, "HttpService");
    TextService = GetService(game, "TextService");
    MarketplaceService = GetService(game, "MarketplaceService");
    Chat = GetService(game, "Chat");
    Teams = GetService(game, "Teams");
    SoundService = GetService(game, "SoundService");
    Lighting = GetService(game, "Lighting");
    ScriptContext = GetService(game, "ScriptContext");
    Stats = GetService(game, "Stats");
}

setmetatable(Services, {
    __index = function(Table, Property)
        local Ret, Service = pcall(GetService, game, Property);
        if (Ret) then
            Services[Property] = Service
            return Service
        end
        return nil
    end,
    __mode = "v"
});

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

local Heartbeat, Stepped, RenderStepped;
do
    local RunService = Services.RunService;
    Heartbeat, Stepped, RenderStepped =
        RunService.Heartbeat,
        RunService.Stepped,
        RunService.RenderStepped
end

local Players = Services.Players
local GetPlayers = Players.GetPlayers

local JSONEncode, JSONDecode, GenerateGUID = 
    Services.HttpService.JSONEncode, 
    Services.HttpService.JSONDecode,
    Services.HttpService.GenerateGUID

local Camera = Services.Workspace.CurrentCamera

local Tfind, sort, concat, pack, unpack;
do
    local table = table
    Tfind, sort, concat, pack, unpack = 
        table.find, 
        table.sort,
        table.concat,
        table.pack,
        table.unpack
end

local lower, upper, Sfind, split, sub, format, len, match, gmatch, gsub, byte;
do
    local string = string
    lower, upper, Sfind, split, sub, format, len, match, gmatch, gsub, byte = 
        string.lower,
        string.upper,
        string.find,
        string.split, 
        string.sub,
        string.format,
        string.len,
        string.match,
        string.gmatch,
        string.gsub,
        string.byte
end

local random, floor, round, abs, atan, cos, sin, rad;
do
    local math = math
    random, floor, round, abs, atan, cos, sin, rad = 
        math.random,
        math.floor,
        math.round,
        math.abs,
        math.atan,
        math.cos,
        math.sin,
        math.rad
end

local InstanceNew = Instance.new
local CFrameNew = CFrame.new
local Vector3New = Vector3.new

local Inverse, toObjectSpace, components
do
    local CalledCFrameNew = CFrameNew();
    Inverse = CalledCFrameNew.Inverse
    toObjectSpace = CalledCFrameNew.toObjectSpace
    components = CalledCFrameNew.components
end

local Connection = game.Loaded
local CWait = Connection.Wait
local CConnect = Connection.Connect

local Disconnect;
do
    local CalledConnection = CConnect(Connection, function() end);
    Disconnect = CalledConnection.Disconnect
end

local __H = InstanceNew("Humanoid");
local UnequipTools = __H.UnequipTools
local ChangeState = __H.ChangeState
local SetStateEnabled = __H.SetStateEnabled
local GetState = __H.GetState
local GetAccessories = __H.GetAccessories

local LocalPlayer = Players.LocalPlayer
local PlayerGui =  FindFirstChildWhichIsA(LocalPlayer, "PlayerGui");
local Mouse = LocalPlayer.GetMouse(LocalPlayer);

local CThread;
do
    local wrap = coroutine.wrap
    CThread = function(Func, ...)
        if (type(Func) ~= 'function') then
            return nil
        end
        local Varag = ...
        return function()
            local Success, Ret = pcall(wrap(Func, Varag));
            if (Success) then
                return Ret
            end
            if (Debug) then
                warn("[FA Error]: " .. debug.traceback(Ret));
            end
        end
    end
end

local startsWith = function(str, searchString, rawPos)
    local pos = rawPos or 1
    return searchString == "" and true or sub(str, pos, pos) == searchString
end

local trim = function(str)
    return gsub(str, "^%s*(.-)%s*$", "%1");
end

local tbl_concat = function(...)
    local new = {}
    for i, v in next, {...} do
        for i2, v2 in next, v do
            new[i] = v2
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
            local Value, Key = ret(i, v);
            new[Key or #new + 1] = Value
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

local deepsearchset;
deepsearchset = function(tbl, ret, value)
    if (type(tbl) == 'table') then
        local new = {}
        for i, v in next, tbl do
            new[i] = v
            if (type(v) == 'table') then
                new[i] = deepsearchset(v, ret, value);
            end
            if (ret(i, v)) then
                new[i] = value(i, v);
            end
        end
        return new
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

local function clone(toClone, shallow)
    if (type(toClone) == 'function' and clonefunction) then
        return clonefunction(toClone);
    end
    local new = {}
    for i, v in pairs(toClone) do
        if (type(v) == 'table' and not shallow) then
            v = clone(v);
        end
        new[i] = v
    end
    return new
end

local setthreadidentity = setthreadidentity or syn_context_set or setthreadcontext or (syn and syn.set_thread_identity)
local getthreadidentity = getthreadidentity or syn_context_get or getthreadcontext or (syn and syn.get_thread_identity)

--END IMPORT [var]



local GetCharacter = GetCharacter or function(Plr)
    return Plr and Plr.Character or LocalPlayer.Character
end

local Utils = {}

--IMPORT [extend]
local Stats = Services.Stats
local ContentProvider = Services.ContentProvider

local firetouchinterest, hookfunction;
do
    local GEnv = getgenv();
    local touched = {}
    firetouchinterest = GEnv.firetouchinterest or function(part1, part2, toggle)
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
    local newcclosure = newcclosure or function(f)
        return f
    end

    hookfunction = GEnv.hookfunction or function(func, newfunc, applycclosure)
        if (replaceclosure) then
            replaceclosure(func, newfunc);
            return func
        end
        func = applycclosure and newcclosure or newfunc
        return func
    end
end

if (not syn_context_set) then
    local CachedConnections = setmetatable({}, {
        __mode = "v"
    });

    GEnv = getgenv();
    getconnections = function(Connection, FromCache, AddOnConnect)
        local getconnections = GEnv.getconnections
        if (not getconnections) then
            return {}
        end

        local CachedConnection;
        for i, v in next, CachedConnections do
            if (i == Connection) then
                CachedConnection = v
                break;
            end
        end
        if (CachedConnection and FromCache) then
            return CachedConnection
        end

        local Connections = GEnv.getconnections(Connection);
        CachedConnections[Connection] = Connections
        return Connections
    end
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

local Hooks = {
    AntiKick = false,
    AntiTeleport = false,
    NoJumpCooldown = false,
}

local mt = getrawmetatable(game);
local OldMetaMethods = {}
setreadonly(mt, false);
for i, v in next, mt do
    OldMetaMethods[i] = v
end
setreadonly(mt, true);
local MetaMethodHooks = {}

local ProtectInstance, SpoofInstance, SpoofProperty;
local pInstanceCount = {0, 0}; -- instancecount, primitivescount
local ProtectedInstances = setmetatable({}, {
    __mode = "v"
});
local FocusedTextBox = nil
do
    local SpoofedInstances = setmetatable({}, {
        __mode = "v"
    });
    local SpoofedProperties = {}
    Hooks.SpoofedProperties = SpoofedProperties

    local otherCheck = function(instance, n)
        if (IsA(instance, "ImageLabel") or IsA(instance, "ImageButton")) then
            ProtectedInstances[#ProtectedInstances + 1] = instance
            return;
        end

        if (IsA(instance, "BasePart")) then
            pInstanceCount[2] = math.max(pInstanceCount[2] + (n or 1), 0);
        end
    end

    ProtectInstance = function(Instance_)
        if (not Tfind(ProtectedInstances, Instance_)) then
            ProtectedInstances[#ProtectedInstances + 1] = Instance_
            local descendants = Instance_:GetDescendants();
            pInstanceCount[1] += 1 + #descendants;
            for i = 1, #descendants do
                otherCheck(descendants[i]);
            end
            local dAdded = Instance_.DescendantAdded:Connect(function(descendant)
                pInstanceCount[1] += 1
                otherCheck(descendant);
            end);
            local dRemoving = Instance_.DescendantRemoving:Connect(function(descendant)
                pInstanceCount[1] = math.max(pInstanceCount[1] - 1, 0);
                otherCheck(descendant, -1);
            end);
            otherCheck(Instance_);

            Instance_.Name = sub(gsub(GenerateGUID(Services.HttpService, false), '-', ''), 1, random(25, 30));
            Instance_.Archivable = false
        end
    end

    SpoofInstance = function(Instance_, Instance2)
        if (not SpoofedInstances[Instance_]) then
            SpoofedInstances[Instance_] = Instance2 and Instance2 or Clone(Instance_);
        end
    end

    UnSpoofInstance = function(Instance_)
        if (SpoofedInstances[Instance_]) then
            SpoofedInstances[Instance_] = nil
        end
    end
    
    local ChangedSpoofedProperties = {}
    SpoofProperty = function(Instance_, Property, NoClone)
        if (SpoofedProperties[Instance_]) then
            local SpoofedPropertiesForInstance = SpoofedProperties[Instance_]
            local Properties = map(SpoofedPropertiesForInstance, function(i, v)
                return v.Property
            end)
            if (not Tfind(Properties, Property)) then
                SpoofedProperties[Instance_][#SpoofedPropertiesForInstance + 1] = {
                    SpoofedProperty = SpoofedPropertiesForInstance[1].SpoofedProperty,
                    Property = Property,
                };
            end
        else
            local Cloned;
            if (not NoClone and IsA(Instance_, "Instance") and not Services[tostring(Instance_)] and Instance_.Archivable) then
                local Success, Ret = pcall(Clone, Instance_);
                if (Success) then
                    Cloned = Ret
                end
            end
            SpoofedProperties[Instance_] = {{
                SpoofedProperty = Cloned and Cloned or {[Property]=Instance_[Property]},
                Property = Property,
            }}
            ChangedSpoofedProperties[Instance_] = {}
        end
    end

    local GetAllParents = function(Instance_, NIV)
        if (typeof(Instance_) == "Instance") then
            local Parents = {}
            local Current = NIV or Instance_
            if (NIV) then
                Parents[#Parents + 1] = Current
            end
            repeat
                local Parent = Current.Parent
                Parents[#Parents + 1] = Parent
                Current = Parent
            until not Current
            return Parents
        end
        return {}
    end

    local Methods = {
        "FindFirstChild",
        "FindFirstChildWhichIsA",
        "FindFirstChildOfClass",
        "IsA"
    }

    local lockedInstances = {};
    setmetatable(lockedInstances, { __mode = "k" });
    local isProtected = function(instance)
        if (lockedInstances[instance]) then
            return true;
        end

        local good2 = pcall(tostring, instance);
        if (not good2) then
            lockedInstances[instance] = true
            return true;
        end

        for i2 = 1, #ProtectedInstances do
            local pInstance = ProtectedInstances[i2]
            if (pInstance == instance) then
                return true;
            end
        end
        return false;
    end

    MetaMethodHooks.Namecall = function(...)
        local __Namecall = OldMetaMethods.__namecall;
        local Args = {...}
        local self = Args[1]
        local Method = getnamecallmethod() or "";

        if (Method ~= "") then
            local Success, result = pcall(OldMetaMethods.__index, self, Method);
            if (not Success or Success and type(result) ~= "function") then
                return __Namecall(...);
            end
        end

        if (Hooks.AntiKick and lower(Method) == "kick") then
            local Player, Message = self, Args[2]
            if (Hooks.AntiKick and Player == LocalPlayer) then
                local Notify = Utils.Notify
                local Context;
                if (setthreadidentity) then
                    Context = getthreadidentity();
                    setthreadidentity(3);
                end
                if (Notify and Context) then
                    Notify(nil, "Attempt to kick", format("attempt to kick %s", (Message and type(Message) == 'number' or type(Message) == 'string') and ": " .. Message or ""));
                    setthreadidentity(Context);
                end
                return
            end
        end

        if (Hooks.AntiTeleport and Method == "Teleport" or Method == "TeleportToPlaceInstance") then
            local Player, PlaceId = self, Args[2]
            if (Hooks.AntiTeleport and Player == LocalPlayer) then
                local Notify = Utils.Notify
                local Context;
                if (setthreadidentity) then
                    Context = getthreadidentity();
                    setthreadidentity(3);
                end
                if (Notify and Context) then
                    Notify(nil, "Attempt to teleport", format("attempt to teleport to place %s", PlaceId and PlaceId or ""));
                    setthreadidentity(Context);
                end
                return
            end
        end

        if (checkcaller()) then
            return __Namecall(...);
        end

        if (Tfind(Methods, Method)) then
            local ReturnedInstance = __Namecall(...);
            if (Tfind(ProtectedInstances, ReturnedInstance)) then
                return Method == "IsA" and false or nil
            end
        end

        -- ik this is horrible but fates admin v3 has a better way of doing hooks
        if (Method == "children" or Method == "GetChildren" or Method ==  "getChildren" or Method == "GetDescendants" or Method == "getDescendants") then
            return filter(__Namecall(...), function(i, instance)
                return not isProtected(instance);
            end);
        end

        if (self == Services.UserInputService and (Method == "GetFocusedTextBox" or Method == "getFocusedTextBox")) then
            local focused = __Namecall(...);
            if (focused) then
                for i = 1, #ProtectedInstances do
                    local ProtectedInstance = ProtectedInstances[i]
                    local iden = getthreadidentity();
                    setthreadidentity(7);
                    local pInstance = Tfind(ProtectedInstances, focused) or focused.IsDescendantOf(focused, ProtectedInstance);
                    setthreadidentity(iden);
                    if (pInstance) then
                        return nil;
                    end
                end
            end
            return focused;
        end

        if (Hooks.NoJumpCooldown and (Method == "GetState" or Method == "GetStateEnabled")) then
            local State = __Namecall(...);
            if (Method == "GetState" and (State == Enum.HumanoidStateType.Jumping or State == "Jumping")) then
                return Enum.HumanoidStateType.RunningNoPhysics
            end
            if (Method == "GetStateEnabled" and (self == Enum.HumanoidStateType.Jumping or self == "Jumping")) then
                return false
            end
        end

        return __Namecall(...);
    end

    local AllowedIndexes = {
        "RootPart",
        "Parent"
    }
    local AllowedNewIndexes = {
        "Jump"
    }
    MetaMethodHooks.Index = function(...)
        local __Index = OldMetaMethods.__index;
        local called = __Index(...);

        if (checkcaller()) then
            return __Index(...);
        end
        local Instance_, Index = ...

        local SanitisedIndex = Index
        if (typeof(Instance_) == 'Instance' and type(Index) == 'string') then
            SanitisedIndex = gsub(sub(Index, 0, 100), "%z.*", "");
        end
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
                local SanitisedIndex = gsub(SanitisedIndex, "^%l", upper);
                if (SanitisedIndex == SpoofedProperty.Property) then
                    local ClientChangedData = ChangedSpoofedProperties[Instance_][SanitisedIndex]
                    local IndexedSpoofed = __Index(SpoofedProperty.SpoofedProperty, Index);
                    local Indexed = __Index(Instance_, Index);
                    if (ClientChangedData.Caller and ClientChangedData.Value ~= Indexed) then
                        OldMetaMethods.__newindex(SpoofedProperty.SpoofedProperty, Index, Indexed);
                        OldMetaMethods.__newindex(Instance_, Index, ClientChangedData.Value);
                        return Indexed
                    end
                    return IndexedSpoofed
                end
            end
        end

        if (Hooks.NoJumpCooldown and SanitisedIndex == "Jump") then
            if (IsA(Instance_, "Humanoid")) then
                return false
            end
        end

        if (Instance_ == Stats and (SanitisedIndex == "InstanceCount" or SanitisedIndex == "instanceCount")) then
            return called - pInstanceCount[1];
        end

        if (Instance_ == Stats and (SanitisedIndex == "PrimitivesCount" or SanitisedIndex == "primitivesCount")) then
            return called - pInstanceCount[2];
        end

        return called;
    end

    MetaMethodHooks.NewIndex = function(...)
        local __NewIndex = OldMetaMethods.__newindex;
        local __Index = OldMetaMethods.__index;
        local Instance_, Index, Value = ...

        local SpoofedInstance = SpoofedInstances[Instance_]
        local SpoofedPropertiesForInstance = SpoofedProperties[Instance_]

        if (checkcaller()) then
            if (Index == "Parent" and Value) then
                local ProtectedInstance
                for i = 1, #ProtectedInstances do
                    local ProtectedInstance_ = ProtectedInstances[i]
                    if (Instance_ == ProtectedInstance_ or Instance_.IsDescendantOf(Value, ProtectedInstance_)) then
                        ProtectedInstance = true
                    end
                end
                if (ProtectedInstance) then
                    local Parents = GetAllParents(Instance_, Value);
                    local child1 = getconnections(Parents[1].ChildAdded, true);
                    local descendantconnections = {}
                    for i, v in next, child1 do
                        v.Disable(v);
                    end
                    for i = 1, #Parents do
                        local Parent = Parents[i]
                        for i2, v in next, getconnections(Parent.DescendantAdded, true) do
                            v.Disable(v);
                            descendantconnections[#descendantconnections + 1] = v
                        end
                    end
                    local good, Ret = pcall(__NewIndex, ...);
                    for i, v in pairs(descendantconnections) do
                        v:Enable();
                    end
                    for i, v in next, child1 do
                        v.Enable(v);
                    end
                    if (not good) then
                        return __NewIndex(...);
                    end
                    return Ret;
                end
            end
            if (SpoofedInstance or SpoofedPropertiesForInstance) then
                if (SpoofedPropertiesForInstance) then
                    ChangedSpoofedProperties[Instance_][Index] = {
                        Caller = true,
                        BeforeValue = Instance_[Index],
                        Value = Value
                    }
                end
                local Connections = tbl_concat(
                    getconnections(GetPropertyChangedSignal(Instance_, SpoofedPropertiesForInstance and SpoofedPropertiesForInstance.Property or Index), true),
                    -- getconnections(Instance_.Changed, true),
                    getconnections(game.ItemChanged, true)
                )
                
                if (not next(Connections)) then
                    return __NewIndex(Instance_, Index, Value);
                end
                for i, v in next, Connections do
                    v.Disable(v);
                end
                local Ret = __NewIndex(Instance_, Index, Value);
                for i, v in next, Connections do
                    v.Enable(v);
                end
                return Ret
            end
            return __NewIndex(...);
        end

        local SanitisedIndex = Index
        if (typeof(Instance_) == 'Instance' and type(Index) == 'string') then
            local len = select(2, gsub(Index, "%z", ""));
            if (len > 255) then
                return __Index(...);
            end

            SanitisedIndex = gsub(sub(Index, 0, 100), "%z.*", "");
        end

        if (SpoofedInstance) then
            if (Tfind(AllowedNewIndexes, SanitisedIndex)) then
                return __NewIndex(...);
            end
            return __NewIndex(SpoofedInstance, Index, __Index(SpoofedInstance, Index));
        end

        if (SpoofedPropertiesForInstance) then
            for i, SpoofedProperty in next, SpoofedPropertiesForInstance do
                if (SpoofedProperty.Property == SanitisedIndex and not Tfind(AllowedIndexes, SanitisedIndex)) then
                    ChangedSpoofedProperties[Instance_][SanitisedIndex] = {
                        Caller = false,
                        BeforeValue = Instance_[Index],
                        Value = Value
                    }
                    return __NewIndex(SpoofedProperty.SpoofedProperty, Index, Value);
                end
            end
        end

        return __NewIndex(...);
    end

    local hookmetamethod = hookmetamethod or function(metatable, metamethod, func)
        setreadonly(metatable, false);
        Old = hookfunction(metatable[metamethod], func, true);
        setreadonly(metatable, true);
        return Old
    end

    OldMetaMethods.__index = hookmetamethod(game, "__index", MetaMethodHooks.Index);
    OldMetaMethods.__newindex = hookmetamethod(game, "__newindex", MetaMethodHooks.NewIndex);
    OldMetaMethods.__namecall = hookmetamethod(game, "__namecall", MetaMethodHooks.Namecall);

    Hooks.Destroy = hookfunction(game.Destroy, function(...)
        local instance = ...
        local protected = table.find(ProtectedInstances, instance);
        if (checkcaller() and protected) then
            otherCheck(instance, -1);
            local Parents = GetAllParents(instance);
            for i, v in next, getconnections(Parents[1].ChildRemoved, true) do
                v.Disable(v);
            end
            for i = 1, #Parents do
                local Parent = Parents[i]
                for i2, v in next, getconnections(Parent.DescendantRemoving, true) do
                    v.Disable(v);
                end
            end
            local destroy = Hooks.Destroy(...);
            for i = 1, #Parents do
                local Parent = Parents[i]
                for i2, v in next, getconnections(Parent.DescendantRemoving, true) do
                    v.Enable(v);
                end
            end
            for i, v in next, getconnections(Parents[1].ChildRemoved, true) do
                v.Enable(v);
            end
            table.remove(ProtectedInstances, protected);
            return destroy;
        end
        return Hooks.Destroy(...);
    end);
end

Hooks.OldGetChildren = hookfunction(game.GetChildren, newcclosure(function(...)
    if (not checkcaller()) then
        local Children = Hooks.OldGetChildren(...);
        return filter(Children, function(i, v)
            return not Tfind(ProtectedInstances, v);
        end)
    end
    return Hooks.OldGetChildren(...);
end));

Hooks.OldGetDescendants = hookfunction(game.GetDescendants, newcclosure(function(...)
    if (not checkcaller()) then
        local Descendants = Hooks.OldGetDescendants(...);
        return filter(Descendants, function(i, v)
            local Protected = false
            for i2 = 1, #ProtectedInstances do
                local ProtectedInstance = ProtectedInstances[i2]
                Protected = v and ProtectedInstance == v or v.IsDescendantOf(v, ProtectedInstance)
                if (Protected) then
                    break;
                end
            end
            return not Protected
        end)
    end
    return Hooks.OldGetDescendants(...);
end));

Hooks.FindFirstChild = hookfunction(game.FindFirstChild, newcclosure(function(...)
    if (not checkcaller()) then
        local ReturnedInstance = Hooks.FindFirstChild(...);
        if (ReturnedInstance and Tfind(ProtectedInstances, ReturnedInstance)) then
            return nil
        end
    end
    return Hooks.FindFirstChild(...);
end));
Hooks.FindFirstChildOfClass = hookfunction(game.FindFirstChildOfClass, newcclosure(function(...)
    if (not checkcaller()) then
        local ReturnedInstance = Hooks.FindFirstChildOfClass(...);
        if (ReturnedInstance and Tfind(ProtectedInstances, ReturnedInstance)) then
            return nil
        end
    end
    return Hooks.FindFirstChildOfClass(...);
end));
Hooks.FindFirstChildWhichIsA = hookfunction(game.FindFirstChildWhichIsA, newcclosure(function(...)
    if (not checkcaller()) then
        local ReturnedInstance = Hooks.FindFirstChildWhichIsA(...);
        if (ReturnedInstance and Tfind(ProtectedInstances, ReturnedInstance)) then
            return nil
        end
    end
    return Hooks.FindFirstChildWhichIsA(...);
end));
Hooks.IsA = hookfunction(game.IsA, newcclosure(function(...)
    if (not checkcaller()) then
        local Args = {...}
        local IsACheck = Args[1]
        if (IsACheck) then
            local ProtectedInstance = Tfind(ProtectedInstances, IsACheck);
            if (ProtectedInstance and Args[2]) then
                return false
            end
        end
    end
    return Hooks.IsA(...);
end));

Hooks.OldGetFocusedTextBox = hookfunction(Services.UserInputService.GetFocusedTextBox, newcclosure(function(...)
    if (not checkcaller() and ... == Services.UserInputService) then
        local FocusedTextBox = Hooks.OldGetFocusedTextBox(...);
        if(FocusedTextBox) then
            local Protected = false
            for i = 1, #ProtectedInstances do
                local ProtectedInstance = ProtectedInstances[i]
                Protected = Tfind(ProtectedInstances, FocusedTextBox) or FocusedTextBox.IsDescendantOf(FocusedTextBox, ProtectedInstance);
            end
            if (Protected) then
                return nil
            end
        end
        return FocusedTextBox;
    end
    return Hooks.OldGetFocusedTextBox(...);
end));

Hooks.OldKick = hookfunction(LocalPlayer.Kick, newcclosure(function(...)
    local Player, Message = ...
    if (Hooks.AntiKick and Player == LocalPlayer) then
        local Notify = Utils.Notify
        local Context;
        if (setthreadidentity) then
            Context = getthreadidentity();
            setthreadidentity(3);
        end
        if (Notify and Context) then
            Notify(nil, "Attempt to kick", format("attempt to kick %s", (Message and type(Message) == 'number' or type(Message) == 'string') and ": " .. Message or ""));
            setthreadidentity(Context)
        end
        return
    end
    return Hooks.OldKick(...);
end))

Hooks.OldTeleportToPlaceInstance = hookfunction(Services.TeleportService.TeleportToPlaceInstance, newcclosure(function(...)
    local Player, PlaceId = ...
    if (Hooks.AntiTeleport and Player == LocalPlayer) then
        local Notify = Utils.Notify
        local Context;
        if (setthreadidentity) then
            Context = getthreadidentity();
            setthreadidentity(3);
        end
        if (Notify and Context) then
            Notify(nil, "Attempt to teleport", format("attempt to teleport to place %s", PlaceId and PlaceId or ""));
            setthreadidentity(Context)
        end
        return
    end
    return Hooks.OldTeleportToPlaceInstance(...);
end))
Hooks.OldTeleport = hookfunction(Services.TeleportService.Teleport, newcclosure(function(...)
    local Player, PlaceId = ...
    if (Hooks.AntiTeleport and Player == LocalPlayer) then
        local Notify = Utils.Notify
        local Context;
        if (setthreadidentity) then
            Context = getthreadidentity();
            setthreadidentity(3);
        end
        if (Notify and Context) then
            Notify(nil, "Attempt to teleport", format("attempt to teleport to place \"%s\"", PlaceId and PlaceId or ""));
            setthreadidentity(Context);
        end
        return
    end
    return Hooks.OldTeleport(...);
end))

Hooks.GetState = hookfunction(GetState, function(...)
    local Humanoid, State = ..., Hooks.GetState(...);
    local Parent, Character = Humanoid.Parent, LocalPlayer.Character
    if (Hooks.NoJumpCooldown and (State == Enum.HumanoidStateType.Jumping or State == "Jumping") and Parent and Character and Parent == Character) then
        return Enum.HumanoidStateType.RunningNoPhysics
    end
    return State
end)

Hooks.GetStateEnabled = hookfunction(__H.GetStateEnabled, function(...)
    local Humanoid, State = ...
    local Ret = Hooks.GetStateEnabled(...);
    local Parent, Character = Humanoid.Parent, LocalPlayer.Character
    if (Hooks.NoJumpCooldown and (State == Enum.HumanoidStateType.Jumping or State == "Jumping") and Parent and Character and Parent == Character) then
        return false
    end
    return Ret
end)
--END IMPORT [extend]



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
    SafePlugins = false
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
_L.CLI = false
_L.ChatLogsEnabled = true
_L.GlobalChatLogsEnabled = false
_L.HttpLogsEnabled = true

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

--IMPORT [ui]
Guis = {}
ParentGui = function(Gui, Parent)
    Gui.Name = sub(gsub(GenerateGUID(Services.HttpService, false), '-', ''), 1, random(25, 30))
    ProtectInstance(Gui);
    if (syn and syn.protect_gui) then syn.protect_gui(Gui); end -- for preload
    Gui.Parent = Parent or Services.CoreGui
    Guis[#Guis + 1] = Gui
    return Gui
end
UI = Clone(Services.InsertService:LoadLocalAsset("rbxassetid://7882275026"));
UI.Enabled = true

local CommandBarPrefix;

local ConfigUI = UI.Config
local ConfigElements = ConfigUI.GuiElements
local CommandBar = UI.CommandBar
local Commands = UI.Commands
local ChatLogs = UI.ChatLogs
local Console = UI.Console
local GlobalChatLogs = Clone(UI.ChatLogs);
local HttpLogs = Clone(UI.ChatLogs);
local Notification = UI.Notification
local Command = UI.Command
local ChatLogMessage = UI.Message
local GlobalChatLogMessage = Clone(UI.Message);
local NotificationBar = UI.NotificationBar

CommandBarOpen = false
CommandBarTransparencyClone = Clone(CommandBar);
ChatLogsTransparencyClone = Clone(ChatLogs);
ConsoleTransparencyClone = Clone(Console);
GlobalChatLogsTransparencyClone = Clone(GlobalChatLogs);
HttpLogsTransparencyClone = Clone(HttpLogs);
CommandsTransparencyClone = nil
ConfigUIClone = Clone(ConfigUI);
PredictionText = ""
do
    local UIParent = CommandBar.Parent
    GlobalChatLogs.Parent = UIParent
    GlobalChatLogMessage.Parent = UIParent
    GlobalChatLogs.Name = "GlobalChatLogs"
    GlobalChatLogMessage.Name = "GlobalChatLogMessage"

    HttpLogs.Parent = UIParent
    HttpLogs.Name = "HttpLogs"
    HttpLogs.Size = UDim2.new(0, 421, 0, 260);
    HttpLogs.Search.PlaceholderText = "Search"
end
-- position CommandBar
CommandBar.Position = UDim2.new(0.5, -100, 1, 5);

local UITheme, Values;
do
    local BaseBGColor = Color3.fromRGB(32, 33, 36);
    local BaseTransparency = 0.25
    local BaseTextColor = Color3.fromRGB(220, 224, 234);
    local BaseValues = { BackgroundColor = BaseBGColor, Transparency = BaseTransparency, TextColor = BaseTextColor }
    Values = { Background = clone(BaseValues), CommandBar = clone(BaseValues), CommandList = clone(BaseValues), Notification = clone(BaseValues), ChatLogs = clone(BaseValues), Config = clone(BaseValues) }
    local Objects = keys(Values);
    local GetBaseMT = function(Object)
        return setmetatable({}, {
            __newindex = function(self, Index, Value)
                local type = typeof(Value);
                if (Index == "BackgroundColor") then
                    if (Value == "Reset") then
                        Value = BaseBGColor
                        type = "Color3"
                    end
                    assert(type == 'Color3', format("invalid argument #3 (Color3 expected, got %s)", type));
                    if (Object == "Background") then
                        CommandBar.BackgroundColor3 = Value
                        Notification.BackgroundColor3 = Value
                        Command.BackgroundColor3 = Value
                        ChatLogs.BackgroundColor3 = Value
                        ChatLogs.Frame.BackgroundColor3 = Value
                        Console.BackgroundColor3 = Value
                        Console.Frame.BackgroundColor3 = Value
                        HttpLogs.BackgroundColor3 = Value
                        HttpLogs.Frame.BackgroundColor3 = Value
                        UI.ToolTip.BackgroundColor3 = Value
                        ConfigUI.BackgroundColor3 = Value
                        ConfigUI.Container.BackgroundColor3 = Value
                        Commands.BackgroundColor3 = Value
                        Commands.Frame.BackgroundColor3 = Value
                        local Children = GetChildren(UI.NotificationBar);
                        for i = 1, #Children do
                            local Child = Children[i]
                            if (IsA(Child, "GuiObject")) then
                                Child.BackgroundColor3 = Value
                            end
                        end
                        local Children = GetChildren(Commands.Frame.List);
                        for i = 1, #Children do
                            local Child = Children[i]
                            if (IsA(Child, "GuiObject")) then
                                Child.BackgroundColor3 = Value
                            end
                        end
                        for i, v in next, Values do
                            Values[i].BackgroundColor = Value
                        end
                    elseif (Object == "CommandBar") then
                        CommandBar.BackgroundColor3 = Value
                    elseif (Object == "Notification") then
                        Notification.BackgroundColor3 = Value
                        local Children = GetChildren(UI.NotificationBar);
                        for i = 1, #Children do
                            local Child = Children[i]
                            if (IsA(Child, "GuiObject")) then
                                Child.BackgroundColor3 = Value
                            end
                        end
                    elseif (Object == "CommandList") then
                        Commands.BackgroundColor3 = Value
                        Commands.Frame.BackgroundColor3 = Value
                    elseif (Object == "Command") then
                        Command.BackgroundColor3 = Value
                    elseif (Object == "ChatLogs") then
                        ChatLogs.BackgroundColor3 = Value
                        ChatLogs.Frame.BackgroundColor3 = Value
                        HttpLogs.BackgroundColor3 = Value
                        HttpLogs.Frame.BackgroundColor3 = Value
                    elseif (Object == "Console") then
                        Console.BackgroundColor3 = Value
                        Console.Frame.BackgroundColor3 = Value
                    elseif (Object == "Config") then
                        ConfigUI.BackgroundColor3 = Value
                        ConfigUI.Container.BackgroundColor3 = Value
                    end
                    Values[Object][Index] = Value
                elseif (Index == "TextColor") then
                    if (Value == "Reset") then
                        Value = BaseTextColor
                        type = "Color3"
                    end
                    assert(type == 'Color3', format("invalid argument #3 (Color3 expected, got %s)", type));
                    if (Object == "Notification") then
                        Notification.Title.TextColor3 = Value
                        Notification.Message.TextColor3 = Value
                        Notification.Close.TextColor3 = Value
                    elseif (Object == "CommandBar") then
                        CommandBar.Input.TextColor3 = Value
                        CommandBar.Arrow.TextColor3 = Value
                    elseif (Object == "CommandList") then
                        Command.CommandText.TextColor3 = Value
                        local Descendants = GetDescendants(Commands);
                        for i = 1, #Descendants do
                            local Descendant = Descendants[i]
                            local IsText = IsA(Descendant, "TextBox") or IsA(Descendant, "TextLabel") or IsA(Descendant, "TextButton");
                            if (IsText) then
                                Descendant.TextColor3 = Value
                            end
                        end
                    elseif (Object == "ChatLogs") then
                        UI.Message.TextColor3 = Value
                    elseif (Object == "Config") then
                        local Descendants = GetDescendants(ConfigUI);
                        for i = 1, #Descendants do
                            local Descendant = Descendants[i]
                            local IsText = IsA(Descendant, "TextBox") or IsA(Descendant, "TextLabel") or IsA(Descendant, "TextButton");
                            if (IsText) then
                                Descendant.TextColor3 = Value
                            end
                        end
                    elseif (Object == "Background") then
                        Notification.Title.TextColor3 = Value
                        Notification.Message.TextColor3 = Value
                        Notification.Close.TextColor3 = Value
                        CommandBar.Input.TextColor3 = Value
                        CommandBar.Arrow.TextColor3 = Value
                        Command.CommandText.TextColor3 = Value
                        UI.Message.TextColor3 = Value
                        local Descendants = GetDescendants(ConfigUI);
                        for i = 1, #Descendants do
                            local Descendant = Descendants[i]
                            local IsText = IsA(Descendant, "TextBox") or IsA(Descendant, "TextLabel") or IsA(Descendant, "TextButton");
                            if (IsText) then
                                Descendant.TextColor3 = Value
                            end
                        end
                        local Descendants = GetDescendants(Commands);
                        for i = 1, #Descendants do
                            local Descendant = Descendants[i]
                            local IsText = IsA(Descendant, "TextBox") or IsA(Descendant, "TextLabel") or IsA(Descendant, "TextButton");
                            if (IsText) then
                                Descendant.TextColor3 = Value
                            end
                        end
                        for i, v in next, Values do
                            Values[i].TextColor = Value
                        end
                    end
                    Values[Object][Index] = Value
                elseif (Index == "Transparency") then
                    if (Value == "Reset") then
                        Value = BaseTransparency
                        type = "number"
                    end
                    assert(type == 'number', format("invalid argument #3 (Color3 expected, got %s)", type));
                    if (Object == "Background") then
                        CommandBar.Transparency = Value
                        Notification.Transparency = Value
                        Command.Transparency = Value + .5
                        ChatLogs.Transparency = Value
                        ChatLogs.Frame.Transparency = Value
                        HttpLogs.Transparency = Value
                        HttpLogs.Frame.Transparency = Value
                        UI.ToolTip.Transparency = Value
                        ConfigUI.Transparency = Value
                        ConfigUI.Container.Transparency = Value + .5
                        Commands.Transparency = Value
                        Commands.Frame.Transparency = Value + .5
                        Values[Object][Index] = Value
                    elseif (Object == "Notification") then
                        Notification.Transparency = Value
                        local Children = GetChildren(UI.NotificationBar);
                        for i = 1, #Children do
                            local Child = Children[i]
                            if (IsA(Child, "GuiObject")) then
                                Child.Transparency = Value
                            end
                        end
                    end
                    Values[Object][Index] = Value
                end
            end,
            __index = function(self, Index)
                return Values[Object][Index]
            end
        })
    end
    UITheme = setmetatable({}, {
        __index = function(self, Index)
            if (Tfind(Objects, Index)) then
                local BaseMt = GetBaseMT(Index);
                self[Index] = BaseMt
                return BaseMt
            end
        end
    })
end

local IsSupportedExploit = isfile and isfolder and writefile and readfile

local GetThemeConfig
local WriteThemeConfig = function(Conf)
    if (IsSupportedExploit and isfolder("fates-admin")) then
        local ToHSV = Color3.new().ToHSV
        local ValuesToEncode = deepsearchset(Values, function(i, v)
            return typeof(v) == 'Color3'
        end, function(i, v)
            local H, S, V = ToHSV(v);
            return {H, S, V, "Color3"}
        end)
        local Data = JSONEncode(Services.HttpService, ValuesToEncode);
        writefile("fates-admin/Theme.json", Data);
    end
end

GetThemeConfig = function()
    if (IsSupportedExploit and isfolder("fates-admin")) then
        if (isfile("fates-admin/Theme.json")) then
            local Success, Data = pcall(JSONDecode, Services.HttpService, readfile("fates-admin/Theme.json"));
            if (not Success or type(Data) ~= 'table') then
                WriteThemeConfig();
                return Values
            end
            local DecodedData = deepsearchset(Data, function(i, v)
                return type(v) == 'table' and #v == 4 and v[4] == "Color3"
            end, function(i,v)
                return Color3.fromHSV(v[1], v[2], v[3]);
            end)
            return DecodedData            
        else
            WriteThemeConfig();
            return Values
        end
    else
        return Values
    end
end

local LoadTheme;
do
    local Config = GetConfig();
    CommandBarPrefix = isfolder and (Config.CommandBarPrefix and Enum.KeyCode[Config.CommandBarPrefix] or Enum.KeyCode.Semicolon) or Enum.KeyCode.Semicolon

    local Theme = GetThemeConfig();
    LoadTheme = function(Theme)
        UITheme.Background.BackgroundColor = Theme.Background.BackgroundColor
        UITheme.Background.Transparency = Theme.Background.Transparency

        UITheme.ChatLogs.BackgroundColor = Theme.ChatLogs.BackgroundColor
        UITheme.CommandBar.BackgroundColor = Theme.CommandBar.BackgroundColor
        UITheme.Config.BackgroundColor = Theme.Config.BackgroundColor
        UITheme.Notification.BackgroundColor = Theme.Notification.BackgroundColor
        UITheme.CommandList.BackgroundColor = Theme.Notification.BackgroundColor
        
        UITheme.ChatLogs.TextColor = Theme.ChatLogs.TextColor
        UITheme.CommandBar.TextColor = Theme.CommandBar.TextColor
        UITheme.Config.TextColor = Theme.Config.TextColor
        UITheme.Notification.TextColor = Theme.Notification.TextColor
        UITheme.CommandList.TextColor = Theme.Notification.TextColor

        UITheme.ChatLogs.Transparency = Theme.ChatLogs.Transparency
        UITheme.CommandBar.Transparency = Theme.CommandBar.Transparency
        UITheme.Config.Transparency = Theme.Config.Transparency
        UITheme.Notification.Transparency = Theme.Notification.Transparency
        UITheme.CommandList.Transparency = Theme.Notification.Transparency
    end
    LoadTheme(Theme);
end
--END IMPORT [ui]



--IMPORT [utils]
Utils.Tween = function(Object, Style, Direction, Time, Goal)
    local TweenService = Services.TweenService
    local TInfo = TweenInfo.new(Time, Enum.EasingStyle[Style], Enum.EasingDirection[Direction])
    local Tween = TweenService.Create(TweenService, Object, TInfo, Goal)

    Tween.Play(Tween)

    return Tween
end

Utils.MultColor3 = function(Color, Delta)
    local clamp = math.clamp
    return Color3.new(clamp(Color.R * Delta, 0, 1), clamp(Color.G * Delta, 0, 1), clamp(Color.B * Delta, 0, 1));
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

    AddConnection(CConnect(Object.MouseEnter, function()
        Utils.Tween(Object, "Sine", "Out", .5, Hover);
    end));

    AddConnection(CConnect(Object.MouseLeave, function()
        Utils.Tween(Object, "Sine", "Out", .5, Origin);
    end));

    AddConnection(CConnect(Object.MouseButton1Down, function()
        Utils.Tween(Object, "Sine", "Out", .3, Press);
    end));

    AddConnection(CConnect(Object.MouseButton1Up, function()
        Utils.Tween(Object, "Sine", "Out", .4, Hover);
    end));
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

    Tween = Utils.Tween(Object, "Sine", "Out", .5, Normal)
    CWait(Tween.Completed);
end

Utils.Hover = function(Object, Goal)
    local Hover = {
        [Goal] = Utils.MultColor3(Object[Goal], 0.9)
    }

    local Origin = {
        [Goal] = Object[Goal]
    }

    AddConnection(CConnect(Object.MouseEnter, function()
        Utils.Tween(Object, "Sine", "Out", .5, Hover);
    end));

    AddConnection(CConnect(Object.MouseLeave, function()
        Utils.Tween(Object, "Sine", "Out", .5, Origin);
    end));
end

Utils.Draggable = function(Ui, DragUi)
    local DragSpeed = 0
    local StartPos
    local DragToggle, DragInput, DragStart, DragPos

    DragUi = Dragui or Ui
    local TweenService = Services.TweenService

    local function UpdateInput(Input)
        local Delta = Input.Position - DragStart
        local Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)

        Utils.Tween(Ui, "Linear", "Out", .25, {
            Position = Position
        });
        local Tween = TweenService.Create(TweenService, Ui, TweenInfo.new(0.25), {Position = Position});
        Tween.Play(Tween);
    end

    AddConnection(CConnect(Ui.InputBegan, function(Input)
        if ((Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and Services.UserInputService.GetFocusedTextBox(Services.UserInputService) == nil) then
            DragToggle = true
            DragStart = Input.Position
            StartPos = Ui.Position

            AddConnection(CConnect(Input.Changed, function()
                if (Input.UserInputState == Enum.UserInputState.End) then
                    DragToggle = false
                end
            end));
        end
    end));

    AddConnection(CConnect(Ui.InputChanged, function(Input)
        if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            DragInput = Input
        end
    end));

    AddConnection(CConnect(Services.UserInputService.InputChanged, function(Input)
        if (Input == DragInput and DragToggle) then
            UpdateInput(Input)
        end
    end));
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
        AddConnection(CConnect(GetPropertyChangedSignal(content, prop), function()
            if prop == "ZIndex" then
                -- keep the input frame on top!
                input[prop] = content[prop] + 1
            else
                input[prop] = content[prop]
            end
        end));
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
    local smoothConnection = AddConnection(CConnect(RenderStepped, function()
        local a = content.CanvasPosition
        local b = input.CanvasPosition
        local c = SmoothingFactor
        local d = (b - a) * c + a

        content.CanvasPosition = d
    end));

    AddConnection(CConnect(content.AncestryChanged, function()
        if content.Parent == nil then
            Destroy(input);
            Disconnect(smoothConnection);
        end
    end));
end

Utils.TweenAllTransToObject = function(Object, Time, BeforeObject) -- max transparency is max object transparency, swutched args bc easier command
    local Descendants = GetDescendants(Object);
    local OldDescentants = GetDescendants(BeforeObject);
    local Tween -- to use to wait

    Tween = Utils.Tween(Object, "Sine", "Out", Time, {
        BackgroundTransparency = BeforeObject.BackgroundTransparency
    })

    for i = 1, #Descendants do
        local v = Descendants[i]
        local IsText = IsA(v, "TextBox") or IsA(v, "TextLabel") or IsA(v, "TextButton")
        local IsImage = IsA(v, "ImageLabel") or IsA(v, "ImageButton")
        local IsScrollingFrame = IsA(v, "ScrollingFrame")

        if (IsA(v, "GuiObject")) then
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

    local Descendants = GetDescendants(Object);
    for i = 1, #Descendants do
        local v = Descendants[i]
        local IsText = IsA(v, "TextBox") or IsA(v, "TextLabel") or IsA(v, "TextButton")
        local IsImage = IsA(v, "ImageLabel") or IsA(v, "ImageButton")
        local IsScrollingFrame = IsA(v, "ScrollingFrame")

        if (IsA(v, "GuiObject")) then
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

    local Descendants = GetDescendants(Object);
    for i = 1, #Descendants do
        local v = Descendants[i]
        local IsText = IsA(v, "TextBox") or IsA(v, "TextLabel") or IsA(v, "TextButton")
        local IsImage = IsA(v, "ImageLabel") or IsA(v, "ImageButton")
        local IsScrollingFrame = IsA(v, "ScrollingFrame")

        if (IsA(v, "GuiObject")) then
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

Utils.TextSize = function(Object)
    local TextService = Services.TextService
    return TextService.GetTextSize(TextService, Object.Text, Object.TextSize, Object.Font, Vector2.new(Object.AbsoluteSize.X, 1000)).Y
end

Utils.Notify = function(Caller, Title, Message, Time)
    if (not Caller or Caller == LocalPlayer) then
        local Notification = UI.Notification
        local NotificationBar = UI.NotificationBar

        local Clone = Clone(Notification)

        local function TweenDestroy()
            if (Utils and Clone) then
                local Tween = Utils.TweenAllTrans(Clone, .25)

                CWait(Tween.Completed)
                Destroy(Clone);
            end
        end

        Clone.Message.Text = Message
        Clone.Title.Text = Title or "Notification"
        Utils.SetAllTrans(Clone)
        Utils.Click(Clone.Close, "TextColor3")
        Clone.Visible = true
	    Clone.Size = UDim2.fromOffset(Clone.Size.X.Offset, Utils.TextSize(Clone.Message) + Clone.Size.Y.Offset - Clone.Message.TextSize);
        Clone.Parent = NotificationBar

        coroutine.wrap(function()
            local Tween = Utils.TweenAllTransToObject(Clone, .5, Notification)

            CWait(Tween.Completed);
            wait(Time or 5);

            if (Clone) then
                TweenDestroy();
            end
        end)()

        AddConnection(CConnect(Clone.Close.MouseButton1Click, TweenDestroy));
        if (Title ~= "Warning" and Title ~= "Error") then
            Utils.Print(format("%s - %s", Title, Message), Caller, true);
        end

        return Clone
    else
        local ChatRemote = Services.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
        ChatRemote.FireServer(ChatRemote, format("/w %s [FA] %s: %s", Caller.Name, Title, Message), "All");
    end
end

Utils.MatchSearch = function(String1, String2)
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
    local SpecialCases = {"all", "others", "random", "me", "nearest", "farthest", "npcs", "allies", "enemies"}
    if (Utils.StringFind(SpecialCases, Arg)) then
        return Utils.StringFind(SpecialCases, Arg);
    end

    local CurrentPlayers = GetPlayers(Players);
    for i, v in next, CurrentPlayers do
        local Name, DisplayName = v.Name, v.DisplayName
        if (Name ~= DisplayName and Utils.MatchSearch(Arg, lower(DisplayName))) then
            return lower(DisplayName);
        end
        if (Utils.MatchSearch(Arg, lower(Name))) then
            return lower(Name);
        end
    end
end

Utils.ToolTip = function(Object, Message)
    local CloneToolTip
    local TextService = Services.TextService

    AddConnection(CConnect(Object.MouseEnter, function()
        if (Object.BackgroundTransparency < 1 and not CloneToolTip) then
            local TextSize = TextService.GetTextSize(TextService, Message, 12, Enum.Font.Gotham, Vector2.new(200, math.huge)).Y > 24

            CloneToolTip = Clone(UI.ToolTip)
            CloneToolTip.Text = Message
            CloneToolTip.TextScaled = TextSize
            CloneToolTip.Visible = true
            CloneToolTip.Parent = UI
        end
    end))

    AddConnection(CConnect(Object.MouseLeave, function()
        if (CloneToolTip) then
            Destroy(CloneToolTip);
            CloneToolTip = nil
        end
    end))

    if (LocalPlayer) then
        AddConnection(CConnect(Mouse.Move, function()
            if (CloneToolTip) then
                CloneToolTip.Position = UDim2.fromOffset(Mouse.X + 10, Mouse.Y + 10)
            end
        end))
    else
        delay(3, function()
            LocalPlayer = Players.LocalPlayer
            AddConnection(CConnect(Mouse.Move, function()
                if (CloneToolTip) then
                    CloneToolTip.Position = UDim2.fromOffset(Mouse.X + 10, Mouse.Y + 10)
                end
            end))
        end)
    end
end

Utils.ClearAllObjects = function(Object)
    local Children = GetChildren(Object);
    for i = 1, #Children do
        local Child = Children[i]
        if (IsA(Child, "GuiObject")) then
            Destroy(Child);
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
            Strings[#Strings + 1] = Character
        else
            TotalCharacters = TotalCharacters + 1
            Strings[#Strings + 1] = {'<font color="rgb(%i, %i, %i)">' .. Character .. '</font>'}
        end
    end

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

        TextObject.Text = String .. " "
    end));
    delay(150, function()
        Disconnect(Connection);
    end)

end

Utils.Vector3toVector2 = function(Vector)
    local Tuple = WorldToViewportPoint(Camera, Vector);
    return Vector2New(Tuple.X, Tuple.Y);
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

    local Added = AddConnection(CConnect(Tag.Player.CharacterAdded, function()
        Billboard.Adornee = WaitForChild(Tag.Player.Character, "Head");
    end));

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

Utils.Thing = function(Object)
    local Container = InstanceNew("Frame");
    local Hitbox = InstanceNew("ImageButton");
    local UDim2fromOffset = UDim2.fromOffset

    Container.Name = "Container"
    Container.Parent = Object.Parent
    Container.BackgroundTransparency = 1.000
    Container.BorderSizePixel = 0
    Container.Position = Object.Position
    Container.ClipsDescendants = true
    Container.Size = UDim2fromOffset(Object.AbsoluteSize.X, Object.AbsoluteSize.Y);
    Container.ZIndex = Object
    
    Object.AutomaticSize = Enum.AutomaticSize.X
    Object.Size = UDim2.fromScale(1, 1)
    Object.Position = UDim2.fromScale(0, 0)
    Object.Parent = Container
    Object.TextTruncate = Enum.TextTruncate.None
    Object.ZIndex = Object.ZIndex + 2
    
    Hitbox.Name = "Hitbox"
    Hitbox.Parent = Container.Parent
    Hitbox.BackgroundTransparency = 1.000
    Hitbox.Size = Container.Size
    Hitbox.Position = Container.Position
    Hitbox.ZIndex = Object.ZIndex + 2
    
    local MouseOut = true
    
    AddConnection(CConnect(Hitbox.MouseEnter, function()
        if Object.AbsoluteSize.X > Container.AbsoluteSize.X then
            MouseOut = false
            repeat
                local Tween1 = Utils.Tween(Object, "Quad", "Out", .5, {
                    Position = UDim2fromOffset(Container.AbsoluteSize.X - Object.AbsoluteSize.X, 0);
                })
                CWait(Tween1.Completed);
                wait(.5);
                local Tween2 = Utils.Tween(Object, "Quad", "Out", .5, {
                    Position = UDim2fromOffset(0, 0);
                })
                CWait(Tween2.Completed);
                wait(.5);
            until MouseOut
        end
    end))

    AddConnection(CConnect(Hitbox.MouseLeave, function()
        MouseOut = true
        Utils.Tween(Object, "Quad", "Out", .25, {
            Position = UDim2fromOffset(0, 0);
        });
    end))
    
    return Object
end

function Utils.Intro(Object)
	local Frame = InstanceNew("Frame");
	local UICorner = InstanceNew("UICorner");
	local CornerRadius = FindFirstChild(Object, "UICorner") and Object.UICorner.CornerRadius or UDim.new(0, 0)
    local UDim2fromOffset  = UDim2.fromOffset

	Frame.Name = "IntroFrame"
	Frame.ZIndex = 1000
	Frame.Size = UDim2fromOffset(Object.AbsoluteSize.X, Object.AbsoluteSize.Y)
	Frame.AnchorPoint = Vector2.new(.5, .5)
	Frame.Position = UDim2.new(Object.Position.X.Scale, Object.Position.X.Offset + (Object.AbsoluteSize.X / 2), Object.Position.Y.Scale, Object.Position.Y.Offset + (Object.AbsoluteSize.Y / 2))
	Frame.BackgroundColor3 = Object.BackgroundColor3
	Frame.BorderSizePixel = 0

	UICorner.CornerRadius = CornerRadius
	UICorner.Parent = Frame

	Frame.Parent = Object.Parent

	if (Object.Visible) then
		Frame.BackgroundTransparency = 1

		local Tween = Utils.Tween(Frame, "Quad", "Out", .25, {
			BackgroundTransparency = 0
		});

		CWait(Tween.Completed);
		Object.Visible = false

		local Tween = Utils.Tween(Frame, "Quad", "Out", .25, {
			Size = UDim2fromOffset(0, 0);
		});

		Utils.Tween(UICorner, "Quad", "Out", .25, {
			CornerRadius = UDim.new(1, 0)
		});

		CWait(Tween.Completed);
		Destroy(Frame);
	else
		Frame.Visible = true
		Frame.Size = UDim2fromOffset(0, 0)
		UICorner.CornerRadius = UDim.new(1, 0)

		local Tween = Utils.Tween(Frame, "Quad", "Out", .25, {
			Size = UDim2fromOffset(Object.AbsoluteSize.X, Object.AbsoluteSize.Y)
		});

		Utils.Tween(UICorner, "Quad", "Out", .25, {
			CornerRadius = CornerRadius
		});

		CWait(Tween.Completed);
		Object.Visible = true

		local Tween = Utils.Tween(Frame, "Quad", "Out", .25, {
			BackgroundTransparency = 1
		})

		CWait(Tween.Completed);
		Destroy(Frame);
	end
end

Utils.MakeGradient = function(ColorTable)
	local Table = {}
    local ColorSequenceKeypointNew = ColorSequenceKeypoint.new
	for Time, Color in next, ColorTable do
		Table[#Table + 1] = ColorSequenceKeypointNew(Time - 1, Color);
	end
	return ColorSequence.new(Table)
end

Utils.Debounce = function(Func)
	local Debounce = false

	return function(...)
		if (not Debounce) then
			Debounce = true
			Func(...);
			Debounce = false
		end
	end
end

Utils.ToggleFunction = function(Container, Enabled, Callback) -- fpr color picker
    local Switch = Container.Switch
    local Hitbox = Container.Hitbox
    local Color3fromRGB = Color3.fromRGB
    local UDim2fromOffset = UDim2.fromOffset

    Container.BackgroundColor3 = Color3fromRGB(255, 79, 87);

    if not Enabled then
        Switch.Position = UDim2fromOffset(2, 2)
        Container.BackgroundColor3 = Color3fromRGB(25, 25, 25);
    end

    AddConnection(CConnect(Hitbox.MouseButton1Click, function()
        Enabled = not Enabled
        
        Utils.Tween(Switch, "Quad", "Out", .25, {
            Position = Enabled and UDim2.new(1, -18, 0, 2) or UDim2fromOffset(2, 2)
        });
        Utils.Tween(Container, "Quad", "Out", .25, {
            BackgroundColor3 = Enabled and Color3fromRGB(255, 79, 87) or Color3fromRGB(25, 25, 25);
        });
        
        Callback(Enabled);
    end));
end

do
    local AmountPrint, AmountWarn, AmountError = 0, 0, 0;

    Utils.Warn = function(Text, Plr)
        local TimeOutputted = os.date("%X");
        local Clone = Clone(UI.MessageOut);
    
        Clone.Name = "W" .. tostring(AmountWarn + 1);
        Clone.Text = format("%s -- %s", TimeOutputted, Text);
        Clone.TextColor3 = Color3.fromRGB(255, 218, 68);
        Clone.Visible = true
        Clone.TextTransparency = 1
        Clone.Parent = Console.Frame.List
    
        Utils.Tween(Clone, "Sine", "Out", .25, {
            TextTransparency = 0
        })
    
        Console.Frame.List.CanvasSize = UDim2.fromOffset(0, Console.Frame.List.UIListLayout.AbsoluteContentSize.Y);
        AmountWarn = AmountWarn + 1
        Utils.Notify(Plr, "Warning", Text);
    end
    
    Utils.Error = function(Text, Caller, FromNotif)
        local TimeOutputted = os.date("%X");
        local Clone = Clone(UI.MessageOut);
    
        Clone.Name = "E" .. tostring(AmountError + 1);
        Clone.Text = format("%s -- %s", TimeOutputted, Text);
        Clone.TextColor3 = Color3.fromRGB(215, 90, 74);
        Clone.Visible = true
        Clone.TextTransparency = 1
        Clone.Parent = Console.Frame.List
    
        Utils.Tween(Clone, "Sine", "Out", .25, {
            TextTransparency = 0
        })
    
        Console.Frame.List.CanvasSize = UDim2.fromOffset(0, Console.Frame.List.UIListLayout.AbsoluteContentSize.Y);
        AmountError = AmountError + 1
    end
    
    Utils.Print = function(Text, Caller, FromNotif)
        local TimeOutputted = os.date("%X");
        local Clone = Clone(UI.MessageOut);
    
        Clone.Name = "P" .. tostring(AmountPrint + 1);
        Clone.Text = format("%s -- %s", TimeOutputted, Text);
        Clone.Visible = true
        Clone.TextTransparency = 1
        Clone.Parent = Console.Frame.List
    
        Utils.Tween(Clone, "Sine", "Out", .25, {
            TextTransparency = 0
        })
    
        Console.Frame.List.CanvasSize = UDim2.fromOffset(0, Console.Frame.List.UIListLayout.AbsoluteContentSize.Y);
        AmountPrint = AmountPrint + 1
        if (len(Text) <= 35 and not FromNotif) then
            Utils.Notify(Caller, "Output", Text);
        end
    end
end
--END IMPORT [utils]



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
                    Utils.Warn("You are missing something that is needed for this command", LocalPlayer);
                    return nil
                elseif (type(v) == 'number' and CommandRequirements[v].Func() == false) then
                    Utils.Warn(CommandRequirements[v].Message, LocalPlayer);
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
            return Utils.Warn(format("Insuficient Args (you need %d)", Command.ArgsNeeded), LocalPlayer);
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
                Utils.Error(format("[FA CMD Error]: Command = '%s' Traceback = '%s'", Name, debug.traceback(Err)), Caller);
                Utils.Notify(Caller, "Error", format("error in the '%s' command, more info shown in console", Name));
            end
        end);
        if (Command.IsPlugin and sett and PluginConf.SafePlugins and Context) then
            sett(Context);
        end
    else
        Utils.Warn("couldn't find the command " .. Name, Caller);
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
        return 'CFrame.new('..concat(components, ', ')..')'
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
    local WindowFocused = true
    AddConnection(CConnect(UserInputService.WindowFocusReleased, function()
        WindowFocused = false
    end));
    AddConnection(CConnect(UserInputService.WindowFocused, function()
        WindowFocused = true
    end));
    local GetFocusedTextBox = UserInputService.GetFocusedTextBox
    AddConnection(CConnect(UserInputService.InputBegan, function(Input, GameProcessed)
        Keys["GameProcessed"] = GameProcessed and WindowFocused and not (not GetFocusedTextBox(UserInputService));
        Keys["LastEntered"] = Input.KeyCode
        if (GameProcessed) then return end
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

        if (Input.KeyCode == Enum.KeyCode.F8) then
            if (Console.Visible) then
                local Tween = Utils.TweenAllTrans(Console, .25)
                CWait(Tween.Completed);
                Console.Visible = false
            else
                local MessageClone = Clone(Console.Frame.List);
    
                Utils.ClearAllObjects(Console.Frame.List)
                Console.Visible = true
            
                local Tween = Utils.TweenAllTransToObject(Console, .25, ConsoleTransparencyClone)
            
                Destroy(Console.Frame.List)
                MessageClone.Parent = Console.Frame
            
                for i, v in next, GetChildren(Console.Frame.List) do
                    if (not IsA(v, "UIListLayout")) then
                        Utils.Tween(v, "Sine", "Out", .25, {
                            TextTransparency = 0
                        })
                    end
                end
            
                local ConsoleListLayout = Console.Frame.List.UIListLayout
            
                CConnect(GetPropertyChangedSignal(ConsoleListLayout, "AbsoluteContentSize"), function()
                    local CanvasPosition = Console.Frame.List.CanvasPosition
                    local CanvasSize = Console.Frame.List.CanvasSize
                    local AbsoluteSize = Console.Frame.List.AbsoluteSize
            
                    if (CanvasSize.Y.Offset - AbsoluteSize.Y - CanvasPosition.Y < 20) then
                       wait();
                       Console.Frame.List.CanvasPosition = Vector2.new(0, CanvasSize.Y.Offset + 1000);
                    end
                end)
            
                Utils.Tween(Console.Frame.List, "Sine", "Out", .25, {
                    ScrollBarImageTransparency = 0
                })
            end
        end
    end));
    AddConnection(CConnect(UserInputService.InputEnded, function(Input, GameProcessed)
        if (GameProcessed) then return end
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

AddCommand("walkspeed", {"ws", "speed"}, "changes your walkspeed to the second argument", {}, function(Caller, Args, CEnv)
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
    SpoofProperty(Humanoid, "UseJumpPower");
    Humanoid.UseJumpPower = true
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

_L.KillCam = {};
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
    if (_L.KillCam and #Target == 1 and TChar) then
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

AddCommand("invisible", {"invis"}, "makes yourself invisible", {3}, function(Caller, Args, CEnv)
    local Root = GetRoot();
    local OldPos = Root.CFrame
    local Seat = InstanceNew("Seat");
    local Weld = InstanceNew("Weld");
    Root.CFrame = CFrameNew(9e9, 9e9, 9e9);
    wait(.2);
    Root.Anchored = true
    ProtectInstance(Seat);
    Seat.Parent = Services.Workspace
    Seat.CFrame = Root.CFrame
    Seat.Anchored = false
    Weld.Parent = Seat
    Weld.Part0 = Seat
    Weld.Part1 = Root
    Root.Anchored = false
    Seat.CFrame = OldPos
    CEnv.Seat = Seat
    CEnv.Weld = Weld
    for i, v in next, GetChildren(Root.Parent) do
        if (IsA(v, "BasePart") or IsA(v, "MeshPart") or IsA(v, "Part")) then
            CEnv[v] = v.Transparency
            v.Transparency = v.Transparency <= 0.3 and 0.4 or v.Transparency
        elseif (IsA(v, "Accessory")) then
            local Handle = FindFirstChildWhichIsA(v, "MeshPart") or FindFirstChildWhichIsA(v, "Part");
            if (Handle) then
                CEnv[Handle] = Handle.Transparency
                Handle.Transparency = Handle.Transparency <= 0.3 and 0.4 or Handle.Transparency    
            end
        end
    end
    return "you are now invisible"
end)

AddCommand("uninvisible", {"uninvis", "noinvis", "visible", "vis"}, "gives you back visiblity", {3}, function(Caller, Args, CEnv)
    local CmdEnv = LoadCommand("invisible").CmdEnv
    local Seat = CmdEnv.Seat
    local Weld = CmdEnv.Weld
    if (Seat and Weld) then
        Weld.Part0 = nil
        Weld.Part1 = nil
        Destroy(Seat);
        Destroy(Weld);
        CmdEnv.Seat = nil
        CmdEnv.Weld = nil
        for i, v in next, CmdEnv do
            if (type(v) == 'number') then
                i.Transparency = v
            end
        end
        return "you are now visible"
    end
    return "you are already visible"
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

AddCommand("dupetools2", {"rejoindupe", "dupe2"}, "sometimes a faster dupetools", {1,"1"}, function(Caller, Args)
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
                    local Handle = WaitForChild(v, "Handle", .5);
                    if (Handle) then
                        firetouchinterest(Handle, RootPart, 0);
                        firetouchinterest(Handle, RootPart, 1);
                    end
                end
            end
            delfile("fates-admin/tooldupe.txt");
            delfile("fates-admin/tooldupe.lua");
            loadstring(game.HttpGet(game, "https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua"))();
            RootPart.CFrame = OldPos
            repeat wait() RootPart.CFrame = OldPos until RootPart.CFrame == OldPos
            getgenv().F_A.PluginLibrary.ExecuteCommand("dp", {"1"}, LocalPlayer);
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

AddCommand("listento", {"listen"}, "Listens to the area around the player (cool with vc)", {}, function(Caller, Args)
    local Target = GetPlayer(Args[1])
    local Part = GetRoot(Target[1])
    if Part then
        Services.SoundService:SetListener(Enum.ListenerType.ObjectPosition, Part)
        AddConnection(CConnect(Target[1].CharacterRemoving, function()
            Services.SoundService:SetListener(Enum.ListenerType.Camera)
            Utils.Notify(Caller, "Listening stopped", "Character has been removed")
        end), CEnv)
    end
end)

AddCommand("unlisten", {} ,"reverts the changes from listento", {}, function(Caller, Args)
    DisableAllCmdConnections("listento")
    Services.SoundService:SetListener(Enum.ListenerType.Camera)
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
    local FPS = 1 / CWait(RenderStepped);
    local Counter = Utils.Notify(LocalPlayer, "FPS", round(FPS));
    local Running;
    delay(4.5, function()
        Disconnect(Running);
    end);
    Running = CConnect(Heartbeat, function()
        if (not Counter or not Counter.Message) then
            Disconnect(Running);
        end
        Counter.Message.Text = round(1 / CWait(RenderStepped));
    end);
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

AddCommand("fling", {"stan"}, "flings a player", {}, function(Caller, Args)
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

AddCommand("fling2", {"stan2"}, "another variant of fling", {}, function(Caller, Args)
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
    if (Tool) then
        local GripPos = Vector3New(tonumber(Args[1]), tonumber(Args[2]), tonumber(Args[3]));
        if (Args[4]) then
            for i, v in next, tbl_concat(GetChildren(LocalPlayer.Backpack), GetChildren(LocalPlayer.Character)) do
                if (IsA(v, "Tool")) then
                    SpoofProperty(Tool, "GripPos");
                    Tool.GripPos = GripPos
                end
            end
        end
        SpoofProperty(Tool, "GripPos");
        Tool.GripPos = GripPos
        Tool.Parent = GetCharacter();
        return "grippos set"
    else
        return "no tool to set grippos"
    end
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
    Services.CoreGui.PurchasePrompt.Enabled = false
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

    _L.GlobalChatLogsEnabled = true
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
            if (_L.GlobalChatLogsEnabled) then
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
            if (_L.GlobalChatLogsEnabled) then
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

    local AddLog = function(reqType, url, Req)
        if (getgenv().F_A and UI) then
            local Clone = Clone(ChatLogMessage);
            Clone.Text = format("%s\nUrl: %s%s\n", Utils.TextFont(reqType .. " Detected (time: " .. tostring(os.date("%X")) ..")", {255, 165, 0}), url, Req and ", RequestPayLoad: " .. Utils.TextFont(Req, {255, 255, 0}) or "");
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
    if (game.HttpGet ~= game.HttpGetAsync) then
        local HttpgetAsync;
        HttpgetAsync = hookfunction(game.HttpGetAsync, newcclosure(function(self, url)
            AddLog("HttpGetAsync", url);
            return HttpgetAsync(self, url);
        end));
    end
    local Httppost;
    Httppost = hookfunction(game.HttpPost, newcclosure(function(self, url)
        AddLog("HttpPost", url);
        return Httppost(self, url);
    end));
    if (game.HttpPost ~= game.HttpPostAsync) then
        local HttppostAsync;
        HttppostAsync = hookfunction(game.HttpPostAsync, newcclosure(function(self, url)
            AddLog("HttpPostAsync", url);
            return HttppostAsync(self, url);
        end));
    end

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
        -- ProtectInstance(Bin);
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
        if (Caller ~= LocalPlayer) then
            ExecuteCommand("bring", {Caller.Name, v.Name}, LocalPlayer)
        else
            GetRoot().CFrame = GetRoot(v).CFrame * CFrameNew(-5, 0, 0);
        end
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
    local IdleAnim1 = "507766388"

    local Character = GetCharacter();
    local Animate = FindFirstChild(Character, "Animate");

    if (Animate) then
        CEnv.Animate = Animate
        Animate.Disabled = true
    end

    SpoofInstance(Root, isR6() and Character.Torso or Character.UpperTorso);
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
    for i, v in pairs(Humanoid:GetPlayingAnimationTracks()) do
        v:Stop();
    end
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
    local FlyCEnv = LoadCommand("fly").CmdEnv
    if (FlyCEnv.Animate) then
        FlyCEnv.Animate.Disabled = false
        FlyCEnv.Animate = nil
    end
    DisableAllCmdConnections("fly");
    table.clear(FlyCEnv);
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
    local Torso = isR6() and Char.Torso or Char.UpperTorso
    local Noclipping2 = AddConnection(CConnect(Torso.Touched, function(Part)
        if (Part and Part.CanCollide and not FindFirstChildWhichIsA(Part.Parent, "Humanoid")) then
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
            LocalPlayer:Kick();
            TeleportService.Teleport(TeleportService, game.PlaceId);
        else
            TeleportService.TeleportToPlaceInstance(TeleportService, game.PlaceId, game.JobId)
        end
        return "Rejoining..."
    end
end)

AddCommand("serverhop", {"sh"}, "switches servers (optional: min, max (default: max))", {{"min", "max"}}, function(Caller, Args)
    if (Caller == LocalPlayer) then
        Utils.Notify(Caller or LocalPlayer, "Command", "Looking for servers...");
        local order = ""
        local Option, Server = lower(Args[1] or "max");
        if Option == "min" then
            order = "Asc"
        elseif Option == "max" then
            order = "Desc"
        end;

        local Servers = {};
        local url = format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=100", game.PlaceId, order);
        local starting = tick();
        repeat
            local good, result = pcall(function()
                return game:HttpGet(url);
            end);
            if (not good) then
                wait(2);
                continue;
            end
            local decoded = Services.HttpService:JSONDecode(result);
            if (#decoded.data ~= 0) then
                Servers = decoded.data
                for i, v in pairs(Servers) do
                    if (v.maxPlayers and v.playing and v.maxPlayers > v.playing and v.id ~= game.JobId) then
                        Server = v
                        break;
                    end
                end
                if (Server) then
                    break;
                end
            end
            url = format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=100&cursor=%s", game.PlaceId, order, decoded.nextPageCursor);
        until tick() - starting >= 600;
        if (not Server or #Servers == 0) then
            return "no servers found";
        end

        local queue_on_teleport = syn and syn.queue_on_teleport or queue_on_teleport
        if (queue_on_teleport and not Args[2]) then
            queue_on_teleport("loadstring(game.HttpGet(game, \"https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua\"))()");
        end;

        Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, Server.id);    
        return format("joining server (%d/%d players)", Server.playing, Server.maxPlayers);
    end
end);

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
        Utils.Print(format("Author: %s\nDate: %s\nMessage: %s", v.Author, v.Date, v.Message));
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
    if (not _L.CLI) then
        _L.CLI = true
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
    if (_L.CLI) then
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
    ToggleChatPrediction();
    local ChatBar = WaitForChild(_L.Frame2, "ChatBar", .1);
    ChatBar.CaptureFocus(ChatBar);
    wait();
    ChatBar.Text = Prefix
    return "chat prediction enabled"
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
        Root.CFrame = CFrameNew(TRoot.Position + Vector3New(sin(tick() * Speed) * Radius, 0, cos(tick() * Speed) * Radius), TRoot.Position);
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
        AddConnection(CConnect(UserInputService.InputChanged, ProcessInput));
        AddConnection(CConnect(UserInputService.InputEnded, ProcessInput));
        AddConnection(CConnect(UserInputService.InputBegan, ProcessInput));
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
            end));

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
            end), CEnv.Connections);

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

AddCommand("freecamgoto", {"fcgoto"}, "takes your freecam to t hem", {"1"}, function(Caller, Args)
    local Target = GetPlayer(Args[1]);
    local Delay = tonumber(Args[2]);
    for i, v in next, Target do
        if (Delay) then
            wait(Delay);
        end
        Camera.CFrame = GetRoot(v).CFrame * CFrameNew(0, 10, 10);
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
    for i, v in next, getconnections(LocalPlayer.Idled, true) do
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
    Tool.Parent = GetCharacter();
    AddConnection(CConnect(Tool.Activated, function()
        local Hit = Mouse.Hit
        GetRoot().CFrame = Hit * CFrame.new(0, 3, 0);
    end))

    local Tool2 = InstanceNew("Tool");
    Tool2.RequiresHandle = false
    Tool2.Name = "Click TweenTP"
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

AddCommand("setzoomdistance", {"szd", "maxzoom"}, "sets your cameras zoom distance so you can zoom out", {}, function(Caller, Args)
    local ZoomDistance = tonumber(Args[1]) or 1000
    LocalPlayer.CameraMaxZoomDistance = ZoomDistance
    LocalPlayer.CameraMode = Enum.CameraMode.Classic
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
    Args = shift(Args);
    CEnv.Looping = true
    CEnv.LoopedCommands = CEnv.LoopedCommands or {}
    CEnv.LoopedCommands[Command] = true
    CThread(function()
        while (CEnv.Looping and CEnv.LoopedCommands[Command]) do
            ExecuteCommand(Command, Args, Caller);
            wait(tonumber(Args[#Args]) or 1);
        end
    end)();
    return format("now looping the %s command", Command);
end)

AddCommand("unloop", {"unloopcommand"}, "unloops a command", {}, function(Caller, Args)
    local Looped = LoadCommand("loop").CmdEnv
    if (Args[1]) then
        if (Looped.LoopedCommands[Args[1]]) then
            Looped.LoopedCommands[Args[1]] = nil
            return format("unlooped command %s", Args[1]);
        end
        return "command isn't looped"
    else
        Looped.Looping = false
        return "unlooped all commands looped"
    end
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

--AddCommand("dex", {"darkdex"}, "A quick way to execute dark dex from the synapse script hub.", {}, loadstring(game:HttpGet("https://cdn.synapse.to/synapsedistro/hub/DarkDex.lua")));

AddCommand("console", {"errors", "warns", "outputs"}, "shows the outputs fates admin has made", {}, function()
    local MessageClone = Clone(Console.Frame.List);
    
    Utils.ClearAllObjects(Console.Frame.List)
    Console.Visible = true

    local Tween = Utils.TweenAllTransToObject(Console, .25, ConsoleTransparencyClone)

    Destroy(Console.Frame.List)
    MessageClone.Parent = Console.Frame

    for i, v in next, GetChildren(Console.Frame.List) do
        if (not IsA(v, "UIListLayout")) then
            Utils.Tween(v, "Sine", "Out", .25, {
                TextTransparency = 0
            })
        end
    end

    local ConsoleListLayout = Console.Frame.List.UIListLayout

    CConnect(GetPropertyChangedSignal(ConsoleListLayout, "AbsoluteContentSize"), function()
        local CanvasPosition = Console.Frame.List.CanvasPosition
        local CanvasSize = Console.Frame.List.CanvasSize
        local AbsoluteSize = Console.Frame.List.AbsoluteSize

        if (CanvasSize.Y.Offset - AbsoluteSize.Y - CanvasPosition.Y < 20) then
           wait();
           Console.Frame.List.CanvasPosition = Vector2.new(0, CanvasSize.Y.Offset + 1000);
        end
    end)

    Utils.Tween(Console.Frame.List, "Sine", "Out", .25, {
        ScrollBarImageTransparency = 0
    })
end)

task.spawn(function()
    local chatted = function(plr, raw)
        local message = raw

        if (_L.ChatLogsEnabled) then

            local time = os.date("%X");
            local Text = format("%s - [%s]: %s", time, plr.Name, raw);
            local Clone = Clone(ChatLogMessage);

            Clone.Text = Text
            Clone.Visible = true
            Clone.TextTransparency = 1
            Clone.Parent = ChatLogs.Frame.List

            Utils.Tween(Clone, "Sine", "Out", .25, {
                TextTransparency = 0
            })

            ChatLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, ChatLogs.Frame.List.UIListLayout.AbsoluteContentSize.Y);
        end

        if (startsWith(raw, "/e")) then
            raw = sub(raw, 4);
        elseif (startsWith(raw, "/w")) then
            raw = shift(shift(split(message, " ")));
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
    end

    CConnect(LocalPlayer.Chatted, function(raw)
        chatted(LocalPlayer, raw);
    end);

    if (Services.TextChatService.ChatVersion == Enum.ChatVersion.TextChatService) then
        Services.TextChatService.OnIncomingMessage = function(message)
            chatted(Services.Players:FindFirstChild(message.TextSource.Name), message.Text);
        end
        return;
    end

    local DefaultChatSystemChatEvents = Services.ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents");
    if (not DefaultChatSystemChatEvents) then return; end
    local OnMessageDoneFiltering = DefaultChatSystemChatEvents:WaitForChild("OnMessageDoneFiltering", 5);
    if (not OnMessageDoneFiltering) then return; end
    if (typeof(OnMessageDoneFiltering) ~= "Instance" or OnMessageDoneFiltering.ClassName ~= "RemoteEvent") then return; end


    CConnect(OnMessageDoneFiltering.OnClientEvent, function(messageData)
        if (type(messageData) ~= "table") then return; end
        local plr = Services.Players:FindFirstChild(messageData.FromSpeaker);
        local raw = messageData.Message
        if (not plr or not raw or plr == LocalPlayer) then return; end

        if (messageData.OriginalChannel == "Team") then
            raw = "/team " .. raw
        else
            local whisper = string.match(messageData.OriginalChannel, "To (.+)");
            if (whisper) then
                raw = string.format("/w %s %s", whisper, raw);
            end
        end

        chatted(plr, raw);
    end);

end);

--IMPORT [uimore]
Notification.Visible = false
Utils.SetAllTrans(CommandBar);
Utils.SetAllTrans(ChatLogs);
Utils.SetAllTrans(GlobalChatLogs);
Utils.SetAllTrans(HttpLogs);
Utils.SetAllTrans(Console);
Commands.Visible = false
ChatLogs.Visible = false
Console.Visible = false
GlobalChatLogs.Visible = false
HttpLogs.Visible = false

Utils.Draggable(Commands);
Utils.Draggable(ChatLogs);
Utils.Draggable(Console);
Utils.Draggable(GlobalChatLogs);
Utils.Draggable(HttpLogs);
Utils.Draggable(ConfigUI);

ParentGui(UI);
Connections.UI = {}

local Times = #LastCommand
AddConnection(CConnect(Services.UserInputService.InputBegan, function(Input, GameProccesed)
    if (Input.KeyCode == CommandBarPrefix and (not GameProccesed)) then
        CommandBarOpen = not CommandBarOpen

        local TransparencyTween = CommandBarOpen and Utils.TweenAllTransToObject or Utils.TweenAllTrans
        local Tween = TransparencyTween(CommandBar, .5, CommandBarTransparencyClone);
        local UserInputService = Services.UserInputService

        if (CommandBarOpen) then
            if (not Draggable) then
                Utils.Tween(CommandBar, "Quint", "Out", .5, {
                    Position = UDim2.new(0.5, WideBar and -200 or -100, 1, -110)
                })
            end

            CommandBar.Input.CaptureFocus(CommandBar.Input);
            CThread(function()
                wait()
                CommandBar.Input.Text = ""
                FocusedTextBox = UserInputService.GetFocusedTextBox(UserInputService);
                local TextBox = CommandBar.Input
                while (FocusedTextBox ~= TextBox) do
                    FocusedTextBox.ReleaseFocus(FocusedTextBox);
                    CommandBar.Input.CaptureFocus(TextBox);
                    FocusedTextBox = UserInputService.GetFocusedTextBox(UserInputService);
                    CWait(Heartbeat);
                end
            end)()
        else
            if (not Draggable) then
                Utils.Tween(CommandBar, "Quint", "Out", .5, {
                    Position = UDim2.new(0.5, WideBar and -200 or -100, 1, 5)
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

Utils.Click(Console.Clear, "BackgroundColor3");
Utils.Click(Console.Save, "BackgroundColor3");
Utils.Click(Console.Close, "TextColor3");

Utils.Click(GlobalChatLogs.Clear, "BackgroundColor3")
Utils.Click(GlobalChatLogs.Save, "BackgroundColor3")
Utils.Click(GlobalChatLogs.Toggle, "BackgroundColor3")
Utils.Click(GlobalChatLogs.Close, "TextColor3")

Utils.Click(HttpLogs.Clear, "BackgroundColor3")
Utils.Click(HttpLogs.Save, "BackgroundColor3")
Utils.Click(HttpLogs.Toggle, "BackgroundColor3")
Utils.Click(HttpLogs.Close, "TextColor3")

AddConnection(CConnect(Commands.Close.MouseButton1Click, function()
    local Tween = Utils.TweenAllTrans(Commands, .25)

    CWait(Tween.Completed);
    Commands.Visible = false
end), Connections.UI, true);

AddConnection(CConnect(GetPropertyChangedSignal(Commands.Search, "Text"), function()
    local Text = Commands.Search.Text
    local Children = GetChildren(Commands.Frame.List);
    for i = 1, #Children do
        local v = Children[i]
        if (IsA(v, "Frame")) then
            local Command = v.CommandText.Text
            v.Visible = Sfind(lower(Command), Text, 1, true)
        end
    end
    Commands.Frame.List.CanvasSize = UDim2.fromOffset(0, Commands.Frame.List.UIListLayout.AbsoluteContentSize.Y)
end), Connections.UI, true);

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

AddConnection(CConnect(Console.Close.MouseButton1Click, function()
    local Tween = Utils.TweenAllTrans(Console, .25)

    CWait(Tween.Completed);
    Console.Visible = false
end), Connections.UI, true);

ChatLogs.Toggle.Text = _L.ChatLogsEnabled and "Enabled" or "Disabled"
GlobalChatLogs.Toggle.Text = _L.ChatLogsEnabled and "Enabled" or "Disabled"
HttpLogs.Toggle.Text = _L.HttpLogsEnabled and "Enabled" or "Disabled"

AddConnection(CConnect(ChatLogs.Toggle.MouseButton1Click, function()
    _L.ChatLogsEnabled = not _L.ChatLogsEnabled
    ChatLogs.Toggle.Text = _L.ChatLogsEnabled and "Enabled" or "Disabled"
end), Connections.UI, true);
AddConnection(CConnect(GlobalChatLogs.Toggle.MouseButton1Click, function()
    _L.GlobalChatLogsEnabled = not _L.GlobalChatLogsEnabled
    GlobalChatLogs.Toggle.Text = _L.GlobalChatLogsEnabled and "Enabled" or "Disabled"
end), Connections.UI, true);
AddConnection(CConnect(HttpLogs.Toggle.MouseButton1Click, function()
    _L.HttpLogsEnabled = not _L.HttpLogsEnabled
    HttpLogs.Toggle.Text = _L.HttpLogsEnabled and "Enabled" or "Disabled"
end), Connections.UI, true);

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

AddConnection(CConnect(Console.Clear.MouseButton1Click, function()
    Utils.ClearAllObjects(Console.Frame.List);
    Console.Frame.List.CanvasSize = UDim2.fromOffset(0, 0);
end), Connections.UI, true);

do
    local ShowWarns, ShowErrors, ShowOutput = true, true, true
    AddConnection(CConnect(Console.Warns.MouseButton1Click, function()
        ShowWarns = not ShowWarns
        local Children = GetChildren(Console.Frame.List);
        for i = 1, #Children do
            local v = Children[i]
            if (not IsA(v, "UIListLayout") and sub(v.Name, 1, 1) == "W") then
                v.Visible = ShowWarns
            end
        end
        Console.Frame.List.CanvasSize = UDim2.fromOffset(0, Console.Frame.List.UIListLayout.AbsoluteContentSize.Y);
        Console.Warns.Text = ShowWarns and "Hide Warns" or "Show Warns"
    end), Connections.UI, true);
    AddConnection(CConnect(Console.Errors.MouseButton1Click, function()
        ShowErrors = not ShowErrors
        local Children = GetChildren(Console.Frame.List);
        for i = 1, #Children do
            local v = Children[i]
            if (not IsA(v, "UIListLayout") and sub(v.Name, 1, 1) == "E") then
                v.Visible = ShowErrors
            end
        end
        Console.Frame.List.CanvasSize = UDim2.fromOffset(0, Console.Frame.List.UIListLayout.AbsoluteContentSize.Y);
        Console.Errors.Text = ShowErrors and "Hide Errors" or "Show Errors"
    end), Connections.UI, true);
    AddConnection(CConnect(Console.Output.MouseButton1Click, function()
        ShowOutput = not ShowOutput
        local Children = GetChildren(Console.Frame.List);
        for i = 1, #Children do
            local v = Children[i]
            if (not IsA(v, "UIListLayout") and sub(v.Name, 1, 1) == "P") then
                v.Visible = ShowOutput
            end
        end
        Console.Frame.List.CanvasSize = UDim2.fromOffset(0, Console.Frame.List.UIListLayout.AbsoluteContentSize.Y);
        Console.Output.Text = ShowOutput and "Hide Output" or "Show Output"
    end), Connections.UI, true);
end

AddConnection(CConnect(GetPropertyChangedSignal(ChatLogs.Search, "Text"), function()
    local Text = ChatLogs.Search.Text
    local Children = GetChildren(ChatLogs.Frame.List);
    for i = 1, #Children do
        local v = Children[i]
        if (not IsA(v, "UIListLayout")) then
            local Message = v.Text
            v.Visible = Sfind(lower(Message), Text, 1, true);
        end
    end
    ChatLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, ChatLogs.Frame.List.UIListLayout.AbsoluteContentSize.Y);
end), Connections.UI, true);

AddConnection(CConnect(GetPropertyChangedSignal(GlobalChatLogs.Search, "Text"), function()
    local Text = GlobalChatLogs.Search.Text

    local Children = GetChildren(GlobalChatLogs.Frame.List);
    for i = 1, #Children do
        local v = Children[i]
        if (not IsA(v, "UIListLayout")) then
            local Message = v.Text

            v.Visible = Sfind(lower(Message), Text, 1, true)
        end
    end
end), Connections.UI, true);

AddConnection(CConnect(GetPropertyChangedSignal(HttpLogs.Search, "Text"), function()
    local Text = HttpLogs.Search.Text

    local Children = GetChildren(HttpLogs.Frame.List);
    for i = 1, #Children do
        local v = Children[i]
        if (not IsA(v, "UIListLayout")) then
            local Message = v.Text
            v.Visible = Sfind(lower(Message), Text, 1, true)
        end
    end
end), Connections.UI, true);

AddConnection(CConnect(GetPropertyChangedSignal(Console.Search, "Text"), function()
    local Text = Console.Search.Text
    local Children = GetChildren(Console.Frame.List);
    for i = 1, #Children do
        local v = Children[i]
        if (not IsA(v, "UIListLayout")) then
            local Message = v.Text
            v.Visible = Sfind(lower(Message), Text, 1, true)
        end
    end
    Console.Frame.List.CanvasSize = UDim2.fromOffset(0, Console.Frame.List.UIListLayout.AbsoluteContentSize.Y)
end), Connections.UI, true);


AddConnection(CConnect(ChatLogs.Save.MouseButton1Click, function()
    local GameName = Services.MarketplaceService.GetProductInfo(Services.MarketplaceService, game.PlaceId).Name
    local String =  format("Fates Admin Chatlogs for %s (%s)\n\n", GameName, os.date());
    local TimeSaved = gsub(tostring(os.date("%x")), "/", "-") .. " " .. gsub(tostring(os.date("%X")), ":", "-");
    local Name = format("fates-admin/chatlogs/%s (%s).txt", GameName, TimeSaved);
    local Children = GetChildren(ChatLogs.Frame.List);
    for i = 1, #Children do
        local v = Children[i]
        if (not IsA(v, "UIListLayout")) then
            String = format("%s%s\n", String, v.Text);
        end
    end
    writefile(Name, String);
    Utils.Notify(LocalPlayer, "Saved", "Chat logs saved!");
end), Connections.UI, true);

AddConnection(CConnect(HttpLogs.Save.MouseButton1Click, function()
    local Children = GetChildren(HttpLogs.Frame.List);
    local Logs =  format("Fates Admin HttpLogs for %s\n\n", os.date());
    for i = 1, #Children do
        local v = Children[i]
        if (not IsA(v, "UIListLayout")) then
            Logs = format("%s%s\n", Logs, v.Text);
        end
    end
    if (not isfolder("fates-admin/httplogs")) then
        makefolder("fates-admin/httplogs");
    end
    writefile(format("fates-admin/httplogs/HttpLogs for %s", gsub(tostring(os.date("%X")), ":", "-")) .. ".txt", gsub(Logs, "%b<>", ""));
    Utils.Notify(LocalPlayer, "Saved", "Http logs saved!");
end), Connections.UI, true);

AddConnection(CConnect(Console.Save.MouseButton1Click, function()
    local GameName = Services.MarketplaceService.GetProductInfo(Services.MarketplaceService, game.PlaceId).Name
    local TimeSaved = gsub(tostring(os.date("%x")), "/", "-") .. " " .. gsub(tostring(os.date("%X")), ":", "-");
    local Children = GetChildren(Console.Frame.List);
    local String =  format("Fates Admin logs %s\nGame: %s - %d\n\n", TimeSaved, GameName, game.PlaceId);
    local Names = { ["P"] = "OUTPUT", ["W"] = "WARNING", ["E"] = "ERROR" }
    for i = 1, #Children do
        local v = Children[i]
        if (not IsA(v, "UIListLayout")) then
            String = format("%s[%s] %s\n", String, Names[sub(v.Name, 1, 1)] or "", v.Text);
        end
    end
    writefile("fates-admin/logs.txt", String);
    Utils.Notify(LocalPlayer, "Saved", "Console Logs saved!");
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


do
    local Enabled = false
    local Connection;
    local Predict;
    ToggleChatPrediction = function()
        if (_L.Frame2) then
            return
        end
        if (not Enabled) then
            local RobloxChat = LocalPlayer.PlayerGui and FindFirstChild(LocalPlayer.PlayerGui, "Chat");
            local RobloxChatBarFrame;
            if (RobloxChat) then
                local RobloxChatFrame = FindFirstChild(RobloxChat, "Frame");
                if (RobloxChatFrame) then
                    RobloxChatBarFrame = FindFirstChild(RobloxChatFrame, "ChatBarParentFrame");
                end
            end
            local PredictionClone, ChatBar
            if (RobloxChatBarFrame) then
                local Frame1 = FindFirstChild(RobloxChatBarFrame, 'Frame');
                if Frame1 then
                    local BoxFrame = FindFirstChild(Frame1, 'BoxFrame');
                    if BoxFrame then
                        _L.Frame2 = FindFirstChild(BoxFrame, 'Frame');
                        if _L.Frame2 then
                            local TextLabel = FindFirstChild(_L.Frame2, 'TextLabel');
                            ChatBar = FindFirstChild(_L.Frame2, 'ChatBar');
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

            ParentGui(PredictionClone, _L.Frame2);
            Predict = PredictionClone

            Connection = AddConnection(CConnect(GetPropertyChangedSignal(ChatBar, "Text"), function() -- todo: add detection for /e
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
            Enabled = true
            return ChatBar
        else
            Disconnect(Connection);
            Destroy(Predict);
            Enabled = false
        end
        return _L.Frame2
    end

    if (CurrentConfig.ChatPrediction) then
        delay(2, ToggleChatPrediction);
    end
end

local ConfigUILib = {}
do
    local GuiObjects = ConfigElements
    local PageCount = 0
    local SelectedPage
    local UserInputService = Services.UserInputService

    local Colors = {
        ToggleEnabled = Color3.fromRGB(5, 5, 6);
        Background = Color3.fromRGB(32, 33, 36);
        ToggleDisabled = Color3.fromRGB(27, 28, 31);
    }

    local ColorElements = ConfigElements.Elements.ColorElements
    local Overlay = ColorElements.Overlay
    local OverlayMain = Overlay.Main
    local ColorPicker = OverlayMain.ColorPicker
    local Settings = OverlayMain.Settings
    local ClosePicker = OverlayMain.Close
    local ColorCanvas = ColorPicker.ColorCanvas
    local ColorSlider = ColorPicker.ColorSlider
    local ColorGradient = ColorCanvas.ColorGradient
    local DarkGradient = ColorGradient.DarkGradient
    local CanvasBar = ColorGradient.Bar
    local RainbowGradient = ColorSlider.RainbowGradient
    local SliderBar = RainbowGradient.Bar
    local CanvasHitbox = ColorCanvas.Hitbox
    local SliderHitbox = ColorSlider.Hitbox
    local ColorPreview = Settings.ColorPreview
    local ColorOptions = Settings.Options
    local RedTextBox = ColorOptions.Red.TextBox
    local BlueTextBox = ColorOptions.Blue.TextBox
    local GreenTextBox = ColorOptions.Green.TextBox
    local RainbowToggle = ColorOptions.Rainbow

    local function UpdateClone()
        ConfigUIClone = Clone(ConfigUI);
    end

    function ConfigUILib.NewPage(Title)
        local Page = Clone(GuiObjects.Page.Container);
        local TextButton = Clone(GuiObjects.Page.TextButton);

        Page.Visible = true
        TextButton.Visible = true

        Utils.Click(TextButton, "BackgroundColor3")
            
        if PageCount == 0 then
            SelectedPage = Page
        end

        AddConnection(CConnect(TextButton.MouseButton1Click, function()
            if SelectedPage.Name ~= TextButton.Name then          
                SelectedPage = Page
                ConfigUI.Container.UIPageLayout:JumpTo(SelectedPage)
            end
        end))
        
        Page.Name = Title
        TextButton.Name = Title
        TextButton.Text = Title
        
        Page.Parent = ConfigUI.Container
        TextButton.Parent = ConfigUI.Selection
        
        PageCount = PageCount + 1


        UpdateClone()

        local function GetKeyName(KeyCode)
            local _, Stringed = pcall(UserInputService.GetStringForKeyCode, UserInputService, KeyCode);
            local IsEnum = Stringed == ""
            return (not IsEnum and _) and Stringed or split(tostring(KeyCode), ".")[3], (IsEnum and not _);
        end

        local PageLibrary = {}

        function PageLibrary.CreateMacroSection(MacrosToAdd, Callback)
            local Macro = Clone(GuiObjects.Elements.Macro);
            local MacroPage = Macro.MacroPage
            local Selection = Page.Selection
            
            Selection.ClearAllChildren(Selection);
            for i,v in next, GetChildren(MacroPage) do
                v.Parent = Selection
            end
            Selection.Container.Visible = true
            local CommandsList = Selection.Container.Commands.Frame.List
            local CurrentMacros = Selection.Container.CurrentMacros
            local AddMacro = Selection.AddMacro
            local BindA, CommandA, ArgsA = AddMacro.Bind, AddMacro.Command, AddMacro["z Args"]
            local Add = AddMacro.AddMacro
            local Keybind = {};
            local Enabled = false
            local Connection
            
            local OnClick = function()
                Enabled = not Enabled
                if Enabled then
                    BindA.Text = "..."
                    local OldShiftLock = LocalPlayer.DevEnableMouseLock
                    LocalPlayer.DevEnableMouseLock = false
                    Keybind = {}
                    Connection = AddConnection(CConnect(UserInputService.InputBegan, function(Input, Processed)
                        if not Processed and Input.UserInputType == Enum.UserInputType.Keyboard then
                            local Input2, Proccessed2;
                            CThread(function()
                                Input2, Proccessed2 = CWait(UserInputService.InputBegan);
                            end)()
                            CWait(UserInputService.InputEnded);
                            if (Input2 and not Processed) then
                                local KeyName, IsEnum = GetKeyName(Input.KeyCode);
                                local KeyName2, IsEnum2 = GetKeyName(Input2.KeyCode); 
                                BindA.Text = format("%s + %s", IsEnum2 and KeyName2 or KeyName, IsEnum2 and KeyName2 or KeyName2);
                                Keybind[1] = Input.KeyCode
                                Keybind[2] = Input2.KeyCode
                            else
                                local KeyName = GetKeyName(Input.KeyCode);
                                BindA.Text = KeyName
                                Keybind[1] = Input.KeyCode
                                Keybind[2] = nil
                            end
                            LocalPlayer.DevEnableMouseLock = OldShiftLock
                        else
                            BindA.Text = "Bind"
                        end
                        Enabled = false
                        Disconnect(Connection);
                    end));
                else
                    BindA.Text = "Bind"
                    Disconnect(Connection);
                end
            end

            AddConnection(CConnect(BindA.MouseButton1Click, OnClick));
            AddConnection(CConnect(Add.MouseButton1Click, function()
                if (BindA.Text == "Bind") then
                    Utils.Notify(nil, nil, "You must assign a keybind");
                    return
                end
                if (not CommandsTable[CommandA.Text]) then
                    Utils.Notify(nil, nil, "You must add a command");
                    return
                end
                Callback(Keybind, CommandA.Text, ArgsA.Text);
            end));

            local Focused = false
            local MacroSection = {
                CommandsList = CommandsList,
                AddCmd = function(Name) 
                    local Command = Clone(Macro.Command);
                    Command.Name = Name
                    Command.Text = Name
                    Command.Parent = CommandsList
                    Command.Visible = true
                    AddConnection(CConnect(Command.MouseButton1Click, function()
                        CommandA.Text = Name
                        ArgsA.CaptureFocus(ArgsA);
                        Focused = true
                        CWait(ArgsA.FocusLost);
                        CWait(UserInputService.InputBegan);
                        Focused = false
                        wait(.2);
                        if (not Focused) then
                            OnClick();
                        end
                    end))
                end,
                AddMacro = function(MacroName, Bind)
                    local NewMacro = Clone(Macro.EditMacro);
                    NewMacro.Bind.Text = Bind
                    NewMacro.Macro.Text = MacroName
                    NewMacro.Parent = CurrentMacros
                    NewMacro.Visible = true

                    Utils.Thing(NewMacro.Bind);
                    Utils.Thing(NewMacro.Macro);

                    FindFirstChild(NewMacro, "Remove").Name = "Delete"
                    AddConnection(CConnect(NewMacro.Delete.MouseButton1Click, function()
                        CWait(Utils.TweenAllTrans(NewMacro, .25).Completed);
                        Destroy(NewMacro);
                        for i = 1, #Macros do
                            if (Macros[i].Command == split(MacroName, " ")[1]) then
                                Macros[i] = nil
                            end
                        end
                        local TempMacros = clone(Macros);
                        for i, v in next, TempMacros do
                            for i2, v2 in next, v.Keys do
                                TempMacros[i]["Keys"][i2] = split(tostring(v2), ".")[3]
                            end
                        end
                        SetConfig({Macros=TempMacros});
                    end))
                end
            }

            for i, v in next, MacrosToAdd do
                local Suc, Err = pcall(concat, v.Args, " ");
                if (not Suc) then
                    SetConfig({Macros={}});
                    Utils.Notify(LocalPlayer, "Error", "Macros were reset due to corrupted data")
                    break;
                end
                local KeyName, IsEnum = GetKeyName(v.Keys[1]);
                local Formatted;
                if (v.Keys[2]) then
                    local KeyName2, IsEnum2 = GetKeyName(v.Keys[2]); 
                    Formatted = format("%s + %s", IsEnum2 and KeyName2 or KeyName, IsEnum2 and KeyName2 or KeyName2);
                else
                    Formatted = KeyName
                end
                MacroSection.AddMacro(v.Command .. " " .. concat(v.Args, " "), Formatted);
            end

            return MacroSection
        end

        function PageLibrary.NewSection(Title)
            local Section = Clone(GuiObjects.Section.Container);
            local SectionOptions = Section.Options
            local SectionUIListLayout = SectionOptions.UIListLayout

            Section.Visible = true

            Utils.SmoothScroll(Section.Options, .14)
            Section.Title.Text = Title
            Section.Parent = Page.Selection
            
            
            SectionOptions.CanvasSize = UDim2.fromOffset(0,0) --// change
            AddConnection(CConnect(GetPropertyChangedSignal(SectionUIListLayout, "AbsoluteContentSize"), function()
                SectionOptions.CanvasSize = UDim2.fromOffset(0, SectionUIListLayout.AbsoluteContentSize.Y + 5);
            end));
            
            UpdateClone();

            local ElementLibrary = {}


            function ElementLibrary.Toggle(Title, Enabled, Callback)
                local Toggle = Clone(GuiObjects.Elements.Toggle);
                local Container = Toggle.Container

                local Switch = Container.Switch
                local Hitbox = Container.Hitbox
                
                if not Enabled then
                    Switch.Position = UDim2.fromOffset(2, 2)
                    Container.BackgroundColor3 = Colors.ToggleDisabled
                end
                local NoCallback = false

                local OnClick = function()
                    Enabled = not Enabled
                    
                    Utils.Tween(Switch, "Quad", "Out", .25, {
                        Position = Enabled and UDim2.new(1, -18, 0, 2) or UDim2.fromOffset(2, 2)
                    })
                    Utils.Tween(Container, "Quad", "Out", .25, {
                        BackgroundColor3 = Enabled and Colors.ToggleEnabled or Colors.ToggleDisabled
                    })
                    
                    if (not NoCallback) then
                        Callback(Enabled);
                    end
                end

                AddConnection(CConnect(Hitbox.MouseButton1Click, OnClick));
                
                Toggle.Visible = true
                Toggle.Title.Text = Title
                Toggle.Parent = Section.Options
                Utils.Thing(Toggle.Title);

                UpdateClone()

                return function()
                    NoCallback = true
                    OnClick();
                    NoCallback = false
                end
            end

            function ElementLibrary.ScrollingFrame(Title, Callback, Elements, Toggles)
                local ScrollingFrame = Clone(GuiObjects.Elements.ScrollingFrame);
                local Frame = ScrollingFrame.Frame
                local Toggle = ScrollingFrame.Toggle

                for ElementTitle, Enabled in next, Elements do
                    local NewToggle = Clone(Toggle);
                    NewToggle.Visible = true
                    NewToggle.Title.Text = ElementTitle
                    NewToggle.Plugins.Text = Enabled and (Toggles and Toggles[1] or "Enabled") or (Toggles and Toggles[2] or "Disabled");


                    Utils.Click(NewToggle.Plugins, "BackgroundColor3")

                    AddConnection(CConnect(NewToggle.Plugins.MouseButton1Click, function()
                        Enabled = not Enabled
                        NewToggle.Plugins.Text = Enabled and (Toggles and Toggles[1] or "Enabled") or (Toggles and Toggles[2] or "Disabled");

                        Callback(ElementTitle, Enabled);
                    end));

                    NewToggle.Parent = Frame.Container
                end

                Frame.Visible = true
                Frame.Title.Text = Title
                Frame.Parent = Section.Options

                for _, NewToggle in next, GetChildren(Frame.Container) do
                    if (IsA(NewToggle, "GuiObject")) then
                        Utils.Thing(NewToggle.Title);
                    end
                end

                UpdateClone()
            end

            function ElementLibrary.Keybind(Title, Bind, Callback)
                local Keybind = Clone(GuiObjects.Elements.Keybind);
                local Enabled = false
                local Connection

                Keybind.Container.Text = Bind
                Keybind.Title.Text = Title

                local Container = Keybind.Container
                AddConnection(CConnect(Container.MouseButton1Click, function()
                    Enabled = not Enabled

                    if Enabled then
                        Container.Text = "..."
                        local OldShiftLock = LocalPlayer.DevEnableMouseLock
                        -- disable shift lock so it doesn't interfere with keybind
                        LocalPlayer.DevEnableMouseLock = false
                        Connection = AddConnection(CConnect(UserInputService.InputBegan, function(Input, Processed)
                            if not Processed and Input.UserInputType == Enum.UserInputType.Keyboard then
                                local Input2, Proccessed2;
                                CThread(function()
                                    Input2, Proccessed2 = CWait(UserInputService.InputBegan);
                                end)()
                                CWait(UserInputService.InputEnded);
                                if (Input2 and not Processed) then
                                    local KeyName, IsEnum = GetKeyName(Input.KeyCode);
                                    local KeyName2, IsEnum2 = GetKeyName(Input2.KeyCode); 
                                    -- Order by if it's an enum first, example 'Shift + K' and not 'K + Shift'
                                    Container.Text = format("%s + %s", IsEnum2 and KeyName2 or KeyName, IsEnum2 and KeyName2 or KeyName2);
                                    Callback(Input.KeyCode, Input2.KeyCode);
                                else
                                    local KeyName = GetKeyName(Input.KeyCode);
                                    Container.Text = KeyName
                                    Callback(Input.KeyCode);
                                end
                                LocalPlayer.DevEnableMouseLock = OldShiftLock
                            else
                                Container.Text = "press"
                            end
                            Enabled = false
                            Disconnect(Connection);
                        end));
                    else
                        Container.Text = "press"
                        Disconnect(Connection);
                    end
                end));

                Utils.Click(Container, "BackgroundColor3");
                Keybind.Visible = true
                Keybind.Parent = Section.Options
                UpdateClone();
            end
            
            function ElementLibrary.TextboxKeybind(Title, Bind, Callback)
                local Keybind = Clone(GuiObjects.Elements.TextboxKeybind);
                
                Keybind.Container.Text = Bind
                Keybind.Title.Text = Title
                
                local Container = Keybind.Container
                AddConnection(CConnect(GetPropertyChangedSignal(Container, "Text"), function(Key)
                    if (#Container.Text >= 1) then
                        Container.Text = sub(Container.Text, 1, 1);
                        Callback(Container.Text);
                        Container.ReleaseFocus(Container);
                    end
                end))
                
                Keybind.Visible = true
                Keybind.Parent = Section.Options
                UpdateClone();
            end

            function ElementLibrary.ColorPicker(Title, DefaultColor, Callback)
                local SelectColor = Clone(ColorElements.SelectColor);
                local CurrentColor = DefaultColor
                local Button = SelectColor.Button
                local ToHSV = DefaultColor.ToHSV
                local Color3New = Color3.new
                local Color3fromHSV = Color3.fromHSV
                local UDim2New = UDim2.new
                local clamp = math.clamp

                local H, S, V = ToHSV(DefaultColor);
                local Opened = false
                local Rainbow = false
                
                local function UpdateText()
                    RedTextBox.PlaceholderText = tostring(math.floor(CurrentColor.R * 255))
                    GreenTextBox.PlaceholderText = tostring(math.floor(CurrentColor.G * 255))
                    BlueTextBox.PlaceholderText = tostring(math.floor(CurrentColor.B * 255))
                end
                
                local function UpdateColor()
                    H, S, V = ToHSV(CurrentColor);
                    
                    SliderBar.Position = UDim2New(0, 0, H, 2);
                    CanvasBar.Position = UDim2New(S, 2, 1 - V, 2);
                    ColorGradient.UIGradient.Color = Utils.MakeGradient({
                        [1] = Color3New(1, 1, 1);
                        [2] = Color3fromHSV(H, 1, 1);
                    })
                    
                    ColorPreview.BackgroundColor3 = CurrentColor
                    UpdateText();
                end
            
                local function UpdateHue(Hue)
                    SliderBar.Position = UDim2New(0, 0, Hue, 2);
                    ColorGradient.UIGradient.Color = Utils.MakeGradient({
                        [1] = Color3New(1, 1, 1);
                        [2] = Color3fromHSV(Hue, 1, 1);
                    });
                    
                    ColorPreview.BackgroundColor3 = CurrentColor
                    UpdateText();
                end
                
                local function ColorSliderInit()
                    local Moving = false
                    
                    local function Update()
                        if Opened and not Rainbow then
                            local LowerBound = SliderHitbox.AbsoluteSize.Y
                            local Position = clamp(Mouse.Y - SliderHitbox.AbsolutePosition.Y, 0, LowerBound);
                            local Value = Position / LowerBound
                            
                            H = Value
                            CurrentColor = Color3fromHSV(H, S, V);
                            ColorPreview.BackgroundColor3 = CurrentColor
                            ColorGradient.UIGradient.Color = Utils.MakeGradient({
                                [1] = Color3New(1, 1, 1);
                                [2] = Color3fromHSV(H, 1, 1);
                            });
                            
                            UpdateText();
                            
                            local Position = UDim2.new(0, 0, Value, 2)
                            local Tween = Utils.Tween(SliderBar, "Linear", "Out", .05, {
                                Position = Position
                            });
                            
                            Callback(CurrentColor);
                            CWait(Tween.Completed);
                        end
                    end
                
                    AddConnection(CConnect(SliderHitbox.MouseButton1Down, function()
                        Moving = true
                        Update()
                    end))
                    
                    AddConnection(CConnect(UserInputService.InputEnded, function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 and Moving then
                            Moving = false
                        end
                    end))
                    
                    AddConnection(CConnect(Mouse.Move, Utils.Debounce(function()
                        if Moving then
                            Update()
                        end
                    end)))
                end
                local function ColorCanvasInit()
                    local Moving = false
                    
                    local function Update()
                        if Opened then
                            local LowerBound = CanvasHitbox.AbsoluteSize.Y
                            local YPosition = clamp(Mouse.Y - CanvasHitbox.AbsolutePosition.Y, 0, LowerBound)
                            local YValue = YPosition / LowerBound
                            local RightBound = CanvasHitbox.AbsoluteSize.X
                            local XPosition = clamp(Mouse.X - CanvasHitbox.AbsolutePosition.X, 0, RightBound)
                            local XValue = XPosition / RightBound
                            
                            S = XValue
                            V = 1 - YValue
                            
                            CurrentColor = Color3fromHSV(H, S, V);
                            ColorPreview.BackgroundColor3 = CurrentColor
                            UpdateText()
                            
                            local Position = UDim2New(XValue, 2, YValue, 2);
                            local Tween = Utils.Tween(CanvasBar, "Linear", "Out", .05, {
                                Position = Position
                            });
                            Callback(CurrentColor);
                            CWait(Tween.Completed);
                        end
                    end
                
                    AddConnection(CConnect(CanvasHitbox.MouseButton1Down, function()
                        Moving = true
                        Update()
                    end))
                    
                    AddConnection(CConnect(UserInputService.InputEnded, function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 and Moving then
                            Moving = false
                        end
                    end))
                    
                    AddConnection(CConnect(Mouse.Move, Utils.Debounce(function()
                        if Moving then
                            Update()
                        end
                    end)))
                end
                
                ColorSliderInit()
                ColorCanvasInit()
                
                AddConnection(CConnect(Button.MouseButton1Click, function()
                    if not Opened then
                        Opened = true
                        UpdateColor()
                        RainbowToggle.Container.Switch.Position = Rainbow and UDim2New(1, -18, 0, 2) or UDim2.fromOffset(2, 2)
                        RainbowToggle.Container.BackgroundColor3 = Color3.fromRGB(25, 25, 25);
                        Overlay.Visible = true
                        OverlayMain.Visible = false
                        Utils.Intro(OverlayMain)
                    end
                end))
                
                AddConnection(CConnect(ClosePicker.MouseButton1Click, Utils.Debounce(function()
                    Button.BackgroundColor3 = CurrentColor
                    Utils.Intro(OverlayMain)
                    Overlay.Visible = false
                    Opened = false
                end)))
                
                AddConnection(CConnect(RedTextBox.FocusLost, function()
                    if Opened then
                        local Number = tonumber(RedTextBox.Text)
                        if Number then
                            Number = clamp(floor(Number), 0, 255)
                            CurrentColor = Color3New(Number / 255, CurrentColor.G, CurrentColor.B)
                            UpdateColor()
                            RedTextBox.PlaceholderText = tostring(Number)
                            Callback(CurrentColor)
                        end
                        RedTextBox.Text = ""
                    end
                end))
                
                AddConnection(CConnect(GreenTextBox.FocusLost, function()
                    if Opened then
                        local Number = tonumber(GreenTextBox.Text)
                        if Number then
                            Number = clamp(floor(Number), 0, 255)
                            CurrentColor = Color3New(CurrentColor.R, Number / 255, CurrentColor.B)
                            UpdateColor()
                            GreenTextBox.PlaceholderText = tostring(Number)
                            Callback(CurrentColor)
                        end
                        GreenTextBox.Text = ""
                    end
                end))
                
                AddConnection(CConnect(BlueTextBox.FocusLost, function()
                    if Opened then
                        local Number = tonumber(BlueTextBox.Text)
                        if Number then
                            Number = clamp(floor(Number), 0, 255)
                            CurrentColor = Color3New(CurrentColor.R, CurrentColor.G, Number / 255)
                            UpdateColor()
                            BlueTextBox.PlaceholderText = tostring(Number)
                            Callback(CurrentColor)
                        end
                        BlueTextBox.Text = ""
                    end
                end))
                
                Utils.ToggleFunction(RainbowToggle.Container, false, function(Callback)
                    if Opened then
                        Rainbow = Callback
                    end
                end)
                
                AddConnection(CConnect(RenderStepped, function()
                    if Rainbow then
                        local Hue = (tick() / 5) % 1
                        CurrentColor = Color3.fromHSV(Hue, S, V)
                        
                        if Opened then
                            UpdateHue(Hue)
                        end
                        
                        Button.BackgroundColor3 = CurrentColor
                        Callback(CurrentColor, true);
                    end
                end))
                                
                Button.BackgroundColor3 = DefaultColor
                SelectColor.Title.Text = Title
                SelectColor.Visible = true
                SelectColor.Parent = Section.Options
                Utils.Thing(SelectColor.Title);
            end

            return ElementLibrary
        end

        return PageLibrary
    end
end

Utils.Click(ConfigUI.Close, "TextColor3")
AddConnection(CConnect(ConfigUI.Close.MouseButton1Click, function()
    ConfigLoaded = false
    CWait(Utils.TweenAllTrans(ConfigUI, .25).Completed);
    ConfigUI.Visible = false
end))
--END IMPORT [uimore]


--IMPORT [plugin]
PluginConf = IsSupportedExploit and GetPluginConfig();
local Plugins;

PluginLibrary = {
    LocalPlayer = LocalPlayer,
    Services = Services,
    GetCharacter = GetCharacter,
    ProtectInstance = ProtectInstance,
    SpoofInstance = SpoofInstance,
    SpoofProperty = SpoofProperty,
    UnSpoofInstance = UnSpoofInstance,
    ReplaceCharacter = ReplaceCharacter,
    ReplaceHumanoid = ReplaceHumanoid,
    GetCorrectToolWithHandle = GetCorrectToolWithHandle,
    DisableAnimate = DisableAnimate,
    GetPlayer = GetPlayer,
    GetHumanoid = GetHumanoid,
    GetRoot = GetRoot,
    GetMagnitude = GetMagnitude,
    GetCommandEnv = function(Name)
        local Command = LoadCommand(Name);
        if (Command.CmdEnv) then
            return Command.CmdEnv
        end
    end,
    isR6 = isR6,
    ExecuteCommand = ExecuteCommand,
    Notify = Utils.Notify,
    HasTool = HasTool,
    isSat = isSat,
    Request = syn and syn.request or request or game.HttpGet,
    CThread = CThread,
    AddConnection = AddConnection,
    filter = filter,
    map = map,
    clone = clone,
    firetouchinterest = firetouchinterest,
    fireproximityprompt = fireproximityprompt,
    decompile = decompile,
    getnilinstances = getnilinstances,
    getinstances = getinstances,
    Drawing = Drawing
}

do
    local IsDebug = IsSupportedExploit and PluginConf.PluginDebug

    Plugins = IsSupportedExploit and map(filter(listfiles("fates-admin/plugins"), function(i, v)
        return lower(split(v, ".")[#split(v, ".")]) == "lua"
    end), function(i, v)
        local splitted = split(v, "\\");
        if (identifyexecutor and identifyexecutor() == "ScriptWare") then
            return {splitted[#splitted], loadfile("fates-admin/plugins/" .. v)}
        else
            return {splitted[#splitted], loadfile(v)}
        end
    end) or {}

    if (SafePlugins) then
        local Renv = clone(getrenv(), true);
        for i, v in next, Renv do
            PluginLibrary[i] = v
        end
    end
    PluginLibrary.debug = nil
    PluginLibrary.getfenv = nil
    PluginLibrary.loadstring = loadstring

    if (PluginConf.SafePlugins) then
        local Funcs = {}
        for i, v in next, PluginLibrary do
            if (type(v) == 'function') then
                Funcs[#Funcs + 1] = v
            end
        end
        local FateEnv = getfenv(1);
        PluginLibrary.getfenv = newcclosure(function(...)
            local f = ({...})[1]
            local Env = getfenv(...);
            if (type(f) == 'function' and Tfind(Funcs, f) or Env == FateEnv and checkcaller()) then
                return PluginLibrary
            end
            return Env
        end)
    end

    if (PluginConf.PluginsEnabled) then
        local LoadPlugin = function(Plugin)
            if (not IsSupportedExploit) then
                return 
            end
        
            if (Plugin and PluginConf.DisabledPlugins[Plugin.Name]) then
                Utils.Notify(LocalPlayer, "Plugin not loaded.", format("Plugin %s was not loaded as it is on the disabled list.", Plugin.Name));
                return "Disabled"
            end
            if (#keys(Plugin) < 3) then
                return Utils.Notify(LocalPlayer, "Plugin Fail", "One of your plugins is missing information.");
            end
            if (IsDebug) then
                Utils.Notify(LocalPlayer, "Plugin loading", format("Plugin %s is being loaded.", Plugin.Name));
            end
            
            local Context;
            local sett, gett = setthreadidentity, getthreadidentity
            if (sett and PluginConf.SafePlugins) then
                Context = gett();
                sett(5);
            end
            local Ran, Return = pcall(Plugin.Init);
            if (sett and Context) then
                sett(Context);
            end
            if (not Ran and Return and IsDebug) then
                return Utils.Notify(LocalPlayer, "Plugin Fail", format("there is an error in plugin Init %s: %s", Plugin.Name, Return));
            end
            
            for i, command in next, Plugin.Commands or {} do -- adding the "or" because some people might have outdated plugins in the dir
                if (#keys(command) < 3) then
                    Utils.Notify(LocalPlayer, "Plugin Command Fail", format("Command %s is missing information", command.Name));
                    continue
                end
                AddCommand(command.Name, command.Aliases or {}, command.Description .. " - " .. Plugin.Author, command.Requirements or {}, command.Func, true);
        
                if (FindFirstChild(Commands.Frame.List, command.Name)) then
                    Destroy(FindFirstChild(Commands.Frame.List, command.Name));
                end
                local Clone = Clone(Command);
                Utils.Hover(Clone, "BackgroundColor3");
                Utils.ToolTip(Clone, format("%s\n%s - %s", command.Name, command.Description, Plugin.Author));
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

        for i, Plugin in next, Plugins do
            local PluginFunc = Plugin[2]
            if (PluginConf.SafePlugins) then
                setfenv(PluginFunc, PluginLibrary);
            else
                local CurrentEnv = getfenv(PluginFunc);
                for i2, v2 in next, PluginLibrary do
                    CurrentEnv[i2] = v2
                end
            end
            local Success, Ret = pcall(PluginFunc);
            if (Success) then
                LoadPlugin(Ret);
            elseif (PluginConf.PluginDebug) then
                Utils.Notify(LocalPlayer, "Fail", "There was an error Loading plugin (console for more information)");
                warn("[FA Plugin Error]: " .. debug.traceback(Ret));             
            end
        end
        
        AddCommand("refreshplugins", {"rfp", "refreshp", "reloadp"}, "Loads all new plugins.", {}, function()
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
                local PluginFunc = Plugin[2]
                setfenv(PluginFunc, PluginLibrary);
                local Success, Ret = pcall(PluginFunc);
                if (Success) then
                    LoadPlugin(Ret);
                elseif (PluginConf.PluginDebug) then
                    Utils.Notify(LocalPlayer, "Fail", "There was an error Loading plugin (console for more information)");
                    warn("[FA Plugin Error]: " .. debug.traceback(Ret));             
                end
            end
        end)
    end
end
--END IMPORT [plugin]


WideBar = false
Draggable = false

--IMPORT [config]
do
    local UserInputService = Services.UserInputService
    local GetStringForKeyCode = UserInputService.GetStringForKeyCode
    local function GetKeyName(KeyCode)
        local _, Stringed = pcall(GetStringForKeyCode, UserInputService, KeyCode);
        local IsEnum = Stringed == ""
        return (not IsEnum and _) and Stringed or split(tostring(KeyCode), ".")[3], (IsEnum and not _);
    end

    local SortKeys = function(Key1, Key2)
        local KeyName, IsEnum = GetKeyName(Key1);
        if (Key2) then
            local KeyName2, IsEnum2 = GetKeyName(Key2);
            return format("%s + %s", IsEnum2 and KeyName2 or KeyName, IsEnum2 and KeyName2 or KeyName2);
        end
        return KeyName
    end

    LoadConfig = function()
        local Script = ConfigUILib.NewPage("Script");
        local Settings = Script.NewSection("Settings");
    
        local CurrentConf = GetConfig();

        Settings.TextboxKeybind("Chat Prefix", Prefix, function(Key)
            if (not match(Key, "%A") or match(Key, "%d") or #Key > 1) then
                Utils.Notify(nil, "Prefix", "Prefix must be a 1 character symbol.");
                return
            end
            Prefix = Key
            Utils.Notify(nil, "Prefix", "Prefix is now " .. Key);
        end)
    
        Settings.Keybind("CMDBar Prefix", GetKeyName(CommandBarPrefix), function(KeyCode1, KeyCode2)
            CommandBarPrefix = KeyCode1
            Utils.Notify(nil, "Prefix", "CommandBar Prefix is now " .. GetKeyName(KeyCode1));
        end)
    
        local ToggleSave;
        ToggleSave = Settings.Toggle("Save Prefix's", false, function(Callback)
            SetConfig({["Prefix"]=Prefix,["CommandBarPrefix"]=split(tostring(CommandBarPrefix), ".")[3]});
            wait(.5);
            ToggleSave();
            Utils.Notify(nil, "Prefix", "saved prefix's");
        end)
    
        local Misc = Script.NewSection("Misc");

        Misc.Toggle("Chat Prediction", CurrentConf.ChatPrediction or false, function(Callback)
            local ChatBar = ToggleChatPrediction();
            if (Callback) then
                ChatBar.CaptureFocus(ChatBar);
                wait();
                ChatBar.Text = Prefix
            end
            SetConfig({ChatPrediction=Callback});
            Utils.Notify(nil, nil, format("ChatPrediction %s", Callback and "enabled" or "disabled"));
        end)

        Misc.Toggle("Anti Kick", Hooks.AntiKick, function(Callback)
            Hooks.AntiKick = Callback
            Utils.Notify(nil, nil, format("AntiKick %s", Hooks.AntiKick and "enabled" or "disabled"));
        end)

        Misc.Toggle("Anti Teleport", Hooks.AntiTeleport, function(Callback)
            Hooks.AntiTeleport = Callback
            Utils.Notify(nil, nil, format("AntiTeleport %s", Hooks.AntiTeleport and "enabled" or "disabled"));
        end)

        Misc.Toggle("wide cmdbar", WideBar, function(Callback)
            WideBar = Callback
            if (not Draggable) then
                Utils.Tween(CommandBar, "Quint", "Out", .5, {
                    Position = UDim2.new(0.5, WideBar and -200 or -100, 1, 5) -- tween -110
                })
            end
            Utils.Tween(CommandBar, "Quint", "Out", .5, {
                Size = UDim2.new(0, WideBar and 400 or 200, 0, 35) -- tween -110
            })
            SetConfig({WideBar=Callback});
            Utils.Notify(nil, nil, format("widebar %s", WideBar and "enabled" or "disabled"));
        end)

        Misc.Toggle("draggable cmdbar", Draggable, function(Callback)
            Draggable = Callback
            CommandBarOpen = true
            Utils.Tween(CommandBar, "Quint", "Out", .5, {
                Position = UDim2.new(0, Mouse.X, 0, Mouse.Y + 36);
            })
            Utils.Draggable(CommandBar);
            local TransparencyTween = CommandBarOpen and Utils.TweenAllTransToObject or Utils.TweenAllTrans
            local Tween = TransparencyTween(CommandBar, .5, CommandBarTransparencyClone);
            CommandBar.Input.Text = ""
            if (not Callback) then
                Utils.Tween(CommandBar, "Quint", "Out", .5, {
                    Position = UDim2.new(0.5, WideBar and -200 or -100, 1, 5) -- tween 5
                })
            end
            Utils.Notify(nil, nil, format("draggable command bar %s", Draggable and "enabled" or "disabled"));
        end)

        Misc.Toggle("KillCam when killing", CurrentConf.KillCam, function(Callback)
            SetConfig({KillCam=Callback});
            _L.KillCam = Callback
        end)

        local OldFireTouchInterest = firetouchinterest
        Misc.Toggle("cframe touchinterest", firetouchinterest == nil, function(Callback)
            firetouchinterest = Callback and function(part1, part2, toggle)
                if (part1 and part2) then
                    if (toggle == 0) then
                        touched[1] = part1.CFrame
                        part1.CFrame = part2.CFrame
                    else
                        part1.CFrame = touched[1]
                        touched[1] = nil
                    end
                end
            end or OldFireTouchInterest
        end)

        local MacrosPage = ConfigUILib.NewPage("Macros");
        local MacroSection;
        MacroSection = MacrosPage.CreateMacroSection(Macros, function(Bind, Command, Args)
            local AlreadyAdded = false
            for i = 1, #Macros do
                if (Macros[i].Command == Command) then
                    AlreadyAdded = true
                end
            end
            if (CommandsTable[Command] and not AlreadyAdded) then
                MacroSection.AddMacro(Command .. " " .. Args, SortKeys(Bind[1], Bind[2]));
                Args = split(Args, " ");
                if (sub(Command, 1, 2) == "un" or CommandsTable["un" .. Command]) then
                    local Shifted = {Command, unpack(Args)}
                    Macros[#Macros + 1] = {
                        Command = "toggle",
                        Args = Shifted,
                        Keys = Bind
                    }
                else
                    Macros[#Macros + 1] = {
                        Command = Command,
                        Args = Args,
                        Keys = Bind
                    }
                end
                local TempMacros = clone(Macros);
                for i, v in next, TempMacros do
                    for i2, v2 in next, v.Keys do
                        TempMacros[i]["Keys"][i2] = split(tostring(v2), ".")[3]
                    end
                end
                SetConfig({Macros=TempMacros});
            end
        end)
        local UIListLayout = MacroSection.CommandsList.UIListLayout
        for i, v in next, CommandsTable do
            if (not FindFirstChild(MacroSection.CommandsList, v.Name)) then
                MacroSection.AddCmd(v.Name);
            end
        end
        MacroSection.CommandsList.CanvasSize = UDim2.fromOffset(0, UIListLayout.AbsoluteContentSize.Y);
        local Search = FindFirstChild(MacroSection.CommandsList.Parent.Parent, "Search");

        AddConnection(CConnect(GetPropertyChangedSignal(Search, "Text"), function()
            local Text = Search.Text
            for _, v in next, GetChildren(MacroSection.CommandsList) do
                if (IsA(v, "TextButton")) then
                    local Command = v.Text
                    v.Visible = Sfind(lower(Command), Text, 1, true)
                end
            end
            MacroSection.CommandsList.CanvasSize = UDim2.fromOffset(0, UIListLayout.AbsoluteContentSize.Y);
        end), Connections.UI, true);
        
        local PluginsPage = ConfigUILib.NewPage("Plugins");
        
        local CurrentPlugins = PluginsPage.NewSection("Current Plugins");
        local PluginSettings = PluginsPage.NewSection("Plugin Settings");
    
        local CurrentPluginConf = GetPluginConfig();
    
        CurrentPlugins.ScrollingFrame("plugins", function(Option, Enabled)
            CurrentPluginConf = GetPluginConfig();
            for i = 1, #Plugins do
                local Plugin = Plugins[i]
                if (Plugin[1] == Option) then
                    local DisabledPlugins = CurrentPluginConf.DisabledPlugins
                    local PluginName = Plugin[2]().Name
                    if (Enabled) then
                        DisabledPlugins[PluginName] = nil
                        SetPluginConfig({DisabledPlugins=DisabledPlugins});
                        Utils.Notify(nil, "Plugin Enabled", format("plugin %s successfully enabled", PluginName));
                    else
                        DisabledPlugins[PluginName] = true
                        SetPluginConfig({DisabledPlugins=DisabledPlugins});
                        Utils.Notify(nil, "Plugin Disabled", format("plugin %s successfully disabled", PluginName));
                    end
                end
            end
        end, map(Plugins, function(Key, Plugin)
            return not PluginConf.DisabledPlugins[Plugin[2]().Name], Plugin[1]
        end));
    
        PluginSettings.Toggle("Plugins Enabled", CurrentPluginConf.PluginsEnabled, function(Callback)
            SetPluginConfig({PluginsEnabled = Callback});
        end)

        PluginSettings.Toggle("Plugins Debug", CurrentPluginConf.PluginDebug, function(Callback)
            SetPluginConfig({PluginDebug = Callback});
        end)

        PluginSettings.Toggle("Safe Plugins", CurrentPluginConf.SafePlugins, function(Callback)
            SetPluginConfig({SafePlugins = Callback});
        end)

        local Themes = ConfigUILib.NewPage("Themes");

        local Color = Themes.NewSection("Colors");
        local Options = Themes.NewSection("Options");

        local RainbowEnabled = false
        Color.ColorPicker("All Background", UITheme.Background.BackgroundColor, function(Callback, IsRainbow)
            UITheme.Background.BackgroundColor = Callback
            RainbowEnabled = IsRainbow
        end)
        Color.ColorPicker("CommandBar", UITheme.CommandBar.BackgroundColor, function(Callback)
            if (not RainbowEnabled) then
                UITheme.CommandBar.BackgroundColor = Callback
            end
        end)
        Color.ColorPicker("Notification", UITheme.Notification.BackgroundColor, function(Callback)
            if (not RainbowEnabled) then
                UITheme.Notification.BackgroundColor = Callback
            end
        end)
        Color.ColorPicker("ChatLogs", UITheme.ChatLogs.BackgroundColor, function(Callback)
            if (not RainbowEnabled) then
                UITheme.ChatLogs.BackgroundColor = Callback
            end
        end)
        Color.ColorPicker("CommandList", UITheme.CommandList.BackgroundColor, function(Callback)
            if (not RainbowEnabled) then
                UITheme.CommandList.BackgroundColor = Callback
            end
        end)
        Color.ColorPicker("Config", UITheme.Config.BackgroundColor, function(Callback)
            if (not RainbowEnabled) then
                UITheme.Config.BackgroundColor = Callback
            end
        end)

        Color.ColorPicker("All Text", UITheme.Background.TextColor, function(Callback)
            UITheme.Background.TextColor = Callback
        end)

        local ToggleSave;
        ToggleSave = Options.Toggle("Save Theme", false, function(Callback)
            WriteThemeConfig();
            wait(.5);
            ToggleSave();
            Utils.Notify(nil, "Theme", "saved theme");
        end)

        local ToggleLoad;
        ToggleLoad = Options.Toggle("Load Theme", false, function(Callback)
            LoadTheme(GetThemeConfig());
            wait(.5);
            ToggleLoad();
            Utils.Notify(nil, "Theme", "Loaded theme");
        end)

        local ToggleReset;
        ToggleReset = Options.Toggle("Reset Theme", false, function(Callback)
            UITheme.Background.BackgroundColor = "Reset"
            UITheme.Notification.TextColor = "Reset"
            UITheme.CommandBar.TextColor = "Reset"
            UITheme.CommandList.TextColor = "Reset"
            UITheme.ChatLogs.TextColor = "Reset"
            UITheme.Config.TextColor = "Reset"
            UITheme.Notification.Transparency = "Reset"
            UITheme.CommandBar.Transparency = "Reset"
            UITheme.CommandList.Transparency = "Reset"
            UITheme.ChatLogs.Transparency = "Reset"
            UITheme.Config.Transparency = "Reset"
            wait(.5);
            ToggleReset();
            Utils.Notify(nil, "Theme", "reset theme");
        end)

    end

    delay(1, function()
        for i = 1, #Macros do
            local Macro = Macros[i]
            for i2 = 1, #Macro.Keys do
                Macros[i].Keys[i2] = Enum.KeyCode[Macros[i].Keys[i2]]
            end
        end
        if (CurrentConfig.WideBar) then
            WideBar = true
            Utils.Tween(CommandBar, "Quint", "Out", .5, {
                Size = UDim2.new(0, WideBar and 400 or 200, 0, 35) -- tween -110
            })
        end
        KillCam = CurrentConfig.KillCam
        local Aliases = CurrentConfig.Aliases
        if (Aliases) then
            for i, v in next, Aliases do
                if (CommandsTable[i]) then
                    for i2 = 1, #v do
                        local Alias = v[i2]
                        local Add = CommandsTable[i]
                        Add.Name = Alias
                        CommandsTable[Alias] = Add
                    end
                end
            end
        end
    end)
end
--END IMPORT [config]


AddConnection(CConnect(CommandBar.Input.FocusLost, function()
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

local PlayerAdded = function(plr)
    RespawnTimes[plr.Name] = tick();
    AddConnection(CConnect(plr.CharacterAdded, function()
        RespawnTimes[plr.Name] = tick();
    end));
end

forEach(GetPlayers(Players), function(i,v)
    PlayerAdded(v);
end);

AddConnection(CConnect(Players.PlayerAdded, function(plr)
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

Utils.Notify(LocalPlayer, "Loaded", format("script loaded in %.3f seconds", (tick()) - _L.start));
Utils.Notify(LocalPlayer, "Welcome", "'cmds' to see all of the commands, 'config' to customise the script");
if (debug.info(2, "f") == nil) then
    Utils.Notify(LocalPlayer, "Outdated Script", "use the loadstring to get latest updates (https://fatesc/fates-admin)", 10);
end
_L.LatestCommit = JSONDecode(Services.HttpService, game.HttpGetAsync(game, "https://api.github.com/repos/fatesc/fates-admin/commits?per_page=1&path=main.lua"))[1]
wait(1);
Utils.Notify(LocalPlayer, "Newest Update", format("%s - %s", _L.LatestCommit.commit.message, _L.LatestCommit.commit.author.name));
