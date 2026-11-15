exports('GetSocietyBalance', function(groupName)
    return Society.GetBalance(groupName)
end)

exports('AddSocietyMoney', function(groupName, amount, reason)
    return Lib47.AddSocietyMoney(groupName, amount, reason)
end)

exports('RemoveSocietyMoney', function(groupName, amount, reason)
    return Lib47.RemoveSocietyMoney(groupName, amount, reason)
end)

exports('GetEmployees', function(groupName, groupType)
    return Employees.GetList(groupName, groupType)
end)

exports('IsBoss', function(source, groupName, groupType)
    return Permissions.IsBoss(source, groupName, groupType)
end)
