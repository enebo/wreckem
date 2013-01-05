require 'wreckem/component'

module Wreckem
  module StateMachineComponents
    Machine = Wreckem::Component.define
    Goal = Wreckem::Component.define
    Name = Wreckem::Component.define_as_string
    StateDestinationRef = Wreckem::Component.define_as_ref
    StateState = Wreckem::Component.define
    StateTransition = Wreckem::Component.define
    StateTransitionRef = Wreckem::Component.define_as_ref
    StateExpression = Wreckem::Component.define_as_string
  end
end
