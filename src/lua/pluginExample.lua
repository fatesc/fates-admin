--[[
    demo plugin
]]

return {
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
            ["Func"] = function(Caller, Args, Tbl)
                Tbl[1] = false
                Tbl[1] = not Tbl[1]
                local Command = LoadCommand("loopjump");
                local Humanoid = GetHumanoid();
                coroutine.wrap(function()
                    while (Command.CmdExtra[1] and Humanoid and Humanoid.Health >= 0) do
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
                LoadCommand("loopjump").CmdExtra[1] = false
                return "loopjump disabled"
            end
        }
    }
}
