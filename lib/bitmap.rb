class Bitmap

    MAX_BYTE = 255
    def self.from_source source
      data = obtain_data source
      width = obtain_width data
      height = obtain_heigth data
      new(width, height, source)
    end

    def initialize(width, height, source)
        set_source(source)
        @width = width
        @height = height
    end

    def wider_than? width
      @width > width
    end

    def print connection
      row_start = 0
      width_in_bytes = @width / 8

      while row_start < @height do
        chunk_height = calculate_chunk_height row_start
        bytes = prepare_image width_in_bytes, chunk_height

        start_print connection
        set_size chunk_height, width_in_bytes, connection
        print_image connection, *bytes
        row_start += MAX_BYTE
      end
    end

    private

    def prepare_image width, height
      (0...(width * height)).map { @data.getbyte }
    end

    def calculate_chunk_height row_start
      ((@height - row_start) > MAX_BYTE) ? MAX_BYTE : (@height - row_start)

      chunk_height = @height - row_start

      if (chunk_height) > MAX_BYTE)
        MAX_BYTE
      end
      chunk_height
    end

    def start_print connection
      connection.write_bytes(18, 42)
    end

    def set_size height, width, connection
      connection.write_bytes(height, width)
    end

    def print_image connection, *bytes
      connection.write_bytes(*bytes)
    end

    def self.obtain_value data
      tmp = data.getbyte
      value = (data.getbyte << 8) + tmp
      value
    end

    def self.obtain_data source
      if source.respond_to?(:getbyte)
        data = source
      else
        data = StringIO.new(source.map(&:chr).join)
      end
      data
    end

    def self.obtain_heigth data
      obtain_value data
    end

    def self.obtain_width data
      obtain_value data
    end

    def set_source(source)
      if source.respond_to?(:getbyte)
        @data = source
      else
        @data = StringIO.new(source.map(&:chr).join)
      end
    end

    def extract_width_and_height_from_data
      tmp = @data.getbyte
      @width = (@data.getbyte << 8) + tmp
      tmp = @data.getbyte
      @height = (@data.getbyte << 8) + tmp
    end
  end
