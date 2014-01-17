local LrLogger = import'LrLogger'

-- Define myLogger globally
logger = LrLogger('g:/photogenity/home/LightroomBirdingPlugin/lightroomBirding.log') -- the log file name.
logger:enable("logfile")