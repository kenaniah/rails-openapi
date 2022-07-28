module Rails
  module Openapi
    # Defines a base class from which OpenAPI engines can be created.
    # Uses namespace isolation to ensure routes don't conflict with any
    # pre-existing routes from the main rails application.
    class Engine < ::Rails::Engine
      isolate_namespace Rails::Openapi
    end

    # Helper method to create a new engine based on a module namespace prefix and an OpenAPI spec file
    def self.Engine namespace:, schema:, publish_schema: true
      # Convert the module prefix into a constant if passed in as a string
      base_module = Object.const_get namespace if String === namespace

      # Ensure the OpenAPI spec file is in an acceptable format
      begin
        require "yaml"
        document = YAML.safe_load schema
        unless document.is_a?(Hash) && document["openapi"].present?
          raise "The schema argument could not be parsed as an OpenAPI schema"
        end
        unless Gem::Version.new(document["openapi"]) >= Gem::Version.new("3.0")
          raise "The schema argument must be an OpenAPI 3.0+ schema. You passed in a schema with version #{document["openapi"]}"
        end
      rescue Psych::SyntaxError
        raise $!, "Problem parsing OpenAPI schema: #{$!.message.lines.first.strip}", $@
      end

      # Builds a routing tree based on the OpenAPI spec file.
      # We'll add each endpoint to the routing tree and additionally
      # store it in an array to be used below.
      router = Router.new
      endpoints = []
      document["paths"].each do |url, actions|
        actions.each do |verb, definition|
          next if verb == "parameters"
          route = Endpoint.new(verb.downcase.to_sym, url, definition)
          router << route
          endpoints << route
        end
      end

      # Creates the engine that will be used to actually route the
      # contents of the OpenAPI spec file. The engine will eventually be
      # attached to the base module (argument to this current method).
      #
      # Exposes `::router` and `::endpoints` methods to allow other parts
      # of the code to tie requests back to their spec file definitions.
      engine = Class.new Engine do
        @router = router
        @endpoints = {}
        @schema = document.freeze

        class << self
          attr_reader :router

          attr_reader :endpoints

          attr_reader :schema
        end

        # Rack app for serving the original OpenAPI file
        openapi_app = Class.new do
          def inspect
            "Rails::Openapi::Engine"
          end
          define_method :call do |env|
            [
              200,
              {"Content-Type" => "application/json"},
              [engine.schema.to_json]
            ]
          end
        end

        # Adds routes to the engine by passing the Mapper to the top
        # of the routing tree. `self` inside the block refers to an
        # instance of `ActionDispatch::Routing::Mapper`.
        routes.draw do
          scope module: base_module.name.underscore, format: false do
            get "openapi.json", to: openapi_app.new, as: :openapi_schema if publish_schema
            router.draw self
          end
        end
      end

      # Assign the engine as a class on the base module
      base_module.const_set :Engine, engine

      # Creates a hash that maps routes back to their OpenAPI spec file
      # equivalents. This is accomplished by mocking a request for each
      # OpenAPI spec file endpoint and determining which controller and
      # action the request is routed to. OpenAPI spec file definitions
      # are then attached to that controller/action pair.
      endpoints.each do |route|
        # Mocks a request using the route's URL
        url = ::ActionDispatch::Journey::Router::Utils.normalize_path route.path
        env = ::Rack::MockRequest.env_for url, method: route[:method].upcase
        req = ::ActionDispatch::Request.new env

        # Maps the OpenAPI spec endpoint to the destination controller
        # action by routing the request.
        begin
          mapped = engine.routes.router.recognize(req) {}.first[2].defaults
        rescue
          Rails.logger.error "Could not resolve the OpenAPI route for #{req.method} #{req.url}"
          next
        end
        key = "#{mapped[:controller]}##{mapped[:action]}"
        engine.endpoints[key] = route
      end
      engine.endpoints.freeze

      # Defines a helper module on the base module that can be used to
      # properly generate OpenAPI-aware controllers. Any controllers
      # referenced from a OpenAPI spec file should include this module.
      mod = Module.new do
        @base = base_module
        def self.included controller
          base_module = @base
          # Returns a reference to the Rails engine generated for this OpenAPI spec file
          define_method :openapi_engine do
            base_module.const_get :Engine
          end
          # Returns the OpenAPI schema used to generate the Rails engine as a Hash
          define_method :openapi_schema do
            base_module.const_get(:Engine).schema
          end
          # Returns the OpenAPI spec's endpoint definition for current request
          define_method :openapi_endpoint do
            openapi_engine.endpoints["#{request.path_parameters[:controller]}##{request.path_parameters[:action]}"]
          end
        end
      end
      base_module.const_set :OpenapiHelper, mod

      # Returns the new engine
      base_module.const_get :Engine
    end
  end
end
