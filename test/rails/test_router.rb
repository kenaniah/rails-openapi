# frozen_string_literal: true

require "test_helper"

class Rails::TestRouter < ActionDispatch::IntegrationTest
  def test_it_properly_routes_the_stripe_api
    @routes = stripe_api.routes
    base = "api/stripe"

    # To debug routes, use:
    # puts ActionDispatch::Routing::RoutesInspector.new(main_app.routes.routes).format(ActionDispatch::Routing::ConsoleFormatter::Sheet.new)

    assert_generates "/#{base}/v1/3d_secure", controller: "#{base}/v1/3d_secure", action: :create
    assert_generates "/#{base}/v1/3d_secure/:id", controller: "#{base}/v1/3d_secure", action: :show, id: ":id"

    assert_generates "/#{base}/v1/account", controller: "#{base}/v1/account", action: :show
    assert_generates "/#{base}/v1/account", controller: "#{base}/v1/account", action: :create
    assert_generates "/#{base}/v1/account", controller: "#{base}/v1/account", action: :destroy

    assert_generates "/#{base}/v1/accounts", controller: "#{base}/v1/accounts", action: :index
    assert_generates "/#{base}/v1/accounts", controller: "#{base}/v1/accounts", action: :create
    assert_generates "/#{base}/v1/accounts/:id", controller: "#{base}/v1/accounts", action: :show, id: ":id"
    assert_generates "/#{base}/v1/accounts/1234", controller: "#{base}/v1/accounts", action: :update, id: "1234"
    assert_generates "/#{base}/v1/accounts/:id", controller: "#{base}/v1/accounts", action: :destroy, id: ":id"

    assert_generates "/#{base}/v1/account/capabilities", controller: "#{base}/v1/account/capabilities", action: :index

    assert_generates "/#{base}/v1/accounts/:account_id/external_accounts/:id", controller: "#{base}/v1/accounts/external_accounts", action: :show, account_id: ":account_id", id: ":id"
    assert_generates "/#{base}/v1/accounts/:account_id/external_accounts/:id", controller: "#{base}/v1/accounts/external_accounts", action: :update, account_id: ":account_id", id: ":id"
    assert_generates "/#{base}/v1/accounts/:account_id/external_accounts/:id", controller: "#{base}/v1/accounts/external_accounts", action: :destroy, account_id: ":account_id", id: ":id"
  end

  def test_it_properly_routes_the_uspto_api
    skip
  end

  def test_it_properly_routes_the_petstore_api
    @routes = petstore.routes
    base = "petstore-api"

    assert_generates "/#{base}/pet", controller: "pet_store/pet", action: :create
    # assert_generates "/#{base}/pet", controller: "pet_store/pet", action: :update # This route breaks restful conventions

    assert_generates "/#{base}/pet/:id", controller: "pet_store/pet", action: :show, id: ":id"
    assert_generates "/#{base}/pet/:id", controller: "pet_store/pet", action: :update, id: ":id"
    assert_generates "/#{base}/pet/:id", controller: "pet_store/pet", action: :destroy, id: ":id"
    assert_generates "/#{base}/pet/:id/uploadImage", controller: "pet_store/pet/upload_image", action: :create, pet_id: ":id"

    assert_generates "/#{base}/pet/findByStatus", controller: "pet_store/pet/pet", action: "find_by_status"
    assert_generates "/#{base}/pet/findByTags", controller: "pet_store/pet/pet", action: "find_by_tags"

    assert_generates "/#{base}/store/inventory", controller: "pet_store/store/inventory", action: :show

    assert_generates "/#{base}/store/order", controller: "pet_store/store/order", action: :create
    assert_generates "/#{base}/store/order/:id", controller: "pet_store/store/order", action: :show, id: ":id"
    assert_generates "/#{base}/store/order/:id", controller: "pet_store/store/order", action: :destroy, id: ":id"

    assert_generates "/#{base}/user/createWithList", controller: "pet_store/user/user", action: "create_with_list"

    assert_generates "/#{base}/user", controller: "pet_store/user", action: :create
    assert_generates "/#{base}/user/login", controller: "pet_store/user/user", action: "login"
    assert_generates "/#{base}/user/logout", controller: "pet_store/user/user", action: "logout"

    assert_generates "/#{base}/user/:id", controller: "pet_store/user", action: :show, id: ":id"
    assert_generates "/#{base}/user/:id", controller: "pet_store/user", action: :update, id: ":id"
    assert_generates "/#{base}/user/:id", controller: "pet_store/user", action: :destroy, id: ":id"
  end
end
