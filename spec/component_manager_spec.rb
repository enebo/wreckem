require 'wreckem/entity_manager'

class Position < Wreckem::Component
  attr_accessor :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end
end

class Shape < Wreckem::Component
  attr_accessor :kind

  def initialize(kind)
    @kind = kind
  end
end

describe Wreckem::ComponentManager do
  before do
    @em = Wreckem::EntityManager.instance
    @entity1 = @em.create("toy")
    @entity2 = @em.create("cpu", "processor")
    @position1 = Position.new(10, 20)
    @position2 = Position.new(0, 0)
    @shape = Shape.new(:triangle)
    @entity1.add @position1
    @entity1.add @shape
    @entity2.add @position2
  end

  after do
    Wreckem::EntityManager.shutdown
  end

  it "should add components to entities" do
    @entity1.to_a.size.should == 2
    @entity2.to_a.size.should == 1
  end

  it "should find entities with intersects/all" do
    Position.intersects(Shape) do |position, shape|
      position.should == @position1
      shape.should == @shape
    end

    Position.all.size.should == 2
    Shape.all.size.should == 1
  end

  it "should remove a component from an entity" do
    @entity1.delete @position1
    @entity1.to_a.size.should == 1
    @entity1.to_a.first.should == @shape
  end
end
