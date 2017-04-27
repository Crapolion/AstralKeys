local _, e = ...

local BROADCAST = true
local versionList = {}
local messageStack = {}
local messageQueue = {}
local highestVersion = 0
local find, sub = string.find, string.sub

local function AddonMessage(index)	
	return AstralKeys[index].name .. ":" .. AstralKeys[index].class .. ':' .. AstralKeys[index].realm .. ':' .. AstralKeys[index].map .. ':' .. AstralKeys[index].level .. ':' .. AstralKeys[index].usable .. ':' .. AstralKeys[index].a1 .. ':' .. AstralKeys[index].a2 .. ':' .. AstralKeys[index].a3 .. ':' .. AstralKeys[index].weeklyCache
end

local akComms = CreateFrame('FRAME')
akComms:RegisterEvent('CHAT_MSG_ADDON')
RegisterAddonMessagePrefix('AstralKeys')

akComms:SetScript('OnEvent', function(self, event, ...)
	local prefix, msg = ...
	if not (prefix == 'AstralKeys') then return end

	local arg, content = msg:match("^(%S*)%s*(.-)$")
		if e.IsPrefixRegistered(arg) then
			akComms[arg](content, ...)
		end
	end)

function e.RegisterPrefix(prefix, func)
	akComms[prefix] = function(...)
	func(...)
	end
end

function e.IsPrefixRegistered(prefix)
	return akComms[prefix]
end

function e.UnregisterPrefix(prefix)
	if not e.IsPrefixRegistered(prefix) then return end
	akComms[prefix] = nil
end

function e.AnnounceNewKey(keyLink, level)
	if not BROADCAST and not IsInGroup() then return end
	SendChatMessage('Astral Keys: New key ' .. keyLink .. ' +' .. level, 'PARTY')
end

