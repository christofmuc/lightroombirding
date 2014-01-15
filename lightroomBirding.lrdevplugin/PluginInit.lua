local LrLogger = import'LrLogger'

-- Define myLogger globally
logger = LrLogger('lightroomBirding') -- the log file name.
logger:enable("logfile")