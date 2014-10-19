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

# because there is no reflection on local variables in compiled code yet (but it is possible)
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

# because mruby tries to read it from iseq, for cfunc is hardcoded to -1
# we need to override Proc#arity and read it some other way (perhaps use hash or try to store it in struct RProc somewhere)
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

# these only do not work because Mrbtest is defined in driver.c specifically for testing
assert('Integer#+', '15.2.8.3.1') do
  a = 1+1
  b = 1+1.0

  assert_equal 2, a
  assert_equal 2.0, b

  assert_raise(TypeError){ 0+nil }
  assert_raise(TypeError){ 1+nil }

  c = Mrbtest::FIXNUM_MAX + 1
  d = Mrbtest::FIXNUM_MAX.__send__(:+, 1)
  e = Mrbtest::FIXNUM_MAX + 1.0
  assert_equal Float, c.class
  assert_equal Float, d.class
  assert_float e, c
  assert_float e, d
end

assert('Integer#-', '15.2.8.3.2') do
  a = 2-1
  b = 2-1.0

  assert_equal 1, a
  assert_equal 1.0, b

  c = Mrbtest::FIXNUM_MIN - 1
  d = Mrbtest::FIXNUM_MIN.__send__(:-, 1)
  e = Mrbtest::FIXNUM_MIN - 1.0
  assert_equal Float, c.class
  assert_equal Float, d.class
  assert_float e, c
  assert_float e, d
end

assert('Integer#*', '15.2.8.3.3') do
  a = 1*1
  b = 1*1.0

  assert_equal 1, a
  assert_equal 1.0, b

  assert_raise(TypeError){ 0*nil }
  assert_raise(TypeError){ 1*nil }

  c = Mrbtest::FIXNUM_MAX * 2
  d = Mrbtest::FIXNUM_MAX.__send__(:*, 2)
  e = Mrbtest::FIXNUM_MAX * 2.0
  assert_equal Float, c.class
  assert_equal Float, d.class
  assert_float e, c
  assert_float e, d
end
