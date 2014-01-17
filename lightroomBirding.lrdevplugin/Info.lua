return {
    LrSdkVersion = 3.0,
    LrToolkitIdentifier = 'info.alpenglow.lightroomBirding',
    LrPluginName = LOC"$$$/LightroomBirding/PluginName=Lightroom Birding",
    LrMetadataProvider = 'MetadataDefinitionFile.lua',
    LrMetadataTagsetFactory = 'MetadataTagset.lua',
    LrInitPlugin = 'PluginInit.lua',
    LrExportMenuItems = {
        {
            title = LOC"$$$/LightroomBirding/SpeciesFromKeywords=Determine Species from Keywords",
            file = "lookup.lua",
        },
        {
            title = LOC"$$$/LightroomBirding/ExportToEbird=Export birding info to eBird",
            file = "export.lua",
        }
    },
}