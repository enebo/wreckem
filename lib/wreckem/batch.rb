module Wreckem
  class Batch
    attr_reader :items

    def initialize
      @items = []
    end

    def <<(item)
      @items << item
    end

    # returns first entity of first component persisted in this batch
    def save
      id = @items.empty? ? nil : @items.first.eid
      @items.map(&:save)
      Wreckem::Entity.new_protected(id)
    end
  end
end
