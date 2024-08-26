local pMeta = FindMetaTable 'Player'

function pMeta:SetCheater(bool)
	if bool then
		hook.Run('AddCheater', self)
	end
	self.Cheater = bool or nil
end

hook.Add('AddCheater', 'CheatPunish', function(ply)
	kouka.Notify('Admin',  kouka.colors.red, ('%s [%s]'):format(ply:Name(), ply:SteamID()), kouka.colors.orange, ' балуется эксплойтами')
end)

hook.Add('PlayerDisconnected', 'CheatPunish', function(ply)
    if ply.Cheater then
    	kouka.PermaBan(ply, 'Exploiter (Uh, oh! You stepped on the trap!) ╮( ˘ ､ ˘ )╭')
    end
end)

hook.Add('PlayerSay', 'CheatPunish', function(ply, text)
	if ply.Cheater then return 'Гав-гав' end
end, HOOK_HIGH)

hook.Add('PlayerUse', 'CheatPunish', function(ply, ent)
	if ply.Cheater then return false end
end, HOOK_HIGH)

hook.Add('PlayerCanHearPlayersVoice', 'CheatPunish', function( listener, talker )
    if talker.Cheater then return false end
end, HOOK_HIGH)
