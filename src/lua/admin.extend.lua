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
    local pos = rawPos or 1
    return searchString == "" and true or string.sub(str, pos, pos) == searchString
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

getconnections = getconnections or function()
    return {}
end

getrawmetatable = getrawmetatable or function()
    return setmetatable({}, {});
end

getnamecallmethod = getnamecallmethod or function()
    return ""
end

checkcaller = checkcaller or function()
    return false
end

getgc = getgc or function()
    return {}
end

local ISPF, Network, Client, GetBodyParts, GunTbl, Trajectory
if (game.PlaceId == 292439477) then
    ISPF = true
    for i, v in next, getgc(true) do
        if (type(v) == "table") then
            if (rawget(v, "send")) then
                Network = v
            end
            if (rawget(v, "getbodyparts")) then
                GetBodyParts = rawget(v, "getbodyparts");
            end
            if (rawget(v, "setsprintdisable")) then
                GunTbl = v
            end
            if (rawget(v, "setsway")) then
                Client = v
            end
        elseif (type(v) == "function") then
            local funcinfo = debug.getinfo(v);
            if (funcinfo.name == "trajectory") then
                Trajectory = v
            end
        end
        if (GunTbl and GetBodyParts and Network and Trajectory) then
            break
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
local SilentAimingPlayer = nil
local SilentAimHitChance = 100
local AimBone = "Head"
local Wallbang = true
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
    
    local Args = {...}

    local Method = getnamecallmethod():gsub("%z.*", "");


    local Protected = ProtectedInstances[self]

    if (Protected) then
        if (table.find(Methods, Method)) then
            return Method == "IsA" and false or nil
        end
    end

    if (Method == "GetChildren" or Method == "GetDescendants") then
        return table.filter(__Namecall(self, ...), function(i, v)
            return not table.find(ProtectedInstances, v);
        end)
    end

    if (Method == "GetFocusedTextBox") then
        if (table.find(ProtectedInstances, __Namecall(self, ...))) then
            return nil
        end
    end

    if (not ISPF and self == Workspace and Method == "FindPartOnRay" and SilentAimingPlayer) then
        local Char = GetCharacter(SilentAimingPlayer);
        local Chance = math.random(1, 100) < SilentAimHitChance
        if (Char and Char[AimBone] and Chance) then  
            local Viewable = not next(Camera.GetPartsObscuringTarget(Camera, {Camera.CFrame.Position, Char[AimBone].Position}, {LocalPlayer.Character, Char}));
            if (Viewable or Wallbang) then
                return Char[AimBone], Char[AimBone].Position + (Vector3.new(math.random(1, 10), math.random(1, 10), math.random(1, 10)) / 10), Vector3.new(0, 1, 0), Char[AimBone].Material
            end
        end
    end

    if (not ISPF and self == Workspace and Method == "FindPartOnRayWithIgnoreList" and SilentAimingPlayer and getcallingscript().Name ~= "CameraModule") then
        local Char = GetCharacter(SilentAimingPlayer);
        local Chance = math.random(1, 100) < SilentAimHitChance
        
        if (Char and Char[AimBone]) then
            local Viewable = not next(Camera.GetPartsObscuringTarget(Camera, {Camera.CFrame.Position, Char[AimBone].Position}, {LocalPlayer.Character, Char}));
            print(Viewable);
            if (Viewable or Wallbang) then
                return Char[AimBone], Char[AimBone].Position + (Vector3.new(math.random(1, 10), math.random(1, 10), math.random(1, 10)) / 10), Vector3.new(0, 1, 0), Char[AimBone].Material
            end
        end
    end

    if (AntiKick and string.lower(Method) == "kick") then
        getgenv().F_A.Utils.Notify(nil, "Attempt to kick", ("attempt to kick with message \"%s\""):format(Args[1]));
        return
    end

    if (AntiTeleport and Method == "Teleport" or Method == "TeleportToPlaceInstance") then
        getgenv().F_A.Utils.Notify(nil, "Attempt to teleport", ("attempt to teleport to place \"%s\""):format(Args[1]));
        return
    end

    return __Namecall(self, unpack(Args));
end)

