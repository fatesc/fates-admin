local config
local default = [[
    local conf = {
        ["pluginsenabled"] = true,
        ["plugindebug"] = false,
        ["disabledplugins"] = {
        }
    }
    return conf
]]

if not isfolder("fates_plugins") then
    makefolder("fates_plugins")
    writefile("fates_plugins/fates_plugins.config",default)
end

config = loadfile("fates_plugins/fates_plugins.config")()
local debug = config.plugindebug

--[[
    Function definitions
]]
function includes(table, whatisin)
    return table[whatisin] ~= nil
end

local cmdsfiles = {}

LoadPlugin = function (plugin)
    if not includes(config.disabledplugins,plugin.Name) then
        if not plugin.Name or not plugin.init or not plugin.Commands then
            if debug then
                Utils.Notify(LocalPlayer,"Plugin failed to load",string.format("One of your plugins is missing information."), 2)
            end
            return
        end
        if debug then
            Utils.Notify(LocalPlayer,"Plugin loading",string.format("Plugin %s is being loaded.",plugin.Name), 5)
        end
        local ss,rr = pcall(function ()
            if plugin.init ~= nil then
                plugin.init();
            elseif debug then
                Utils.Notify(LocalPlayer,"No init in plugin",string.format("Plugin %s has no init. Skipping.",plugin.Name),5)
            end
            if plugin.Commands ~= nil then
                for ii,vv in pairs(plugin.Commands) do
                    AddCommand(vv.Name,vv.Aliases,vv.Description,vv.Options,vv.Call)

                    local Clone = Command:Clone()

                    Utils.Hover(Clone, "BackgroundColor3");
                    Utils.ToolTip(Clone, vv.Name .. "\n" .. vv.Description);
                    Clone.CommandText.RichText = true
                    Clone.CommandText.Text = ("%s %s %s"):format(vv.Name, next(vv.Aliases) and ("(%s)"):format(table.concat(vv.Aliases, ", ")) or "", Utils.TextFont("[PLUGIN]", {77, 255, 255}))
                    Clone.Name = vv.Name
                    Clone.Visible = true
                    Clone.Parent = Commands.Frame.List
                end
            elseif debug then
                Utils.Notify(LocalPlayer,"No commands in plugin",string.format("Plugin %s has no commands. Skipping.",plugin.Name),5)
            end
        end)
        if not ss then
            if debug then
                math.randomseed(os.time())
                local a = math.random(999)
                Utils.Notify(LocalPlayer,"Error loading plugin",string.format("Plugin %s errored on load, saving log as fate_plugincrash_%s.txt",plugin.Name,a),5)
                writefile("fate_plugincrash_"..a..".txt",rr)
            end
        end
    elseif debug then
        Utils.Notify(LocalPlayer,"Plugin not loaded.",string.format("Plugin %s was not loaded as it is on the disabled list.",plugin.Name),5)
    end
end

if config.pluginsenabled then
    for i, file in pairs(listfiles("fates_plugins")) do
        LoadPlugin(loadstring(readfile(file))())
    end
elseif debug then
    Utils.Notify(LocalPlayer,"Plugins disabled.","You have disabled all plugins.",5)
end

AddCommand("refreshplugins",{"rfp","refresh","reload"},"Loads all new plugins.",{}, function(caller)
    for i, file in pairs(listfiles("fates_plugins")) do
        LoadPlugin(loadstring(readfile(file))())
    end
end)

Utils.LoadFatesPlugin = LoadPlugin
