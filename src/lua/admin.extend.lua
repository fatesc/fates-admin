if (setreadonly) then
    setreadonly(table, false);
    setreadonly(string, false)
else
    local makewritable = function(global)
        if (getfenv()[global]) then
            local new = {}
            local old = getfenv()[global]
            for i, v in next, old do
                new[i] = v
            end
            return new
        end
        return {}
    end

    table = makewritable("table");
    string = makewritable("string");
end

---Returns true if the sequence of elements of searchString converted to a String is the same as the corresponding elements of this object (converted to a String) starting at position. Otherwise returns fals
---@param searchString string
---@param rawPos number
---@return string
string.startsWith = function(str, searchString, rawPos)
	local pos = rawPos and (rawPos > 0 and rawPos or 0) or 0
	return searchString == "" and true or string.sub(str, pos, pos + #searchString) == searchString
end

---trims the string
---@param str any
---@return string
string.trim = function(str)
	return str:gsub("^%s*(.-)%s*$", "%1");
end

---The table.tbl_concat() method concatenates the string arguments to the calling string and returns a new string.
---@return table
table.tbl_concat = function(...)
	local new = {}
	for i, v in next, {
		...
	} do
		for i2, v2 in next, v do
			table.insert(new, i, v2);
		end
	end
	return new
end

---The string.indexOf() method returns the index within the calling String object of the first occurrence of the specified value, starting the search at fromIndex. Returns -1 if the value is not found.
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

---The table.forEach() method executes a provided function once for each array element.
---@param tbl table
---@param ret function
table.forEach = function(tbl, ret)
	for i, v in next, tbl do
		ret(i, v);
	end
end

---The table.filter() method creates a new array with all elements that pass the test implemented by the provided function.
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

---The table.map() method creates a new array populated with the results of calling a provided function on every element in the calling array
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

---deepsearches a table with the callback on each value
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

---The flatMap() method returns a new array formed by applying a given callback function to each element of the array, and then flattening the result by one level. It is identical to a map() followed by a flat() of depth 1, but slightly more efficient than calling those two methods separately.
---@param tbl table
---@param ret function
---@return table
table.flatMap = function(tbl, ret)
	if (type(tbl) == 'table') then
		local new = table.flat(table.map(tbl, ret));
		return new
	end
end

---The table.shift() method removes the first element from an array and returns that removed element. This method changes the length of the array.
---@param tbl any
table.shift = function(tbl)
	if (type(tbl) == 'table') then
		local firstVal = tbl[1]
		tbl = table.pack(table.unpack(tbl, 2, #tbl));
		tbl.n = nil
		return tbl
	end
end


-- local OldEnv, Mt = getfenv() or function()
--     return _ENV
-- end, {
--     __index = function(self, key)
--         return table[key]
--     end
-- }
-- local NewEnv = setmetatable({}, {
--     __index = function(self, key)
--         return OldEnv[key]
--     end,
--     __newindex = function(self, key, val)
--         if (type(val) == 'table') then
--             setmetatable(val, Mt);
--         end
--         OldEnv[key] = val
--         return val
--     end
-- });
-- if (_ENV) then
--     _ENV = NewEnv
-- else
--     setfenv(1, NewEnv);
-- end
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