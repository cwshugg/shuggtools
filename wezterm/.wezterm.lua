-- Wezterm Configuration File
-- https://wezfurlong.org/wezterm

-- Pull Wezterm API
local wezterm = require "wezterm"

-- Config table (or, in newer versions, use a config builder object)
local config = {}
if wezterm.config_builder then
    config = wezterm.config_builder()
end


------------------------------- Helper Functions -------------------------------
local function str_is_empty(s)
    return s == nil or s == ""
end


--------------------------------- OS Detection ---------------------------------
-- Get OS name and determine the OS type
local os = string.lower(wezterm.target_triple)
local os_is_windows = not str_is_empty(string.match(os, "window"))
local os_is_linux = not str_is_empty(string.match(os, "linux"))
local os_is_mac = (not str_is_empty(string.match(os, "apple"))) or
                  (not str_is_empty(string.match(os, "darwin")))

-- Log results
wezterm.log_info("OS:             ", os)
wezterm.log_info("OS is Windows?  ", os_is_windows)
wezterm.log_info("OS is Linux?    ", os_is_linux)
wezterm.log_info("OS is Mac?      ", os_is_mac)


---------------------------- Windows Configuration -----------------------------
if os_is_windows then
    -- add the command prompt and WSL to the launch menu
    config.launch_menu = {
        {
            label = "Windows Command Prompt",
            args = {"cmd"},
        },
        {
            label = "Windows Subsystem for Linux (WSL)",
            args = {"wsl"}
        }
    }
end

---------------------------- Generic Configuration -----------------------------
-- Visual Bell (disable audible bell)
config.audible_bell = "Disabled"
config.visual_bell = {
    fade_in_function = "EaseIn",
    fade_in_duration_ms = 25,
    fade_out_function = "EaseOut",
    fade_out_duration_ms = 100
}

-- Key Bindings
config.keys = {
    -- TODO
}

-- Mouse Bindings
config.mouse_bindings = {
    -- Make left-click select text (NOT follow hyperlinks)
    {
        event = {Up = {streak = 1, button = "Left"}},
        mods = "NONE",
        action = wezterm.action.CompleteSelection "ClipboardAndPrimarySelection"
    },
    -- Make CTRL + left-click follow hyperlinks
    {
        event = {Up = {streak = 1, button = "Left"}},
        mods = "CTRL",
        action = wezterm.action.OpenLinkAtMouseCursor
    },

    -- Make right-click copy selected text
    {
        event = {Up = {streak = 1, button = "Right"}},
        mods = "NONE",
        action = wezterm.action.CopyTo "ClipboardAndPrimarySelection"
    },
    -- Make DOUBLE right-click paste the selected text immediately
    {
        event = {Up = {streak = 2, button = "Right"}},
        mods = "NONE",
        action = wezterm.action.PasteFrom "PrimarySelection"
    },

    -- Make CTRL + scroll-up increase the font size
    {
        event = {Down = {streak = 1, button = {WheelUp = 1}}},
        mods = "CTRL",
        action = wezterm.action.IncreaseFontSize
    },
    -- Make CTRL + scroll-down decrease the font size
    {
        event = {Down = {streak = 1, button = {WheelDown = 1}}},
        mods = "CTRL",
        action = wezterm.action.DecreaseFontSize
    }
}

------------------------------ Custom Appearance -------------------------------
config.color_schemes = {
    ["Dwarrowdelf"] = {
        -- Foreground/Background defaults
        foreground = "silver",
        background = "black",
    
        -- Cursor
        cursor_fg = "black",        -- text color when cursor is on top of it
        cursor_bg = "silver",       -- cursor background color
        cursor_border = "silver",   -- cursor border color (when window is not selected)

        -- Selected text
        selection_fg = "#FFFFFF",
        selection_bg = "#6C6C6C",

        -- Scrollbar thumb
        scrollbar_thumb = "#FFCD60",

        -- Split line between panes
        split = "#87D7FF",
        
        -- Standard colors
        ansi = {
            "#000000",
            "#900000",
            "#009000",
            "#D09000",
            "#5F87FF",
            "#876FFF",
            "#AFFFFF",
            "#E6E8E9",
        },
        brights = {
            "#343434",
            "#D70000",
            "#00D700",
            "#FFCE60",
            "#5F87FF",
            "#AF00D7",
            "#20FFFF",
            "#FFFFFF"
        },
        
        -- Visual bell
        visual_bell = "#545454"
    }
}
config.color_scheme = "Dwarrowdelf"

-- Fonts
config.font = wezterm.font_with_fallback {
    "JetBrains Mono"
}
config.font_size = 10

-- FINAL LINE - return config object
return config

