require 'json-schema/attribute'

module JSON
  class Schema
    class UniqueItemsAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        return unless data.is_a?(Array)

        if data.clone.uniq!
          message = "The property '#{build_fragment(fragments)}' contained duplicated array values"
          validation_error(processor, message: message, fragments: fragments, schema: current_schema, failed_attribute: self, record_errors: options[:record_errors])
        end
      end
    end
  end
end
