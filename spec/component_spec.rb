require 'wreckem/entity_manager'

class Position < Wreckem::Component
  attr_accessor :x, :y

  def initialize(x, y)
    super()
    @x, @y = x, y
  end
end

class Shape < Wreckem::Component
  attr_accessor :kind

  def initialize(kind)
    super()
    @kind = kind
  end
end

describe Wreckem::Component do
  before do
    @em = Wreckem::EntityManager.instance(false)
    @entity1 = @em.create_entity("toy")
    @entity2 = @em.create_entity("cpu", "processor")
    @position1 = Position.new(10, 20)
    @position2 = Position.new(0, 0)
    @shape = Shape.new(:triangle)
    @entity1.add @position1
    @entity1.add @shape
    @entity2.add @position2
    @entity3 = @em.create_entity do |e|
      e.add Shape.new(:square)
      e.add Shape.new(:rectangle)
    end
  end

  after do
    Wreckem::EntityManager.shutdown
  end

  it "should add components to entities" do
    @entity1.to_a.size.should == 2
    @entity2.to_a.size.should == 1
  end

  it "should find all component instances using all" do
    Position.all.size.should == 2
    Shape.all.size.should == 3
  end

  it "should find entities with intersects" do
    Position.intersects(Shape) do |entity, position, shape|
      entity.should == @entity1
      position.should == @position1
      shape.should == @shape
    end
  end

  it "should final entities using entities" do
    entities = Shape.entities
    entities.size.should == 2
    entities.first.class.should == Wreckem::Entity
  end

  it "should remove a component from an entity" do
    @entity1.delete @position1
    @entity1.components.size.should == 1
    @entity1.components.first.should == @shape
  end

  it "should get component from an entity" do
    Shape.one(@entity1).should == @shape
    Shape.many(@entity3).size.should == 2
  end

  it "should get entity from a component instance" do
    @shape.entity.should == @entity1
  end

  it "should create new components with define" do
    Foo = Wreckem::Component.define
    @entity1.is Foo

    @entity1.is?(Foo).should_not be_nil

    Bar = Wreckem::Component.define_as_int
    @entity1.has Bar.new(5)

    @entity1.one(Bar).type.should == :int
    @entity1.one(Bar).value.should == 5
    @entity1.one(Bar).value = 6
    @entity1.one(Bar).value.should == 6
  end

  it "should to_s the boxed component value" do
    Num = Wreckem::Component.define_as_int

    @entity1.has Num.new(5)
    @entity1.one(Num).to_s.should == "5"
  end

  it "should allow same? to do equality comparison" do
    Fun = Wreckem::Component.define_as_ref

    fun = Fun.new(@entity1)

    fun.same?(@entity1.uuid).should == true
  end

  it "should extract out matched types of comp.new(comp)" do
    Gun = Wreckem::Component.define_as_ref
    Hun = Wreckem::Component.define_as_ref
    Iun = Wreckem::Component.define_as_int

    gun = Gun.new(@entity1)
    hun = Hun.new(gun)
    iun = Iun.new(5)

    gun.same?(hun).should == true
    hun.same?(iun).should == false
  end

  it "should should all all comp(:ref) to accept entities" do
    Jun = Wreckem::Component.define_as_int
    
    Jun.new(@entity1).value.should == @entity1

  end
end
