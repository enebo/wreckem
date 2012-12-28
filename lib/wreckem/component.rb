require 'wreckem/common_methods'

module Wreckem
  ##
  # Component is the data holder for this EC framework.  This is probably
  # more heavy-weight than many EC frameworks by standing up an instance
  # around all data, but hell it is my first implementation and standing
  # up an instance inherited from a common Component class allows for 
  # friendly API where I can ask components questions about the game
  # they live in.
  #
  class Component
    include Wreckem::CommonMethods
    extend Wreckem::CommonMethods

    def initialize()
      @uuid = generate_uuid
    end

    ##
    # Delete this component instance from the game.
    #
    def delete
      manager.delete_component(self)
      self
    end

    ##
    # Get the (first) entity for this component instance.
    #
    def entity
      manager.entities_for_component(@uuid).first
    end

    ##
    # Get all components instances of this type from the specified
    # entity.  If only one instance exists then it returns just the
    # instance; otherwise it will return the instances as a list.
    #
    def self.many(e)
      manager.components_of_entity(e).find_all {|c| c.class == self }
    end

    ##
    # Get the first/single component of this type for the supplied
    # entity.
    #
    def self.one(e)
      many(e).first
    end

    ##
    # All component instances for this Component type 
    #
    # == Examples
    #
    #   PlayerInput.all do |pi|
    #     pi.command_line
    #   end
    #
    def self.all(&block)
      manager.components_for_class(self, &block)
    end

    ##
    # All entities associated with this component.  This is a foundational
    # method for outer-most access by Systems.
    #
    # == Examples
    #
    #   Player.entities # A systems wants to act on all player entities
    #
    def self.entities
      return manager.entities_for_component_class(self) unless block_given?

      manager.entities_for_component_class(self).each { |e| yield e }
    end

    ##
    # Retrieve entity + all intersected component instances which are
    # present across all entities.  Note that your first component should
    # be your narrowest search (least number of matching entities) to
    # reduce the amount of entities you will be scouring.
    #
    # == Examples
    #
    #  CommandLine.intersects(Diety, Name) do |entity, cli, diety, name|
    #     puts "#{name.value} is executing #{cli.line}"
    #     execute(cli.line)
    #     entity.delete cli  # Done executing command
    #  end
    #
    #  In this example very few people are entering commands and they may be 
    #  many Dieties in the game.  Name is a very common component.
    #
    def self.intersects(*cclasses)
      cclasses = [self] + cclasses
      manager.entities_for_component_class(self).each do |entity_uuid|
        entity = manager[entity_uuid]
        hash = manager.components_of_entity(entity_uuid).inject({}) do |s, c|
          s[c.class] = c if cclasses.include? c.class
          s
        end

        list = cclasses.map { |c| hash[c] }.compact

        yield entity, *list if list.size == cclasses.size
      end
    end

    ##
    # Define a content-less component (for pure aspect identification)
    #
    def self.define
      define_as_type(:aspect)
    end

    def self.define_as_bool
      define_as_type(:bool)
    end

    def self.define_as_int
      define_as_type(:int)
    end

    def self.define_as_ref
      define_as_type(:ref)
    end

    def self.define_as_string
      define_as_type(:string)
    end

    def self.define_as_text
      define_as_test(:text)
    end

    def self.define_as_type(data_type)
      Class.new(Component) do
        if data_type == :aspect
          def initialize
            super()
          end

          def value
            true
          end
        else
          attr_accessor :value 

          def initialize(value)
            super()

            if value.kind_of?(Wreckem::Component) && value.type == type
              @value = value.value
            elsif value.kind_of?(Wreckem::Entity) && type == :ref
              @value = value.uuid
            else
              @value = value
            end
          end
        end

        def same?(other)
          if other.kind_of?(Wreckem::Component)
            self.value == other.value
          else
            value == other
          end
        end

        def to_s
          @value.to_s
        end

        # Special reference method for things to key off of.
        alias_method :ref, :value if data_type == :ref

        define_method(:type) { data_type }
      end
    end
  end
end
