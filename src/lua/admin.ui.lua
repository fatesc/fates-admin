Guis = {}
ParentGui = function(Gui, Parent)
    Gui.Name = sub(gsub(GenerateGUID(Services.HttpService, false), '-', ''), 1, random(25, 30))
    ProtectInstance(Gui);
    Gui.Parent = Parent or Services.CoreGui
    Guis[#Guis + 1] = Gui
    return Gui
end
UI = Clone(game.GetObjects(game, "rbxassetid://6167929302")[1]);
UI.Enabled = true

if isfolder("fates-admin") and not isfile("fates-admin/UI.json") then writefile("fates-admin/UI.json", game:HttpGet("https://pastebin.com/raw/JUZCZeBF")) end;

local UIConfig;
local CommandBarPrefix;

do
    local ok, res = pcall(game.HttpService.JSONDecode, game.HttpService, readfile("fates-admin/UI.json"));
    local Config = GetConfig();

    UIConfig = ok and res or game.HttpService:JSONDecode(game:HttpGet("https://pastebin.com/raw/JUZCZeBF"));
    CommandBarPrefix = isfolder and (Config.CommandBarPrefix and Enum.KeyCode[Config.CommandBarPrefix] or Enum.KeyCode.Semicolon) or Enum.KeyCode.Semicolon
end

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

local CommandBarOpen = false
local CommandBarTransparencyClone = Clone(CommandBar);
local ChatLogsTransparencyClone = Clone(ChatLogs);
local GlobalChatLogsTransparencyClone = Clone(GlobalChatLogs);
local HttpLogsTransparencyClone = Clone(HttpLogs);
local CommandsTransparencyClone
local ConfigUIClone = Clone(ConfigUI);
local PredictionText = ""
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

-- Loading theme
do
    local CommandBarB = UIConfig.CommandBar.Background
    CommandBar.BackgroundColor3 = Color3.fromRGB(CommandBarB.Color.R, CommandBarB.Color.G, CommandBarB.Color.B);
    CommandBar.BackgroundTransparency = CommandBarB.Transparency;

    local CommandListB = UIConfig.CommandList.Background
    Commands.BackgroundColor3 = Color3.fromRGB(CommandListB.Color.R, CommandListB.Color.G, CommandListB.Color.B);
    Commands.BackgroundTransparency = CommandListB.Transparency;

    local NotificationB = UIConfig.Notification.Background
    Notification.BackgroundColor3 = Color3.fromRGB(NotificationB.Color.R, NotificationB.Color.G, NotificationB.Color.B);
    Notification.BackgroundTransparency = NotificationB.Transparency;
end;