require 'wreckem/state_machine/components'
require 'wreckem/state_machine/state'
require 'wreckem/state_machine/transition'
require 'wreckem/state_machine/builder'

module Wreckem
  class StateMachine
    attr_reader :name, :start_state, :id
    attr_accessor :components

    ##
    # Create a new state machine.  If id is provided it is because
    # this state machine has been reified from an existing definition
    # of components.   The id is merely a convenience for storing
    # state associated with the execution of this this machine.
    def initialize(name, start_state, id=nil)
      @name, @start_state, @id = name, start_state, id
      @components = []
    end

    def execute(a, b)
      @start_state.execute(a, b)
    end

    def self.build(machine_definition_entity)
      Wreckem::StateMachineBuilder.build(machine_definition_entity)
    end
  end
end
