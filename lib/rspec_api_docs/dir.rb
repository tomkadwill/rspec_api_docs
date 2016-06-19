class RspecApiDocs::Dir
  def self.find_or_create_api_docs_folder_in(path)
    api_docs_folder_path = File.join(path, '/api_docs/')
    Dir.mkdir(api_docs_folder_path) unless Dir.exists?(api_docs_folder_path)

    api_docs_folder_path
  end
end
