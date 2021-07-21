local IsSupportedExploit = isfile and isfolder and writefile and readfile
local PluginConf = IsSupportedExploit and GetPluginConfig();
local Plugins;

do
    local IsDebug = IsSupportedExploit and PluginConf.PluginDebug
    
    Plugins = IsSupportedExploit and map(filter(listfiles("fates-admin/plugins"), function(i, v)
        return lower(split(v, ".")[#split(v, ".")]) == "lua"
    end), function(i, v)
        return {split(v, "\\")[2], loadfile(v)}
    end) or {}

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
    end
end