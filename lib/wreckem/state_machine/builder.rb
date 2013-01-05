module Wreckem
  class StateMachineBuilder
    include Wreckem::StateMachineComponents
    def self.build(machine_def)
      unless machine_def.is?(Machine)
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

      Wreckem::State.new state.one(Name), transitions, state.is?(StateGoal)
    end

    def self.build_transition(transition)
      unless state.is? StateTransition
        raise ArgumentError.new "Not a state transition" 
      end

      name = transition.one(Name).value
      destination = transtion.one(StateDestinationRef).to_entity
      expression = transition.one(StateExpression).value

      Wreck::Transition.generate(name, destination, expression)
    end
  end
end
