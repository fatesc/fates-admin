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

local mt = getrawmetatable(game);
local OldMetaMethods = {}
setreadonly(mt, false);
for i, v in next, mt do
    OldMetaMethods[i] = v
end
local MetaMethodHooks = {}

MetaMethodHooks.Namecall = function(...)
    local __Namecall = OldMetaMethods.__namecall;
    local Args = {...}
    local self = Args[1]

    if (checkcaller()) then
        return __Namecall(...);
    end

    local Method = getnamecallmethod();
    local Protected = ProtectedInstances[self]

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

    if (AntiKick and lower(Method) == "kick") then
        getgenv().F_A.Utils.Notify(nil, "Attempt to kick", format("attempt to kick with message \"%s\"", Args[2]));
        return
    end

    if (AntiTeleport and Method == "Teleport" or Method == "TeleportToPlaceInstance") then
        getgenv().F_A.Utils.Notify(nil, "Attempt to teleport", format("attempt to teleport to place \"%s\"", Args[2]));
        return
    end

    return __Namecall(...);
end

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
    
    return __Index(...);
end

MetaMethodHooks.NewIndex = function(...)
    local __NewIndex = OldMetaMethods.__newindex;
    local __Index = OldMetaMethods.__index;
    local Instance_, Index, Value = ...

    local SpoofedInstance = SpoofedInstances[Instance_]
    local SpoofedPropertiesForInstance = SpoofedProperties[Instance_]

    if (checkcaller()) then
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
            local Suc, Ret = pcall(function()
                return __NewIndex(Instance_, Index, Value);
            end)
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

if (syn) then
    OldMetaMethods.__index = hookmetamethod(game, "__index", MetaMethodHooks.Index);
    OldMetaMethods.__newindex = hookmetamethod(game, "__newindex", MetaMethodHooks.NewIndex);
    OldMetaMethods.__namecall = hookmetamethod(game, "__namecall", MetaMethodHooks.Namecall);
else
    mt.__index = newcclosure(MetaMethodHooks.Index, mt.__index);
    mt.__namecall = newcclosure(MetaMethodHooks.Namecall, mt.__namecall);
    mt.__newindex = newcclosure(MetaMethodHooks.NewIndex, mt.__newindex);
end
setreadonly(mt, true);

local Hooks = {}

Hooks.OldGetChildren = nil
Hooks.OldGetChildren = hookfunction(game.GetChildren, newcclosure(function(...)
    if (not checkcaller()) then
        local Children = Hooks.OldGetChildren(...);
        return filter(Children, function(i, v)
            return not Tfind(ProtectedInstances, v);
        end)
    end
    return Hooks.OldGetChildren(...);
end, game.GetChildren));

Hooks.OldGetDescendants = nil
Hooks.OldGetDescendants = hookfunction(game.GetDescendants, newcclosure(function(...)
    if (not checkcaller()) then
        local Descendants = Hooks.OldGetDescendants(...);
        return filter(Descendants, function(i, v)
            return not Tfind(ProtectedInstances, v);
        end)
    end
    return Hooks.OldGetDescendants(...);
end, game.GetDescendants));

Hooks.OldGetFocusedTextBox = nil
Hooks.OldGetFocusedTextBox = hookfunction(Services.UserInputService.GetFocusedTextBox, newcclosure(function(...)
    if (not checkcaller()) then
        local FocusedTextBox = Hooks.OldGetFocusedTextBox(...);
        if (FocusedTextBox and Tfind(ProtectedInstances, FocusedTextBox)) then
            return nil
        end
    end
    return Hooks.OldGetFocusedTextBox(...);
end, Services.UserInputService.GetFocusedTextBox));

Hooks.OldKick = nil
Hooks.OldKick = hookfunction(LocalPlayer.Kick, newcclosure(function(...)
    if (AntiKick) then
        getgenv().F_A.Utils.Notify(nil, "Attempt to kick", format("attempt to kick with message \"%s\"", ({...})[2]));
        return
    end
    return Hooks.OldKick(...);
end, LocalPlayer.Kick))

Hooks.OldTeleportToPlaceInstance = nil
Hooks.OldTeleportToPlaceInstance = hookfunction(Services.TeleportService.TeleportToPlaceInstance, newcclosure(function(...)
    if (AntiTeleport) then
        getgenv().F_A.Utils.Notify(nil, "Attempt to teleport", format("attempt to teleport to place \"%s\"", ({...})[2]));
        return
    end
    return Hooks.OldTeleportToPlaceInstance(...);
end, Services.TeleportService.TeleportToPlaceInstance))
Hooks.OldTeleport = nil
Hooks.OldTeleport = hookfunction(Services.TeleportService.Teleport, newcclosure(function(...)
    if (AntiTeleport) then
        getgenv().F_A.Utils.Notify(nil, "Attempt to teleport", format("attempt to teleport to place \"%s\"", ({...})[2]));
        return
    end
    return Hooks.OldTeleport(...);
end, Services.TeleportService.Teleport))

local ProtectInstance = function(Instance_, disallow)
    if (not Tfind(ProtectedInstances, Instance_)) then
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