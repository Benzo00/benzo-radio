for channel, config in pairs(Config.RestrictedChannels) do
    exports['pma-voice']:addChannelCheck(channel, function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        return config[xPlayer.job.name]
    end)
end


if Config.Item then
exports('radio', function(event, item, inventory)
    if event == 'usingItem' then
        TriggerClientEvent('benzo-radio:use', inventory.id)
        return
     end
  end)
end


                                                                                          

 
