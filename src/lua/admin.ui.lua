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

local CommandBarPrefix;
local UIConfig = {
    CommandBar = {
        Background = {
            Color = {
                R = 32,
                G = 33,
                B = 36
            },
            Transparency = 0.25
        },
        InputText = {
            Color = {
                R = 255,
                G = 255,
                B = 255
            }
        },
        Arrow = {
            Color = {
                R = 255,
                G = 255,
                B = 255
            }
        }
    },
    CommandList = {
        Background = {
            Color = {
                R = 32,
                G = 33,
                B = 36
            },
            Transparency = 0.25
        },
        Title = {
            Text = "Search Commands",
            Color = {
                R = 184,
                G = 187,
                B = 195
            }
        }
    },
    Notification = {
        Background = {
            Color = {
                R = 32,
                G = 33,
                B = 36
            },
            Transparency = 0.25
        },
        Title = {
            Text = "Notification",
            Color = {
                R = 220,
                G = 224,
                B = 234
            }
        },
        Message = {
            Color = {
                R = 220,
                G = 224,
                B = 234
            }
        }
    },
    Command = {
        Background = {
            Color = {
                R = 32,
                G = 33,
                B = 36
            },
            Transparency = 0.75
        },
        TextColor = {
            R = 220,
            G = 224,
            B = 234
        }
    }
}

if isfolder("fates-admin") and not isfile("fates-admin/UI.json") then 
    local Data = JSONEncode(Services.HttpService, UIConfig);
    writefile("fates-admin/UI.json", Data);
    writefile("fates-admin/UI-Backup.json", Data);
end;

do
    local ok, res = pcall(JSONDecode, Services.HttpService, readfile("fates-admin/UI.json"));
    local Config = GetConfig();

    UIConfig = ok and res or UIConfig;
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
    local fromRGB = Color3.fromRGB;
    local CloneCmdC = UIConfig.Command; 
    local CommandBarC = UIConfig.CommandBar;
    local CommandListC = UIConfig.CommandList;
    local NotificationC = UIConfig.Notification;

    CommandBar.BackgroundColor3 = fromRGB(CommandBarC.Background.Color.R, CommandBarC.Background.Color.G, CommandBarC.Background.Color.B);
    CommandBar.BackgroundTransparency = CommandBarC.Background.Transparency;

    CommandBar.Input.TextColor3 = fromRGB(CommandBarC.InputText.Color.R, CommandBarC.InputText.Color.G, CommandBarC.InputText.Color.B);
    CommandBar.Arrow.TextColor3 = fromRGB(CommandBarC.Arrow.Color.R, CommandBarC.Arrow.Color.G, CommandBarC.Arrow.Color.B);

    Commands.BackgroundColor3 = fromRGB(CommandListC.Background.Color.R, CommandListC.Background.Color.G, CommandListC.Background.Color.B);
    Commands.BackgroundTransparency = CommandListC.Background.Transparency;

    Commands.Search.PlaceholderColor3 = fromRGB(CommandListC.Title.Color.R, CommandListC.Title.Color.G, CommandListC.Title.Color.B);
    Commands.Search.PlaceholderText = CommandListC.Title.Text;

    Notification.BackgroundColor3 = fromRGB(NotificationC.Background.Color.R, NotificationC.Background.Color.G, NotificationC.Background.Color.B);
    Notification.BackgroundTransparency = NotificationC.Background.Transparency;

    Notification.Title.TextColor3 = fromRGB(NotificationC.Title.Color.R, NotificationC.Title.Color.G, NotificationC.Title.Color.B);
    Notification.Title.Text = NotificationC.Title.Text;

    Notification.Message.TextColor3 = fromRGB(NotificationC.Message.Color.R, NotificationC.Message.Color.G, NotificationC.Message.Color.B);

    Command.CommandText.TextColor3 = fromRGB(CloneCmdC.TextColor.R, CloneCmdC.TextColor.G, CloneCmdC.TextColor.B);

    Command.BackgroundColor3 = fromRGB(CloneCmdC.Background.Color.R, CloneCmdC.Background.Color.G, CloneCmdC.Background.Color.B);
    Command.BackgroundTransparency = CloneCmdC.Background.Transparency;
end;