-- http://www.johnrellis.com/lightroom/debugging-toolkit.htm
local Require = require 'Require'.path ("../debugscript.lrdevplugin")
local Debug = require 'Debug'.init ()
require 'strict'

local LrApplication = import'LrApplication'
local LrTasks = import'LrTasks'
local LrDate = import'LrDate'

require'photogenityUtil'

local function writeIfNotNil(file, value, default)
    if value ~= nil then
        file:write(value .. ",")
    else
        if default ~= nil then
            file:write(default .. ",")
        else
            file:write(",")
        end
    end
end

local function findMeta(metadata, key)
    for key2, value in pairs(metadata) do
        if value['id'] == key then
            return value['value']
        end
    end
    return nil
end

local exportToEbirdLibraryItem = {}
function exportToEbirdLibraryItem.export()
    LrTasks.startAsyncTask(Debug.showErrors (function(context)
        local catalog = LrApplication.activeCatalog()
        local selected = catalog:getTargetPhotos()

        local file = assert(io.open("c:/users/christof/exportToEBird.csv", "w"))

        for key, photo in pairs(selected) do
            local metadata = photo:getRawMetadata('customMetadata')

            -- Export our observation in eBird Record Format, see
            -- http://help.ebird.org/customer/portal/articles/973915-uploading-data-to-ebird#ebird-record-format-specifications

            -- Common Name
            writeIfNotNil(file, metadata['Common Name'], " ")

            -- Genus
            writeIfNotNil(file, metadata['Genus'], " ")

            -- Species
            writeIfNotNil(file, metadata['Species'], " ")

            -- Species Count
            writeIfNotNil(file, findMeta(metadata, 'speciesCount'), "X")

            -- Species Comments
            writeIfNotNil(file, findMeta(metadata, 'speciesComments'), " ")

            -- Location Name
            writeIfNotNil(file, photo:getFormattedMetadata('location'), " ")

            -- Latitude and Longitude
            local gps = photo:getRawMetadata('gps')
            if gps ~= nil then
                writeIfNotNil(file, gps.latitude, " ")
                writeIfNotNil(file, gps.longitude, " ")
            else
                file:write(" , ,")
            end

            -- Observation Date
            local dateTime = photo:getRawMetadata('dateTime')
            writeIfNotNil(file, LrDate.timeToUserFormat(dateTime, '%m/%d/%Y'), " ")

            -- Observation Start Time
            writeIfNotNil(file, findMeta(metadata, 'startTime'), " ")

            -- State
            writeIfNotNil(file, photo:getFormattedMetadata('stateProvince'), " ")

            -- Country
            writeIfNotNil(file,  photo:getFormattedMetadata('isoCountryCode'), " ")

            -- Protocol
            writeIfNotNil(file, findMeta(metadata, 'protocol'), "Casual")

            -- Number of Observers
            writeIfNotNil(file, findMeta(metadata, 'numberOfObservers'), " ")

            -- Duration
            writeIfNotNil(file, findMeta(metadata, 'duration'), " ")

            -- All Observations Reported?
            writeIfNotNil(file, findMeta(metadata, 'allObservations'), "N")

            -- Distance Covered
            writeIfNotNil(file, findMeta(metadata, 'distance'), " ")

            -- Area Covered
            writeIfNotNil(file, findMeta(metadata, 'area'), " ")

            -- Checklist Comments
            local comment = findMeta(metadata, 'comments')
            if comment ~= nil then
                file:write(comment)
            end

            file:write("\n")
        end

        file:close()
    end))
end

exportToEbirdLibraryItem.export()
