Grades = {}

function Grades.GetList(groupName, groupType)
    local list = {}

    if groupType == 'gang' then
        local gangs = Lib47.GetGangList and Lib47.GetGangList() or {}
        local gangData = gangs[groupName]
        if gangData and gangData.grades then
            for gradeLevel, gradeInfo in pairs(gangData.grades) do
                table.insert(list, {
                    grade = tonumber(gradeLevel) or 0,
                    name = gradeInfo.name,
                    label = gradeInfo.name,
                    salary = 0,
                })
            end
        end
    else
        local jobs = Lib47.GetJobs() or {}
        local jobData = jobs[groupName]
        if jobData and jobData.grades then
            for gradeLevel, gradeInfo in pairs(jobData.grades) do
                table.insert(list, {
                    grade = tonumber(gradeLevel) or tonumber(gradeInfo.grade) or 0,
                    name = gradeInfo.name,
                    label = gradeInfo.label or gradeInfo.name,
                    salary = tonumber(gradeInfo.salary) or tonumber(gradeInfo.payment) or 0,
                })
            end
        end
    end

    table.sort(list, function(a, b) return a.grade < b.grade end)
    return list
end

function Grades.UpdateSalary(source, groupName, gradeLevel, newSalary)
    newSalary = tonumber(newSalary)
    if not newSalary or newSalary < 0 or newSalary > Config.MaxSalary then
        return false, _U('invalid_amount')
    end

    if not Permissions.IsBoss(source, groupName, 'job') then
        return false, _U('no_permission')
    end

    if Lib47.Framework == 'esx' then
        MySQL.update.await('UPDATE job_grades SET salary = ? WHERE job_name = ? AND grade = ?', {
            newSalary, groupName, gradeLevel
        })
        local ESX = exports['es_extended']:getSharedObject()
        if ESX and ESX.RefreshJobs then
            ESX.RefreshJobs()
        end
        return true, _U('salary_updated', gradeLevel, newSalary)
    end

    return false, 'Salary editing is only supported on SQL-driven job tables.'
end
