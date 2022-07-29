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

# Run the tests
require "minitest/autorun"
