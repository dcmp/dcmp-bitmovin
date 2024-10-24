module EncryptedFields
  extend ActiveSupport::Concern

  class InvalidFieldTypeError < StandardError; end
  class InvalidJSONError < StandardError; end

  class_methods do
    def encrypted_field(attribute_name, type: :json, symbolize: false)
      secured_attribute = "secured_#{attribute_name}"

      define_method(attribute_name) do
        instance_variable_get("@#{attribute_name}") || begin
          encrypted_data = send(secured_attribute)
          return default_value(type) unless encrypted_data

          decrypted_data = Encryption.decrypt(Base64.decode64(encrypted_data))

          case type
          when :json
            config = Marshal.load(decrypted_data)
            config = config.deep_symbolize_keys if symbolize
            config = config.with_indifferent_access unless symbolize
          when :string
            config = decrypted_data
          else
            raise InvalidFieldTypeError, "Unsupported field type: #{type}"
          end

          instance_variable_set("@#{attribute_name}", config)
          config
        end
      end

      define_method("#{attribute_name}=") do |value|
        case type
        when :json
          if value.is_a?(String)
            value = JSON.parse(value) rescue value
          end

          raise InvalidJSONError, "Configuration must be a Hash" unless value.is_a?(Hash)
          value = value.deep_symbolize_keys if symbolize
          value = value.with_indifferent_access unless symbolize
        when :string
          raise InvalidFieldTypeError, "Value must be a String" unless value.is_a?(String)
        else
          raise InvalidFieldTypeError, "Unsupported field type: #{type}"
        end

        instance_variable_set("@#{attribute_name}", value)
        instance_variable_set("@#{attribute_name}_changed", true)
      end

      before_save do
        if instance_variable_get("@#{attribute_name}_changed")
          data_to_serialize = send(attribute_name)
          serialized_configuration = type == :json ? Marshal.dump(data_to_serialize) : data_to_serialize
          encrypted_data = Base64.encode64(Encryption.encrypt(serialized_configuration))
          send("#{secured_attribute}=", encrypted_data)
        end
      end
    end
  end

private

  def default_value(type)
    case type
    when :json
      {}
    when :string
      ""
    else
      raise InvalidFieldTypeError, "Unsupported field type: #{type}"
    end
  end
end
