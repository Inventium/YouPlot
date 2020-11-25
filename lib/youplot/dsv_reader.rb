# frozen_string_literal: true

require 'csv'

module YouPlot
  # Read and interpret Delimiter-separated values format file or stream.
  module DSVReader
    module_function

    def input(input, delimiter, headers, transpose)
      arr = parse_as_csv(input, delimiter)
      headers = get_headers(arr, headers, transpose)
      series = get_series(arr, headers, transpose)
      if headers.nil?
        Data.new(headers, series)
      else
        if headers.include?(nil)
          warn "\e[35mHeaders contains nil in it.\e[0m"
        elsif headers.include? ''
          warn "\e[35mHeaders contains \"\" in it.\e[0m"
        end
        h_size = headers.size
        s_size = series.size
        if h_size == s_size
          Data.new(headers, series)
        elsif h_size > s_size
          warn "\e[35mThe number of headers is greater than the number of series.\e[0m"
          exit 1
        elsif h_size < s_size
          warn "\e[35mThe number of headers is less than the number of series.\e[0m"
          exit 1
        end
      end
    end

    def parse_as_csv(input, delimiter)
      CSV.parse(input, col_sep: delimiter)
         .delete_if do |i|
           i == [] or i.all? nil
         end
    end

    # Transpose different sized ruby arrays
    # https://stackoverflow.com/q/26016632
    def transpose2(arr)
      Array.new(arr.map(&:length).max) { |i| arr.map { |e| e[i] } }
    end

    def get_headers(arr, headers, transpose)
      if headers
        if transpose
          arr.map(&:first)
        else
          arr[0]
        end
      end
    end

    def get_series(arr, headers, transpose)
      if transpose
        if headers
          arr.map { |row| row[1..-1] }
        else
          arr
        end
      elsif headers
        transpose2(arr[1..-1])
      else
        transpose2(arr)
      end
    end
  end
end
