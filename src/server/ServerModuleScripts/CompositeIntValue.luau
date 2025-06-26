local CompositeIntValue = {}
CompositeIntValue.__index = CompositeIntValue

local CompositeIntValueMetaTable = {
	__index = function(t,key)
		if key == "Value" then
			print(#t._originTable)
			local sum = 0
			for i, v in ipairs(t._originTable) do
				if v.Value then
					sum += v.Value
				end
			end
			return sum
		end

		local value = rawget(t, key)
        if value ~= nil then
            return value
        end

		return nil
	end,
	__add = function(a,b)
		local contains = false
		for i, v in ipairs(a._originTable) do
			if v.Name == b.Name then
				v.Value += b.Value
				contains = true
			end
		end
		if not contains then
			table.insert(a._originTable,{Name = b.Name, Value = b.Value})
		end
		return a
	end,
	__sub = function(a,b)
		local contains = false
		for i, v in ipairs(a._originTable) do
			if v.Name == b.Name then
				v.Value -= b.Value
				contains = true
			end
			if a._originTable[i] and a._originTable[i].Value == 0 then
				a._originTable[i] = nil
			end
			if a._originTable[i] == nil then
				a._originTable[i] = a._originTable[i+1]
			end
		end
		if not contains then
			table.insert(a._originTable,{Name = b.Name, Value = -b.Value})
		end
		return a
	end
}

function CompositeIntValue.new(value)
	local obj = {}
	obj._originTable = {}
	setmetatable(obj, CompositeIntValueMetaTable)
	if value and (value > 0 or value < 0) then
		obj._originTable[1] = { Name = "init", Value = value }
	end
	return obj
end

return CompositeIntValue