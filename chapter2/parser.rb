require 'pry'
require 'treetop'
require './DenotationalSemantics'

Treetop.load('simple')
parse_tree = SimpleParser.new.parse('while (x < 5){ x = x * 3 }')
# parse 的参数字符串的格式在 simple.treetop 的 `rule while` 下面一行定义
# 格式必须完全一致，包括空格
statement = parse_tree.to_ast
proc = eval(statement.to_ruby)
p proc.call({ x: 1 })

# treetop 作用是按照 simple.treetop 中定义的规则
# 将字符串 'while (x < 5) { x = x * 3 }' 转换为抽象语法树，
# 上面的 statement = parse_tree.to_ast 相当于下面的代码：
#
# statement = While.new(
#   LessThan.new(Variable.new(:x), Number.new(5)),
#   Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))
# )
