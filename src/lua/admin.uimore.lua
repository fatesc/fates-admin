Notification.Visible = false
Stats.Visible = false
Utils.SetAllTrans(CommandBar)
Utils.SetAllTrans(ChatLogs)
Utils.SetAllTrans(GlobalChatLogs)
Utils.SetAllTrans(HttpLogs);
Commands.Visible = false
ChatLogs.Visible = false
GlobalChatLogs.Visible = false
HttpLogs.Visible = false

Utils.Draggable(Commands);
Utils.Draggable(ChatLogs);
Utils.Draggable(GlobalChatLogs);
Utils.Draggable(HttpLogs);
Utils.Draggable(ConfigUI);

ParentGui(UI);
Connections.UI = {}

local Times = #LastCommand
AddConnection(CConnect(Services.UserInputService.InputBegan, function(Input, GameProccesed)
    if (Input.KeyCode == CommandBarPrefix and (not GameProccesed)) then
        CommandBarOpen = not CommandBarOpen

        local TransparencyTween = CommandBarOpen and Utils.TweenAllTransToObject or Utils.TweenAllTrans
        local Tween = TransparencyTween(CommandBar, .5, CommandBarTransparencyClone);
        local UserInputService = Services.UserInputService

        if (CommandBarOpen) then
            if (not Draggable) then
                Utils.Tween(CommandBar, "Quint", "Out", .5, {
                    Position = UDim2.new(0.5, WideBar and -200 or -100, 1, -110)
                })
            end

            local TextConnections;
            if (UndetectedCmdBar) then
                TextConnections = getconnections(UserInputService.TextBoxFocused);
                for i, v in next, TextConnections do
                    v.Disable(v);
                end
                for i, v in next, getconnections(UserInputService.TextBoxFocusReleased) do
                    v.Disable(v);
                end
            end

            CommandBar.Input.CaptureFocus(CommandBar.Input);
            CThread(function()
                wait()
                CommandBar.Input.Text = ""
                local FocusedTextBox = UserInputService.GetFocusedTextBox(UserInputService);
                local TextBox = CommandBar.Input
                while (FocusedTextBox ~= TextBox) do
                    FocusedTextBox.ReleaseFocus(FocusedTextBox);
                    CommandBar.Input.CaptureFocus(TextBox);
                    FocusedTextBox = UserInputService.GetFocusedTextBox(UserInputService);
                    CWait(Heartbeat);
                end
            end)()
            
            if (UndetectedCmdBar) then
                for i, v in next, TextConnections do
                    v.Enable(v);
                end
            end
        else
            if (not Draggable) then
                Utils.Tween(CommandBar, "Quint", "Out", .5, {
                    Position = UDim2.new(0.5, WideBar and -200 or -100, 1, 5)
                })
            end
        end
    elseif (not GameProccesed and ChooseNewPrefix) then
        CommandBarPrefix = Input.KeyCode
        Utils.Notify(LocalPlayer, "New Prefix", "Your new prefix is: " .. split(tostring(Input.KeyCode), ".")[3]);
        ChooseNewPrefix = false
        if (writefile) then
            Utils.Notify(LocalPlayer, nil, "use command saveprefix to save your prefix");
        end
    elseif (GameProccesed and CommandBarOpen) then
        if (Input.KeyCode == Enum.KeyCode.Up) then
            Times = Times >= 3 and Times or Times + 1
            CommandBar.Input.Text = LastCommand[Times][1] .. " "
            CommandBar.Input.CursorPosition = #CommandBar.Input.Text + 2
        end
        if (Input.KeyCode == Enum.KeyCode.Down) then
            Times = Times <= 1 and 1 or Times - 1
            CommandBar.Input.Text = LastCommand[Times][1] .. " "
            CommandBar.Input.CursorPosition = #CommandBar.Input.Text + 2
        end
    end
end), Connections.UI, true);

Utils.Click(Commands.Close, "TextColor3")
Utils.Click(ChatLogs.Clear, "BackgroundColor3")
Utils.Click(ChatLogs.Save, "BackgroundColor3")
Utils.Click(ChatLogs.Toggle, "BackgroundColor3")
Utils.Click(ChatLogs.Close, "TextColor3")

Utils.Click(GlobalChatLogs.Clear, "BackgroundColor3")
Utils.Click(GlobalChatLogs.Save, "BackgroundColor3")
Utils.Click(GlobalChatLogs.Toggle, "BackgroundColor3")
Utils.Click(GlobalChatLogs.Close, "TextColor3")

Utils.Click(HttpLogs.Clear, "BackgroundColor3")
Utils.Click(HttpLogs.Save, "BackgroundColor3")
Utils.Click(HttpLogs.Toggle, "BackgroundColor3")
Utils.Click(HttpLogs.Close, "TextColor3")

AddConnection(CConnect(Commands.Close.MouseButton1Click, function()
    local Tween = Utils.TweenAllTrans(Commands, .25)

    CWait(Tween.Completed);
    Commands.Visible = false
end), Connections.UI, true);

AddConnection(CConnect(GetPropertyChangedSignal(Commands.Search, "Text"), function()
    local Text = Commands.Search.Text
    local Children = GetChildren(Commands.Frame.List);
    for i = 1, #Children do
        local v = Children[i]
        if (IsA(v, "Frame")) then
            local Command = v.CommandText.Text
            v.Visible = Sfind(lower(Command), Text, 1, true)
        end
    end
    Commands.Frame.List.CanvasSize = UDim2.fromOffset(0, Commands.Frame.List.UIListLayout.AbsoluteContentSize.Y)
end), Connections.UI, true);

