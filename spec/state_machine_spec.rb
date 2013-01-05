require 'wreckem/state_machine'
require 'wreckem/state_machine/generator'

describe Wreckem::StateMachine do
  before { @em = Wreckem::EntityManager.new }
  after { @em.destroy }

  def simple_machine
    positive = Wreckem::State.new "Positive", [], true
    positive_transition = Wreckem::Transition.generate("Positive", positive, "a > b")
    negative = Wreckem::State.new "Negative", [], true
    negative_transition = Wreckem::Transition.generate("Negative", negative, "a < b")
    equal = Wreckem::State.new "Equal", [], true
    equal_transition = Wreckem::Transition.generate("Equal", equal, "a == b")
    transitions = [positive_transition, negative_transition, equal_transition]
    start = Wreckem::State.new "Start", transitions, false
    Wreckem::StateMachine.new("Positive value", start)
  end

  it "should generate state_machine entities" do
    machine_entity = Wreckem::StateMachineGenerator.generate(simple_machine)
    machine_entity.one(Wreckem::StateMachineComponents::Name).value.should == "Positive value"
  end

  it "should execute a simple state machine" do
    machine = simple_machine
    machine.execute(1, 2)
  end
end
