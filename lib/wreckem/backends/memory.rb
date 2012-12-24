module Wreckem
  class MemoryStore
    def initialize(components)
      @components = components
      @entities = {}          # {uuid => entity_instance}
      @aliases = {}           # {alias_name => uuid}
      @map_to_aliases = {}    # {uuid => alias_name}
    end

    ##
    # Deletes the entity and any associated aliases and returns the entity
    # if successful.  Otherwise nil is returned.
    def delete(uuid)
      entity = load(uuid)
      return nil unless entity

      @entities.delete(uuid)
      @components.delete(entity)
      map_to_aliases(uuid).each { |alias_name| @aliases.delete(alias_name) }
      @map_to_aliases.delete(uuid)

      entity
    end

    ##
    # Return all entities or yield to all entities
    #
    def entities
      return @entities.values unless block_given?

      @entities.each { |uuid, entity| yield entity }
    end

    ##
    # Load entity of uuid
    #
    def load(entity_uuid)
      @entities[entity_uuid]
    end

    ##
    # Load entity of alias
    #
    def load_from_alias(a)
      uuid = @aliases[a]
      uuid ? load(uuid) : nil
    end

    ##
    # Store new entity along with its aliases.  It will return the entity
    # that was submitted.
    #
    def store(entity, aliases)
      @entities[entity.uuid] = entity

      aliases.each do |a|
        @aliases[a] = entity.uuid
        map_to_aliases(entity.uuid) << a
      end

      entity
    end

    def map_to_aliases(uuid)
      @map_to_aliases[uuid] ||= []
    end
    private :map_to_aliases
  end
end
