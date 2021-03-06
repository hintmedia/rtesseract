# frozen_string_literal: true

class RTesseract
  module Box
    extend RTesseract::Base

    class << self
      def run(source, errors, options)
        options.tessedit_create_hocr = 1

        RTesseract::Command.new(source, temp_file, errors, options).run

        parse(File.read(temp_file('.hocr')))
      end

      def parse(content)
        content.lines.map { |line| parse_line(line) }.compact
      end

      def parse_line(line)
        return unless line.match?(/oc(rx|r)_word/)

        word = line.match(/(?<=>)(.*?)(?=<)/).to_s

        return if word.strip == ''

        word_info(word, parse_position(line))
      end

      def word_info(word, positions)
        {
          word: word,
          x_start: positions[1].to_i,
          y_start: positions[2].to_i,
          x_end: positions[3].to_i,
          y_end: positions[4].to_i
        }
      end

      def parse_position(line)
        line.match(/(?<=title)(.*?)(?=;)/).to_s.split(' ')
      end
    end
  end
end
