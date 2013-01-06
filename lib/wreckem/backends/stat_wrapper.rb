module Wreckem
  class StatWrapper
    def initialize(backend)
      @backend = backend
      @counts, @times = {}, {}
    end

    def delete_entity(entity)
      time_and_count(:delete_entity) do
        @backend.delete_entity(entity)
      end
    end

    def delete_component(component)
      time_and_count(:delete_component) do
        @backend.delete_component(component)
      end
    end

    def destroy
      time_and_count(:destroy) do
        @backend.destroy
      end
    end

    def generate_id
      time_and_count(:generate_id) do
        @backend.generate_id
      end
    end

    def insert_component(component)
      time_and_count(:insert_component) do
        @backend.insert_component(component)
      end
    end

    def load_components_from_class(component_class, &block)
      time_and_count(:load_components_from_class) do
        @backend.load_components_from_class(component_class, &block)
      end
    end

    def load_components_of_entity(entity_id, &block)
      time_and_count(:load_components_of_entity) do
        @backend.load_components_of_entity(entity_id, &block)
      end
    end

    def load_entity(entity_id)
      time_and_count(:load_entity) do
        @backend.load_entity(entity_id)
      end
    end

    def load_entities_for_component_class(component_class)
      time_and_count(:load_entities_for_component_class) do
        @backend.load_entities_for_component_class(component_class)
      end
    end

    def self.restore
      @backend.class.restore
    end

    def save
      @backend.save
    end

    def update_component(component)
      time_and_count(:update_component) do
        @backend.update_component(component)
      end
    end

    def transaction(&block)
      time_and_count(:transaction) do
        @backend.transaction(&block)
      end
    end


    def time_and_count(method)
      start = Time.now
      ret = yield
      time_spent = Time.now - start
      
      update_count(method)
      update_time(method, time_spent)
      
      ret
    end

    def update_count(method)
      count = @counts[method] || 0
      @counts[method] = count + 1
    end

    def update_time(method, time_spent)
      time = @times[method] || 0.0
      @times[method] = time + time_spent
    end

    def all_stats
      [:delete_entity, :delete_component, :entities, 
       :load_components_from_class, :load_components_of_entity,
       :load_entity, :load_entity_from_alias, 
       :load_entities_of_component, :load_entities_for_component_class,
       :store_entity, :store_component].inject([]) do |list, method|
        list << stats_for(method)
      end
    end

    def stats_for(method)
      time = @times[method] || 0.0
      count = @counts[method] || 0
      
      [method, count, time]
    end
  end
end
