require 'open3'

class SearchEngine

  def query(term, options={})
    addon_dir = options[:directory]
    regex_enabled = !!options[:regex]

    search_term = search_term(term, regex_enabled)
    raw_results = Open3.capture2(*command(search_term, addon_dir))
    raw_results.first.split("\n")
  end

  private

  def search_term(term, regex_enabled)
    regex_enabled ? term : Regexp.escape(term)
  end

  def command(search_term, addon_dir)
    if addon_dir
      ['csearch', '-f', addon_dir, '-n', search_term]
    else
      ['csearch', '-l', search_term]
    end
  end

end
