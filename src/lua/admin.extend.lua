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

local getconnections;
do
    local CachedConnections = setmetatable({}, {
        mode = "v"
    });
    getconnections = function(Connection, FromCache)
        local getconnections = getgenv().getconnections
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

        local Connections = getgenv().getconnections(Connection);
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

local hookmetamethod = hookmetamethod or function(metatable, metamethod, func)
    setreadonly(metatable, false);
    Old = hookfunction(metatable[metamethod], func, true);
    setreadonly(metatable, true);
    return Old
end

local GetAllParents = function(Instance_)
    if (typeof(Instance_) == "Instance") then
        local Parents = {}
        local Current = Instance_
        repeat
            local Parent = Current.Parent
            Parents[#Parents + 1] = Parent
            Current = Parent
        until not Current
        return Parents
    end
    return {}
end
local Hooks = {
    AntiKick = false,
    AntiTeleport = false,
    NoJumpCooldown = false,
    UndetectedMessageOut = true
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
local UnSpoofInstance;
local ProtectedInstances = setmetatable({}, {
    mode = "v"
});
do
    local SpoofedInstances = setmetatable({}, {
        mode = "v"
    });
    local SpoofedProperties = setmetatable({}, {
        mode = "v"
    });
    Hooks.SpoofedProperties = SpoofedProperties

    ProtectInstance = function(Instance_, disallow)
        if (not Tfind(ProtectedInstances, Instance_)) then
            ProtectedInstances[#ProtectedInstances + 1] = Instance_
            if (syn and syn.protect_gui and not disallow) then
                syn.protect_gui(Instance_);
            end
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
                    SpoofedProperty = SpoofedPropertiesForInstance.SpoofedProperty,
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

    local Methods = {
        "FindFirstChild",
        "FindFirstChildWhichIsA",
        "FindFirstChildOfClass",
        "IsA"
    }
    MetaMethodHooks.Namecall = function(...)
        local __Namecall = OldMetaMethods.__namecall;
        local Args = {...}
        local self = Args[1]
        local Method = getnamecallmethod() or "";

        if (Hooks.AntiKick and lower(Method) == "kick") then
            local Player, Message = self, Args[2]
            if (Hooks.AntiKick and Player == LocalPlayer) then
                local Notify = Utils.Notify
                local Context;
                local sett, gett = setthreadidentity, getthreadidentity
                if (sett) then
                    Context = gett();
                    sett(3);
                end
                if (Notify and Context) then
                    Notify(nil, "Attempt to kick", format("attempt to kick %s", (Message and type(Message) == 'number' or type(Message) == 'number') and ": " .. Message or ""));
                    sett(Context);
                end
                return
            end
        end

        if (Hooks.AntiTeleport and Method == "Teleport" or Method == "TeleportToPlaceInstance") then
            local Player, PlaceId = self, Args[2]
            if (Hooks.AntiTeleport and Player == LocalPlayer) then
                local Notify = Utils.Notify
                local Context;
                local sett, gett = setthreadidentity, getthreadidentity
                if (sett) then
                    Context = gett();
                    sett(3);
                end
                if (Notify and Context) then
                    Notify(nil, "Attempt to teleport", format("attempt to teleport to place %s", PlaceId and PlaceId or ""));
                    sett(Context);
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
        

        if (Method == "GetChildren" or Method == "GetDescendants") then
            return filter(__Namecall(...), function(i, v)
                return not Tfind(ProtectedInstances, v);
            end)
        end

        if (Method == "GetFocusedTextBox") then
            if (Tfind(ProtectedInstances, __Namecall(...))) then
                return nil
            end
        end

        if (Hooks.UndetectedMessageOut and Method == "GetLogHistory") then
            if (self == Services.LogService) then
                local LogHistory = __Namecall(...);
                local MessagesOut = Hooks.MessagesOut
                local FilteredLogHistory = {}
                for i, v in next, LogHistory do
                    if (not Tfind(MessagesOut, v.message)) then
                        FilteredLogHistory[#FilteredLogHistory + 1] = v
                    end
                end
                return FilteredLogHistory
            end
        end

        if (Hooks.NoJumpCooldown and Method == "GetState" or Method == "GetStateEnabled") then
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
                if (SanitisedIndex == SpoofedProperty.Property) then
                    local ClientChangedData = ChangedSpoofedProperties[Instance_][SanitisedIndex]
                    local IndexedSpoofed = __Index(SpoofedProperty.SpoofedProperty, Index);
                    local Indexed = __Index(Instance_, Index);
                    if (not ClientChangedData and IndexedSpoofed ~= Indexed) then
                        OldMetaMethods.__NewIndex(SpoofedProperty.SpoofedProperty, Index, Indexed);
                        return __Index(SpoofedProperty.SpoofedProperty, Index);
                    end
                    if (ClientChangedData.Caller) then
                        ChangedSpoofedProperties[Instance_][SanitisedIndex] = nil
                    end
                    return IndexedSpoofed
                end
            end
        end

        if (Tfind(ProtectedInstances, __Index(...))) then
            return nil
        end
        if (Tfind(ProtectedInstances, Instance_) and SanitisedIndex == "ClassName") then
            return "Part"
        end

        if (Hooks.NoJumpCooldown and SanitisedIndex == "Jump") then
            if (IsA(Instance_, "Humanoid")) then
                return false
            end
        end
        
        return __Index(...);
    end

    MetaMethodHooks.NewIndex = function(...)
        local __NewIndex = OldMetaMethods.__newindex;
        local __Index = OldMetaMethods.__index;
        local Instance_, Index, Value = ...

        local SpoofedInstance = SpoofedInstances[Instance_]
        local SpoofedPropertiesForInstance = SpoofedProperties[Instance_]

        if (checkcaller()) then
            if (Index == "Parent") then
                local ProtectedInstance;-- = Tfind(ProtectedInstances, Instance_);
                for i = 1, #ProtectedInstances do
                    local ProtectedInstance_ = ProtectedInstances[i]
                    if (Instance_ == ProtectedInstance_ or Instance_.IsDescendantOf(Instance_, ProtectedInstance_)) then
                        ProtectedInstance = true
                    end
                end
                if (ProtectedInstance) then
                    local Parents = GetAllParents(Value);
                    for i, v in next, getconnections(Parents[1].ChildAdded, true) do
                        v.Disable(v);
                    end
                    for i = 1, #Parents do
                        local Parent = Parents[i]
                        for i2, v in next, getconnections(Parent.DescendantAdded, true) do
                            v.Disable(v);
                        end
                    end
                    local Ret = __NewIndex(...);
                    for i = 1, #Parents do
                        local Parent = Parents[i]
                        for i2, v in next, getconnections(Parent.DescendantAdded, true) do
                            v.Enable(v);
                        end
                    end
                    for i, v in next, getconnections(Parents[1].ChildAdded, true) do
                        v.Enable(v);
                    end
                    return Ret
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
                    getconnections(GetPropertyChangedSignal(Instance_, SpoofedPropertiesForInstance and SpoofedPropertiesForInstance.Property or Index)),
                    getconnections(Instance_.Changed),
                    getconnections(game.ItemChanged)
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
end

OldMetaMethods.__index = hookmetamethod(game, "__index", MetaMethodHooks.Index);
OldMetaMethods.__newindex = hookmetamethod(game, "__newindex", MetaMethodHooks.NewIndex);
OldMetaMethods.__namecall = hookmetamethod(game, "__namecall", MetaMethodHooks.Namecall);

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
            return not Tfind(ProtectedInstances, v);
        end)
    end
    return Hooks.OldGetDescendants(...);
end));

Hooks.FindFirstChild = hookfunction(game.FindFirstChild, newcclosure(function(...)
    if (not checkcaller()) then
        local ReturnedInstance = Hooks.FindFirstChild(...);
        if (Tfind(ProtectedInstances, ReturnedInstance)) then
            return nil
        end
    end
    return Hooks.FindFirstChild(...);
end));
Hooks.FindFirstChildOfClass = hookfunction(game.FindFirstChildOfClass, newcclosure(function(...)
    if (not checkcaller()) then
        local ReturnedInstance = Hooks.FindFirstChildOfClass(...);
        if (Tfind(ProtectedInstances, ReturnedInstance)) then
            return nil
        end
    end
    return Hooks.FindFirstChildOfClass(...);
end));
Hooks.FindFirstChildWhichIsA = hookfunction(game.FindFirstChildWhichIsA, newcclosure(function(...)
    if (not checkcaller()) then
        local ReturnedInstance = Hooks.FindFirstChildWhichIsA(...);
        if (Tfind(ProtectedInstances, ReturnedInstance)) then
            return nil
        end
    end
    return Hooks.FindFirstChildWhichIsA(...);
end));
Hooks.IsA = hookfunction(game.IsA, newcclosure(function(...)
    if (not checkcaller()) then
        local Args = {...}
        local IsACheck = Args[1]
        local ProtectedInstance = Tfind(ProtectedInstances, IsACheck);
        if (ProtectedInstance and Args[2]) then
            return false
        end
    end
    return Hooks.IsA(...);
end));

local UndetectedCmdBar;
Hooks.OldGetFocusedTextBox = hookfunction(Services.UserInputService.GetFocusedTextBox, newcclosure(function(...)
    if (not checkcaller() and UndetectedCmdBar) then
        local FocusedTextBox = Hooks.OldGetFocusedTextBox(...);
        if (FocusedTextBox and Tfind(ProtectedInstances, FocusedTextBox)) then
            return nil
        end
    end
    return Hooks.OldGetFocusedTextBox(...);
end));

Hooks.OldKick = hookfunction(LocalPlayer.Kick, newcclosure(function(...)
    local Player, Message = ...
    if (Hooks.AntiKick and Player == LocalPlayer) then
        local Notify = Utils.Notify
        local Context;
        local sett, gett = setthreadidentity, getthreadidentity
        if (sett) then
            Context = gett();
            sett(3);
        end
        if (Notify and Context) then
            Notify(nil, "Attempt to kick", format("attempt to kick %s", (Message and type(Message) == 'number' or type(Message) == 'string') and ": " .. Message or ""));
            sett(Context)
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
        local sett, gett = setthreadidentity, getthreadidentity
        if (sett) then
            Context = gett();
            sett(3);
        end
        if (Notify and Context) then
            Notify(nil, "Attempt to teleport", format("attempt to teleport to place %s", PlaceId and PlaceId or ""));
            sett(Context)
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
        local sett, gett = setthreadidentity, getthreadidentity
        if (sett) then
            Context = gett();
            sett(3);
        end
        if (Notify and Context) then
            Notify(nil, "Attempt to teleport", format("attempt to teleport to place \"%s\"", PlaceId and PlaceId or ""));
            sett(Context);
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
    local Parent, Character = Humanoid.Parent, LocalPlayer.Character
    if (Hooks.NoJumpCooldown and (State == Enum.HumanoidStateType.Jumping or State == "Jumping") and Parent and Character and Parent == Character) then
        return false
    end
    return Hooks.GetStateEnabled(...);
end)

do
    local LogService = Services.LogService
    local MessageOut = LogService.MessageOut
    Hooks.MessagesOut = {}
    local MessagesOut = Hooks.MessagesOut

    Hooks.Print = hookfunction(print, newcclosure(function(...)
        if (Hooks.UndetectedMessageOut and checkcaller()) then
            local MessageOutConnections = getconnections(MessageOut);
            for i = 1, #MessageOutConnections do
                MessageOutConnections[i]:Disable();
            end
            local Print = Hooks.Print(...);
            MessagesOut[#MessagesOut + 1] = concat(map({...}, function(i, v)
                return tostring(v);
            end), " ") .. " ";
            for i = 1, #MessageOutConnections do
                MessageOutConnections[i]:Enable();
            end
            return Print
        end
        return Hooks.Print(...);
    end));
    
    Hooks.Warn = hookfunction(warn, newcclosure(function(...)
        if (Hooks.UndetectedMessageOut and checkcaller()) then
            local MessageOutConnections = getconnections(MessageOut);
            for i = 1, #MessageOutConnections do
                MessageOutConnections[i]:Disable();
            end
            local Warn = Hooks.Warn(...);
            MessagesOut[#MessagesOut + 1] = concat(map({...}, function(i, v)
                return tostring(v);
            end), " ") .. " ";
            for i = 1, #MessageOutConnections do
                MessageOutConnections[i]:Enable();
            end
            return Warn
        end
        return Hooks.Warn(...);
    end))

    Hooks.OldGetLogHistory = hookfunction(LogService.GetLogHistory, newcclosure(function(...)
        if (Hooks.UndetectedMessageOut) then
            local LogHistory = Hooks.OldGetLogHistory(...);
            local FilteredLogHistory = {}
            for i, v in next, LogHistory do
                if (not Tfind(MessagesOut, v.message)) then
                    FilteredLogHistory[#FilteredLogHistory + 1] = v
                end
            end
            return FilteredLogHistory
        end
        return Hooks.OldGetLogHistory(...);
    end))
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

-- local UnSpoofProperty = function(Instance_, Property)
--     local SpoofedProperty = SpoofedProperties[Instance_]
--     if (SpoofedProperty and SpoofedProperty.Property == Property) then
--         Destroy(SpoofedProperty.SpoofedProperty);
--         SpoofedInstances[Instance_] = nil
--     end
-- end