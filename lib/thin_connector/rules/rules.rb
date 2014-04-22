require 'json'

module ThinConnector
  module Rules

    class Rules
      attr_accessor :tag, :value

      def initialize(value, tag=nil)
        @value = value
        @tag = tag || ''
      end

      def to_h
        {
            value: value,
            tag: tag
        }
      end

      def to_s
        to_h.to_s
      end

      def to_json
        to_h.to_json
      end
    end

  end
end