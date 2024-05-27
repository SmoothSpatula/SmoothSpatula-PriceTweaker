-- Price Tweaker v1.0.1
-- SmoothSpatula

log.info("Successfully loaded ".._ENV["!guid"]..".")

-- ========== Parameters ==========

mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.tomlfuncs then Toml = v end end 
    params = {
        price_tweaker_enabled = true,
        price_factor = 1.0
    }
    params = Toml.config_update(_ENV["!guid"], params) -- Load Save
end)

local isChanged = false

-- ========== ImGui ==========

gui.add_to_menu_bar(function()
    local new_value, clicked = ImGui.Checkbox("Enable Price Tweaker", params['price_tweaker_enabled'])
    if clicked then
        params['price_tweaker_enabled'] = new_value
        Toml.save_cfg(_ENV["!guid"], params)
    end
end)

gui.add_to_menu_bar(function()
    local new_value, isChanged = ImGui.InputFloat("Price factor", params['price_factor'], 0.05, 0.2, "%.2f", 0)
    if isChanged and new_value >= -0.01 then -- due to floating point precision error, checking against 0 does not work
        params['price_factor'] = math.abs(new_value) -- same as above, so it display -0.0
        Toml.save_cfg(_ENV["!guid"], params)
    end
end)

-- ========== Main ==========

-- Change the base price of every interactable by a custom factor
gm.pre_script_hook(gm.constants.interactable_init_cost, function(self, other, result, args)
    if not params['price_tweaker_enabled'] then return end

    args[3].value = args[3].value * params['price_factor']
end)
