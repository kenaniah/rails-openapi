# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

# Initialize the Rails application
require "bundler/setup"
require "action_controller/railtie"
require "rails/test_unit/railtie"
require "rails/openapi"
Bundler.require(*Rails.groups)
module Dummy
  class Application < Rails::Application
    config.load_defaults 6.0
    config.eager_load = false
    config.logger = Logger.new($stdout)
  end
end
Rails.application.initialize!

module Api
  module Stripe
  end
end

module PetStore
end

module USPTO
end

Rails.application.routes.draw do
  scope :api do
    mount Rails::Openapi::Engine(namespace: "Api::Stripe", schema: File.read("test/schemas/stripe-api.yaml")), at: :stripe, as: :stripe_api
    scope :uspto do
      mount Rails::Openapi::Engine(namespace: "USPTO", schema: File.read("test/schemas/uspto.yaml")), at: "/", as: :uspto
    end
  end
  mount Rails::Openapi::Engine(namespace: "PetStore", schema: File.read("test/schemas/petstore.json")), at: "petstore-api", as: :petstore
end

# Monkey patches to support testing engines
class ActionDispatch::IntegrationTest
  class << self
    def route_using &block
      @engine = block
      @routes = block.call.routes
    end

    def engine
      @engine || proc { main_app }
    end
  end

  # Asserts that path and options match both ways; in other words, it verifies that <tt>path</tt> generates
  # <tt>options</tt> and then that <tt>options</tt> generates <tt>path</tt>. This essentially combines +assert_recognizes+
  # and +assert_generates+ into one step.
  #
  # The +extras+ hash allows you to specify options that would normally be provided as a query string to the action. The
  # +message+ parameter allows you to specify a custom error message to display upon failure.
  #
  #  # Asserts a basic route: a controller with the default action (index)
  #  assert_routing '/home', controller: 'home', action: 'index'
  #
  #  # Test a route generated with a specific controller, action, and parameter (id)
  #  assert_routing '/entries/show/23', controller: 'entries', action: 'show', id: 23
  #
  #  # Asserts a basic route (controller + default action), with an error message if it fails
  #  assert_routing '/store', { controller: 'store', action: 'index' }, {}, {}, 'Route for store index not generated properly'
  #
  #  # Tests a route, providing a defaults hash
  #  assert_routing 'controller/action/9', {id: "9", item: "square"}, {controller: "controller", action: "action"}, {}, {item: "square"}
  #
  #  # Tests a route with an HTTP method
  #  assert_routing({ method: 'put', path: '/product/321' }, { controller: "product", action: "update", id: "321" })
  #
  # Adapted from https://github.com/rails/rails/blob/e3c9d566aee43545951648b8b60b1045dc4d8c37/actionpack/lib/action_dispatch/testing/assertions/routing.rb#L128-L138
  def assert_routing(path, options, defaults = {}, extras = {}, message = nil)
    # Adjust the router to use the main application's routes
    old_routes = @routes
    @routes = main_app.routes
    assert_recognizes(options, path, extras, message)

    controller, default_controller = options[:controller], defaults[:controller]
    if controller&.include?("/") && default_controller && default_controller.include?("/")
      options[:controller] = "/#{controller}"
    end

    # Adjust the router to use the engine's routes
    @routes = instance_eval(&self.class.engine).routes
    generate_options = options.dup.delete_if { |k, _| defaults.key?(k) }
    assert_generates(path.is_a?(Hash) ? path[:path] : path, generate_options, defaults, extras, message)
  ensure
    # Restore the original router
    @routes = old_routes
  end
end

# Run the tests
require "minitest/autorun"
