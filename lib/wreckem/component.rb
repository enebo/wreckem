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
    attr_accessor :id
    attr_accessor :eid

    def initialize
    end

    ##
    # Delete this component instance from the game.
    #
    def delete
      self.class.manager.delete_component(self)
      self
    end

    ##
    # Get the (first) entity for this component instance.
    #
    def entity
      Wreckem::Entity.new_protected(eid)
    end

    ##
    # Save/persist this component
    #
    def save
      self.class.manager.save_component(self)
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
    #   PlayerInput.all
    #
    def self.all
      manager.components_for_class(self)
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

    # FIXME: The DB should be doing this intersection logic

    ##
    # Retrieve entity + all intersected component instances which are
    # present across all entities.  Note that your first component should
    # be your narrowest search (least number of matching entities) to
    # reduce the amount of entities you will be scouring.
    #
    # == Examples
    #
    #  CommandLine.intersects(Diety, Name) do |cli, diety, name|
    #     puts "#{name.value} is executing #{cli.line}"
    #     execute(cli.line)
    #     cli.delete  # Done executing command
    #  end
    #
    #  In this example very few people are entering commands and they may be 
    #  many Dieties in the game.  Name is a very common component.
    #
    def self.intersects(*cclasses)
      cclasses = [self] + cclasses
      manager.entities_for_component_class(self).each do |entity_id|
        entity = manager[entity_id]
        hash = manager.components_of_entity(entity_id).inject({}) do |s, c|
          s[c.class] = c if cclasses.include? c.class
          s
        end

        list = cclasses.map { |c| hash[c] }.compact

        yield list if list.size == cclasses.size
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
            super
          end

          def ==(other)
            self.class == other.class && self.id == other.id
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
              @value = value.id
            else
              @value = value
            end

            @value = @value.to_s if type == :string
          end
        end

        def ==(other)
          self.class == other.class && self.id == other.id && self.value == other.value
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

        if data_type == :ref
          def to_entity
            manager[ref]
          end

          # Special reference method for things to key off of.
          alias_method :ref, :value
        end

        define_method(:type) { data_type }
      end
    end

    def self.manager=(manager)
      @@manager = manager
    end

    def self.manager
      @@manager
    end
  end
end
