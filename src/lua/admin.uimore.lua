-- parent ui function
ParentGui = function(Gui)
    Gui.Name = HttpService:GenerateGUID(false):gsub('-', ''):sub(1, math.random(25, 30))

    if ((not is_sirhurt_closure) and (syn and syn.protect_gui)) then
        syn.protect_gui(Gui);
        Gui.Parent = CoreGui
    elseif (CoreGui:FindFirstChild("RobloxGui")) then
        Gui.Parent = CoreGui.RobloxGui
    else
        Gui.Parent = CoreGui
    end
    Guis[#Guis + 1] = Gui 
    return Gui
end

-- make all elements not visible
Notification.Visible = false
Stats.Visible = false
Utils.SetAllTrans(CommandBar)
Utils.SetAllTrans(ChatLogs)
Utils.SetAllTrans(AdminChatLogs)
Commands.Visible = false
Animations.Visible = false
ChatLogs.Visible = false
AdminChatLogs.Visible = false

-- make the ui draggable
Utils.Draggable(Commands)
Utils.Draggable(Animations)
Utils.Draggable(ChatLogs)
Utils.Draggable(AdminChatLogs)

-- parent ui
ParentGui(UI)
Connections.UI = {}
-- tweencommand bar on prefix
Connections.UI.CommandBarInput = UserInputService.InputBegan:Connect(function(Input, GameProccesed)
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

            CommandBar.Input:CaptureFocus()
            coroutine.wrap(function()
                wait()
                CommandBar.Input.Text = ""
            end)()
        else
            if (not Draggable) then
                Utils.Tween(CommandBar, "Quint", "Out", .5, {
                    Position = UDim2.new(0.5, WideBar and -200 or -100, 1, 5) -- tween 5
                })
            end
        end
    end
end)

-- smooth scroll commands
Utils.SmoothScroll(Commands.Frame.List, .14)
Utils.SmoothScroll(Animations.Frame.List, .14)

-- fill commands with commands!
for _, v in next, CommandsTable do -- auto size
    if (not Commands.Frame.List:FindFirstChild(v.Name)) then
        local Clone = Command:Clone()

        Utils.Hover(Clone, "BackgroundColor3") -- add tooltip
        Utils.ToolTip(Clone, v.Name .. "\n" .. v.Description)
        Clone.CommandText.Text = v.Name .. (#v.Aliases > 0 and " (" ..table.concat(v.Aliases, ", ") .. ")" or "")
        Clone.Name = v.Name
        Clone.Visible = true
        Clone.Parent = Commands.Frame.List
    end
end



Utils.Click(Commands.Close, "TextColor3")
Commands.Frame.List.CanvasSize = UDim2.fromOffset(0, Commands.Frame.List.UIListLayout.AbsoluteContentSize.Y)
Animations.Frame.List.CanvasSize = UDim2.fromOffset(0, Animations.Frame.List.UIListLayout.AbsoluteContentSize.Y)
CommandsTransparencyClone = Commands:Clone()
AnimationsTransparencyClone = Animations:Clone()
Utils.SetAllTrans(Commands)
Utils.SetAllTrans(Animations)
Utils.Click(ChatLogs.Clear, "BackgroundColor3")
Utils.Click(ChatLogs.Save, "BackgroundColor3")
Utils.Click(ChatLogs.Toggle, "BackgroundColor3")
Utils.Click(ChatLogs.Close, "TextColor3")

Utils.Click(AdminChatLogs.Clear, "BackgroundColor3")
Utils.Click(AdminChatLogs.Save, "BackgroundColor3")
Utils.Click(AdminChatLogs.Toggle, "BackgroundColor3")
Utils.Click(AdminChatLogs.Close, "TextColor3")

-- close tween commands
Connections.CommandsClose = Commands.Close.MouseButton1Click:Connect(function()
    local Tween = Utils.TweenAllTrans(Commands, .25)

    Tween.Completed:Wait()
    Commands.Visible = false
end)

-- command search
Connections.UI.CommandsSearch = Commands.Search:GetPropertyChangedSignal("Text"):Connect(function()
    local Text = Commands.Search.Text
    for _, v in next, Commands.Frame.List:GetChildren() do
        if (v:IsA("Frame")) then
            local Command = v.CommandText.Text

            v.Visible = string.find(string.lower(Command), Text, 1, true)
        end
    end

    Commands.Frame.List.CanvasSize = UDim2.fromOffset(0, Commands.Frame.List.UIListLayout.AbsoluteContentSize.Y)
end)

-- close chatlogs
Connections.UI.ChatLogsClose = ChatLogs.Close.MouseButton1Click:Connect(function()
    local Tween = Utils.TweenAllTrans(ChatLogs, .25)

    Tween.Completed:Wait()
    ChatLogs.Visible = false
end)
Connections.UI.AdminChatLogsClose = AdminChatLogs.Close.MouseButton1Click:Connect(function()
    local Tween = Utils.TweenAllTrans(AdminChatLogs, .25)

    Tween.Completed:Wait()
    AdminChatLogs.Visible = false
end)

ChatLogs.Toggle.Text = ChatLogsEnabled and "Enabled" or "Disabled"
-- enable chat logs
Connections.UI.ChatLogsToggle = ChatLogs.Toggle.MouseButton1Click:Connect(function()
    ChatLogsEnabled = not ChatLogsEnabled
    ChatLogs.Toggle.Text = ChatLogsEnabled and "Enabled" or "Disabled"
end)
Connections.UI.AdminChatLogsToggle = AdminChatLogs.Toggle.MouseButton1Click:Connect(function()
    AdminChatLogsEnabled = AdminChatLogsEnabled
    AdminChatLogs.Toggle.Text = AdminChatLogsEnabled and "Enabled" or "Disabled"
end)

-- clear chat logs
Connections.UI.ChatLogsClear = ChatLogs.Clear.MouseButton1Click:Connect(function()
    Utils.ClearAllObjects(ChatLogs.Frame.List)
    ChatLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, 0)
end)
Connections.UI.AdminChatLogsClear = AdminChatLogs.Clear.MouseButton1Click:Connect(function()
    Utils.ClearAllObjects(AdminChatLogs.Frame.List)
    AdminChatLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, 0)
end)

