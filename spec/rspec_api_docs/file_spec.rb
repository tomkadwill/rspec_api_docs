require 'spec_helper'
require 'fileutils'

describe RspecApiDocs::File do
  let(:subject) { RspecApiDocs::File }
  let(:files) { ['v1_foo.txt', 'v2_bar.txt'] }
  let(:existing_file) { "spec/fixtures/api_docs/v1_baz.txt" }
  let(:api_docs_folder_path) { 'spec/fixtures/api_docs' }

  before(:each) do
    Dir.mkdir('spec/fixtures/api_docs') unless Dir.exists?('spec/fixtures/api_docs')
    FileUtils.touch(existing_file)
  end

  after(:each) do
    File.delete(existing_file)
    Dir.rmdir('spec/fixtures/api_docs')
  end

  describe "when RSpec finds files" do
    it 'finds files to remove' do
      rspec_api_docs_files = subject.files_to_remove(files, api_docs_folder_path)
      expect(rspec_api_docs_files).to eq(files)
    end
  end

  describe "when RSpec doesn't find files" do
    let(:files) { [existing_file] }

    it 'finds files to remove' do
      rspec_api_docs_files = subject.files_to_remove([], api_docs_folder_path)
      expect(rspec_api_docs_files).to eq(files)
    end
  end
end
