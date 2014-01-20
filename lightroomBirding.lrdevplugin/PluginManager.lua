-- http://www.johnrellis.com/lightroom/debugging-toolkit.htm
local Require = require'Require'.reload()
local Debug = require'Debug'.init()
require'strict'

local LrView = import"LrView"
local LrHttp = import"LrHttp"
local bind = import"LrBinding"
local LrDialogs = import"LrDialogs"
local LrPathUtils = import'LrPathUtils'

local pluginPrefs = import'LrPrefs'.prefsForPlugin()

require'KeywordSelectionDialog'

PluginManager = {}
function PluginManager.sectionsForTopOfDialog(f, p)
    return {
        {
            title = 'alpenglow.info\'s "Lightroom Birding"',
            bind_to_object = pluginPrefs,
            f:row{
                spacing = f:control_spacing(),
                f:static_text{
                    font = "<system/bold>",
                    title = 'Lightroom Birding',
                    alignment = 'left',
                    fill_horizontal = 1,
                },
                f:push_button{
                    width = 150,
                    title = 'Visit plugin page',
                    enabled = true,
                    action = function()
                        LrHttp.openUrlInBrowser("http://www.alpenglow.info/lightroombirding")
                    end,
                },
            },
            f:static_text{
                title = "- a metadata plugin to record birding observations and export to eBird!",
            },
            f:separator{},
            f:static_text{
                font = "<system/bold>",
                title = "Plugin Settings",
                alignment = "left",
            },
            f:column{
                spacing = f:label_spacing(),
                fill_horizontal = 1,
                f:static_text{
                    title = 'Table of eBird export state and country code mappings: ',
                    alignment = 'left',
                },
                f:row{
                    f:edit_field{
                        value = LrView.bind('stateAndCountryCodeTable'),
                        wraps = false,
                        fill_horizontal = 1,
                    },
                    f:push_button{
                        title = "Browse",
                        action = function()
                            local stateTable = LrDialogs.runOpenPanel({
                                title = "Select CSV file with the state and country codes",
                                requiredFileType = "csv",
                                allowsMultipleSelection = false,
                                canChooseDirectories = false,
                                canCreateDirectories = false,
                                canChooseFiles = true,
                                accessoryView = nil,
                                initialDirectory = pluginPrefs.lastDirectory
                            })
                            if stateTable then
                                pluginPrefs.stateAndCountryCodeTable = stateTable[1]
                                pluginPrefs.lastDirectory = LrPathUtils.parent(stateTable[1])
                            end
                        end
                    },
                    f:push_button{
                        title = "Default",
                        action = function()
                            pluginPrefs.stateAndCountryCodeTable = LrPathUtils.child(_PLUGIN.path, "StateCountryCodes.csv")
                        end
                    }
                },
            },
            f:column{
                spacing = f:label_spacing(),
                fill_horizontal = 1,
                f:static_text{
                    title = 'Select the top level bird species element in your catalog: ',
                    alignment = 'left',
                },
                f:row{
                    f:edit_field{
                        value = LrView.bind('speciesParentKeyword'),
                        wraps = false,
                        fill_horizontal = 1,
                    },
                    f:push_button{
                        title = "Select",
                        action = function()
                            getListOfKeywords()
                        end
                    },
                },
            },
            f:static_text{
                size = "mini",
                title = "Copyright 2014 by Christof Ruch",
            },
        },
    }
end