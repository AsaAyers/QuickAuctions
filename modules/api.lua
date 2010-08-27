local QuickAuctions = select(2, ...)

local Manage = QuickAuctions:GetModule("Manage")
local Scan = QuickAuctions:GetModule("Scan")
local Config = QuickAuctions:GetModule("Config")

local function AssertGroupExists(groupName)
	assert(QuickAuctions.db.global.groups[groupName] ~= nil, format('Invalid group name [%s]', tostring(groupName)))
end

-- Simple data API
QAAPI = {
	GetSafeLink = QuickAuctions.GetSafeLink
}
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
		Manage:GetGroupConfigValue(groupName, 'perAuction'),
		Manage:GetGroupConfigValue(groupName, 'fallback')
end

function QAAPI:AddItem(groupName, itemLink)
	AssertGroupExists(groupName)
	itemLink = QuickAuctions:GetSafeLink(itemLink)
	assert(itemLink, format('invalid link [%s]', tostring(itemLink)))
	Config:AddItem(groupName, itemLink, true)
end

function QAAPI:SetGroupConfig(groupName, key, value)
	AssertGroupExists(groupName)
	if key == 'threshold' or key == 'fallback' then
		assert(value == nil or value >= 0, format("Invalid %s value [%s]", key, tostring(value)))
		QuickAuctions.db.profile[key][groupName] = value
	else
		error(format("Config key [%s] is not supported.", key))
	end
end