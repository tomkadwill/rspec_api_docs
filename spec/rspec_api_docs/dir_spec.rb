require 'spec_helper'

describe RspecApiDocs::Helper do
  let(:file_path) { 'spec/fixtures' }
  let(:api_docs_path) { 'spec/fixtures/api_docs' }
  let(:root_path) { 'home/rails' }
  let(:rails) { double(:rails, root: root_path) }

  describe '.file' do
    it 'returns file path' do
      stub_const("Rails", rails)
      expect(described_class.file).to eq('home/apiary.apib')
    end
  end

  describe '.running_api_specs?' do
    let(:config) { double(:config) }

    it 'returns true if running api specs' do
      config.instance_variable_set(:@files_or_directories_to_run, ["spec/controllers/api/"])
      expect(described_class.running_api_specs?(config)).to eq(true)
    end

    it 'returns false if not running api specs' do
      config.instance_variable_set(:@files_or_directories_to_run, ["spec/"])
      expect(described_class.running_api_specs?(config)).to eq(false)
    end
  end

end
