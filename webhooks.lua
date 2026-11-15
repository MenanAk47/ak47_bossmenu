-- ====================================================================
-- Ak47 Boss Management - Discord Webhook Logging
-- ====================================================================

Webhooks = {
    enabled = false,
    url = '',
    botName = 'AK47 Boss Management',
    avatar = 'https://i.imgur.com/8Q9j9sZ.png',
}

function SendDiscordLog(title, description, color)
    if not Webhooks.enabled or Webhooks.url == '' or Webhooks.url == 'YOUR_WEBHOOK_URL_HERE' then return end

    PerformHttpRequest(Webhooks.url, function() end, 'POST', json.encode({
        username = Webhooks.botName,
        avatar_url = Webhooks.avatar,
        embeds = {{
            title = title,
            description = description,
            color = color or 3447003,
            footer = { text = 'AK47 Boss Management • ' .. os.date('%Y-%m-%d %H:%M:%S'), icon_url = Webhooks.avatar },
            author = { name = Webhooks.botName, icon_url = Webhooks.avatar },
        }}
    }), { ['Content-Type'] = 'application/json' })
end
