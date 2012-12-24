require 'wreckem/entity'
require 'wreckem/component_manager'
require 'wreckem/backends/memory'

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
      @components = Wreckem::ComponentManager.new self
      @backend = Wreckem::MemoryStore.new(@components)
    end

    ##
    # Create a new entity and provide it with n possible aliases.
    # Note: These aliases are considered to be unique across all
    # entities.
    #
    def create(*aliases, &block)
      @backend.store(Entity.new(&block), aliases)
    end

    ##
    # Retrieve entity from entity instance, uuid, or alias in that order
    def [](entity_or_alias)
      if entity_or_alias.respond_to? :uuid
        @backend.load(entity_or_alias.uuid)
      else
        value = @backend.load(entity_or_alias)
        value = @backend.load_from_alias(entity_or_alias) unless value
        value
      end
    end

    def delete(entity)
      entity = entity.uuid if entity.respond_to? :uuid
      @backend.delete(entity)
    end

    def each(&block)
      @backend.entities &block
    end

    def size
      @backend.entities.size
    end
  end
end
