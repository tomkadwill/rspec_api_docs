class RspecApiDocs::Helper
  def self.file
    root_path = Rails.root.to_s.gsub('/rails', '')
    file = File.join(root_path, "apiary.apib")
  end

  def self.running_api_specs?(config)
    files_to_run = config.instance_variable_get(:@files_or_directories_to_run)
    files_to_run == ["spec/controllers/api/"]
  end
end
