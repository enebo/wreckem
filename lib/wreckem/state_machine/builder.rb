module Wreckem
  class StateMachineBuilder
    include Wreckem::StateMachineComponents
    def self.build(machine_def)
      components = []
      is_machine = false
      start = name = nil
      machine_def.each do |c|
        case c
        when Machine then
          is_machine = true
        when Name then
          name = c
        when StateDestinationRef then
          start = c
        else
          components << c
        end
      end
      
      raise ArgumentError.new "Not a state machine defintiion #{machine_def.as_string}" unless is_machine
      raise ArgumentError.new "Improper state machine definition: missing name or start state" if !name || !start

      start_state = build_state(start.to_entity)

      Wreckem::StateMachine.new(name.value, start_state, name.id).tap do |sm|
        sm.components.concat components
      end
    end

    def self.build_state(state)
      is_goal = is_state = false
      name = nil
      transitions = []
      components = []
      state.each do |c|
        case c
        when StateState then
          is_state = true
        when StateTransitionRef then
          transitions << build_transition(c.to_entity)
        when Name then
          name = c
        when StateGoal
          is_goal = true
        else
          components << c
        end
      end

      raise ArgumentError.new "Not a state entity" unless is_state

      Wreckem::State.new(name.value, transitions, is_goal, name.id).tap do |s|
        s.components.concat components
      end
    end

    def self.build_transition(transition)
      is_transition = false
      components = []
      name = expression = destination = nil
      transition.each do |c|
        case c
        when StateTransition then
          is_transition = true
        when Name then
          name = c
        when StateExpression then
          expression = c.value
        when StateDestinationRef then
          destination = c.to_entity
        else
          components << c
        end
      end

      raise ArgumentError.new "Not a state transition" unless is_transition

      Wreckem::Transition.generate(name.value, destination, expression, 
                                   name.id).tap do |t|
        t.components.concat components
      end
    end
  end
end
