require 'wreckem/common_methods'

module Wreckem
  class Entity
    include Enumerable, Wreckem::CommonMethods

    def initialize
      generate_uuid

      yield self if block_given?
    end

    def add(*components)
      manager.components.add(self, *components)
    end

    def each
      manager.components.components_set_for(self).each { |c| yield c }
    end

    def delete(*components)
      full_set = manager.components.components_set_for(self)
      components.each { |component| full_set.delete(component) }
    end

    def [](component_class)
      # TODO: implement me
    end
  end
end
