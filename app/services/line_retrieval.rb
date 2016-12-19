require 'open3'

class LineRetrieval

  def retrieve_match(filename, line_number)
    from_line = line_number - 3
    from_line = 1 if from_line < 1
    to_line = line_number + 3

    sed_command = "#{from_line},#{to_line}p;#{to_line+1}q"

    lines = Open3.capture2('sed', '-n', sed_command, filename)
    lines.first.split("\n").zip(from_line..to_line)
  end

end
