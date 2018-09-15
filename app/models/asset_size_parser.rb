# frozen_string_literal: true

class AssetSizeParser
  def initialize(file_contents)
    @file_contents = file_contents
  end

  def asset_size_json
    normalized_contents = file_contents.dup
    normalized_contents.sub!(/^(.*?)\n/, '') until normalized_contents.starts_with? '{'
    JSON.parse(normalized_contents)
  end

  attr_reader :file_contents
end
