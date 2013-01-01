require 'wreckem/batch'

module Wreckem
  class Entity
    include Enumerable

    attr_reader :id

    class << self
      alias :new_protected :new

      def new
        raise NoMethodError.new("Use Wreckem::Entity.is")
      end
    end

    ##
    # Create a new entity.  Entity is really just the id and the batch
    # is just a mechanism for capturing all the construction aspects of
    # this API.
    def initialize(id, batch=nil)
      @id, @batch = id, batch
    end

    ##
    # Do two instances of entity represent the same 
    #
    def ==(other)
      self.class == other.class && self.id == other.id
    end

    ##
    # Add all components to this entity
    #
    def add(*components)
      components.each do |component|
        component.eid = id
        if @batch
          @batch << component
        else
          component.save
        end
      end
    end
    alias_method :has, :add

    ##
    # Get a list of all local components (e.g. non-persisted)
    def components
      manager.components_of_entity(self).to_a
    end

    def delete
      manager.delete_entity(self)
    end

    ##
    # For boolean components as a nicer looking way of specifying them
    def is(*cclasses)
      cclasses.each do |component_class|
        raise ArgumentError unless component_class
        add(component_class.new)
      end
    end

    ##
    # Is the component class associated with this entity?
    def is?(component_class)
      !!component_class.one(self)
    end
    alias_method :has?, :is?

    ##
    # Give 0 or more resulting components of the supplied component class
    # for this entity.
    def many(component_class)
      component_class.many(self)
    end

    ##
    # Give 0 or one component of the supplied component class for this entity.
    def one(component_class)
      component_class.one(self)
    end

    def each
      manager.components_of_entity(self).each { |c| yield c }
    end

    def manager
      self.class.manager
    end

    def as_string
      components.inject(id.inspect + "\n") do |s, component|
        s << "    #{component.inspect}\n"
      end
    end

    ##
    # Primary method for defining entities and its associated components.
    # Note that this method will only define the entity and anything
    # constructed within the block locally.
    def self.is(&block)
      Batch.new.tap do |batch| 
        yield Entity.new_protected(manager.generate_id, batch) 
      end
    end

    def self.is!(&block)
      is(&block).save
    end

    def self.find(entity_id)
      manager[entity_id]
    end

    def self.manager=(manager)
      @@manager = manager
    end

    def self.manager
      @@manager
    end
  end
end
