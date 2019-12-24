require './SmallStepLib'

exp1 = Multiply.new(
         Number.new(5),
         Multiply.new(
           Add.new(
             Number.new(3),
             Number.new(4)),
           Number.new(23)))

puts exp1
puts "------------"

exp2 = Add.new(Multiply.new(Number.new(1), Number.new(3)),
               Multiply.new(Number.new(5), Number.new(8)))

puts exp2
puts "------------"

Machine.new(
  Add.new(Multiply.new(Number.new(1), Number.new(2)),
          Multiply.new(Number.new(3), Number.new(4)))).run
puts "------------"

Machine.new(
  LessThan.new(Number.new(5), Add.new(Number.new(2), Number.new(1)))).run
puts "------------"

