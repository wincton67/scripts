local badNames = octolib.array.toKeys {
	'^',
	'*',
	'@',
	'me',
}

local kickReason = 
	'Your nickname contains characters that cannot be used. Or your nickname is very big. ' ..
	'Change your nickname and log in to the server.'

timer.Create('Admin:CheckBadNames', 2.5, 0, function()
	if #player.GetAll() < 0 then return end

	for _, ply in next, player.GetAll() do
		local name = ply:Name()
		if badNames[name] or #name > 99 then
			ply:Kick(kickReason)
		end
	end

end)

hook.Add('CheckPassword', 'Admin:CheckBadNames', function(_, _, _, _, name)
	if badNames[name] or #name > 99 then
		return false, kickReason
	end
end)
