require 'pry'

class Number < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "《#{self}》"
  end

  def reducible?
    false
  end
end

class Add < Struct.new(:left, :right)
  def to_s
    "#{left} + #{right}"
  end

  def inspect
    "《#{self}》"
  end

  def reducible?
    true
  end

  def reduce
    if left.reducible?
      Add.new(left.reduce, right)
    elsif right.reducible?
      Add.new(left, right.reduce)
    else
      Number.new(left.value + right.value)
    end
  end
end

class Multiply < Struct.new(:left, :right)
  def to_s
    "#{left} * #{right}"
  end

  def inspect
    "《#{self}》"
  end

  def reducible?
    true
  end

  def reduce
    if left.reducible?
      Add.new(left.reduce, right)
    elsif right.reducible?
      Add.new(left, right.reduce)
    else
      Number.new(left.value * right.value)
    end
  end
end

exp1 = Multiply.new(
         Number.new(5),
         Multiply.new(
           Add.new(
             Number.new(3),
             Number.new(4)),
           Number.new(23)))

#puts exp1

exp2 = Add.new(Multiply.new(Number.new(1), Number.new(3)),
               Multiply.new(Number.new(5), Number.new(8)))

#puts exp2

class Machine
  def initialize(expression)
    @expr = expression
  end

  def step
    @expr = @expr.reduce
  end

  def run
    while @expr.reducible?
      puts @expr
      step
    end
    puts @expr
  end
end

class Machine2 < Struct.new(:expression)
  def step
    print "Step     : expression id:", expression.object_id, "\n"
    print "Step: self.expression id:", self.expression.object_id, "\n"
    print "Step:     @expression id:", @expression.object_id, "\n"
    print "Step:            self.id:", self.object_id, "\n"
    puts "------------"
    self.expression = self.expression.reduce
    print "Step: self.expression id:", self.expression.object_id, "\n"
  end

  def run
    print "Run      : expression id:", expression.object_id, "\n"
    print "Run : self.expression id:", self.expression.object_id, "\n"
    while self.expression.reducible?
      print "RUN/while: expression id:", self.expression.object_id, "\n"
      step
    end
    puts "final exprssion in run:", expression
  end
end

# 上述运行结果表明：通过 Struct.new(:attr1, :attr2) 给属性赋的值，
# 只能通过 self.attr1, self.attr2 访问（也可以省略 self）
# 不能用 @ 访问

#Machine.new(
  #Add.new(Multiply.new(Number.new(1), Number.new(2)),
          #Multiply.new(Number.new(3), Number.new(4)))).run

Machine2.new(
  Add.new(Multiply.new(Number.new(1), Number.new(2)),
          Multiply.new(Number.new(3), Number.new(4)))).run

