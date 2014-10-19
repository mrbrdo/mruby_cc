GC.disable

#include 'mruby/test/assert.rb'

##
# ArgumentError ISO Test

assert('ArgumentError', '15.2.24') do
  e2 = nil
  a = []
  begin
    # this will cause an exception due to the wrong arguments
    a[]
  rescue => e1
    e2 = e1
  end

  assert_equal(Class, ArgumentError.class)
  assert_equal(ArgumentError, e2.class)
end
##
# Array ISO Test

assert('Array', '15.2.12') do
  assert_equal(Class, Array.class)
end

assert('Array inclueded modules', '15.2.12.3') do
  assert_true(Array.include?(Enumerable))
end

assert('Array.[]', '15.2.12.4.1') do
  assert_equal([1, 2, 3], Array.[](1,2,3))
end

assert('Array#+', '15.2.12.5.1') do
  assert_equal([1, 1], [1].+([1]))
end

assert('Array#*', '15.2.12.5.2') do
  assert_raise(ArgumentError) do
    # this will cause an exception due to the wrong argument
    [1].*(-1)
  end
  assert_equal([1, 1, 1], [1].*(3))
  assert_equal([], [1].*(0))
end

assert('Array#<<', '15.2.12.5.3') do
  assert_equal([1, 1], [1].<<(1))
end

assert('Array#[]', '15.2.12.5.4') do
  a = Array.new
  assert_raise(ArgumentError) do
    # this will cause an exception due to the wrong arguments
    a.[]()
  end
  assert_raise(ArgumentError) do
    # this will cause an exception due to the wrong arguments
    a.[](1,2,3)
  end

  assert_equal(2, [1,2,3].[](1))
  assert_equal(nil, [1,2,3].[](4))
  assert_equal(3, [1,2,3].[](-1))
  assert_equal(nil, [1,2,3].[](-4))

  a = [ "a", "b", "c", "d", "e" ]
  assert_equal("b", a[1.1])
  assert_equal(["b", "c"], a[1,2])
  assert_equal(["b", "c", "d"], a[1..-2])
end

assert('Array#[]=', '15.2.12.5.5') do
  a = Array.new
  assert_raise(ArgumentError) do
    # this will cause an exception due to the wrong arguments
    a.[]=()
  end
  assert_raise(ArgumentError) do
    # this will cause an exception due to the wrong arguments
    a.[]=(1,2,3,4)
  end
  assert_raise(IndexError) do
    # this will cause an exception due to the wrong arguments
    a = [1,2,3,4,5]
    a[1, -1] = 10
  end

  assert_equal(4, [1,2,3].[]=(1,4))
  assert_equal(3, [1,2,3].[]=(1,2,3))

  a = [1,2,3,4,5]
  a[3..-1] = 6
  assert_equal([1,2,3,6], a)

  a = [1,2,3,4,5]
  a[3..-1] = []
  assert_equal([1,2,3], a)

  a = [1,2,3,4,5]
  a[2...4] = 6
  assert_equal([1,2,6,5], a)
end

assert('Array#clear', '15.2.12.5.6') do
  a = [1]
  a.clear
  assert_equal([], a)
end

assert('Array#collect!', '15.2.12.5.7') do
  a = [1,2,3]
  a.collect! { |i| i + i }
  assert_equal([2,4,6], a)
end

assert('Array#concat', '15.2.12.5.8') do
  assert_equal([1,2,3,4], [1, 2].concat([3, 4]))
end

assert('Array#delete_at', '15.2.12.5.9') do
  a = [1,2,3]
  assert_equal(2, a.delete_at(1))
  assert_equal([1,3], a)
  assert_equal(nil, a.delete_at(3))
  assert_equal([1,3], a)
  assert_equal(nil, a.delete_at(-3))
  assert_equal([1,3], a)
  assert_equal(3, a.delete_at(-1))
  assert_equal([1], a)
end

assert('Array#each', '15.2.12.5.10') do
  a = [1,2,3]
  b = 0
  a.each {|i| b += i}
  assert_equal(6, b)
end

assert('Array#each_index', '15.2.12.5.11') do
  a = [1]
  b = nil
  a.each_index {|i| b = i}
  assert_equal(0, b)
end

assert('Array#empty?', '15.2.12.5.12') do
  a = []
  b = [b]
  assert_true([].empty?)
  assert_false([1].empty?)
end

assert('Array#first', '15.2.12.5.13') do
  assert_raise(ArgumentError) do
    # this will cause an exception due to the wrong argument
    [1,2,3].first(-1)
  end
  assert_raise(ArgumentError) do
    # this will cause an exception due to the wrong argument
    [1,2,3].first(1,2)
  end

  assert_nil([].first)

  b = [1,2,3]
  assert_equal(1, b.first)
  assert_equal([], b.first(0))
  assert_equal([1], b.first(1))
  assert_equal([1,2,3], b.first(4))
end

assert('Array#index', '15.2.12.5.14') do
  a = [1,2,3]

  assert_equal(1, a.index(2))
  assert_equal(nil, a.index(0))
end

assert('Array#initialize', '15.2.12.5.15') do
  a = [].initialize(1)
  b = [].initialize(2)
  c = [].initialize(2, 1)
  d = [].initialize(2) {|i| i}

  assert_equal([nil], a)
  assert_equal([nil,nil], b)
  assert_equal([1,1], c)
  assert_equal([0,1], d)
end

assert('Array#initialize_copy', '15.2.12.5.16') do
  a = [1,2,3]
  b = [].initialize_copy(a)

  assert_equal([1,2,3], b)
end

assert('Array#join', '15.2.12.5.17') do
  a = [1,2,3].join
  b = [1,2,3].join(',')

  assert_equal('123', a)
  assert_equal('1,2,3', b)
end

assert('Array#last', '15.2.12.5.18') do
  assert_raise(ArgumentError) do
    # this will cause an exception due to the wrong argument
    [1,2,3].last(-1)
  end

  a = [1,2,3]
  assert_equal(3, a.last)
  assert_nil([].last)
end

assert('Array#length', '15.2.12.5.19') do
  a = [1,2,3]

  assert_equal(3, a.length)
end

assert('Array#map!', '15.2.12.5.20') do
  a = [1,2,3]
  a.map! { |i| i + i }
  assert_equal([2,4,6], a)
end

assert('Array#pop', '15.2.12.5.21') do
  a = [1,2,3]
  b = a.pop

  assert_nil([].pop)
  assert_equal([1,2], a)
  assert_equal(3, b)
end

assert('Array#push', '15.2.12.5.22') do
  a = [1,2,3]
  b = a.push(4)

  assert_equal([1,2,3,4], a)
  assert_equal([1,2,3,4], b)
end

assert('Array#replace', '15.2.12.5.23') do
  a = [1,2,3]
  b = [].replace(a)

  assert_equal([1,2,3], b)
end

assert('Array#reverse', '15.2.12.5.24') do
  a = [1,2,3]
  b = a.reverse

  assert_equal([1,2,3], a)
  assert_equal([3,2,1], b)
end

assert('Array#reverse!', '15.2.12.5.25') do
  a = [1,2,3]
  b = a.reverse!

  assert_equal([3,2,1], a)
  assert_equal([3,2,1], b)
end

assert('Array#rindex', '15.2.12.5.26') do
  a = [1,2,3]

  assert_equal(1, a.rindex(2))
  assert_equal(nil, a.rindex(0))
end

assert('Array#shift', '15.2.12.5.27') do
  a = [1,2,3]
  b = a.shift

  assert_nil([].shift)
  assert_equal([2,3], a)
  assert_equal(1, b)
end

assert('Array#size', '15.2.12.5.28') do
  a = [1,2,3]

  assert_equal(3, a.size)
end

assert('Array#slice', '15.2.12.5.29') do
  a = "12345".slice(1, 3)
  b = a.slice(0)

  assert_equal("2:", "#{b}:")
  assert_equal(2, [1,2,3].[](1))
end

assert('Array#unshift', '15.2.12.5.30') do
  a = [2,3]
  b = a.unshift(1)
  c = [2,3]
  d = c.unshift(0, 1)

  assert_equal([1,2,3], a)
  assert_equal([1,2,3], b)
  assert_equal([0,1,2,3], c)
  assert_equal([0,1,2,3], d)
end

assert('Array#to_s', '15.2.12.5.31 / 15.2.12.5.32') do
  a = [2, 3,   4, 5]
  r1 = a.to_s
  r2 = a.inspect

  assert_equal(r2, r1)
  assert_equal("[2, 3, 4, 5]", r1)
end

assert('Array#==', '15.2.12.5.33') do
  assert_false(["a", "c"] == ["a", "c", 7])
  assert_true(["a", "c", 7] == ["a", "c", 7])
  assert_false(["a", "c", 7] == ["a", "d", "f"])
end

assert('Array#eql?', '15.2.12.5.34') do
  a1 = [ 1, 2, 3 ]
  a2 = [ 1, 2, 3 ]
  a3 = [ 1.0, 2.0, 3.0 ]

  assert_true(a1.eql? a2)
  assert_false(a1.eql? a3)
end

assert('Array#hash', '15.2.12.5.35') do
  a = [ 1, 2, 3 ]

  assert_true(a.hash.is_a? Integer)
  assert_equal([1,2].hash, [1,2].hash)
end

assert('Array#<=>', '15.2.12.5.36') do
  r1 = [ "a", "a", "c" ]    <=> [ "a", "b", "c" ]   #=> -1
  r2 = [ 1, 2, 3, 4, 5, 6 ] <=> [ 1, 2 ]            #=> +1
  r3 = [ "a", "b", "c" ]    <=> [ "a", "b", "c" ]   #=> 0

  assert_equal(-1, r1)
  assert_equal(+1, r2)
  assert_equal(0, r3)
end

# Not ISO specified

assert("Array (Shared Array Corruption)") do
  a = [ "a", "b", "c", "d", "e", "f" ]
  b = a.slice(1, 3)
  a.clear
  b.clear
end

##
# BasicObject

assert('BasicObject') do
  assert_equal(Class, BasicObject.class)
end

assert('BasicObject superclass') do
  assert_nil(BasicObject.superclass)
end

##
# Bootstrap tests for blocks

assert('BS Block 1') do
  assert_equal(1) do
    1.times{
      begin
        a = 1
      ensure
        foo = nil
      end
    }
  end
end

assert('BS Block 2') do
  assert_equal 2, [1,2,3].find{|x| x == 2}
end

assert('BS Block 3') do
  class E
    include Enumerable
    def each(&block)
      [1, 2, 3].each(&block)
    end
  end
  assert_equal 2, E.new.find {|x| x == 2 }
end

assert('BS Block 3') do
  sum = 0
  for x in [1, 2, 3]
    sum += x
  end
  assert_equal 6, sum
end

assert('BS Block 4') do
  sum = 0
  for x in (1..5)
    sum += x
  end
  assert_equal 15, sum
end

assert('BS Block 5') do
  sum = 0
  for x in []
    sum += x
  end
  assert_equal 0, sum
end

assert('BS Block 6') do
  ans = []
  assert_equal(1) do
    1.times{
      for n in 1..3
        a = n
        ans << a
      end
    }
  end
end

assert('BS Block 7') do
  ans = []
  assert_equal((1..3)) do
    for m in 1..3
      for n in 2..4
        a = [m, n]
        ans << a
      end
    end
  end
end

assert('BS Block 8') do
  assert_equal [1, 2, 3], (1..3).to_a
end

assert('BS Block 9') do
  assert_equal([4, 8, 12]) do
    (1..3).map{|e|
      e * 4
    }
  end
end

assert('BS Block 10') do
  def m
    yield
  end
  def n
    yield
  end

  assert_equal(100) do
    m{
      n{
        100
      }
    }
  end
end

assert('BS Block 11') do
  def m
    yield 1
  end

  assert_equal(20) do
    m{|ib|
      m{|jb|
        i = 20
      }
    }
  end
end

assert('BS Block 12') do
  def m
    yield 1
  end

  assert_equal(2) do
    m{|ib|
      m{|jb|
        ib = 20
        kb = 2
      }
    }
  end
end

assert('BS Block 13') do
  def iter1
    iter2{
      yield
    }
  end

  def iter2
    yield
  end

  assert_equal(3) do
    iter1{
      jb = 2
      iter1{
        jb = 3
      }
      jb
    }
  end
end

assert('BS Block 14') do
  def iter1
    iter2{
      yield
    }
  end

  def iter2
    yield
  end

  assert_equal(2) do
    iter1{
      jb = 2
      iter1{
        jb
      }
      jb
    }
  end
end

assert('BS Block 15') do
  def m
    yield 1
  end
  assert_equal(2) do
    m{|ib|
      ib*2
    }
  end
end

assert('BS Block 16') do
  def m
    yield 12345, 67890
  end
  assert_equal(92580) do
    m{|ib,jb|
      ib*2+jb
    }
  end
end

assert('BS Block 17') do
  def iter
    yield 10
  end

  a = nil
  assert_equal [10, nil] do
    [iter{|a|
      a
    }, a]
  end
end

assert('BS Block 18') do
  def iter
    yield 10
  end

  assert_equal(21) do
    iter{|a|
      iter{|a|
        a + 1
      } + a
    }
  end
end

assert('BS Block 19') do
  def iter
    yield 10, 20, 30, 40
  end

  a = b = c = d = nil
  assert_equal([10, 20, 30, 40, nil, nil, nil, nil]) do
    iter{|a, b, c, d|
      [a, b, c, d]
    } + [a, b, c, d]
  end
end

assert('BS Block 20') do
  def iter
    yield 10, 20, 30, 40
  end

  a = b = nil
  assert_equal([10, 20, 30, 40, nil, nil]) do
    iter{|a, b, c, d|
      [a, b, c, d]
    } + [a, b]
  end
end

assert('BS Block 21') do
  def iter
    yield 1, 2
  end

  assert_equal([1, [2]]) do
    iter{|a, *b|
      [a, b]
    }
  end
end

assert('BS Block 22') do
  def iter
    yield 1, 2
  end

  assert_equal([[1, 2]]) do
    iter{|*a|
      [a]
    }
  end
end

assert('BS Block 23') do
  def iter
    yield 1, 2
  end

  assert_equal([1, 2, []]) do
    iter{|a, b, *c|
      [a, b, c]
    }
  end
end

assert('BS Block 24') do
  def m
    yield
  end
  assert_equal(1) do
    m{
      1
    }
  end
end

assert('BS Block 25') do
  def m
    yield 123
  end
  assert_equal(15129) do
    m{|ib|
      m{|jb|
        ib*jb
      }
    }
  end
end

assert('BS Block 26') do
  def m a
    yield a
  end
  assert_equal(2) do
    m(1){|ib|
      m(2){|jb|
        ib*jb
      }
    }
  end
end

assert('BS Block 27') do
  sum = 0
  3.times{|ib|
    2.times{|jb|
      sum += ib + jb
    }}
  assert_equal sum, 9
end

assert('BS Block 28') do
  assert_equal(10) do
    3.times{|bl|
      break 10
    }
  end
end

assert('BS Block 29') do
  def iter
    yield 1,2,3
  end

  assert_equal([1, 2]) do
    iter{|i, j|
      [i, j]
    }
  end
end

assert('BS Block 30') do
  def iter
    yield 1
  end

  assert_equal([1, nil]) do
    iter{|i, j|
      [i, j]
    }
  end
end

assert('BS Block [ruby-dev:31147]') do
  def m
    yield
  end
  assert_nil m{|&b| b}
end

assert('BS Block [ruby-dev:31160]') do
  def m()
    yield
  end
  assert_nil m {|(v,(*))|}
end

assert('BS Block [issue #750]') do
  def m(a, *b)
    yield
  end
  args = [1, 2, 3]
  assert_equal m(*args){ 1 }, 1
end

assert('BS Block 31') do
  def m()
    yield
  end
  assert_nil m {|((*))|}
end

assert('BS Block [ruby-dev:31440]') do
  def m
    yield [0]
  end
  assert_equal m{|v, &b| v}, [0]
end

assert('BS Block 32') do
  r = false; 1.times{|&b| r = b}
  assert_equal NilClass, r.class
end

assert('BS Block [ruby-core:14395]') do
  class Controller
    def respond_to(&block)
      responder = Responder.new
      block.call(responder)
      responder.respond
    end
    def test_for_bug
      respond_to{|format|
        format.js{
          "in test"
          render{|obj|
            obj
          }
        }
      }
    end
    def render(&block)
      "in render"
    end
  end

  class Responder
    def method_missing(symbol, &block)
      "enter method_missing"
      @response = Proc.new{
        'in method missing'
        block.call
      }
      "leave method_missing"
    end
    def respond
      @response.call
    end
  end
  t = Controller.new
  assert_true t.test_for_bug
end

