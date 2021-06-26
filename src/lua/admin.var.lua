local Services = {}
Services.Workspace = GetService(game, "Workspace");
local GetChildren, GetDescendants = game.GetChildren, game.GetDescendants
local IsA = game.IsA
local FindFirstChild, FindFirstChildOfClass, FindFirstChildWhichIsA, WaitForChild = 
    game.FindFirstChild,
    game.FindFirstChildOfClass,
    game.FindFirstChildWhichIsA,
    game.WaitForChild

local GetPropertyChangedSignal, Changed = 
    game.GetPropertyChangedSignal,
    game.Changed
    
local Destroy, Clone = game.Destroy, game.Clone

local RunService = GetService(game, "RunService");
local Heartbeat, Stepped, RenderStepped =
    RunService.Heartbeat,
    RunService.Stepped,
    RunService.RenderStepped

local Players = GetService(game, "Players");
local GetPlayers = Players.GetPlayers

Services.UserInputService = GetService(game, "UserInputService");
Services.ReplicatedStorage = GetService(game, "ReplicatedStorage");
Services.StarterPlayer = GetService(game, "StarterPlayer");
Services.StarterPack = GetService(game, "StarterPack");
Services.StarterGui = GetService(game, "StarterGui");
Services.TeleportService = GetService(game, "TeleportService");
Services.CoreGui = GetService(game, "CoreGui");
Services.TweenService = GetService(game, "TweenService");
Services.HttpService = GetService(game, "HttpService");
Services.TextService = GetService(game, "TextService");
Services.MarketplaceService = GetService(game, "MarketplaceService")
Services.Chat = GetService(game, "Chat");
Services.Teams = GetService(game, "Teams");
Services.SoundService = GetService(game, "SoundService");
Services.Lighting = GetService(game, "Lighting");
Services.ScriptContext = GetService(game, "ScriptContext");
Services.Stats = GetService(game, "Stats");

local JSONEncode, JSONDecode, GenerateGUID = 
    Services.HttpService.JSONEncode, 
    Services.HttpService.JSONDecode,
    Services.HttpService.GenerateGUID

local Camera = Services.Workspace.CurrentCamera

local table = table
local Tfind, sort, concat, pack, unpack, insert, remove = 
    table.find, 
    table.sort,
    table.concat,
    table.pack,
    table.unpack,
    table.insert,
    table.remove

local string = string
local lower, trim, Sfind, split, sub, format, len, match, gmatch, gsub, byte = 
    string.lower, 
    string.trim, 
    string.find, 
    string.split, 
    string.sub,
    string.format,
    string.len,
    string.match,
    string.gmatch,
    string.gsub,
    string.byte

local math = math
local random, floor, round, abs, atan, cos, sin, rad = 
    math.random,
    math.floor,
    math.round,
    math.abs,
    math.atan,
    math.cos,
    math.sin,
    math.rad

local tostring, tonumber = tostring, tonumber

local InstanceNew = Instance.new
local CFrameNew = CFrame.new
local Vector3New = Vector3.new

local CalledCFrameNew = CFrameNew();
local Inverse = CalledCFrameNew.Inverse
local toObjectSpace = CalledCFrameNew.toObjectSpace
local components = CalledCFrameNew.components

local Connection = game.Loaded
local CWait = Connection.Wait
local CConnect = Connection.Connect
local CalledConnection = CConnect(Connection, function() end);
local Disconnect = CalledConnection.Disconnect

local __H = InstanceNew("Humanoid");
local UnequipTools = __H.UnequipTools
local ChangeState = __H.ChangeState
local SetStateEnabled = __H.SetStateEnabled
local GetState = __H.GetState
local GetAccessories = __H.GetAccessories
local MoveTo = __H.MoveTo

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer.GetMouse(LocalPlayer);