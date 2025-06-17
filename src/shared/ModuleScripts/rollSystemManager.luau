local slapStyleFolder: Folder = game:GetService("ServerStorage"):WaitForChild("Tools"):WaitForChild("Slapstyles")
local slapstyles = slapStyleFolder:GetDescendants()

rollsystemManager = {}

local ROLL_CLASSES = {
	common = 0.71,
	uncommon = 0.23,
	rare = 0.054,
	legendary = 0.002,
}

local testItems = {
	common = {
		{ item = "commonTestItem1" },
		{ item = "commonTestItem2" },
		{ item = "commonTestItem3" },
		{ item = "commonTestItem4" },
	},
	uncommon = {
		{ item = "uncommonTestItem1" },
		{ item = "uncommonTestItem2" },
		{ item = "uncommonTestItem3" },
	},
	rare = {
		{ item = "rareTestItem1" },
		{ item = "rareTestItem2" },
	},
	legendary = {
		{ item = "legendaryTestItem1" },
	},
}
local availableItems = {
	common = {},
	uncommon = {},
	rare = {},
	legendary = {},
}

for i, style in ipairs(slapstyles) do
	if not style:IsA("Tool") then
		continue
	end
	local rarity = style:GetAttribute("Rarity")
	if rarity == "common" then
		availableItems.common[#availableItems.common + 1] = style
	elseif rarity == "uncommon" then
		availableItems.uncommon[#availableItems.uncommon + 1] = style
	elseif rarity == "rare" then
		availableItems.rare[#availableItems.rare + 1] = style
	elseif rarity == "legendary" then
		availableItems.legendary[#availableItems.legendary + 1] = style
	end
end

print(availableItems)
function rollsystemManager.getNewItem()
	local change = math.random()
	if change >= 1 - ROLL_CLASSES.legendary then
		return availableItems.legendary[math.random(#availableItems.legendary)]
	elseif change >= 1 - ROLL_CLASSES.rare then
		return availableItems.rare[math.random(#availableItems.rare)]
	elseif change >= 1 - ROLL_CLASSES.uncommon then
		return availableItems.uncommon[math.random(#availableItems.uncommon)]
	else
		return availableItems.common[math.random(#availableItems.common)]
	end
end

return rollsystemManager