assert("BS Block 33") do
  module TestReturnFromNestedBlock
    def self.test
      1.times do
        1.times do
          return :ok
        end
      end
      :bad
    end
  end
  assert_equal :ok, TestReturnFromNestedBlock.test
end

assert("BS Block 34") do
  module TestReturnFromNestedBlock_BSBlock34
    def self.test
      1.times do
        while true
          return :ok
        end
      end
      :bad
    end
  end
  assert_equal :ok, TestReturnFromNestedBlock_BSBlock34.test
end

assert("BS Block 35") do
  module TestReturnFromNestedBlock_BSBlock35
    def self.test
      1.times do
        until false
          return :ok
        end
      end
      :bad
    end
  end
  assert_equal :ok, TestReturnFromNestedBlock_BSBlock35.test
end

assert('BS Block 36') do
  def iter
    yield 1, 2, 3, 4, 5
  end

  assert_equal([1, 2, [3, 4], 5]) do
    iter{|a, b, *c, d|
      [a, b, c, d]
    }
  end
end

assert('BS Block 37') do
  def iter
    yield 1, 2, 3
  end

  assert_equal([1, 2, [], 3]) do
    iter{|a, b, *c, d|
      [a, b, c, d]
    }
  end
end

assert('BS Block 38') do
  def iter
    yield 1,2,3,4,5,6
  end

  assert_equal [1,2,3,4,5], iter{|a,b,c=:c,d,e| [a,b,c,d,e]}
end
##
# Bootstrap test for literals

assert('BS Literal 1') do
  assert_true true
end

assert('BS Literal 2') do
  assert_equal TrueClass, true.class
end

assert('BS Literal 3') do
  assert_false false
end

assert('BS Literal 4') do
  assert_equal FalseClass, false.class
end

assert('BS Literal 5') do
  assert_equal 'nil', nil.inspect
end

assert('BS Literal 6') do
  assert_equal NilClass, nil.class
end

assert('BS Literal 7') do
  assert_equal Symbol, :sym.class
end

assert('BS Literal 8') do
  assert_equal 1234, 1234
end

assert('BS Literal 9') do
  assert_equal Fixnum, 1234.class
end
##
# Class ISO Test

assert('Class', '15.2.3') do
  assert_equal(Class, Class.class)
end

assert('Class#initialize', '15.2.3.3.1') do
  c = Class.new do
    def test
      :test
    end
  end.new

  assert_equal(c.test, :test)
end

assert('Class#initialize_copy', '15.2.3.3.2') do
  class TestClass
    attr_accessor :n
    def initialize(n)
      @n = n
    end
    def initialize_copy(obj)
      @n = n
    end
  end

  c1 = TestClass.new('Foo')
  c2 = c1.dup
  c3 = TestClass.new('Bar')

  assert_equal(c1.n, c2.n)
  assert_not_equal(c1.n, c3.n)
end

assert('Class#new', '15.2.3.3.3') do
  assert_raise(TypeError, 'Singleton should raise TypeError') do
    "a".singleton_class.new
  end

  class TestClass
    def initialize args, &block
      @result = if not args.nil? and block.nil?
        # only arguments
        :only_args
      elsif not args.nil? and not block.nil?
        # args and block is given
        :args_and_block
      else
        # this should never happen
        :broken
      end
    end

    def result; @result; end
  end

  assert_equal(:only_args, TestClass.new(:arg).result)
  # with block doesn't work yet
end

assert('Class#superclass', '15.2.3.3.4') do
  class SubClass < String; end
  assert_equal(String, SubClass.superclass)
end

# Not ISO specified

assert('Class 1') do
  class C1; end
  assert_equal(Class, C1.class)
end

assert('Class 2') do
  class C2; end
  assert_equal(C2, C2.new.class)
end

assert('Class 3') do
  class C3; end
  assert_equal(Class, C3.new.class.class)
end

assert('Class 4') do
  class C4_A; end
  class C4 < C4_A; end
  assert_equal(Class, C4.class)
end

assert('Class 5') do
  class C5_A; end
  class C5 < C5_A; end
  assert_equal(C5, C5.new.class)
end

assert('Class 6') do
  class C6_A; end
  class C6 < C6_A; end
  assert_equal(Class, C6.new.class.class)
end

assert('Class 7') do
  class C7_A; end
  class C7_B; end

  class C7 < C7_A; end

  assert_raise(TypeError) do
    # Different superclass.
    class C7 < C7_B; end
  end
end

assert('Class 8') do
  class C8_A; end

  class C8; end  # superclass is Object

  assert_raise(TypeError) do
    # Different superclass.
    class C8 < C8_A; end
  end
end

assert('Class 9') do
  Class9Const = "a"

  assert_raise(TypeError) do
    class Class9Const; end
  end
end

assert('Class Module 1') do
  module M; end
  assert_equal(Module, M.class)
end

assert('Class Module 2') do
  module M; end
  class C; include M; end
  assert_equal(C, C.new.class)
end

# nested class
assert('Class Nested 1') do
  class A; end
  class A::B; end
  assert_equal(A::B, A::B)
end

assert('Class Nested 2') do
  class A; end
  class A::B; end
  assert_equal(A::B, A::B.new.class)
end

assert('Class Nested 3') do
  class A; end
  class A::B; end
  assert_equal(Class, A::B.new.class.class)
end

assert('Class Nested 4') do
  class A; end
  class A::B; end
  class A::B::C; end
  assert_equal(A::B::C, A::B::C)
end

assert('Class Nested 5') do
  class A; end
  class A::B; end
  class A::B::C; end
  assert_equal(Class, A::B::C.class)
end

assert('Class Nested 6') do
  class A; end
  class A::B; end
  class A::B::C; end
  assert_equal(A::B::C, A::B::C.new.class)
end

assert('Class Nested 7') do
  class A; end
  class A::B; end
  class A::B2 < A::B; end
  assert_equal(A::B2, A::B2)
end

assert('Class Nested 8') do
  class A; end
  class A::B; end
  class A::B2 < A::B; end
  assert_equal(Class, A::B2.class)
end

assert('Class Colon 1') do
  class A; end
  A::C = 1
  assert_equal(1, A::C)
end

assert('Class Colon 2') do
  class A; class ::C; end end
  assert_equal(C, C)
end

assert('Class Colon 3') do
  class A; class ::C; end end
  assert_equal(Class, C.class)
end

assert('Class Dup 1') do
  class C; end
  assert_equal(Class, C.dup.class)
end

assert('Class Dup 2') do
  module M; end
  assert_equal(Module, M.dup.class)
end

assert('Class.new') do
  assert_equal(Class, Class.new.class)
  a = []
  klass = Class.new do |c|
    a << c
  end
  assert_equal([klass], a)
end

assert('class to return the last value') do
  m = class C; :m end
  assert_equal(m, :m)
end

assert('raise when superclass is not a class') do
  module FirstModule; end
  assert_raise(TypeError, 'should raise TypeError') do
    class FirstClass < FirstModule; end
  end

  class SecondClass; end
  assert_raise(TypeError, 'should raise TypeError') do
    class SecondClass < false; end
  end

  class ThirdClass; end
  assert_raise(TypeError, 'should raise TypeError') do
    class ThirdClass < ThirdClass; end
  end
end

assert('Class#inherited') do
  class Foo
    @@subclass_name = nil
    def self.inherited(subclass)
      @@subclass_name = subclass
    end
    def self.subclass_name
      @@subclass_name
    end
  end

  assert_equal(nil, Foo.subclass_name)

  class Bar < Foo
  end

  assert_equal(Bar, Foo.subclass_name)

  class Baz < Bar
  end

  assert_equal(Baz, Foo.subclass_name)
end

assert('singleton tests') do
  module FooMod
    def run_foo_mod
      100
    end
  end

  bar = String.new

  baz = class << bar
    extend FooMod
    def self.run_baz
      200
    end
  end

  assert_false baz.singleton_methods.include? :run_foo_mod
  assert_false baz.singleton_methods.include? :run_baz

  assert_raise(NoMethodError, 'should raise NoMethodError') do
    baz.run_foo_mod
  end
  assert_raise(NoMethodError, 'should raise NoMethodError') do
    baz.run_baz
  end

  assert_raise(NoMethodError, 'should raise NoMethodError') do
    bar.run_foo_mod
  end
  assert_raise(NoMethodError, 'should raise NoMethodError') do
    bar.run_baz
  end

  baz = class << bar
    extend FooMod
    def self.run_baz
      300
    end
    self
  end

  assert_true baz.singleton_methods.include? :run_baz
  assert_true baz.singleton_methods.include? :run_foo_mod
  assert_equal 100, baz.run_foo_mod
  assert_equal 300, baz.run_baz

  assert_raise(NoMethodError, 'should raise NoMethodError') do
    bar.run_foo_mod
  end
  assert_raise(NoMethodError, 'should raise NoMethodError') do
    bar.run_baz
  end

  fv = false
  class << fv
    def self.run_false
      5
    end
  end

  nv = nil
  class << nv
    def self.run_nil
      6
    end
  end

  tv = true
  class << tv
    def self.run_nil
      7
    end
  end

  assert_raise(TypeError, 'should raise TypeError') do
    num = 1.0
    class << num
      def self.run_nil
        7
      end
    end
  end
end

assert('clone Class') do
  class Foo
    def func
      true
    end
  end

  Foo.clone.new.func
end

assert('class variable and class << self style class method') do
  class ClassVariableTest
    @@class_variable = "value"
    class << self
      def class_variable
        @@class_variable
      end
    end
  end

  assert_equal("value", ClassVariableTest.class_variable)
end

assert('Comparable#<', '15.3.3.2.1') do
  class Foo
    include Comparable
    def <=>(x)
      x
    end
  end
  assert_false(Foo.new < 0)
  assert_false(Foo.new < 1)
  assert_true(Foo.new < -1)
  assert_raise(ArgumentError){ Foo.new < nil }
end

assert('Comparable#<=', '15.3.3.2.2') do
  class Foo
    include Comparable
    def <=>(x)
      x
    end
  end
  assert_true(Foo.new <= 0)
  assert_false(Foo.new <= 1)
  assert_true(Foo.new <= -1)
  assert_raise(ArgumentError){ Foo.new <= nil }
end

assert('Comparable#==', '15.3.3.2.3') do
  class Foo
    include Comparable
    def <=>(x)
      0
    end
  end

  assert_true(Foo.new == Foo.new)
end

assert('Comparable#>', '15.3.3.2.4') do
  class Foo
    include Comparable
    def <=>(x)
      x
    end
  end
  assert_false(Foo.new > 0)
  assert_true(Foo.new > 1)
  assert_false(Foo.new > -1)
  assert_raise(ArgumentError){ Foo.new > nil }
end

assert('Comparable#>=', '15.3.3.2.5') do
  class Foo
    include Comparable
    def <=>(x)
      x
    end
  end
  assert_true(Foo.new >= 0)
  assert_true(Foo.new >= 1)
  assert_false(Foo.new >= -1)
  assert_raise(ArgumentError){ Foo.new >= nil }
end

assert('Comparable#between?', '15.3.3.2.6') do
  class Foo
    include Comparable
    def <=>(x)
      x
    end
  end

  c = Foo.new

  assert_false(c.between?(-1,  1))
  assert_false(c.between?(-1, -1))
  assert_false(c.between?( 1,  1))
  assert_true(c.between?( 1, -1))
  assert_true(c.between?(0, 0))
end
##
# Enumerable ISO Test

assert('Enumerable', '15.3.2') do
  assert_equal(Module, Enumerable.class)
end

assert('Enumerable#all?', '15.3.2.2.1') do
  assert_true([1,2,3].all?)
  assert_false([1,false,3].all?)

  a = [2,4,6]
  all = a.all? do |e|
    e % 2 == 0
  end
  assert_true(all)

  a = [2,4,7]
  all = a.all? do |e|
    e % 2 == 0
  end
  assert_false(all)
end

assert('Enumerable#any?', '15.3.2.2.2') do
  assert_true([false,true,false].any?)
  assert_false([false,false,false].any?)

  a = [1,3,6]
  any = a.any? do |e|
    e % 2 == 0
  end
  assert_true(any)

  a = [1,3,5]
  any = a.any? do |e|
    e % 2 == 0
  end
  assert_false(any)
end

assert('Enumerable#collect', '15.3.2.2.3') do
  assert_true [1,2,3].collect { |i| i + i } == [2,4,6]
end

assert('Enumerable#detect', '15.3.2.2.4') do
  assert_equal 1, [1,2,3].detect() { true }
  assert_equal 'a', [1,2,3].detect("a") { false }
end

assert('Array#each_with_index', '15.3.2.2.5') do
  a = nil
  b = nil

  [1].each_with_index {|e,i| a = e; b = i}

  assert_equal(1, a)
  assert_equal(0, b)
end

assert('Enumerable#entries', '15.3.2.2.6') do
  assert_equal([1], [1].entries)
end

assert('Enumerable#find', '15.3.2.2.7') do
  assert_equal 1, [1,2,3].find() { true }
  assert_equal 'a', [1,2,3].find("a") { false }
end

assert('Enumerable#find_all', '15.3.2.2.8') do
  assert_true [1,2,3,4,5,6,7,8,9].find_all() {|i| i%2 == 0}, [2,4,6,8]
end

assert('Enumerable#grep', '15.3.2.2.9') do
  assert_equal [4,5,6], [1,2,3,4,5,6,7,8,9].grep(4..6)
end

assert('Enumerable#include?', '15.3.2.2.10') do
  assert_true [1,2,3,4,5,6,7,8,9].include?(5)
  assert_false [1,2,3,4,5,6,7,8,9].include?(0)
end

assert('Enumerable#inject', '15.3.2.2.11') do
  assert_equal 21, [1,2,3,4,5,6].inject() {|s, n| s + n}
  assert_equal 22, [1,2,3,4,5,6].inject(1) {|s, n| s + n}
end

assert('Enumerable#map', '15.3.2.2.12') do
  assert_equal [2,4,6], [1,2,3].map { |i| i + i }
end

assert('Enumerable#max', '15.3.2.2.13') do
  a = ['aaa', 'bb', 'c']
  assert_equal 'c', a.max
  assert_equal 'aaa', a.max {|i1,i2| i1.length <=> i2.length}
end

assert('Enumerable#min', '15.3.2.2.14') do
  a = ['aaa', 'bb', 'c']
  assert_equal 'aaa', a.min
  assert_equal 'c', a.min {|i1,i2| i1.length <=> i2.length}
end

assert('Enumerable#member?', '15.3.2.2.15') do
  assert_true [1,2,3,4,5,6,7,8,9].member?(5)
  assert_false [1,2,3,4,5,6,7,8,9].member?(0)
end

assert('Enumerable#partition', '15.3.2.2.16') do
  partition = [0,1,2,3,4,5,6,7,8,9].partition do |i|
    i % 2 == 0
  end
  assert_equal [[0,2,4,6,8], [1,3,5,7,9]], partition
end

assert('Enumerable#reject', '15.3.2.2.17') do
  reject = [0,1,2,3,4,5,6,7,8,9].reject do |i|
    i % 2 == 0
  end
  assert_equal [1,3,5,7,9], reject
end

assert('Enumerable#select', '15.3.2.2.18') do
  assert_equal [2,4,6,8], [1,2,3,4,5,6,7,8,9].select() {|i| i%2 == 0}
end

assert('Enumerable#sort', '15.3.2.2.19') do
  assert_equal [1,2,3,4,6,7], [7,3,1,2,6,4].sort
  assert_equal [7,6,4,3,2,1], [7,3,1,2,6,4].sort {|e1,e2|e2<=>e1}
end

assert('Enumerable#to_a', '15.3.2.2.20') do
  assert_equal [1], [1].to_a
end
##
# Exception ISO Test

assert('Exception', '15.2.22') do
  assert_equal Class, Exception.class
end

assert('Exception.exception', '15.2.22.4.1') do
  e = Exception.exception('a')

  assert_equal Exception, e.class
end

assert('Exception#exception', '15.2.22.5.1') do
  e = Exception.new
  re = RuntimeError.new
  assert_equal e, e.exception
  assert_equal e, e.exception(e)
  assert_equal re, re.exception(re)
  changed_re = re.exception('message has changed')
  assert_not_equal re, changed_re
  assert_equal 'message has changed', changed_re.message
end

assert('Exception#message', '15.2.22.5.2') do
  e = Exception.exception('a')

  assert_equal 'a', e.message
end

assert('Exception#to_s', '15.2.22.5.3') do
  e = Exception.exception('a')

  assert_equal 'a', e.to_s
end

assert('Exception.exception', '15.2.22.4.1') do
  e = Exception.exception()
  e.initialize('a')

  assert_equal 'a', e.message
end

assert('NameError', '15.2.31') do
  assert_raise(NameError) do
    raise NameError.new
  end

  e = NameError.new "msg", "name"
  assert_equal "msg", e.message
  assert_equal "name", e.name