mt.__index = newcclosure(function(Instance_, Index)
    if (checkcaller()) then
        return __Index(Instance_, Index);
    end

    local SanitisedIndex = type(Index) == 'string' and Index:gsub("%z.*", "") or Index

    local ProtectedInstance = ProtectedInstances[Instance_]
    local SpoofedInstance = SpoofedInstances[Instance_]
    local SpoofedPropertiesForInstance = SpoofedProperties[Instance_]

    if (SpoofedInstance) then
        if (table.find(AllowedIndexes, SanitisedIndex)) then
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
            if (SanitisedIndex == SpoofedProperty.Property) then
                return __Index(SpoofedProperty.SpoofedProperty, Index);
            end
        end
    end

    if (ProtectedInstance) then
        if (table.find(Methods, SanitisedIndex)) then
            return newcclosure(function()
                return SanitisedIndex == "IsA" and false or nil
            end);
        end
    end

    if (Instance_ == Mouse and SilentAimingPlayer) then
        local Char = GetCharacter(SilentAimingPlayer);
        local Chance = math.random(1, 100) < SilentAimHitChance
        if (Char and Char[AimBone] and Chance) then
            local ViewportPoint = Camera:WorldToViewportPoint(Char[AimBone].Position);
            local Viewable = not next(Camera.GetPartsObscuringTarget(Camera, {Camera.CFrame.Position, Char[AimBone].Position}, {LocalPlayer.Character, Char}));
            if (SanitisedIndex:lower() == "target") then
                if (Viewable or Wallbang) then
                    return Char[AimBone]
                end
            elseif (SanitisedIndex:lower() == "hit" and (Viewable or Wallbang)) then
                if (Viewable or Wallbang) then
                    return Char[AimBone].CFrame * CFrame.new(math.random(1, 10) / 10, math.random(1, 10) / 10, math.random(1, 10) / 10);
                end
            elseif (SanitisedIndex:lower() == "x" and (Viewable or Wallbang)) then
                return ViewportPoint.X + (math.random(1, 10) / 10);
            elseif (SanitisedIndex == "y" and (Viewable or Wallbang)) then
                return ViewportPoint.Y + (math.random(1, 10) / 10);
            end
        end
    end

    -- if (ISPF and GunTbl.currentgun and tostring(Instance_) == "SightMark" and Index == "CFrame" and SilentAimingPlayer) then
    --     local Char = GetCharacter(SilentAimingPlayer);
    --     local Chance = math.random(1, 100) < SilentAimHitChance
    --     if (Char and Char[AimBone] and Chance) then
    --         return CFrame.new(Instance_.Position, Char[AimBone].Position);
    --     end
    -- end

    return __Index(Instance_, Index);
end)

mt.__newindex = newcclosure(function(Instance_, Index, Value)
    local SpoofedInstance = SpoofedInstances[Instance_]
    local SpoofedPropertiesForInstance = SpoofedProperties[Instance_]

    if (checkcaller()) then
        local Connections = getconnections(Instance_:GetPropertyChangedSignal(Index));
        if (next(Connections)) then
            for i, v in next, Connections do
                v:Disable();
            end
            local Suc, Ret = pcall(function()
                return __NewIndex(Instance_, Index, Value);
            end)
            for i, v in next, Connections do
                v:Enable();
            end
            return Ret
        end
        return __NewIndex(Instance_, Index, Value);
    end

    local SanitisedIndex = type(Index) == 'string' and Index:gsub("%z.*", "") or Index

    if (SpoofedInstance) then
        if (table.find(AllowedNewIndexes, SanitisedIndex)) then
            return __NewIndex(Instance_, Index, Value);
        end
        return __NewIndex(SpoofedInstance, Index, __Index(SpoofedInstance, Index));
    end

    if (SpoofedPropertiesForInstance) then
        for i, SpoofedProperty in next, SpoofedPropertiesForInstance do
            if (SpoofedProperty.Property == SanitisedIndex and not table.find(AllowedIndexes, SanitisedIndex)) then
                return __NewIndex(SpoofedProperty.SpoofedProperty, Index, __Index(SpoofedProperty.SpoofedProperty, Index));
            end
        end
    end

    return __NewIndex(Instance_, Index, Value);
end)

setreadonly(mt, true);

local OldGetChildren
OldGetChildren = hookfunction(game.GetChildren, function(...)
    if (not checkcaller()) then
        local Children = OldGetChildren(...);
        if (table.find(Children, ProtectedInstances)) then
            return table.filter(Children, function(i, v)
                return not table.find(ProtectedInstances, v);
            end)
        end
    end
    return OldGetChildren(...);
end)

local OldGetDescendants
OldGetDescendants = hookfunction(game.GetDescendants, newcclosure(function(...)
    if (not checkcaller()) then
        local Descendants = OldGetDescendants(...);
        if (table.find(Descendants, ProtectedInstances)) then
            return table.filter(Descendants, function(i, v)
                return not table.find(ProtectedInstances, v);
            end)
        end
    end
    return OldGetDescendants(...);
end))

local OldGetFocusedTextBox
OldGetFocusedTextBox = hookfunction(game:GetService("UserInputService").GetFocusedTextBox, newcclosure(function(...)
    if (not checkcaller()) then
        local FocusedTextBox = OldGetFocusedTextBox(...);
        if (FocusedTextBox and table.find(ProtectedInstances, FocusedTextBox)) then
            return nil
        end
    end
    return OldGetFocusedTextBox(...);
end))

local OldKick
OldKick = hookfunction(Instance.new("Player").Kick, newcclosure(function(self, ...)
    if (AntiKick) then
        local Args = {...}
        getgenv().F_A.Utils.Notify(nil, "Attempt to kick", ("attempt to kick with message \"%s\""):format(Args[1]));
        return
    end

    return OldKick(self, ...);
end))

