
UI = game:GetObjects("rbxassetid://6167929302")[1]:Clone()


Guis = {}
local ParentGui
local CommandBarPrefix = GetConfig().CommandBarPrefix and Enum.KeyCode[GetConfig().CommandBarPrefix] or Enum.KeyCode.Semicolon

local CommandBar = UI.CommandBar
local Commands = UI.Commands
local Animations = UI.Commands:Clone()
local ChatLogs = UI.ChatLogs
local AdminChatLogs = UI.ChatLogs:Clone()
local Notification = UI.Notification
local Command = UI.Command
local Animation = UI.Command:Clone()
local ChatLogMessage = UI.Message
local AdminChatLogMessage = UI.Message:Clone()
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
local AdminChatLogsTransparencyClone = AdminChatLogs:Clone()
local CommandsTransparencyClone
local PredictionText = ""

local UIParent = CommandBar.Parent
AdminChatLogs.Parent = UIParent
AdminChatLogMessage.Parent = UIParent
Animations.Parent = UIParent
Animations.Search.Text = "Search Animations"
Animations.Search.PlaceholderText = "Search Animations"
Animation.Parent = UIParent
AdminChatLogs.Name = "AdminChatLogs"
AdminChatLogMessage.Name = "AdminChatLogMessage"
Animations.Name = "Animations"
Animation.Name = "Animation"
Stats.Name = "Stats"
Stats.Parent = UIParent
StatsBar.Name = "StatsBar"
StatsBar.Parent = UIParent
StatsBar.Position = UDim2.new(0, 600, 0, -150)

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