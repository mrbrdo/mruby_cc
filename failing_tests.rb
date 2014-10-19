GC.disable

#include 'mruby/test/assert.rb'

assert('GC.enable') do
  assert_false GC.disable
  assert_true GC.enable
  assert_false GC.enable
end

assert('GC.disable') do
  begin
    assert_false GC.disable
    assert_true GC.disable
  ensure
    GC.enable
  end
end

assert('GC.interval_ratio=') do
  origin = GC.interval_ratio
  begin
    assert_equal 150, (GC.interval_ratio = 150)
  ensure
    GC.interval_ratio = origin
  end
end

assert('GC.step_ratio=') do
  origin = GC.step_ratio
  begin
    assert_equal 150, (GC.step_ratio = 150)
  ensure
    GC.step_ratio = origin
  end
end

assert('GC.generational_mode=') do
  origin = GC.generational_mode
  begin
    assert_false (GC.generational_mode = false)
    assert_true (GC.generational_mode = true)
    assert_true (GC.generational_mode = true)
  ensure
    GC.generational_mode = origin
  end
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

assert('Kernel.local_variables', '15.3.1.2.7') do
  a, b = 0, 1
  a += b

  vars = Kernel.local_variables.sort
  assert_equal [:a, :b, :vars], vars

  Proc.new {
    c = 2
    vars = Kernel.local_variables.sort
    assert_equal [:a, :b, :c, :vars], vars
  }.call
end

assert('Proc#arity', '15.2.17.4.2') do
  a = Proc.new {|x, y|}.arity
  b = Proc.new {|x, *y, z|}.arity
  c = Proc.new {|x=0, y|}.arity
  d = Proc.new {|(x, y), z=0|}.arity

  assert_equal  2, a
  assert_equal(-3, b)
  assert_equal  1, c
  assert_equal  1, d
end

assert('__FILE__') do
  file = __FILE__
  assert_true 'test/t/syntax.rb' == file || 'test\t\syntax.rb' == file
end

assert('__LINE__') do
  assert_equal 7, __LINE__
end
