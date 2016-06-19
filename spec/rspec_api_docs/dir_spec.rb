require 'spec_helper'

describe RspecApiDocs::Dir do
  let(:subject) { RspecApiDocs::Dir }
  let(:file_path) { 'spec/fixtures' }
  let(:api_docs_path) { 'spec/fixtures/api_docs' }

  after(:each) do
    Dir.rmdir(api_docs_path) if Dir.exists?(api_docs_path)
  end

  it 'creates api docs folder' do
    subject.find_or_create_api_docs_folder_in(file_path)
    expect(Dir.exists?(api_docs_path)).to eq(true)
  end
end
