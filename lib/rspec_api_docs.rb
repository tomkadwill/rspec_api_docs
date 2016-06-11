require "rspec_api_docs/version"

RSpec.configure do |config|
  config.before(:suite) do
    if defined? Rails
      api_docs_folder_path = File.join(Rails.root, '/api_docs/')
    else
      api_docs_folder_path = File.join(File.expand_path('.'), '/api_docs/')
    end

    Dir.mkdir(api_docs_folder_path) unless Dir.exists?(api_docs_folder_path)

    Dir.glob(File.join(api_docs_folder_path, '*')).each do |f|
      File.delete(f)
    end
  end

  config.after(:each) do |example|
    # exit unless this is under api/v*
    next unless example.metadata[:file_path].match(/api\/v\d*/)
    begin
      next unless request && request.try(:symbolized_path_parameters)
    rescue => e
      # Continue anyway
      next
    end

    if response
      example_group = example.metadata[:example_group]
      example_groups = []

      while example_group
        example_groups << example_group
        example_group = example_group[:example_group]
      end

      file_name = request.symbolized_path_parameters[:controller].gsub(/\//, '_').gsub('api_', '')
      action = "#{request.request_method} #{request.symbolized_path_parameters[:controller]}"

      if defined? Rails
        file = File.join(Rails.root, "/api_docs/#{file_name}.txt")
      else
        file = File.join(File.expand_path('.'), "/api_docs/#{file_name}.txt")
      end

      File.open(file, 'a') do |f|
        if File.zero?(File.join(Rails.root, "/api_docs/#{file_name}.txt"))
          f.write "FORMAT: 1A\n"
          f.write "HOST: https://qa1.google.co.uk/api\n\n"

          f.write "# #{action}\n\n"

          f.write "description blah blah blah\n\n"
        end

        # skip if the action is already defined
        next if File.read(File.join(Rails.root, "/api_docs/#{file_name}.txt")).include?(action)

        collection = action.match(/(POST|GET|PATCH|DELETE) (portal\/api|api)\/v\d*\/(.*)/)[3]
        f.write "## #{collection.capitalize} collection [/#{collection}]\n\n"

        f.write "### #{collection.capitalize} #{request.method.downcase} [#{request.method}]\n\n"

        # Request
        request_body = request.env["action_dispatch.request.request_parameters"]
        authorization_header = request.env ? request.env['Authorization'] : request.headers['Authorization']

        if request_body.present? || authorization_header.present?
          f.write "+ Request #{request.content_type}\n\n"

          # Request Headers
          # if authorization_header.present?
          #   f.write "+ Headers\n\n".indent(4)
          #   f.write "Authorization: #{authorization_header}\n\n".indent(12)
          # end

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
  end
end
