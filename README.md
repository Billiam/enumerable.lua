# enumerable.lua

[![Build Status](https://travis-ci.org/Billiam/enumerable.lua.svg)](https://travis-ci.org/Billiam/enumerable.lua)

A Ruby-inspired collection library.

## Installation

Add [enumerable.lua](enumerable.lua) (or [enumerable-min.lua](enumerable-min.lua)) to your project.

## Usage

```lua
local Enumerable = require('enumerable')
collectionInstance = Enumerable.create({1,2,3,4,5})

collectionInstance:each(function(value, index) 
  print(value)
end)

doubledCollection = collection:map(function(value, index)
  return value * 2
end)

sum = collectionInstance:reduce(0, function(accumulator, value)
  return accumulator + value
end)
```

Additional usage examples are in the [spec file](spec/enumerable_spec.lua).

## Available Enumerable methods

Method | Description
-------------|--------------
`all(callback)` | Returns true if callback returns truthy for all elements in the collection.
`any(callback)` | Returns true if callback returns truthy for any element in the collection.
`concat(other)` | Append the contents of one table onto the end of the exsting enumerable
`count(callback)` | Return the number of items in the collection.
`data()` | Return the unwrapped collection data
`each(callback)` | Pass all elements in the collection to a callback
`empty()` | Whether the collection has no elements.
`find(callback)` | Returns the first element in the collection where the callback returns true
`find_index(callback)` | Find the position of the first item in collection for which the callback returns true.
`first(n)` | Return the first element or elements in the collection.
`group_by(callback)` | Groups elements into collections based on the result of the provided callback.
`last(n)` | Return the last element or elements in the collection.
`map(callback)` | Pass all elements in collection to a callback. Aliases: `collect`
`max(callback)` | Find the highest value in the enumerable instance.
`min(callback)` | Find the lowest value in the enumerable instance.
`minmax(callback)` | Find the highest and lowest values in the enumerable.
`partition(callback)` | Split enumerable into two groups, based on the true or false result of the callback.
`pop()` | Remove and return the last item from the collection.
`push(...)` | Add one or more items to the enumerable.
`reduce(initial, callback)` | Combine elements of enumerable by passing all items to a callback. Aliases: `inject`
`reject(callback)` | Create a new collection with elements which the callback returns false.
`select(callback)` | Create a new collection with elements which the callback returns true. Aliases: `detect`, `find_all`
`shift()` | Remove and return the first item from the collection.
`to_table()` | Create a shallow copy of the unwrapped collection data
`unshift(...)` | Insert one or more items into the beginning of the collection.

[Full API documentation](http://billiam.github.io/enumerable.lua/)

Related projects:
* [underscore.lua](https://github.com/mirven/underscore.lua)
* [Moses](https://github.com/Yonaba/Moses)
* [lua-enumerable](https://github.com/mikelovesrobots/lua-enumerable)
