local main = Library.new(
    "Clawr",                       -- change this to your script name
    "rbxassetid://14488863746"     -- replace with your own logo image id
)

repeat task.wait() until game:IsLoaded()

-- ---- TABS ------------------------------------------------------------------
-- main:create_tab( "Tab Name" , "rbxassetid://ICON_ID" )
-- Make as many tabs as you want.  The first one is selected automatically.
local tabMain     = main:create_tab("General",  "rbxassetid://14488863746")
local tabSettings = main:create_tab("Settings", "rbxassetid://13300915301")

-- ---- MODULES ---------------------------------------------------------------
-- tabName:create_module({ ... })
-- title       = what appears on the card header
-- flag        = unique ID (any string, no spaces, never repeat)
-- description = small subtitle under the title
-- section     = "left" or "right"  (which column the card sits in)
-- callback    = function(enabled) ... end   called when toggled on/off
local modCombat = tabMain:create_module({
    title       = "Combat",
    flag        = "modCombat",
    description = "Aim and hit settings",
    section     = "left",
    callback    = function(on) print("Combat:", on) end,
})

-- ---- CHECKBOX --------------------------------------------------------------
-- modName:create_checkbox({ title, flag, callback })
-- callback receives  true  (checked) or  false  (unchecked)
modCombat:create_checkbox({
    title    = "Silent Aim",
    flag     = "silentAim",
    callback = function(v) print("Silent Aim:", v) end,
})

-- ---- SLIDER ----------------------------------------------------------------
-- modName:create_slider({ title, flag, minimum_value, maximum_value, value, round_number, callback })
-- value        = starting position
-- round_number = true for whole numbers, false for one decimal
-- callback receives the current number while dragging
modCombat:create_slider({
    title         = "FOV Size",
    flag          = "fovSize",
    minimum_value = 0,
    maximum_value = 360,
    value         = 90,
    round_number  = true,
    callback      = function(v) print("FOV:", v) end,
})

-- ---- DROPDOWN (single select) ----------------------------------------------
-- modName:create_dropdown({ title, flag, options, maximum_options, callback })
-- options         = list of strings shown in the dropdown
-- maximum_options = rows visible before scrolling (999 = show all)
-- callback receives the selected string
modCombat:create_dropdown({
    title           = "Hit Part",
    flag            = "hitPart",
    options         = { "Head", "Torso", "Random" },
    maximum_options = 999,
    callback        = function(v) print("Hit part:", v) end,
})

-- ---- MULTI DROPDOWN (multi select) -----------------------------------------
-- Same as dropdown but the user can tick multiple items.
-- callback receives a table of all selected strings
modCombat:create_multi_dropdown({
    title           = "Ignored Players",
    flag            = "ignoredPlayers",
    options         = { "Friends", "Teammates", "Admins" },
    maximum_options = 999,
    callback        = function(sel) print("Ignored:", table.concat(sel, ", ")) end,
})

-- ---- BUTTON ----------------------------------------------------------------
-- modName:create_button({ title, callback })
-- callback fires when the button is clicked
modCombat:create_button({
    title    = "Reset Config",
    callback = function()
        print("Reset clicked!")
        main:notify("Reset", "Config has been reset.")
    end,
})

-- ---- Second module (left column, same tab) ---------------------------------
local modVisuals = tabMain:create_module({
    title       = "Visuals",
    flag        = "modVisuals",
    description = "ESP and rendering options",
    section     = "left",
    callback    = function(on) print("Visuals:", on) end,
})
modVisuals:create_checkbox({
    title    = "ESP Enabled",
    flag     = "espEnabled",
    callback = function(v) print("ESP:", v) end,
})
modVisuals:create_slider({
    title         = "ESP Distance",
    flag          = "espDist",
    minimum_value = 0,
    maximum_value = 1000,
    value         = 500,
    round_number  = true,
    callback      = function(v) print("ESP dist:", v) end,
})

-- ---- Right column module ---------------------------------------------------
local modConfig = tabMain:create_module({
    title       = "Notes",
    flag        = "modNotes",
    description = "Save notes for this session",
    section     = "right",
    callback    = function(on) print("Notes:", on) end,
})

-- ---- SEPARATOR -------------------------------------------------------------
-- modName:create_separator({ title })
-- Draws a labelled divider line inside a module to group elements visually
modConfig:create_separator({ title = "Player" })

-- ---- TEXTBOX ---------------------------------------------------------------
-- modName:create_textbox({ flag, placeholder, callback })
-- placeholder = grey hint text when empty
-- callback( text, pressedEnter )  called when the box loses focus
modConfig:create_textbox({
    flag        = "notePlayer",
    placeholder = "Enter player name...",
    callback    = function(text) print("Player note:", text) end,
})
modConfig:create_separator({ title = "Match" })
modConfig:create_textbox({
    flag        = "noteMatch",
    placeholder = "Enter match notes...",
    callback    = function(text) print("Match note:", text) end,
})

-- ---- Settings tab ----------------------------------------------------------
local modUI = tabSettings:create_module({
    title       = "Interface",
    flag        = "modUI",
    description = "UI preferences",
    section     = "left",
    callback    = function(on) print("Interface:", on) end,
})
modUI:create_checkbox({
    title    = "Show Keybind Hints",
    flag     = "keybindHints",
    callback = function(v) print("Hints:", v) end,
})
modUI:create_dropdown({
    title           = "Theme",
    flag            = "uiTheme",
    options         = { "Dark", "Light", "System" },
    maximum_options = 999,
    callback        = function(v) print("Theme:", v) end,
})

-- ---- NOTIFICATION ----------------------------------------------------------
-- main:notify( "Title" , "Subtitle" )
-- Shows a toast in the top-right corner. Auto-dismisses after ~3.5 s.
-- Call it from anywhere — buttons, callbacks, timers, etc.
task.delay(1, function()
    main:notify("Script Loaded", "Clawr is ready. Enjoy!")
end)
