-- http://www.johnrellis.com/lightroom/debugging-toolkit.htm
local Require = require 'Require'.reload()
local Debug = require'Debug'.init()
require'strict'

local LrApplication = import'LrApplication'
local LrTasks = import'LrTasks'
local LrDate = import'LrDate'

require'photogenityUtil'
require'PluginInit'

--
-- Required to find something in the result of getRawMetadata("customMetadata")
--

local function findMeta(metadata, key)
    for key2, value in pairs(metadata) do
        if value['id'] == key then
            return value['value']
        end
    end
    return nil
end

-- http://www.lua.org/pil/20.4.html
local function fromCSV(s)
    s = s .. ',' -- ending comma
    local t = {} -- table to collect fields
    local fieldstart = 1
    repeat
        -- next field is quoted? (start with `"'?)
        if string.find(s, '^"', fieldstart) then
            local a, c
            local i = fieldstart
            repeat
                -- find closing quote
                a, i, c = string.find(s, '"("?)', i + 1)
                until c ~= '"' -- quote not followed by quote?
            if not i then error('unmatched "') end
            local f = string.sub(s, fieldstart + 1, i - 1)
            table.insert(t, (string.gsub(f, '""', '"')))
            fieldstart = string.find(s, ',', i) + 1
        else -- unquoted; find next comma
            local nexti = string.find(s, ',', fieldstart)
            table.insert(t, string.sub(s, fieldstart, nexti - 1))
            fieldstart = nexti + 1
        end
        until fieldstart > string.len(s)
    return t
end

--
-- These functions are used to read in the eBird table of country and state codes that need to be used by the export
--

local stateMap = {}
local countryMap = {}
local allowedCodes = {}

local function readStateAndCountryCodes()
    local file = assert(io.open("g:/photogenity/home/LightroomBirdingPlugin/State_Country_Codes_10_Nov_2011.csv", "r"))
    for line in file:lines() do
        local table = fromCSV(line)
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

local function isempty(s)
    return s == nil or s == ''
end

local function writeIfNotNil(file, value, default)
    if not isempty(value) then
        file:write(value .. ",")
    else
        if not isempty(default) then
            file:write(default .. ",")
        else
            file:write(",")
        end
    end
end

local exportToEbirdLibraryItem = {}
function exportToEbirdLibraryItem.export()
    LrTasks.startAsyncTask(Debug.showErrors(function(context)
        local catalog = LrApplication.activeCatalog()
        local selected = catalog:getTargetPhotos()

        readStateAndCountryCodes()

        local file = assert(io.open("c:/users/christof/exportToEBird.csv", "w"))

        for key, photo in pairs(selected) do
            local metadata = photo:getRawMetadata('customMetadata')

            -- Export our observation in eBird Record Format, see
            -- http://help.ebird.org/customer/portal/articles/973915-uploading-data-to-ebird#ebird-record-format-specifications

            -- Common Name
            writeIfNotNil(file, findMeta(metadata, 'commonName'), " ")

            local scientificName = findMeta(metadata, 'scientificName')
            if not isempty(scientificName) then
                local name = photogenityUtil.split(scientificName, " ", nil)
                -- Genus
                writeIfNotNil(file, name[1], " ")
                -- Species
                writeIfNotNil(file, name[2], " ")
            end

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

            -- State and Country have to match specific codes
            local stateFromMeta = photo:getFormattedMetadata('stateProvince')
            local countryFromMeta = photo:getFormattedMetadata('country')
            local state
            if stateMap[countryFromMeta] then
                state = stateMap[countryFromMeta][stateFromMeta]
            end
            writeIfNotNil(file, state, " ")

            -- Country
            local countryCode
            local countryCodeFromMeta = photo:getFormattedMetadata('isoCountryCode')
            if not isempty(countryCodeFromMeta) then
                if allowedCodes[countryCodeFromMeta] == nil then
                    logger:warn("Country code " .. countryCodeFromMeta .. " of photo " .. photo:getFormattedMetadata("fileName") .. " is not in the list of all country codes, using it anyway")
                end
                countryCode = countryCodeFromMeta
            elseif not isempty(countryFromMeta) then
                if countryMap[countryFromMeta] == nil then
                    logger:warn("Country " .. countryFromMeta .. " of photo " .. photo:getFormattedMetadata("fileName") .. " is not in the list of all countries, can't supply code")
                else
                    countryCode = countryMap[countryFromMeta]
                end
            end
            writeIfNotNil(file, countryCode, " ")

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