local function UpdateKeyList(entry)
	local messageReceived = {}
	if find(entry, '_') then
		while find(entry, '_') do
			local _pos = find(entry, '_')
			messageReceived[#messageReceived + 1] = sub(entry, 1, _pos - 1)
			entry = sub(entry, _pos + 1, entry:len())
		end
		for i = 1, #messageReceived do
			local unit, unitClass, unitRealm = messageReceived[i]:match('(%a+):(%a+):([%a%s-\']+)')
			local dungeonID, keyLevel, isUsable, affixOne, affixTwo, affixThree, weekly10 = messageReceived[i]:match(':(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)')

			dungeonID = tonumber(dungeonID)
			keyLevel = tonumber(keyLevel)
			isUsable = tonumber(isUsable)
			affixOne = tonumber(affixOne)
			affixTwo = tonumber(affixTwo)
			affixThree = tonumber(affixThree)
			weekly10 = tonumber(weekly10)

			if not e.UnitInGuild(unit .. '-' .. unitRealm) then return end

			if affixOne ~= 0 then
				e.SetAffix(1, affixOne)
			end

			if affixTwo ~= 0 then
				e.SetAffix(2, affixTwo)
			end

			if affixThree ~= 0 then
				e.SetAffix(3, affixThree)
			end

			local id = e.GetUnitID(unit .. '-' .. unitRealm)

			if id then
				if AstralKeys[id].weeklyCache ~= weekly10 then AstralKeys[id].weeklyCache = weekly10 end

				if AstralKeys[id].level < keyLevel or AstralKeys[id].usable ~= isUsable then
					AstralKeys[id].map = dungeonID
					AstralKeys[id].level = keyLevel
					AstralKeys[id].usable = isUsable
					e.UpdateFrames()
				end
			else
				table.insert(AstralKeys, {name = unit, class = unitClass, realm = unitRealm, map = dungeonID, level = keyLevel, usable = isUsable, a1 = affixOne, a2 = affixTwo, a3 = affixThree, weeklyCache = weekly10})
				e.SetUnitID(unit .. '-' .. unitRealm, #AstralKeys)
				if unit == e.PlayerName() and unitRealm == e.PlayerRealm() then
					e.SetPlayerID()
				end
				e.UpdateFrames()
			end

			if sender == e.PlayerName() and unitRealm == e.PlayerRealm() then
				e.UpdateCharacterFrames()
			end
		end
	else	
		local unit, unitClass, unitRealm = entry:match('(%a+):(%a+):([%a%s-\']+)')
		local dungeonID, keyLevel, isUsable, affixOne, affixTwo, affixThree, weekly10 = entry:match(':(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)')

		dungeonID = tonumber(dungeonID)
		keyLevel = tonumber(keyLevel)
		isUsable = tonumber(isUsable)
		affixOne = tonumber(affixOne)
		affixTwo = tonumber(affixTwo)
		affixThree = tonumber(affixThree)
		weekly10 = tonumber(weekly10)

		if not e.UnitInGuild(unit .. '-' .. unitRealm) then return end

		if affixOne ~= 0 then
			e.SetAffix(1, affixOne)
		end

		if affixTwo ~= 0 then
			e.SetAffix(2, affixTwo)
		end

		if affixThree ~= 0 then
			e.SetAffix(3, affixThree)
		end

		local id = e.GetUnitID(unit .. '-' .. unitRealm)

		if id then
			if AstralKeys[id].weeklyCache ~= weekly10 then AstralKeys[id].weeklyCache = weekly10 end

			if AstralKeys[id].level < keyLevel or AstralKeys[id].usable ~= isUsable then
				AstralKeys[id].map = dungeonID
				AstralKeys[id].level = keyLevel
				AstralKeys[id].usable = isUsable
				e.UpdateFrames()
			end
		else
			table.insert(AstralKeys, {name = unit, class = unitClass, realm = unitRealm, map = dungeonID, level = keyLevel, usable = isUsable, a1 = affixOne, a2 = affixTwo, a3 = affixThree, weeklyCache = weekly10})
			e.SetUnitID(unit .. '-' .. unitRealm, #AstralKeys)
			if unit == e.PlayerName() and unitRealm == e.PlayerRealm() then
				e.SetPlayerID()
			end
			e.UpdateFrames()
		end

		if sender == e.PlayerName() and unitRealm == e.PlayerRealm() then
			e.UpdateCharacterFrames()
		end
	end
	e.UpdateAffixes()
end
e.RegisterPrefix('updateV4', UpdateKeyList)

local function UpdateWeekly10(...)
	local weekly = ...
	local sender = select(4, ...)

	local id = e.GetUnitID(sender)
	if id then
		AstralKeys[id].weeklyCache = tonumber(weekly)
	end
end
e.RegisterPrefix('updateWeekly', UpdateWeekly10)

local function PushKeyList(...)
	local sender = select(4, ...)
	--if sender == e.PlayerName() .. '-' .. e.PlayerRealm() then return end
	wipe(messageStack)
	for i = 1, #AstralKeys do
		if e.UnitInGuild(AstralKeys[i].name .. '-' .. AstralKeys[i].realm) then
			messageStack[#messageStack + 1] = AddonMessage(i) .. '_'
		end
	end
	-- Keep 10 characters for prefix length, extra incase version goes into double digits

	local index = 1
	messageQueue[index] = ''
	while messageStack[1] do		
		local nextMessage = messageQueue[index] .. messageStack[1]
		if nextMessage:len() < 245 then
			messageQueue[index] = nextMessage
			table.remove(messageStack, 1)
		else
			index = index + 1
			messageQueue[index] = ''
		end
	end

	for i = 1, #messageQueue do
		SendAddonMessage('AstralKeys', 'updateV4 ' .. messageQueue[i], 'GUILD')
	end
	
end

	
e.RegisterPrefix('request', PushKeyList)

local function VersionRequest()
	local version = GetAddOnMetadata('AstralKeys', 'version')
	version = version:gsub('[%a%p]', '')
	SendAddonMessage('AstralKeys', 'versionPush ' .. version .. ':' .. e.PlayerClass(), 'GUILD')
end
e.RegisterPrefix('versionRequest', VersionRequest)

local function VersionPush(msg, ...)
	local sender = select(4, ...)
	local version, class = msg:match('(%d+):(%a+)')
	if tonumber(version) > highestVersion then
		highestVersion = tonumber(version)
	end
	versionList[sender] = {version = version, class = class}
end

local function ResetAK()
	AstralKeysSettings['reset'] = false
	e.WipeUnitList()
	wipe(AstralKeys)
	wipe(AstralCharacters)
	AstralAffixes[1] = 0
	AstralAffixes[2] = 0
	AstralAffixes[3] = 0
	e.GetBestClear()
	e.SetPlayerID()
	e.FindKeyStone(true)
	e.SetCharacterID()
	e.UpdateAffixes()
	C_Timer.After(.75, function()
		e.UpdateCharacterFrames()
		e.UpdateFrames()
	end)
end
e.RegisterPrefix('resetAK', ResetAK)
--SendAddonMessage('AstralKeys', 'resetAK', 'GUILD')
--[[SendAddonMessage('AstralKeys', 'updateV4 Jpeg:DEMONHUNTER:Turalyon:200:22:1:13:13:10:1', 'GUILD')
	SendAddonMessage('AstralKeys', 'updateV4 Unsu:SHAMAN:Turalyon:227:22:1:13:13:10:1', 'GUILD')
	SendAddonMessage('AstralKeys', 'updateV4 Phrike:MAGE:Turalyon:200:22:1:13:13:10:0', 'GUILD')
	SendAddonMessage('AstralKeys', 'updateV4 Ripmalv:SHAMAN:Turalyon:234:22:1:13:13:10:0', 'GUILD')
	SendAddonMessage('AstralKeys', 'updateV4 Ipsi:DRUID:Turalyon:234:22:1:13:13:10:0', 'GUILD')
	SendAddonMessage('AstralKeys', 'updateV4 Abbychu:DRUID:Turalyon:234:22:1:13:13:10:0', 'GUILD')
	SendAddonMessage('AstralKeys', 'updateV4 Shootsu:HUNTER:Turalyon:234:22:1:13:13:10:0', 'GUILD')
	SendAddonMessage('AstralKeys', 'updateV4 Terra:DEATHKNIGHT:Turalyon:234:22:1:13:13:10:0', 'GUILD')

]]
function e.AnounceCharacterKeys(channel)
	for i = 1, #AstralCharacters do
		local id = e.UnitID(e.CharacterName(i))

		if id then
			local link, keyLevel = e.CreateKeyLink(id)
			if keyLevel >= e.GetMinKeyLevel() then
				if channel == 'PARTY' and not IsInGroup() then return end
				SendChatMessage(e.CharacterName(i) .. ' ' .. link .. ' +' .. keyLevel, channel)
			end
		end
	end
end

local function PrintVersion()
	local outOfDate = 'Out of date: '
	local upToDate = 'Up to date: '
	local notInstalled = 'Not installed: '

	local i = 1
	for k,v in pairs(versionList) do
		if tonumber(v.version) < highestVersion then
			outOfDate = outOfDate .. WrapTextInColorCode(Ambiguate(k, 'GUILD'), select(4, GetClassColor(v.class))) .. '(' .. v.version .. ') '
		else
			upToDate = upToDate .. WrapTextInColorCode(Ambiguate(k, 'GUILD'), select(4, GetClassColor(v.class))) .. '(' .. v.version .. ') '
		end
	end
	for i = 1, select(2, GetNumGuildMembers()) do
		local unit = GetGuildRosterInfo(i)
		local class = select(11, GetGuildRosterInfo(i))
		if not versionList[unit] then
			notInstalled = notInstalled .. WrapTextInColorCode(Ambiguate(unit, 'GUILD'), select(4, GetClassColor(class))) .. ' '
		end
	end
	ChatFrame1:AddMessage(upToDate)
	ChatFrame1:AddMessage(outOfDate)
	ChatFrame1:AddMessage(notInstalled)
end

local timer
function e.VersionCheck()
	if not IsInGuild() then return end
	if not e.IsPrefixRegistered('versionPush') then
		e.RegisterPrefix('versionPush', VersionPush)
	end
	highestVersion = 0
	wipe(versionList)
	SendAddonMessage('AstralKeys', 'versionRequest', 'GUILD')
	if timer then timer:Cancel() end
	timer =  C_Timer.NewTicker(3, function() PrintVersion() e.UnregisterPrefix('versionPush') end, 1)
end

--[[
PARSE COMBINED MESSAGES
test = 'Jpeg:DEMONHUNTER:Turalyon:200:22:1:13:13:10:1_Unsu:SHAMAN:Turalyon:227:22:1:13:13:10:1_'
strings = {}

test:sub(1, test:find('_'))

while test:find('_') do
strings[#strings + 1] = test:sub(1, test:find('_') - 1)
test = test:sub(test:find('_')+1 , test:len())
end

tprint(strings)
]]