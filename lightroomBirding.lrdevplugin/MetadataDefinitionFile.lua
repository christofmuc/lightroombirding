return {
    metadataFieldsForPhotos = {
        {
            id = 'commonName',
            title = LOC"$$$/LightroomBirding/Fields/CommonName=Common Name",
            dataType = 'string',
            searchable = true,
            browsable = true,
            version = 2
        },
        {
            id = 'scientificName',
            title = LOC"$$$/LightroomBirding/Fields/ScientificName=Scientific Name",
            dataType = 'string',
            searchable = true,
            browsable = true,
            version = 2
        },
        {
            id = 'speciesComments',
            title = LOC"$$$/LightroomBirding/Fields/SpeciesComments=Species Comments",
            dataType = 'string',
            searchable = true,
            version = 2
        },
        {
            id = 'speciesCount',
            title = LOC"$$$/LightroomBirding/Fields/SpeciesCount=Species Count",
            dataType = 'string',
            searchable = false
        },
        {
            id = 'startTime',
            title = LOC"$$$/LightroomBirding/Fields/StartTime=Start time (e.g. 14:30 or 2:30 PM)",
            dataType = 'string',
            searchable = false
        },
        {
            id = 'protocol',
            title = LOC"$$$/LightroomBirding/Fields/Protocol=Protocol",
            dataType = 'enum',
            values = {
                { value = nil, title = 'Casual' },
                { value = 'Stationary', title = 'Stationary' },
                { value = 'Traveling', title = 'Traveling' },
                { value = 'Area', title = 'Area' }
            },
            searchable = false,
            version = 2
        },
        {
            id = 'numberOfObservers',
            title = LOC"$$$/LightroomBirding/Fields/NumberOfObservers=Number of observers",
            dataType = 'string',
            searchable = false
        },
        {
            id = 'duration',
            title = LOC"$$$/LightroomBirding/Fields/Duration=Duration (minutes)",
            dataType = 'string',
            searchable = false
        },
        {
            id = 'allObservations',
            title = LOC"$$$/LightroomBirding/Fields/AllObservations=All observations reported?",
            dataType = 'enum',
            values = { { value = nil, title = "No" }, { value = 'Y', title = 'Yes' }},
            searchable = false
        },
        {
            id = 'distance',
            title = LOC"$$$/LightroomBirding/Fields/Distance=Distance covered (miles))",
            dataType = 'string',
            searchable = false
        },
        {
            id = 'area',
            title = LOC"$$$/LightroomBirding/Fields/Area=Area covered (acres)",
            dataType = 'string',
            searchable = false
        },
        {
            id = 'comments',
            title = LOC"$$$/LightroomBirding/Fields/Comments=Checklist comments",
            dataType = 'string',
            searchable = true,
            version = 2
        },
    },
schemaVersion = 1,
}
