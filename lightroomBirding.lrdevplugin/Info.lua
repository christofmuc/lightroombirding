return {
    VERSION = { display = "20140119" },
    LrSdkVersion = 4.0,
    LrToolkitIdentifier = 'info.alpenglow.lightroomBirding',
    LrPluginName = LOC"$$$/LightroomBirding/PluginName=Lightroom Birding",
    LrPluginInfoUrl = "http://www.alpenglow.info/lightroombirding",
    LrMetadataProvider = 'MetadataDefinitionFile.lua',
    LrMetadataTagsetFactory = 'MetadataTagset.lua',
    LrInitPlugin = 'PluginInit.lua',
    LrPluginInfoProvider = 'PluginInfoProvider.lua',
    LrAlsoUseBuiltInTranslations = true,
    LrExportMenuItems = {
        {
            title = LOC"$$$/LightroomBirding/SpeciesFromKeywords=Determine Species from Keywords",
            file = "lookup.lua",
        },
        {
            title = LOC"$$$/LightroomBirding/ExportToEbird=Export birding info to eBird",
            file = "export.lua",
        },
        {
            title = "Debug",
            file = "DebugScript.lua",
        },
    },
}