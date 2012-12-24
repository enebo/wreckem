require 'wreckem/common_methods'

module Wreckem
  class Entity
    include Enumerable, Wreckem::CommonMethods

    def initialize(uuid=nil)
      @uuid =  uuid ? uuid : generate_uuid

      yield self if block_given?
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

    def each
      manager.components_of_entity(self).each { |c| yield c }
    end

    def components
      manager.components_of_entity(self).to_a
    end

    def delete(*components)
      components.each { |component| manager.delete_component(component) }
    end
  end
end
