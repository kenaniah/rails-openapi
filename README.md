# Rails::Openapi

Provides mountable Rails engines that can be used to route and serve your APIs from their OpenAPI schema specifications.

OpenAPI schema versions 3.0 and newer are supported. For more information about the OpenAPI specification, see https://oai.github.io/Documentation/introduction.html.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
    $ bundle add rails-openapi
```

## Usage

Define your OpenAPI schemas and mount the engines within your Rails application's routes:

```ruby
# config/routes.rb
Rails.application.routes.draw do

  # Mount at /api/stripe using an engine namespace of Api::Stripe::
  namespace :api do
    Rails::Openapi::Engine(namespace: "Api::Stripe", schema: File.read("test/schemas/stripe-api.yaml")), at: :stripe, as: :stripe_api
  end

end
```

For example, when loading [Stripe's OpenAPI Schema](https://raw.githubusercontent.com/stripe/openapi/master/openapi/spec3.yaml), Rails would generate the following routes:

```
                    Prefix        Verb     URI Pattern                                          Controller#Action
                 api_stripe_api            /api/stripe                                          Api::Stripe::Engine

Routes for Api::Stripe::Engine:
                 openapi_schema   GET      /openapi.json                                        Rails::Openapi::Engine
             v1_3d_secure_index   POST     /v1/3d_secure(.:format)                              api/stripe/v1/3d_secure#create
                   v1_3d_secure   GET      /v1/3d_secure/:id(.:format)                          api/stripe/v1/3d_secure#show
             account_v1_account   DELETE   /v1/account/account(.:format)                        api/stripe/v1/account#account
       v1_account_bank_accounts   POST     /v1/account/bank_accounts(.:format)                  api/stripe/v1/account/bank_accounts#create
        v1_account_bank_account   GET      /v1/account/bank_accounts/:id(.:format)              api/stripe/v1/account/bank_accounts#show
                                  DELETE   /v1/account/bank_accounts/:id(.:format)              api/stripe/v1/account/bank_accounts#destroy
        v1_account_capabilities   GET      /v1/account/capabilities(.:format)                   api/stripe/v1/account/capabilities#index
                                  POST     /v1/account/capabilities(.:format)                   api/stripe/v1/account/capabilities#create
          v1_account_capability   GET      /v1/account/capabilities/:id(.:format)               api/stripe/v1/account/capabilities#show
   v1_account_external_accounts   GET      /v1/account/external_accounts(.:format)              api/stripe/v1/account/external_accounts#index
                                  POST     /v1/account/external_accounts(.:format)              api/stripe/v1/account/external_accounts#create
    v1_account_external_account   GET      /v1/account/external_accounts/:id(.:format)          api/stripe/v1/account/external_accounts#show
                                  DELETE   /v1/account/external_accounts/:id(.:format)          api/stripe/v1/account/external_accounts#destroy
         login_links_v1_account   POST     /v1/account/login_links(.:format)                    api/stripe/v1/account/account#login_links
              v1_account_people   GET      /v1/account/people(.:format)                         api/stripe/v1/account/people#index
                                  POST     /v1/account/people(.:format)                         api/stripe/v1/account/people#create
              v1_account_person   GET      /v1/account/people/:id(.:format)                     api/stripe/v1/account/people#show
                                  DELETE   /v1/account/people/:id(.:format)                     api/stripe/v1/account/people#destroy
             v1_account_persons   GET      /v1/account/persons(.:format)                        api/stripe/v1/account/persons#index
                                  POST     /v1/account/persons(.:format)                        api/stripe/v1/account/persons#create
                                  GET      /v1/account/persons/:id(.:format)                    api/stripe/v1/account/persons#show
                                  DELETE   /v1/account/persons/:id(.:format)                    api/stripe/v1/account/persons#destroy
                     v1_account   GET      /v1/account(.:format)                                api/stripe/v1/account#show
                                  POST     /v1/account(.:format)                                api/stripe/v1/account#create
                                  ...                                                         ...
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rails-openapi.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
