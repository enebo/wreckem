require 'wreckem/entity'
require 'wreckem/component'
require 'wreckem/backends/memory'
require 'wreckem/backends/sequel_store'

module Wreckem
  EntityAlias = Wreckem::Component.define

  class EntityManager
    include Enumerable

    def initialize(backend=Wreckem::SequelStore.new)
      Wreckem::Entity.manager = self
      Wreckem::Component.manager = self
      
      @backend = backend
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
    def [](entity)
      if entity.respond_to?(:ref)
        entity = entity.ref
      elsif entity.respond_to?(:id)
        entity = entity.id
      end

      @backend.load_entity(entity)
    end

    def delete_component(component)
      @backend.delete_component(component)
    end

    def delete_entity(entity)
      @backend.delete_entity(entity)
    end

    def destroy
      @backend.destroy
    end

    def entities_for_component(component)
      @backend.load_entities_of_component(id_for(component))
    end

    def entities_for_component_class(component_class)
      @backend.load_entities_for_component_class(component_class)
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

    def save_component(component)
      # New components have no assigned ids yet.  They are set once stored
      # in the database.
      if component.id
        @backend.update_component(component)
      else
        @backend.insert_component(component)
      end
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
