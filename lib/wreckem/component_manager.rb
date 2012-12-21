require 'wreckem/entity_manager'
require 'wreckem/component'
require 'set'

# entities => {uuid}
# aliases => {name => uuid}

module Wreckem
  class ComponentManager
    def initialize(manager)
      @manager = manager
      @entities_set_for = {}   # {component_class => [entity1,...entityn]}
      @components_set_for = {} # {uuid => [component1,...componentn]}
    end

    def add(entity, *components)
      components.each do |component|
        entities_set_for(component.class).add entity
        components_set_for(entity).add component
      end
    end

    def delete(entity)
      components_set_for(entity).each do |component|
        entities_set_for(component.class).delete entity
      end
      @components_set_for.delete entity.uuid
    end

    def delete_component(*components)
      components.each do |component|
        entities_set_for(component.class).each do |entity|
          components_set_for(entity).delete component
        end
        @entities_set_for.delete component.class
      end
    end

    def all(component_class)
      entities_set_for(component_class).each do |entity|
        components_set_for(entity).each do |component|
          yield component if component_class == component.class
        end
      end
    end

    def entities_set_for(component_class)
      @entities_set_for[component_class] ||= Set.new
    end

    def components_set_for(entity)
      @components_set_for[entity.uuid] ||= Set.new
    end
  end
end
