local IsSupportedExploit = isfile and isfolder and writefile and readfile
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
    clone = clone
}

do
    local IsDebug = IsSupportedExploit and PluginConf.PluginDebug
    
    Plugins = IsSupportedExploit and map(filter(listfiles("fates-admin/plugins"), function(i, v)
        return lower(split(v, ".")[#split(v, ".")]) == "lua"
    end), function(i, v)
        local splitted = split(v, "\\")
        return {splitted[#splitted], loadfile(v)}
    end) or {}

    local Renv = getrenv();
    for i, v in next, PluginLibrary do
        Renv[i] = v
    end
    Renv.debug = nil


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
            if (PluginConf.SafePlugins) then
                if (syn_context_set or setthreadidentity) then
                    Context = (syn_context_get or getthreadidentity)();
                    (syn_context_set or setthreadidentity)(2);
                end
            end
            local Ran, Return = pcall(Plugin.Init);
            if (not Ran and Return and IsDebug) then
                return Utils.Notify(LocalPlayer, "Plugin Fail", format("there is an error in plugin Init %s: %s", Plugin.Name, Return));
            end
            if (setthreadidentity or  syn_context_set and CurrentConfig.SafePlugins) then
                (syn_context_set or setthreadidentity)(Context);
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
            local PluginFunc = Plugin[2]
            if (PluginConf.SafePlugins) then
                setfenv(PluginFunc, Renv);
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
                setfenv(PluginFunc, Renv);
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