local OldTeleportToPlaceInstance
OldTeleportToPlaceInstance = hookfunction(game:GetService("TeleportService").TeleportToPlaceInstance, newcclosure(function(self, ...)
    if (AntiTeleport) then
        getgenv().F_A.Utils.Notify(nil, "Attempt to teleport", ("attempt to teleport to place \"%s\""):format(Args[1]));
        return
    end
    return OldTeleportToPlaceInstance(self, ...);
end))
local OldTeleport
OldTeleport = hookfunction(game:GetService("TeleportService").Teleport, newcclosure(function(self, ...)
    if (AntiTeleport) then
        getgenv().F_A.Utils.Notify(nil, "Attempt to teleport", ("attempt to teleport to place \"%s\""):format(Args[1]));
        return
    end
    return OldTeleport(self, ...);
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

local OldFindPartOnRay
OldFindPartOnRay = hookfunction(Workspace.FindPartOnRay, newcclosure(function(...)
    if (not ISPF and SilentAimingPlayer) then
        local Char = GetCharacter(SilentAimingPlayer);
        local Chance = math.random(1, 100) < SilentAimHitChance
        if (Char and Char[AimBone] and Chance) then
            local Viewable = not next(Camera.GetPartsObscuringTarget(Camera, {Camera.CFrame.Position, Char[AimBone].Position}, {LocalPlayer.Character, Char}));
            if (Viewable or Wallbang) then
                return Char[AimBone], Char[AimBone].Position + (Vector3.new(math.random(1, 10), math.random(1, 10), math.random(1, 10)) / 10), Vector3.new(0, 1, 0), Char[AimBone].Material
            end
        end
    end
    return OldFindPartOnRay(...);
end))
local OldFindPartOnRayWithIgnoreList
OldFindPartOnRayWithIgnoreList = hookfunction(Workspace.FindPartOnRayWithIgnoreList, newcclosure(function(...)
    if (not ISPF and SilentAimingPlayer and getcallingscript().Name ~= "CameraModule") then
        local Char = GetCharacter(SilentAimingPlayer);
        local Chance = math.random(1, 100) < SilentAimHitChance
        if (Char and Char[AimBone] and Chance) then
            local Viewable = not next(Camera.GetPartsObscuringTarget(Camera, {Camera.CFrame.Position, Char[AimBone].Position}, {LocalPlayer.Character, Char}));
            if (Viewable or Wallbang) then
                return Char[AimBone], Char[AimBone].Position + (Vector3.new(math.random(1, 10), math.random(1, 10), math.random(1, 10)) / 10), Vector3.new(0, 1, 0), Char[AimBone].Material
            end
        end
    end
    return OldFindPartOnRayWithIgnoreList(...);
end))
if (ISPF and Network and Network.send) then
    local OldSend = Network.send
    Network.send = function(...)
        local Args = {...}
        local Type = Args[2]
        if (Type == "newbullets") then
            local Char
            if (SilentAimingPlayer) then
                Char = GetCharacter(SilentAimingPlayer);
            end
            if (Char and Char[AimBone]) then
                local AimPos = Char[AimBone].Position + (Vector3.new(math.random(1, 10), math.random(1, 10), math.random(1, 10)) / 10);
                Args[3].bullets[1][1] = Trajectory(Client.basecframe * Vector3.new(0, 0, 1), Vector3.new(0, -Workspace.Gravity, 0), AimPos, GunTbl.currentgun.data.bulletspeed);
      
                OldSend(Args[1], "newbullets", Args[3], Args[4]);
                OldSend(Args[1], "bullethit", SilentAimingPlayer, AimPos, GetCharacter(SilentAimingPlayer).Head, Args[3].bullets[1][2]);
                return
            end
        end
        return OldSend(...)
    end
end

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
        SpoofedInstances[Instance_] = Instance2 and Instance2 or Instance_:Clone();
    end
end

local SpoofProperty = function(Instance_, Property)
    if (SpoofedProperties[Instance_]) then
        local Properties = table.map(SpoofedProperties[Instance_], function(i, v)
            return v.Property
        end)
        if (not table.find(Properties, Property)) then
            table.insert(SpoofedProperties[Instance_], {
                SpoofedProperty = SpoofedProperties[Instance_].SpoofedProperty,
                Property = Property,
            });
        end
    else
        SpoofedProperties[Instance_] = {{
            SpoofedProperty = Instance_:Clone(),
            Property = Property,
        }}
    end
end

local UnProtectInstance = function(Instance_)
    for i, v in next, ProtectedInstances do
        if (ProtectedInstances[i] == Instance_) then
            ProtectedInstances[i] = nil
        end
    end
end

local UnSpoofInstance = function(Instance_)
    if (SpoofedInstances[Instance_]) then
        SpoofedInstances[Instance_]:Destroy();
        SpoofedInstances[Instance_] = nil
    end
end
local UnSpoofProperty = function(Instance_, Property)
    local SpoofedProperty = SpoofedProperties[Instance_]
    if (SpoofedProperty and SpoofedProperty.Property == Property) then
        SpoofedProperty.SpoofedProperty:Destroy();
        SpoofedInstances[Instance_] = nil
    end
end