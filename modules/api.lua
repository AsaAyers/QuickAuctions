local QuickAuctions = select(2, ...)

local Manage = QuickAuctions:GetModule("Manage")
local Scan = QuickAuctions:GetModule("Scan")

local function AssertGroupExists(groupName)
	assert(QuickAuctions.db.global.groups[groupName] ~= nil, format('Invalid group name [%s]', tostring(groupName)))
end

-- Simple data API
QAAPI = {}
function QAAPI:GetData(itemLink)
	if( not itemLink ) then return end
	itemLink = QuickAuctions:GetSafeLink(itemLink)

	return Scan.auctionData[itemLink]
end

function QAAPI:GetItemGroup(itemLink)
	itemLink = QuickAuctions:GetSafeLink(itemLink)
	if( not itemLink ) then return end
	Manage:UpdateReverseLookup()
	return Manage.reverseLookup[itemLink ]
end

function QAAPI:GetGroups()
	groups = {}
	for group, items in pairs(QuickAuctions.db.global.groups) do
		if( not QuickAuctions.db.profile.groupStatus[group] ) then
			groups[group] = true
		end
	end
	return groups
end

function QAAPI:GetItemsInGroup(groupName)
	AssertGroupExists(groupName)
	local items = {}
	for link, bool in pairs(QuickAuctions.db.global.groups[groupName]) do
		if bool then
			items[link] = bool
		end
	end

	return items
end

function QAAPI:GetGroupConfig(groupName)
	AssertGroupExists(groupName)
	return Manage:GetGroupConfigValue(groupName, 'threshold'),
		Manage:GetGroupConfigValue(groupName, 'postCap'),
		Manage:GetGroupConfigValue(groupName, 'perAuction')
end

function QAAPI:SetGroupConfig(groupName, key, value)
	AssertGroupExists(groupName)
	if key == 'threshold' then
		assert(value ~= nil and value >= 0, format("Invalid threshold value [%s]", tostring(value)))
		QuickAuctions.db.profile['threshold'][groupName] = value
	else
		error(format("Config key [%s] is not supported.", key))
	end
end