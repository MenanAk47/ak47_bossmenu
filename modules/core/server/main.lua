Lib47.IsVersionCompatible('2.1.3')
Lib47.EnsureAnyDependency({'ak47_target', 'ox_target', 'qb-target', 'qtarget'})

Lib47.Callback.Register('ak47_bossmenu:server:getInitialData', function(source, groupName, groupType)
    groupType = groupType or 'job'
    if not Permissions.IsBoss(source, groupName, groupType) then
        return nil
    end

    return {
        groupName = groupName,
        groupType = groupType,
        balance = Society.GetBalance(groupName),
        employees = Employees.GetList(groupName, groupType),
        grades = Grades.GetList(groupName, groupType),
        myGrade = Permissions.GetGradeLevel(source, groupName, groupType),
        myCid = Lib47.GetIdentifier(source),
        enableStash = Config.EnableStash,
        enableWardrobe = Config.EnableWardrobe,
        enableMoneyWash = Config.EnableMoneyWash,
        blackMoney = Config.EnableMoneyWash and MoneyWash.GetPlayerBlackMoney(source) or 0,
    }
end)

Lib47.Callback.Register('ak47_bossmenu:server:washMoney', function(source, groupName, amount)
    local success, message, newBalance = MoneyWash.Wash(source, groupName, amount)
    local blackMoney = Config.EnableMoneyWash and MoneyWash.GetPlayerBlackMoney(source) or 0
    return success, message, newBalance, blackMoney
end)

Lib47.Callback.Register('ak47_bossmenu:server:deposit', function(source, groupName, amount)
    return Society.Deposit(source, groupName, amount)
end)

Lib47.Callback.Register('ak47_bossmenu:server:withdraw', function(source, groupName, amount)
    return Society.Withdraw(source, groupName, amount)
end)

Lib47.Callback.Register('ak47_bossmenu:server:updateGrade', function(source, targetCid, groupName, groupType, newGrade)
    local success, message = Employees.UpdateGrade(source, targetCid, groupName, groupType, newGrade)
    local employees = success and Employees.GetList(groupName, groupType) or nil
    return success, message, employees
end)

Lib47.Callback.Register('ak47_bossmenu:server:fireEmployee', function(source, targetCid, groupName, groupType)
    local success, message = Employees.Fire(source, targetCid, groupName, groupType)
    local employees = success and Employees.GetList(groupName, groupType) or nil
    return success, message, employees
end)

Lib47.Callback.Register('ak47_bossmenu:server:hireEmployee', function(source, targetSource, groupName, groupType)
    local success, message = Employees.Hire(source, targetSource, groupName, groupType)
    local employees = success and Employees.GetList(groupName, groupType) or nil
    return success, message, employees
end)

Lib47.Callback.Register('ak47_bossmenu:server:updateSalary', function(source, groupName, gradeLevel, newSalary)
    return Grades.UpdateSalary(source, groupName, gradeLevel, newSalary)
end)

Lib47.Callback.Register('ak47_bossmenu:server:getNearbyPlayers', function(source)
    local players = {}
    local srcPed = GetPlayerPed(source)
    local srcCoords = GetEntityCoords(srcPed)

    for _, playerId in ipairs(GetPlayers()) do
        local targetId = tonumber(playerId)
        if targetId and targetId ~= source then
            local targetPed = GetPlayerPed(targetId)
            local dist = #(srcCoords - GetEntityCoords(targetPed))
            if dist <= 10.0 then
                table.insert(players, {
                    source = targetId,
                    name = Lib47.GetCharacterName(targetId),
                    cid = Lib47.GetIdentifier(targetId),
                })
            end
        end
    end

    return players
end)
