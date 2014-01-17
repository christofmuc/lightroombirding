-- http://www.johnrellis.com/lightroom/debugging-toolkit.htm
local Require = require 'Require'.reload()
local Debug = require'Debug'.init()
require'strict'

local LrApplication = import'LrApplication'
local LrTasks = import'LrTasks'
local LrDate = import'LrDate'

require'alpenglowUtil'
require'PluginInit'

local lookupSpeciesLibraryItem = {}
function lookupSpeciesLibraryItem.lookup()
    LrTasks.startAsyncTask(Debug.showErrors(function(context)
        for key, photo in pairs(selected) do
            local metadata = photo:getRawMetadata('customMetadata')
        end
    end))
end

lookupSpeciesLibraryItem.lookup()