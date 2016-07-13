require 'rspec/core'
require "rspec_api_docs/version"
require "rspec_api_docs/helper"

RSpec.configure do |config|
  config.before(:suite) do
    next unless RspecApiDocs::Helper.running_api_specs?(config)

    file = RspecApiDocs::Helper.file
    File.new(file,  "w+") unless File.exists?(file)
  end

  config.after(:each) do |example|
    begin
      next unless RspecApiDocs::Helper.running_api_specs?(config)
      next unless example.metadata[:file_path].match(/api\/v\d*/)
      next unless request && request.try(:symbolized_path_parameters)

      if response
        example_group = example.metadata[:example_group]
        example_groups = []

        while example_group
          example_groups << example_group
          example_group = example_group[:example_group]
        end

        file_name = request.symbolized_path_parameters[:controller].gsub(/\//, '_').gsub('api_', '')

        id_symbol = request.symbolized_path_parameters.keys.find{|k| k.match /id/}
        optional_param = request.symbolized_path_parameters[id_symbol] ? "/{:#{id_symbol}}" : ""
        action = "#{request.request_method} #{request.symbolized_path_parameters[:controller]}#{optional_param}"

        file = RspecApiDocs::Dir.file

        collection = action.match(/(POST|GET|PATCH|DELETE) (portal\/api|api)\/v\d*\/(.*)/)[3]
        version_and_collection = action.match(/(POST|GET|PATCH|DELETE) (portal\/api|api)(.*)/)[3]

        action_title = "#{collection.capitalize} #{request.symbolized_path_parameters[:action].capitalize} [#{request.method}]"
        File.open(file, 'a') do |f|
          if File.zero?(File.join(file))
            f.write "FORMAT: 1A\n"
            f.write "HOST: https://qa1.google.co.uk/api\n\n"

            f.write "# #{collection.capitalize}\n\n"

            f.write "description blah blah blah\n\n"
          end

          # skip if the action is already defined
          next if File.read(File.join(file)).include?(action_title)

          f.write "## #{collection.capitalize} collection [#{version_and_collection}]\n\n"

          f.write "### #{action_title}\n\n"

          # Request
          request_body = request.env["action_dispatch.request.request_parameters"]
          authorization_header = request.env ? request.env['Authorization'] : request.headers['Authorization']

          if request_body.present? || authorization_header.present?
            f.write "+ Request #{request.content_type}\n\n"

            # Request Body
            if request_body.present?# && request.content_type == 'application/json'
              f.write "+ Body\n\n".indent(4)# if authorization_header
              f.write "#{JSON.pretty_generate(JSON.parse(JSON.pretty_generate(request_body)))}\n\n".indent(authorization_header ? 12 : 8)
            end
          end

          # Response
          f.write "+ Response #{response.status} #{response.content_type}\n\n"

          if response.body.present? && response.content_type =~ /application\/json/
            f.write "#{JSON.pretty_generate(JSON.parse(response.body))}\n\n".indent(8)
          end
        end unless response.status.to_s =~ /4\d\d/ || response.status.to_s =~ /3\d\d/
      end
    rescue => e
      # Just carry on as normal to that errors here don't iterfere with tests
      Rails.logger.info "rspec_api_docs error: #{e}"
    end
  end
end
