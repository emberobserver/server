class AssetSizeParser
  def initialize(file_contents)
    @file_contents = file_contents
  end

  def asset_size_json
    file_contents.sub!(/^(.*?)\n/, '') until file_contents.starts_with? '{'
    JSON.parse(file_contents)
  end

  attr_reader :file_contents
end
