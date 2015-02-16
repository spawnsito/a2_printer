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
        chunk_height = ((@height - row_start) > MAX_BYTE) ? MAX_BYTE : (@height - row_start)
        bytes = (0...(width_in_bytes * chunk_height)).map { @data.getbyte }


        start_print connection
        set_size chunk_height, width_in_bytes, connection
        connection.write_bytes(*bytes)
        row_start += MAX_BYTE
      end
    end

    private
    def start_print connection
      connection.write_bytes(18, 42)
    end

    def set_size height, width, connection
      connection.write_bytes(height, width)
    end

    def print_image *bytes

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
