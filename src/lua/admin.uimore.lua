-- make all elements not visible
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

-- make the ui draggable
Utils.Draggable(Commands)
Utils.Draggable(ChatLogs)
Utils.Draggable(GlobalChatLogs)
Utils.Draggable(HttpLogs);

-- parent ui
ParentGui(UI);
Connections.UI = {}
-- tweencommand bar on prefix
local Times = #LastCommand
AddConnection(CConnect(Services.UserInputService.InputBegan, function(Input, GameProccesed)
    if (Input.KeyCode == CommandBarPrefix and (not GameProccesed)) then
        CommandBarOpen = not CommandBarOpen

        local TransparencyTween = CommandBarOpen and Utils.TweenAllTransToObject or Utils.TweenAllTrans
        local Tween = TransparencyTween(CommandBar, .5, CommandBarTransparencyClone)

        -- tween position
        if (CommandBarOpen) then
            if (not Draggable) then
                Utils.Tween(CommandBar, "Quint", "Out", .5, {
                    Position = UDim2.new(0.5, WideBar and -200 or -100, 1, -110) -- tween -110
                })
            end

            local Connections = getconnections(Services.UserInputService.TextBoxFocused);
            for i, v in next, Connections do
                v.Disable(v);
            end
            for i, v in next, getconnections(Services.UserInputService.TextBoxFocusReleased) do
                v.Disable(v);
            end

            CommandBar.Input.CaptureFocus(CommandBar.Input);
            coroutine.wrap(function()
                wait()
                CommandBar.Input.Text = ""
            end)()

            
            for i, v in next, Connections do
                v.Enable(v);
            end
        else
            if (not Draggable) then
                Utils.Tween(CommandBar, "Quint", "Out", .5, {
                    Position = UDim2.new(0.5, WideBar and -200 or -100, 1, 5) -- tween 5
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

-- close tween commands
AddConnection(CConnect(Commands.Close.MouseButton1Click, function()
    local Tween = Utils.TweenAllTrans(Commands, .25)

    CWait(Tween.Completed);
    Commands.Visible = false
end), Connections.UI, true);

-- command search
AddConnection(CConnect(GetPropertyChangedSignal(Commands.Search, "Text"), function()
    local Text = Commands.Search.Text
    for _, v in next, GetChildren(Commands.Frame.List) do
        if (IsA(v, "Frame")) then
            local Command = v.CommandText.Text

            v.Visible = Sfind(lower(Command), Text, 1, true)
        end
    end

    Commands.Frame.List.CanvasSize = UDim2.fromOffset(0, Commands.Frame.List.UIListLayout.AbsoluteContentSize.Y)
end), Connections.UI, true);

-- close chatlogs
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

ChatLogs.Toggle.Text = ChatLogsEnabled and "Enabled" or "Disabled"
GlobalChatLogs.Toggle.Text = ChatLogsEnabled and "Enabled" or "Disabled"
HttpLogs.Toggle.Text = HttpLogsEnabled and "Enabled" or "Disabled"


-- enable chat logs
AddConnection(CConnect(ChatLogs.Toggle.MouseButton1Click, function()
    ChatLogsEnabled = not ChatLogsEnabled
    ChatLogs.Toggle.Text = ChatLogsEnabled and "Enabled" or "Disabled"
end), Connections.UI, true);
AddConnection(CConnect(GlobalChatLogs.Toggle.MouseButton1Click, function()
    GlobalChatLogsEnabled = not GlobalChatLogsEnabled
    GlobalChatLogs.Toggle.Text = GlobalChatLogsEnabled and "Enabled" or "Disabled"
end), Connections.UI, true);
AddConnection(CConnect(HttpLogs.Toggle.MouseButton1Click, function()
    HttpLogsEnabled = not HttpLogsEnabled
    HttpLogs.Toggle.Text = HttpLogsEnabled and "Enabled" or "Disabled"
end), Connections.UI, true);

-- clear chat logs
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

-- chat logs search
AddConnection(CConnect(GetPropertyChangedSignal(ChatLogs.Search, "Text"), function()
    local Text = ChatLogs.Search.Text

    for _, v in next, GetChildren(ChatLogs.Frame.List) do
        if (not IsA(v, "UIListLayout")) then
            local Message = split(v.Text, ": ")[2]
            v.Visible = Sfind(lower(Message), Text, 1, true)
        end
    end

    ChatLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, ChatLogs.Frame.List.UIListLayout.AbsoluteContentSize.Y)
end), Connections.UI, true);

AddConnection(CConnect(GetPropertyChangedSignal(GlobalChatLogs.Search, "Text"), function()
    local Text = GlobalChatLogs.Search.Text

    for _, v in next, GetChildren(GlobalChatLogs.Frame.List) do
        if (not IsA(v, "UIListLayout")) then
            local Message = v.Text

            v.Visible = Sfind(lower(Message), Text, 1, true)
        end
    end
end), Connections.UI, true);

AddConnection(CConnect(GetPropertyChangedSignal(HttpLogs.Search, "Text"), function()
    local Text = HttpLogs.Search.Text

    for _, v in next, GetChildren(HttpLogs.Frame.List) do
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
    for i, v in next, GetChildren(ChatLogs.Frame.List) do
        if (not IsA(v, "UIListLayout")) then
            String = format("%s%s\n", String, v.Text);
        end
    end
    writefile(Name, String);
    Utils.Notify(LocalPlayer, "Saved", "Chat logs saved!");
end), Connections.UI, true);

AddConnection(CConnect(HttpLogs.Save.MouseButton1Click, function()
    print("saved");
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

if (ChatBar) then
    AddConnection(CConnect(GetPropertyChangedSignal(ChatBar, "Text"), function() -- todo: add detection for /e
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
end