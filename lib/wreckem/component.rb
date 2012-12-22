require 'wreckem/common_methods'

module Wreckem
  class Component
    include Wreckem::CommonMethods
    extend Wreckem::CommonMethods

    def initialize
      generate_uuid
    end

    def delete
      manager.components.delete_component(self)
      self
    end

    def entity
      manager.components.entities_set_for(self.class).each do |e|
        manager.components.components_set_for(e).each do |c|
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
      list = manager.components.components_set_for(e).find_all do |c|
        c.class == self
      end

      list.length == 1 ? list[0] : list
    end

    def self.all(&block)
      manager.components.all(self, &block)
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
