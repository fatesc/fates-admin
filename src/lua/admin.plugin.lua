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
    ReplaceCharacter = ReplaceCharacter,
    ReplaceHumanoid = ReplaceHumanoid,
    GetCorrectToolWithHandle = GetCorrectToolWithHandle,
    DisableAnimate = DisableAnimate,
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
    clone = clone,
    firetouchinterest = firetouchinterest,
    fireproximityprompt = fireproximityprompt,
    decompile = decompile,
    getnilinstances = getnilinstances,
    getinstances = getinstances,
    Drawing = Drawing
}

do
    local IsDebug = IsSupportedExploit and PluginConf.PluginDebug

    Plugins = IsSupportedExploit and map(filter(listfiles("fates-admin/plugins"), function(i, v)
        return lower(split(v, ".")[#split(v, ".")]) == "lua"
    end), function(i, v)
        local splitted = split(v, "\\");
        if (identifyexecutor and identifyexecutor() == "ScriptWare") then
            return {splitted[#splitted], loadfile("fates-admin/plugins/" .. v)}
        else
            return {splitted[#splitted], loadfile(v)}
        end
    end) or {}

    if (SafePlugins) then
        local Renv = clone(getrenv(), true);
        for i, v in next, Renv do
            PluginLibrary[i] = v
        end
    end
    PluginLibrary.debug = nil
    PluginLibrary.getfenv = nil
    PluginLibrary.loadstring = loadstring

    if (PluginConf.SafePlugins) then
        local Funcs = {}
        for i, v in next, PluginLibrary do
            if (type(v) == 'function') then
                Funcs[#Funcs + 1] = v
            end
        end
        local FateEnv = getfenv(1);
        PluginLibrary.getfenv = newcclosure(function(...)
            local f = ({...})[1]
            local Env = getfenv(...);
            if (type(f) == 'function' and Tfind(Funcs, f) or Env == FateEnv and checkcaller()) then
                return PluginLibrary
            end
            return Env
        end)
    end

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
            local sett, gett = setthreadidentity, getthreadidentity
            if (sett and PluginConf.SafePlugins) then
                Context = gett();
                sett(5);
            end
            local Ran, Return = pcall(Plugin.Init);
            if (sett and Context) then
                sett(Context);
            end
            if (not Ran and Return and IsDebug) then
                return Utils.Notify(LocalPlayer, "Plugin Fail", format("there is an error in plugin Init %s: %s", Plugin.Name, Return));
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
                Utils.ToolTip(Clone, format("%s\n%s - %s", command.Name, command.Description, Plugin.Author));
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
                setfenv(PluginFunc, PluginLibrary);
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
                setfenv(PluginFunc, PluginLibrary);
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