end

assert('ScriptError', '15.2.37') do
  assert_raise(ScriptError) do
    raise ScriptError.new
  end
end

assert('SyntaxError', '15.2.38') do
  assert_raise(SyntaxError) do
    raise SyntaxError.new
  end
end

# Not ISO specified

assert('Exception 1') do
r=begin
    1+1
  ensure
    2+2
  end
  assert_equal 2, r
end

assert('Exception 2') do
r=begin
    1+1
    begin
      2+2
    ensure
      3+3
    end
  ensure
    4+4
  end
  assert_equal 4, r
end

assert('Exception 3') do
r=begin
    1+1
    begin
      2+2
    ensure
      3+3
    end
  ensure
    4+4
    begin
      5+5
    ensure
      6+6
    end
  end
  assert_equal 4, r
end

assert('Exception 4') do
  a = nil
  1.times{|e|
    begin
    rescue => err
    end
    a = err.class
  }
  assert_equal NilClass, a
end

assert('Exception 5') do
  $ans = []
  def m
    $!
  end
  def m2
    1.times{
      begin
        return
      ensure
        $ans << m
      end
    }
  end
  m2
  assert_equal [nil], $ans
end

assert('Exception 6') do
  $i = 0
  def m
    iter{
      begin
        $i += 1
        begin
          $i += 2
          break
        ensure

        end
      ensure
        $i += 4
      end
      $i = 0
    }
  end

  def iter
    yield
  end
  m
  assert_equal 7, $i
end

assert('Exception 7') do
  $i = 0
  def m
    begin
      $i += 1
      begin
        $i += 2
        return
      ensure
        $i += 3
      end
    ensure
      $i += 4
    end
    p :end
  end
  m
  assert_equal 10, $i
end

assert('Exception 8') do
r=begin
    1
  rescue
    2
  else
    3
  end
  assert_equal 3, r
end

assert('Exception 9') do
r=begin
    1+1
  rescue
    2+2
  else
    3+3
  ensure
    4+4
  end
  assert_equal 6, r
end

assert('Exception 10') do
r=begin
    1+1
    begin
      2+2
    rescue
      3+3
    else
      4+4
    end
  rescue
    5+5
  else
    6+6
  ensure
    7+7
  end
  assert_equal 12, r
end

assert('Exception 11') do
  a = :ok
  begin
    begin
      raise Exception
    rescue
      a = :ng
    end
  rescue Exception
  end
  assert_equal :ok, a
end

assert('Exception 12') do
  a = :ok
  begin
    raise Exception rescue a = :ng
  rescue Exception
  end
  assert_equal :ok, a
end

assert('Exception 13') do
  a = :ng
  begin
    raise StandardError
  rescue TypeError, ArgumentError
    a = :ng
  rescue
    a = :ok
  else
    a = :ng
  end
  assert_equal :ok, a
end

assert('Exception 14') do
  def exception_test14; UnknownConstant; end
  a = :ng
  begin
    send(:exception_test14)
  rescue
    a = :ok
  end

  assert_equal :ok, a
end

assert('Exception 15') do
  a = begin
        :ok
      rescue
        :ko
      end
  assert_equal :ok, a
end

assert('Exception 16') do
  begin
    raise "foo"
    false
  rescue => e
    assert_equal "foo", e.message
  end
end

assert('Exception 17') do
r=begin
    raise "a"  # RuntimeError
  rescue ArgumentError
    1
  rescue StandardError
    2
  else
    3
  ensure
    4
  end
  assert_equal 2, r
end

assert('Exception 18') do
r=begin
    0
  rescue ArgumentError
    1
  rescue StandardError
    2
  else
    3
  ensure
    4
  end
  assert_equal 3, r
end

assert('Exception#inspect without message') do
  assert_equal "Exception: Exception", Exception.new.inspect
end

assert('Raise in rescue') do
  assert_raise(ArgumentError) do
    begin
      raise "" # RuntimeError
    rescue
      raise ArgumentError
    end
  end
end
##
# FalseClass ISO Test

assert('FalseClass', '15.2.6') do
  assert_equal Class, FalseClass.class
end

assert('FalseClass false', '15.2.6.1') do
  assert_false false
  assert_equal FalseClass, false.class
  assert_false FalseClass.method_defined? :new
end

assert('FalseClass#&', '15.2.6.3.1') do
  assert_false false.&(true)
  assert_false false.&(false)
end

assert('FalseClass#^', '15.2.6.3.2') do
  assert_true false.^(true)
  assert_false false.^(false)
end

assert('FalseClass#to_s', '15.2.6.3.3') do
  assert_equal 'false', false.to_s
end

assert('FalseClass#|', '15.2.6.3.4') do
  assert_true false.|(true)
  assert_false false.|(false)
end
##
# Float ISO Test

assert('Float', '15.2.9') do
  assert_equal Class, Float.class
end

assert('Float#+', '15.2.9.3.1') do
  a = 3.123456788 + 0.000000001
  b = 3.123456789 + 1

  assert_float(3.123456789, a)
  assert_float(4.123456789, b)

  assert_raise(TypeError){ 0.0+nil }
  assert_raise(TypeError){ 1.0+nil }
end

assert('Float#-', '15.2.9.3.2') do
  a = 3.123456790 - 0.000000001
  b = 5.123456789 - 1

  assert_float(3.123456789, a)
  assert_float(4.123456789, b)
end

assert('Float#*', '15.2.9.3.3') do
  a = 3.125 * 3.125
  b = 3.125 * 1

  assert_float(9.765625, a)
  assert_float(3.125   , b)
end

assert('Float#/', '15.2.9.3.4') do
  a = 3.123456789 / 3.123456789
  b = 3.123456789 / 1

  assert_float(1.0        , a)
  assert_float(3.123456789, b)
end

assert('Float#%', '15.2.9.3.5') do
  a = 3.125 % 3.125
  b = 3.125 % 1

  assert_float(0.0  , a)
  assert_float(0.125, b)
end

assert('Float#<=>', '15.2.9.3.6') do
  a = 3.125 <=> 3.123
  b = 3.125 <=> 3.125
  c = 3.125 <=> 3.126
  a2 = 3.125 <=> 3
  c2 = 3.125 <=> 4

  assert_equal( 1, a)
  assert_equal( 0, b)
  assert_equal(-1, c)
  assert_equal( 1, a2)
  assert_equal(-1, c2)
end

assert('Float#==', '15.2.9.3.7') do
  assert_true 3.1 == 3.1
  assert_false 3.1 == 3.2
end

assert('Float#ceil', '15.2.9.3.8') do
  a = 3.123456789.ceil
  b = 3.0.ceil
  c = -3.123456789.ceil
  d = -3.0.ceil

  assert_equal( 4, a)
  assert_equal( 3, b)
  assert_equal(-3, c)
  assert_equal(-3, d)
end

assert('Float#finite?', '15.2.9.3.9') do
  assert_true 3.123456789.finite?
  assert_false (1.0 / 0.0).finite?
end

assert('Float#floor', '15.2.9.3.10') do
  a = 3.123456789.floor
  b = 3.0.floor
  c = -3.123456789.floor
  d = -3.0.floor

  assert_equal( 3, a)
  assert_equal( 3, b)
  assert_equal(-4, c)
  assert_equal(-3, d)
end

assert('Float#infinite?', '15.2.9.3.11') do
  a = 3.123456789.infinite?
  b = (1.0 / 0.0).infinite?
  c = (-1.0 / 0.0).infinite?

  assert_nil a
  assert_equal( 1, b)
  assert_equal(-1, c)
end

assert('Float#round', '15.2.9.3.12') do
  a = 3.123456789.round
  b = 3.5.round
  c = 3.4999.round
  d = (-3.123456789).round
  e = (-3.5).round
  f = 12345.67.round(-1)
  g = 3.423456789.round(0)
  h = 3.423456789.round(1)
  i = 3.423456789.round(3)

  assert_equal(    3, a)
  assert_equal(    4, b)
  assert_equal(    3, c)
  assert_equal(   -3, d)
  assert_equal(   -4, e)
  assert_equal(12350, f)
  assert_equal(    3, g)
  assert_float(  3.4, h)
  assert_float(3.423, i)

  assert_equal(42.0, 42.0.round(307))
  assert_equal(1.0e307, 1.0e307.round(2))

  inf = 1.0/0.0
  assert_raise(FloatDomainError){ inf.round }
  assert_raise(FloatDomainError){ inf.round(-1) }
  assert_equal(inf, inf.round(1))
  nan = 0.0/0.0
  assert_raise(FloatDomainError){ nan.round }
  assert_raise(FloatDomainError){ nan.round(-1) }
  assert_true(nan.round(1).nan?)
end

assert('Float#to_f', '15.2.9.3.13') do
  a = 3.123456789

  assert_float(a, a.to_f)
end

assert('Float#to_i', '15.2.9.3.14') do
  assert_equal(3, 3.123456789.to_i)
end

assert('Float#truncate', '15.2.9.3.15') do
  assert_equal( 3,  3.123456789.truncate)
  assert_equal(-3, -3.1.truncate)
end

assert('Float#divmod') do
  def check_floats exp, act
    assert_float exp[0], act[0]
    assert_float exp[1], act[1]
  end

  # Note: quotients are Float because mruby does not have Bignum.
  check_floats [ 0,  0.0],   0.0.divmod(1)
  check_floats [ 0,  1.1],   1.1.divmod(3)
  check_floats [ 3,  0.2],   3.2.divmod(1)
  check_floats [ 2,  6.3],  20.3.divmod(7)
  check_floats [-1,  1.6],  -3.4.divmod(5)
  check_floats [-2, -0.5],  25.5.divmod(-13)
  check_floats [ 1, -6.6], -13.6.divmod(-7)
  check_floats [ 3,  0.2],   9.8.divmod(3.2)
end

assert('Float#nan?') do
  assert_true (0.0/0.0).nan?
  assert_false 0.0.nan?
  assert_false (1.0/0.0).nan?
  assert_false (-1.0/0.0).nan?
end

##
# Hash ISO Test

assert('Hash', '15.2.13') do
  assert_equal Class, Hash.class
end

assert('Hash#==', '15.2.13.4.1') do
  assert_true({ 'abc' => 'abc' } == { 'abc' => 'abc' })
  assert_false({ 'abc' => 'abc' } ==  { 'cba' => 'cba' })
  assert_true({ :equal => 1 } == { :equal => 1.0 })
  assert_false({ :a => 1 } == true)
end

assert('Hash#[]', '15.2.13.4.2') do
  a = { 'abc' => 'abc' }

  assert_equal 'abc', a['abc']
end

assert('Hash#[]=', '15.2.13.4.3') do
  a = Hash.new
  a['abc'] = 'abc'

  assert_equal 'abc', a['abc']
end

assert('Hash#clear', '15.2.13.4.4') do
  a = { 'abc' => 'abc' }
  a.clear

  assert_equal({ }, a)
end

assert('Hash#default', '15.2.13.4.5') do
  a = Hash.new
  b = Hash.new('abc')
  c = Hash.new {|s,k| s[k] = k}

  assert_nil a.default
  assert_equal 'abc', b.default
  assert_nil c.default
  assert_equal 'abc', c.default('abc')
end

assert('Hash#default=', '15.2.13.4.6') do
  a = { 'abc' => 'abc' }
  a.default = 'cba'

  assert_equal 'abc', a['abc']
  assert_equal 'cba', a['notexist']
end

assert('Hash#default_proc', '15.2.13.4.7') do
  a = Hash.new
  b = Hash.new {|s,k| s[k] = k + k}
  c = b[2]
  d = b['cat']

  assert_nil a.default_proc
  assert_equal Proc, b.default_proc.class
  assert_equal 4, c
  assert_equal 'catcat', d
end

assert('Hash#delete', '15.2.13.4.8') do
  a = { 'abc' => 'abc' }
  b = { 'abc' => 'abc' }
  b_tmp_1 = false
  b_tmp_2 = false

  a.delete('abc')
  b.delete('abc') do |k|
    b_tmp_1 = true
  end
  b.delete('abc') do |k|
    b_tmp_2 = true
  end

  assert_nil a.delete('cba')
  assert_false a.has_key?('abc')
  assert_false b_tmp_1
  assert_true b_tmp_2
end

assert('Hash#each', '15.2.13.4.9') do
  a = { 'abc_key' => 'abc_value' }
  key = nil
  value = nil

  a.each  do |k,v|
    key = k
    value = v
  end

  assert_equal 'abc_key', key
  assert_equal 'abc_value', value
end

assert('Hash#each_key', '15.2.13.4.10') do
  a = { 'abc_key' => 'abc_value' }
  key = nil

  a.each_key  do |k|
    key = k
  end

  assert_equal 'abc_key', key
end

assert('Hash#each_value', '15.2.13.4.11') do
  a = { 'abc_key' => 'abc_value' }
  value = nil

  a.each_value  do |v|
    value = v
  end

  assert_equal 'abc_value', value
end

assert('Hash#empty?', '15.2.13.4.12') do
  a = { 'abc_key' => 'abc_value' }
  b = Hash.new

  assert_false a.empty?
  assert_true b.empty?
end

assert('Hash#has_key?', '15.2.13.4.13') do
  a = { 'abc_key' => 'abc_value' }
  b = Hash.new

  assert_true a.has_key?('abc_key')
  assert_false b.has_key?('cba')
end

assert('Hash#has_value?', '15.2.13.4.14') do
  a = { 'abc_key' => 'abc_value' }
  b = Hash.new

  assert_true a.has_value?('abc_value')
  assert_false b.has_value?('cba')
end

assert('Hash#include?', '15.2.13.4.15') do
  a = { 'abc_key' => 'abc_value' }
  b = Hash.new

  assert_true a.include?('abc_key')
  assert_false b.include?('cba')
end

assert('Hash#initialize', '15.2.13.4.16') do
  # Testing initialize by new.
  h = Hash.new
  h2 = Hash.new(:not_found)

  assert_true h.is_a? Hash
  assert_equal({ }, h)
  assert_nil h["hello"]
  assert_equal :not_found, h2["hello"]
end

assert('Hash#initialize_copy', '15.2.13.4.17') do
  a = { 'abc_key' => 'abc_value' }
  b = Hash.new.initialize_copy(a)

  assert_equal({ 'abc_key' => 'abc_value' }, b)
end

assert('Hash#key?', '15.2.13.4.18') do
  a = { 'abc_key' => 'abc_value' }
  b = Hash.new

  assert_true a.key?('abc_key')
  assert_false b.key?('cba')
end

assert('Hash#keys', '15.2.13.4.19') do
  a = { 'abc_key' => 'abc_value' }

  assert_equal ['abc_key'], a.keys
end

assert('Hash#length', '15.2.13.4.20') do
  a = { 'abc_key' => 'abc_value' }
  b = Hash.new

  assert_equal 1, a.length
  assert_equal 0, b.length
end

assert('Hash#member?', '15.2.13.4.21') do
  a = { 'abc_key' => 'abc_value' }
  b = Hash.new

  assert_true a.member?('abc_key')
  assert_false b.member?('cba')
end

assert('Hash#merge', '15.2.13.4.22') do
  a = { 'abc_key' => 'abc_value', 'cba_key' => 'cba_value' }
  b = { 'cba_key' => 'XXX',  'xyz_key' => 'xyz_value' }

  result_1 = a.merge b
  result_2 = a.merge(b) do |key, original, new|
    original
  end

  assert_equal({'abc_key' => 'abc_value', 'cba_key' => 'XXX',
                'xyz_key' => 'xyz_value' }, result_1)
  assert_equal({'abc_key' => 'abc_value', 'cba_key' => 'cba_value',
                'xyz_key' => 'xyz_value' }, result_2)

  assert_raise(TypeError) do
    { 'abc_key' => 'abc_value' }.merge "a"
  end
end

assert('Hash#replace', '15.2.13.4.23') do
  a = { 'abc_key' => 'abc_value' }
  b = Hash.new.replace(a)

  assert_equal({ 'abc_key' => 'abc_value' }, b)

  a = Hash.new(42)
  b = {}
  b.replace(a)
  assert_equal(42, b[1])

  a = Hash.new{|h,x| x}
  b.replace(a)
  assert_equal(127, b[127])
end

assert('Hash#shift', '15.2.13.4.24') do
  a = { 'abc_key' => 'abc_value', 'cba_key' => 'cba_value' }
  b = a.shift

  assert_equal Array, b.class
  assert_equal 2, b.size
  assert_equal 1, a.size

  b = a.shift

  assert_equal Array, b.class
  assert_equal 2, b.size
  assert_equal 0, a.size
end

assert('Hash#size', '15.2.13.4.25') do
  a = { 'abc_key' => 'abc_value' }
  b = Hash.new

  assert_equal 1, a.size
  assert_equal 0, b.size
