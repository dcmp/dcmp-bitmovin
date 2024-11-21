  class Bitmovin::Object
    class << self
      # Meta programming
      def param(name, opts = {})
        required_params << name
        attr_accessor name

        if opts[:exclude]
          excluded_params << name
        end
      end

      def option(name, opts = {})
        optional_params[name] = opts[:default] || nil
        attr_accessor name

        define_method("#{name}") do
          instance_variable_get("@#{name}") || opts[:default]
        end
      end

      def route(path)
        @route = path
      end

      def route_path
        @route
      end

    private

      def required_params
        @required_params ||= []
      end

      def optional_params
        @optional_params ||= {}
      end

      def excluded_params
        @excluded_params ||= []
      end
    end

    attr_reader :id
    attr_reader :instance_path

    def initialize(attributes = {})
      validate_attributes!(attributes)
      set_attributes(attributes)
    end

    def instance_route(path)
      @instance_path = path
    end

    def route_path
      @instance_path || self.class.route_path
    end

    def save!
      payload = build_payload
      path = route_path

      path.scan(/:([a-z_]+)/).flatten.each do |var|
        path = path.gsub(":#{var}", self.send(var))
      end

      puts "GONNA SEND TO: vvvv-----> #{path}"
      puts "Payload: #{payload.to_json}"

      response = Bitmovin.client.post(path, data: payload)
      puts response
      @id = response["data"]["result"]["id"]

      self
    end

  protected

    def build_payload
      payload = {}

      self.class.send(:required_params).each do |param|
        next if self.class.send(:excluded_params).include?(param)
        payload[param.to_s.camelize(:lower)] = instance_variable_get("@#{param}")
      end

      self.class.send(:optional_params).each do |param, _|
        value = instance_variable_get("@#{param}")
        payload[param.to_s.camelize(:lower)] = value unless value.nil?
      end

      payload
    end

  private

    def validate_attributes!(attributes)
      validate_required_params!(attributes)
      validate_no_extra_params!(attributes)
    end

    def validate_no_extra_params!(attributes)
      extra_params = attributes.keys - self.class.send(:required_params) - self.class.send(:optional_params).keys

      if extra_params.any?
        raise ArgumentError, "Unknown params: #{extra_params.join(", ")}"
      end
    end

    def validate_required_params!(attributes)
      missing_params = self.class.send(:required_params) - attributes.keys

      if missing_params.any?
        raise ArgumentError, "Missing required params: #{missing_params.join(", ")}"
      end
    end

    def set_attributes(attributes)
      attributes.each do |key, value|
        if self.class.send(:required_params).include?(key) || self.class.send(:optional_params).key?(key)
          instance_variable_set("@#{key}", value)
        else
          raise ArgumentError, "Unknown param: #{key}"
        end
      end
    end
  end