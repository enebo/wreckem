require 'wreckem/entity_manager'
require 'wreckem/component'

Container = Wreckem::Component.define
Wound = Wreckem::Component.define_as_int

describe Wreckem::Entity do
  before { @em = Wreckem::EntityManager.new }
  after { @em.destroy }

  it "should not be directly constructable" do
    expect { Wreckem::Entity.new }.to raise_error NoMethodError
  end

  it "should create an entity using 'is'" do
    # Local un-saved section
    entity = nil
    batch = Wreckem::Entity.is do |e|
      e.is(Container)
      entity = e
    end

    batch.items.map(&:class).should == [Container] # Exists only in batch

    Container.one(entity).should == nil # Not saved yet
    
    batch.save # Save via backend

    # Lookup via backend
    Container.one(entity).class.should == Container
  end

  it "should create an entity using 'is!" do
    entity = Wreckem::Entity.is! { |e| e.is(Container) }

    Container.one(entity).class.should == Container
  end

  it "should add to an entity using 'has'" do
    entity = Wreckem::Entity.is! { |e| e.has(Wound.new(12)) }

    Wound.one(entity).value.should == 12
  end

  it "should add an entity outside of is/is!" do
    entity = Wreckem::Entity.is! { |e| e.has(Wound.new(12)) }

    entity.is Container

    Container.one(entity).class.should == Container
  end

  it "should know if it contains components with 'is' and 'has'" do
    entity = Wreckem::Entity.is! { |e| e.is(Container) }

    entity.is?(Container).should_not be_nil
    entity.has?(Container).should_not be_nil
  end

  it "should be findable via Wreckem::Entity.find" do
    entity = Wreckem::Entity.is! { |e| e.is(Container) }

    entity2 = Wreckem::Entity.find entity.id
    
    entity.should == entity2
  end

  it "should access all same-type components using 'many'" do
    entity = Wreckem::Entity.is! do |e|
      e.has Wound.new(5)
      e.has Wound.new(4)
      e.has Wound.new(3)
    end

    count = 0
    entity.many(Wound).each do |w|
      w.class.should == Wound
      count += 1
    end
    count.should == 3
  end

  # to_a from Enumerable excercises 'each'
  it "should access all same-type components using 'each'" do
    entity = Wreckem::Entity.is! do |e|
      e.is Container
      e.has Wound.new(5)
      e.has Wound.new(4)
      e.has Wound.new(3)
    end

    entity.to_a.size.should == 4
  end

  it "should 'delete' all components associated with it" do
    entity = Wreckem::Entity.is! do |e|
      e.has Wound.new(5)
      e.has Wound.new(4)
      e.has Wound.new(3)
    end

    entity.many(Wound).to_a.size.should == 3

    entity.delete

    entity.many(Wound).to_a.size.should == 0
  end
end
