require 'spec_helper'
require 'json'

describe RspecApiDocs::Example do

  let(:rspec_api_docs) { described_class.new(example, config, request, response, filepath) }
  let(:example) { double(:example, metadata: metadata) }
  let(:metadata) { {file_path: 'api/v1/'} }
  let(:config) { double(:config) }
  let(:request_env) { {"action_dispatch.request.request_parameters" => request_body, 'Authorization' => double(present?: false)} }
  let(:files_to_run) { ["spec/controllers/api/"] }
  let(:response) { double(:response, status: 200, content_type: 'application/json', body: response_body) }
  let(:filepath) { File.join("apiary.apib") }
  let(:request) do 
    double(:request, 
           path_parameters: symbolized_path_parameters, 
           request_method: method, 
           method: method, 
           env: request_env,
           content_type: 'application/json')
  end

  before do
    allow(request).to receive(:try).with(:path_parameters).and_return(true)
    allow(config).to receive(:instance_variable_get).with(:@files_or_directories_to_run).and_return(files_to_run)
    allow_any_instance_of(Hash).to receive(:present?).and_return(true)
    allow_any_instance_of(String).to receive(:present?).and_return(true)
  end

  after do
    File.delete(filepath) if File.exists?(filepath)
  end

  describe 'GET request' do
    let(:action) { 'index' }
    let(:method) { 'GET' }
    let(:symbolized_path_parameters) { {controller: 'api/v1/users', action: action} }
    let(:request_body) { double(present?: false) }
    let(:response_body) do
      JSON.generate(
        {name: 'mark', date_of_birth: '1993-09-11'}
      )
    end

    it 'generates API documentation' do
      rspec_api_docs.generate
      file = File.read(File.join(filepath))
      expect(file).to include('FORMAT: 1A')
      expect(file).to include('HOST: https://qa1.google.co.uk/api')
      expect(file).to include('Users')
      expect(file).to include('description blah blah blah')
      expect(file).to include('Users collection [/v1/users]')
      expect(file).to include('Users Index [GET]')
      expect(file).to include('Response 200 application/json')
      expect(file).to include('"name": "mark"')
      expect(file).to include('"date_of_birth": "1993-09-11"')
    end
  end

  describe 'POST request' do
    let(:method) { 'POST' }
    let(:action) { 'create' }
    let(:symbolized_path_parameters) { {user_id: 1, controller: 'api/v1/users', action: action} }
    let(:request_body) do
      {name: 'tom'}
    end
    let(:response_body) do
      JSON.generate(
        {id: 1, name: 'tom'}
      )
    end

    it 'generates API documentation for POST request' do
      rspec_api_docs.generate
      file = File.read(File.join(filepath))
      expect(file).to include('FORMAT: 1A')
      expect(file).to include('HOST: https://qa1.google.co.uk/api')
      expect(file).to include('Users')
      expect(file).to include('description blah blah blah')
      expect(file).to include('Users/{:user_id} collection [/v1/users/{:user_id}]')
      expect(file).to include('Users/{:user_id} Create [POST]')
      expect(file).to include('Request')
      expect(file).to include('Body')
      expect(file).to include('"name": "tom"')
      expect(file).to include('Response 200 application/json')
      expect(file).to include('"id": 1')
      expect(file).to include('"name": "tom"')
    end
  end
end

class String
  def indent(n)
    self
  end
end