AddConnection(CConnect(ChatLogs.Close.MouseButton1Click, function()
    local Tween = Utils.TweenAllTrans(ChatLogs, .25)

    CWait(Tween.Completed);
    ChatLogs.Visible = false
end), Connections.UI, true);
AddConnection(CConnect(GlobalChatLogs.Close.MouseButton1Click, function()
    local Tween = Utils.TweenAllTrans(GlobalChatLogs, .25)

    CWait(Tween.Completed);
    GlobalChatLogs.Visible = false
end), Connections.UI, true);
AddConnection(CConnect(HttpLogs.Close.MouseButton1Click, function()
    local Tween = Utils.TweenAllTrans(HttpLogs, .25)

    CWait(Tween.Completed);
    HttpLogs.Visible = false
end), Connections.UI, true);

ChatLogs.Toggle.Text = _L.ChatLogsEnabled and "Enabled" or "Disabled"
GlobalChatLogs.Toggle.Text = _L.ChatLogsEnabled and "Enabled" or "Disabled"
HttpLogs.Toggle.Text = _L.HttpLogsEnabled and "Enabled" or "Disabled"

AddConnection(CConnect(ChatLogs.Toggle.MouseButton1Click, function()
    _L.ChatLogsEnabled = not _L.ChatLogsEnabled
    ChatLogs.Toggle.Text = _L.ChatLogsEnabled and "Enabled" or "Disabled"
end), Connections.UI, true);
AddConnection(CConnect(GlobalChatLogs.Toggle.MouseButton1Click, function()
    _L.GlobalChatLogsEnabled = not _L.GlobalChatLogsEnabled
    GlobalChatLogs.Toggle.Text = _L.GlobalChatLogsEnabled and "Enabled" or "Disabled"
end), Connections.UI, true);
AddConnection(CConnect(HttpLogs.Toggle.MouseButton1Click, function()
    _L.HttpLogsEnabled = not _L.HttpLogsEnabled
    HttpLogs.Toggle.Text = _L.HttpLogsEnabled and "Enabled" or "Disabled"
end), Connections.UI, true);

AddConnection(CConnect(ChatLogs.Clear.MouseButton1Click, function()
    Utils.ClearAllObjects(ChatLogs.Frame.List)
    ChatLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, 0)
end), Connections.UI, true);
AddConnection(CConnect(GlobalChatLogs.Clear.MouseButton1Click, function()
    Utils.ClearAllObjects(GlobalChatLogs.Frame.List)
    GlobalChatLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, 0)
end), Connections.UI, true);
AddConnection(CConnect(HttpLogs.Clear.MouseButton1Click, function()
    Utils.ClearAllObjects(HttpLogs.Frame.List)
    HttpLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, 0)
end), Connections.UI, true);

AddConnection(CConnect(GetPropertyChangedSignal(ChatLogs.Search, "Text"), function()
    local Text = ChatLogs.Search.Text
    local Children = GetChildren(ChatLogs.Frame.List);
    for i = 1, #Children do
        local v = Children[i]
        if (not IsA(v, "UIListLayout")) then
            local Message = split(v.Text, ": ")[2]
            v.Visible = Sfind(lower(Message), Text, 1, true)
        end
    end

    ChatLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, ChatLogs.Frame.List.UIListLayout.AbsoluteContentSize.Y)
end), Connections.UI, true);

AddConnection(CConnect(GetPropertyChangedSignal(GlobalChatLogs.Search, "Text"), function()
    local Text = GlobalChatLogs.Search.Text

    local Children = GetChildren(GlobalChatLogs.Frame.List);
    for i = 1, #Children do
        local v = Children[i]
        if (not IsA(v, "UIListLayout")) then
            local Message = v.Text

            v.Visible = Sfind(lower(Message), Text, 1, true)
        end
    end
end), Connections.UI, true);

AddConnection(CConnect(GetPropertyChangedSignal(HttpLogs.Search, "Text"), function()
    local Text = HttpLogs.Search.Text

    local Children = GetChildren(HttpLogs.Frame.List);
    for i = 1, #Children do
        local v = Children[i]
        if (not IsA(v, "UIListLayout")) then
            local Message = v.Text
            v.Visible = Sfind(lower(Message), Text, 1, true)
        end
    end
end), Connections.UI, true);

AddConnection(CConnect(ChatLogs.Save.MouseButton1Click, function()
    local GameName = Services.MarketplaceService.GetProductInfo(Services.MarketplaceService, game.PlaceId).Name
    local String =  format("Fates Admin Chatlogs for %s (%s)\n\n", GameName, os.date());
    local TimeSaved = gsub(tostring(os.date("%x")), "/", "-") .. " " .. gsub(tostring(os.date("%X")), ":", "-");
    local Name = format("fates-admin/chatlogs/%s (%s).txt", GameName, TimeSaved);
    local Children = GetChildren(ChatLogs.Frame.List);
    for i = 1, #Children do
        local v = Children[i]
        if (not IsA(v, "UIListLayout")) then
            String = format("%s%s\n", String, v.Text);
        end
    end
    writefile(Name, String);
    Utils.Notify(LocalPlayer, "Saved", "Chat logs saved!");
end), Connections.UI, true);

