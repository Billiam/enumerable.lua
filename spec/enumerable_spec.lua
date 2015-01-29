local Enumerable = require('enumerable')

describe("Enumerable", function()
  describe("create()", function()

    describe("when instantiated with no data", function()
      local instance = Enumerable.create()

      it("stores an empty table", function()
        assert.are.same({}, instance._data)
      end)

      describe("when created with an existing table", function()
        local data = {'test'}
        local instance = Enumerable.create(data)
        it("uses existing table data", function()
          assert.are.equal(data, instance._data)
        end)
      end)

      describe("when created with invalid data", function()        
        it("throws an error", function()
          assert.has_error(function() Enumerable.create('not a table') end)
          assert.has_error(function() Enumerable.create(10) end)
        end)
      end)

      describe("when created with a non-sequence table", function()
        it("throws an error", function()
          assert.has_error(function() Enumerable.create({field = 'value'}) end)

          local data = {1,2,3}
          data[2] = nil

          assert.has_error(function() Enumerable.create(data) end)
        end)
      end)
    end)
  end)

  describe("Instance methods", function()
    describe("data()", function()
      local data = {'test'}
      local instance = Enumerable.create(data)

      it("returns raw table data", function()
        assert.are.equal(data, instance:data())
      end)
    end)

    describe("toTable()", function()
      local data = {'test'}
      local complexData = {'test', data}


      it("clones internal data", function()
        local result = Enumerable.create(data):toTable()

        assert.are_not.equal(data, result)
        assert.same(result, data)
      end)

      it("copies child content by reference", function()
        local result = Enumerable.create(complexData):toTable()

        assert.are_not.equal(data, result)
        assert.are.equal(data, result[2])
      end)
    end)

    describe("each()", function()
      local instance = Enumerable.create({'a', 'b', 'c'})

      it("applies callback to enumerable items", function()
        local callback = spy.new(function() end)
        instance:each(callback)

        assert.spy(callback).was.called_with('a', 1)
        assert.spy(callback).was.called_with('b', 2)
        assert.spy(callback).was.called_with('c', 3)
        assert.spy(callback).was.called(3)
      end)

      it("returns the enumerable instance", function()
        assert.are.equal(instance, instance:each(function() end))
      end)
    end)
  end)
  
  describe("map()", function()
    local instance = Enumerable.create({10,20,30})

    it("returns a new Enumerable instance", function()
      local result = instance:map(function() end)

      assert.are.equal('table', type(result))
      assert.are_not.equal(instance, result)
    end)

    it("calls provided function for each table element", function()
      local callback = spy.new(function() end)
      instance:map(callback)

      assert.spy(callback).was.called_with(10,1)
      assert.spy(callback).was.called_with(20, 2)
      assert.spy(callback).was.called_with(30,3)
      assert.spy(callback).was.called(3)
    end)

    it("applies callback to table elements", function()
      local result = instance:map(function(v) return v * 2 end)

      assert.are.same({20, 40, 60}, result:data())
    end)

    it("compacts arrays when callback returns nil", function()
      local result = instance:map(function(v, i) return i > 1 and v or nil end)

      assert.are.same({20, 30}, result:data())
    end)

    it("returns a new enumerable instance", function()
      local result = instance:map(function(i) return i end)

      assert.are_not.equal(instance, result)
      assert.are.same(instance, result)
    end)
  end)
 
  describe("find_index()", function()
    local instance = Enumerable.create({5, 10, 15})
    local callback = function(v, i) return v > 6 end

    it("returns the position of the first matching result", function()
      assert.are.equal(2, instance:find_index(callback))
    end)
  end)

  describe("first()", function()
    local instance = Enumerable.create({5, 10, 15, 20})

    describe("with no arguments", function()
      it("returns the first table element", function()
        assert.are.equal(5, instance:first())
      end)
    end)

    describe("with a count lower than available table elements", function()
      it("returns the requested number of elements", function()
        assert.are.same({5, 10, 15}, instance:first(3))
      end)
    end)

    describe("with a count greater than available table elements", function()
      it("returns the maximum number of elements", function()
        assert.are.same({5, 10, 15, 20}, instance:first(6))
      end)
    end)
  end)

  describe("last()", function()
    local instance = Enumerable.create({5, 10, 15, 20})

    describe("with no arguments", function()
      it("returns the last table element", function()
        assert.are.equal(20, instance:last())
      end)
    end)

    describe("with a count lower than available table elements", function()
      it("returns the requested number of elements from the end of the table", function()
        assert.are.same({10, 15, 20}, instance:last(3))
      end)
    end)

    describe("with a count greater than available table elements", function()
      it("returns the maximum number of elements", function()
        assert.are.same({5, 10, 15, 20}, instance:last(6))
      end)
    end)
  end)

  describe("count()", function()
    local instance = Enumerable.create({1,2,3,4})

    describe("when called without a callback", function() 
      it("returns the internal table length", function()
        assert.are.equal(4, instance:count())
      end)
    end)

    describe("when called with a callback", function()
      local callback = function(item) return item > 2 end

      it("returns the count of elements based on callback", function()
        assert.are.equal(2, instance:count(callback))
      end)
    end)
  end)

  describe("concat()", function()
    local append = {4,5,6}


    it("appends new content to the end of an existing table", function()
      local instance = Enumerable.create({1,2,3})
      assert.are.same({1,2,3,4,5,6}, instance:concat(append):data())
    end)

    it("returns the enumerable instance", function()
      local instance = Enumerable.create({1,2,3})
      assert.are.same(instance, instance:concat(append))
    end)
  end)

  describe("reduce()", function()
    local instance = Enumerable.create({1,2,3})

    it("applies callback to each element", function()
      local callback = spy.new(function() end)

      instance:reduce(callback)

      assert.spy(callback).was.called_with(nil, 1, 1)
      assert.spy(callback).was.called_with(nil, 2, 2)
      assert.spy(callback).was.called_with(nil, 3, 3)
      assert.spy(callback).was.called(3)
    end)
    
    describe("without an initial value", function()
      local callback = function(reduce, value) return (reduce or 0) + value end

      it("returns the result of the callback applied to list items", function()
        assert.are.equal(6, instance:reduce(callback))
      end)
    end)

    describe("with an initial value", function()
      local callback = function(reduce, value) return reduce + value end

      it("begins reduction with a seeded value", function()
        assert.are.equal(16, instance:reduce(10, callback))
      end)
    end)
  end)

  describe("min()", function()
    local instance = Enumerable.create({3,5,1,4,2})

    describe("when called without a callback", function()
      it("returns the lowest value in a sequence", function()
        assert.are.equal(1, instance:min())
      end)
    end)

    describe("when called with a callback", function()
      it("applies callback to each element", function()
        local callback = spy.new(function() end)

        instance:min(callback)

        assert.spy(callback).was.called_with(3)
        assert.spy(callback).was.called_with(5)
        assert.spy(callback).was.called_with(1)
        assert.spy(callback).was.called_with(4)
        assert.spy(callback).was.called_with(2)        
        assert.spy(callback).was.called(5)
      end)
    

      it("returns the value of the item with the lowest callback result", function()
        local callback = function(v) return v == 4 and 1 or 2 end

        assert.are.equal(4, instance:min(callback))
      end)
    end)
  end)

  describe("max()", function()
    local instance = Enumerable.create({3,5,1,4,2})

    describe("when called without a callback", function()
      it("returns the highest value in a sequence", function()
        assert.are.equal(5, instance:max())
      end)
    end)

    describe("when called with a callback", function()
      it("applies callback to each element", function()
        local callback = spy.new(function() end)

        instance:max(callback)
        
        assert.spy(callback).was.called_with(3)
        assert.spy(callback).was.called_with(5)
        assert.spy(callback).was.called_with(1)
        assert.spy(callback).was.called_with(4)
        assert.spy(callback).was.called_with(2)        
        assert.spy(callback).was.called(5)
      end)
      
      it("returns the value of the item with the highest callback result", function()
        local callback = function(v) return v == 4 and 2 or 1 end

        assert.are.equal(4, instance:max(callback))
      end)
    end)
  end)

  describe("minmax()", function()
    describe("when called without a callback", function()
      local instance = Enumerable.create({3,5,1,4,2})

      it("returns the highest and lowest values in a sequence", function()
        local min, max = instance:minmax()
        assert.are.equal(1, min)
        assert.are.equal(5, max)
      end)
    end)

    describe("when called with a callback", function()
      local data = {'bbb','aaaa','c','dd'}
      local instance = Enumerable.create(data)

      it("applies callback to each element", function()
        local callback = spy.new(function() end)

        instance:minmax(callback)
     
        assert.spy(callback).was.called(8)
      end)

      it("uses callback for min and max comparison", function()
        local min, max = instance:minmax(function(v) return #v end)

        assert.are.equal('c', min)
        assert.are.equal('aaaa', max)
      end)
    end)
  end)

  describe("sort()", function()
    it("returns the enumerable instance", function()
      local instance =  Enumerable.create({5,1,4,3,2})

      assert.are.equal(instance, instance:sort())
    end)

    describe("when called without a callback", function() 
      local instance =  Enumerable.create({5,1,4,3,2})

      it("sorts elements in ascending order", function()
        assert.are.same({1,2,3,4,5}, instance:sort():data())
      end)
    end)

    describe("when called with a callback", function() 
      local instance =  Enumerable.create({5,1,4,3,2})
      local callback = function(a, b) return b < a end

      it("sorts elements based on callback result", function()
        assert.are.same({5,4,3,2,1}, instance:sort(callback):data())
      end)
    end)
  end)

  describe("push()", function()
    it("returns the enumerable instance", function()
      local instance = Enumerable.create()

      assert.are.equal(instance, instance:push(1))
    end)

    it("adds new items to the end of the list", function()
      local instance = Enumerable.create({1, 2})

      assert.are.same({1,2,3,4}, instance:push(3, 4):data())
    end)
  end)

  describe("pop()", function()
    it("returns the last item in the sequence", function()
      local instance = Enumerable.create({1,2,3})
      assert.are.equal(3, instance:pop())
    end)

    it("removes the last item ine the sequence", function()
      local instance = Enumerable.create({1,2,3})
      instance:pop()

      assert.are.same({1,2}, instance:data())
    end)
  end)

  describe("shift()", function()
    it("returns the first item in the sequence", function()
      local instance = Enumerable.create({1,2,3})
      assert.are.equal(1, instance:shift())
    end)

    it("removes the first item ine the sequence", function()
      local instance = Enumerable.create({1,2,3})
      instance:shift()

      assert.are.same({2,3}, instance:data())
    end)
  end)

  describe("unshift()", function()
    it("returns the enumerable instance", function()
      local instance = Enumerable.create()

      assert.are.equal(instance, instance:unshift(1))
    end)

    it("adds new items to the beginning of the list", function()
      local instance = Enumerable.create({1,2})

      assert.are.same({10, 11, 1, 2}, instance:unshift(10, 11):data())
    end)
  end)

  describe("find()", function()
    local instance = Enumerable.create({10, 20, 30})
    local callback = function(v) return v > 15 end

    it("finds the first element matching a callback", function()
      assert.are.equal(20, instance:find(callback))
    end)
  end)

  describe("reject()", function()
    local instance = Enumerable.create({1,2,3,4,5,6})

    it("applies callback to each element", function()
      local callback = spy.new(function() end)

      instance:reject(callback)
      
      assert.spy(callback).was.called_with(1, 1)
      assert.spy(callback).was.called_with(2, 2)
      assert.spy(callback).was.called_with(3, 3)
      assert.spy(callback).was.called_with(4, 4)
      assert.spy(callback).was.called_with(5, 5)
      assert.spy(callback).was.called_with(6, 6)
      assert.spy(callback).was.called(6)
    end)

    it("returns an instance with items removed based on callback result", function()
      local result = instance:reject(function(v) return v % 2 == 0 end)

      assert.are.same({1,3,5}, result:data())
    end)

    it("returns a new enumerable instance", function()
      local result = instance:reject(function() end)

      assert.are_not.equal(instance, result)
      assert.are.same(instance, result)
    end)
  end)

  describe("select()", function()
    local instance = Enumerable.create({1,2,3,4,5,6})
    
    it("returns an instance with items included based on callback result", function()
      local result = instance:select(function(v) return v % 2 == 0 end)

      assert.are.same({2,4,6}, result:data())
    end)

    it("returns a new enumerable instance", function()
      local result = instance:select(function() return true end)

      assert.are_not.equal(instance, result)
      assert.are.same(instance, result)
    end)
  end)

  describe("all()", function()
    local instance = Enumerable.create({10, 20, 30, 40})

    describe("when all elements match callback criteria", function()
      local callback = function(v) return v > 5 end

      it("returns true", function()
        assert.is_true(instance:all(callback))
      end)
    end)

    describe("when any elements do not match callback criteria", function()
      local callback = function(v) return v < 39 end

      it("returns false", function()
        assert.is_false(instance:all(callback))
      end)
    end)
  end)

  describe("any()", function()
    local instance = Enumerable.create({10, 20, 30, 40})

    describe("when any elements match callback criteria", function()
      local callback = function(v) return v > 35 end

      it("returns true", function()
        assert.is_true(instance:any(callback))
      end)
    end)

    describe("when no elements match callback criteria", function()
      local callback = function(v) return v > 50 end

      it("returns false", function()
        assert.is_false(instance:all(callback))
      end)
    end)
  end)

  describe("group_by()", function()
    local instance = Enumerable.create({'apple', 'amber', 'candy', 'pumpkin'})
    local callback = function(v) return string.sub(v, 1, 1) end

    it("creates multiple lists based on callback criteria", function()
      local result = instance:group_by(callback)
      local expected = {
        a = Enumerable.create({'apple', 'amber'}),
        c = Enumerable.create({'candy'}),
        p = Enumerable.create({'pumpkin'}),
      }

      assert.are.same(expected, result)
    end)
  end)

  describe("partition()", function()
    local instance = Enumerable.create({1,2,3,4})
    local callback = function(v) return v % 2 == 0 end 

    it("creates lists based on boolean callback result", function()
      local truthyResult, falseyResult = instance:partition(callback)

      assert.are.same(Enumerable.create({2,4}), truthyResult)
      assert.are.same(Enumerable.create({1,3}), falseyResult)
    end)
  end)
end)