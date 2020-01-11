class FARule < Struct.new(:state, :character, :next_state)
  def applies_to?(state, character)
    self.state == state && self.character == character
  end

  def follow
    next_state
  end

  def inspect
    "#<FARule #{state.inspect} --#{character}--> #{next_state.inspect}>"
  end
end

class DFARulebook < Struct.new(:rules)
  def next_state(state, character)
    rule_for(state, character).follow
  end

  def rule_for(state, character)
    rules.detect { |rule| rule.applies_to?(state, character) }
  end
end

rulebook = DFARulebook.new([
  FARule.new(1, 'a', 2), FARule.new(1, 'b', 1),
  FARule.new(2, 'a', 2), FARule.new(2, 'b', 3),
  FARule.new(3, 'a', 3), FARule.new(3, 'b', 3)
])
# rulebook 里的规则是没有顺序的

p rulebook.next_state(1, 'a')
p rulebook.next_state(1, 'b')
p rulebook.next_state(2, 'b')
puts "================="

# 这里 DFARulebook 的属性 :rules 是一个 Enumerable，
# 其 detect 方法类似于 filter_first，参数是一个 proc，返回符合要求的第一个元素，
# 例如 [1,2,3].detect {|x| x -1 > 0} 返回 2，详见 `? [1,2,3].detect`。

class DFA < Struct.new(:current_state, :accept_states, :rulebook)
  def accepting?
    accept_states.include?(current_state)
  end
end

# rulebook 定义了状态机的连通图，accept_states 则定义了其中哪些状态是“可接受状态”，
# 也就是双圆圈标记的状态

p DFA.new(1, [1, 3], rulebook).accepting?
p DFA.new(1, [3], rulebook).accepting?
puts "================="

class DFA
  def read_charater(character)
    self.current_state = rulebook.next_state(current_state, character)
  end
end

dfa = DFA.new(1, [3], rulebook)
p dfa.accepting?
dfa.read_charater('b')
p dfa.accepting?
3.times do
  dfa.read_charater('a')
end
p dfa.accepting?
dfa.read_charater('b')
p dfa.accepting?
puts "================="

class DFA
  def read_string(string)
    string.chars.each do |character|
      read_charater(character)
    end
  end
end

dfa = DFA.new(1, [3], rulebook)
p dfa.accepting?
dfa.read_string('baaab')
p dfa.accepting?
puts "================="

class DFADesign < Struct.new(:start_state, :accept_states, :rulebook)
  def to_dfa
    DFA.new(start_state, accept_states, rulebook)
  end

  def accepts?(string)
    to_dfa.tap { |dfa| dfa.read_string(string) }.accepting?
  end
end

dfa_desgin = DFADesign.new(1, [3], rulebook)
p dfa_desgin.accepts?('a')
p dfa_desgin.accepts?('baa')
p dfa_desgin.accepts?('baba')
puts "------------"

class DFADesign2 < Struct.new(:start_state, :accept_states, :rulebook)
  def initialize
    @dfa = DFA.new(start_state, accept_states, rulebook)
  end

  def accepts?(string)
    @dfa.read_string(string)
    dfa.accepting?
  end
end

dfa_desgin2 = DFADesign.new(1, [3], rulebook)
p dfa_desgin2.accepts?('a')
p dfa_desgin2.accepts?('baa')
p dfa_desgin2.accepts?('baba')
p dfa_desgin2.accepts?('abba')
p dfa_desgin2.accepts?('bbba')
puts "===================="

# 一个对象用 `tap` 带的代码块处理完后返回自己，
# 从而实现在方法调用链条里嵌入任意代码，例如：
# 原始的数据处理链条：(1..10).to_a.select {|x| x%2 == 0}.map {|x| x*x}
# 每次变换后用 `tap` 添加调试代码：
# (1..10).tap { |x| puts "original: #{x.inspect}" }.to_a.
#    tap    { |x| puts "array: #{x.inspect}" }.
#    select { |x| x%2 == 0 }.
#    tap    { |x| puts "evens: #{x.inspect}" }.
#    map    { |x| x*x }.
#    tap    { |x| puts "squares: #{x.inspect}" }
#
# `tap` 的实现如下：
# class Object
#   def tap
#     yield self
#     self
#   end
# end
#
# DFADesign2.accepts? 不用 `tap` 实现了 DFADesign.accepts? 方法，
# 并用初始化函数优化了类设计
