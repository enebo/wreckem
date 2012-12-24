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

    def initialize(uuid = nil)
      @uuid = uuid ? uuid : generate_uuid
    end

    ##
    # Delete this component instance from the game.
    #
    def delete
      manager.delete_component(uuid)
      self
    end

    ##
    # Get the (first) entity for this component instance.
    #
    def entity
      manager.entities_for_component(uuid).first
    end

    ##
    # Get all components instances of this type from the specified
    # entity.  If only one instance exists then it returns just the
    # instance; otherwise it will return the instances as a list.
    def self.for(e)
      if block_given?
        manager.components_of_entity(e).each { |c| yield c if c.class == self }
      else
        manager.components_of_entity(e).find_all {|c| c.class == self }
      end
    end

    def self.one_for(e)
      self.for(e) { |c| return c }
      nil
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
        list = manager.components_of_entity(entity_uuid).inject([]) do |s, c|
          s << c if cclasses.include? c.class
          s
        end

        if list.length == cclasses.length 
          yield cclasses.length == 1 ?  list.first : list 
        end
      end
    end
  end
end
