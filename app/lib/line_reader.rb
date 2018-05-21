# frozen_string_literal: true

class LineReader
  def retrieve_context(filename, line_number)
    from_line = line_number - 3
    from_line = 1 if from_line < 1
    to_line = line_number + 3

    lines = IO.readlines(filename, "\n")
    lines[from_line - 1..to_line - 1].zip(from_line..to_line)
  end
end
