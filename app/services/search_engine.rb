class SearchEngine

  def query(term, addon_dir = nil)
    if addon_dir
      command = "csearch -f #{addon_dir} -i -n '#{term}'"
    else
      command = "csearch -i -n '#{term}'"
    end
    raw_results = `#{command}`
    raw_results.split("\n")
  end

end
