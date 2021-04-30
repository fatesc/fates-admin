if (isfolder and isfolder("fates-admin") and isfolder("fates-admin/plugins") and isfolder("fates-admin/chatlogs")) then
    local Plugins = table.map(table.filter(listfiles("fates-admin/plugins"), function(i, v)
        return v:split(".")[#v:split(".")]:lower() == "lua"
    end), function(i, v)
        return {v:split("\\")[2], loadfile(v)}
    end)

    for i, v in next, Plugins do
        local Executed, Cmd, Error = pcall(v[2]);
        if (Executed and not Err) then
            local Executed, Err = pcall(function()
                AddCommand(Cmd.Name, Cmd.Aliases, Cmd.Description .. ", Plugin made by: " .. Cmd.Author, Cmd.Requirements, Cmd.Func);

                local Clone = Command:Clone()

                Utils.Hover(Clone, "BackgroundColor3");
                Utils.ToolTip(Clone, Cmd.Name .. "\n" .. Cmd.Description);
                Clone.CommandText.Text = Cmd.Name .. (#Cmd.Aliases > 0 and " (" ..table.concat(Cmd.Aliases, ", ") .. ")" or "");
                Clone.Name = Cmd.Name
                Clone.Visible = true
                Clone.Parent = Commands.Frame.List
            end);
            if (Err) then
                warn(("Error in plugin %s: %s"):format(v[1], Err));
            end
        else
            print(Executed)
            print(Err)
            warn(("Error in plugin %s: %s"):format(v[1], Err));
        end
    end
elseif (isfolder) then
    WriteConfig();
end