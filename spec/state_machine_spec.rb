require 'wreckem/state_machine'
require 'wreckem/state_machine/generator'

Quest = Wreckem::Component.define
QuestionText = Wreckem::Component.define_as_string

describe Wreckem::StateMachine do
  before { @em = Wreckem::EntityManager.new }
  after { @em.destroy }

  def simple_machine
    @positive = Wreckem::State.new "Positive", [], true
    positive_transition = Wreckem::Transition.generate("Positive", @positive, "a > b")
    @negative = Wreckem::State.new "Negative", [], true
    negative_transition = Wreckem::Transition.generate("Negative", @negative, "a < b")
    transitions = [positive_transition, negative_transition]
    @start = Wreckem::State.new "Start", transitions, false
    @start.components << QuestionText.new("Two numbers should be positive?")
    Wreckem::StateMachine.new("Positive value", @start).tap do |machine|
      machine.components << Quest.new
    end
  end

  it "should generate state_machine entities" do
    machine_entity = Wreckem::StateMachineGenerator.generate(simple_machine)
    machine_entity.one(Wreckem::StateMachineComponents::Name).value.should == "Positive value"
    machine_entity.is?(Quest).should == true
  end

  it "should build a state_mechine from a generated one" do
    machine_entity = Wreckem::StateMachineGenerator.generate(simple_machine)
    machine = Wreckem::StateMachine.build(machine_entity)
    machine.components.first.class.should == Quest
  end

  it "should execute a simple state machine" do
    machine = simple_machine
    new_state = machine.execute(1, 2)
    new_state.should == @negative
    new_state.goal?.should == true
    new_state = machine.execute(2, 1)
    new_state.should == @positive
    new_state.goal?.should == true
  end

  it "should not transition to a new state when nothing fires" do
    machine = simple_machine
    new_state = machine.execute(1, 1) 
    new_state.should == nil
  end
end