end

assert('Hash#store', '15.2.13.4.26') do
  a = Hash.new
  a.store('abc', 'abc')

  assert_equal 'abc', a['abc']
end

assert('Hash#value?', '15.2.13.4.27') do
  a = { 'abc_key' => 'abc_value' }
  b = Hash.new

  assert_true a.value?('abc_value')
  assert_false b.value?('cba')
end

assert('Hash#values', '15.2.13.4.28') do
  a = { 'abc_key' => 'abc_value' }

  assert_equal ['abc_value'], a.values
end

# Not ISO specified

assert('Hash#eql?') do
  a = { 'a' => 1, 'b' => 2, 'c' => 3 }
  b = { 'a' => 1, 'b' => 2, 'c' => 3 }
  c = { 'a' => 1.0, 'b' => 2, 'c' => 3 }
  assert_true(a.eql?(b))
  assert_false(a.eql?(c))
  assert_false(a.eql?(true))
end

assert('Hash#reject') do
  h = {:one => 1, :two => 2, :three => 3, :four => 4}
  ret = h.reject do |k,v|
    v % 2 == 0
  end
  assert_equal({:one => 1, :three => 3}, ret)
  assert_equal({:one => 1, :two => 2, :three => 3, :four => 4}, h)
end

assert('Hash#reject!') do
  h = {:one => 1, :two => 2, :three => 3, :four => 4}
  ret = h.reject! do |k,v|
    v % 2 == 0
  end
  assert_equal({:one => 1, :three => 3}, ret)
  assert_equal({:one => 1, :three => 3}, h)
end

assert('Hash#select') do
  h = {:one => 1, :two => 2, :three => 3, :four => 4}
  ret = h.select do |k,v|
    v % 2 == 0
  end
  assert_equal({:two => 2, :four => 4}, ret)
  assert_equal({:one => 1, :two => 2, :three => 3, :four => 4}, h)
end

assert('Hash#select!') do
  h = {:one => 1, :two => 2, :three => 3, :four => 4}
  ret = h.select! do |k,v|
    v % 2 == 0
  end
  assert_equal({:two => 2, :four => 4}, ret)
  assert_equal({:two => 2, :four => 4}, h)
end

# Not ISO specified

assert('Hash#inspect') do
  h = { "c" => 300, "a" => 100, "d" => 400, "c" => 300  }
  ret = h.to_s

  assert_include ret, '"c"=>300'
  assert_include ret, '"a"=>100'
  assert_include ret, '"d"=>400'
end
##
# IndexError ISO Test

assert('IndexError', '15.2.33') do
  assert_equal Class, IndexError.class
end
##
# Integer ISO Test

assert('Integer', '15.2.8') do
  assert_equal Class, Integer.class
end

assert('Integer#/', '15.2.8.3.4') do
  a = 2/1
  b = 2/1.0

  assert_equal 2, a
  assert_equal 2.0, b
end

assert('Integer#%', '15.2.8.3.5') do
  a = 1%1
  b = 1%1.0
  c = 2%4

  assert_equal 0, a
  assert_equal 0.0, b
  assert_equal 2, c
end

assert('Integer#<=>', '15.2.9.3.6') do
  a = 1<=>0
  b = 1<=>1
  c = 1<=>2

  assert_equal  1, a
  assert_equal  0, b
  assert_equal(-1, c)
end

assert('Integer#==', '15.2.8.3.7') do
  a = 1==0
  b = 1==1

  assert_false a
  assert_true b
end

assert('Integer#~', '15.2.8.3.8') do
  # Complement
  assert_equal(-1, ~0)
  assert_equal(-3, ~2)
end

assert('Integer#&', '15.2.8.3.9') do
  # Bitwise AND
  #   0101 (5)
  # & 0011 (3)
  # = 0001 (1)
  assert_equal 1, 5 & 3
end

assert('Integer#|', '15.2.8.3.10') do
  # Bitwise OR
  #   0101 (5)
  # | 0011 (3)
  # = 0111 (7)
  assert_equal 7, 5 | 3
end

assert('Integer#^', '15.2.8.3.11') do
  # Bitwise XOR
  #   0101 (5)
  # ^ 0011 (3)
  # = 0110 (6)
  assert_equal 6, 5 ^ 3
end

assert('Integer#<<', '15.2.8.3.12') do
  # Left Shift by one
  #   00010111 (23)
  # = 00101110 (46)
  assert_equal 46, 23 << 1

  # Left Shift by a negative is Right Shift
  assert_equal 23, 46 << -1

  # Raise when shift is too large
  assert_raise(RangeError) do
    2 << 128
  end
end

assert('Integer#>>', '15.2.8.3.13') do
  # Right Shift by one
  #   00101110 (46)
  # = 00010111 (23)
  assert_equal 23, 46 >> 1

  # Right Shift by a negative is Left Shift
  assert_equal 46, 23 >> -1

  # Don't raise on large Right Shift
  assert_equal 0, 23 >> 128

  # Raise when shift is too large
  assert_raise(RangeError) do
    2 >> -128
  end
end

assert('Integer#ceil', '15.2.8.3.14') do
  assert_equal 10, 10.ceil
end

assert('Integer#downto', '15.2.8.3.15') do
  a = 0
  3.downto(1) do |i|
    a += i
  end
  assert_equal 6, a
end

assert('Integer#eql?', '15.2.8.3.16') do
  a = 1.eql?(1)
  b = 1.eql?(2)
  c = 1.eql?(nil)

  assert_true a
  assert_false b
  assert_false c
end

assert('Integer#floor', '15.2.8.3.17') do
  a = 1.floor

  assert_equal 1, a
end

assert('Integer#next', '15.2.8.3.19') do
  assert_equal 2, 1.next
end

assert('Integer#round', '15.2.8.3.20') do
  assert_equal 1, 1.round
end

assert('Integer#succ', '15.2.8.3.21') do
  assert_equal 2, 1.succ
end

assert('Integer#times', '15.2.8.3.22') do
  a = 0
  3.times do
    a += 1
  end
  assert_equal 3, a
end

assert('Integer#to_f', '15.2.8.3.23') do
  assert_equal 1.0, 1.to_f
end

assert('Integer#to_i', '15.2.8.3.24') do
  assert_equal 1, 1.to_i
end

assert('Integer#to_s', '15.2.8.3.25') do
  assert_equal '1', 1.to_s
  assert_equal("-1", -1.to_s)
end

assert('Integer#truncate', '15.2.8.3.26') do
  assert_equal 1, 1.truncate
end

assert('Integer#upto', '15.2.8.3.27') do
  a = 0
  1.upto(3) do |i|
    a += i
  end
  assert_equal 6, a
end

assert('Integer#divmod', '15.2.8.3.30') do
  assert_equal [ 0,  0],   0.divmod(1)
  assert_equal [ 0,  1],   1.divmod(3)
  assert_equal [ 3,  0],   3.divmod(1)
  assert_equal [ 2,  6],  20.divmod(7)
  assert_equal [-1,  2],  -3.divmod(5)
  assert_equal [-2, -1],  25.divmod(-13)
  assert_equal [ 1, -6], -13.divmod(-7)
end

# Not ISO specified

assert('Integer#step') do
  a = []
  b = []
  1.step(3) do |i|
    a << i
  end
  1.step(6, 2) do |i|
    b << i
  end

  assert_equal [1, 2, 3], a
  assert_equal [1, 3, 5], b
end
##
# Kernel ISO Test

assert('Kernel', '15.3.1') do
  assert_equal Module, Kernel.class
end

assert('Kernel.block_given?', '15.3.1.2.2') do
  def bg_try(&b)
    if Kernel.block_given?
      yield
    else
      "no block"
    end
  end

  assert_false Kernel.block_given?
  # test without block
  assert_equal "no block", bg_try
  # test with block
  assert_equal "block" do
    bg_try { "block" }
  end
  # test with block
  assert_equal "block" do
    bg_try do
      "block"
    end
  end
end

# Kernel.eval is provided by the mruby-gem mrbgem. '15.3.1.2.3'

assert('Kernel.global_variables', '15.3.1.2.4') do
  assert_equal Array, Kernel.global_variables.class
end

# Not implemented at the moment
#assert('Kernel.local_variables', '15.3.1.2.7') do
#  Kernel.local_variables.class == Array
#end


assert('Kernel.p', '15.3.1.2.9') do
  # TODO search for a way to test p to stdio
  assert_true true
end

assert('Kernel.print', '15.3.1.2.10') do
  # TODO search for a way to test print to stdio
  assert_true true
end

assert('Kernel.puts', '15.3.1.2.11') do
  # TODO search for a way to test puts to stdio
  assert_true true
end

assert('Kernel.raise', '15.3.1.2.12') do
  assert_raise RuntimeError do
    Kernel.raise
  end

  assert_raise RuntimeError do
    Kernel.raise RuntimeError.new
  end
end

assert('Kernel#__id__', '15.3.1.3.3') do
  assert_equal Fixnum, __id__.class
end

assert('Kernel#__send__', '15.3.1.3.4') do
  # test with block
  l = __send__(:lambda) do
    true
  end

  assert_true l.call
  assert_equal Proc, l.class
  # test with argument
  assert_true __send__(:respond_to?, :nil?)
  # test without argument and without block
  assert_equal  Array, __send__(:public_methods).class
end

assert('Kernel#block_given?', '15.3.1.3.6') do
  def bg_try(&b)
    if block_given?
      yield
    else
      "no block"
    end
  end

  assert_false block_given?
  assert_equal "no block", bg_try
  assert_equal "block" do
    bg_try { "block" }
  end
  assert_equal "block" do
    bg_try do
      "block"
    end
  end
end

assert('Kernel#class', '15.3.1.3.7') do
  assert_equal Module, Kernel.class
end

assert('Kernel#clone', '15.3.1.3.8') do
  class KernelCloneTest
    def initialize
      @v = 0
    end

    def get
      @v
    end

    def set(v)
      @v = v
    end
  end

  a = KernelCloneTest.new
  a.set(1)
  b = a.clone

  def a.test
  end
  a.set(2)
  c = a.clone

  immutables = [ 1, :foo, true, false, nil ]
  error_count = 0
  immutables.each do |i|
    begin
      i.clone
    rescue TypeError
      error_count += 1
    end
  end

  assert_equal 2, a.get
  assert_equal 1, b.get
  assert_equal 2, c.get
  assert_true a.respond_to?(:test)
  assert_false b.respond_to?(:test)
  assert_true c.respond_to?(:test)
end

assert('Kernel#dup', '15.3.1.3.9') do
  class KernelDupTest
    def initialize
      @v = 0
    end

    def get
      @v
    end

    def set(v)
      @v = v
    end
  end

  a = KernelDupTest.new
  a.set(1)
  b = a.dup

  def a.test
  end
  a.set(2)
  c = a.dup

  immutables = [ 1, :foo, true, false, nil ]
  error_count = 0
  immutables.each do |i|
    begin
      i.dup
    rescue TypeError
      error_count += 1
    end
  end

  assert_equal immutables.size, error_count
  assert_equal 2, a.get
  assert_equal 1, b.get
  assert_equal 2, c.get
  assert_true a.respond_to?(:test)
  assert_false b.respond_to?(:test)
  assert_false c.respond_to?(:test)
end

# Kernel#eval is provided by mruby-eval mrbgem '15.3.1.3.12'

assert('Kernel#extend', '15.3.1.3.13') do
  class Test4ExtendClass
  end

  module Test4ExtendModule
    def test_method; end
  end

  a = Test4ExtendClass.new
  a.extend(Test4ExtendModule)
  b = Test4ExtendClass.new

  assert_true a.respond_to?(:test_method)
  assert_false b.respond_to?(:test_method)
end

assert('Kernel#extend works on toplevel', '15.3.1.3.13') do
  module Test4ExtendModule
    def test_method; end
  end
  # This would crash...
  extend(Test4ExtendModule)

  assert_true respond_to?(:test_method)
end

assert('Kernel#global_variables', '15.3.1.3.14') do
  assert_equal Array, global_variables.class
end

assert('Kernel#hash', '15.3.1.3.15') do
  assert_equal hash, hash
end

assert('Kernel#inspect', '15.3.1.3.17') do
  s = inspect

  assert_equal String, s.class
  assert_equal "main", s
end

assert('Kernel#instance_variable_defined?', '15.3.1.3.20') do
  o = Object.new
  o.instance_variable_set(:@a, 1)

  assert_true o.instance_variable_defined?("@a")
  assert_false o.instance_variable_defined?("@b")
  assert_true o.instance_variable_defined?("@a"[0,2])
  assert_true o.instance_variable_defined?("@abc"[0,2])
end

assert('Kernel#instance_variables', '15.3.1.3.23') do
  o = Object.new
  o.instance_eval do
    @a = 11
    @b = 12
  end
  ivars = o.instance_variables

  assert_equal Array, ivars.class,
  assert_equal(2, ivars.size)
  assert_true ivars.include?(:@a)
  assert_true ivars.include?(:@b)
end

assert('Kernel#is_a?', '15.3.1.3.24') do
  assert_true is_a?(Kernel)
  assert_false is_a?(Array)

  assert_raise TypeError do
    42.is_a?(42)
  end
end

assert('Kernel#iterator?', '15.3.1.3.25') do
  assert_false iterator?
end

assert('Kernel#kind_of?', '15.3.1.3.26') do
  assert_true kind_of?(Kernel)
  assert_false kind_of?(Array)
end

assert('Kernel#lambda', '15.3.1.3.27') do
  l = lambda do
    true
  end

  m = lambda(&l)

  assert_true l.call
  assert_equal Proc, l.class
  assert_true m.call
  assert_equal Proc, m.class
end

# Not implemented yet
#assert('Kernel#local_variables', '15.3.1.3.28') do
#  local_variables.class == Array
#end

assert('Kernel#method_missing', '15.3.1.3.30') do
  class MMTestClass
    def method_missing(sym)
      "A call to #{sym}"
    end
  end
  mm_test = MMTestClass.new
  assert_equal 'A call to no_method_named_this', mm_test.no_method_named_this

  a = String.new
  begin
    a.no_method_named_this
  rescue NoMethodError => e
    assert_equal "undefined method 'no_method_named_this' for \"\"", e.message
  end

  class ShortInspectClass
    def inspect
      'An inspect string'
    end
  end
  b = ShortInspectClass.new
  begin
    b.no_method_named_this
  rescue NoMethodError => e
    assert_equal "undefined method 'no_method_named_this' for An inspect string", e.message
  end

  class LongInspectClass
    def inspect
      "A" * 70
    end
  end
  c = LongInspectClass.new
  begin
    c.no_method_named_this
  rescue NoMethodError => e
    assert_equal "undefined method 'no_method_named_this' for #{c.to_s}", e.message
  end

  class NoInspectClass
    undef inspect
  end
  d = NoInspectClass.new
  begin
    d.no_method_named_this
  rescue NoMethodError => e
    assert_equal "undefined method 'no_method_named_this' for #{d.to_s}", e.message
  end
end

assert('Kernel#methods', '15.3.1.3.31') do
  assert_equal Array, methods.class
end

assert('Kernel#nil?', '15.3.1.3.32') do
  assert_false nil?
end

assert('Kernel#object_id', '15.3.1.3.33') do
  a = ""
  b = ""
  assert_not_equal a.object_id, b.object_id

  assert_kind_of Numeric, object_id
  assert_kind_of Numeric, "".object_id
  assert_kind_of Numeric, true.object_id
  assert_kind_of Numeric, false.object_id
  assert_kind_of Numeric, nil.object_id
  assert_kind_of Numeric, :no.object_id
  assert_kind_of Numeric, 1.object_id
  assert_kind_of Numeric, 1.0.object_id
end

# Kernel#p is defined in mruby-print mrbgem. '15.3.1.3.34'

# Kernel#print is defined in mruby-print mrbgem. '15.3.1.3.35'

assert('Kernel#private_methods', '15.3.1.3.36') do
  assert_equal Array, private_methods.class
end

assert('Kernel#protected_methods', '15.3.1.3.37') do
  assert_equal Array, protected_methods.class
end

assert('Kernel#public_methods', '15.3.1.3.38') do
  assert_equal Array, public_methods.class
end

# Kernel#puts is defined in mruby-print mrbgem. '15.3.1.3.39'

assert('Kernel#raise', '15.3.1.3.40') do
  assert_raise RuntimeError do
    raise
  end

  assert_raise RuntimeError do
    raise RuntimeError.new
  end
end

assert('Kernel#remove_instance_variable', '15.3.1.3.41') do
  class Test4RemoveInstanceVar
    attr_reader :var
    def initialize
      @var = 99
    end
    def remove
      remove_instance_variable(:@var)
    end
  end

  tri = Test4RemoveInstanceVar.new
  assert_equal 99, tri.var
  tri.remove
  assert_equal nil, tri.var
  assert_raise NameError do
    tri.remove
  end
