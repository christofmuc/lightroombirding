-- http://www.johnrellis.com/lightroom/debugging-toolkit.htm
local Debug = require'Debug'.init()
require'strict'

local LrApplication = import'LrApplication'
local LrTasks = import'LrTasks'
local LrDate = import'LrDate'

local pluginPrefs = import 'LrPrefs'.prefsForPlugin()

require'alpenglowUtil'

function isInBirdNameHierarchy(keyword)
    if keyword:getName() == pluginPrefs.speciesParentKeyword then
        return true
    elseif not keyword:getParent() then
        return false
    else
        return isInBirdNameHierarchy(keyword:getParent())
    end
end

local lookupSpeciesLibraryItem = {}
function lookupSpeciesLibraryItem.lookup()
    LrTasks.startAsyncTask(Debug.showErrors(function(context)
        local catalog = LrApplication.activeCatalog()
        local selected = catalog:getTargetPhotos()

        for key, photo in pairs(selected) do
            local keywords = photo:getRawMetadata('keywords')
            -- Find out if this photo has a keyword that is part of our species hierarchy
            local species = {}
            local n = 1
            for key, word in pairs(keywords) do
                if next(word:getChildren()) == nil then
                    -- have found leaf node keyword, is it a bird?
                    if isInBirdNameHierarchy(word) then
                        species[n] = word
                        n = n + 1
                    end
                end
            end

            -- If it is, then find out the common and the scientific names of the birds
            local commonNames = ""
            local scientificNames = ""
            for key, s in pairs(species) do
                catalog:withWriteAccessDo("LightroomBirding copying species information", Debug.showErrors(function(context)
                    photo:setPropertyForPlugin(_PLUGIN, "commonName", s:getName())
                    local synonyms = s:getSynonyms();
                    photo:setPropertyForPlugin(_PLUGIN, "scientificName", synonyms[1] )
                end))
            end
        end
    end))
end

lookupSpeciesLibraryItem.lookup()