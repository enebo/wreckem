require 'java'

module Wreckem
  module CommonMethods
    attr_reader :uuid

    def generate_uuid
      java.util.UUID.randomUUID().to_s
    end
  end
end
