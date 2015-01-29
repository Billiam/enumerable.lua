local Enumerable = {}
Enumerable.__index = Enumerable

local function isSequence(t)
  local i = 0
  for _ in pairs(t) do
     i = i + 1
     if t[i] == nil then return false end
  end
  return true
end

local function isCallable(f)
  local t = type(f)

  if t == 'function' then
    return true
  end

  if t == 'table' then
    local meta = getmetatable(f)

    return meta and type(meta.__call) == 'function'
  end

  return false
end

function Enumerable.create(collection)
  if collection and not (type(collection) == 'table' and isSequence(collection)) then
    error('Enumerable data must be a sequence')
  end
  
  local instance = {
    _data = collection or {}
  }
  
  setmetatable(instance, Enumerable)

  return instance
end

function Enumerable:data()
  return self._data
end

function Enumerable:toTable()
  local meta = getmetatable(self._data)
  local target = {}

  for k, v in pairs(self._data) do target[k] = v end
  setmetatable(target, meta)
  return target
end

--- Iterate over
function Enumerable:each(callback)
  for i,v in ipairs(self._data) do
    callback(v, i)
  end

  return self
end

function Enumerable:map(callback)
  local map = {}

  for i,v in ipairs(self._data) do
    local result = callback(v, i)
    if result ~= nil then
      table.insert(map, result)
    end
  end
  return Enumerable.create(map)
end

function Enumerable:find_index(callback)
  for i,v in ipairs(self._data) do
    if callback(v, i) then
      return i
    end
  end
end

function Enumerable:empty()
  return #self._data == 0
end

function Enumerable:first(n)
  if not n or n == 1 then
    return self._data[1]
  end

  local list = {}

  n = math.min(n, #self._data)
  for i=1,n do
    table.insert(list, self._data[i])
  end

  return list
end

function Enumerable:last(n)
  if not n or n == 1 then
    return self._data[#self._data]
  end

  local list = {}

  n = math.max(1, #self._data - (n - 1))
  for i=n,#self._data do
    table.insert(list, self._data[i])
  end

  return list
end

function Enumerable:count(callback)
  if not callback then
    return #self._data
  end

  local count = 0

  for i,v in ipairs(self._data) do
    if callback(v, i) then
      count = count + 1
    end
  end

  return count
end

function Enumerable:concat(other)
  return self:push(unpack(other))
end

function Enumerable:reduce(initial, callback)
  if not callback and isCallable(initial) then
    callback = initial
    initial = nil
  end

  local reduce = initial

  for i,v in ipairs(self._data) do
    reduce = callback(reduce, v, i)
  end

  return reduce
end

function Enumerable:min(callback)
  callback = callback or function(v) return v end

  local lowestValue

  return self:reduce(function(output, v)
    local result = callback(v)
 
    if not output or (result and result < lowestValue) then
      lowestValue = result
      return v
    end
    
    return output
  end)
end

function Enumerable:max(callback)
  callback = callback or function(v) return v end

  local highestValue

  return self:reduce(function(output, v)
    local result = callback(v)
 
    if not output or (result and result > highestValue) then
      highestValue = result
      return v
    end
    
    return output
  end)
end

function Enumerable:minmax(callback)
  return self:min(callback), self:max(callback)
end

function Enumerable:sort(callback)
  table.sort(self._data, callback)

  return self
end

function Enumerable:push(...)
  for i,v in ipairs(arg) do
    table.insert(self._data, v)
  end

  return self
end

function Enumerable:pop()
  return table.remove(self._data, #self._data)
end

function Enumerable:shift(item)
  return table.remove(self._data, 1)
end

function Enumerable:unshift(...)
  for i,v in ipairs(arg) do
    table.insert(self._data, i, v)
  end

  return self
end

function Enumerable:find(callback)
  for i,v in ipairs(self._data) do
    if callback(v, i) then
      return v
    end
  end
end

function Enumerable:reject(callback)
  local reject = {}

  for i,v in ipairs(self._data) do
    if not callback(v, i) then
      table.insert(reject, v)
    end
  end

  return Enumerable.create(reject)
end

function Enumerable:select(callback)
  local select = {}

  for i,v in ipairs(self._data) do
    if callback(v, i) then
      table.insert(select, v)
    end
  end

  return Enumerable.create(select)
end

function Enumerable:all(callback)
  for i,v in ipairs(self._data) do
    if not callback(v, i) then
      return false
    end
  end

  return true
end

function Enumerable:any(callback)
  for i,v in ipairs(self._data) do
    if callback(v, i) then
      return true
    end
  end

  return false
end

function Enumerable:group_by(callback)
  local groups = {}

  for i,v in ipairs(self._data) do
    local criteria = callback(v, i)

    groups[criteria] = groups[criteria] or Enumerable.create()

    groups[criteria]:push(v)
  end

  return groups
end

function Enumerable:partition(callback)
  local truthyCallback = function(v, i)
    return callback(v, i) and true or false
  end

 local results = self:group_by(truthyCallback)

 return results[true], results[false]
end

--define aliases
Enumerable.find_all = Enumerable.select
Enumerable.detect = Enumerable.select

Enumerable.collect = Enumerable.map

Enumerable.inject = Enumerable.reduce

return Enumerable