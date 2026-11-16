-- Drop-in client events and exports for legacy menus

RegisterNetEvent('esx_society:openBossMenu', function(societyName, closeCb, options)
    local jobName = tostring(societyName):gsub('^society_', '')
    OpenBossMenu(jobName, 'job')
end)

exports('openBossMenu', function(societyName)
    local jobName = tostring(societyName):gsub('^society_', '')
    OpenBossMenu(jobName, 'job')
end)

RegisterNetEvent('qb-bossmenu:client:OpenMenu', function()
    local job = Lib47.GetJob()
    if job and job.name then
        OpenBossMenu(job.name, 'job')
    end
end)

RegisterNetEvent('qb-gangmenu:client:OpenMenu', function()
    local gang = Lib47.GetGang()
    if gang and gang.name then
        OpenBossMenu(gang.name, 'gang')
    end
end)

exports('OpenMenu', function()
    local job = Lib47.GetJob()
    if job and job.name then
        OpenBossMenu(job.name, 'job')
    end
end)
