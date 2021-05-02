UI = game:GetObjects("rbxassetid://6167929302")[1]:Clone()


Guis = {}
local ParentGui
local CommandBarPrefix = isfolder and (GetConfig().CommandBarPrefix and Enum.KeyCode[GetConfig().CommandBarPrefix] or Enum.KeyCode.Semicolon) or Enum.KeyCode.Semicolon

local CommandBar = UI.CommandBar
local Commands = UI.Commands
local ChatLogs = UI.ChatLogs
local GlobalChatLogs = UI.ChatLogs:Clone()
local HttpLogs = UI.ChatLogs:Clone();
local Notification = UI.Notification
local Command = UI.Command
local ChatLogMessage = UI.Message
local GlobalChatLogMessage = UI.Message:Clone()
local NotificationBar = UI.NotificationBar
local Stats = UI.Notification:Clone();
local StatsBar = UI.NotificationBar:Clone();

local RobloxChat = PlayerGui:FindFirstChild("Chat")
if (RobloxChat) then
    local RobloxChatFrame = RobloxChat:WaitForChild("Frame")
    RobloxChatChannelParentFrame = RobloxChatFrame:WaitForChild("ChatChannelParentFrame")
    RobloxChatBarFrame = RobloxChatFrame:WaitForChild("ChatBarParentFrame")
    RobloxFrameMessageLogDisplay = RobloxChatChannelParentFrame:WaitForChild("Frame_MessageLogDisplay")
    RobloxScroller = RobloxFrameMessageLogDisplay:WaitForChild("Scroller")
end

local CommandBarOpen = false
local CommandBarTransparencyClone = CommandBar:Clone()
local ChatLogsTransparencyClone = ChatLogs:Clone()
local GlobalChatLogsTransparencyClone = GlobalChatLogs:Clone()
local HttpLogsTransparencyClone = HttpLogs:Clone()
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

if (RobloxChatBarFrame) then
    PredictionClone = RobloxChatBarFrame.Frame.BoxFrame.Frame.TextLabel:Clone();
    PredictionClone.Text = ""
    PredictionClone.TextTransparency = 0.3
    PredictionClone.Name = "Predict"
    PredictionClone.Parent = RobloxChatBarFrame.Frame.BoxFrame.Frame
    
    ChatBar = RobloxChatBarFrame.Frame.BoxFrame.Frame.ChatBar
end


-- position CommandBar
CommandBar.Position = UDim2.new(0.5, -100, 1, 5)