AddConnection(CConnect(HttpLogs.Save.MouseButton1Click, function()
    local Children = GetChildren(HttpLogs.Frame.List);
    local Logs =  format("Fates Admin HttpLogs for %s\n\n", os.date());
    for i = 1, #Children do
        local v = Children[i]
        if (not IsA(v, "UIListLayout")) then
            Logs = format("%s%s\n", Logs, v.Text);
        end
    end
    if (not isfolder("fates-admin/httplogs")) then
        makefolder("fates-admin/httplogs");
    end
    writefile(format("fates-admin/httplogs/HttpLogs for %s", gsub(tostring(os.date("%X")), ":", "-")) .. ".txt", gsub(Logs, "%b<>", ""));
    Utils.Notify(LocalPlayer, "Saved", "Http logs saved!");
end), Connections.UI, true);

-- auto correct
AddConnection(CConnect(GetPropertyChangedSignal(CommandBar.Input, "Text"), function() -- make it so that every space a players name will appear
    CommandBar.Input.Text = CommandBar.Input.Text
    local Text = CommandBar.Input.Text
    local Prediction = CommandBar.Input.Predict
    local PredictionText = Prediction.Text

    local Args = split(Text, " ")

    Prediction.Text = ""
    if (Text == "") then
        return
    end

    local FoundCommand = false
    local FoundAlias = false
    CommandArgs = CommandArgs or {}
    if (not CommandsTable[Args[1]]) then
        for _, v in next, CommandsTable do
            local CommandName = v.Name
            local Aliases = v.Aliases
            local FoundAlias
    
            if (Utils.MatchSearch(Args[1], CommandName)) then -- better search
                Prediction.Text = CommandName
                CommandArgs = v.Args or {}
                break
            end
    
            for _, v2 in next, Aliases do
                if (Utils.MatchSearch(Args[1], v2)) then
                    FoundAlias = true
                    Prediction.Text = v2
                    CommandArgs = v2.Args or {}
                    break
                end
    
                if (FoundAlias) then
                    break
                end
            end
        end
    end

    for i, v in next, Args do -- make it get more players after i space out
        if (i > 1 and v ~= "") then
            local Predict = ""
            if (#CommandArgs >= 1) then
                for i2, v2 in next, CommandArgs do
                    if (lower(v2) == "player") then
                        Predict = Utils.GetPlayerArgs(v) or Predict;
                    else
                        Predict = Utils.MatchSearch(v, v2) and v2 or Predict
                    end
                end
            else
                Predict = Utils.GetPlayerArgs(v) or Predict;
            end
            Prediction.Text = sub(Text, 1, #Text - #Args[#Args]) .. Predict
            local split = split(v, ",");
            if (next(split)) then
                for i2, v2 in next, split do
                    if (i2 > 1 and v2 ~= "") then
                        local PlayerName = Utils.GetPlayerArgs(v2)
                        Prediction.Text = sub(Text, 1, #Text - #split[#split]) .. (PlayerName or "")
                    end
                end
            end
        end
    end

    if (Sfind(Text, "\t")) then -- remove tab from preditction text also
        CommandBar.Input.Text = PredictionText
        CommandBar.Input.CursorPosition = #CommandBar.Input.Text + 1
    end
end))


do
    local Enabled = false
    local Connection;
    local Predict;
    ToggleChatPrediction = function()
        if (_L.Frame2) then
            return
        end
        if (not Enabled) then
            local RobloxChat = LocalPlayer.PlayerGui and FindFirstChild(LocalPlayer.PlayerGui, "Chat");
            local RobloxChatBarFrame;
            if (RobloxChat) then
                local RobloxChatFrame = FindFirstChild(RobloxChat, "Frame");
                if (RobloxChatFrame) then
                    RobloxChatBarFrame = FindFirstChild(RobloxChatFrame, "ChatBarParentFrame");
                end
            end
            local PredictionClone, ChatBar
            if (RobloxChatBarFrame) then
                local Frame1 = FindFirstChild(RobloxChatBarFrame, 'Frame');
                if Frame1 then
                    local BoxFrame = FindFirstChild(Frame1, 'BoxFrame');
                    if BoxFrame then
                        _L.Frame2 = FindFirstChild(BoxFrame, 'Frame');
                        if _L.Frame2 then
                            local TextLabel = FindFirstChild(_L.Frame2, 'TextLabel');
                            ChatBar = FindFirstChild(_L.Frame2, 'ChatBar');
                            if TextLabel and ChatBar then
                                PredictionClone = InstanceNew('TextLabel');
                                PredictionClone.Font = TextLabel.Font
                                PredictionClone.LineHeight = TextLabel.LineHeight
                                PredictionClone.MaxVisibleGraphemes = TextLabel.MaxVisibleGraphemes
                                PredictionClone.RichText = TextLabel.RichText
                                PredictionClone.Text = ''
                                PredictionClone.TextColor3 = TextLabel.TextColor3
                                PredictionClone.TextScaled = TextLabel.TextScaled
                                PredictionClone.TextSize = TextLabel.TextSize
                                PredictionClone.TextStrokeColor3 = TextLabel.TextStrokeColor3
                                PredictionClone.TextStrokeTransparency = TextLabel.TextStrokeTransparency
                                PredictionClone.TextTransparency = 0.3
                                PredictionClone.TextTruncate = TextLabel.TextTruncate
                                PredictionClone.TextWrapped = TextLabel.TextWrapped
                                PredictionClone.TextXAlignment = TextLabel.TextXAlignment
                                PredictionClone.TextYAlignment = TextLabel.TextYAlignment
                                PredictionClone.Name = "Predict"
                                PredictionClone.Size = UDim2.new(1, 0, 1, 0);
                                PredictionClone.BackgroundTransparency = 1
                            end
                        end
                    end
                end
            end

            ParentGui(PredictionClone, _L.Frame2);
            Predict = PredictionClone

            Connection = AddConnection(CConnect(GetPropertyChangedSignal(ChatBar, "Text"), function() -- todo: add detection for /e
                local Text = ChatBar.Text
                local Prediction = PredictionClone
                local PredictionText = PredictionClone.Text
            
                local Args = split(concat(shift(split(Text, ""))), " ");
            
                Prediction.Text = ""
                if (not startsWith(Text, Prefix)) then
                    return
                end
            
                local FoundCommand = false
                local FoundAlias = false
                CommandArgs = CommandArgs or {}
                if (not rawget(CommandsTable, Args[1])) then
                    for _, v in next, CommandsTable do
                        local CommandName = v.Name
                        local Aliases = v.Aliases
                        local FoundAlias
                
                        if (Utils.MatchSearch(Args[1], CommandName)) then -- better search
                            Prediction.Text = Prefix .. CommandName
                            FoundCommand = true
                            CommandArgs = v.Args or {}
                            break
                        end
                
                        for _, v2 in next, Aliases do
                            if (Utils.MatchSearch(Args[1], v2)) then
                                FoundAlias = true
                                Prediction.Text = v2
                                CommandArgs = v.Args or {}
                                break
                            end
                
                            if (FoundAlias) then
                                break
                            end
                        end
                    end
                end
            
                for i, v in next, Args do -- make it get more players after i space out
                    if (i > 1 and v ~= "") then
                        local Predict = ""
                        if (#CommandArgs >= 1) then
                            for i2, v2 in next, CommandArgs do
                                if (lower(v2) == "player") then
                                    Predict = Utils.GetPlayerArgs(v) or Predict;
                                else
                                    Predict = Utils.MatchSearch(v, v2) and v2 or Predict
                                end
                            end
                        else
                            Predict = Utils.GetPlayerArgs(v) or Predict;
                        end
                        Prediction.Text = sub(Text, 1, #Text - #Args[#Args]) .. Predict
                        local split = split(v, ",");
                        if (next(split)) then
                            for i2, v2 in next, split do
                                if (i2 > 1 and v2 ~= "") then
                                    local PlayerName = Utils.GetPlayerArgs(v2)
                                    Prediction.Text = sub(Text, 1, #Text - #split[#split]) .. (PlayerName or "")
                                end
                            end
                        end
                    end
                end
            
                if (Sfind(Text, "\t")) then -- remove tab from preditction text also
                    ChatBar.Text = PredictionText
                    ChatBar.CursorPosition = #ChatBar.Text + 2
                end
            end))
            Enabled = true
            return ChatBar
        else
            Disconnect(Connection);
            Destroy(Predict);
            Enabled = false
        end
        return _L.Frame2
    end

    if (CurrentConfig.ChatPrediction) then
        delay(2, ToggleChatPrediction);
    end
end

local ConfigUILib = {}
do
    local GuiObjects = ConfigElements
    local PageCount = 0
    local SelectedPage
    local UserInputService = Services.UserInputService

    local Colors = {
        ToggleEnabled = Color3.fromRGB(5, 5, 6);
        Background = Color3.fromRGB(32, 33, 36);
        ToggleDisabled = Color3.fromRGB(27, 28, 31);
    }

    local ColorElements = ConfigElements.Elements.ColorElements
    local Overlay = ColorElements.Overlay
    local OverlayMain = Overlay.Main
    local ColorPicker = OverlayMain.ColorPicker
    local Settings = OverlayMain.Settings
    local ClosePicker = OverlayMain.Close
    local ColorCanvas = ColorPicker.ColorCanvas
    local ColorSlider = ColorPicker.ColorSlider
    local ColorGradient = ColorCanvas.ColorGradient
    local DarkGradient = ColorGradient.DarkGradient
    local CanvasBar = ColorGradient.Bar
    local RainbowGradient = ColorSlider.RainbowGradient
    local SliderBar = RainbowGradient.Bar
    local CanvasHitbox = ColorCanvas.Hitbox
    local SliderHitbox = ColorSlider.Hitbox
    local ColorPreview = Settings.ColorPreview
    local ColorOptions = Settings.Options
    local RedTextBox = ColorOptions.Red.TextBox
    local BlueTextBox = ColorOptions.Blue.TextBox
    local GreenTextBox = ColorOptions.Green.TextBox
    local RainbowToggle = ColorOptions.Rainbow

    local function UpdateClone()
        ConfigUIClone = Clone(ConfigUI);
    end

    function ConfigUILib.NewPage(Title)
        local Page = Clone(GuiObjects.Page.Container);
        local TextButton = Clone(GuiObjects.Page.TextButton);

        Page.Visible = true
        TextButton.Visible = true

        Utils.Click(TextButton, "BackgroundColor3")
            
        if PageCount == 0 then
            SelectedPage = Page
        end

        AddConnection(CConnect(TextButton.MouseButton1Click, function()
            if SelectedPage.Name ~= TextButton.Name then          
                SelectedPage = Page
                ConfigUI.Container.UIPageLayout:JumpTo(SelectedPage)
            end
        end))
        
        Page.Name = Title
        TextButton.Name = Title
        TextButton.Text = Title
        
        Page.Parent = ConfigUI.Container
        TextButton.Parent = ConfigUI.Selection
        
        PageCount = PageCount + 1


        UpdateClone()

        local function GetKeyName(KeyCode)
            local _, Stringed = pcall(UserInputService.GetStringForKeyCode, UserInputService, KeyCode);
            local IsEnum = Stringed == ""
            return (not IsEnum and _) and Stringed or split(tostring(KeyCode), ".")[3], (IsEnum and not _);
        end

        local PageLibrary = {}

        function PageLibrary.CreateMacroSection(MacrosToAdd, Callback)
            local Macro = Clone(GuiObjects.Elements.Macro);
            local MacroPage = Macro.MacroPage
            local Selection = Page.Selection
            
            Selection.ClearAllChildren(Selection);
            for i,v in next, GetChildren(MacroPage) do
                v.Parent = Selection
            end
            Selection.Container.Visible = true
            local CommandsList = Selection.Container.Commands.Frame.List
            local CurrentMacros = Selection.Container.CurrentMacros
            local AddMacro = Selection.AddMacro
            local BindA, CommandA, ArgsA = AddMacro.Bind, AddMacro.Command, AddMacro["z Args"]
            local Add = AddMacro.AddMacro
            local Keybind = {};
            local Enabled = false
            local Connection
            
            local OnClick = function()
                Enabled = not Enabled
                if Enabled then
                    BindA.Text = "..."
                    local OldShiftLock = LocalPlayer.DevEnableMouseLock
                    LocalPlayer.DevEnableMouseLock = false
                    Keybind = {}
                    Connection = AddConnection(CConnect(UserInputService.InputBegan, function(Input, Processed)
                        if not Processed and Input.UserInputType == Enum.UserInputType.Keyboard then
                            local Input2, Proccessed2;
                            CThread(function()
                                Input2, Proccessed2 = CWait(UserInputService.InputBegan);
                            end)()
                            CWait(UserInputService.InputEnded);
                            if (Input2 and not Processed) then
                                local KeyName, IsEnum = GetKeyName(Input.KeyCode);
                                local KeyName2, IsEnum2 = GetKeyName(Input2.KeyCode); 
                                BindA.Text = format("%s + %s", IsEnum2 and KeyName2 or KeyName, IsEnum2 and KeyName2 or KeyName2);
                                Keybind[1] = Input.KeyCode
                                Keybind[2] = Input2.KeyCode
                            else
                                local KeyName = GetKeyName(Input.KeyCode);
                                BindA.Text = KeyName
                                Keybind[1] = Input.KeyCode
                                Keybind[2] = nil
                            end
                            LocalPlayer.DevEnableMouseLock = OldShiftLock
                        else
                            BindA.Text = "Bind"
                        end
                        Enabled = false
                        Disconnect(Connection);
                    end));
                else
                    BindA.Text = "Bind"
                    Disconnect(Connection);
                end
            end

            AddConnection(CConnect(BindA.MouseButton1Click, OnClick));
            AddConnection(CConnect(Add.MouseButton1Click, function()
                if (BindA.Text == "Bind") then
                    Utils.Notify(nil, nil, "You must assign a keybind");
                    return
                end
                if (not CommandsTable[CommandA.Text]) then
                    Utils.Notify(nil, nil, "You must add a command");
                    return
                end
                Callback(Keybind, CommandA.Text, ArgsA.Text);
            end));

            local Focused = false
            local MacroSection = {
                CommandsList = CommandsList,
                AddCmd = function(Name) 
                    local Command = Clone(Macro.Command);
                    Command.Name = Name
                    Command.Text = Name
                    Command.Parent = CommandsList
                    Command.Visible = true
                    AddConnection(CConnect(Command.MouseButton1Click, function()
                        CommandA.Text = Name
                        ArgsA.CaptureFocus(ArgsA);
                        Focused = true
                        CWait(ArgsA.FocusLost);
                        CWait(UserInputService.InputBegan);
                        Focused = false
                        wait(.2);
                        if (not Focused) then
                            OnClick();
                        end
                    end))
                end,
                AddMacro = function(MacroName, Bind)
                    local NewMacro = Clone(Macro.EditMacro);
                    NewMacro.Bind.Text = Bind
                    NewMacro.Macro.Text = MacroName
                    NewMacro.Parent = CurrentMacros
                    NewMacro.Visible = true

                    Utils.Thing(NewMacro.Bind);
                    Utils.Thing(NewMacro.Macro);

                    FindFirstChild(NewMacro, "Remove").Name = "Delete"
                    AddConnection(CConnect(NewMacro.Delete.MouseButton1Click, function()
                        CWait(Utils.TweenAllTrans(NewMacro, .25).Completed);
                        Destroy(NewMacro);
                        for i = 1, #Macros do
                            if (Macros[i].Command == split(MacroName, " ")[1]) then
                                Macros[i] = nil
                            end
                        end
                        local TempMacros = clone(Macros);
                        for i, v in next, TempMacros do
                            for i2, v2 in next, v.Keys do
                                TempMacros[i]["Keys"][i2] = split(tostring(v2), ".")[3]
                            end
                        end
                        SetConfig({Macros=TempMacros});
                    end))
                end
            }

            for i, v in next, MacrosToAdd do
                local Suc, Err = pcall(concat, v.Args, " ");
                if (not Suc) then
                    SetConfig({Macros={}});
                    Utils.Notify(LocalPlayer, "Error", "Macros were reset due to corrupted data")
                    break;
                end
                local KeyName, IsEnum = GetKeyName(v.Keys[1]);
                local Formatted;
                if (v.Keys[2]) then
                    local KeyName2, IsEnum2 = GetKeyName(v.Keys[2]); 
                    Formatted = format("%s + %s", IsEnum2 and KeyName2 or KeyName, IsEnum2 and KeyName2 or KeyName2);
                else
                    Formatted = KeyName
                end
                MacroSection.AddMacro(v.Command .. " " .. concat(v.Args, " "), Formatted);
            end

            return MacroSection
        end

        function PageLibrary.NewSection(Title)
            local Section = Clone(GuiObjects.Section.Container);
            local SectionOptions = Section.Options
            local SectionUIListLayout = SectionOptions.UIListLayout

            Section.Visible = true

            Utils.SmoothScroll(Section.Options, .14)
            Section.Title.Text = Title
            Section.Parent = Page.Selection
            
            
            SectionOptions.CanvasSize = UDim2.fromOffset(0,0) --// change
            AddConnection(CConnect(GetPropertyChangedSignal(SectionUIListLayout, "AbsoluteContentSize"), function()
                SectionOptions.CanvasSize = UDim2.fromOffset(0, SectionUIListLayout.AbsoluteContentSize.Y + 5);
            end));
            
            UpdateClone();

            local ElementLibrary = {}


            function ElementLibrary.Toggle(Title, Enabled, Callback)
                local Toggle = Clone(GuiObjects.Elements.Toggle);
                local Container = Toggle.Container

                local Switch = Container.Switch
                local Hitbox = Container.Hitbox
                
                if not Enabled then
                    Switch.Position = UDim2.fromOffset(2, 2)
                    Container.BackgroundColor3 = Colors.ToggleDisabled
                end
                local NoCallback = false

                local OnClick = function()
                    Enabled = not Enabled
                    
                    Utils.Tween(Switch, "Quad", "Out", .25, {
                        Position = Enabled and UDim2.new(1, -18, 0, 2) or UDim2.fromOffset(2, 2)
                    })
                    Utils.Tween(Container, "Quad", "Out", .25, {
                        BackgroundColor3 = Enabled and Colors.ToggleEnabled or Colors.ToggleDisabled
                    })
                    
                    if (not NoCallback) then
                        Callback(Enabled);
                    end
                end

                AddConnection(CConnect(Hitbox.MouseButton1Click, OnClick));
                
                Toggle.Visible = true
                Toggle.Title.Text = Title
                Toggle.Parent = Section.Options
                Utils.Thing(Toggle.Title);

                UpdateClone()

                return function()
                    NoCallback = true
                    OnClick();
                    NoCallback = false
                end
            end

            function ElementLibrary.ScrollingFrame(Title, Callback, Elements, Toggles)
                local ScrollingFrame = Clone(GuiObjects.Elements.ScrollingFrame);
                local Frame = ScrollingFrame.Frame
                local Toggle = ScrollingFrame.Toggle

                for ElementTitle, Enabled in next, Elements do
                    local NewToggle = Clone(Toggle);
                    NewToggle.Visible = true
                    NewToggle.Title.Text = ElementTitle
                    NewToggle.Plugins.Text = Enabled and (Toggles and Toggles[1] or "Enabled") or (Toggles and Toggles[2] or "Disabled");


                    Utils.Click(NewToggle.Plugins, "BackgroundColor3")

                    AddConnection(CConnect(NewToggle.Plugins.MouseButton1Click, function()
                        Enabled = not Enabled
                        NewToggle.Plugins.Text = Enabled and (Toggles and Toggles[1] or "Enabled") or (Toggles and Toggles[2] or "Disabled");

                        Callback(ElementTitle, Enabled);
                    end));

                    NewToggle.Parent = Frame.Container
                end

                Frame.Visible = true
                Frame.Title.Text = Title
                Frame.Parent = Section.Options

                for _, NewToggle in next, GetChildren(Frame.Container) do
                    if (IsA(NewToggle, "GuiObject")) then
                        Utils.Thing(NewToggle.Title);
                    end
                end

                UpdateClone()
            end

            function ElementLibrary.Keybind(Title, Bind, Callback)
                local Keybind = Clone(GuiObjects.Elements.Keybind);
                local Enabled = false
                local Connection

                Keybind.Container.Text = Bind
                Keybind.Title.Text = Title

                local Container = Keybind.Container
                AddConnection(CConnect(Container.MouseButton1Click, function()
                    Enabled = not Enabled

                    if Enabled then
                        Container.Text = "..."
                        local OldShiftLock = LocalPlayer.DevEnableMouseLock
                        -- disable shift lock so it doesn't interfere with keybind
                        LocalPlayer.DevEnableMouseLock = false
                        Connection = AddConnection(CConnect(UserInputService.InputBegan, function(Input, Processed)
                            if not Processed and Input.UserInputType == Enum.UserInputType.Keyboard then
                                local Input2, Proccessed2;
                                CThread(function()
                                    Input2, Proccessed2 = CWait(UserInputService.InputBegan);
                                end)()
                                CWait(UserInputService.InputEnded);
                                if (Input2 and not Processed) then
                                    local KeyName, IsEnum = GetKeyName(Input.KeyCode);
                                    local KeyName2, IsEnum2 = GetKeyName(Input2.KeyCode); 
                                    -- Order by if it's an enum first, example 'Shift + K' and not 'K + Shift'
                                    Container.Text = format("%s + %s", IsEnum2 and KeyName2 or KeyName, IsEnum2 and KeyName2 or KeyName2);
                                    Callback(Input.KeyCode, Input2.KeyCode);
                                else
                                    local KeyName = GetKeyName(Input.KeyCode);
                                    Container.Text = KeyName
                                    Callback(Input.KeyCode);
                                end
                                LocalPlayer.DevEnableMouseLock = OldShiftLock
                            else
                                Container.Text = "press"
                            end
                            Enabled = false
                            Disconnect(Connection);
                        end));
                    else
                        Container.Text = "press"
                        Disconnect(Connection);
                    end
                end));

                Utils.Click(Container, "BackgroundColor3");
                Keybind.Visible = true
                Keybind.Parent = Section.Options
                UpdateClone();
            end
            
            function ElementLibrary.TextboxKeybind(Title, Bind, Callback)
                local Keybind = Clone(GuiObjects.Elements.TextboxKeybind);
                
                Keybind.Container.Text = Bind
                Keybind.Title.Text = Title
                
                local Container = Keybind.Container
                AddConnection(CConnect(GetPropertyChangedSignal(Container, "Text"), function(Key)
                    if (#Container.Text >= 1) then
                        Container.Text = sub(Container.Text, 1, 1);
                        Callback(Container.Text);
                        Container.ReleaseFocus(Container);
                    end
                end))
                
                Keybind.Visible = true
                Keybind.Parent = Section.Options
                UpdateClone();
            end

            function ElementLibrary.ColorPicker(Title, DefaultColor, Callback)
                local SelectColor = Clone(ColorElements.SelectColor);
                local CurrentColor = DefaultColor
                local Button = SelectColor.Button
                local ToHSV = DefaultColor.ToHSV
                local Color3New = Color3.new
                local Color3fromHSV = Color3.fromHSV
                local UDim2New = UDim2.new
                local clamp = math.clamp

                local H, S, V = ToHSV(DefaultColor);
                local Opened = false
                local Rainbow = false
                
                local function UpdateText()
                    RedTextBox.PlaceholderText = tostring(math.floor(CurrentColor.R * 255))
                    GreenTextBox.PlaceholderText = tostring(math.floor(CurrentColor.G * 255))
                    BlueTextBox.PlaceholderText = tostring(math.floor(CurrentColor.B * 255))
                end
                
                local function UpdateColor()
                    H, S, V = ToHSV(CurrentColor);
                    
                    SliderBar.Position = UDim2New(0, 0, H, 2);
                    CanvasBar.Position = UDim2New(S, 2, 1 - V, 2);
                    ColorGradient.UIGradient.Color = Utils.MakeGradient({
                        [1] = Color3New(1, 1, 1);
                        [2] = Color3fromHSV(H, 1, 1);
                    })
                    
                    ColorPreview.BackgroundColor3 = CurrentColor
                    UpdateText();
                end
            
                local function UpdateHue(Hue)
                    SliderBar.Position = UDim2New(0, 0, Hue, 2);
                    ColorGradient.UIGradient.Color = Utils.MakeGradient({
                        [1] = Color3New(1, 1, 1);
                        [2] = Color3fromHSV(Hue, 1, 1);
                    });
                    
                    ColorPreview.BackgroundColor3 = CurrentColor
                    UpdateText();
                end
                
                local function ColorSliderInit()
                    local Moving = false
                    
                    local function Update()
                        if Opened and not Rainbow then
                            local LowerBound = SliderHitbox.AbsoluteSize.Y
                            local Position = clamp(Mouse.Y - SliderHitbox.AbsolutePosition.Y, 0, LowerBound);
                            local Value = Position / LowerBound
                            
                            H = Value
                            CurrentColor = Color3fromHSV(H, S, V);
                            ColorPreview.BackgroundColor3 = CurrentColor
                            ColorGradient.UIGradient.Color = Utils.MakeGradient({
                                [1] = Color3New(1, 1, 1);
                                [2] = Color3fromHSV(H, 1, 1);
                            });
                            
                            UpdateText();
                            
                            local Position = UDim2.new(0, 0, Value, 2)
                            local Tween = Utils.Tween(SliderBar, "Linear", "Out", .05, {
                                Position = Position
                            });
                            
                            Callback(CurrentColor);
                            CWait(Tween.Completed);
                        end
                    end
                
                    AddConnection(CConnect(SliderHitbox.MouseButton1Down, function()
                        Moving = true
                        Update()
                    end))
                    
                    AddConnection(CConnect(UserInputService.InputEnded, function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 and Moving then
                            Moving = false
                        end
                    end))
                    
                    AddConnection(CConnect(Mouse.Move, Utils.Debounce(function()
                        if Moving then
                            Update()
                        end
                    end)))
                end
                local function ColorCanvasInit()
                    local Moving = false
                    
                    local function Update()
                        if Opened then
                            local LowerBound = CanvasHitbox.AbsoluteSize.Y
                            local YPosition = clamp(Mouse.Y - CanvasHitbox.AbsolutePosition.Y, 0, LowerBound)
                            local YValue = YPosition / LowerBound
                            local RightBound = CanvasHitbox.AbsoluteSize.X
                            local XPosition = clamp(Mouse.X - CanvasHitbox.AbsolutePosition.X, 0, RightBound)
                            local XValue = XPosition / RightBound
                            
                            S = XValue
                            V = 1 - YValue
                            
                            CurrentColor = Color3fromHSV(H, S, V);
                            ColorPreview.BackgroundColor3 = CurrentColor
                            UpdateText()
                            
                            local Position = UDim2New(XValue, 2, YValue, 2);
                            local Tween = Utils.Tween(CanvasBar, "Linear", "Out", .05, {
                                Position = Position
                            });
                            Callback(CurrentColor);
                            CWait(Tween.Completed);
                        end
                    end
                
                    AddConnection(CConnect(CanvasHitbox.MouseButton1Down, function()
                        Moving = true
                        Update()
                    end))
                    
                    AddConnection(CConnect(UserInputService.InputEnded, function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 and Moving then
                            Moving = false
                        end
                    end))
                    
                    AddConnection(CConnect(Mouse.Move, Utils.Debounce(function()
                        if Moving then
                            Update()
                        end
                    end)))
                end
                
                ColorSliderInit()
                ColorCanvasInit()
                
                AddConnection(CConnect(Button.MouseButton1Click, function()
                    if not Opened then
                        Opened = true
                        UpdateColor()
                        RainbowToggle.Container.Switch.Position = Rainbow and UDim2New(1, -18, 0, 2) or UDim2.fromOffset(2, 2)
                        RainbowToggle.Container.BackgroundColor3 = Color3.fromRGB(25, 25, 25);
                        Overlay.Visible = true
                        OverlayMain.Visible = false
                        Utils.Intro(OverlayMain)
                    end
                end))
                
                AddConnection(CConnect(ClosePicker.MouseButton1Click, Utils.Debounce(function()
                    Button.BackgroundColor3 = CurrentColor
                    Utils.Intro(OverlayMain)
                    Overlay.Visible = false
                    Opened = false
                end)))
                
                AddConnection(CConnect(RedTextBox.FocusLost, function()
                    if Opened then
                        local Number = tonumber(RedTextBox.Text)
                        if Number then
                            Number = clamp(floor(Number), 0, 255)
                            CurrentColor = Color3New(Number / 255, CurrentColor.G, CurrentColor.B)
                            UpdateColor()
                            RedTextBox.PlaceholderText = tostring(Number)
                            Callback(CurrentColor)
                        end
                        RedTextBox.Text = ""
                    end
                end))
                
                AddConnection(CConnect(GreenTextBox.FocusLost, function()
                    if Opened then
                        local Number = tonumber(GreenTextBox.Text)
                        if Number then
                            Number = clamp(floor(Number), 0, 255)
                            CurrentColor = Color3New(CurrentColor.R, Number / 255, CurrentColor.B)
                            UpdateColor()
                            GreenTextBox.PlaceholderText = tostring(Number)
                            Callback(CurrentColor)
                        end
                        GreenTextBox.Text = ""
                    end
                end))
                
                AddConnection(CConnect(BlueTextBox.FocusLost, function()
                    if Opened then
                        local Number = tonumber(BlueTextBox.Text)
                        if Number then
                            Number = clamp(floor(Number), 0, 255)
                            CurrentColor = Color3New(CurrentColor.R, CurrentColor.G, Number / 255)
                            UpdateColor()
                            BlueTextBox.PlaceholderText = tostring(Number)
                            Callback(CurrentColor)
                        end
                        BlueTextBox.Text = ""
                    end
                end))
                
                Utils.ToggleFunction(RainbowToggle.Container, false, function(Callback)
                    if Opened then
                        Rainbow = Callback
                    end
                end)
                
                AddConnection(CConnect(RenderStepped, function()
                    if Rainbow then
                        local Hue = (tick() / 5) % 1
                        CurrentColor = Color3.fromHSV(Hue, S, V)
                        
                        if Opened then
                            UpdateHue(Hue)
                        end
                        
                        Button.BackgroundColor3 = CurrentColor
                        Callback(CurrentColor, true);
                    end
                end))
                                
                Button.BackgroundColor3 = DefaultColor
                SelectColor.Title.Text = Title
                SelectColor.Visible = true
                SelectColor.Parent = Section.Options
                Utils.Thing(SelectColor.Title);
            end

            return ElementLibrary
        end

        return PageLibrary
    end
end

Utils.Click(ConfigUI.Close, "TextColor3")
AddConnection(CConnect(ConfigUI.Close.MouseButton1Click, function()
    ConfigLoaded = false
    CWait(Utils.TweenAllTrans(ConfigUI, .25).Completed);
    ConfigUI.Visible = false
end))