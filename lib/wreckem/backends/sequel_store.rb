require 'sequel'

module Wreckem
  class SequelStore
    ASPECT = 1
    STRING = 2
    REF = 3
    INT = 4
    FLOAT = 5
    BOOL = 6

    TYPE_MAP = {
      :aspect => ASPECT,
      :string => STRING,
      :ref => REF,
      :int => INT,
      :float => FLOAT,
      :bool => BOOL,
    }

    COLUMN_MAP = {
      ASPECT => nil,
      STRING => :string_data,
      REF => :int_data,
      INT => :int_data,
      FLOAT => :float_data,
      BOOL => :bool_data,
    }

    def initialize()
      @db = Sequel.connect("jdbc:sqlite:db")
      unless @db.table_exists?(:sequence)
        @db.create_table(:sequence) do
          primary_key :id
          integer :count
        end
        @db[:sequence].insert(:id => 0, :count => 0)
      end
      @ids = @db[:sequence]

      unless @db.table_exists?(:components)
        @db.create_table(:components) do
          primary_key :id, :auto_increment => true
          string :name, :null => false, :index => true
          integer :type, :null => false, :index => true
          integer :eid, :null => false, :index => true
          integer :int_data, :null => true
          float :float_data, :null => true
          string :string_data, :null => true, :index => true
          string :text_data, :null => true
          boolean :bool_data, :null => true
        end
      end
      @components = @db[:components]
    end

    ##
    # 
    def insert_component(component)
      db_type = TYPE_MAP[component.type]
      row_data = {eid: component.eid, name: component.class.name, type: db_type}
      value_column = COLUMN_MAP[db_type]
      row_data[value_column] = component.value if value_column
      new_id = @components.insert row_data
      component.id = new_id
    end

    ##
    # Deletes the entity and any associated aliases.
    #
    def delete_entity(entity)
      @components.where(eid: entity.id).delete
    end

    def delete_component(component)
      @components.where(id: component.id).delete
    end

    def destroy
      @db.drop_table(:components)
      @db.drop_table(:sequence)
    end

    ##
    # Generate a new id.  Note this is not part of transaction because worst
    # case we give out some unused ids
    def generate_id
      id = @ids.first[:count]
      @ids.where(:id => 0).update(:count => id + 1)
      id
    end

    ##
    # Load component from class
    #
    def load_components_from_class(component_class, &block)
      query = @components.where(:name => component_class.name).map do |row|
        instantiate_component(row)
      end

      return query.enum_for(:each) if !block_given? 
        
      query.each { |component| yield component }
    end

    ##
    # Load all components for the specified entity id.
    #
    def load_components_of_entity(entity_id, &block)
      query = @components.where(:eid => entity_id).map do |row|
        instantiate_component(row)
      end

      return query.enum_for(:each) if !block_given? 
        
      query.each { |component| yield component }
    end

    ##
    # Load entity of id
    #
    def load_entity(entity_id)
      return nil unless entity_id

      Entity.new_protected(entity_id)  # FIXME: should we really query on this?
    end

    def load_entities_for_component_class(component_class, &block)
      query = @components.where(:name => component_class.name).map do |row|
        Entity.new_protected(row[:eid])
      end

      return query.enum_for(:each) if !block_given? 
        
      query.each { |entity| yield entity }
    end

    ##
    # explicit memory stores use this but SQL db does not need it
    def self.restore
    end

    ##
    # explicit memory stores use this but SQL db does not need it
    def save
    end

    def update_component(component)
      db_type = TYPE_MAP[component.type]
      row_data = {id: component.id, eid: component.eid, 
        name: component.class.name, type: db_type}
      value_column = COLUMN_MAP[db_type]
      row_data[value_column] = component.value if value_column
      @components.where(id: component.id).update(row_data)
      component
    end

    def transaction(&block)
      yield
    end

    def name_to_class(class_name)
      class_name.split("::").inject(Object) do |parent, name|
        parent.const_get(name) 
      end
    end
    private :name_to_class

    def instantiate_component(row)
      component_class = name_to_class(row[:name])
      component = if row[:type] == ASPECT
                    component_class.new
                  else
                    component_class.new(row[COLUMN_MAP[row[:type]]])
                  end
      component.id = row[:id]
      component.eid = row[:eid]
      component
    end
    private :instantiate_component
    
  end
end
