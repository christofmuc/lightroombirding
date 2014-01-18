local LrPathUtils = import 'LrPathUtils'

local properties = import 'LrPrefs'.prefsForPlugin()

function initIfEmpty(propName, default)
    if properties[propName] == nil then
        properties[propName] = default
    end
end

initIfEmpty("exportFileName", "new_ebird_sightings.csv")
initIfEmpty("exportAlreadyExported", "No")
initIfEmpty("markAsExported", "Yes")
initIfEmpty("stateAndCountryCodeTable", LrPathUtils.child (_PLUGIN.path, "State_Country_Codes_10_Nov_2011.csv"))
initIfEmpty("lastDirectory", _PLUGIN.path)
initIfEmpty("speciesParentKeyword", "Birds")
