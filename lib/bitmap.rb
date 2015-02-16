class Bitmap

    MAX_CHUNK_SIZE = 255

    def self.from_source connection, source
      data = obtain_data source
      width = obtain_width data
      height = obtain_heigth data
      new(connection, width, height, source)
    end

    def initialize(connection, width, height, source)
        set_source(source)
        @width = width
        @height = height
        @connection = connection
    end

    def wider_than? width
      @width > width
    end

    def print
      row_start = 0
      width_in_bytes = to_bytes @width

      while row_start < @height do
        chunk_height = calculate_chunk_height row_start
        bytes = prepare_image width_in_bytes, chunk_height

        print_chunk chunk_height, width_in_bytes, *bytes
        row_start += MAX_CHUNK_SIZE
      end
    end

    private

    def print_chunk height, width, *bytes
      start_print
      set_size height, width
      print_image *bytes
    end

    def to_bytes width
      width / 8
    end

    def prepare_image width, height
      (0...(width * height)).map { @data.getbyte }
    end

    def calculate_chunk_height row_start
      chunk_height = @height - row_start
      sanitize chunk_height
    end

    def sanitize height
      return MAX_CHUNK_SIZE if height > MAX_CHUNK_SIZE
      height
    end

    def start_print
      @connection.write_bytes(18, 42)
    end

    def set_size height, width
      @connection.write_bytes(height, width)
    end

    def print_image *bytes
      @connection.write_bytes(*bytes)
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
