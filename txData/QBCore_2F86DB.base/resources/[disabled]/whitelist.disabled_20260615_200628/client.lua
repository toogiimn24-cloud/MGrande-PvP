AddEventHandler('onClientGameTypeStart', function()
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {"[Whitelist]", "✅ Та whitelist-д байна. Тавтай морил!"}
    })
end)