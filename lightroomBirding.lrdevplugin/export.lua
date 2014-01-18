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

require'alpenglowUtil'

--
-- Required to find something in the result of getRawMetadata("customMetadata")
--

--
-- These functions are used to read in the eBird table of country and state codes that need to be used by the export
--

local stateMap = {}
local countryMap = {}
local allowedCodes = {}

local function readStateAndCountryCodes()
    local file = assert(io.open(pluginPrefs.stateAndCountryCodeTable, "r"))
    for line in file:lines() do
        local table = util.fromCSV(line)
        if table[4] == "State" then
            if not stateMap[table[3]] then
                stateMap[table[3]] = {}
            end
            stateMap[table[3]][table[2]] = table[1]

            if table[5] ~= nil then
                -- Adding potential 5th column with alternate names
                stateMap[table[3]][table[5]] = table[1]
            end

        elseif table[4] == "Country" then
            countryMap[table[3]] = table[1]
            allowedCodes[table[1]] = true
        end
    end
    file:close()
end

--
-- Main module - exportToEbird
--

local exportToEbirdLibraryItem = {}
function exportToEbirdLibraryItem.export(exportedFileName, exportAlreadyExported, markAsExported)
    LrTasks.startAsyncTask(Debug.showErrors(function(context)
        local catalog = LrApplication.activeCatalog()
        local selected = catalog:getTargetPhotos()
        local totalExportedItems = 0

        readStateAndCountryCodes()

        local file = assert(io.open(exportedFileName, "w"))

        for key, photo in pairs(selected) do
            local metadata = photo:getRawMetadata('customMetadata')

            -- Check if it was already exported, and in eventually skip it
            if exportAlreadyExported or util.findMeta(metadata, 'wasExported') == nil then

                -- Export our observation in eBird Record Format, see
                -- http://help.ebird.org/customer/portal/articles/973915-uploading-data-to-ebird#ebird-record-format-specifications

                -- Common Name
                util.writeIfNotNil(file, util.findMeta(metadata, 'commonName'), " ")

                local scientificName = util.findMeta(metadata, 'scientificName')
                if not util.isempty(scientificName) then
                    local name = util.split(scientificName, " ", nil)
                    -- Genus
                    util.writeIfNotNil(file, name[1], " ")
                    -- Species
                    util.writeIfNotNil(file, name[2], " ")
                end

                -- Species Count
                util.writeIfNotNil(file, util.findMeta(metadata, 'speciesCount'), "X")

                -- Species Comments
                util.writeIfNotNil(file, util.findMeta(metadata, 'speciesComments'), " ")

                -- Location Name
                local locName = photo:getFormattedMetadata('location')
                if util.isempty(locName) then
                    locName = photo:getFormattedMetadata('city')
                end
                if util.isempty(locName) then
                    locName = photo:getFormattedMetadata('stateProvince')
                end
                if util.isempty(locName) then
                    locName = photo:getFormattedMetadata('country')
                end
                util.writeIfNotNil(file, locName, "not specified")


                -- Latitude and Longitude
                local gps = photo:getRawMetadata('gps')
                if gps ~= nil then
                    util.writeIfNotNil(file, gps.latitude, " ")
                    util.writeIfNotNil(file, gps.longitude, " ")
                else
                    file:write(" , ,")
                end

                -- Observation Date
                local dateTime = photo:getRawMetadata('dateTime')
                util.writeIfNotNil(file, LrDate.timeToUserFormat(dateTime, '%m/%d/%Y'), " ")

                -- Observation Start Time
                util.writeIfNotNil(file, util.findMeta(metadata, 'startTime'), " ")

                -- State and Country have to match specific codes
                local stateFromMeta = photo:getFormattedMetadata('stateProvince')
                local countryFromMeta = photo:getFormattedMetadata('country')
                local state
                if stateMap[countryFromMeta] then
                    state = stateMap[countryFromMeta][stateFromMeta]
                end
                util.writeIfNotNil(file, state, " ")

                -- Country
                local countryCode
                local countryCodeFromMeta = photo:getFormattedMetadata('isoCountryCode')
                if not util.isempty(countryCodeFromMeta) then
                    if allowedCodes[countryCodeFromMeta] == nil then
                        Debug.logn("Country code " .. countryCodeFromMeta .. " of photo " .. photo:getFormattedMetadata("fileName") .. " is not in the list of all country codes, using it anyway")
                    end
                    countryCode = countryCodeFromMeta
                elseif not util.isempty(countryFromMeta) then
                    if countryMap[countryFromMeta] == nil then
                        Debug.logn("Country " .. countryFromMeta .. " of photo " .. photo:getFormattedMetadata("fileName") .. " is not in the list of all countries, can't supply code")
                    else
                        countryCode = countryMap[countryFromMeta]
                    end
                end
                util.writeIfNotNil(file, countryCode, " ")

                -- Protocol
                util.writeIfNotNil(file, util.findMeta(metadata, 'protocol'), "Casual")

                -- Number of Observers
                util.writeIfNotNil(file, util.findMeta(metadata, 'numberOfObservers'), " ")

                -- Duration
                util.writeIfNotNil(file, util.findMeta(metadata, 'duration'), " ")

                -- All Observations Reported?
                util.writeIfNotNil(file, util.findMeta(metadata, 'allObservations'), "N")

                -- Distance Covered
                util.writeIfNotNil(file, util.findMeta(metadata, 'distance'), " ")

                -- Area Covered
                util.writeIfNotNil(file, util.findMeta(metadata, 'area'), " ")

                -- Checklist Comments
                local comment = util.findMeta(metadata, 'comments')
                if comment ~= nil then
                    file:write(comment)
                end

                file:write("\n")

                totalExportedItems = totalExportedItems + 1

                if markAsExported then
                    -- Mark this bird as exported
                    catalog:withWriteAccessDo("Mark birds as exported", Debug.showErrors(function(context)
                        photo:setPropertyForPlugin(_PLUGIN, "wasExported", "Y")
                    end))
                end
            end
        end

        file:close()
        LrDialogs.message("Birding information exported for " .. totalExportedItems .. " sightings")
    end))
