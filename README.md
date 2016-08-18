# RspecApiDocs

Use RspecApiDocs to generate API documentation from your RSpec tests.

**This gem is still a work in progress.**

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec_api_docs'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec_api_docs

Include the `RspecApiDocs` Module inside your `spec_helper.rb`. Eg:

```ruby
# spec_helper.rb

RSpec.configure do |config|
  config.include RspecApiDocs
end
```

## Usage

To generate documentation, just run your API tests. eg:

    $ rspec spec/controllers/api/

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rspec_api_docs. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

