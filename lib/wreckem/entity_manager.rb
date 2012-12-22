require 'wreckem/entity'
require 'wreckem/component_manager'

module Wreckem
  class EntityManager
    attr_reader :components

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
      @entities = {}          # {uuid => entity_instance}
      @aliases = {}           # {alias_name => entity_instance}
      @map_to_aliases = {}    # {uuid => alias_name
      @components = Wreckem::ComponentManager.new self
    end

    ##
    # Create a new entity and provide it with n possible aliases.
    # Note: These aliases are considered to be unique across all
    # entities.
    def create(*aliases, &block)
      entity = Entity.new &block
      
      @entities[entity.uuid] = entity

      aliases.each do |a|
        @aliases[a] = entity
        map_to_aliases(entity.uuid) << a
      end

      entity
    end

    ##
    # Retrieve entity from entity instance, uuid, or alias in that order
    def [](entity_or_alias)
      if entity_or_alias.respond_to? :uuid
        @entities[entity_or_alias.uuid]
      else
        value = @entities[entity_or_alias]
        value = @aliases[entity_or_alias] unless value
        value
      end
    end

    def delete(entity_or_alias)
      entity = self[entity_or_alias]
      uuid = entity.uuid

      @entities.delete(uuid)
      @components.delete(entity)
      map_to_aliases(uuid).each { |alias_name| @aliases.delete(alias_name) }
      @map_to_aliases.delete(uuid)

      entity
    end

    def map_to_aliases(uuid)
      @map_to_aliases[uuid] ||= []
    end

    def each
      @entities.each { |e| yield e }
    end

    def size
      @entities.size
    end
  end
end
