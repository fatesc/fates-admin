Guis = {}
ParentGui = function(Gui, Parent)
    Gui.Name = sub(gsub(GenerateGUID(Services.HttpService, false), '-', ''), 1, random(25, 30))
    ProtectInstance(Gui);
    Gui.Parent = Parent or Services.CoreGui
    Guis[#Guis + 1] = Gui
    return Gui
end
UI = Clone(Services.InsertService:LoadLocalAsset("rbxassetid://7855824528"));
UI.Enabled = true

local CommandBarPrefix;

local ConfigUI = UI.Config
local ConfigElements = ConfigUI.GuiElements
local CommandBar = UI.CommandBar
local Commands = UI.Commands
local ChatLogs = UI.ChatLogs
local GlobalChatLogs = Clone(UI.ChatLogs);
local HttpLogs = Clone(UI.ChatLogs);
local Notification = UI.Notification
local Command = UI.Command
local ChatLogMessage = UI.Message
local GlobalChatLogMessage = Clone(UI.Message);
local NotificationBar = UI.NotificationBar
local Stats = Clone(UI.Notification);
local StatsBar = Clone(UI.NotificationBar);

CommandBarOpen = false
CommandBarTransparencyClone = Clone(CommandBar);
ChatLogsTransparencyClone = Clone(ChatLogs);
GlobalChatLogsTransparencyClone = Clone(GlobalChatLogs);
HttpLogsTransparencyClone = Clone(HttpLogs);
CommandsTransparencyClone = nil
ConfigUIClone = Clone(ConfigUI);
PredictionText = ""
do
    local UIParent = CommandBar.Parent
    GlobalChatLogs.Parent = UIParent
    GlobalChatLogMessage.Parent = UIParent
    GlobalChatLogs.Name = "GlobalChatLogs"
    GlobalChatLogMessage.Name = "GlobalChatLogMessage"

    HttpLogs.Parent = UIParent
    HttpLogs.Name = "HttpLogs"
    HttpLogs.Size = UDim2.new(0, 421, 0, 260);
    HttpLogs.Search.PlaceholderText = "Search"
end
-- position CommandBar
CommandBar.Position = UDim2.new(0.5, -100, 1, 5);
ProtectInstance(CommandBar.Input, true);
ProtectInstance(Commands.Search, true);

local UITheme, Values;
do
    local BaseBGColor = Color3.fromRGB(32, 33, 36);
    local BaseTransparency = 0.25
    local BaseTextColor = Color3.fromRGB(220, 224, 234);
    local BaseValues = { BackgroundColor = BaseBGColor, Transparency = BaseTransparency, TextColor = BaseTextColor }
    Values = { Background = clone(BaseValues), CommandBar = clone(BaseValues), CommandList = clone(BaseValues), Notification = clone(BaseValues), ChatLogs = clone(BaseValues), Config = clone(BaseValues) }
    local Objects = keys(Values);
    local GetBaseMT = function(Object)
        return setmetatable({}, {
            __newindex = function(self, Index, Value)
                local type = typeof(Value);
                if (Index == "BackgroundColor") then
                    if (Value == "Reset") then
                        Value = BaseBGColor
                        type = "Color3"
                    end
                    assert(type == 'Color3', format("invalid argument #3 (Color3 expected, got %s)", type));
                    if (Object == "Background") then
                        CommandBar.BackgroundColor3 = Value
                        Notification.BackgroundColor3 = Value
                        Command.BackgroundColor3 = Value
                        ChatLogs.BackgroundColor3 = Value
                        ChatLogs.Frame.BackgroundColor3 = Value
                        HttpLogs.BackgroundColor3 = Value
                        HttpLogs.Frame.BackgroundColor3 = Value
                        UI.ToolTip.BackgroundColor3 = Value
                        ConfigUI.BackgroundColor3 = Value
                        ConfigUI.Container.BackgroundColor3 = Value
                        Commands.BackgroundColor3 = Value
                        Commands.Frame.BackgroundColor3 = Value
                        local Children = GetChildren(UI.NotificationBar);
                        for i = 1, #Children do
                            local Child = Children[i]
                            if (IsA(Child, "GuiObject")) then
                                Child.BackgroundColor3 = Value
                            end
                        end
                        local Children = GetChildren(Commands.Frame.List);
                        for i = 1, #Children do
                            local Child = Children[i]
                            if (IsA(Child, "GuiObject")) then
                                Child.BackgroundColor3 = Value
                            end
                        end
                        for i, v in next, Values do
                            Values[i].BackgroundColor = Value
                        end
                    elseif (Object == "CommandBar") then
                        CommandBar.BackgroundColor3 = Value
                    elseif (Object == "Notification") then
                        Notification.BackgroundColor3 = Value
                        local Children = GetChildren(UI.NotificationBar);
                        for i = 1, #Children do
                            local Child = Children[i]
                            if (IsA(Child, "GuiObject")) then
                                Child.BackgroundColor3 = Value
                            end
                        end
                    elseif (Object == "CommandList") then
                        Commands.BackgroundColor3 = Value
                        Commands.Frame.BackgroundColor3 = Value
                    elseif (Object == "Command") then
                        Command.BackgroundColor3 = Value
                    elseif (Object == "ChatLogs") then
                        ChatLogs.BackgroundColor3 = Value
                        ChatLogs.Frame.BackgroundColor3 = Value
                        HttpLogs.BackgroundColor3 = Value
                        HttpLogs.Frame.BackgroundColor3 = Value
                    elseif (Object == "Config") then
                        ConfigUI.BackgroundColor3 = Value
                        ConfigUI.Container.BackgroundColor3 = Value
                    end
                    Values[Object][Index] = Value
                elseif (Index == "TextColor") then
                    if (Value == "Reset") then
                        Value = BaseTextColor
                        type = "Color3"
                    end
                    assert(type == 'Color3', format("invalid argument #3 (Color3 expected, got %s)", type));
                    if (Object == "Notification") then
                        Notification.Title.TextColor3 = Value
                        Notification.Message.TextColor3 = Value
                        Notification.Close.TextColor3 = Value
                    elseif (Object == "CommandBar") then
                        CommandBar.Input.TextColor3 = Value
                        CommandBar.Arrow.TextColor3 = Value
                    elseif (Object == "CommandList") then
                        Command.CommandText.TextColor3 = Value
                        local Descendants = GetDescendants(Commands);
                        for i = 1, #Descendants do
                            local Descendant = Descendants[i]
                            local IsText = IsA(Descendant, "TextBox") or IsA(Descendant, "TextLabel") or IsA(Descendant, "TextButton");
                            if (IsText) then
                                Descendant.TextColor3 = Value
                            end
                        end
                    elseif (Object == "ChatLogs") then
                        UI.Message.TextColor3 = Value
                    elseif (Object == "Config") then
                        local Descendants = GetDescendants(ConfigUI);
                        for i = 1, #Descendants do
                            local Descendant = Descendants[i]
                            local IsText = IsA(Descendant, "TextBox") or IsA(Descendant, "TextLabel") or IsA(Descendant, "TextButton");
                            if (IsText) then
                                Descendant.TextColor3 = Value
                            end
                        end
                    elseif (Object == "Background") then
                        Notification.Title.TextColor3 = Value
                        Notification.Message.TextColor3 = Value
                        Notification.Close.TextColor3 = Value
                        CommandBar.Input.TextColor3 = Value
                        CommandBar.Arrow.TextColor3 = Value
                        Command.CommandText.TextColor3 = Value
                        UI.Message.TextColor3 = Value
                        local Descendants = GetDescendants(ConfigUI);
                        for i = 1, #Descendants do
                            local Descendant = Descendants[i]
                            local IsText = IsA(Descendant, "TextBox") or IsA(Descendant, "TextLabel") or IsA(Descendant, "TextButton");
                            if (IsText) then
                                Descendant.TextColor3 = Value
                            end
                        end
                        local Descendants = GetDescendants(Commands);
                        for i = 1, #Descendants do
                            local Descendant = Descendants[i]
                            local IsText = IsA(Descendant, "TextBox") or IsA(Descendant, "TextLabel") or IsA(Descendant, "TextButton");
                            if (IsText) then
                                Descendant.TextColor3 = Value
                            end
                        end
                        for i, v in next, Values do
                            Values[i].TextColor = Value
                        end
                    end
                    Values[Object][Index] = Value
                elseif (Index == "Transparency") then
                    if (Value == "Reset") then
                        Value = BaseTransparency
                        type = "number"
                    end
                    assert(type == 'number', format("invalid argument #3 (Color3 expected, got %s)", type));
                    if (Object == "Background") then
                        CommandBar.Transparency = Value
                        Notification.Transparency = Value
                        Command.Transparency = Value
                        ChatLogs.Transparency = Value
                        ChatLogs.Frame.Transparency = Value
                        HttpLogs.Transparency = Value
                        HttpLogs.Frame.Transparency = Value
                        UI.ToolTip.Transparency = Value
                        ConfigUI.Transparency = Value
                        ConfigUI.Container.Transparency = Value + .5
                        Commands.Transparency = Value
                        Commands.Frame.Transparency = Value
                        Values[Object][Index] = Value
                    elseif (Object == "Notification") then
                        Notification.Transparency = Value
                        local Children = GetChildren(UI.NotificationBar);
                        for i = 1, #Children do
                            local Child = Children[i]
                            if (IsA(Child, "GuiObject")) then
                                Child.Transparency = Value
                            end
                        end
                    end
                    Values[Object][Index] = Value
                end
            end,
            __index = function(self, Index)
                return Values[Object][Index]
            end
        })
    end
    UITheme = setmetatable({}, {
        __index = function(self, Index)
            if (Tfind(Objects, Index)) then
                local BaseMt = GetBaseMT(Index);
                self[Index] = BaseMt
                return BaseMt
            end
        end
    })
end

local IsSupportedExploit = isfile and isfolder and writefile and readfile

local GetThemeConfig
local WriteThemeConfig = function(Conf)
    if (IsSupportedExploit and isfolder("fates-admin")) then
        local ToHSV = Color3.new().ToHSV
        local ValuesToEncode = deepsearchset(Values, function(i, v)
            return typeof(v) == 'Color3'
        end, function(i, v)
            local H, S, V = ToHSV(v);
            return {H, S, V, "Color3"}
        end)
        local Data = JSONEncode(Services.HttpService, ValuesToEncode);
        writefile("fates-admin/Theme.json", Data);
    end
end

GetThemeConfig = function()
    if (IsSupportedExploit and isfolder("fates-admin")) then
        if (isfile("fates-admin/Theme.json")) then
            local Success, Data = pcall(JSONDecode, Services.HttpService, readfile("fates-admin/Theme.json"));
            if (not Success or type(Data) ~= 'table') then
                WriteThemeConfig();
                return Values
            end
            local DecodedData = deepsearchset(Data, function(i, v)
                return type(v) == 'table' and #v == 4 and v[4] == "Color3"
            end, function(i,v)
                return Color3.fromHSV(v[1], v[2], v[3]);
            end)
            return DecodedData            
        else
            WriteThemeConfig();
        end
    else
        return Values
    end
end

local LoadTheme;
do
    local Config = GetConfig();
    CommandBarPrefix = isfolder and (Config.CommandBarPrefix and Enum.KeyCode[Config.CommandBarPrefix] or Enum.KeyCode.Semicolon) or Enum.KeyCode.Semicolon

    local Theme = GetThemeConfig();
    LoadTheme = function(Theme)
        UITheme.Background.BackgroundColor = Theme.Background.BackgroundColor
        UITheme.Background.Transparency = Theme.Background.Transparency

        UITheme.ChatLogs.BackgroundColor = Theme.ChatLogs.BackgroundColor
        UITheme.CommandBar.BackgroundColor = Theme.CommandBar.BackgroundColor
        UITheme.Config.BackgroundColor = Theme.Config.BackgroundColor
        UITheme.Notification.BackgroundColor = Theme.Notification.BackgroundColor
        UITheme.CommandList.BackgroundColor = Theme.Notification.BackgroundColor
        
        UITheme.ChatLogs.TextColor = Theme.ChatLogs.TextColor
        UITheme.CommandBar.TextColor = Theme.CommandBar.TextColor
        UITheme.Config.TextColor = Theme.Config.TextColor
        UITheme.Notification.TextColor = Theme.Notification.TextColor
        UITheme.CommandList.TextColor = Theme.Notification.TextColor

        UITheme.ChatLogs.Transparency = Theme.ChatLogs.Transparency
        UITheme.CommandBar.Transparency = Theme.CommandBar.Transparency
        UITheme.Config.Transparency = Theme.Config.Transparency
        UITheme.Notification.Transparency = Theme.Notification.Transparency
        UITheme.CommandList.Transparency = Theme.Notification.Transparency
    end
    LoadTheme(Theme);
end