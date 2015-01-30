local n={}n.__index=n
local function r(e)local n=0
for t in pairs(e)do
n=n+1
if e[n]==nil then return false end
end
return true
end
local function t(e)local n=type(e)if n=='function'then
return true
end
if n=='table'then
local n=getmetatable(e)return n and type(n.__call)=='function'end
return false
end
function n.create(e)if e and not(type(e)=='table'and r(e))then
error('Enumerable data must be a sequence')end
local e={_data=e or{}}setmetatable(e,n)return e
end
function n:data()return self._data
end
function n:to_table()local t=getmetatable(self._data)local n={}for e,t in pairs(self._data)do n[e]=t end
setmetatable(n,t)return n
end
function n:each(n)for t,e in ipairs(self._data)do
n(e,t)end
return self
end
function n:map(r)local e={}for t,n in ipairs(self._data)do
local n=r(n,t)if n~=nil then
table.insert(e,n)end
end
return n.create(e)end
function n:find_index(e)for n,t in ipairs(self._data)do
if e(t,n)then
return n
end
end
end
function n:empty()return#self._data==0
end
function n:first(n)if not n or n==1 then
return self._data[1]end
local e={}n=math.min(n,#self._data)for n=1,n do
table.insert(e,self._data[n])end
return e
end
function n:last(n)if not n or n==1 then
return self._data[#self._data]end
local e={}n=math.max(1,#self._data-(n-1))for n=n,#self._data do
table.insert(e,self._data[n])end
return e
end
function n:count(e)if not e then
return#self._data
end
local n=0
for r,t in ipairs(self._data)do
if e(t,r)then
n=n+1
end
end
return n
end
function n:concat(n)return self:push(unpack(n))end
function n:reduce(n,e)if not e and t(n)then
e=n
n=nil
end
local n=n
for t,r in ipairs(self._data)do
n=e(n,r,t)end
return n
end
function n:min(n)n=n or function(n)return n end
local r
return self:reduce(function(e,t)local n=n(t)if not e or(n and n<r)then
r=n
return t
end
return e
end)end
function n:max(n)n=n or function(n)return n end
local t
return self:reduce(function(r,e)local n=n(e)if not r or(n and n>t)then
t=n
return e
end
return r
end)end
function n:minmax(n)return self:min(n),self:max(n)end
function n:sort(n)table.sort(self._data,n)return self
end
function n:push(...)for e,n in ipairs(arg)do
table.insert(self._data,n)end
return self
end
function n:pop()return table.remove(self._data,#self._data)end
function n:shift()return table.remove(self._data,1)end
function n:unshift(...)for e,n in ipairs(arg)do
table.insert(self._data,e,n)end
return self
end
function n:find(e)for t,n in ipairs(self._data)do
if e(n,t)then
return n
end
end
end
function n:reject(t)local e={}for r,n in ipairs(self._data)do
if not t(n,r)then
table.insert(e,n)end
end
return n.create(e)end
function n:select(r)local e={}for t,n in ipairs(self._data)do
if r(n,t)then
table.insert(e,n)end
end
return n.create(e)end
function n:all(n)for e,t in ipairs(self._data)do
if not n(t,e)then
return false
end
end
return true
end
function n:any(t)for e,n in ipairs(self._data)do
if t(n,e)then
return true
end
end
return false
end
function n:group_by(a)local e={}for t,r in ipairs(self._data)do
local t=a(r,t)e[t]=e[t]or n.create()e[t]:push(r)end
return e
end
function n:partition(e)local e=function(n,t)return e(n,t)and true or false
end
local e=self:group_by(e)return e[true]or n.create(),e[false]or n.create()end
n.find_all=n.select
n.detect=n.select
n.collect=n.map
n.inject=n.reduce
return n