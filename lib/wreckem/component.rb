require 'wreckem/common_methods'

module Wreckem
  class Component
    include Wreckem::CommonMethods
    extend Wreckem::CommonMethods

    def initialize(uuid = nil)
      @uuid = uuid ? uuid : generate_uuid
    end

    def delete
      components.delete_component(self)
      self
    end

    ##
    # Get the entity for this component instance.
    #
    def entity
      self.class.entities do |e|
        components.components_set_for(e).each do |c| 
         return e if c == self 
        end
      end
      nil
    end

    ##
    # Get all components instances of this type from the specified
    # entity.  If only one instance exists then it returns just the
    # instance; otherwise it will return the instances as a list.
    def self.for(e)
      if block_given?
        manager.components.components_set_for(e).each do |c|
          yield c if c.class == self
        end
      else
        manager.components.components_set_for(e).find_all {|c| c.class == self }
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
      manager.components.all(self, &block)
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
      return components.entities_set_for(self).to_a unless block_given?

      components.entities_set_for(self).each { |e| yield e }
    end

    def self.intersects(*cclasses)
      components = manager.components
      cclasses = [self] + cclasses
      components.entities_set_for(self).each do |entity|
        list = components.components_set_for(entity).inject([]) do |s, c|
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
