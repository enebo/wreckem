require 'wreckem/entity_manager'
require 'wreckem/component'

Container = Wreckem::Component.define
HitPoints = Wreckem::Component.define_as_int
Wound = Wreckem::Component.define_as_int

describe Wreckem::Entity do
  before do
    @em = Wreckem::EntityManager.new
  end

  it "should not be directly constructable" do
    expect { Wreckem::Entity.new }.to raise_error NoMethodError
  end

  it "should add to an entity using is" do
    bag = @em.create_entity("bag")
    bag.is(Container)
    components = bag.to_a
    components.size.should == 1
    components[0].class.should == Container

    Container.one(bag).class.should == Container
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

    bag.one(Container).class.should == Container
  end

  it "should execute in a transaction for create_entity" do
    h = HitPoints.new(6)
    id = nil
    player = @em.create_entity do |e|
      id = e.id
      e.has(h)
      @em[e.id].should == nil
      HitPoints.all.find { |hp| hp == h }.should == nil
    end

    @em[id].should == player
    HitPoints.all.find { |hp| hp == h }.should == h
  end

  it "should execute in an explicit transaction block" do
    h = HitPoints.new(6)
    player = nil
    id = nil
    @em.transaction do
      player = @em.create_entity
      id = player.id
      player.has(h)
      @em[player.id].should == nil
      HitPoints.all.find { |hp| hp == h }.should == nil
    end

    @em[id].should == player
    HitPoints.all.find { |hp| hp == h }.should == h
  end

  it "nested transactions in same thread should merge" do
    @em.transaction do
      h = HitPoints.new(6)
      player = @em.create_entity do |e|
        id = e.id
        e.has(h)
        @em[id].should == nil
        HitPoints.all.find { |hp| hp == h }.should == nil
      end
    end
  end

  it "should know if it contains components with is and has" do
    bag = @em.create_entity("bag")
    bag.is(Container)

    bag.is?(Container).should_not be_nil
    bag.has?(Container).should_not be_nil
  end

  it "should access one component using one" do
    bag = @em.create_entity
    bag.has HitPoints.new(9001)

    bag.one(HitPoints).value.should == 9001
  end

  it "should access all same-type components using many" do
    player = @em.create_entity do |p|
      p.has Wound.new(5)
      p.has Wound.new(4)
      p.has Wound.new(3)
    end

    player.many(Wound).size.should == 3
  end
end