end

function exportToEbirdLibraryItem.openDialog()
    LrFunctionContext.callWithContext('exportToEbirdDialog', function(context)
        local factory = LrView.osFactory()
        local dialogPrefs = LrBinding.makePropertyTable(context)
        dialogPrefs.exportFileName = pluginPrefs.exportFileName
        dialogPrefs.exportAlreadyExported = pluginPrefs.exportAlreadyExported
        dialogPrefs.markAsExported = pluginPrefs.markAsExported
        local dialogUI = factory:column{
            spacing = factory:control_spacing(),
            bind_to_object = dialogPrefs,
            factory:column{
                spacing = factory:label_spacing(),
                factory:static_text{
                    title = "Export file name"
                },
                factory:row{
                    factory:edit_field{
                        value = LrView.bind('exportFileName'),
                        wraps = false,
                        width_in_chars = 40,
                    },
                    factory:push_button{
                        title = "Browse",
                        action = function()
                            local saveTo = LrDialogs.runSavePanel({
                                title = "Select folder and enter file name to create",
                                requiredFileType = "csv",
                                canCreateDirectories = true
                            })
                            dialogPrefs.exportFileName = saveTo
                        end
                    }
                }
            },
            factory:checkbox{
                title = "Anyway export items marked as already being on eBird",
                value = LrView.bind('exportAlreadyExported'),
                checked_value = 'Yes',
                unchecked_value = 'No',
            },
            factory:checkbox{
                title = "Mark items exported as being on eBird in the catalog",
                value = LrView.bind('markAsExported'),
                checked_value = 'Yes',
                unchecked_value = 'No',
            },
        }
        local result = LrDialogs.presentModalDialog({
            title = LOC"$$$/LightroomBirding/ExportToEbird=Export birding info to eBird",
            contents = dialogUI,
            actionVerb = "Export",
        })
        if result == 'ok' then
            -- Persist choices
            pluginPrefs.exportFileName = dialogPrefs.exportFileName
            pluginPrefs.exportAlreadyExported = dialogPrefs.exportAlreadyExported
            pluginPrefs.markAsExported = dialogPrefs.markAsExported

            -- Perform action
            exportToEbirdLibraryItem.export(dialogPrefs.exportFileName,
                dialogPrefs.exportAlreadyExported == "Yes",
                dialogPrefs.markAsExported == "Yes")
        end
    end)
end

exportToEbirdLibraryItem.openDialog()
