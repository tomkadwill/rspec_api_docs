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
      File.open(file, 'a') do |f|
        write_title(f) if File.zero?(File.join(file))

        return if action_already_defined?

        write_collection_and_title(f)

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

  def action
    id_symbol = request.path_parameters.keys.find{|k| k.match /id/}
    optional_param = request.path_parameters[id_symbol] ? "/{:#{id_symbol}}" : ""

    "#{request.request_method} #{request.path_parameters[:controller]}#{optional_param}"
  end

  def collection
    action.match(/(POST|GET|PATCH|DELETE) (portal\/api|api)\/v\d*\/(.*)/)[3]
  end

  def version_and_collection
    action.match(/(POST|GET|PATCH|DELETE) (portal\/api|api)(.*)/)[3]
  end

  def action_title
    "#{collection.capitalize} #{request.path_parameters[:action].capitalize} [#{request.method}]"
  end

  def action_already_defined?
    File.read(File.join(file)).include?(action_title)
  end

  def request_body
    request.env["action_dispatch.request.request_parameters"]
  end

  def authorization_header
    request.env ? request.env['Authorization'] : request.headers['Authorization']
  end

  def write_title(file)
    file.write "FORMAT: 1A\n"
    file.write "HOST: https://qa1.google.co.uk/api\n\n"

    file.write "# #{collection.capitalize}\n\n"

    file.write "description blah blah blah\n\n"
  end

  def write_collection_and_title(f)
    f.write "## #{collection.capitalize} collection [#{version_and_collection}]\n\n"
    f.write "### #{action_title}\n\n"
  end
end
