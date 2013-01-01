require 'wreckem/entity_manager'

Position = Wreckem::Component.define_as_int
Shape = Wreckem::Component.define_as_string
FooRef = Wreckem::Component.define_as_ref

describe Wreckem::Component do
  before { @em = Wreckem::EntityManager.new }
  after { @em.destroy }

  it "should not be able to add nil as a component" do
    expect { Wreckem::Entity.is! {|e| e.is(nil) }}.to raise_error(ArgumentError)
  end


  it "should find all component instances using 'all'" do
    Wreckem::Entity.is! { |e| e.has Position.new(4) }
    Wreckem::Entity.is! { |e| e.has Position.new(5) }
  
    Position.all.to_a.size.should == 2
  end

  it "should find all component instances using 'all' with block" do
    Wreckem::Entity.is! { |e| e.has Position.new(4) }
    Wreckem::Entity.is! { |e| e.has Position.new(5) }
  
    count = 0
    Position.all { |c|
      count += 1
      c.class.should == Position
    }
    count.should == 2
  end

  it "should find entities with 'intersects'" do
    Wreckem::Entity.is! { |e| e.has Position.new(4) }
    Wreckem::Entity.is! do |e| 
      e.has Position.new(5)
      e.has Shape.new "circle"
    end

    Position.intersects(Shape) do |position, shape|
      position.value.should == 5
      shape.value.should == "circle"
    end
  end

  it "should find all entities using 'entities'" do
    Wreckem::Entity.is! { |e| e.has Position.new(4) }
    Wreckem::Entity.is! { |e| e.has Shape.new("square") }
    Wreckem::Entity.is! do |e| 
      e.has Position.new(5)
      e.has Shape.new "circle"
    end

    entities = Shape.entities.to_a
    entities.size.should == 2
    entities.first.class.should == Wreckem::Entity
  end

  it "should find all entities using 'entities' via enumerator" do
    Wreckem::Entity.is! { |e| e.has Position.new(4) }
    Wreckem::Entity.is! { |e| e.has Shape.new("square") }
    Wreckem::Entity.is! do |e| 
      e.has Position.new(5)
      e.has Shape.new "circle"
    end

    entities = Shape.entities
    count = 0
    entities.each do |e|
      count += 1
      e.class.should == Wreckem::Entity
    end
    count.should == 2
  end

  it "should get component from an entity" do
    entity1 = Wreckem::Entity.is! { |e| e.has Shape.new("square") }
    entity2 = Wreckem::Entity.is! do |e| 
      e.has Shape.new "sphere"
      e.has Shape.new "circle"
    end

    Shape.one(entity1).value.should == "square"
    Shape.many(entity2).size.should == 2
  end

  it "should get entity from a component instance" do
    shape = Shape.new "square"
    entity = Wreckem::Entity.is! { |e| e.has shape }

    shape.entity.should == entity
  end

  it "should update components using 'save'" do
    entity = Wreckem::Entity.is! { |e| e.has Position.new(4) }

    position = Position.one(entity)
    position.value += 1
    position.save

    position = Position.one(entity)
    position.value.should == 5
  end

  it "should 'to_s' the boxed component value" do
    entity = Wreckem::Entity.is! { |e| e.has Position.new(4) }

    entity.one(Position).to_s.should == "4"
  end

  it "should allow same? to do equality comparison" do
    entity = Wreckem::Entity.is! { |e| e.has Position.new(4) }

    fun = FooRef.new(entity)
    fun.same?(entity.id).should == true
  end

  it "should allow references to call 'to_entity'" do
    entity = Wreckem::Entity.is! { |e| e.has Position.new(4) }
    entity2 = Wreckem::Entity.is! do |e|
      e.has Position.new(3)
      e.has FooRef.new(entity.id)
    end

    FooRef.one(entity2).to_entity.should == entity
  end

  it "should allow new values via 'update'" do
    entity = Wreckem::Entity.is! { |e| e.has Position.new(4) }

    pos = Position.one(entity)
    pos.update(5)
    pos.value.should == 5

    pos2 = Position.one(entity)
    pos2.value.should == 4

    pos.save

    pos2 = Position.one(entity)
    pos2.value.should == 5
  end

  it "should allow new values via 'update!'" do
    entity = Wreckem::Entity.is! { |e| e.has Position.new(4) }

    pos = Position.one(entity)
    pos.update!(5)
    pos2 = Position.one(entity)
    pos2.value.should == 5
  end
end
