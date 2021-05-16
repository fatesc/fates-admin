Debug = true
if (getconnections) then
    local ErrorConnections = getconnections(game:GetService("ScriptContext").Error);
    if (next(ErrorConnections)) then
        getfenv().error = warn
        getgenv().error = warn
    end
end

local table = {}
for i,v in pairs(getfenv().table) do
    table[i] = v
end
local string = {}
for i,v in pairs(getfenv().string) do
    string[i] = v
end

---@param searchString string
---@param rawPos number
---@return boolean
string.startsWith = function(str, searchString, rawPos)
    local pos = rawPos and (rawPos > 0 and rawPos or 0) or 0
    return searchString == "" and true or string.sub(str, pos, pos + #searchString) == searchString
end

---@param str any
---@return string
string.trim = function(str)
    return str:gsub("^%s*(.-)%s*$", "%1");
end

---@return table
table.tbl_concat = function(...)
    local new = {}
    for i, v in next, {...} do
        for i2, v2 in next, v do
            table.insert(new, #new + 1, v2);
        end
    end
    return new
end

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

---@param tbl table
---@param ret function
table.forEach = function(tbl, ret)
    for i, v in next, tbl do
        ret(i, v);
    end
end

---@param tbl table
---@param ret function
---@return table
table.filter = function(tbl, ret)
    if (type(tbl) == 'table') then
        local new = {}
        for i, v in next, tbl do
            if (ret(i, v)) then
                table.insert(new, #new + 1, v);
            end
        end
        return new
    end
end

---@param tbl table
---@param ret function
---@return table
table.map = function(tbl, ret)
    if (type(tbl) == 'table') then
        local new = {}
        for i, v in next, tbl do
            table.insert(new, #new + 1, ret(i, v));
        end
        return new
    end
end

---@param tbl table
---@param ret function
table.deepsearch = function(tbl, ret)
    if (type(tbl) == 'table') then
        for i, v in next, tbl do
            if (type(v) == 'table') then
                table.deepsearch(v, ret);
            end
            ret(i, v);
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

---@param tbl table
---@param ret function
---@return table
table.flatMap = function(tbl, ret)
    if (type(tbl) == 'table') then
        local new = table.flat(table.map(tbl, ret));
        return new
    end
end

---@param tbl any
table.shift = function(tbl)
    if (type(tbl) == 'table') then
        local firstVal = tbl[1]
        tbl = table.pack(table.unpack(tbl, 2, #tbl));
        tbl.n = nil
        return tbl
    end
end

table.keys = function(tbl)
    if (type(tbl) == 'table') then
        local new = {}
        for i, v in next, tbl do
            new[#new + 1] = i	
        end
        return new
    end
end

local touched = {}
firetouchinterest = firetouchinterest or function(part1, part2, toggle)
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

hookfunction = hookfunction or function(func, newfunc)
    if (replaceclosure) then
        replaceclosure(func, newfunc);
        return newfunc
    end

    func = newcclosure and newcclosure(newfunc) or newfunc
    return newfunc
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
local Stats = game:GetService("Stats");
for i, v in next, Enum.DeveloperMemoryTag:GetEnumItems() do
    OldMemoryTags[v] = Stats:GetMemoryUsageMbForTag(v);
end

local mt = getrawmetatable(game);
local OldMetaMethods = {}
setreadonly(mt, false);
for i, v in next, mt do
    OldMetaMethods[i] = v
end
local __Namecall = OldMetaMethods.__namecall
local __Index = OldMetaMethods.__index
local __NewIndex = OldMetaMethods.__newindex

mt.__namecall = newcclosure(function(self, ...)
    if (checkcaller()) then
        return __Namecall(self, ...);
    end
    
    local Method = getnamecallmethod():gsub("%z", function(x)
        return x
    end):gsub("%z", "");

    local Protected = ProtectedInstances[self]

    if (Protected) then
        if (table.find(Methods, Method)) then
            return Method == "IsA" and false or nil
        end
    end
    return __Namecall(self, ...);
end)

mt.__index = newcclosure(function(Instance_, Index)
    if (checkcaller()) then
        return __Index(Instance_, Index);
    end

    Index = type(Index) == 'string' and Index:gsub("%z", function(x)
        return x
    end):gsub("%z", "") or Index
    
    local ProtectedInstance = ProtectedInstances[Instance_]
    local SpoofedInstance = SpoofedInstances[Instance_]
    local SpoofedPropertiesForInstance = SpoofedProperties[Instance_]

    if (SpoofedInstance) then
        if (table.find(AllowedIndexes, Index)) then
            return __Index(Instance_, Index);
        end
        if (Instance_:IsA("Humanoid") and game.PlaceId == 6650331930) then
            for i, v in next, getconnections(Instance_:GetPropertyChangedSignal("WalkSpeed")) do
                v:Disable();
            end
        end
        return __Index(SpoofedInstance, Index);
    end

    if (SpoofedPropertiesForInstance) then
        for i, SpoofedProperty in next, SpoofedPropertiesForInstance do
            if (Index == SpoofedProperty.Property) then
                return SpoofedProperty.Value
            end
        end
    end

    if (ProtectedInstance) then
        if (table.find(Methods, Index)) then
            return function()
                return Index == "IsA" and false or nil
            end
        end
    end

    return __Index(Instance_, Index);
end)

mt.__newindex = newcclosure(function(Instance_, Index, Value)
    if (checkcaller()) then
        return __NewIndex(Instance_, Index, Value);
    end

    local SpoofedInstance = SpoofedInstances[Instance_]
    local SpoofedPropertiesForInstance = SpoofedProperties[Instance_]

    if (SpoofedInstance) then
        if (table.find(AllowedNewIndexes, Index)) then
            return __NewIndex(Instance_, Index, Value);
        end
        return __NewIndex(SpoofedInstance, Index, SpoofedInstance[Index]);
    end

    if (SpoofedPropertiesForInstance) then
        for i, SpoofedProperty in next, SpoofedPropertiesForInstance do
            if (SpoofedProperty.Property == Index) then
                return __NewIndex(Instance_, Index, SpoofedProperty.Value);
            end
        end
    end

    return __NewIndex(Instance_, Index, Value);
end)

setreadonly(mt, true);

local OldKick
OldKick = hookfunction(game.Players.LocalPlayer.Kick, newcclosure(function(self, ...)
    if (AntiKick) then
        local Args = {...}
        getgenv().F_A.Utils.Notify(LocalPlayer, "Attempt to kick", ("attempt to kick with message \"%s\""):format(Args[1]));
        return
    end

    return OldKick(self, ...);
end))

local OldTeleportToPlaceInstance
OldTeleportToPlaceInstance = hookfunction(game:GetService("TeleportService").TeleportToPlaceInstance, newcclosure(function(self, ...)
    if (AntiTeleport) then
        return
    end
    return TeleportToPlaceInstance(self, ...)
end))
local OldTeleport
OldTeleport = hookfunction(game:GetService("TeleportService").Teleport, newcclosure(function(self, ...)
    if (AntiTeleport) then
        return
    end
    return Teleport(self, ...)
end))

local OldGetMemoryUsageMbForTag
OldGetMemoryUsageMbForTag = hookfunction(Stats.GetMemoryUsageMbForTag, newcclosure(function(self, ...)
    if (game.PlaceId == 6650331930) then
        local Args = {...}
        if (Args[1] == Enum.DeveloperMemoryTag.Gui) then
            return Stats:GetMemoryUsageMbForTag(Args[1]) - 1
        end
    end
    return OldGetMemoryUsageMbForTag(self, ...);
end))

local ProtectInstance = function(Instance_)
    if (not ProtectedInstances[Instance_]) then
        ProtectedInstances[#ProtectedInstances + 1] = Instance_
        if (syn and syn.protect_gui) then
            syn.protect_gui(Instance_);
        end
    end
end

local SpoofInstance = function(Instance_, Instance2)
    if (not SpoofedInstances[Instance_]) then
        SpoofedInstances[Instance_] = Instance2 and Instance2 or Instance_:Clone();
    end
end

local SpoofProperty = function(Instance_, Property, Value)
    if (SpoofedProperties[Instance_]) then
        local Properties = table.map(SpoofedProperties[Instance_], function(i, v)
            return v.Property
        end)
        if (not table.find(Properties, Property)) then
            table.insert(SpoofedProperties[Instance_], {
                Property = Property,
                Value = Value and Value or Instance_[Property]
            });
        end
        return
    end
    SpoofedProperties[Instance_] = {{
        Property = Property,
        Value = Value and Value or Instance_[Property]
    }}
end