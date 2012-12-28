require 'wreckem/entity_manager'

describe Wreckem::EntityManager do
  before do
    @em = Wreckem::EntityManager.instance(false)
    @entity1 = @em.create_entity("toy")
    @entity2 = @em.create_entity("cpu", "processor")
  end

  after do
    Wreckem::EntityManager.shutdown
  end

  it "should create new entities" do
    @entity1.class.should == Wreckem::Entity
    @entity2.class.should == Wreckem::Entity
    @entity1.should_not == @entity2
    @em.size.should == 2
  end

  it "should be able to delete entities" do
    @em.size.should == 2
    entity = @em.delete_entity(@entity1)
    entity.should == @entity1
    @em.size.should == 1
    @em.first.should == @entity2
  end

  it "should be able to retrieve entities" do
    @em[@entity1].should == @entity1
    @em[@entity2].should == @entity2
  end

  it "should be able to retrieve entities using aliases" do
    @em["toy"].should == @entity1
    @em["cpu"].should == @entity2
    @em["processor"].should == @entity2
  end

  it "should be able to retriece entities using raw uuid" do
    @em[@entity1.uuid].should == @entity1
  end

  it "should save" do
    @em.save
    Wreckem::EntityManager.shutdown
    @em = Wreckem::EntityManager.instance
  end

  it "should look up entities using ref components" do
    Ref = Wreckem::Component.define_as_ref
    ref = Ref.new(@entity1.uuid)
    @em[ref].should == @entity1
  end
end
