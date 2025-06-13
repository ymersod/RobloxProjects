rollsystemManager = {}

local ROLL_CLASSES = {
    common = 0.71,
    uncommon = 0.23,
    rare = 0.054,
    legendary = 0.002
}

local availableItems = {
    common = {
        {item = "commonTestItem1"},
        {item = "commonTestItem2"},
        {item = "commonTestItem3"},
        {item = "commonTestItem4"},
    },
    uncommon = {
        {item = "uncommonTestItem1"},
        {item = "uncommonTestItem2"},
        {item = "uncommonTestItem3"},
    },
    rare = {
        {item = "rareTestItem1"},
        {item = "rareTestItem2"},
    },
    legendary = {
        {item = "legendaryTestItem1"},
    }
}

function rollsystemManager.getNewItem()
    local change = math.random()
    if change >= 1 - ROLL_CLASSES.legendary then
        return availableItems.legendary[math.random(#availableItems.legendary)]
    elseif change >= 1 - ROLL_CLASSES.rare then
        return availableItems.rare[math.random(#availableItems.rare)]
    elseif change >= 1- ROLL_CLASSES.uncommon then
        return availableItems.uncommon[math.random(#availableItems.uncommon)]
    else
        return availableItems.common[math.random(#availableItems.common)]
    end
end 

return rollsystemManager