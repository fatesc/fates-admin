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
    Function declerations
]]
function includes(table, whatisin)
    return table[whatisin] ~= nil
end


LoadPlugin = function (plugin)
    if not includes(config.disabledplugins,plugin.Name) then
        if debug then
            Utils.Notify("Plugin loading",string.format("Plugin %s is being loaded.",plugin.Name))
        end
        local ss,rr = pcall(function ()
            if plugin.init ~= nil then
                plugin.init();
            elseif debug then
                Utils.Notify("No init in plugin",string.format("Plugin %s has no init. Skipping.",plugin.Name))
            end
            if plugin.Commands ~= nil then
                for ii,vv in pairs(plugin.Commands) do
                    local com = vv
                    AddCommand(com.Name,com.Aliases,com.Description,com.Call)

                    local Clone = Command:Clone()

                    Utils.Hover(Clone, "BackgroundColor3");
                    Utils.ToolTip(Clone, com.Name .. "\n" .. com.Description);
                    Clone.CommandText.RichText = true
                    Clone.CommandText.Text = ("%s %s %s"):format(com.Name, next(com.Aliases) and ("(%s)"):format(table.concat(com.Aliases, ", ")) or "", Utils.TextFont("[PLUGIN]", {77, 255, 255}))
                    Clone.Name = com.Name
                    Clone.Visible = true
                    Clone.Parent = Commands.Frame.List
                end
            elseif debug then
                Utils.Notify("No commands in plugin",string.format("Plugin %s has no commands. Skipping.",plugin.Name))
            end
        end)
        if not ss then
            if debug then
                math.randomseed(os.time())
                local a = math.random(999)
                Utils.Notify("Error loading plugin",string.format("Plugin %s errored on load, saving log as fate_plugincrash_%s.txt",plugin.Name,a))
                writefile("fate_plugincrash_"..a..".txt",rr)
            end
        end
    elseif debug then
        Utils.Notify("Plugin not loaded.",string.format("Plugin %s was not loaded as it is on the disabled list.",plugin.Name))
    end
end

if config.pluginsenabled then
    for i, v in pairs(listfiles("fates_plugins")) do
        local file = v
        LoadPlugin(loadstring(readfile(file)))
    end
elseif debug then
    Utils.Notify("Plugins disabled.","You have disabled all plugins.")
end

getfenv().LoadFatesPlugin = LoadPlugin
