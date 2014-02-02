-- http://www.johnrellis.com/lightroom/debugging-toolkit.htm
local Debug = require'Debug'.init()
require'strict'

--noinspection UnassignedVariableAccess
local LrApplication = import'LrApplication'
--noinspection UnassignedVariableAccess
local LrTasks = import'LrTasks'
--noinspection UnassignedVariableAccess
local LrDialogs = import'LrDialogs'

--noinspection UnassignedVariableAccess
local pluginPrefs = import'LrPrefs'.prefsForPlugin()

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

local doNotShowKey = "OverwriteCommonNameWarning"

local lookupSpeciesLibraryItem = {}
function lookupSpeciesLibraryItem.lookup()
    LrTasks.startAsyncTask(Debug.showErrors(function(context)
        local catalog = LrApplication.activeCatalog()
        local selected = catalog:getTargetPhotos()
        local speciesFound = 0
        local writtenPhotos = 0
        local abort = false

        -- Reset prompt dialog, as this is not supposed to be a global selection
        LrDialogs.resetDoNotShowFlag(doNotShowKey)

        for key, photo in pairs(selected) do
            local keywords = photo:getRawMetadata('keywords')
            local metadata = photo:getRawMetadata('customMetadata')

            -- Find out if this photo has a keyword that is part of our species hierarchy
            local species = {}
            local n = 1
            for key, word in pairs(keywords) do
                if next(word:getChildren()) == nil then
                    -- have found leaf node keyword, is it a bird?
                    if isInBirdNameHierarchy(word) then
                        species[n] = word
                        n = n + 1
                        speciesFound = speciesFound + 1
                    end
                end
            end

            -- If it is, then find out the common and the scientific names of the birds
            local commonNames = {}
            local scientificNames = {}
            for key, s in pairs(species) do
                commonNames[#commonNames + 1] = s:getName()
                local synonyms = s:getSynonyms()
                if not util.isempty(synonyms[1]) then
                    scientificNames[#scientificNames + 1] = synonyms[1]
                end
            end
            local allCommonNames = util.concat(commonNames, ', ')
            local allScientificNames = util.concat(scientificNames, ', ')
            if not util.isempty(allCommonNames) then
                catalog:withWriteAccessDo("LightroomBirding copying species information", Debug.showErrors(function(context)
                    local previousCommonName = util.findMeta(metadata, "commonName")

                    if previousCommonName ~= allCommonNames then
                        local override = "ok"
                        if not util.isempty(previousCommonName) then
                            override = LrDialogs.promptForActionWithDoNotShow{
                                message = "Overwrite '" .. previousCommonName .. "' with '" .. allCommonNames .. "'?",
                                info = "The common name metadata field of file " .. photo:getFormattedMetadata("fileName") .. " has already been assigned a value. Please choose whether you want " ..
                                        " to overwrite the values",
                                actionPrefKey = doNotShowKey,
                                verbBtns = { { label = "Yes", verb = "ok" }, { label = "No", verb = "no" } }
                            }
                            if override == false then
                                abort = true
                                return
                            end
                        end
                        if override == "ok" then
                            local iii
                            --noinspection UnassignedVariableAccess
                            photo:setPropertyForPlugin(_PLUGIN, "commonName", allCommonNames)
                            --noinspection UnassignedVariableAccess
                            photo:setPropertyForPlugin(_PLUGIN, "scientificName", allScientificNames)
                            writtenPhotos = writtenPhotos + 1
                        end
                    end
                end))
            end

            if abort then
                return
            end
        end
        --noinspection UnassignedVariableAccess
        LrDialogs.message("Found " .. speciesFound .. " species in " .. #selected .. " photo(s), updated " .. writtenPhotos .. " photo(s)")
    end))
end

lookupSpeciesLibraryItem.lookup()