end

# Kernel#require is defined in mruby-require. '15.3.1.3.42'

assert('Kernel#respond_to?', '15.3.1.3.43') do
  class Test4RespondTo
    def valid_method; end

    def test_method; end
    undef test_method
  end

  assert_raise TypeError do
    Test4RespondTo.new.respond_to?(1)
  end

  assert_raise ArgumentError do
    Test4RespondTo.new.respond_to?
  end

  assert_raise ArgumentError do
    Test4RespondTo.new.respond_to? :a, true, :aa
  end

  assert_true respond_to?(:nil?)
  assert_true Test4RespondTo.new.respond_to?(:valid_method)
  assert_true Test4RespondTo.new.respond_to?('valid_method')
  assert_false Test4RespondTo.new.respond_to?(:test_method)
end

assert('Kernel#send', '15.3.1.3.44') do
  # test with block
  l = send(:lambda) do
    true
  end

  assert_true l.call
  assert_equal l.class, Proc
  # test with argument
  assert_true send(:respond_to?, :nil?)
  # test without argument and without block
  assert_equal send(:public_methods).class, Array
end

assert('Kernel#singleton_methods', '15.3.1.3.45') do
  assert_equal singleton_methods.class, Array
end

assert('Kernel#to_s', '15.3.1.3.46') do
  assert_equal to_s.class, String
end

assert('Kernel#!=') do
  str1 = "hello"
  str2 = str1
  str3 = "world"

  assert_false (str1[1] != 'e')
  assert_true (str1 != str3)
  assert_false (str2 != str1)
end

# operator "!~" is defined in ISO Ruby 11.4.4.
assert('Kernel#!~') do
  x = "x"
  def x.=~(other)
    other == "x"
  end
  assert_false x !~ "x"
  assert_true  x !~ "z"

  y = "y"
  def y.=~(other)
    other == "y"
  end
  def y.!~(other)
    other == "not y"
  end
  assert_false y !~ "y"
  assert_false y !~ "z"
  assert_true  y !~ "not y"
end

assert('Kernel#respond_to_missing?') do
  class Test4RespondToMissing
    def respond_to_missing?(method_name, include_private = false)
      method_name == :a_method
    end
  end

  assert_true Test4RespondToMissing.new.respond_to?(:a_method)
  assert_false Test4RespondToMissing.new.respond_to?(:no_method)
end

assert('Kernel#global_variables') do
  variables = global_variables
  1.upto(9) do |i|
    assert_equal variables.include?(:"$#{i}"), true
  end
end

assert('Kernel#define_singleton_method') do
  o = Object.new
  ret = o.define_singleton_method(:test_method) do
    :singleton_method_ok
  end
  assert_equal :test_method, ret
  assert_equal :singleton_method_ok, o.test_method
end

assert('stack extend') do
  def recurse(count, stop)
    return count if count > stop
    recurse(count+1, stop)
  end

  assert_equal 6, recurse(0, 5)
end

##
# Literals ISO Test

assert('Literals Numerical', '8.7.6.2') do
  # signed and unsigned integer
  assert_equal 1, 1
  assert_equal(-1, -1)
  assert_equal(+1, +1)
  # signed and unsigned float
  assert_equal 1.0, 1.0
  assert_equal(-1.0, -1.0)
  # binary
  assert_equal 128, 0b10000000
  assert_equal 128, 0B10000000
  # octal
  assert_equal 8, 0o10
  assert_equal 8, 0O10
  assert_equal 8, 0_10
  # hex
  assert_equal 255, 0xff
  assert_equal 255, 0Xff
  # decimal
  assert_equal 999, 0d999
  assert_equal 999, 0D999
  # decimal seperator
  assert_equal 10000000, 10_000_000
  assert_equal       10, 1_0
  # integer with exponent
  assert_equal 10.0, 1e1,
  assert_equal(0.1, 1e-1)
  assert_equal 10.0, 1e+1
  # float with exponent
  assert_equal 10.0, 1.0e1
  assert_equal(0.1, 1.0e-1)
  assert_equal 10.0, 1.0e+1
end

assert('Literals Strings Single Quoted', '8.7.6.3.2') do
  assert_equal 'abc', 'abc'
  assert_equal '\'', '\''
  assert_equal '\\', '\\'
end

assert('Literals Strings Double Quoted', '8.7.6.3.3') do
  a = "abc"

  assert_equal "abc", "abc"
  assert_equal "\"", "\""
  assert_equal "\\", "\\"
  assert_equal "abc", "#{a}"
end

