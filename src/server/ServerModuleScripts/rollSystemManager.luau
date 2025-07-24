local inventoryFunctions = require(script.Parent.inventoryFunctions)
local slapStyleFolder: Folder = game:GetService("ServerStorage"):WaitForChild("Tools"):WaitForChild("Slapstyles")
local slapstyles = slapStyleFolder:GetDescendants()

rollsystemManager = {}

local ROLL_CLASSES = {
	common = 0.71,
	uncommon = 0.23,
	rare = 0.054,
	legendary = 0.002,
}

local VALID_TAG = "ValidSlapStyle"

-- local testItems = {
-- 	common = {
-- 		{ item = "commonTestItem1" },
-- 		{ item = "commonTestItem2" },
-- 		{ item = "commonTestItem3" },
-- 		{ item = "commonTestItem4" },
-- 	},
-- 	uncommon = {
-- 		{ item = "uncommonTestItem1" },
-- 		{ item = "uncommonTestItem2" },
-- 		{ item = "uncommonTestItem3" },
-- 	},
-- 	rare = {
-- 		{ item = "rareTestItem1" },
-- 		{ item = "rareTestItem2" },
-- 	},
-- 	legendary = {
-- 		{ item = "legendaryTestItem1" },
-- 	},
-- }
local availableItems = {
	common = {},
	uncommon = {},
	rare = {},
	legendary = {},
}

for i, style in ipairs(slapstyles) do
	if not style:IsA("Tool") or not style:HasTag(VALID_TAG) then
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

-- print(availableItems)
function rollsystemManager.getNewItem(player: Player, rollSlot: number)
	if rollSlot < 1 or rollSlot > 4 then
		warn("Selectedslot is out of range: ", rollSlot)
		return nil
	end
	local change = math.random()
	local rolledStyle: Tool?
	if change >= 1 - ROLL_CLASSES.legendary then
		rolledStyle = availableItems.legendary[math.random(#availableItems.legendary)]:Clone()
	elseif change >= 1 - ROLL_CLASSES.rare then
		rolledStyle = availableItems.rare[math.random(#availableItems.rare)]:Clone()
	elseif change >= 1 - ROLL_CLASSES.uncommon then
		rolledStyle = availableItems.uncommon[math.random(#availableItems.uncommon)]:Clone()
	else
		rolledStyle = availableItems.common[math.random(#availableItems.common)]:Clone()
	end

	if rolledStyle then
		return inventoryFunctions.AddToInventory(player, rolledStyle, rollSlot)
	else
		warn("Something went wrong rolling for a new style")
		return nil
	end
end

return rollsystemManager
