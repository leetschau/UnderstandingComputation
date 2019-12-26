class Number < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "《#{self}》"
  end

  def to_ruby
    "-> e { #{value.inspect} }"
    # A Ruby lambda string, where "e" is the parameter of
    # the lambda (but not used in the body).
    # And `e` is a hash map corresponding to "environment" in operational semantics
  end
end

class Boolean < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "《#{self}》"
  end

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
puts "----------"

class Assign < Struct.new(:name, :expression)
  def to_s
    "#{name} := #{expression}"
  end

  def inspect
    "《#{self}》"
  end
  def to_ruby
    "-> e { e.merge({ #{name.inspect} => (#{expression.to_ruby}).call(e) }) }"
  end
end

statement = Assign.new(:y, Add.new(Variable.new(:x), Number.new(1)))
p statement
p statement.to_ruby
proc5 = eval(statement.to_ruby)
p proc5.call({x: 3})
puts "----------"

class DoNothing
  def to_s
    "do-nothing"
  end

  def inspect
    "《#{self}》"
  end

  def to_ruby
    "-> e { e }"
  end
end

class If < Struct.new(:condition, :consequence, :alternative)
  def to_s
    "if #{condition} then #{consequence} else #{alternative}"
  end

  def inspect
    "《#{self}》"
  end

  def to_ruby
    "-> e { if (#{condition.to_ruby}).call(e)" +
        " then (#{consequence.to_ruby}).call(e)" +
        " else (#{alternative.to_ruby}).call(e)" +
        " end }"
  end
end

class Sequence < Struct.new(:first, :second)
  def to_s
    "Seq: #{first} and #{second}"
  end

  def inspect
    "《#{self}》"
  end

  def to_ruby
    "-> e { (#{second.to_ruby}).call((#{first.to_ruby}).call(e)) }"
  end
end

class While < Struct.new(:condition, :body)
  def to_s
    "while #{condition} { #{body} }"
  end

  def inspect
    "《#{self}》"
  end

  def to_ruby
    "-> e {" +
      " while (#{condition.to_ruby}).call(e); e = (#{body.to_ruby}).call(e); end;" +
      " e" +
      " }"
  end
end

statement = While.new(
  LessThan.new(Variable.new(:x), Number.new(5)),
  Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))
)

p statement
p statement.to_ruby
proc6 = eval(statement.to_ruby)
p proc6.call({x:1})
