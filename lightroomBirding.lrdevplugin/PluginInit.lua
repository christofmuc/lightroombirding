local LrLogger = import'LrLogger'

-- Define myLogger globally
logger = LrLogger('g:/photogenity/home/LightroomBirdingPlugin/lightroomBirding.log') -- the log file name.
logger:enable("logfile")

local properties = import 'LrPrefs'.prefsForPlugin()
properties.exportFileName = "new_ebird_sightings.csv"
properties.exportAlreadyExported = "No"
properties.markAsExported = "Yes"
