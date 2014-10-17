GC.disable

#include 'mruby/mrblib/*.rb'
#include 'mruby/test/assert.rb'

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
