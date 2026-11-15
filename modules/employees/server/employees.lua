Employees = {}

local function getTargetPlayer(cid)
    if Lib47.Framework == 'qbx' then
        return exports.qbx_core:GetPlayerByCitizenId(cid) or exports.qbx_core:GetOfflinePlayer(cid)
    elseif Lib47.Framework == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore.Functions.GetPlayerByCitizenId(cid) or QBCore.Functions.GetOfflinePlayerByCitizenId(cid)
    end
    return nil
end

function Employees.GetList(groupName, groupType)
    local list = {}
    local jobs = Lib47.GetJobs() or {}
    local jobData = jobs[groupName]

    if Lib47.Framework == 'esx' then
        local rows = MySQL.query.await('SELECT identifier, firstname, lastname, job_grade FROM users WHERE job = ?', { groupName })
        for _, r in ipairs(rows or {}) do
            local onlineSrc = Lib47.GetSourceFromIdentifier(r.identifier)
            local gradeNum = tonumber(r.job_grade) or 0
            local gradeInfo = nil
            if jobData and jobData.grades then
                for k, g in pairs(jobData.grades) do
                    if (tonumber(g.grade) or tonumber(k)) == gradeNum then
                        gradeInfo = g
                        break
                    end
                end
            end

            table.insert(list, {
                cid = r.identifier,
                name = r.firstname .. ' ' .. r.lastname,
                grade = gradeNum,
                gradeLabel = gradeInfo and (gradeInfo.label or gradeInfo.name) or ('Rank ' .. gradeNum),
                isOnline = onlineSrc ~= nil and onlineSrc > 0,
                source = onlineSrc or nil,
            })
        end
    else
        local column = groupType == 'gang' and 'gang' or 'job'
        local rows = MySQL.query.await(('SELECT citizenid, charinfo, %s FROM players WHERE %s LIKE ?'):format(column, column), { '%' .. groupName .. '%' })
        for _, r in ipairs(rows or {}) do
            local charinfo = type(r.charinfo) == 'string' and json.decode(r.charinfo) or r.charinfo
            local roleData = type(r[column]) == 'string' and json.decode(r[column]) or r[column]

            if roleData and roleData.name == groupName then
                local onlineSrc = Lib47.GetSourceFromIdentifier(r.citizenid)
                table.insert(list, {
                    cid = r.citizenid,
                    name = charinfo.firstname .. ' ' .. charinfo.lastname,
                    grade = roleData.grade.level,
                    gradeLabel = roleData.grade.name,
                    isOnline = onlineSrc ~= nil and onlineSrc > 0,
                    source = onlineSrc or nil,
                })
            end
        end
    end

    table.sort(list, function(a, b) return a.grade > b.grade end)
    return list
end

function Employees.UpdateGrade(source, targetCid, groupName, groupType, newGrade)
    newGrade = tonumber(newGrade)
    if not newGrade then return false, _U('invalid_amount') end

    if not Permissions.IsBoss(source, groupName, groupType) then
        return false, _U('no_permission')
    end

    local bossGrade = Permissions.GetGradeLevel(source, groupName, groupType)
    if newGrade >= bossGrade then
        return false, _U('cannot_promote_higher')
    end

    if Lib47.Framework == 'esx' then
        local onlineSrc = Lib47.GetSourceFromIdentifier(targetCid)
        if onlineSrc and onlineSrc > 0 then
            Lib47.SetJob(onlineSrc, groupName, newGrade)
        else
            MySQL.update.await('UPDATE users SET job_grade = ? WHERE identifier = ? AND job = ?', { newGrade, targetCid, groupName })
        end
    else
        local target = getTargetPlayer(targetCid)
        if target then
            if groupType == 'gang' then
                target.Functions.SetGang(groupName, newGrade)
            else
                target.Functions.SetJob(groupName, newGrade)
            end
            target.Functions.Save()
        end
    end

    SendDiscordLog('Rank Update', string.format('%s updated rank of %s to %s in %s', Lib47.GetCharacterName(source), targetCid, newGrade, groupName), 3447003)
    return true, _U('promoted_success', targetCid)
end

function Employees.Fire(source, targetCid, groupName, groupType)
    if not Permissions.IsBoss(source, groupName, groupType) then
        return false, _U('no_permission')
    end

    if targetCid == Lib47.GetIdentifier(source) then
        return false, _U('cannot_fire_self')
    end

    local onlineSrc = Lib47.GetSourceFromIdentifier(targetCid)

    if Lib47.Framework == 'esx' then
        if onlineSrc and onlineSrc > 0 then
            if Permissions.GetGradeLevel(onlineSrc, groupName, groupType) >= Permissions.GetGradeLevel(source, groupName, groupType) then
                return false, _U('cannot_fire_higher')
            end
            Lib47.SetJob(onlineSrc, 'unemployed', 0)
        else
            MySQL.update.await('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ? AND job = ?', { 'unemployed', 0, targetCid, groupName })
        end
    else
        local target = getTargetPlayer(targetCid)
        if target then
            local currentGrade = groupType == 'gang' and target.PlayerData.gang.grade.level or target.PlayerData.job.grade.level
            if currentGrade >= Permissions.GetGradeLevel(source, groupName, groupType) then
                return false, _U('cannot_fire_higher')
            end
            if groupType == 'gang' then
                target.Functions.SetGang('none', 0)
            else
                target.Functions.SetJob('unemployed', 0)
            end
            target.Functions.Save()
        end
    end

    if GetResourceState('ak47_multijob') == 'started' then
        if onlineSrc and onlineSrc > 0 then
            exports['ak47_multijob']:RemoveJob(source, groupName)
        else

        end
    end

    SendDiscordLog('Employee Dismissed', string.format('%s fired %s from %s', Lib47.GetCharacterName(source), targetCid, groupName), 16711680)
    return true, _U('fired_success')
end

function Employees.Hire(source, targetSource, groupName, groupType)
    targetSource = tonumber(targetSource)
    if not targetSource or targetSource <= 0 then return false end

    if not Permissions.IsBoss(source, groupName, groupType) then
        return false, _U('no_permission')
    end

    if groupType == 'gang' then
        Lib47.SetGang(targetSource, groupName, 0)
    else
        Lib47.SetJob(targetSource, groupName, 0)
    end

    local targetName = Lib47.GetCharacterName(targetSource)
    SendDiscordLog('Member Recruited', string.format('%s hired %s into %s', Lib47.GetCharacterName(source), targetName, groupName), 65280)
    return true, _U('hired_success', targetName)
end
