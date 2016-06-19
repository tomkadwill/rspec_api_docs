require 'rspec/core'
require "rspec_api_docs/version"
require "rspec_api_docs/dir"
require "rspec_api_docs/file"

RSpec.configure do |config|
  config.before(:suite) do
    api_docs_folder_path = RspecApiDocs::Dir.find_or_create_api_docs_folder_in(Rails.root)

    RspecApiDocs::File.files_to_remove(config.files_to_run, api_docs_folder_path).each do |f|
      next unless f.match(/api\/v*.\/.*/)

      file = f.match(/api\/v*.\/.*/)[0].gsub('/', '_').gsub('api_', '').gsub('_controller_test.rb', '.txt')
      file = "api_docs/#{file}"
      File.delete(file) if File.exists?(file)
    end
  end

  config.after(:each) do |example|
    begin
      # exit unless this is under api/v*
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

        if defined? Rails
          file = File.join(Rails.root, "/api_docs/#{file_name}.txt")
        else
          file = File.join(File.expand_path('.'), "/api_docs/#{file_name}.txt")
        end

        collection = action.match(/(POST|GET|PATCH|DELETE) (portal\/api|api)\/v\d*\/(.*)/)[3]
        File.open(file, 'a') do |f|
          if File.zero?(File.join(Rails.root, "/api_docs/#{file_name}.txt"))
            f.write "FORMAT: 1A\n"
            f.write "HOST: https://qa1.google.co.uk/api\n\n"

            f.write "# #{collection.capitalize}\n\n"

            f.write "description blah blah blah\n\n"
          end

          # skip if the action is already defined
          next if File.read(File.join(Rails.root, "/api_docs/#{file_name}.txt")).include?(action)

          f.write "## #{collection.capitalize} collection [/#{collection}]\n\n"

          f.write "### #{collection.capitalize} #{request.symbolized_path_parameters[:action].capitalize} [#{request.method}]\n\n"

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
