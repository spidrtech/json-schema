require 'json-schema/attribute'

module JSON
  class Schema
    class OneOfAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        errors = Hash.new { |hsh, k| hsh[k] = [] }

        validation_errors = 0
        one_of = current_schema.schema['oneOf']

        original_data = data.is_a?(Hash) ? data.clone : data
        success_data = nil

        one_of.each_with_index do |element, schema_index|
          schema = JSON::Schema.new(element,current_schema.uri,validator)
          pre_validation_error_count = validation_errors(processor).count
          begin
            schema.validate(data,fragments,processor,options)
            success_data = data.is_a?(Hash) ? data.clone : data
          rescue ValidationError
            # just ignore
          end

          diff = validation_errors(processor).count - pre_validation_error_count
          validation_errors += 1 if diff > 0
          while diff > 0
            diff = diff - 1
            errors["oneOf ##{schema_index} "].push(validation_errors(processor).pop)
          end

          data = original_data
        end



        if validation_errors == one_of.length - 1
          data = success_data
          return
        end

        if validation_errors == one_of.length
          message = "The property '#{build_fragment(fragments)}' of type #{data.class} did not match any of the required schemas"
        else
          message = "The property '#{build_fragment(fragments)}' of type #{data.class} matched more than one of the required schemas"
        end

        validation_error(processor, message, fragments, current_schema, self, options[:record_errors]) if message
        validation_errors(processor).last.sub_errors = errors
      end
    end
  end
end
