-- QBX Management Drop-in Interoperability Layer

exports('RegisterBossMenu', function(data)
    if not data or not data.groupName or not data.coords then return end
    Config.Menus[data.groupName] = {
        label = data.label or (data.groupName:gsub("^%l", string.upper) .. ' Management'),
        type = data.type or 'job',
        coords = data.coords,
        size = data.size or vector3(1.5, 1.5, 2.0),
        rotation = data.rotation or 0.0,
    }
end)

if GetResourceState('ox_lib') ~= 'missing' then
    local lib = exports.ox_lib

    pcall(function()
        lib.callback.register('qbx_management:server:getEmployees', function(source, groupName, groupType)
            groupType = groupType or 'job'
            return Employees.GetList(groupName, groupType)
        end)
    end)
end
