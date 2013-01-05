require 'wreckem/state_machine/components'
require 'wreckem/state_machine/state'
require 'wreckem/state_machine/transition'

module Wreckem
  class StateMachine
    attr_reader :name, :start_state

    def initialize(name, start_state)
      @name, @start_state = name, start_state
    end

    def execute(a, b)
      state = @start_state
      while state = state.execute(a, b)
      end
    end

    def self.build(machine_definition_entity)
      Wreckem::StateMachineBuilder.build(machine_definition_entity)
    end
  end
end
