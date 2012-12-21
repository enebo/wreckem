require 'java'

module Wreckem
  module CommonMethods
    attr_reader :uuid

    def generate_uuid
      @uuid = java.util.UUID.randomUUID().to_s
    end
    private :generate_uuid

    def manager
      Wreckem::EntityManager.instance
    end
    private :manager
  end
end
