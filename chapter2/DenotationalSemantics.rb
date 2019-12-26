class Number < Struct.new(:value)
  def to_ruby
    "-> e { #{value.inspect} }"
    # A Ruby lambda string, where "e" is the parameter of
    # the lambda (but not used in the body).
    # And `e` is a hash map corresponding to "environment" in operational semantics
  end
end

class Boolean < Struct.new(:value)
  def to_ruby
    "-> e { #{value.inspect} }"
  end
end

proc1 = eval(Number.new(5).to_ruby)
puts proc1.call({})
puts proc1[{}]
puts eval(Boolean.new(false).to_ruby).call({})
puts "-------"

class Variable < Struct.new(:name)
  def to_s
    "#{name}"
  end

  def inspect
    "《#{self}》"
  end

  def to_ruby
    "-> e { e[#{name.inspect}] }"
  end
end

expr = Variable.new(:x)
puts expr
puts expr.to_ruby
proc2 = eval(expr.to_ruby)
p proc2[{ x: 8 }]
puts "-------"

class Add < Struct.new(:left, :right)
  def to_s
    "#{left} + #{right}"
  end

  def inspect
    "《#{self}》"
  end

  def to_ruby
    "-> e { (#{left.to_ruby}).call(e) + (#{right.to_ruby}).call(e) }"
  end
end

class Multiply < Struct.new(:left, :right)
  def to_s
    "#{left} * #{right}"
  end

  def inspect
    "《#{self}》"
  end

  def to_ruby
    "-> e { (#{left.to_ruby}).call(e) * (#{right.to_ruby}).call(e) }"
  end
end

class LessThan < Struct.new(:left, :right)
  def to_s
    "#{left} < #{right}"
  end

  def inspect
    "《#{self}》"
  end

  def to_ruby
    "-> e { (#{left.to_ruby}).call(e) < (#{right.to_ruby}).call(e) }"
  end
end

proc3 = Add.new(Variable.new(:x), Number.new(3)).to_ruby
proc4 = LessThan.new(Add.new(Variable.new(:x), Number.new(4)), Number.new(7)).to_ruby
env = { x: 1 }

p proc3
p proc4
p eval(proc3).call(env)
p eval(proc4).call(env)


