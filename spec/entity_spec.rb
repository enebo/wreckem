require 'wreckem/entity_manager'
require 'wreckem/component'

class Container < Wreckem::Component
end

describe Wreckem::Entity do
  before do
    @em = Wreckem::EntityManager.instance(false)
  end

  after do
    Wreckem::EntityManager
  end

  it "should add to an entity using is" do
    bag = @em.create_entity("bag")
    bag.is(Container)
    components = bag.to_a
    components.size.should == 1
    components[0].class.should == Container

    Container.one_for(bag).class.should == Container
  end

  it "should add to an entity using has" do
    bag = @em.create_entity("bag")
    bag.has(Container.new)
    components = bag.to_a
    components.size.should == 1
    components[0].class.should == Container
  end

  it "should create entity using a block" do
    bag = @em.create_entity("bag") do |e|
      e.is(Container)
    end

    Container.one_for(bag).class.should == Container
  end

  it "should know if it contains components with is and has" do
    bag = @em.create_entity("bag")
    bag.is(Container)

    bag.is?(Container).should_not be_nil
    bag.has?(Container).should_not be_nil
  end
end
