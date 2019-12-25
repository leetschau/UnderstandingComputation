require 'pry'

class Number < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "《#{self}》"
  end

  def evaluate(environment)
    self
  end
end

class Boolean < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "《#{self}》"
  end

  def evaluate(environment)
    self
  end
end

class Variable < Struct.new(:name)
  def to_s
    "#{name}"
  end

  def inspect
    "《#{self}》"
  end

  def evaluate(environment)
    environment[name]
  end
end

class Add < Struct.new(:left, :right)
  def to_s
    "#{left} + #{right}"
  end

  def inspect
    "《#{self}》"
  end

  def evaluate(environment)
    Number.new(left.evaluate(environment).value + right.evaluate(environment).value)
  end
end

class Multiply < Struct.new(:left, :right)
  def to_s
    "#{left} * #{right}"
  end

  def inspect
    "《#{self}》"
  end

  def evaluate(environment)
    Number.new(left.evaluate(environment).value * right.evaluate(environment).value)
  end
end

class LessThan < Struct.new(:left, :right)
  def to_s
    "#{left} < #{right}"
  end

  def inspect
    "《#{self}》"
  end

  def evaluate(environment)
    Boolean.new(left.evaluate(environment).value < right.evaluate(environment).value)
  end
end

p Number.new(23).evaluate({})

p Variable.new(:x).evaluate({x: Number.new(33)})

p LessThan.new(
  Add.new(Variable.new(:x), Number.new(2)),
  Variable.new(:y)
).evaluate({x: Number.new(4), y: Number.new(5)})

puts "-------"

class Assign < Struct.new(:name, :expression)
  def to_s
    "#{name} := #{expression}"
  end

  def inspect
    "《#{self}》"
  end

  def evaluate(environment)
    environment.merge({ name => expression.evaluate(environment) })
  end
end

class DoNothing
  def to_s
    "do-nothing"
  end

  def inspect
    "《#{self}》"
  end

  def evaluate(environment)
    environment
  end
end

class If < Struct.new(:condition, :consequence, :alternative)
  def to_s
    "if #{condition} then #{consequence} else #{alternative}"
  end

  def inspect
    "《#{self}》"
  end

  def evaluate(environment)
    case condition.evaluate(environment)
    when Boolean.new(true)
      consequence.evaluate(environment)
    when Boolean.new(false)
      alternative.evaluate(environment)
    end
  end
end

class Sequence < Struct.new(:first, :second)
  def to_s
    "Seq: #{first} and #{second}"
  end

  def inspect
    "《#{self}》"
  end

  def evaluate(environment)
    second.evaluate(first.evaluate(environment))
  end
end

statement = Sequence.new(
  Assign.new(:x, Add.new(Number.new(3), Number.new(5))),
  Assign.new(:y, Add.new(Variable.new(:x), Number.new(7))))

p statement
p statement.evaluate({})
puts "-------"

class While < Struct.new(:condition, :body)
  def evaluate(environment)
    #puts "start evaluation. Env: #{environment}"
    binding.pry
    case condition.evaluate(environment)
    when Boolean.new(true)
      #puts "condition true, re-evaluate"
      evaluate(body.evaluate(environment))
    when Boolean.new(false)
      environment
    end
  end
end

statement = While.new(
  LessThan.new(Variable.new(:x), Number.new(5)),
  Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3))))
p statement
p statement.evaluate({ x: Number.new(1) })

# 总体来看，基于递归的大步语义比小步语义实现更简洁，
# 代价是更依赖于堆栈，如果宿主机性能不好，解释器的性能也会变差。

