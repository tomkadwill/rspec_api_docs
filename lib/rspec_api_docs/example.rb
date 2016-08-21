class RspecApiDocs::Example

  attr_accessor :example, :files_to_run, :config, :request, :response, :file

  def initialize(example, config, request, response, file)
    @example = example
    @config = config
    @files_to_run = config.instance_variable_get(:@files_or_directories_to_run)
    @request = request
    @response = response
    @file = file || RspecApiDocs::Helper.file
  end

  def generate
    return unless has_request?

    if response
      file_name = request.path_parameters[:controller].gsub(/\//, '_').gsub('api_', '')

      id_symbol = request.path_parameters.keys.find{|k| k.match /id/}
      optional_param = request.path_parameters[id_symbol] ? "/{:#{id_symbol}}" : ""
      action = "#{request.request_method} #{request.path_parameters[:controller]}#{optional_param}"

      collection = action.match(/(POST|GET|PATCH|DELETE) (portal\/api|api)\/v\d*\/(.*)/)[3]
      version_and_collection = action.match(/(POST|GET|PATCH|DELETE) (portal\/api|api)(.*)/)[3]

      action_title = "#{collection.capitalize} #{request.path_parameters[:action].capitalize} [#{request.method}]"
      File.open(file, 'a') do |f|
        if File.zero?(File.join(file))
          f.write "FORMAT: 1A\n"
          f.write "HOST: https://qa1.google.co.uk/api\n\n"

          f.write "# #{collection.capitalize}\n\n"

          f.write "description blah blah blah\n\n"
        end

        # skip if the action is already defined
        return if File.read(File.join(file)).include?(action_title)

        f.write "## #{collection.capitalize} collection [#{version_and_collection}]\n\n"

        f.write "### #{action_title}\n\n"

        # Request
        request_body = request.env["action_dispatch.request.request_parameters"]
        authorization_header = request.env ? request.env['Authorization'] : request.headers['Authorization']

        if request_body.present? || authorization_header.present?
          f.write "+ Request #{request.content_type}\n\n"

          # Request Body
          if request_body.present?
            f.write "+ Body\n\n".indent(4)
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

  private

  def has_request?
    request && request.try(:path_parameters)
  end
end
