Employees = {}

local QBCore = nil
local function getTargetPlayer(cid)
    if Lib47.Framework == 'qbx' then
        return exports.qbx_core:GetPlayerByCitizenId(cid) or exports.qbx_core:GetOfflinePlayer(cid)
    elseif Lib47.Framework == 'qb' then
        if not QBCore then
            QBCore = exports['qb-core']:GetCoreObject()
        end
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
        local foundIdentifiers = {}

        local multiJobMap = nil
        if GetResourceState('ak47_multijob') == 'started' and groupType ~= 'gang' then
            multiJobMap = {}
            local mjRows = MySQL.query.await('SELECT identifier, grade FROM ak47_multijob WHERE job = ?', { groupName })
            for _, mj in ipairs(mjRows or {}) do
                multiJobMap[mj.identifier] = tonumber(mj.grade) or 0
            end
        end

        for _, r in ipairs(rows or {}) do
            local onlineSrc = Lib47.GetSourceFromIdentifier(r.identifier)
            local isOnline = onlineSrc ~= nil and onlineSrc > 0
            local stillHasJob = true
            local gradeNum = tonumber(r.job_grade) or 0

            if isOnline then
                local pJob = Lib47.GetJob(onlineSrc)
                if multiJobMap then
                    local hasJobInMulti = multiJobMap[r.identifier] ~= nil
                    if not hasJobInMulti and (not pJob or pJob.name ~= groupName) then
                        stillHasJob = false
                    elseif pJob and pJob.name == groupName then
                        gradeNum = tonumber(pJob.grade and (pJob.grade.level or pJob.grade)) or multiJobMap[r.identifier] or gradeNum
                    else
                        gradeNum = multiJobMap[r.identifier] or gradeNum
                    end
                else
                    if not pJob or pJob.name ~= groupName then
                        stillHasJob = false
                        if pJob and pJob.name then
                            local realGrade = tonumber(pJob.grade and (pJob.grade.level or pJob.grade)) or 0
                            MySQL.update('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ? AND job = ?', { pJob.name, realGrade, r.identifier, groupName })
                        end
                    else
                        gradeNum = tonumber(pJob.grade and (pJob.grade.level or pJob.grade)) or gradeNum
                    end
                end
            elseif multiJobMap then
                if multiJobMap[r.identifier] == nil then
                    stillHasJob = false
                    MySQL.update('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ? AND job = ?', { 'unemployed', 0, r.identifier, groupName })
                else
                    gradeNum = multiJobMap[r.identifier]
                end
            end

            if stillHasJob then
                foundIdentifiers[r.identifier] = true
                local gradeInfo = nil
                if jobData and jobData.grades then
                    for k, g in pairs(jobData.grades) do
                        if (tonumber(g.grade) or tonumber(k)) == gradeNum then
                            gradeInfo = g
                            break
                        end
                    end
                end

                local fullName = (r.firstname and r.lastname and (r.firstname .. ' ' .. r.lastname)) or (onlineSrc and Lib47.GetCharacterName(onlineSrc)) or r.identifier

                table.insert(list, {
                    cid = r.identifier,
                    name = fullName,
                    grade = gradeNum,
                    gradeLabel = gradeInfo and (gradeInfo.label or gradeInfo.name) or ('Rank ' .. gradeNum),
                    isOnline = isOnline,
                    source = onlineSrc or nil,
                })
            end
        end

        for _, playerId in ipairs(GetPlayers()) do
            local pId = tonumber(playerId)
            if pId then
                local pJob = Lib47.GetJob(pId)
                local hasJob = false
                local gradeNum = 0
                local pIdentifier = Lib47.GetIdentifier(pId)

                if pJob and pJob.name == groupName then
                    hasJob = true
                    gradeNum = tonumber(pJob.grade and (pJob.grade.level or pJob.grade)) or 0
                elseif multiJobMap and pIdentifier and multiJobMap[pIdentifier] ~= nil then
                    hasJob = true
                    gradeNum = multiJobMap[pIdentifier]
                end

                if hasJob and pIdentifier and not foundIdentifiers[pIdentifier] then
                    foundIdentifiers[pIdentifier] = true
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
                        cid = pIdentifier,
                        name = Lib47.GetCharacterName(pId),
                        grade = gradeNum,
                        gradeLabel = gradeInfo and (gradeInfo.label or gradeInfo.name) or ('Rank ' .. gradeNum),
                        isOnline = true,
                        source = pId,
                    })
                end
            end
        end
    else
        local column = groupType == 'gang' and 'gang' or 'job'
        local rows = MySQL.query.await(('SELECT citizenid, charinfo, %s FROM players WHERE %s LIKE ?'):format(column, column), { '%' .. groupName .. '%' })
        local foundIdentifiers = {}

        for _, r in ipairs(rows or {}) do
            local charinfo = type(r.charinfo) == 'string' and json.decode(r.charinfo) or r.charinfo
            local roleData = type(r[column]) == 'string' and json.decode(r[column]) or r[column]

            if roleData and roleData.name == groupName then
                local onlineSrc = Lib47.GetSourceFromIdentifier(r.citizenid)
                local isOnline = onlineSrc ~= nil and onlineSrc > 0
                local stillHasJob = true
                local gradeNum = roleData.grade and roleData.grade.level or 0
                local gradeLabel = roleData.grade and roleData.grade.name or ('Rank ' .. gradeNum)

                if isOnline then
                    local pRole = groupType == 'gang' and Lib47.GetGang(onlineSrc) or Lib47.GetJob(onlineSrc)
                    if not pRole or pRole.name ~= groupName then
                        stillHasJob = false
                    else
                        gradeNum = tonumber(pRole.grade and (pRole.grade.level or pRole.grade)) or gradeNum
                        gradeLabel = (pRole.grade and pRole.grade.name) or gradeLabel
                    end
                end

                if stillHasJob then
                    foundIdentifiers[r.citizenid] = true
                    table.insert(list, {
                        cid = r.citizenid,
                        name = (charinfo and charinfo.firstname and charinfo.lastname and (charinfo.firstname .. ' ' .. charinfo.lastname)) or r.citizenid,
                        grade = gradeNum,
                        gradeLabel = gradeLabel,
                        isOnline = isOnline,
                        source = onlineSrc or nil,
                    })
                end
            end
        end

        for _, playerId in ipairs(GetPlayers()) do
            local pId = tonumber(playerId)
            if pId then
                local pRole = groupType == 'gang' and Lib47.GetGang(pId) or Lib47.GetJob(pId)
                if pRole and pRole.name == groupName then
                    local pIdentifier = Lib47.GetIdentifier(pId)
                    if pIdentifier and not foundIdentifiers[pIdentifier] then
                        foundIdentifiers[pIdentifier] = true
                        local gradeNum = tonumber(pRole.grade and (pRole.grade.level or pRole.grade)) or 0
                        table.insert(list, {
                            cid = pIdentifier,
                            name = Lib47.GetCharacterName(pId),
                            grade = gradeNum,
                            gradeLabel = (pRole.grade and pRole.grade.name) or ('Rank ' .. gradeNum),
                            isOnline = true,
                            source = pId,
                        })
                    end
                end
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
        end
        MySQL.update.await('UPDATE users SET job_grade = ? WHERE identifier = ? AND job = ?', { newGrade, targetCid, groupName })
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
        end
        MySQL.update.await('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ? AND job = ?', { 'unemployed', 0, targetCid, groupName })
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
            exports['ak47_multijob']:RemoveJob(onlineSrc, groupName)
        else
            exports['ak47_multijob']:RemoveJobOffline(targetCid, groupName)
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

    local targetCid = Lib47.GetIdentifier(targetSource)

    if groupType == 'gang' then
        Lib47.SetGang(targetSource, groupName, 0)
    else
        Lib47.SetJob(targetSource, groupName, 0)
        if Lib47.Framework == 'esx' and targetCid then
            MySQL.update.await('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', { groupName, 0, targetCid })
        end
    end

    if GetResourceState('ak47_multijob') == 'started' and groupType ~= 'gang' then
        exports['ak47_multijob']:AddJob(targetSource, groupName, 0)
    end

    local targetName = Lib47.GetCharacterName(targetSource)
    SendDiscordLog('Member Recruited', string.format('%s hired %s into %s', Lib47.GetCharacterName(source), targetName, groupName), 65280)
    return true, _U('hired_success', targetName)
end