assert('Literals Strings Quoted Non-Expanded', '8.7.6.3.4') do
  a = %q{abc}
  b = %q(abc)
  c = %q[abc]
  d = %q<abc>
  e = %q/abc/
  f = %q/ab\/c/
  g = %q{#{a}}

  assert_equal 'abc', a
  assert_equal 'abc', b
  assert_equal 'abc', c
  assert_equal 'abc', d
  assert_equal 'abc', e
  assert_equal 'ab/c', f
  assert_equal '#{a}', g
end

assert('Literals Strings Quoted Expanded', '8.7.6.3.5') do
  a = %Q{abc}
  b = %Q(abc)
  c = %Q[abc]
  d = %Q<abc>
  e = %Q/abc/
  f = %Q/ab\/c/
  g = %Q{#{a}}

  assert_equal 'abc', a
  assert_equal 'abc', b
  assert_equal 'abc', c
  assert_equal 'abc', d
  assert_equal 'abc', e
  assert_equal 'ab/c', f
  assert_equal 'abc', g
end

assert('Literals Strings Here documents', '8.7.6.3.6') do
  a = <<AAA
aaa
AAA
   b = <<b_b
bbb
b_b
    c = [<<CCC1, <<"CCC2", <<'CCC3']
c1
CCC1
c 2
CCC2
c  3
CCC3

      d = <<DDD
d#{1+2}DDD
d\t
DDD\n
DDD
  e = <<'EEE'
e#{1+2}EEE
e\t
EEE\n
EEE
  f = <<"FFF"
F
FF#{"f"}FFF
F
FFF

  g = <<-GGG
  ggg
  GGG
  h = <<-"HHH"
  hhh
  HHH
  i = <<-'III'
  iii
  III
  j = [<<-JJJ1   , <<-"JJJ2"   , <<-'JJJ3' ]
  j#{1}j
  JJJ1
  j#{2}j
  JJJ2
  j#{3}j
  JJJ3

  k = <<'KKK'.to_i
123
KKK

  m = [<<MM1, <<MM2]
x#{m2 = {x:<<MM3}}y
mm3
MM3
mm1
MM1
mm2
MM2

  n = [1, "#{<<NN1}", 3,
nn1
NN1
  4]

  qqq = Proc.new {|*x| x.join(' $ ')}
  q1 = qqq.call("a", <<QQ1, "c",
q
QQ1
      "d")
  q2 = qqq.call("l", "m#{<<QQ2}n",
qq
QQ2
      "o")

  w = %W( 1 #{<<WWW} 3
www
WWW
      4 5 )

  x = [1, <<XXX1,
foo #{<<XXX2} bar
222 #{<<XXX3} 444
333
XXX3
5
XXX2
6
XXX1
    9]

  z = <<'ZZZ'
ZZZ

  assert_equal "aaa\n", a
  assert_equal "bbb\n", b
  assert_equal ["c1\n", "c 2\n", "c  3\n"], c
  assert_equal "d3DDD\nd\t\nDDD\n\n", d
  assert_equal "e\#{1+2}EEE\ne\\t\nEEE\\n\n", e
  assert_equal "F\nFFfFFF\nF\n", f
  assert_equal "  ggg\n", g
  assert_equal "  hhh\n", h
  assert_equal "  iii\n", i
  assert_equal ["  j1j\n", "  j2j\n", "  j\#{3}j\n"], j
  assert_equal 123, k
  assert_equal ["x{:x=>\"mm3\\n\"}y\nmm1\n", "mm2\n"], m
  assert_equal ({:x=>"mm3\n"}), m2
  assert_equal [1, "nn1\n", 3, 4], n
  assert_equal "a $ q\n $ c $ d", q1
  assert_equal "l $ mqq\nn $ o", q2
  assert_equal ["1", "www\n", "3", "4", "5"], w
  assert_equal [1, "foo 222 333\n 444\n5\n bar\n6\n", 9], x
  assert_equal "", z

end


assert('Literals Array', '8.7.6.4') do
  a = %W{abc#{1+2}def \}g}
  b = %W(abc #{2+3} def \(g)
  c = %W[#{3+4}]
  d = %W< #{4+5} >
  e = %W//
  f = %W[[ab cd][ef]]
  g = %W{
    ab
    #{-1}1
    2#{2}
  }
  h = %W(a\nb
         test\ abc
         c\
d
         x\y x\\y x\\\y)

  assert_equal ['abc3def', '}g'], a
  assert_equal ['abc', '5', 'def', '(g'], b
  assert_equal ['7'],c
  assert_equal ['9'], d
  assert_equal [], e
  assert_equal ['[ab', 'cd][ef]'], f
  assert_equal ['ab', '-11', '22'], g
  assert_equal ["a\nb", 'test abc', "c\nd", "xy", "x\\y", "x\\y"], h

  a = %w{abc#{1+2}def \}g}
  b = %w(abc #{2+3} def \(g)
  c = %w[#{3+4}]
  d = %w< #{4+5} >
  e = %w//
  f = %w[[ab cd][ef]]
  g = %w{
    ab
    #{-1}1
    2#{2}
  }
  h = %w(a\nb
         test\ abc
         c\
d
         x\y x\\y x\\\y)

  assert_equal ['abc#{1+2}def', '}g'], a
  assert_equal ['abc', '#{2+3}', 'def', '(g'], b
  assert_equal ['#{3+4}'], c
  assert_equal ['#{4+5}'], d
  assert_equal [], e
  assert_equal ['[ab', 'cd][ef]'], f
  assert_equal ['ab', '#{-1}1', '2#{2}'], g
  assert_equal ["a\\nb", "test abc", "c\nd", "x\\y", "x\\y", "x\\\\y"], h
end


assert('Literals Array of symbols') do
  a = %I{abc#{1+2}def \}g}
  b = %I(abc #{2+3} def \(g)
  c = %I[#{3+4}]
  d = %I< #{4+5} >
  e = %I//
  f = %I[[ab cd][ef]]
  g = %I{
    ab
    #{-1}1
    2#{2}
  }

  assert_equal [:'abc3def', :'}g'], a
  assert_equal [:'abc', :'5', :'def', :'(g'], b
  assert_equal [:'7'],c
  assert_equal [:'9'], d
  assert_equal [], e
  assert_equal [:'[ab', :'cd][ef]'], f
  assert_equal [:'ab', :'-11', :'22'], g

  a = %i{abc#{1+2}def \}g}
  b = %i(abc #{2+3} def \(g)
  c = %i[#{3+4}]
  d = %i< #{4+5} >
  e = %i//
  f = %i[[ab cd][ef]]
  g = %i{
    ab
    #{-1}1
    2#{2}
  }

  assert_equal [:'abc#{1+2}def', :'}g'], a
  assert_equal [:'abc', :'#{2+3}', :'def', :'(g'], b
  assert_equal [:'#{3+4}'], c
  assert_equal [:'#{4+5}'], d
  assert_equal [] ,e
  assert_equal [:'[ab', :'cd][ef]'], f
  assert_equal [:'ab', :'#{-1}1', :'2#{2}'], g
end

assert('Literals Symbol', '8.7.6.6') do
  # do not compile error
  :$asd
  :@asd
  :@@asd
  :asd=
  :asd!
  :asd?
  :+
  :+@
  :if
  :BEGIN

  a = :"asd qwe"
  b = :'foo bar'
  c = :"a#{1+2}b"
  d = %s(asd)
  e = %s( foo \))
  f = %s[asd \[
qwe]
  g = %s/foo#{1+2}bar/
  h = %s{{foo bar}}

  assert_equal :'asd qwe', a
  assert_equal :"foo bar", b
  assert_equal :a3b, c
  assert_equal :asd, d
  assert_equal :' foo )', e
  assert_equal :"asd [\nqwe", f
  assert_equal :'foo#{1+2}bar', g
  assert_equal :'{foo bar}', h
end

# Not Implemented ATM assert('Literals Regular expression', '8.7.6.5') do
##
# LocalJumpError ISO Test

assert('LocalJumpError', '15.2.25') do
  assert_equal Class, LocalJumpError.class
#  assert_raise LocalJumpError do
#    # this will cause an exception due to the wrong location
#    retry
#  end
end

# TODO 15.2.25.2.1 LocalJumpError#exit_value
# TODO 15.2.25.2.2 LocalJumpError#reason
##
# Chapter 13.3 "Methods" ISO Test

assert('The alias statement', '13.3.6 a) 4)') do
  # check aliasing in all possible ways

  def alias_test_method_original; true; end

  alias alias_test_method_a alias_test_method_original
  alias :alias_test_method_b :alias_test_method_original

  assert_true(alias_test_method_original)
  assert_true(alias_test_method_a)
  assert_true(alias_test_method_b)
end

assert('The alias statement (overwrite original)', '13.3.6 a) 4)') do
  # check that an aliased method can be overwritten
  # without side effect

  def alias_test_method_original; true; end

  alias alias_test_method_a alias_test_method_original
  alias :alias_test_method_b :alias_test_method_original

  assert_true(alias_test_method_original)

  def alias_test_method_original; false; end

  assert_false(alias_test_method_original)
  assert_true(alias_test_method_a)
  assert_true(alias_test_method_b)
end

assert('The alias statement', '13.3.6 a) 5)') do
  # check that alias is raising NameError if
  # non-existing method should be undefined

  assert_raise(NameError) do
    alias new_name_a non_existing_method
  end

  assert_raise(NameError) do
    alias :new_name_b :non_existing_method
  end
end

assert('The undef statement', '13.3.7 a) 4)') do
  # check that undef is undefining method
  # based on the method name

  def existing_method_a; true; end
  def existing_method_b; true; end
  def existing_method_c; true; end
  def existing_method_d; true; end
  def existing_method_e; true; end
  def existing_method_f; true; end

  # check that methods are defined

  assert_true(existing_method_a, 'Method should be defined')
  assert_true(existing_method_b, 'Method should be defined')
  assert_true(existing_method_c, 'Method should be defined')
  assert_true(existing_method_d, 'Method should be defined')
  assert_true(existing_method_e, 'Method should be defined')
  assert_true(existing_method_f, 'Method should be defined')

  # undefine in all possible ways and check that method
  # is undefined

  undef existing_method_a
  assert_raise(NoMethodError) do
    existing_method_a
  end

  undef :existing_method_b
  assert_raise(NoMethodError) do
    existing_method_b
  end

  undef existing_method_c, existing_method_d
  assert_raise(NoMethodError) do
    existing_method_c
  end
  assert_raise(NoMethodError) do
    existing_method_d
  end

  undef :existing_method_e, :existing_method_f
  assert_raise(NoMethodError) do
    existing_method_e
  end
  assert_raise(NoMethodError) do
    existing_method_f
  end
end

assert('The undef statement (method undefined)', '13.3.7 a) 5)') do
  # check that undef is raising NameError if
  # non-existing method should be undefined

  assert_raise(NameError) do
    undef non_existing_method
  end

  assert_raise(NameError) do
    undef :non_existing_method
  end
end
##
# Module ISO Test

assert('Module', '15.2.2') do
  assert_equal Class, Module.class
end

# TODO not implemented ATM assert('Module.constants', '15.2.2.3.1') do

# TODO not implemented ATM assert('Module.nesting', '15.2.2.3.2') do

assert('Module#ancestors', '15.2.2.4.9') do
  class Test4ModuleAncestors
  end
  sc = Test4ModuleAncestors.singleton_class
  r = String.ancestors

  assert_equal Array, r.class
  assert_true r.include?(String)
  assert_true r.include?(Object)
end

assert('Module#append_features', '15.2.2.4.10') do
  module Test4AppendFeatures
    def self.append_features(mod)
      Test4AppendFeatures2.const_set(:Const4AppendFeatures2, mod)
    end
  end
  module Test4AppendFeatures2
    include Test4AppendFeatures
  end

  assert_equal Test4AppendFeatures2, Test4AppendFeatures2.const_get(:Const4AppendFeatures2)
end

assert('Module#attr NameError') do
  %w[
    foo?
    @foo
    @@foo
    $foo
  ].each do |name|
    module NameTest; end

    assert_raise(NameError) do
      NameTest.module_eval { attr_reader name.to_sym }
    end

    assert_raise(NameError) do
      NameTest.module_eval { attr_writer name.to_sym }
    end

    assert_raise(NameError) do
      NameTest.module_eval { attr name.to_sym }
    end

    assert_raise(NameError) do
      NameTest.module_eval { attr_accessor name.to_sym }
    end
  end

end

assert('Module#attr', '15.2.2.4.11') do
  class AttrTest
    class << self
      attr :cattr
      def cattr_val=(val)
        @cattr = val
      end
    end
    attr :iattr
    def iattr_val=(val)
      @iattr = val
    end
  end

  test = AttrTest.new
  assert_true AttrTest.respond_to?(:cattr)
  assert_true test.respond_to?(:iattr)

  assert_false AttrTest.respond_to?(:cattr=)
  assert_false test.respond_to?(:iattr=)

  test.iattr_val = 'test'
  assert_equal 'test', test.iattr

  AttrTest.cattr_val = 'test'
  assert_equal 'test', AttrTest.cattr
end

assert('Module#attr_accessor', '15.2.2.4.12') do
  class AttrTestAccessor
    class << self
      attr_accessor :cattr
    end
    attr_accessor :iattr, 'iattr2'
  end

  attr_instance = AttrTestAccessor.new
  assert_true AttrTestAccessor.respond_to?(:cattr=)
  assert_true attr_instance.respond_to?(:iattr=)
  assert_true attr_instance.respond_to?(:iattr2=)
  assert_true AttrTestAccessor.respond_to?(:cattr)
  assert_true attr_instance.respond_to?(:iattr)
  assert_true attr_instance.respond_to?(:iattr2)

  attr_instance.iattr = 'test'
  assert_equal 'test', attr_instance.iattr

  AttrTestAccessor.cattr = 'test'
  assert_equal 'test', AttrTestAccessor.cattr
end

assert('Module#attr_reader', '15.2.2.4.13') do
  class AttrTestReader
    class << self
      attr_reader :cattr
      def cattr_val=(val)
        @cattr = val
      end
    end
    attr_reader :iattr, 'iattr2'
    def iattr_val=(val)
      @iattr = val
    end
  end

  attr_instance = AttrTestReader.new
  assert_true AttrTestReader.respond_to?(:cattr)
  assert_true attr_instance.respond_to?(:iattr)
  assert_true attr_instance.respond_to?(:iattr2)

  assert_false AttrTestReader.respond_to?(:cattr=)
  assert_false attr_instance.respond_to?(:iattr=)
  assert_false attr_instance.respond_to?(:iattr2=)

  attr_instance.iattr_val = 'test'
  assert_equal 'test', attr_instance.iattr

  AttrTestReader.cattr_val = 'test'
  assert_equal 'test', AttrTestReader.cattr
end

assert('Module#attr_writer', '15.2.2.4.14') do
  class AttrTestWriter
    class << self
      attr_writer :cattr
      def cattr_val
        @cattr
      end
    end
    attr_writer :iattr, 'iattr2'
    def iattr_val
      @iattr
    end
  end

  attr_instance = AttrTestWriter.new
  assert_true AttrTestWriter.respond_to?(:cattr=)
  assert_true attr_instance.respond_to?(:iattr=)
  assert_true attr_instance.respond_to?(:iattr2=)

  assert_false AttrTestWriter.respond_to?(:cattr)
  assert_false attr_instance.respond_to?(:iattr)
  assert_false attr_instance.respond_to?(:iattr2)

  attr_instance.iattr = 'test'
  assert_equal 'test', attr_instance.iattr_val

  AttrTestWriter.cattr = 'test'
  assert_equal 'test', AttrTestWriter.cattr_val
end

assert('Module#class_eval', '15.2.2.4.15') do
  class Test4ClassEval
    @a = 11
    @b = 12
  end
  Test4ClassEval.class_eval do
    def method1
    end
  end
  r = Test4ClassEval.instance_methods

  assert_equal 11, Test4ClassEval.class_eval{ @a }
  assert_equal 12, Test4ClassEval.class_eval{ @b }
  assert_equal Array, r.class
  assert_true r.include?(:method1)
end

assert('Module#class_variable_defined?', '15.2.2.4.16') do
  class Test4ClassVariableDefined
    @@cv = 99
  end

  assert_true Test4ClassVariableDefined.class_variable_defined?(:@@cv)
  assert_false Test4ClassVariableDefined.class_variable_defined?(:@@noexisting)
end

assert('Module#class_variable_get', '15.2.2.4.17') do
  class Test4ClassVariableGet
    @@cv = 99
  end

  assert_equal 99, Test4ClassVariableGet.class_variable_get(:@@cv)
end

assert('Module#class_variable_set', '15.2.2.4.18') do
  class Test4ClassVariableSet
    @@foo = 100
    def foo
      @@foo
    end
  end

  assert_true Test4ClassVariableSet.class_variable_set(:@@cv, 99)
  assert_true Test4ClassVariableSet.class_variable_set(:@@foo, 101)
  assert_true Test4ClassVariableSet.class_variables.include? :@@cv
  assert_equal 99, Test4ClassVariableSet.class_variable_get(:@@cv)
  assert_equal 101, Test4ClassVariableSet.new.foo
end

assert('Module#class_variables', '15.2.2.4.19') do
  class Test4ClassVariables1
    @@var1 = 1
  end
  class Test4ClassVariables2 < Test4ClassVariables1
    @@var2 = 2
  end

  assert_equal [:@@var1], Test4ClassVariables1.class_variables
  assert_equal [:@@var2, :@@var1], Test4ClassVariables2.class_variables
end

assert('Module#const_defined?', '15.2.2.4.20') do
  module Test4ConstDefined
    Const4Test4ConstDefined = true
  end

  assert_true Test4ConstDefined.const_defined?(:Const4Test4ConstDefined)
  assert_false Test4ConstDefined.const_defined?(:NotExisting)
end

assert('Module#const_get', '15.2.2.4.21') do
  module Test4ConstGet
    Const4Test4ConstGet = 42
  end

  assert_equal 42, Test4ConstGet.const_get(:Const4Test4ConstGet)
end

assert('Module#const_missing', '15.2.2.4.22') do
  module Test4ConstMissing
    def self.const_missing(sym)
      42 # the answer to everything
    end
  end

  assert_equal 42, Test4ConstMissing.const_get(:ConstDoesntExist)
end

assert('Module#const_get', '15.2.2.4.23') do
  module Test4ConstSet
    Const4Test4ConstSet = 42
  end

  assert_true Test4ConstSet.const_set(:Const4Test4ConstSet, 23)
  assert_equal 23, Test4ConstSet.const_get(:Const4Test4ConstSet)
end

assert('Module#constants', '15.2.2.4.24') do
  $n = []
  module TestA
    C = 1
  end
  class TestB
    include TestA
    C2 = 1
    $n = constants.sort
  end

  assert_equal [ :C ], TestA.constants
  assert_equal [ :C, :C2 ], $n
end

assert('Module#include', '15.2.2.4.27') do
  module Test4Include
    Const4Include = 42
  end
  module Test4Include2
    include Test4Include
  end

  assert_equal 42, Test4Include2.const_get(:Const4Include)
end

assert('Module#include?', '15.2.2.4.28') do
  module Test4IncludeP
  end
  class Test4IncludeP2
    include Test4IncludeP
  end
  class Test4IncludeP3 < Test4IncludeP2
  end

  assert_true Test4IncludeP2.include?(Test4IncludeP)
  assert_true Test4IncludeP3.include?(Test4IncludeP)
  assert_false Test4IncludeP.include?(Test4IncludeP)
end

assert('Module#included', '15.2.2.4.29') do
  module Test4Included
    Const4Included = 42
    def self.included mod
      Test4Included.const_set(:Const4Included2, mod)
    end
  end
  module Test4Included2
    include Test4Included
  end

  assert_equal 42, Test4Included2.const_get(:Const4Included)
  assert_equal Test4Included2, Test4Included2.const_get(:Const4Included2)
end

assert('Module#included_modules', '15.2.2.4.30') do
  module Test4includedModules
  end
  module Test4includedModules2
    include Test4includedModules
  end
  r = Test4includedModules2.included_modules

  assert_equal Array, r.class
  assert_true r.include?(Test4includedModules)
end

assert('Module#initialize', '15.2.2.4.31') do
  assert_kind_of Module, Module.new
  mod = Module.new { def hello; "hello"; end }
  assert_equal [:hello], mod.instance_methods
  a = nil
  mod = Module.new { |m| a = m }
  assert_equal mod, a
end

assert('Module#instance_methods', '15.2.2.4.33') do
  module Test4InstanceMethodsA
    def method1()  end
  end
  class Test4InstanceMethodsB
    def method2()  end
  end
  class Test4InstanceMethodsC < Test4InstanceMethodsB
    def method3()  end
  end

  r = Test4InstanceMethodsC.instance_methods(true)

  assert_equal [:method1], Test4InstanceMethodsA.instance_methods
  assert_equal [:method2], Test4InstanceMethodsB.instance_methods(false)
  assert_equal [:method3], Test4InstanceMethodsC.instance_methods(false)
  assert_equal Array, r.class
  assert_true r.include?(:method3)
  assert_true r.include?(:method2)
end

assert('Module#method_defined?', '15.2.2.4.34') do
  module Test4MethodDefined
    module A
      def method1()  end
    end

    class B
      def method2()  end
    end

    class C < B
      include A
      def method3()  end
    end
  end

  assert_true Test4MethodDefined::A.method_defined? :method1
  assert_true Test4MethodDefined::C.method_defined? :method1
  assert_true Test4MethodDefined::C.method_defined? "method2"
  assert_true Test4MethodDefined::C.method_defined? "method3"
  assert_false Test4MethodDefined::C.method_defined? "method4"
end


assert('Module#module_eval', '15.2.2.4.35') do
  module Test4ModuleEval
    @a = 11
    @b = 12
  end

  assert_equal 11, Test4ModuleEval.module_eval{ @a }
  assert_equal 12, Test4ModuleEval.module_eval{ @b }
end

assert('Module#remove_class_variable', '15.2.2.4.39') do
  class Test4RemoveClassVariable
    @@cv = 99
  end

  assert_equal 99, Test4RemoveClassVariable.remove_class_variable(:@@cv)
  assert_false Test4RemoveClassVariable.class_variables.include? :@@cv
end

assert('Module#remove_const', '15.2.2.4.40') do
  module Test4RemoveConst
    ExistingConst = 23
  end

  result = Test4RemoveConst.module_eval { remove_const :ExistingConst }

  name_error = false
  begin
    Test4RemoveConst.module_eval { remove_const :NonExistingConst }
  rescue NameError
    name_error = true
  end

  # Constant removed from Module
  assert_false Test4RemoveConst.const_defined? :ExistingConst
  # Return value of binding
  assert_equal 23, result
  # Name Error raised when Constant doesn't exist
  assert_true name_error
end

assert('Module#remove_method', '15.2.2.4.41') do
  module Test4RemoveMethod
    class Parent
      def hello
      end
     end

     class Child < Parent
      def hello
      end
    end
  end

  assert_true Test4RemoveMethod::Child.class_eval{ remove_method :hello }
  assert_true Test4RemoveMethod::Child.instance_methods.include? :hello
  assert_false Test4RemoveMethod::Child.instance_methods(false).include? :hello
end

assert('Module#undef_method', '15.2.2.4.42') do
  module Test4UndefMethod
    class Parent
      def hello
      end
     end

     class Child < Parent
      def hello
      end
     end

     class GrandChild < Child
     end
  end
  Test4UndefMethod::Child.class_eval{ undef_method :hello }

  assert_true Test4UndefMethod::Parent.new.respond_to?(:hello)
  assert_false Test4UndefMethod::Child.new.respond_to?(:hello)
  assert_false Test4UndefMethod::GrandChild.new.respond_to?(:hello)
end

# Not ISO specified

assert('Module#to_s') do
  module Test4to_sModules
  end

  assert_equal 'Test4to_sModules', Test4to_sModules.to_s
end

assert('Module#inspect') do
  module Test4to_sModules
  end

  assert_equal 'Test4to_sModules', Test4to_sModules.inspect
end

assert('clone Module') do
  module M1
    def foo
      true
    end
  end

  class B
    include M1.clone
  end

  B.new.foo
end

assert('Module#module_function') do
  module M
    def modfunc; end
    module_function :modfunc
  end

  assert_true M.respond_to?(:modfunc)
end

##
# NameError ISO Test

assert('NameError', '15.2.31') do
  assert_equal Class, NameError.class
end

assert('NameError#name', '15.2.31.2.1') do

  # This check is not duplicate with 15.2.31.2.2 check.
  # Because the NameError in this test is generated in
  # C API.
  class TestDummy
    alias foo bar
  rescue NameError => e
    $test_dummy_result = e.name
  end

  assert_equal :bar, $test_dummy_result
end

assert('NameError#initialize', '15.2.31.2.2') do
   e = NameError.new('a', :foo)

   assert_equal NameError, e.class
   assert_equal 'a', e.message
   assert_equal :foo, e.name
end
##
# NilClass ISO Test

assert('NilClass', '15.2.4') do
  assert_equal Class, NilClass.class
end

assert('NilClass', '15.2.4.1') do
  assert_equal NilClass, nil.class
  assert_false NilClass.method_defined? :new
end

assert('NilClass#&', '15.2.4.3.1') do
  assert_false nil.&(true)
  assert_false nil.&(nil)
end

assert('NilClass#^', '15.2.4.3.2') do
  assert_true nil.^(true)
  assert_false nil.^(false)
end

assert('NilClass#|', '15.2.4.3.3') do
  assert_true nil.|(true)
  assert_false nil.|(false)
end

assert('NilClass#nil?', '15.2.4.3.4') do
  assert_true nil.nil?
end

assert('NilClass#to_s', '15.2.4.3.5') do
  assert_equal '', nil.to_s
end
##
# NoMethodError ISO Test

assert('NoMethodError', '15.2.32') do
  NoMethodError.class == Class
  assert_raise NoMethodError do
    doesNotExistAsAMethodNameForVerySure("")
  end
end

assert('NoMethodError#args', '15.2.32.2.1') do
  a = NoMethodError.new 'test', :test, [1, 2]
  assert_equal [1, 2], a.args

  assert_nothing_raised do
    begin
      doesNotExistAsAMethodNameForVerySure 3, 1, 4
    rescue NoMethodError => e
      assert_equal [3, 1, 4], e.args
    end
  end
end
##
# Numeric ISO Test

assert('Numeric', '15.2.7') do
  assert_equal Class, Numeric.class
end

assert('Numeric#+@', '15.2.7.4.1') do
  assert_equal(+1, +1)
end

assert('Numeric#-@', '15.2.7.4.2') do
  assert_equal(-1, -1)
end

assert('Numeric#abs', '15.2.7.4.3') do
  assert_equal(1, 1.abs)
  assert_equal(1.0, -1.abs)
end

assert('Numeric#pow') do
  assert_equal(8, 2 ** 3)
  assert_equal(-8, -2 ** 3)
  assert_equal(1, 2 ** 0)
  assert_equal(1, 2.2 ** 0)
  assert_equal(0.5, 2 ** -1)
end

assert('Numeric#/', '15.2.8.3.4') do
  n = Class.new(Numeric){ def /(x); 15.1;end }.new

  assert_equal(2, 10/5)
  assert_equal(0.0625, 1/16)
  assert_equal(15.1, n/10)
  assert_raise(TypeError){ 1/n }
  assert_raise(TypeError){ 1/nil }
end

# Not ISO specified

assert('Numeric#**') do
  assert_equal 8.0, 2.0**3
end
##
# Object ISO Test

assert('Object', '15.2.1') do
  assert_equal Class, Object.class
end

assert('Object superclass', '15.2.1.2') do
  assert_equal BasicObject, Object.superclass
end

##
# Proc ISO Test

assert('Proc', '15.2.17') do
  assert_equal Class, Proc.class
end

assert('Proc.new', '15.2.17.3.1') do
  assert_raise ArgumentError do
    Proc.new
  end

  assert_equal (Proc.new {}).class, Proc
end

assert('Proc#[]', '15.2.17.4.1') do
  a = 0
  b = Proc.new { a += 1 }
  b.[]

  a2 = 0
  b2 = Proc.new { |i| a2 += i }
  b2.[](5)

  assert_equal 1, a
  assert_equal 5, a2
end

assert('Proc#call', '15.2.17.4.3') do
  a = 0
  b = Proc.new { a += 1 }
  b.call

  a2 = 0
  b2 = Proc.new { |i| a2 += i }
  b2.call(5)

  assert_equal 1, a
  assert_equal 5, a2
end

assert('Proc#call proc args pos block') do
  pr = Proc.new {|a,b,&c|
    [a, b, c.class, c&&c.call(:x)]
  }
  assert_equal [nil, nil, Proc, :proc], (pr.call(){ :proc })
  assert_equal [1, nil, Proc, :proc], (pr.call(1){ :proc })
  assert_equal [1, 2, Proc, :proc], (pr.call(1, 2){ :proc })
  assert_equal [1, 2, Proc, :proc], (pr.call(1, 2, 3){ :proc })
  assert_equal [1, 2, Proc, :proc], (pr.call(1, 2, 3, 4){ :proc })

  assert_equal [nil, nil, Proc, :x], (pr.call(){|x| x})
  assert_equal [1, nil, Proc, :x], (pr.call(1){|x| x})
  assert_equal [1, 2, Proc, :x], (pr.call(1, 2){|x| x})
  assert_equal [1, 2, Proc, :x], (pr.call(1, 2, 3){|x| x})
  assert_equal [1, 2, Proc, :x], (pr.call(1, 2, 3, 4){|x| x})
end

assert('Proc#call proc args pos rest post') do
  pr = Proc.new {|a,b,*c,d,e|
    [a,b,c,d,e]
  }
  assert_equal [nil, nil, [], nil, nil], pr.call()
  assert_equal [1, nil, [], nil, nil], pr.call(1)
  assert_equal [1, 2, [], nil, nil], pr.call(1,2)
  assert_equal [1, 2, [], 3, nil], pr.call(1,2,3)
  assert_equal [1, 2, [], 3, 4], pr.call(1,2,3,4)
  assert_equal [1, 2, [3], 4, 5], pr.call(1,2,3,4,5)
  assert_equal [1, 2, [3, 4], 5, 6], pr.call(1,2,3,4,5,6)
  assert_equal [1, 2, [3, 4, 5], 6,7], pr.call(1,2,3,4,5,6,7)

  assert_equal [nil, nil, [], nil, nil], pr.call([])
  assert_equal [1, nil, [], nil, nil], pr.call([1])
  assert_equal [1, 2, [], nil, nil], pr.call([1,2])
  assert_equal [1, 2, [], 3, nil], pr.call([1,2,3])
  assert_equal [1, 2, [], 3, 4], pr.call([1,2,3,4])
  assert_equal [1, 2, [3], 4, 5], pr.call([1,2,3,4,5])
  assert_equal [1, 2, [3, 4], 5, 6], pr.call([1,2,3,4,5,6])
  assert_equal [1, 2, [3, 4, 5], 6,7], pr.call([1,2,3,4,5,6,7])
end

assert('Proc#return_does_not_break_self') do
  class TestClass
    attr_accessor :block
    def initialize
    end
    def return_array
      @block = Proc.new { self }
      return []
    end
    def return_instance_variable
      @block = Proc.new { self }
      return @block
    end
    def return_const_fixnum
      @block = Proc.new { self }
      return 123
    end
    def return_nil
      @block = Proc.new { self }
      return nil
    end
  end

  c = TestClass.new
  assert_equal [], c.return_array
  assert_equal c, c.block.call

  c.return_instance_variable
  assert_equal c, c.block.call

  assert_equal 123, c.return_const_fixnum
  assert_equal c, c.block.call

  assert_equal nil, c.return_nil
  assert_equal c, c.block.call
end

assert('&obj call to_proc if defined') do
  pr = Proc.new{}
  def mock(&b)
    b
  end
  assert_equal pr.object_id, mock(&pr).object_id
  assert_equal pr, mock(&pr)

  obj = Object.new
  def obj.to_proc
    Proc.new{ :from_to_proc }
  end
  assert_equal :from_to_proc, mock(&obj).call

  assert_raise(TypeError){ mock(&(Object.new)) }
end
##
# Range ISO Test

assert('Range', '15.2.14') do
  assert_equal Class, Range.class
end

assert('Range#==', '15.2.14.4.1') do
  assert_true (1..10) == (1..10)
  assert_false (1..10) == (1..100)
  assert_true (1..10) == Range.new(1.0, 10.0)
end

assert('Range#===', '15.2.14.4.2') do
  a = (1..10)

  assert_true a === 5
  assert_false a === 20
end

assert('Range#begin', '15.2.14.4.3') do
  assert_equal 1, (1..10).begin
end

assert('Range#each', '15.2.14.4.4') do
  a = (1..3)
  b = 0
  a.each {|i| b += i}
  assert_equal 6, b
end

assert('Range#end', '15.2.14.4.5') do
  assert_equal 10, (1..10).end
end

assert('Range#exclude_end?', '15.2.14.4.6') do
  assert_true (1...10).exclude_end?
  assert_false (1..10).exclude_end?
end

assert('Range#first', '15.2.14.4.7') do
  assert_equal 1, (1..10).first
end

assert('Range#include?', '15.2.14.4.8') do
  a = (1..10)

  assert_true a.include?(5)
  assert_false a.include?(20)
end

assert('Range#initialize', '15.2.14.4.9') do
  a = Range.new(1, 10, true)
  b = Range.new(1, 10, false)

  assert_equal (1...10), a
  assert_true a.exclude_end?
  assert_equal (1..10), b
  assert_false b.exclude_end?
end

assert('Range#last', '15.2.14.4.10') do
  assert_equal 10, (1..10).last
end

assert('Range#member?', '15.2.14.4.11') do
  a = (1..10)

  assert_true a.member?(5)
  assert_false a.member?(20)
end

assert('Range#to_s', '15.2.14.4.12') do
  assert_equal "0..1", (0..1).to_s
  assert_equal "0...1", (0...1).to_s
  assert_equal "a..b", ("a".."b").to_s
  assert_equal "a...b", ("a"..."b").to_s
end

assert('Range#inspect', '15.2.14.4.13') do
  assert_equal "0..1", (0..1).inspect
  assert_equal "0...1", (0...1).inspect
  assert_equal "\"a\"..\"b\"", ("a".."b").inspect
  assert_equal "\"a\"...\"b\"", ("a"..."b").inspect
end

assert('Range#eql?', '15.2.14.4.14') do
  assert_true (1..10).eql? (1..10)
  assert_false (1..10).eql? (1..100)
  assert_false (1..10).eql? (Range.new(1.0, 10.0))
  assert_false (1..10).eql? "1..10"
end
##
# RangeError ISO Test

assert('RangeError', '15.2.26') do
  assert_equal Class, RangeError.class
end
##
# RegexpError ISO Test

# TODO broken ATM assert('RegexpError', '15.2.27') do
##
# RuntimeError ISO Test

assert('RuntimeError', '15.2.28') do
  assert_equal Class, RuntimeError.class
end
##
# StandardError ISO Test

assert('StandardError', '15.2.23') do
  assert_equal Class, StandardError.class
end
##
# String ISO Test

assert('String', '15.2.10') do
  assert_equal Class, String.class
end

assert('String#<=>', '15.2.10.5.1') do
  a = '' <=> ''
  b = '' <=> 'not empty'
  c = 'not empty' <=> ''
  d = 'abc' <=> 'cba'
  e = 'cba' <=> 'abc'

  assert_equal  0, a
  assert_equal(-1, b)
  assert_equal  1, c
  assert_equal(-1, d)
  assert_equal  1, e
end

assert('String#==', '15.2.10.5.2') do
  assert_equal 'abc', 'abc'
  assert_not_equal 'abc', 'cba'
end

# 'String#=~', '15.2.10.5.3' will be tested in mrbgems.

assert('String#+', '15.2.10.5.4') do
  assert_equal 'ab', 'a' + 'b'
end

assert('String#*', '15.2.10.5.5') do
  assert_equal 'aaaaa', 'a' * 5
  assert_equal '', 'a' * 0
  assert_raise(ArgumentError) do
    'a' * -1
  end
end

assert('String#[]', '15.2.10.5.6') do
  # length of args is 1
  a = 'abc'[0]
  b = 'abc'[-1]
  c = 'abc'[10]
  d = 'abc'[-10]

  # length of args is 2
  a1 = 'abc'[0, -1]
  b1 = 'abc'[10, 0]
  c1 = 'abc'[-10, 0]
  d1 = 'abc'[0, 0]
  e1 = 'abc'[1, 2]

  # args is RegExp
  # It will be tested in mrbgems.

  # args is String
  a3 = 'abc'['bc']
  b3 = 'abc'['XX']

  assert_equal 'a', a
  assert_equal 'c', b
  assert_nil c
  assert_nil d
  assert_nil a1
  assert_nil b1
  assert_nil c1
  assert_equal '', d1
  assert_equal 'bc', e1
  assert_equal 'bc', a3
  assert_nil b3
end

assert('String#[] with Range') do
  a1 = 'abc'[1..0]
  b1 = 'abc'[1..1]
  c1 = 'abc'[1..2]
  d1 = 'abc'[1..3]
  e1 = 'abc'[1..4]
  f1 = 'abc'[0..-2]
  g1 = 'abc'[-2..3]
  h1 = 'abc'[3..4]
  i1 = 'abc'[4..5]
  j1 = 'abcdefghijklmnopqrstuvwxyz'[1..3]
  a2 = 'abc'[1...0]
  b2 = 'abc'[1...1]
  c2 = 'abc'[1...2]
  d2 = 'abc'[1...3]
  e2 = 'abc'[1...4]
  f2 = 'abc'[0...-2]
  g2 = 'abc'[-2...3]
  h2 = 'abc'[3...4]
  i2 = 'abc'[4...5]
  j2 = 'abcdefghijklmnopqrstuvwxyz'[1...3]

  assert_equal '', a1
  assert_equal 'b', b1
  assert_equal 'bc', c1
  assert_equal 'bc', d1
  assert_equal 'bc', e1
  assert_equal 'ab', f1
  assert_equal 'bc', g1
  assert_equal '', h1
  assert_nil i2
  assert_equal 'bcd', j1
  assert_equal '', a2
  assert_equal '', b2
  assert_equal 'b', c2
  assert_equal 'bc', d2
  assert_equal 'bc', e2
  assert_equal 'a', f2
  assert_equal 'bc', g2
  assert_equal '', h2
  assert_nil i2
  assert_equal 'bc', j2
end

assert('String#capitalize', '15.2.10.5.7') do
  a = 'abc'
  a.capitalize

  assert_equal 'abc', a
  assert_equal 'Abc', 'abc'.capitalize
end

assert('String#capitalize!', '15.2.10.5.8') do
  a = 'abc'
  a.capitalize!

  assert_equal 'Abc', a
  assert_equal nil, 'Abc'.capitalize!
end

assert('String#chomp', '15.2.10.5.9') do
  a = 'abc'.chomp
  b = ''.chomp
  c = "abc\n".chomp
  d = "abc\n\n".chomp
  e = "abc\t".chomp("\t")
  f = "abc\n"

  f.chomp

  assert_equal 'abc', a
  assert_equal '', b
  assert_equal 'abc', c
  assert_equal "abc\n", d
  assert_equal 'abc', e
  assert_equal "abc\n", f
end

assert('String#chomp!', '15.2.10.5.10') do
  a = 'abc'
  b = ''
  c = "abc\n"
  d = "abc\n\n"
  e = "abc\t"

  a.chomp!
  b.chomp!
  c.chomp!
  d.chomp!
  e.chomp!("\t")

  assert_equal 'abc', a
  assert_equal '', b
  assert_equal 'abc', c
  assert_equal "abc\n", d
  assert_equal 'abc', e
end

assert('String#chop', '15.2.10.5.11') do
  a = ''.chop
  b = 'abc'.chop
  c = 'abc'

  c.chop

  assert_equal '', a
  assert_equal 'ab', b
  assert_equal 'abc', c
end

assert('String#chop!', '15.2.10.5.12') do
  a = ''
  b = 'abc'

  a.chop!
  b.chop!

  assert_equal a, ''
  assert_equal b, 'ab'
end

assert('String#downcase', '15.2.10.5.13') do
  a = 'ABC'.downcase
  b = 'ABC'

  b.downcase

  assert_equal 'abc', a
  assert_equal 'ABC', b
end

assert('String#downcase!', '15.2.10.5.14') do
  a = 'ABC'

  a.downcase!

  assert_equal 'abc', a
  assert_equal nil, 'abc'.downcase!
end

assert('String#each_line', '15.2.10.5.15') do
  a = "first line\nsecond line\nthird line"
  list = ["first line\n", "second line\n", "third line"]
  n_list = []

  a.each_line do |line|
    n_list << line
  end

  assert_equal list, n_list
end

assert('String#empty?', '15.2.10.5.16') do
  a = ''
  b = 'not empty'

  assert_true a.empty?
  assert_false b.empty?
end

assert('String#eql?', '15.2.10.5.17') do
  assert_true 'abc'.eql?('abc')
  assert_false 'abc'.eql?('cba')
end

assert('String#gsub', '15.2.10.5.18') do
  assert_equal('aBcaBc', 'abcabc'.gsub('b', 'B'), 'gsub without block')
  assert_equal('aBcaBc', 'abcabc'.gsub('b'){|w| w.capitalize }, 'gsub with block')
  assert_equal('$a$a$',  '#a#a#'.gsub('#', '$'), 'mruby/mruby#847')
  assert_equal('$a$a$',  '#a#a#'.gsub('#'){|w| '$' }, 'mruby/mruby#847 with block')
  assert_equal('$$a$$',  '##a##'.gsub('##', '$$'), 'mruby/mruby#847 another case')
  assert_equal('$$a$$',  '##a##'.gsub('##'){|w| '$$' }, 'mruby/mruby#847 another case with block')
  assert_equal('A',      'a'.gsub('a', 'A'))
  assert_equal('A',      'a'.gsub('a'){|w| w.capitalize })
end

assert('String#gsub!', '15.2.10.5.19') do
  a = 'abcabc'
  a.gsub!('b', 'B')

  b = 'abcabc'
  b.gsub!('b') { |w| w.capitalize }

  assert_equal 'aBcaBc', a
  assert_equal 'aBcaBc', b
end

assert('String#hash', '15.2.10.5.20') do
  a = 'abc'

  assert_equal 'abc'.hash, a.hash
end

assert('String#include?', '15.2.10.5.21') do
  assert_true 'abc'.include?(97)
  assert_false 'abc'.include?(100)
  assert_true 'abc'.include?('a')
  assert_false 'abc'.include?('d')
end

assert('String#index', '15.2.10.5.22') do
  assert_equal 0, 'abc'.index('a')
  assert_nil 'abc'.index('d')
  assert_equal 3, 'abcabc'.index('a', 1)
end

assert('String#initialize', '15.2.10.5.23') do
  a = ''
  a.initialize('abc')
  assert_equal 'abc', a

  a.initialize('abcdefghijklmnopqrstuvwxyz')
  assert_equal 'abcdefghijklmnopqrstuvwxyz', a
end

assert('String#initialize_copy', '15.2.10.5.24') do
  a = ''
  a.initialize_copy('abc')

  assert_equal 'abc', a
end

assert('String#intern', '15.2.10.5.25') do
  assert_equal :abc, 'abc'.intern
end

assert('String#length', '15.2.10.5.26') do
  assert_equal 3, 'abc'.length
end

# 'String#match', '15.2.10.5.27' will be tested in mrbgems.

assert('String#replace', '15.2.10.5.28') do
  a = ''
  a.replace('abc')

  assert_equal 'abc', a
  assert_equal 'abc', 'cba'.replace(a)

  b = 'abc' * 10
  c = ('cba' * 10).dup
  b.replace(c);
  c.replace(b);
  assert_equal c, b

  # shared string
  s = "foo" * 100
  a = s[10, 90]                # create shared string
  assert_equal("", s.replace(""))    # clear
  assert_equal("", s)          # s is cleared
  assert_not_equal("", a)      # a should not be affected
end

assert('String#reverse', '15.2.10.5.29') do
  a = 'abc'
  a.reverse

  assert_equal 'abc', a
  assert_equal 'cba', 'abc'.reverse
end

assert('String#reverse!', '15.2.10.5.30') do
  a = 'abc'
  a.reverse!

  assert_equal 'cba', a
  assert_equal 'cba', 'abc'.reverse!
end

assert('String#rindex', '15.2.10.5.31') do
  assert_equal 0, 'abc'.rindex('a')
  assert_nil 'abc'.rindex('d')
  assert_equal 0, 'abcabc'.rindex('a', 1)
  assert_equal 3, 'abcabc'.rindex('a', 4)

  assert_equal 3,   'abcabc'.rindex(97)
  assert_equal nil, 'abcabc'.rindex(0)
end

# 'String#scan', '15.2.10.5.32' will be tested in mrbgems.

assert('String#size', '15.2.10.5.33') do
  assert_equal 3, 'abc'.size
end

assert('String#slice', '15.2.10.5.34') do
  # length of args is 1
  a = 'abc'.slice(0)
  b = 'abc'.slice(-1)
  c = 'abc'.slice(10)
  d = 'abc'.slice(-10)

  # length of args is 2
  a1 = 'abc'.slice(0, -1)
  b1 = 'abc'.slice(10, 0)
  c1 = 'abc'.slice(-10, 0)
  d1 = 'abc'.slice(0, 0)
  e1 = 'abc'.slice(1, 2)

  # slice of shared string
  e11 = e1.slice(0)

  # args is RegExp
  # It will be tested in mrbgems.

  # args is String
  a3 = 'abc'.slice('bc')
  b3 = 'abc'.slice('XX')

  assert_equal 'a', a
  assert_equal 'c', b
  assert_nil c
  assert_nil d
  assert_nil a1
  assert_nil b1
  assert_nil c1
  assert_equal '', d1
  assert_equal 'bc', e1
  assert_equal 'b', e11
  assert_equal 'bc', a3
  assert_nil b3
end

# TODO Broken ATM
assert('String#split', '15.2.10.5.35') do
  # without RegExp behavior is actually unspecified
  assert_equal ['abc', 'abc', 'abc'], 'abc abc abc'.split
  assert_equal ["a", "b", "c", "", "d"], 'a,b,c,,d'.split(',')
  assert_equal ['abc', 'abc', 'abc'], 'abc abc abc'.split(nil)
  assert_equal ['a', 'b', 'c'], 'abc'.split("")
end

assert('String#sub', '15.2.10.5.36') do
  assert_equal 'aBcabc', 'abcabc'.sub('b', 'B')
  assert_equal 'aBcabc', 'abcabc'.sub('b') { |w| w.capitalize }
  assert_equal 'aa$', 'aa#'.sub('#', '$')
end

assert('String#sub!', '15.2.10.5.37') do
  a = 'abcabc'
  a.sub!('b', 'B')

  b = 'abcabc'
  b.sub!('b') { |w| w.capitalize }

  assert_equal 'aBcabc', a
  assert_equal 'aBcabc', b
end

assert('String#to_f', '15.2.10.5.38') do
  a = ''.to_f
  b = '123456789'.to_f
  c = '12345.6789'.to_f

  assert_float(0.0, a)
  assert_float(123456789.0, b)
  assert_float(12345.6789, c)
end

assert('String#to_i', '15.2.10.5.39') do
  a = ''.to_i
  b = '32143'.to_i
  c = 'a'.to_i(16)
  d = '100'.to_i(2)
  e = '1_000'.to_i

  assert_equal 0, a
  assert_equal 32143, b
  assert_equal 10, c
  assert_equal 4, d
  assert_equal 1_000, e
end

assert('String#to_s', '15.2.10.5.40') do
  assert_equal 'abc', 'abc'.to_s
end

assert('String#to_sym', '15.2.10.5.41') do
  assert_equal :abc, 'abc'.to_sym
end

assert('String#upcase', '15.2.10.5.42') do
  a = 'abc'.upcase
  b = 'abc'

  b.upcase

  assert_equal 'ABC', a
  assert_equal 'abc', b
end

assert('String#upcase!', '15.2.10.5.43') do
  a = 'abc'

  a.upcase!

  assert_equal 'ABC', a
  assert_equal nil, 'ABC'.upcase!

  a = 'abcdefghijklmnopqrstuvwxyz'
  b = a.dup
  a.upcase!
  b.upcase!
  assert_equal 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', b
end

assert('String#inspect', '15.2.10.5.46') do
  # should not raise an exception - regress #1210
  assert_nothing_raised do
  ("\1" * 100).inspect
  end

  assert_equal "\"\\000\"", "\0".inspect
end

# Not ISO specified

assert('String interpolation (mrb_str_concat for shared strings)') do
  a = "A" * 32
  assert_equal "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA:", "#{a}:"
end

assert('Check the usage of a NUL character') do
  "qqq\0ppp"
end

assert('String#bytes') do
  str1 = "hello"
  bytes1 = [104, 101, 108, 108, 111]

  str2 = "\xFF"
  bytes2 = [0xFF]

  assert_equal bytes1, str1.bytes
  assert_equal bytes2, str2.bytes
end

assert('String#each_byte') do
  str1 = "hello"
  bytes1 = [104, 101, 108, 108, 111]
  bytes2 = []

  str1.each_byte {|b| bytes2 << b }

  assert_equal bytes1, bytes2
end
[
  # [:Object, :implementation_defined_value, '15.2.2.1'],
  [:Module, :Object, '15.2.2.2'],
  [:Class, :Module, '15.2.3.2'],
  [:NilClass, :Object, '15.2.4.2'],
  [:TrueClass, :Object, '15.2.5.2'],
  [:FalseClass, :Object, '15.2.6.2'],
  [:Numeric, :Object, '15.2.7.2'],
  [:Integer, :Numeric, '15.2.8.2'],
  [:Float, :Numeric, '15.2.9.2'],
  [:String, :Object, '15.2.10.2'],
  [:Symbol, :Object, '15.2.11.2'],
  [:Array, :Object, '15.2.12.2'],
  [:Hash, :Object, '15.2.13.2'],
  [:Range, :Object, '15.2.14.2'],
#  [:Regexp, :Object, '15.2.15.2'],      #No Regexp in mruby core
#  [:MatchData, :Object, '15.2.16.2'],
  [:Proc, :Object, '15.2.17.2'],
#  [:Struct, :Object, '15.2.18.2'],
#  [:Time, :Object, '15.2.19.2'],
#  [:IO, :Object, '15.2.20.2'],
#  [:File, :IO, '15.2.21.2'],
  [:Exception, :Object, '15.2.22.2'],
  [:StandardError, :Exception, '15.2.23.2'],
  [:ArgumentError, :StandardError, '15.2.24.2'],
  [:LocalJumpError, :StandardError, '15.2.25.2'],
  [:RangeError, :StandardError, '12.2.26.2'],
  [:RegexpError, :StandardError, '12.2.27.2'],
  [:RuntimeError, :StandardError, '12.2.28.2'],
  [:TypeError, :StandardError, '12.2.29.2'],
#  [:ZeroDivisionError, :StandardError, '12.2.30.2'],  # No ZeroDivisionError in mruby
  [:NameError, :StandardError, '15.2.31.2'],
  [:NoMethodError, :NameError, '15.2.32.2'],
  [:IndexError, :StandardError, '15.2.33.2'],
#  [:IOError, :StandardError, '12.2.34.2'],
#  [:EOFError, :IOError, '12.2.35.2'],
#  [:SystemCallError, :StandardError, '15.2.36.2'],
  [:ScriptError, :Exception, '12.2.37.2'],
  [:SyntaxError, :ScriptError, '12.2.38.2'],
#  [:LoadError, :ScriptError, '12.2.39,2'],
].each do |cls, super_cls, iso|
  assert "Direct superclass of #{cls}", iso do
    skip "#{cls} isn't defined" unless Object.const_defined? cls
    assert_equal Object.const_get(super_cls), Object.const_get(cls).superclass
  end
end
##
# Symbol ISO Test

assert('Symbol', '15.2.11') do
  assert_equal Class, Symbol.class
end

assert('Symbol#===', '15.2.11.3.1') do
  assert_true :abc == :abc
  assert_false :abc == :cba
end

assert('Symbol#id2name', '15.2.11.3.2') do
  assert_equal 'abc', :abc.id2name
end

assert('Symbol#to_s', '15.2.11.3.3') do
  assert_equal  'abc', :abc.to_s
end

assert('Symbol#to_sym', '15.2.11.3.4') do
  assert_equal :abc, :abc.to_sym
end

assert('super', '11.3.4') do
  assert_raise NoMethodError do
    super
  end

  class SuperFoo
    def foo
      true
    end
    def bar(*a)
      a
    end
  end
  class SuperBar < SuperFoo
    def foo
      super
    end
    def bar(*a)
      super(*a)
    end
  end
  bar = SuperBar.new

  assert_true bar.foo
  assert_equal [1,2,3], bar.bar(1,2,3)
end

assert('yield', '11.3.5') do
  assert_raise LocalJumpError do
    yield
  end
end

assert('Abbreviated variable assignment', '11.4.2.3.2') do
  a ||= 1
  b &&= 1
  c = 1
  c += 2

  assert_equal 1, a
  assert_nil b
  assert_equal 3, c
end

assert('case expression', '11.5.2.2.4') do
  # case-expression-with-expression, one when-clause
  x = 0
  case "a"
  when "a"
    x = 1
  end
  assert_equal 1, x

  # case-expression-with-expression, multiple when-clauses
  x = 0
  case "b"
  when "a"
    x = 1
  when "b"
    x = 2
  end
  assert_equal 2, x

  # no matching when-clause
  x = 0
  case "c"
  when "a"
    x = 1
  when "b"
    x = 2
  end
  assert_equal 0, x

  # case-expression-with-expression, one when-clause and one else-clause
  a = 0
  case "c"
  when "a"
    x = 1
  else
    x = 3
  end
  assert_equal 3, x

  # case-expression-without-expression, one when-clause
  x = 0
  case
  when true
    x = 1
  end
  assert_equal 1, x

  # case-expression-without-expression, multiple when-clauses
  x = 0
  case
  when 0 == 1
    x = 1
  when 1 == 1
    x = 2
  end
  assert_equal 2, x

  # case-expression-without-expression, one when-clause and one else-clause
  x = 0
  case
  when 0 == 1
    x = 1
  else
    x = 3
  end
  assert_equal 3, x

  # multiple when-arguments
  x = 0
  case 4
  when 1, 3, 5
    x = 1
  when 2, 4, 6
    x = 2
  end
  assert_equal 2, x

  # when-argument with splatting argument
  x = :integer
  odds  = [ 1, 3, 5, 7, 9 ]
  evens = [ 2, 4, 6, 8 ]
  case 5
  when *odds
    x = :odd
  when *evens
    x = :even
  end
  assert_equal :odd, x

  true
end

assert('Nested const reference') do
  module Syntax4Const
    CONST1 = "hello world"
    class Const2
      def const1
        CONST1
      end
    end
  end
  assert_equal "hello world", Syntax4Const::CONST1
  assert_equal "hello world", Syntax4Const::Const2.new.const1
end

assert('Abbreviated variable assignment as returns') do
  module Syntax4AbbrVarAsgnAsReturns
    class A
      def b
        @c ||= 1
      end
    end
  end
  assert_equal 1, Syntax4AbbrVarAsgnAsReturns::A.new.b
end

assert('Splat and mass assignment') do
  *a = *[1,2,3]
  b, *c = *[7,8,9]

  assert_equal [1,2,3], a
  assert_equal 7, b
  assert_equal [8,9], c
end

assert('Return values of case statements') do
  a = [] << case 1
  when 3 then 2
  when 2 then 2
  when 1 then 2
  end

  b = [] << case 1
  when 2 then 2
  else
  end

  def fb
    n = 0
    Proc.new do
      n += 1
      case
      when n % 15 == 0
      else n
      end
    end
  end

  assert_equal [2], a
  assert_equal [nil], b
  assert_equal 1, fb.call
end

assert('splat in case statement') do
  values = [3,5,1,7,8]
  testa = [1,2,7]
  testb = [5,6]
  resulta = []
  resultb = []
  resultc = []
  values.each do |value|
    case value
    when *testa
      resulta << value
    when *testb
      resultb << value
    else
      resultc << value
    end
  end

  assert_equal [1,7], resulta
  assert_equal [5], resultb
  assert_equal [3,8], resultc
end

assert('External command execution.') do
  class << Kernel
    sym = '`'.to_sym
    alias_method :old_cmd, sym

    results = []
    define_method(sym) do |str|
      results.push str
      str
    end

    `test` # NOVAL NODE_XSTR
    `test dynamic #{sym}` # NOVAL NODE_DXSTR
    assert_equal ['test', 'test dynamic `'], results

    t = `test` # VAL NODE_XSTR
    assert_equal 'test', t
    assert_equal ['test', 'test dynamic `', 'test'], results

    t = `test dynamic #{sym}` # VAL NODE_DXSTR
    assert_equal 'test dynamic `', t
    assert_equal ['test', 'test dynamic `', 'test', 'test dynamic `'], results

    alias_method sym, :old_cmd
  end
  true
end

assert('parenthesed do-block in cmdarg') do
  class ParenDoBlockCmdArg
    def test(block)
      block.call
    end
  end
  x = ParenDoBlockCmdArg.new
  result = x.test (Proc.new do :ok; end)
  assert_equal :ok, result
end

assert('method definition in cmdarg') do
  if false
    bar def foo; self.each do end end
  end
  true
end

assert('optional argument in the rhs default expressions') do
  class OptArgInRHS
    def foo
      "method called"
    end
    def t(foo = foo)
      foo
    end
    def t2(foo = foo())
      foo
    end
  end
  o = OptArgInRHS.new
  assert_nil(o.t)
  assert_equal("method called", o.t2)
end

assert('optional block argument in the rhs default expressions') do
  assert_nil(Proc.new {|foo = foo| foo}.call)
end

assert('multiline comments work correctly') do
=begin
this is a comment with nothing after begin and end
=end
=begin  this is a comment
this is a comment with extra after =begin
=end
=begin
this is a comment that has =end with spaces after it
=end
=begin this is a comment
this is a comment that has extra after =begin and =end with spaces after it
=end
  line = __LINE__
=begin  this is a comment
this is a comment that has extra after =begin and =end with tabs after it
=end  xxxxxxxxxxxxxxxxxxxxxxxxxx
  assert_equal(line + 4, __LINE__)
end
##
# TrueClass ISO Test

assert('TrueClass', '15.2.5') do
  assert_equal Class, TrueClass.class
end

assert('TrueClass true', '15.2.5.1') do
  assert_true true
  assert_equal TrueClass, true.class
  assert_false TrueClass.method_defined? :new
end

assert('TrueClass#&', '15.2.5.3.1') do
  assert_true true.&(true)
  assert_false true.&(false)
end

assert('TrueClass#^', '15.2.5.3.2') do
  assert_false true.^(true)
  assert_true true.^(false)
end

assert('TrueClass#to_s', '15.2.5.3.3') do
  assert_equal 'true', true.to_s
end

assert('TrueClass#|', '15.2.5.3.4') do
  assert_true true.|(true)
  assert_true true.|(false)
end
##
# TypeError ISO Test

assert('TypeError', '15.2.29') do
  assert_equal Class, TypeError.class
end
# Test of the \u notation

assert('bare \u notation test') do
  # Mininum and maximum one byte characters
  assert_equal("\u0000", "\x00")
  assert_equal("\u007F", "\x7F")

  # Mininum and maximum two byte characters
  assert_equal("\u0080", "\xC2\x80")
  assert_equal("\u07FF", "\xDF\xBF")

  # Mininum and maximum three byte characters
  assert_equal("\u0800", "\xE0\xA0\x80")
  assert_equal("\uFFFF", "\xEF\xBF\xBF")

  # Four byte characters require the \U notation
end

assert('braced \u notation test') do
  # Mininum and maximum one byte characters
  assert_equal("\u{0000}", "\x00")
  assert_equal("\u{007F}", "\x7F")

  # Mininum and maximum two byte characters
  assert_equal("\u{0080}", "\xC2\x80")
  assert_equal("\u{07FF}", "\xDF\xBF")

  # Mininum and maximum three byte characters
  assert_equal("\u{0800}", "\xE0\xA0\x80")
  assert_equal("\u{FFFF}", "\xEF\xBF\xBF")

  # Mininum and maximum four byte characters
  assert_equal("\u{10000}",  "\xF0\x90\x80\x80")
  assert_equal("\u{10FFFF}", "\xF4\x8F\xBF\xBF")
end

assert('Kernel.loop', '15.3.1.2.8') do
  i = 0

  Kernel.loop do
    i += 1
    break if i == 100
  end

  assert_equal 100, i
end

assert('Kernel#loop', '15.3.1.3.29') do
  i = 0

  loop do
    i += 1
    break if i == 100
  end

  assert_equal i, 100
end

assert('Kernel.iterator?', '15.3.1.2.5') do
  assert_false Kernel.iterator?
end

assert('Hash#dup') do
  a = { 'a' => 1 }
  b = a.dup
  a['a'] = 2
  assert_equal({'a' => 1}, b)
end

assert('Exception#backtrace') do
  assert_nothing_raised do
    begin
      raise "get backtrace"
    rescue => e
      e.backtrace
    end
  end
end

assert('Issue 1467') do
  module M1
    def initialize()
      super()
    end
  end

  class C1
    include M1
     def initialize()
       super()
     end
  end

  class C2
    include M1
  end

  C1.new
  C2.new
end

assert('Exception 19') do
  class Class4Exception19
    def a
      r = @e = false
      begin
        b
      rescue TypeError
        r = self.z
      end
      [ r, @e ]
    end

    def b
      begin
        1 * "b"
      ensure
        @e = self.z
      end
    end

    def z
      true
    end
  end
  assert_equal [true, true], Class4Exception19.new.a
end

assert('Raise in ensure') do
  assert_raise(ArgumentError) do
    begin
      raise "" # RuntimeError
    ensure
      raise ArgumentError
    end
  end
end

report
