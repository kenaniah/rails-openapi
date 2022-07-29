# frozen_string_literal: true

require "test_helper"

class Rails::TestStripeApi < ActionDispatch::IntegrationTest
  def test_it_properly_routes_the_stripe_api
    @routes = stripe_api.routes
    base = "api/stripe"

    # To debug routes, use:
    puts ActionDispatch::Routing::RoutesInspector.new(main_app.routes.routes).format(ActionDispatch::Routing::ConsoleFormatter::Sheet.new)

    assert_generates "/#{base}/v1/3d_secure", controller: "#{base}/v1/3d_secure", action: :create
    assert_generates "/#{base}/v1/3d_secure/:id", controller: "#{base}/v1/3d_secure", action: :show, id: ":id"

    assert_generates "/#{base}/v1/account", controller: "#{base}/v1/account", action: :show
    assert_generates "/#{base}/v1/account", controller: "#{base}/v1/account", action: :create
    assert_generates "/#{base}/v1/account", controller: "#{base}/v1/account", action: :destroy

    assert_generates "/#{base}/v1/accounts", controller: "#{base}/v1/accounts", action: :index
    assert_generates "/#{base}/v1/accounts", controller: "#{base}/v1/accounts", action: :create
    assert_generates "/#{base}/v1/accounts/:id", controller: "#{base}/v1/accounts", action: :show, id: ":id"
    #assert_generates "/#{base}/v1/accounts/1234", controller: "#{base}/v1/accounts", action: :create, id: "1234"
    assert_generates "/#{base}/v1/accounts/:id", controller: "#{base}/v1/accounts", action: :destroy, id: ":id"

    # assert_equal route_for("v1/accounts", :index), "#{base}/v1/accounts"
    # assert_equal route_for("v1/accounts", :create), "#{base}/v1/accounts"
    # assert_equal route_for("v1/accounts", :show, id: 1234), "#{base}/v1/accounts/1234"
    # assert_equal route_for("v1/accounts", :create, id: 1234), "#{base}/v1/accounts/1234"
    # assert_equal route_for("v1/accounts", :destroy, id: 1234), "#{base}/v1/accounts/1234"
  end
end
