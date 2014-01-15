return {
    LrSdkVersion = 3.0,
    LrToolkitIdentifier = 'info.alpenglow.lightroomBirding',
    LrPluginName = LOC"$$$/LightroomBirding/PluginName=Lightroom Birding",
    LrMetadataProvider = 'MetadataDefinitionFile.lua',
    LrMetadataTagsetFactory = 'MetadataTagset.lua',
    LrInitPlugin = 'PluginInit.lua',
    --LrLibraryMenuItems = {{ title = 'LOC"$$$/MyMetadataSample/ActionDialog=Photogenic &Weather', file = 'yesterdaysWeather.lua', enabledWhen='photosSelected' }},
    LrExportMenuItems = {
    title = "Export birding info to eBird", -- The display text for the menu item
    file = "export.lua", -- The script that runs when the item is selected
    },
}