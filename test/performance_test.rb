GC.disable
N_EXAMPLE_ITERATIONS = 1000
N_SUITE_ITERATIONS = 1

$example_durations = Hash.new

#include '../mruby/test/assert.rb'
self.class.alias_method :assert_orig, :assert
def assert(str = 'Assertion failed', iso = '', &block)
  i = 0
  start_at = Time.now
  assert_orig(str, iso, &block) while (i += 1) <= N_EXAMPLE_ITERATIONS
  duration = Time.now - start_at

  str += ", #{iso}" unless iso.empty?
  $example_durations[str] = duration
end

_suite_iterations = 0
_suite_start_at = Time.now
while (_suite_iterations += 1) <= N_SUITE_ITERATIONS
#include '../passing_tests.rb'
end
$example_durations['ALL'] = Time.now - _suite_start_at

puts "Durations:"
p $example_durations
