local CompositeIntValue = {}
CompositeIntValue.__index = CompositeIntValue

local CompositeIntValueMetaTable = {
	__index = function(t, key)
		if key == "Value" then
			print(#t._originTable)
			local sum = 0
			local postMul = 1
			for i, v in ipairs(t._originTable) do
				print(v)
				if v.Value and not (t._mode == "mul" and v.Name == "init") and not v.PostMul then
					sum += v.Value
				end
				if v.PostMul then
					if postMul == 1 then
						postMul = 0
					end
					postMul += v.Value
				end
			end
			if t._mode == "mul" then
				if sum == 0 then
					sum = 1
				end
				print("Postmul", postMul)
				return t._originTable[1].Value * sum * postMul
			end
			return sum
		end

		local value = rawget(t, key)
		if value ~= nil then
			return value
		end

		return nil
	end,
	__add = function(a, b)
		local contains = false
		for i, v in ipairs(a._originTable) do
			if v.Name == b.Name then
				v.Value += b.Value
				contains = true
			end
		end
		if not contains then
			table.insert(a._originTable, { Name = b.Name, Value = b.Value })
		end
		if a._boundTarget then
			(a._boundTarget :: IntValue).Value = a.Value
		end
		return a
	end,
	__sub = function(a, b)
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
				a._originTable[i] = a._originTable[i + 1]
				a._originTable[i + 1] = nil
			end
		end
		if not contains then
			table.insert(a._originTable, { Name = b.Name, Value = -b.Value })
		end
		if a._boundTarget then
			(a._boundTarget :: IntValue).Value = a.Value
		end
		return a
	end,
}

type TableEntry = { Name: string, Value: number, PostMul: true? }

type TableRemove = { EntryId: string }

type CompositeIntValueType = {
	Value: number,
	_mode: "sum" | "mul",
	_originTable: { TableEntry },
	_boundTarget: IntValue,
	setBoundTarget: (IntValue) -> (),
	containsMod: (string) -> boolean,
	removeModifier: (string) -> (),
	__add: (CompositeIntValueType, { Name: string, Value: number, PostMul: boolean? }) -> CompositeIntValueType,
	__sub: (CompositeIntValueType, { Name: string, Value: number }) -> CompositeIntValueType,
}

export type QueueEntry = {
	type: "add" | "remove",
	data: TableEntry,
}

function CompositeIntValue.new(mode: "sum" | "mul", value: number?, boundTarget: IntValue?): CompositeIntValueType
	local obj = {}
	obj._mode = mode
	obj._isProcessing = false
	obj._isAdding = false
	obj._originTable = {}

	local removeQueue = {}
	local processQueue: { QueueEntry } = {}

	local function getIndexOnTable(name: string)
		for i, v in ipairs(obj._originTable) do
			if v.Name == name then
				return i
			end
		end
	end

	if mode == "mul" and not value then
		error("mul mode requires an initial value")
	end

	setmetatable(obj, CompositeIntValueMetaTable)
	if value and (value > 0 or value < 0) then
		obj._originTable[1] = { Name = "init", Value = value }
	end
	if boundTarget then
		obj._boundTarget = boundTarget
	end

	function obj.setBoundTarget(target: IntValue)
		obj._boundTarget = target
	end

	function obj.containsMod(key: string)
		for i, v in ipairs(obj._originTable) do
			if v.Name == key then
				return true
			end
		end
		return false
	end

	local function processQueueEntries()
		if obj._isProcessing or #processQueue == 0 then
			return
		end
		obj._isProcessing = true

		while #processQueue > 0 do
			local entry = table.remove(processQueue, 1)
			local index = getIndexOnTable(entry.data.Name)
			if entry.type == "add" then
				if not index then
					table.insert(obj._originTable, entry.data)
				end
			elseif entry.type == "remove" then
				if index then
					table.remove(obj._originTable, index)
				end
			end
		end
		obj._isProcessing = false

		if obj._boundTarget then
			(obj._boundTarget :: IntValue).Value = obj.Value
		end
	end

	function obj.removeModifier(key: string)
		local entry: QueueEntry = { type = "remove", data = { Name = key, Value = 0 } }
		table.insert(processQueue, entry)
		processQueueEntries()
	end

	function obj.addModifier(modifier: TableEntry)
		local entry: QueueEntry = { type = "add", data = modifier }
		table.insert(processQueue, entry)
		processQueueEntries()
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
