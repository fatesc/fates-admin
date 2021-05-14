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
local Methods = {
    "FindFirstChild",
    "FindFirstChildWhichIsA",
    "FindFirstChildOfClass",
    "IsA"
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

mt.__namecall = newcclosure(function(self, ...)
    local Return = __Namecall(self, ...);
    if (checkcaller()) then
        return Return
    end
    
    local Method = getnamecallmethod():gsub("%z", function(x)
        return x
    end):gsub("%z", "");
    local Args = {...}

    if (table.find(Methods, Method) and table.find(ProtectedInstances, self)) then 
        return Method == "IsA" and false or nil
    end
    if (Method == "GetMemoryUsageMbForTag" and game.PlaceId == 6650331930) then
        -- return OldMemoryTags[Args[1]]
        return Stats:GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.Gui) - 1
    end
    if (AntiKick and string.lower(Method) == "kick") then
        getgenv().F_A.Utils.Notify(LocalPlayer, "Attempt to kick", ("attempt to kick with message \"%s\""):format(Args[1]));
        return
    end
    if (AntiTeleport and Method == "Teleport" or Method == "TeleportToPlaceInstance") then
        getgenv().F_A.Utils.Notify(Caller or LocalPlayer, "Attempt to teleport", "an attempt to teleport has been made");
        return
    end
    return Return
end)

mt.__index = newcclosure(function(Instance_, index)
    local Return = __Index(Instance_, index);
    if (checkcaller()) then
        return Return
    end

    index = type(index) == 'string' and index:gsub("%z", function(x)
        return x
    end):gsub("%z", "") or index
    
    if (index == "ClassName" and table.find(ProtectedInstances, Instance_)) then
        -- return "Part"
    end
    if (table.find(Methods, index) and table.find(ProtectedInstances, Instance_)) then
        return function()
            return index == "IsA" and false or nil
        end
    end
    if (index == "GetMemoryUsageMbForTag" and game.PlaceId == 6650331930) then
        return function()
            return Stats:GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.Gui) - 1
        end
    end

    if (AntiKick and type(index) == 'string' and string.lower(index) == "kick") then
        getgenv().F_A.Utils.Notify(Caller or LocalPlayer, "Attempt to kick", "an attempt to kick has been made");
        return function() return end
    end
    if (AntiTeleport and index == "Teleport" or index == "TeleportToPlaceInstance") then
        getgenv().F_A.Utils.Notify(Caller or LocalPlayer, "Attempt to teleport", "an attempt to teleport has been made");
        return function() return end
    end

    return Return
end)

setreadonly(mt, true);


local ProtectInstance = function(Instance_)
    ProtectedInstances[#ProtectedInstances + 1] = Instance_
    if (syn and syn.protect_gui) then
        syn.protect_gui(Instance_);
    end
end