-- QBX Management Drop-in Interoperability Layer

if GetResourceState('ox_lib') ~= 'missing' then
    local lib = exports.ox_lib

    pcall(function()
        lib.callback.register('qbx_management:server:getEmployees', function(source, groupName, groupType)
            groupType = groupType or 'job'
            return Employees.GetList(groupName, groupType)
        end)
    end)
end
