require 'wreckem/state_machine'

module Wreckem
  class StateMachineGenerator
    include Wreckem::StateMachineComponents
    def initialize
      @states_visited = {}
      @transitions_visited = {}
    end

    def generate(state_machine)
      Entity.is! do |e|
        e.is Machine
        e.has Name.new(state_machine.name)
        state = generate_state(state_machine.start_state)
        e.has StateDestinationRef.new state
      end
    end

    def generate_state(state)
      new_state = @states_visited[state]
      return if new_state # Only need to generate once

      @states_visited[state] = Entity.is! do |e|
        e.is StateState
        e.has Name.new(state.name)
        e.is Goal if state.goal?
        state.transitions.each do |transition|
          trans = generate_transition(transition)
          e.has StateTransitionRef.new trans
        end
      end
    end

    def generate_transition(transition)
      new_transition = @transitions_visited[transition]
      return if new_transition # Only need to generate once

      @transitions_visited[transition] = Entity.is! do |e|
        e.is StateTransition
        e.has Name.new(transition.name)
        e.has StateExpression.new(transition.expression_as_string)
        dest_state = generate_state(transition.destination)
        e.has StateDestinationRef.new dest_state
      end
    end

    def self.generate(state_machine)
      new.generate(state_machine)
    end
  end
end
