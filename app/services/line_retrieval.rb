class LineRetrieval

  def retrieve_match(filename, line_number)
    from_line = line_number - 3
    from_line = 1 if from_line < 1

    sed_command = "#{from_line},#{line_number+3}p;#{line_number + 4}q"
    command = ['sed -n', "'#{sed_command}'", filename].join(' ')

    lines = `#{command}`
    lines.split("\n").zip(from_line..line_number + 3)
  end

end
