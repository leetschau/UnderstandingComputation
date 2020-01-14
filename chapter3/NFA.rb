require 'set'
require './DFA'

class NFARulebook < Struct.new(:rules)
  def next_states(states, character)
    states.flat_map { |state| follow_rules_for(state, character) }.to_set
  end

  def follow_rules_for(state, character)
    rules_for(state, character).map(&:follow)
  end

  def rules_for(state, character)
    rules.select { |rule| rule.applies_to?(state, character) }
  end
end

rulebook = NFARulebook.new([
  FARule.new(1, 'a', 1), FARule.new(1, 'b', 1), FARule.new(1, 'b', 2),
  FARule.new(2, 'a', 3), FARule.new(2, 'b', 3),
  FARule.new(3, 'a', 4), FARule.new(3, 'b', 4)])

p rulebook.next_states(Set[1], 'b')     # 当前状态为 1 时，输入 'b'
p rulebook.next_states(Set[1, 2], 'a')  # 当前状态包含 1, 2 时，输入 'a'
p rulebook.next_states(Set[1, 3], 'b')
puts "================="

class NFA < Struct.new(:current_states, :accept_states, :rulebook)
  def accepting?
    (current_states & accept_states).any?  # `&` 表示做交集
  end

  def read_character(character)
    self.current_states = rulebook.next_states(current_states, character)
  end

  def read_string(string)
    string.chars.each do |character|
      read_character(character)
    end
  end
end

nfa = NFA.new(Set[1], [4], rulebook)
p nfa.accepting?
nfa.read_character('b')
p nfa.accepting?
nfa.read_character('a')
p nfa.accepting?
nfa.read_character('b')
p nfa.accepting?
puts "------------"

nfa = NFA.new(Set[1], [4], rulebook)
p nfa.accepting?
nfa.read_string('bbbbbb')
p nfa.accepting?
puts "================="

class NFADesign < Struct.new(:start_state, :accept_states, :rulebook)
  def accepts?(string)
    to_nfa.tap { |nfa| nfa.read_string(string) }.accepting?
  end

  def to_nfa
    NFA.new(Set[start_state], accept_states, rulebook)
  end
end

nfa_design = NFADesign.new(1, [4], rulebook)
p nfa_design.accepts?('bab')
nfa_design = NFADesign.new(1, [4], rulebook)
p nfa_design.accepts?('bbbbb')
nfa_design = NFADesign.new(1, [4], rulebook)
p nfa_design.accepts?('bbabb')

puts "====== Free Moves ==========="

rulebook = NFARulebook.new([
  FARule.new(1, nil, 2), FARule.new(1, nil, 4),
  FARule.new(2, 'a', 3),
  FARule.new(3, 'a', 2),
  FARule.new(4, 'a', 5),
  FARule.new(5, 'a', 6),
  FARule.new(6, 'a', 4),
])
p rulebook.next_states(Set[1], nil)

class NFARulebook
  def follow_free_moves(states)
    more_states = next_states(states, nil)

    if more_states.subset?(states)
      states
    else
      follow_free_moves(states + more_states)
    end
  end
end

p rulebook.follow_free_moves(Set[1])
puts "------------"

class NFA
  def current_states   # 覆盖了 Struct 提供的访问属性的方法
    rulebook.follow_free_moves(super)
  end
end

nfa_design = NFADesign.new(1, [2, 4], rulebook)
p nfa_design.accepts?('aa')
p nfa_design.accepts?('aaa')
p nfa_design.accepts?('aaaaa')
p nfa_design.accepts?('aaaaaa')
