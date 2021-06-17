local IsSupportedExploit = isfile and isfolder and writefile and readfile
local PluginConf = IsSupportedExploit and GetPluginConfig();
local IsDebug = IsSupportedExploit and PluginConf.PluginDebug

local LoadPlugin = function(Plugin)
    if (not IsSupportedExploit) then
        return 
    end
    if (Plugin and PluginConf.DisabledPlugins[Plugin.Name]) then
        return Utils.Notify(LocalPlayer, "Plugin not loaded.", ("Plugin %s was not loaded as it is on the disabled list."):format(Plugin.Name));
    end
    if (#table.keys(Plugin) < 3) then
        return IsDebug and Utils.Notify(LocalPlayer, "Plugin Fail", "One of your plugins is missing information.") or nil
    end
    if (IsDebug) then
        Utils.Notify(LocalPlayer, "Plugin loading", ("Plugin %s is being loaded."):format(Plugin.Name));
    end

    local Ran, Return = pcall(Plugin.Init);
    if (not Ran and Return and IsDebug) then
        return Utils.Notify(LocalPlayer, "Plugin Fail", ("there is an error in plugin Init %s: %s"):format(Plugin.Name, Return));
    end
    
    for i, command in next, Plugin.Commands or {} do -- adding the "or" because some people might have outdated plugins in the dir
        if (#table.keys(command) < 3) then
            Utils.Notify(LocalPlayer, "Plugin Command Fail", ("Command %s is missing information"):format(command.Name));
            continue
        end
        AddCommand(command.Name, command.Aliases or {}, command.Description .. " - " .. Plugin.Author, command.Requirements or {}, command.Func);

        if (Commands.Frame.List:FindFirstChild(command.Name)) then
            Commands.Frame.List:FindFirstChild(command.Name):Destroy();
        end
        local Clone = Command:Clone();
        Utils.Hover(Clone, "BackgroundColor3");
        Utils.ToolTip(Clone, command.Name .. "\n" .. command.Description .. " - " .. Plugin.Author);
        Clone.CommandText.RichText = true
        Clone.CommandText.Text = ("%s %s %s"):format(command.Name, next(command.Aliases or {}) and ("(%s)"):format(table.concat(command.Aliases, ", ")) or "", Utils.TextFont("[PLUGIN]", {77, 255, 255}));
        Clone.Name = command.Name
        Clone.Visible = true
        Clone.Parent = Commands.Frame.List
        if (IsDebug) then
            Utils.Notify(LocalPlayer, "Plugin Command Loaded", ("Command %s loaded successfully"):format(command.Name));
        end
    end
end

if (IsSupportedExploit) then
    if (not isfolder("fates-admin") and not isfolder("fates-admin/plugins") and not isfolder("fates-admin/plugin-conf.json") or not isfolder("fates-admin/chatlogs")) then
        WriteConfig();
    end
end

--Fixed random crashing and improper handling
local Plugins = {}
if IsSupportedExploit then
    for i,v in pairs(listfiles("fates-admin/plugins")) do
        if string.find(v,".lua") then
            Plugins[#Plugins + 1] = {split(v,"([^\\]+)")[2],loadfile(v)}
        end
    end
end

utils.LoadPlugin = LoadPlugin

for i, Plugin in pairs(Plugins) do
    if not Plugin[2] then
        Utils.Notify(LocalPlayer, nil, Plugin[1].." failed to load due to error...");
    else
        LoadPlugin(Plugin[2]());
    end
end

AddCommand("refreshplugins", {"rfp", "refresh", "reload"}, "Loads all new plugins.", {}, function()
    if (not IsSupportedExploit) then
        return "your exploit does not support plugins"
    end
    PluginConf = GetPluginConfig();
    IsDebug = PluginConf.PluginDebug
    
    Plugins = table.map(table.filter(listfiles("fates-admin/plugins"), function(i, v)
        return v:split(".")[#v:split(".")]:lower() == "lua"
    end), function(i, v)
        return {v:split("\\")[2], loadfile(v)}
    end)
    
    for i, Plugin in next, Plugins do
        LoadPlugin(Plugin[2]());
    end
end)
