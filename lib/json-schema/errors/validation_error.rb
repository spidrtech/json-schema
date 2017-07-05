module JSON
  class Schema
    class ValidationError < StandardError
      INDENT = "    "
      attr_accessor :sub_errors

      def initialize data = {}
        @data = data.freeze
        @sub_errors = {}
        super(message_with_schema)
      end

      def to_string(subschema_level = 0)
        if @sub_errors.empty?
          subschema_level == 0 ? message_with_schema : @data[:message]
        else
          messages = ["#{@data[:message]}. The schema specific errors were:\n"]
          @sub_errors.each do |subschema, errors|
            messages.push "- #{subschema}:"
            messages.concat Array(errors).map { |e| "#{INDENT}- #{e.to_string(subschema_level + 1)}" }
          end
          messages.map { |m| (INDENT * subschema_level) + m }.join("\n")
        end
      end

      def to_hash
        base = {
            :schema => @data[:schema].uri,
            :fragment => ::JSON::Schema::Attribute.build_fragment(@data[:fragments]),
            :message => message_with_schema,
            :failed_attribute => @data[:failed_attribute].to_s.split(":").last.split("Attribute").first,
            :data => @data[:failed_attribute],
            :orig_message => @data[:message],
            :fragments => @data[:fragments],
            :orig_schema => @data[:schema]
        }
        if !@sub_errors.empty?
          base[:errors] = @sub_errors.inject({}) do |hsh, (subschema, errors)|
            subschema_sym = subschema.downcase.gsub(/\W+/, '_').to_sym
            hsh[subschema_sym] = Array(errors).map{|e| e.to_hash}
            hsh
          end
        end
        base
      end

      def message_with_schema
        "#{@data[:message]} in schema #{@data[:schema].uri}"
      end
    end
  end
end
