
class C1
  def x
    puts "ok"
  end
end

class C2 < C1
  def x
    puts "1"
    super
    puts "2"
  end
end

C2.new.x
