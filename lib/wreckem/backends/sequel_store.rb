require 'sequel'
require 'securerandom'

module Wreckem
  class SequelStore
    ASPECT = 1
    STRING = 2
    REF = 3
    INT = 4
    FLOAT = 5
    BOOL = 6
    TEXT = 7

    TYPE_MAP = {
      :aspect => ASPECT,
      :string => STRING,
      :ref => REF,
      :int => INT,
      :float => FLOAT,
      :bool => BOOL,
      :text => TEXT
    }

    COLUMN_MAP = {
      ASPECT => :bool_data,
      STRING => :string_data,
      REF => :int_data,
      INT => :int_data,
      FLOAT => :float_data,
      BOOL => :bool_data,
      TEXT => :text_data
    }


    def initialize(db_string="jdbc:sqlite:db")
      @db = Sequel.connect(db_string)
#      @db.logger = @@logger
      @db.drop_table :sequence if @db.table_exists?(:sequence)
      @db.drop_table :components if @db.table_exists?(:components)
      unless @db.table_exists?(:sequence)
        @db.create_table(:sequence) do
          primary_key :id
          Integer :count
        end
        @db[:sequence].insert(:id => 1, :count => 0)
      end
      @ids = @db[:sequence]

      unless @db.table_exists?(:components)
        @db.create_table(:components) do
          primary_key :id, :auto_increment => true
          String :name, :null => false, :index => true
          Integer :type, :null => false, :index => true
          Int :eid, :null => false, :index => true
          Integer :int_data, :null => true
          Float :float_data, :null => true
          String :string_data, :null => true, :index => true
          String :text_data, :null => true
          Boolean :bool_data, :null => true
        end
      end
      @components = @db[:components]
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
      @ids.where(:id => 1).update(:count => id + 1)
      id
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
    # Load component from class
    #
    def load_components_from_class(component_class, &block)
      query = @components.where(:name => component_class.name).map do |row|
        instantiate_component_from_row(row)
      end

      return query.enum_for(:each) if !block_given?

      query.each { |component| yield component }
    end

    ##
    # Load component from classes
    #
    def load_components_from_classes(component_classes, &block)
      where_hash = component_classes.pop if component_classes.last.class == Hash
      joins, eqs, names, datas, wheres = [], [], [], [], []

      ## TODO - escape illegal characters
      component_classes.each_with_index do |c, i|
        joins << " INNER JOIN components as components#{i} " if i != 0
        eqs << " components#{i}.eid = components#{ (i+1) == component_classes.size ? 0 : i+1}.eid "
        names << " components#{i}.name = '#{c.name}' "
        datas << " components#{i}.#{ COLUMN_MAP[TYPE_MAP[c.type]]} as #{c.name.gsub(':', '')}Component, components#{i}.id as #{c.name.gsub(':', '')}Id "
        if where_hash and conds = (where_hash[c.name.to_sym] or conds = where_hash[c.name.downcase.to_sym])
          if conds[:value]
            val = conds[:value].class == String ? "'#{conds[:value]}'" : conds[:value].to_s
            column = COLUMN_MAP[TYPE_MAP[c.type]]
            wheres << " components#{i}.#{ column } #{'!' if val.include?('!')}= #{val.gsub('!', '')} "
          end
          if conds[:eid]
            val = conds[:eid]
            column = 'eid'
            wheres << " components#{i}.#{ column } #{'!' if val.include?('!')}= #{val.gsub('!', '')} "
          end
        end
      end
      if not wheres.empty?
        where_query = "WHERE #{wheres.join(" AND ")}"
      end
      query_string = "select components0.eid, #{datas.join(",")} from components as components0 #{joins.join(" ")} on (#{eqs.join("and")} and #{names.join("and")}) #{where_query};"

      query = @db[query_string].map do |row|
        instantiate_components_from_columns(row)
      end

      return query.enum_for(:each) if !block_given?

      query.each { |component| yield component }
    end

    ##
    # Load all components for the specified entity id.
    #
    def load_components_of_entity(entity_id, &block)
      query = @components.where(:eid => entity_id).map do |row|
        instantiate_component_from_row(row)
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

    def instantiate_components_from_columns(row)
      keys = row.keys
      eid = row[keys.shift]
      component_classes = keys.each_with_index.map{|c, i| name_to_class(c.to_s.gsub("Component",'')) if i.even?}.compact!
      components = component_classes.map do |component_class|
        component = component_class.type == :aspect ? component_class.new : component_class.new(row["#{component_class.name}Component".to_sym])
        component.id = row[:"#{component_class.name}Id"].to_i
        component.eid = eid
        component
      end
      return components
    end
    private :instantiate_components_from_columns

    def instantiate_component_from_row(row)
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
    private :instantiate_component_from_row

  end
end
