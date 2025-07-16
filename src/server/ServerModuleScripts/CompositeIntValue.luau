local CompositeIntValue = {}
CompositeIntValue.__index = CompositeIntValue

local CompositeIntValueMetaTable = {
	__index = function(t,key)
		if key == "Value" then
			print(#t._originTable)
			local sum = 0
			for i, v in ipairs(t._originTable) do
				if v.Value and not( t._mode == "mul" and v.Name == "init") then
					sum += v.Value
				end
			end
			if t._mode == "mul" then
				if sum == 0 then sum = 1 end
				return t._originTable[1].Value * sum
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
		if a._boundTarget then
			(a._boundTarget :: IntValue).Value = a.Value
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
		if a._boundTarget then
			(a._boundTarget :: IntValue).Value = a.Value
		end
		return a
	end
}

type CompositeIntValueType = { 
	Value:number,
	_mode: "sum"|"mul",
	_originTable: {{Name:string,Value:number}},
	_boundTarget: IntValue,
	setBoundTarget:(IntValue)->(),
	containsMod:(string)->boolean,
	removeModifier:(string)->(),
	__add:(CompositeIntValueType,{Name:string,Value:number})->CompositeIntValueType,
	__sub:(CompositeIntValueType,{Name:string,Value:number})->CompositeIntValueType 
}

function CompositeIntValue.new(mode:"sum"|"mul",value:number?,boundTarget:IntValue?) : CompositeIntValueType
	local obj = {}
	obj._mode = mode

	if mode == "mul" and not value then
		error("mul mode requires an initial value")
	end

	obj._originTable = {}
	setmetatable(obj, CompositeIntValueMetaTable)
	if value and (value > 0 or value < 0) then
		obj._originTable[1] = { Name = "init", Value = value }
	end
	if boundTarget then
		obj._boundTarget = boundTarget
	end

	function obj.setBoundTarget(target:IntValue)
		obj._boundTarget = target
	end

	function obj.containsMod(key:string)
		for i,v in ipairs(obj._originTable) do
			if v.Name == key then
				return true
			end
		end
		return false
	end

	function obj.removeModifier(key)
		for i, v in ipairs(obj._originTable) do
			if obj._originTable[i] and obj._originTable[i].Name == key then
				obj._originTable[i] = nil
			end
			if obj._originTable[i] == nil then
				obj._originTable[i] = obj._originTable[i+1]
			end
		end
		if obj._boundTarget then
			(obj._boundTarget :: IntValue).Value = obj.Value
		end

	end

	function obj.resetModifiers()
		obj._boundTarget = {}
		if value and (value > 0 or value < 0) then
			obj._originTable[1] = { Name = "init", Value = value }
		end
		if obj._boundTarget then
			(obj._boundTarget :: IntValue).Value = obj.Value
		end
	end

	return obj :: any
end

return CompositeIntValue