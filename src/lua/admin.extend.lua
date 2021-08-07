local Debug = true

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

local getconnections = function(...)
    if (not getconnections) then
        return {}
    end
    local Connections = getconnections(...);
    do return Connections end
    local ActualConnections = filter(Connections, function(i, Connection)
        if (Connection.Function) then
            if (syn and not is_synapse_function(Connection.Function)) then
                return true
            end
            return true
        end
        return false
    end);
    return ActualConnections
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
    NoJumpCooldown = false
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
do
    local ProtectedInstances = {}
    local SpoofedInstances = {}
    local SpoofedProperties = {}
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
            SpoofedProperties[Instance_] = {{
                SpoofedProperty = NoClone and Instance_ or Clone(Instance_),
                Property = Property,
            }}
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

        if (checkcaller()) then
            return __Namecall(...);
        end

        local Method = getnamecallmethod();
        local Protected = Tfind(ProtectedInstances, self);

        if (Protected) then
            if (Tfind(Methods, Method)) then
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

        if (Hooks.AntiKick and lower(Method) == "kick") then
            getgenv().F_A.Utils.Notify(nil, "Attempt to kick", format("attempt to kick with message \"%s\"", Args[2]));
            return
        end

        if (Hooks.AntiTeleport and Method == "Teleport" or Method == "TeleportToPlaceInstance") then
            getgenv().F_A.Utils.Notify(nil, "Attempt to teleport", format("attempt to teleport to place \"%s\"", Args[2]));
            return
        end

        if (Hooks.NoJumpCooldown and Method == "GetState" or Method == "GetStateEnabled") then
            local State = __Namecall(...);
            if (Method == "GetState" and State == Enum.HumanoidStateType.Jumping) then
                return Enum.HumanoidStateType.RunningNoPhysics
            end
            if (Method == "GetStateEnabled" and Args[1] == Enum.HumanoidStateType.Jumping) then
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
        local ProtectedInstance = Tfind(ProtectedInstances, Instance_);
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

        if (Tfind(ProtectedInstances, __Index(...))) then
            return nil
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
            if (Index == "Parent" and false) then
                local ProtectedInstance = Tfind(ProtectedInstances, Instance_)
                if (ProtectedInstance) then
                    local Parents = GetAllParents(Value);
                    for i, v in next, getconnections(Parents[1].ChildAdded) do
                        v.Disable(v);
                    end
                    for i = 1, #Parents do
                        local Parent = Parents[i]
                        for i2, v in next, getconnections(Parent.DescendantAdded) do
                            v.Disable(v);
                        end
                    end
                    local Ret = __NewIndex(...);
                    for i = 1, #Parents do
                        local Parent = Parents[i]
                        for i2, v in next, getconnections(Parent.DescendantAdded) do
                            v.Enable(v);
                        end
                    end
                    for i, v in next, getconnections(Parents[1].ChildAdded) do
                        v.Enable(v);
                    end
                    return Ret
                end
            end
            if (SpoofedInstance or SpoofedPropertiesForInstance) then
                local Connections = getconnections(GetPropertyChangedSignal(Instance_, SpoofedPropertiesForInstance and SpoofedPropertiesForInstance.Property or Index));
                local Connections2 = getconnections(Instance_.Changed);

                if (not next(Connections) and not next(Connections2)) then
                    return __NewIndex(Instance_, Index, Value);
                end
                for i, v in next, Connections do
                    v.Disable(v);
                end
                for i, v in next, Connections2 do
                    v.Disable(v);
                end
                local Ret = __NewIndex(Instance_, Index, Value);
                for i, v in next, Connections do
                    v.Enable(v);
                end
                for i, v in next, Connections2 do
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
                    return __NewIndex(SpoofedProperty.SpoofedProperty, Index, __Index(SpoofedProperty.SpoofedProperty, Index));
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

Hooks.OldGetFocusedTextBox = hookfunction(Services.UserInputService.GetFocusedTextBox, newcclosure(function(...)
    if (not checkcaller()) then
        local FocusedTextBox = Hooks.OldGetFocusedTextBox(...);
        if (FocusedTextBox and Tfind(ProtectedInstances, FocusedTextBox)) then
            return nil
        end
    end
    return Hooks.OldGetFocusedTextBox(...);
end, Services.UserInputService.GetFocusedTextBox));

Hooks.OldKick = hookfunction(LocalPlayer.Kick, newcclosure(function(...)
    if (Hooks.AntiKick) then
        getgenv().F_A.Utils.Notify(nil, "Attempt to kick", format("attempt to kick with message \"%s\"", ({...})[2]));
        return
    end
    return Hooks.OldKick(...);
end, LocalPlayer.Kick))

Hooks.OldTeleportToPlaceInstance = hookfunction(Services.TeleportService.TeleportToPlaceInstance, newcclosure(function(...)
    if (Hooks.AntiTeleport) then
        getgenv().F_A.Utils.Notify(nil, "Attempt to teleport", format("attempt to teleport to place \"%s\"", ({...})[2]));
        return
    end
    return Hooks.OldTeleportToPlaceInstance(...);
end))

Hooks.OldTeleport = hookfunction(Services.TeleportService.Teleport, newcclosure(function(...)
    if (AntiTeleport) then
        getgenv().F_A.Utils.Notify(nil, "Attempt to teleport", format("attempt to teleport to place \"%s\"", ({...})[2]));
        return
    end
    return Hooks.OldTeleport(...);
end))

Hooks.GetState = hookfunction(GetState, function(...)
    local State = Hooks.GetState(...);
    if (State == Enum.HumanoidStateType.Jumping) then
        return Enum.HumanoidStateType.RunningNoPhysics
    end
    return State
end)

Hooks.GetStateEnabled = hookfunction(__H.GetStateEnabled, function(...)
    if (({...})[1] == Enum.HumanoidStateType.Jumping) then
        return false
    end
    return Hooks.GetStateEnabled(...);
end)

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