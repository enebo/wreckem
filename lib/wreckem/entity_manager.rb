require 'wreckem/entity'
require 'wreckem/component'
require 'wreckem/backends/memory'

module Wreckem
  class EntityManager
    include Enumerable

    ##
    # Code smell...one global manager instance?
    def self.instance
      @manager ||= new
    end

    def self.shutdown
      @manager = nil
    end

    def initialize
      @backend = Wreckem::MemoryStore.new
    end

    ##
    # Create a new entity and provide it with n possible aliases.
    # Note: These aliases are considered to be unique across all
    # entities.
    #
    def create_entity(*aliases, &block)
      @backend.store_entity(Entity.new(&block), aliases)
    end

    ##
    # Add supplied components to the supplied entity.
    #
    def add_component(entity, component)
      @backend.store_component(entity, component)
    end

    def components_for_class(component_class, &block)
      @backend.load_components_from_class(component_class, &block)
    end

    def components_of_entity(entity)
      @backend.load_components_of_entity(uuid_for(entity))
    end

    ##
    # Retrieve entity from entity instance, uuid, or alias in that order
    #
    def [](entity_or_alias)
      if entity_or_alias.respond_to? :uuid
        @backend.load_entity(entity_or_alias.uuid)
      else
        value = @backend.load_entity(entity_or_alias)
        value = @backend.load_entity_from_alias(entity_or_alias) unless value
        value
      end
    end

    def delete_component(component)
      @backend.delete_component(component)
    end

    def delete_entity(uuid)
      @backend.delete_entity(uuid_for(uuid))
    end

    def entities_for_component(component)
      @backend.load_entities_of_component(component).map {|uuid| self[uuid] }
    end

    def entities_for_component_class(component_class)
      @backend.load_entities_for_component_class(component_class)
    end

    def each(&block)
      @backend.entities &block
    end

    def size
      @backend.entities.size
    end

    def uuid_for(something)
      something.respond_to?(:uuid) ? something.uuid : something
    end
    private :uuid_for
  end
end
