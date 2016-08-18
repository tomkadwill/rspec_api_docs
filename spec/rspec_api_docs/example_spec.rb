require 'spec_helper'

describe RspecApiDocs::Example do
  let(:metadata) { {file_path: 'api/v1/'} }
  let(:example) { double(:example, metadata: metadata) }
  let(:files_to_run) { ["spec/controllers/api/"] }
  let(:config) { double(:config) }
  let(:symbolized_path_parameters) { {controller: 'api/v1/users', action: 'index'} }
  let(:request_env) { {"action_dispatch.request.request_parameters" => double(present?: false), 'Authorization' => double(present?: false)} }
  let(:request) { double(:request, path_parameters: symbolized_path_parameters, request_method: 'GET', method: 'GET', env: request_env) }
  let(:response) { double(:response, status: 200, content_type: 'application/json', body: double(present?: false)) }
  let(:filepath) { File.join("apiary.apib") }
  let(:rspec_api_docs) { described_class.new(example, config, request, response, filepath) }

  before do
    allow(request).to receive(:try).with(:path_parameters).and_return(true)
    allow(config).to receive(:instance_variable_get).with(:@files_or_directories_to_run).and_return(files_to_run)
  end

  after do
    File.delete(filepath) if File.exists?(filepath)
  end

  it 'generates API documentation for an RSpec example' do
    rspec_api_docs.generate
    file = File.read(File.join(filepath))
    expect(file).to include('FORMAT: 1A')
    expect(file).to include('HOST: https://qa1.google.co.uk/api')
    expect(file).to include('Users')
    expect(file).to include('description blah blah blah')
    expect(file).to include('Users collection [/v1/users]')
    expect(file).to include('Users Index [GET]')
    expect(file).to include('Response 200 application/json')
    #expect(file).to include("name: 'mark'")
    #expect(file).to include("date_of_birth: '1993-09-11'")
  end
end
