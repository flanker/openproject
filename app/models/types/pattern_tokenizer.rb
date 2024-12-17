# frozen_string_literal: true

#-- copyright
#++

module Types
  class PatternTokenizer
    TOKEN_REGEX = /\{\{[A-z_]+:[0-9A-z_]+\}\}+/

    class Token
      attr_reader :replacement_token

      def initialize(token_string)
        @target, @property = token_string.tr("{}", "").split(":")
        @replacement_token = token_string
      end

      def resolve(work_package)
        if @target == "work_package"
          stringify(work_package.public_send(@property.to_sym))
        else
          stringify(work_package.send(@target.to_sym).send(@property.to_sym))
        end
      end

      private

      def stringify(value)
        case value
        when Date, Time, DateTime
          value.strftime("%Y-%m-%d")
        when Array
          value.join(", ")
        else
          value.to_s
        end
      end
    end

    def initialize(pattern)
      @pattern = pattern
      @tokens = pattern.scan(TOKEN_REGEX).map { |token| Token.new(token) }
    end

    def resolve(work_package)
      @tokens.each_with_object(@pattern.dup) do |token, result|
        result.gsub!(token.replacement_token, token.resolve(work_package))
      end
    end
  end
end
