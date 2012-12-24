require 'set'

module Wreckem
  class MemoryStore
    def initialize()
      @entities = {}           # {euuid => entity_instance}
      @aliases = {}            # {alias_name => euuid}
      @map_to_aliases = {}     # {euuid => alias_name}
      @entities_set_for = {}   # {component_class_name => [euuid,...euuidn]}
      @components = {}         # {cuuid => [euuid1,...,euuidn]}
      @components_set_for = {} # {euuid => [component1,...componentn]}
    end

    ##
    # Deletes the entity and any associated aliases and returns the entity
    # if successful.  Otherwise nil is returned.
    def delete_entity(uuid)
      entity = load_entity(uuid)
      return nil unless entity

      @entities.delete(uuid)

      components_set_for(uuid).each do |component|
        entities_set_for(component.class.name).delete uuid
        components_for(component.uuid).delete uuid
      end
      @components_set_for.delete uuid

      map_to_aliases(uuid).each { |alias_name| @aliases.delete(alias_name) }
      @map_to_aliases.delete(uuid)

      entity
    end

    def delete_component(component)
      eset = entities_set_for(component.class.name)
      components_for(component.uuid).each do |entity_uuid|
        components_set_for(entity_uuid).delete component
        eset.delete(entity_uuid)
      end
    end

    ##
    # Return all entities or yield to all entities
    #
    def entities
      return @entities.values unless block_given?

      @entities.each { |uuid, entity| yield entity }
    end

    ##
    # Load component from class
    #
    def load_components_from_class(component_class)
      if block_given?
        entities_set_for(component_class.name).each do |entity_uuid|
          components_set_for(entity_uuid).dup.each do |component|
            yield component if component_class == component.class
          end
        end
      else
        a = []
        entities_set_for(component_class.name).each do |entity_uuid|
          components_set_for(entity_uuid).each do |component|
            a << component if component_class == component.class
          end
        end
        a
      end
    end

    def load_components_of_entity(entity_uuid)
      components_set_for(entity_uuid)
    end

    ##
    # Load entity of uuid
    #
    def load_entity(entity_uuid)
      @entities[entity_uuid]
    end

    ##
    # Load entity of alias
    #
    def load_entity_from_alias(a)
      uuid = @aliases[a]
      uuid ? load_entity(uuid) : nil
    end

    ##
    # Load entities of an particular component
    def load_entities_of_component(component_uuid)
      components_for(component_uuid)
    end

    def load_entities_for_component_class(component_class)
      entities_set_for(component_class.name)
    end
    
    def self.restore
      File.open("db", "rb") { |f| Marshal.load(f.gets(nil)) }
    rescue
      new
    end

    def save
      File.open("db", "wb") { |f| f.write Marshal.dump(self) }
    end

    ##
    # Store new entity along with its aliases.  It will return the entity
    # that was submitted.
    #
    def store_entity(entity, aliases)
      @entities[entity.uuid] = entity

      aliases.each do |a|
        @aliases[a] = entity.uuid
        map_to_aliases(entity.uuid) << a
      end

      entity
    end

    def store_component(entity, component)
      components_for(component.uuid).add entity.uuid
      entities_set_for(component.class.name).add entity.uuid
      components_set_for(entity.uuid).add component
    end

    def map_to_aliases(uuid)
      @map_to_aliases[uuid] ||= []
    end
    private :map_to_aliases


    def entities_set_for(component_class_name)
      @entities_set_for[component_class_name] ||= Set.new
    end
    private :entities_set_for

    def components_set_for(entity_uuid)
      @components_set_for[entity_uuid] ||= Set.new
    end
    private :components_set_for

    def components_for(component_uuid)
      @components[component_uuid] ||= Set.new
    end
  end
end
