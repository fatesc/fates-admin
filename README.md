# fates-admin
a roblox admin script with fe features

## Developers
- [fate#5647](https://github.com/fatesc) (Main Script Developer)
- [Iaying#6564](https://github.com/Iaying6564) (Script Developer)
- [misrepresenting#4917](https://github.com/misrepresenting) (UI Developer)

## Plugin Docs
### (will do later in a seperate file) example plugin:
```lua
return {
    ["Name"] = "hatspin",
    ["Aliases"] = {"hs", "spinhats"},
    ["Description"] = "spins hats you are wearing",
    ["Author"] = "fate",
    ["Requirements"] = {
        function()
            return GetCharacter():FindFirstChildWhichIsA("Accessory");
        end
    },
    ["Func"] = function(Caller, Args)
        local Hats = table.filter(GetHumanoid():GetAccessories(), function(i, v)
            return v.Handle and v:FindFirstChildWhichIsA("Weld", true);
        end);
        if (not next(Hats)) then
            return "you need a hat with a weld for this to work"
        end
        for i, v in next, Hats do
            local Spin = Instance.new("BodyAngularVelocity", v.Handle);
            local BodyPos = Instance.new("BodyPosition", v.Handle);
            v:FindFirstChildWhichIsA("Weld", true):Destroy();
            Spin.MaxTorque = Vector3.new(0, math.huge, 0);
            Spin.AngularVelocity = Vector3.new(0, tonumber(Args[1]) or 20, 0);

            coroutine.wrap(function()
                local Connection = RunService.Heartbeat:Connect(function()
                    BodyPos.Position = GetCharacter().Head.Position
                end)
                AddConnection(Connection);
                GetHumanoid().Died:Wait();
                Connection:Disconnect();
            end)()
        end
        return "Now spinning hats"
    end
}
```