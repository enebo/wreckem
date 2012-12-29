require 'wreckem/entity'
require 'wreckem/component'
require 'wreckem/backends/memory'

module Wreckem
  class EntityManager
    include Enumerable

    def initialize(backend=Wreckem::MemoryStore.new)
      Wreckem::Entity.manager = self
      Wreckem::Component.manager = self
      
      @backend = backend
    end

    ##
    # Create a new entity and provide it with n possible aliases.
    # Note: These aliases are considered to be unique across all
    # entities.
    #
    def create_entity(*aliases)
      if block_given?
        transaction do
          entity = Entity.new_protected(@backend.generate_id)
          yield entity if block_given?
          @backend.create_entity(entity, aliases)
        end
      else
        entity = Entity.new_protected(@backend.generate_id)
        @backend.create_entity(entity, aliases)
      end
    end

    ##
    # Add supplied components to the supplied entity.
    #
    def add_component(entity, component)
      @backend.store_component(entity, component)
    end

    def components_for_class(component_class)
      @backend.load_components_from_class(component_class)
    end

    def components_of_entity(entity)
      @backend.load_components_of_entity(id_for(entity))
    end

    ##
    # Retrieve entity from entity instance, id, or alias in that order
    #
    def [](entity_or_alias)
      if entity_or_alias.respond_to?(:ref)
        @backend.load_entity(entity_or_alias.ref)
      elsif entity_or_alias.respond_to? :id
        @backend.load_entity(entity_or_alias.id)
      else
        value = @backend.load_entity(entity_or_alias)
        value = @backend.load_entity_from_alias(entity_or_alias) unless value
        value
      end
    end

    def delete_component(component)
      @backend.delete_component(component)
    end

    def delete_entity(entity)
      @backend.delete_entity(entity)
    end

    def entities_for_component(component)
      @backend.load_entities_of_component(id_for(component)).map do |id|
        self[id]
      end
    end

    def entities_for_component_class(component_class)
      @backend.load_entities_for_component_class(component_class).map {|id| self[id] }
    end

    def entity_as_string(entity)
      entity.components.inject("#{entity.id.inspect}\n") do |s, component|
        s << "    #{component.inspect}\n"
      end
    end

    def generate_id
      @backend.generate_id
    end

    def each
      @backend.entities.each { |e| yield e }
    end

    def save
      @backend.save
    end

    def size
      @backend.entities.size
    end

    def transaction(&block)
      @backend.transaction(&block)
    end

    def id_for(something)
      something.respond_to?(:id) ? something.id : something
    end
    private :id_for
  end
end
