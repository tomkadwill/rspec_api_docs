require 'rspec/core'
require "rspec_api_docs/version"
require "rspec_api_docs/helper"
require "rspec_api_docs/example"

RSpec.configure do |config|
  config.before(:suite) do
    next unless RspecApiDocs::Helper.running_api_specs?(config)

    file = RspecApiDocs::Helper.file

    # Delete and re-create the file each time
    File.delete(file) if File.exists?(file)
    File.new(file,  "w+") unless File.exists?(file)
  end

  config.after(:each) do |example|
    next unless RspecApiDocs::Helper.running_api_specs?(config, example)

    begin
      RspecApiDocs::Example.new(
        example, 
        config,
        request, 
        response, 
        nil
      ).generate
    rescue => e
      # Just carry on as normal to that errors here don't iterfere with tests
      Rails.logger.info "rspec_api_docs error: #{e}"
    end
  end
end
