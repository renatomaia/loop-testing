-- Project: LOOP Class Library
-- Release: 2.3 beta
-- Title  : Simple Queue
-- Author : Renato Maia <maia@inf.puc-rio.br>
-- Notes  :
--   Can be used as a module that provides functions instead of methods.

local table = require "table"
local concat = table.concat

local oo = require "loop.base"
local class = oo.class


local OneAsDefaultValue = {
	__mode = "k",
	__index = function(self, key)
		self[key] = 1
		return 1
	end,
}
local headOf = setmetatable({}, OneAsDefaultValue)
local tailOf = setmetatable({}, OneAsDefaultValue)

local Queue = class()

-- { }              :__len() --> { }               : 0
-- { one }          :__len() --> { one }           : 1
-- { one two }      :__len() --> { one two }       : 2
-- { one two three }:__len() --> { one two three } : 3
function Queue:__len()
	return headOf[self] - tailOf[self]
end

-- { }       :empty() --> { }        : true
-- { item ? }:empty() --> { item ? } : false
function Queue:empty(item)
	return headOf[self] >= tailOf[self]
end

-- { }       :head() --> { }        : nil
-- { item ? }:head() --> { item ? } : item
function Queue:head()
	return self[ headOf[self] ]
end

-- { }       :last() --> { }        : nil
-- { ? item }:last() --> { ? item } : item
function Queue:last()
	return self[ tailOf[self]-1 ]
end

-- { ? }      :enqueue()     --> { ? nil }        : nil
-- { ? }      :enqueue(nil)  --> { ? nil }        : nil
-- { ? }      :enqueue(item) --> { ? item }       : item
-- { other ? }:enqueue(item) --> { other ? item } : item
-- { item ? } :enqueue(item) --> { item ? item }  : item
function Queue:enqueue(item)
	local tail = tailOf[self]
	self[tail] = item
	tailOf[self] = tail+1
	return item
end

-- { }       :dequeue() --> { }   : 
-- { item ? }:dequeue() --> { ? } : item
function Queue:dequeue()
	local head = headOf[self]
	if head < tailOf[self] then
		local item = self[head]
		self[head] = nil
		headOf[self] = head+1
		return item
	end
end

-- { ? }                   :remove()  --> { ? }                 : error "attempt to perform arithmetic on local 'index' (a nil value)"
-- { }                     :remove(0) --> { }                   : 
-- { }                     :remove(1) --> { }                   : 
-- { }                     :remove(2) --> { }                   : 
-- { ? }                   :remove(0) --> { ? }                 : 
-- { item ? }              :remove(1) --> { ? }                 : item
-- { other item ? }        :remove(2) --> { other ? }           : item
-- { other another item ? }:remove(3) --> { other another ? }   : item
-- { one other another }   :remove(4) --> { one other another } : 
function Queue:remove(index)
	local head = headOf[self]
	local pos = head+index-1
	if pos >= head then
		local last = tailOf[self]-1
		if pos <= last then
			local item = self[pos]
			if pos < (head+last)/2 then
				for i = pos, head, -1 do
					self[i] = self[i-1]
				end
				headOf[self] = head+1
			else
				for i = pos, last do
					self[i] = self[i+1]
				end
				tailOf[self] = last
			end
			return item
		end
	end
end

local function iterator(self, index)
	local pos = headOf[self]+index
	if pos < tailOf[self] then
		return index+1, self[pos]
	end
end
function Queue:items()
	return iterator, self, 0
end

function Queue:__tostring()
	local result = { "{ " }
	for i = headOf[self], tailOf[self]-1 do
		result[#result+1] = tostring(self[i])
		result[#result+1] = ", "
	end
	local last = #result
	result[last] = (last == 1) and "{}" or " }"
	return concat(result)
end

return Queue