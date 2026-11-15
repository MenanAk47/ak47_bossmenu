Society = {}

function Society.GetBalance(groupName)
    return Lib47.GetSocietyMoney(groupName) or 0
end

function Society.Deposit(source, groupName, amount)
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        return false, _U('invalid_amount')
    end

    if not Lib47.RemoveMoney(source, 'money', amount) then
        return false, _U('insufficient_player_funds')
    end

    Lib47.AddSocietyMoney(groupName, amount, 'Boss Deposit')
    SendDiscordLog('Society Deposit', string.format('%s deposited $%s into %s', Lib47.GetCharacterName(source), amount, groupName), 65280)
    return true, _U('society_deposit_success', amount)
end

function Society.Withdraw(source, groupName, amount)
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        return false, _U('invalid_amount')
    end

    if not Lib47.RemoveSocietyMoney(groupName, amount, 'Boss Withdrawal') then
        return false, _U('insufficient_funds')
    end

    Lib47.AddMoney(source, 'money', amount)
    SendDiscordLog('Society Withdrawal', string.format('%s withdrew $%s from %s', Lib47.GetCharacterName(source), amount, groupName), 16711680)
    return true, _U('society_withdraw_success', amount)
end
