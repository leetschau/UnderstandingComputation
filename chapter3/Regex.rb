require './NFA'
puts "=== 3.3.1 语法 ==="
module Pattern
  def bracket(outer_precedence)
    if precedence < outer_precedence
      '(' + to_s + ')'
    else
      to_s
    end
  end

  def inspect
    "/#{self}/"
  end
end

class Empty
  include Pattern

  def to_s
    ""
  end

  def precedence
    3
  end
end

class Literal < Struct.new(:character)
  include Pattern

  def to_s
    character
  end

  def precedence
    3
  end
end

class Concatenate < Struct.new(:first, :second)
  include Pattern

  def to_s
    [first, second].map { |pattern| pattern.bracket(precedence) }.join
  end

  def precedence
    1
  end
end

class Choose < Struct.new(:first, :second)
  include Pattern

  def to_s
    [first, second].map { |pattern| pattern.bracket(precedence) }.join('|')
  end

  def precedence
    0
  end
end

class Repeat < Struct.new(:pattern)
  include Pattern

  def to_s
    pattern.bracket(precedence) + '*'
  end

  def precedence
    2
  end
end

pattern = Repeat.new(
  Choose.new(
    Concatenate.new(
      Literal.new('a'),
      Literal.new('b')),
    Literal.new('a')))

p pattern

puts "=== 3.3.2 语义 ==="

puts '--- Basic Definition ---'

class Empty
  def to_nfa_design
    start_state = Object.new
    accept_states = [start_state]
    rulebook = NFARulebook.new([])
    NFADesign.new(start_state, accept_states, rulebook)
  end
end

class Literal
  def to_nfa_design
    start_state = Object.new
    accept_state = Object.new
    rule = FARule.new(start_state, character, accept_state)
    rulebook = NFARulebook.new([rule])
    NFADesign.new(start_state, [accept_state], rulebook)
  end
end

nfa_design = Empty.new.to_nfa_design
p nfa_design.accepts?('')
p nfa_design.accepts?('a')
puts '-----------'

nfa_design = Literal.new('a').to_nfa_design
p nfa_design.accepts?('')
p nfa_design.accepts?('a')
p nfa_design.accepts?('b')
# 这里 A.accepts?(B) 表示 B 字符串是否能够让 A 代表的 NFA 进入 accept 状态，
# 也就是是否能 match A 正则表达式

# module 也可以再次打开并添加/更新方法
module Pattern
  def matches?(string)
    to_nfa_design.accepts?(string)
  end
end

p Empty.new.matches?('a')
p Literal.new('a').matches?('a')

puts '--- NFA of `Concatenate` ---'

class Concatenate
  def to_nfa_design
    first_nfa_design = first.to_nfa_design
    second_nfa_design = second.to_nfa_design

    start_state = first_nfa_design.start_state
    accept_states = second_nfa_design.accept_states
    rules = first_nfa_design.rulebook.rules + second_nfa_design.rulebook.rules
    extra_rules = first_nfa_design.accept_states.map { |state|
      FARule.new(state, nil, second_nfa_design.start_state)
    }
    rulebook = NFARulebook.new(rules + extra_rules)

    NFADesign.new(start_state, accept_states, rulebook)
  end
end

pattern = Concatenate.new(Literal.new('a'), Literal.new('b'))
p pattern
p pattern.matches?('a')
p pattern.matches?('ab')
p pattern.matches?('abc')

puts '--- complex concatenation pattern ---'

pattern = Concatenate.new(Literal.new('a'),
                          Concatenate.new(Literal.new('b'),
                                          Literal.new('c')))
p pattern
p pattern.matches?('a')
p pattern.matches?('ab')
p pattern.matches?('abc')

puts '--- NFA of `Choose` ---'

class Choose
  def to_nfa_design
    first_nfa_design = first.to_nfa_design
    second_nfa_design = second.to_nfa_design

    start_state = Object.new
    accept_states = first_nfa_design.accept_states +
                    second_nfa_design.accept_states
    rules = first_nfa_design.rulebook.rules + second_nfa_design.rulebook.rules
    extra_rules = [first_nfa_design, second_nfa_design].map {|nfa_design|
      FARule.new(start_state, nil, nfa_design.start_state)
    }
    rulebook = NFARulebook.new(rules + extra_rules)

    NFADesign.new(start_state, accept_states, rulebook)
  end
end

pattern = Choose.new(Literal.new('a'), Literal.new('b'))
p pattern
p pattern.matches?('a')
p pattern.matches?('b')
p pattern.matches?('c')

puts '--- NFA of `Repeat` ---'

class Repeat
  def to_nfa_design
    pattern_nfa_design = pattern.to_nfa_design
    start_state = Object.new
    accept_states = pattern_nfa_design.accept_states + [start_state]
    rules = pattern_nfa_design.rulebook.rules
    extra_rules = pattern_nfa_design.accept_states.map { |accept_state|
      FARule.new(accept_state, nil, pattern_nfa_design.start_state)
    } + [FARule.new(start_state, nil, pattern_nfa_design.start_state)]
    rulebook = NFARulebook.new(rules + extra_rules)

    NFADesign.new(start_state, accept_states, rulebook)
  end
end

pattern = Repeat.new(Literal.new('a'))
p pattern
p pattern.matches?('')
p pattern.matches?('a')
p pattern.matches?('aaaa')
p pattern.matches?('b')

puts '--- Combined NFA ---'

pattern = Repeat.new(Concatenate.new(Literal.new('a'),
                                     Choose.new(Empty.new,
                                                Literal.new('b'))))
p pattern # 0 或 多组 （a 或者 ab）
p pattern.matches?('')  # 0 组
p pattern.matches?('a')  # 1 组
p pattern.matches?('ab')  # 1 组
p pattern.matches?('aba')  # 2 组: ab, a
p pattern.matches?('abab')  # 2 组：ab, ab
p pattern.matches?('abaab')  # 3 组：ab, a, ab
p pattern.matches?('abba')  # ab 后无法匹配

puts "=== 3.3.3 解析 ==="

require 'treetop'
Treetop.load('pattern')
parse_tree = PatternParser.new.parse('(a(|b))*')
pattern = parse_tree.to_ast
p pattern.matches?('abaab')
p pattern.matches?('abba')
