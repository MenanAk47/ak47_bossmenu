Permissions = {}

function Permissions.IsBoss(source, groupName, groupType)
    if groupType == 'gang' then
        local gang = Lib47.GetGang(source)
        if not gang or gang.name ~= groupName then return false end
        return gang.isboss == true
    end

    local job = Lib47.GetJob(source)
    if not job or job.name ~= groupName then return false end

    if job.isboss then return true end

    if Lib47.Framework == 'esx' then
        local xPlayer = Lib47.GetPlayer(source)
        return xPlayer and Config.BossGrades[xPlayer.job.grade_name] == true or false
    end

    return false
end

function Permissions.GetGradeLevel(source, groupName, groupType)
    if groupType == 'gang' then
        local gang = Lib47.GetGang(source)
        return (gang and gang.name == groupName) and gang.grade.level or -1
    end

    local job = Lib47.GetJob(source)
    return (job and job.name == groupName) and job.grade.level or -1
end
