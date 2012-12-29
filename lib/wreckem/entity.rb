require 'wreckem/common_methods'

module Wreckem
  class Entity
    include Enumerable, Wreckem::CommonMethods

    class << self
      alias :new_protected :new

      def new
        raise NoMethodError.new("Use Wreckem::EntityManager.create_entity")
      end
    end

    def initialize()
      @uuid =  uuid ? uuid : generate_uuid
    end

    def add(*components)
      components.each { |component| manager.add_component(self, component) }
    end
    alias_method :has, :add

    ##
    # For boolean components as a nicer looking way of specifying them
    def is(*cclasses)
      cclasses.each { |component_class| add(component_class.new) }
    end

    def is?(component_class)
      !!component_class.one(self)
    end
    alias_method :has?, :is?

    def one(component_class)
      component_class.one(self)
    end

    def many(component_class)
      component_class.many(self)
    end

    def each
      manager.components_of_entity(self).each { |c| yield c }
    end

    def components
      manager.components_of_entity(self).to_a
    end

    def delete(*components)
      components.each { |component| manager.delete_component(component) }
    end

    def manager
      self.class.manager
    end

    def self.manager=(manager)
      @@manager = manager
    end

    def self.manager
      @@manager
    end
  end
end
