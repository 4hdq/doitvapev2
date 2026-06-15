local cloneref = cloneref or function(ref: any)
    return ref
end

if isfolder('doitvapev2') then
    delfolder('doitvapev2')
end

cloneref(game:GetService('StarterGui')):SetCore('SendNotification', {
    Title = 'Cat Vape',
    Text = 'Successfully reinstalled Cat Vape, Please rejoin the game to take effect',
    Duration = 20
})