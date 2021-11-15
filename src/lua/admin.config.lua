do
    local UserInputService = Services.UserInputService
    local GetStringForKeyCode = UserInputService.GetStringForKeyCode
    local function GetKeyName(KeyCode)
        local _, Stringed = pcall(GetStringForKeyCode, UserInputService, KeyCode);
        local IsEnum = Stringed == ""
        return (not IsEnum and _) and Stringed or split(tostring(KeyCode), ".")[3], (IsEnum and not _);
    end

    local SortKeys = function(Key1, Key2)
        local KeyName, IsEnum = GetKeyName(Key1);
        if (Key2) then
            local KeyName2, IsEnum2 = GetKeyName(Key2);
            return format("%s + %s", IsEnum2 and KeyName2 or KeyName, IsEnum2 and KeyName2 or KeyName2);
        end
        return KeyName
    end

    LoadConfig = function()
        local Script = ConfigUILib.NewPage("Script");
        local Settings = Script.NewSection("Settings");
    
        local CurrentConf = GetConfig();
        UndetectedCmdBar = CurrentConf.UndetectedCmdBar


        Settings.TextboxKeybind("Chat Prefix", Prefix, function(Key)
            if (not match(Key, "%A") or match(Key, "%d") or #Key > 1) then
                Utils.Notify(nil, "Prefix", "Prefix must be a 1 character symbol.");
                return
            end
            Prefix = Key
            Utils.Notify(nil, "Prefix", "Prefix is now " .. Key);
        end)
    
        Settings.Keybind("CMDBar Prefix", GetKeyName(CommandBarPrefix), function(KeyCode1, KeyCode2)
            CommandBarPrefix = KeyCode1
            Utils.Notify(nil, "Prefix", "CommandBar Prefix is now " .. GetKeyName(KeyCode1));
        end)
    
        local ToggleSave;
        ToggleSave = Settings.Toggle("Save Prefix's", false, function(Callback)
            SetConfig({["Prefix"]=Prefix,["CommandBarPrefix"]=split(tostring(CommandBarPrefix), ".")[3]});
            wait(.5);
            ToggleSave();
            Utils.Notify(nil, "Prefix", "saved prefix's");
        end)
    
        local Misc = Script.NewSection("Misc");

        Misc.Toggle("Chat Prediction", CurrentConf.ChatPrediction or false, function(Callback)
            local ChatBar = ToggleChatPrediction();
            if (Callback) then
                ChatBar.CaptureFocus(ChatBar);
                wait();
                ChatBar.Text = Prefix
            end
            SetConfig({ChatPrediction=Callback});
            Utils.Notify(nil, nil, format("ChatPrediction %s", Callback and "enabled" or "disabled"));
        end)

        Misc.Toggle("Undetected CommandBar", UndetectedCmdBar, function(Callback)
            SetConfig({UndetectedCmdBar=Callback});
        end)

        Misc.Toggle("Anti Kick", Hooks.AntiKick, function(Callback)
            Hooks.AntiKick = Callback
            Utils.Notify(nil, nil, format("AntiKick %s", Hooks.AntiKick and "enabled" or "disabled"));
        end)

        Misc.Toggle("Anti Teleport", Hooks.AntiTeleport, function(Callback)
            Hooks.AntiTeleport = Callback
            Utils.Notify(nil, nil, format("AntiTeleport %s", Hooks.AntiTeleport and "enabled" or "disabled"));
        end)

        Misc.Toggle("wide cmdbar", WideBar, function(Callback)
            WideBar = Callback
            if (not Draggable) then
                Utils.Tween(CommandBar, "Quint", "Out", .5, {
                    Position = UDim2.new(0.5, WideBar and -200 or -100, 1, 5) -- tween -110
                })
            end
            Utils.Tween(CommandBar, "Quint", "Out", .5, {
                Size = UDim2.new(0, WideBar and 400 or 200, 0, 35) -- tween -110
            })
            SetConfig({WideBar=Callback});
            Utils.Notify(nil, nil, format("widebar %s", WideBar and "enabled" or "disabled"));
        end)

        Misc.Toggle("draggable cmdbar", Draggable, function(Callback)
            Draggable = Callback
            CommandBarOpen = true
            Utils.Tween(CommandBar, "Quint", "Out", .5, {
                Position = UDim2.new(0, Mouse.X, 0, Mouse.Y + 36);
            })
            Utils.Draggable(CommandBar);
            local TransparencyTween = CommandBarOpen and Utils.TweenAllTransToObject or Utils.TweenAllTrans
            local Tween = TransparencyTween(CommandBar, .5, CommandBarTransparencyClone);
            CommandBar.Input.Text = ""
            if (not Callback) then
                Utils.Tween(CommandBar, "Quint", "Out", .5, {
                    Position = UDim2.new(0.5, WideBar and -200 or -100, 1, 5) -- tween 5
                })
            end
            Utils.Notify(nil, nil, format("draggable command bar %s", Draggable and "enabled" or "disabled"));
        end)

        Misc.Toggle("KillCam when killing", CurrentConf.KillCam, function(Callback)
            SetConfig({KillCam=Callback});
            _L.KillCam = Callback
        end)

        local OldFireTouchInterest = firetouchinterest
        Misc.Toggle("cframe touchinterest", firetouchinterest == nil, function(Callback)
            firetouchinterest = Callback and function(part1, part2, toggle)
                if (part1 and part2) then
                    if (toggle == 0) then
                        touched[1] = part1.CFrame
                        part1.CFrame = part2.CFrame
                    else
                        part1.CFrame = touched[1]
                        touched[1] = nil
                    end
                end
            end or OldFireTouchInterest
        end)

        local MacrosPage = ConfigUILib.NewPage("Macros");
        local MacroSection;
        MacroSection = MacrosPage.CreateMacroSection(Macros, function(Bind, Command, Args)
            local AlreadyAdded = false
            for i = 1, #Macros do
                if (Macros[i].Command == Command) then
                    AlreadyAdded = true
                end
            end
            if (CommandsTable[Command] and not AlreadyAdded) then
                MacroSection.AddMacro(Command .. " " .. Args, SortKeys(Bind[1], Bind[2]));
                Args = split(Args, " ");
                if (sub(Command, 1, 2) == "un" or CommandsTable["un" .. Command]) then
                    local Shifted = {Command, unpack(Args)}
                    Macros[#Macros + 1] = {
                        Command = "toggle",
                        Args = Shifted,
                        Keys = Bind
                    }
                else
                    Macros[#Macros + 1] = {
                        Command = Command,
                        Args = Args,
                        Keys = Bind
                    }
                end
                local TempMacros = clone(Macros);
                for i, v in next, TempMacros do
                    for i2, v2 in next, v.Keys do
                        TempMacros[i]["Keys"][i2] = split(tostring(v2), ".")[3]
                    end
                end
                SetConfig({Macros=TempMacros});
            end
        end)
        local UIListLayout = MacroSection.CommandsList.UIListLayout
        for i, v in next, CommandsTable do
            if (not FindFirstChild(MacroSection.CommandsList, v.Name)) then
                MacroSection.AddCmd(v.Name);
            end
        end
        MacroSection.CommandsList.CanvasSize = UDim2.fromOffset(0, UIListLayout.AbsoluteContentSize.Y);
        local Search = FindFirstChild(MacroSection.CommandsList.Parent.Parent, "Search");

        AddConnection(CConnect(GetPropertyChangedSignal(Search, "Text"), function()
            local Text = Search.Text
            for _, v in next, GetChildren(MacroSection.CommandsList) do
                if (IsA(v, "TextButton")) then
                    local Command = v.Text
                    v.Visible = Sfind(lower(Command), Text, 1, true)
                end
            end
            MacroSection.CommandsList.CanvasSize = UDim2.fromOffset(0, UIListLayout.AbsoluteContentSize.Y);
        end), Connections.UI, true);
        
        local PluginsPage = ConfigUILib.NewPage("Plugins");
        
        local CurrentPlugins = PluginsPage.NewSection("Current Plugins");
        local PluginSettings = PluginsPage.NewSection("Plugin Settings");
    
        local CurrentPluginConf = GetPluginConfig();
    
        CurrentPlugins.ScrollingFrame("plugins", function(Option, Enabled)
            CurrentPluginConf = GetPluginConfig();
            for i = 1, #Plugins do
                local Plugin = Plugins[i]
                if (Plugin[1] == Option) then
                    local DisabledPlugins = CurrentPluginConf.DisabledPlugins
                    local PluginName = Plugin[2]().Name
                    if (Enabled) then
                        DisabledPlugins[PluginName] = nil
                        SetPluginConfig({DisabledPlugins=DisabledPlugins});
                        Utils.Notify(nil, "Plugin Enabled", format("plugin %s successfully enabled", PluginName));
                    else
                        DisabledPlugins[PluginName] = true
                        SetPluginConfig({DisabledPlugins=DisabledPlugins});
                        Utils.Notify(nil, "Plugin Disabled", format("plugin %s successfully disabled", PluginName));
                    end
                end
            end
        end, map(Plugins, function(Key, Plugin)
            return not PluginConf.DisabledPlugins[Plugin[2]().Name], Plugin[1]
        end));
    
        PluginSettings.Toggle("Plugins Enabled", CurrentPluginConf.PluginsEnabled, function(Callback)
            SetPluginConfig({PluginsEnabled = Callback});
        end)

        PluginSettings.Toggle("Plugins Debug", CurrentPluginConf.PluginDebug, function(Callback)
            SetPluginConfig({PluginDebug = Callback});
        end)

        PluginSettings.Toggle("Safe Plugins", CurrentPluginConf.SafePlugins, function(Callback)
            SetPluginConfig({SafePlugins = Callback});
        end)

        local Themes = ConfigUILib.NewPage("Themes");

        local Color = Themes.NewSection("Colors");
        local Options = Themes.NewSection("Options");

        local RainbowEnabled = false
        Color.ColorPicker("All Background", UITheme.Background.BackgroundColor, function(Callback, IsRainbow)
            UITheme.Background.BackgroundColor = Callback
            RainbowEnabled = IsRainbow
        end)
        Color.ColorPicker("CommandBar", UITheme.CommandBar.BackgroundColor, function(Callback)
            if (not RainbowEnabled) then
                UITheme.CommandBar.BackgroundColor = Callback
            end
        end)
        Color.ColorPicker("Notification", UITheme.Notification.BackgroundColor, function(Callback)
            if (not RainbowEnabled) then
                UITheme.Notification.BackgroundColor = Callback
            end
        end)
        Color.ColorPicker("ChatLogs", UITheme.ChatLogs.BackgroundColor, function(Callback)
            if (not RainbowEnabled) then
                UITheme.ChatLogs.BackgroundColor = Callback
            end
        end)
        Color.ColorPicker("CommandList", UITheme.CommandList.BackgroundColor, function(Callback)
            if (not RainbowEnabled) then
                UITheme.CommandList.BackgroundColor = Callback
            end
        end)
        Color.ColorPicker("Config", UITheme.Config.BackgroundColor, function(Callback)
            if (not RainbowEnabled) then
                UITheme.Config.BackgroundColor = Callback
            end
        end)

        Color.ColorPicker("All Text", UITheme.Background.TextColor, function(Callback)
            UITheme.Background.TextColor = Callback
        end)

        local ToggleSave;
        ToggleSave = Options.Toggle("Save Theme", false, function(Callback)
            WriteThemeConfig();
            wait(.5);
            ToggleSave();
            Utils.Notify(nil, "Theme", "saved theme");
        end)

        local ToggleLoad;
        ToggleLoad = Options.Toggle("Load Theme", false, function(Callback)
            LoadTheme(GetThemeConfig());
            wait(.5);
            ToggleLoad();
            Utils.Notify(nil, "Theme", "Loaded theme");
        end)

        local ToggleReset;
        ToggleReset = Options.Toggle("Reset Theme", false, function(Callback)
            UITheme.Background.BackgroundColor = "Reset"
            UITheme.Notification.TextColor = "Reset"
            UITheme.CommandBar.TextColor = "Reset"
            UITheme.CommandList.TextColor = "Reset"
            UITheme.ChatLogs.TextColor = "Reset"
            UITheme.Config.TextColor = "Reset"
            UITheme.Notification.Transparency = "Reset"
            UITheme.CommandBar.Transparency = "Reset"
            UITheme.CommandList.Transparency = "Reset"
            UITheme.ChatLogs.Transparency = "Reset"
            UITheme.Config.Transparency = "Reset"
            wait(.5);
            ToggleReset();
            Utils.Notify(nil, "Theme", "reset theme");
        end)

    end

    delay(1, function()
        for i = 1, #Macros do
            local Macro = Macros[i]
            for i2 = 1, #Macro.Keys do
                Macros[i].Keys[i2] = Enum.KeyCode[Macros[i].Keys[i2]]
            end
        end
        if (CurrentConfig.WideBar) then
            WideBar = true
            Utils.Tween(CommandBar, "Quint", "Out", .5, {
                Size = UDim2.new(0, WideBar and 400 or 200, 0, 35) -- tween -110
            })
        end
        KillCam = CurrentConfig.KillCam
        local Aliases = CurrentConfig.Aliases
        if (Aliases) then
            for i, v in next, Aliases do
                if (CommandsTable[i]) then
                    for i2 = 1, #v do
                        local Alias = v[i2]
                        local Add = CommandsTable[i]
                        Add.Name = Alias
                        CommandsTable[Alias] = Add
                    end
                end
            end
        end
    end)
end