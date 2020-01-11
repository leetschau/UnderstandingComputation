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

