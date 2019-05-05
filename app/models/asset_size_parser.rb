# frozen_string_literal: true

class AssetSizeParser
  class ParseError < StandardError ; end

  def initialize(file_contents)
    @file_contents = file_contents
  end

  def asset_size_json
    normalized_contents = file_contents.dup
    raise ParseError unless normalized_contents.include? '{'
    normalized_contents.sub!(/^(.*?)\n/, '') until normalized_contents.starts_with? '{'
    begin
      JSON.parse(normalized_contents)
    rescue
      raise ParseError
    end
  end

  attr_reader :file_contents
end
