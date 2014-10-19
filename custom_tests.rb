GC.disable

#include 'mruby/test/assert.rb'

assert('break between interpreter and compiler (eval does not carry break info further)') do
  $pr2 = proc do
    break 5
  end

  $pr = proc do
    (1..2).map do |j|
      eval("$pr2.call")
    end
  end

  v = (1..2).map do |i|
    break $pr.call
  end

  assert_equal(v, 5)
end
