require 'wreckem/entity_manager'
require 'wreckem/component'

class Container < Wreckem::Component
end

describe Wreckem::Entity do
  before do
    @em = Wreckem::EntityManager.instance
  end

  after do
    Wreckem::EntityManager
  end

  it "should add to an entity" do
    bag = @em.create("bag")
    bag.is(Container)
    components = bag.to_a
    components.size.should == 1
    components[0].class.should == Container

    Container.for(bag).class.should == Container
  end

  it "should create entity using a block" do
    bag = @em.create("bag") do |e|
      e.is(Container)
    end

    Container.for(bag).class.should == Container
  end
end
