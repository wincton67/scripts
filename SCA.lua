--Suspicious chat
local susWords = octolib.array.toKeys {
	'exechack.cc',
	'СКРИПТХУКНУЛ',
	'нет старт',
	'продам читы',
	'Hello, fucker',
}

hook.Add('PlayerSay', 'SCA:BAN', function(ply, text)
	if text == '' then return end
	for _, word in next, susWords do
		if not text:utf8lower():find(v) then continue end
		kouka.PermaBan(ply, 'SCA', true)
		return ''
	end
end)
