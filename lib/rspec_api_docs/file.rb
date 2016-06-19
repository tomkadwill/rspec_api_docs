class RspecApiDocs::File
  def self.files_to_remove(files, api_docs_folder_path)
    if files == []
      Dir.glob(File.join(api_docs_folder_path, '*'))
    else
      files
    end
  end
end