-- chat logs search
Connections.UI.ChatLogs = ChatLogs.Search:GetPropertyChangedSignal("Text"):Connect(function()
    local Text = ChatLogs.Search.Text

    for _, v in next, ChatLogs.Frame.List:GetChildren() do
        if (not v:IsA("UIListLayout")) then
            local Message = v.Text:split(": ")[2]
            v.Visible = string.find(string.lower(Message), Text, 1, true)
        end
    end

    ChatLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, ChatLogs.Frame.List.UIListLayout.AbsoluteContentSize.Y)
end)

Connections.UI.AdminChatLogs = AdminChatLogs.Search:GetPropertyChangedSignal("Text"):Connect(function()
    local Text = AdminChatLogs.Search.Text

    for _, v in next, AdminChatLogs.Frame.List:GetChildren() do
        if (not v:IsA("UIListLayout")) then
            local Message = v.Text

            v.Visible = string.find(string.lower(Message), Text, 1, true)
        end
    end

    -- AdminChatLogs.Frame.List.CanvasSize = UDim2.fromOffset(0, AdminChatLogs.Frame.List.UIListLayout.AbsoluteContentSize.Y)
end)

Connections.UI.ChatLogsSave = ChatLogs.Save.MouseButton1Click:Connect(function()
    local GameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
    local String =  ("Fates Admin Chatlogs for %s (%s)\n\n"):format(GameName, os.date());
    local TimeSaved = tostring(os.date("%x")):gsub("/","-") .. " " .. tostring(os.date("%X")):gsub(":","-");
    local Name = ("fates-admin/chatlogs/%s (%s).txt"):format(GameName, TimeSaved);
    for i, v in next, ChatLogs.Frame.List:GetChildren() do
        if (not v:IsA("UIListLayout")) then
            String = ("%s%s\n"):format(String, v.Text);
        end
    end
    writefile(Name, String);
    Utils.Notify(LocalPlayer, "Saved", "Chat logs saved!");
end)