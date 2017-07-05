require 'json-schema/attribute'

module JSON
  class Schema
    class PatternAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        return unless data.is_a?(String)

        pattern = current_schema.schema['pattern']
        regexp  = Regexp.new(pattern)
        unless regexp.match(data)
          message = "The property '#{build_fragment(fragments)}' value #{data.inspect} did not match the regex '#{pattern}'"
          validation_error(processor, message: message, fragments: fragments, schema: current_schema, failed_attribute: self, record_errors: options[:record_errors])
        end
      end
    end
  end
end
