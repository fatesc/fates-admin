--[[
    demo plugin
]]

local ExamplePlugin = {
    ["Name"] = "gamerjuice",
    ["Author"] = "fate",
    ["Init"] = function()
        print("test plugin loaded!"); 
    end,
    ["Commands"] = {
        {
            ["Name"] = "loopjump",
            ["Description"] = "loopjumps your character until you die or unloop",
            ["Requirements"] = {3},
            ["Func"] = function(Caller, Args, CEnv)
                CEnv.Jumping = true
                local Humanoid = GetHumanoid();
                CThread(function()
                    while (CEnv.Jumping and Humanoid and Humanoid.Health >= 0) do
                        Humanoid.Jump = true
                        wait(.1);
                    end
                end)();
                return "now loopjumping"
            end
        },
        {
            ["Name"] = "unloopjump",
            ["Description"] = "Disables loopjump if enabled",
            ["Aliases"] = {"noloopjump"},
            ["Func"] = function()
                GetCommandEnv("loopjump").Jumping = false
                return "loopjump disabled"
            end
        }
    }
}

return ExamplePlugin