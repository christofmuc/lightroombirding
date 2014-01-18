local LrPathUtils = import 'LrPathUtils'

local properties = import 'LrPrefs'.prefsForPlugin()
properties.exportFileName = "new_ebird_sightings.csv"
properties.exportAlreadyExported = "No"
properties.markAsExported = "Yes"
properties.stateAndCountryCodeTable = LrPathUtils.child (_PLUGIN.path, "State_Country_Codes_10_Nov_2011.csv")
