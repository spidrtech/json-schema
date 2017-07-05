require 'json-schema/attribute'
require 'json-schema/errors/custom_format_error'

module JSON
  class Schema
    class CustomFormat < FormatAttribute
      def initialize(validation_proc)
        @validation_proc = validation_proc
      end

      def validate(current_schema, data, fragments, processor, validator, options = {})
        begin
          @validation_proc.call data
        rescue JSON::Schema::CustomFormatError => e
          message = "The property '#{self.class.build_fragment(fragments)}' #{e.message}"
          self.class.validation_error(processor, message: message, fragments: fragments, schema: current_schema, failed_attribute: self, record_errors: options[:record_errors])
        end
      end
    end
  end
end
