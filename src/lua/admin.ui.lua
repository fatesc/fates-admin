Guis = {}
ParentGui = function(Gui, Parent)
    Gui.Name = sub(gsub(GenerateGUID(Services.HttpService, false), '-', ''), 1, random(25, 30))
    ProtectInstance(Gui);
    Gui.Parent = Parent or Services.CoreGui
    Guis[#Guis + 1] = Gui
    return Gui
end
UI = Clone(game.GetObjects(game, "rbxassetid://6167929302")[1]);

local CommandBarPrefix = isfolder and (GetConfig().CommandBarPrefix and Enum.KeyCode[GetConfig().CommandBarPrefix] or Enum.KeyCode.Semicolon) or Enum.KeyCode.Semicolon

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

local RobloxChat = PlayerGui and FindFirstChild(PlayerGui, "Chat");
if (RobloxChat) then
    local RobloxChatFrame = WaitForChild(RobloxChat, "Frame", .1);
    if RobloxChatFrame then
        RobloxChatChannelParentFrame = WaitForChild(RobloxChatFrame, "ChatChannelParentFrame", .1);
        RobloxChatBarFrame = WaitForChild(RobloxChatFrame, "ChatBarParentFrame", .1);
        if RobloxChatChannelParentFrame then
            RobloxFrameMessageLogDisplay = WaitForChild(RobloxChatChannelParentFrame, "Frame_MessageLogDisplay", .1);
            if RobloxFrameMessageLogDisplay then
                RobloxScroller = WaitForChild(RobloxFrameMessageLogDisplay, "Scroller", .1);
            end
        end
    end
end

local CommandBarOpen = false
local CommandBarTransparencyClone = Clone(CommandBar);
local ChatLogsTransparencyClone = Clone(ChatLogs);
local GlobalChatLogsTransparencyClone = Clone(GlobalChatLogs);
local HttpLogsTransparencyClone = Clone(HttpLogs);
local CommandsTransparencyClone
local PredictionText = ""

local UIParent = CommandBar.Parent
GlobalChatLogs.Parent = UIParent
GlobalChatLogMessage.Parent = UIParent
GlobalChatLogs.Name = "GlobalChatLogs"
GlobalChatLogMessage.Name = "GlobalChatLogMessage"

HttpLogs.Parent = UIParent
HttpLogs.Name = "HttpLogs"
HttpLogs.Size = UDim2.new(0, 421, 0, 260);
HttpLogs.Search.PlaceholderText = "Search"

local Frame2;
local PredictionClone;
if (RobloxChatBarFrame) then
    local Frame1 = WaitForChild(RobloxChatBarFrame, 'Frame', .1);
    if Frame1 then
        local BoxFrame = WaitForChild(Frame1, 'BoxFrame', .1);
        if BoxFrame then
            Frame2 = WaitForChild(BoxFrame, 'Frame', .1);
            if Frame2 then
                local TextLabel = WaitForChild(Frame2, 'TextLabel', .1);
                ChatBar = WaitForChild(Frame2, 'ChatBar', .1);
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

-- position CommandBar
CommandBar.Position = UDim2.new(0.5, -100, 1, 5);
ProtectInstance(CommandBar.Input, true);
ProtectInstance(Commands.Search, true);