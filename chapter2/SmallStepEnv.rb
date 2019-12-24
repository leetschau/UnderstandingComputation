require './SmallStepLib.rb'

class Variable < Struct.new(:name)
  def to_s
    name.to_s
  end

  def inspect
    "《#{self}》"
  end

  def reducible?
    true
  end

  def reduce(environment)
    environment[name]
  end
end

class Add
  def reduce(environment)
    if left.reducible?
      Add.new(left.reduce(environment), right)
    elsif right.reducible?
      Add.new(left, right.reduce(environment))
    else
      Number.new(left.value + right.value)
    end
  end
end

class Multiply
  def reduce(environment)
    if left.reducible?
      Add.new(left.reduce(environment), right)
    elsif right.reducible?
      Add.new(left, right.reduce(environment))
    else
      Number.new(left.value * right.value)
    end
  end
end

class LessThan
  def reduce
    if left.reducible?
      LessThan.new(left.reduce, right)
    elsif right.reducible?
      LessThan.new(left, right.reduce)
    else
      Boolean.new(left.value < right.value)
    end
  end
end

Object.send(:remove_const, :Machine)

class Machine < Struct.new(:expression, :environment)
  def step
    self.expression = expression.reduce(environment)
  end

  def run
    while expression.reducible?
      puts expression
      step
    end

    puts expression
  end
end

Machine.new(
  Add.new(Variable.new(:x), Variable.new(:y)),
  {x: Number.new(3), y: Number.new(4) }).run

class DoNothing
  def to_s
    'do-nothing'
  end

  def inspect
    "《#{self}》"
  end

  def ==(other_statement)
    other_statement.instance_of?(DoNothing)
  end

  def reducible?
    false
  end
end

class Assign < Struct.new(:name, :expression)
  def to_s
    "#{name} = #{expression}"
  end

  def inspect
    "《#{self}》"
  end

  def reducible?
    true
  end

  def reduce(environment)
    if expression.reducible?
      [Assign.new(name, expression.reduce(environment)), environment]
    else
      [DoNothing.new, environment.merge({ name => expression })]
    end
  end
end

statement = Assign.new(:x, Add.new(Variable.new(:x), Number.new(13)))
puts statement
puts statement.reducible?
environment = { x: Number.new(22) }

# 手工循环对语句求值
statement, environment = statement.reduce(environment)
puts statement, environment
puts statement.reducible?
statement, environment = statement.reduce(environment)
puts statement, environment
puts statement.reducible?
statement, environment = statement.reduce(environment)
puts statement, environment
puts statement.reducible?

