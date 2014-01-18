-- http://www.johnrellis.com/lightroom/debugging-toolkit.htm
local Require = require'Require'.reload()
local Debug = require'Debug'.init()
require'strict'

-- Required for the export function
local LrApplication = import'LrApplication'
local LrTasks = import'LrTasks'
local LrDate = import'LrDate'

-- Required for the UI
local LrBinding = import"LrBinding"
local LrDialogs = import"LrDialogs"
local LrFunctionContext = import"LrFunctionContext"
local LrView = import"LrView"

local pluginPrefs = import'LrPrefs'.prefsForPlugin()

function getListOfKeywords()
    LrTasks.startAsyncTask(Debug.showErrors(function(context)
        local catalog = LrApplication.activeCatalog()
        local toplevel = catalog:getKeywords()

        local alltoplevel = {}
        local n = 1
        for key, keyword in pairs(toplevel) do
            alltoplevel[n] = keyword:getName()
            n = n + 1
        end
        selectKeywordDialog(alltoplevel)
    end))
end

function selectKeywordDialog(all_keywords)
    LrFunctionContext.callWithContext('selectKeywordDialog', function(context)
        local factory = LrView.osFactory()
        local dialogPrefs = LrBinding.makePropertyTable(context)
        dialogPrefs.speciesParentKeyword = pluginPrefs.speciesParentKeyword
        local dialogUI = factory:column{
            spacing = factory:control_spacing(),
            bind_to_object = dialogPrefs,
            factory:edit_field{
                value = LrView.bind('speciesParentKeyword'),
                completion = all_keywords,
                auto_completion= true,
            },
        }
        local result = LrDialogs.presentModalDialog({
            title = LOC"$$$/LightroomBirding/SelectKeyword=Enter bird species hierarchy keyword",
            contents = dialogUI,
            actionVerb = "Select",
        })
        if result == 'ok' then
            pluginPrefs.speciesParentKeyword = dialogPrefs.speciesParentKeyword
        end
    end)
end