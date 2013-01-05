require 'wreckem/state_machine/components'
require 'wreckem/state_machine/state'
require 'wreckem/state_machine/transition'

module Wreckem
  class StateMachine
    def initialize(name, start_state)
      @name, @start_state = name, start_state
    end

    def execute(a, b)
      state = @start_state
      while state = state.execute(a, b)
      end
    end

    def self.build(machine_def)
      unless machine_def.is?(StateMachine)
        raise ArgumentError.new "Not a state machine defintiion #{machine_def.as_string}" 
      end

      name = machine_def.one(Name)
      start = machine_def.one(StateDestinationRef)
      start_state = build_state(start).to_entity

      new(name, start_state)
    end

    def self.build_state(state)
      raise ArgumentError.new "Not a state entity" if !state.is? StateState

      transitions = state.many(StateTransitionRef).inject([]) do |list, str|
        list << build_transition(str.entity)
      end

      Wreckem::State.new(state.one(Name), transitions, state.is?(Goal))
    end

    def self.build_transition(transition)
      unless state.is? StateTransition
        raise ArgumentError.new "Not a state transition" 
      end

      name = transition.one(Name).value
      expression = transition.one(StateExpression).value
      destination = transtion.one(StateDestinationRef).to_entity

      cls = eval(<<-EOS)
Class.new(Wreckem::Transition) do
  def initialize(name, destination)
    super(name, destination)
  end

  def fires?
    #{expression}
  end
end
EOS
      cls.new(name, destination)
    end
  end
end
