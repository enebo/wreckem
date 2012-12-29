require 'set'

module Wreckem
  class MemoryStore
    class TransactionElement
      attr_reader :method, :args
    
      def initialize(method, *args)
        @method, @args = method, args
      end

      def execute(store)
        store.__send__(method, *args, true)
      end
    end

    def initialize()
      @entities = {}           # {eid => entity_instance}
      @aliases = {}            # {alias_name => eid}
      @map_to_aliases = {}     # {eid => alias_name}
      @entities_set_for = {}   # {component_class_name => [eid,...eidn]}
      @components = {}         # {cid => [eid1,...,eidn]}
      @components_set_for = {} # {eid => [component1,...componentn]}
      @id = 0                  # Give out ids for components/entities
      @in_transaction = false
      @transaction_elements = []
    end

    ##
    # other backends differentiate between a update and an insert
    def create_entity(entity, aliases)
      store_entity(entity, aliases)
    end

    ##
    # Deletes the entity and any associated aliases.
    #
    def delete_entity(entity, force=false)
      if !force && transaction?
        add_transaction_element(:delete_entity, entity)
      else
        id = entity.id
        @entities.delete(id)

        components_set_for(id).each do |component|
          entities_set_for(component.class.name).delete id
          components_for(component.id).delete id
        end
        @components_set_for.delete id

        map_to_aliases(id).each { |alias_name| @aliases.delete(alias_name) }
        @map_to_aliases.delete(id)
      end
      entity
    end

    def delete_component(component, force=false)
      if !force && transaction?
        add_transaction_element(:delete_component, component)
      else
        eset = entities_set_for(component.class.name)
        components_for(component.id).each do |entity_id|
          components_set_for(entity_id).delete component
          eset.delete(entity_id)
        end
      end
    end

    ##
    # Return all entities
    #
    def entities
      @entities.values
    end

    ##
    # Generate a new id.  Note this is not part of transaction because worst
    # case we give out some unused ids
    def generate_id
      id = @id
      @id += 1
      id
    end

    ##
    # Load component from class
    #
    def load_components_from_class(component_class)
      a = []
      entities_set_for(component_class.name).each do |entity_id|
        components_set_for(entity_id).each do |component|
          a << component if component_class == component.class
        end
      end
      a
    end

    def load_components_of_entity(entity_id)
      components_set_for(entity_id).to_a
    end

    ##
    # Load entity of id
    #
    def load_entity(entity_id)
      @entities[entity_id]
    end

    ##
    # Load entity of alias
    #
    def load_entity_from_alias(a)
      id = @aliases[a]
      id ? load_entity(id) : nil
    end

    ##
    # Load entities of an particular component
    def load_entities_of_component(component_id)
      components_for(component_id)
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
    def store_entity(entity, aliases, force=false)
      if !force && transaction?
        add_transaction_element(:store_entity, entity, aliases)
      else
        @entities[entity.id] = entity

        aliases.each do |a|
          @aliases[a] = entity.id
          map_to_aliases(entity.id) << a
        end
      end
      entity
    end

    def store_component(entity, component, force=false)
      if !force && transaction?
        add_transaction_element(:store_component, entity, component)
      else
        cid = component.id
        raise "Component #{component.class} has no id..missing super?" if !cid

        components_for(cid).add entity.id
        entities_set_for(component.class.name).add entity.id
        components_set_for(entity.id).add component
      end

      component
    end

    def transaction(&block)
      @in_transaction = true
      yield
      last = nil
      @transaction_elements.each { |element| last = element.execute(self) }
      last
    ensure
      @in_transaction = false
    end

    def add_transaction_element(*args)
      @transaction_elements << Wreckem::MemoryStore::TransactionElement.new(*args)
    end

    def map_to_aliases(id)
      @map_to_aliases[id] ||= []
    end
    private :map_to_aliases


    def entities_set_for(component_class_name)
      @entities_set_for[component_class_name] ||= Set.new
    end
    private :entities_set_for

    def components_set_for(entity_id)
      @components_set_for[entity_id] ||= Set.new
    end
    private :components_set_for

    def components_for(component_id)
      @components[component_id] ||= Set.new
    end
    private :components_for

    def transaction?
      @in_transaction
    end
    private :transaction?

    def components_set_as_string
      @components_set_for.inject("@components_set_for = {eid => [components]}\n") do |s, (eid, components)|
        s << "   #{eid.inspect}=[#{components.map(&:inspect).to_a.join(', ')}]\n"
      end
    end

    def components_as_string
      @components.inject("@components = {cid => [eids]\n") do |s, (cid, eids)|
        s << "   #{cid.inspect}=[#{eids.map(&:inspect).to_a.join(', ')}]\n"
      end
    end
  end
end
