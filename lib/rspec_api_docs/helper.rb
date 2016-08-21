class RspecApiDocs::Helper
  def self.file
    root_path = Rails.root.to_s.gsub('/rails', '')
    file = File.join(root_path, "apiary.apib")
  end

  def self.running_api_specs?(config, example = nil)
    files_to_run = config.instance_variable_get(:@files_or_directories_to_run)

    return false unless files_to_run == ["spec/controllers/api/"]
    return false unless is_example_an_api_spec?(example) if example

    return true
  end

  private

  def self.is_example_an_api_spec?(example)
    !!example.metadata[:file_path].match(/api\/v\d*/)
  end
end
