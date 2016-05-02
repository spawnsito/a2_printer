require "serial_connection"
require "bitmap"
require "print_mode"
require "barcode"
require "format"
require "control"

class A2Printer

  ESC_SEQUENCE = 27
  LINE_FEED = 10
  CARRIAGE_RETURN = "\n"
  NOT_ALLOWED_CHAR = 0x13

  MAXIMUM_WIDTH = 384

  def initialize(connection)
    @connection = connection
    @print_mode = PrintMode.new @connection
    @barcode = Barcode.new @connection
    @format = Format.new @connection
    @control = Control.new @connection
  end

  def begin(heat_time)
    reset
    set_parameters heat_time
    modify_density(calculate_density_setting)
  end

  def reset_formatting
    online
    normal
    reset
    set_default_heights
  end

  def feed(lines=1)
    lines.times { line_feed }
  end

  def feed_rows(rows = 0)
    write_bytes(ESC_SEQUENCE, 74, rows)
  end

  def flush
    write_bytes(12)
  end

  def test_page
    write_bytes(18, 84)
  end

  def print(string)
    string.bytes { |char_as_byte| write(char_as_byte) }
  end

  def println(string)
    print(string + CARRIAGE_RETURN)
  end

  def write(char)
    return if not_allowed? char
    write_bytes(char)
  end

  def print_bitmap(*args)
    bitmap = obtain_bitmap *args

    return if bitmap.wider_than? MAXIMUM_WIDTH
    bitmap.print
  end

  def set_barcode_height(height)
    @barcode.set_height height
  end

  def print_barcode(text, type)
    @barcode.print text, type
  end

  def set_default
    reset_formatting
  end

  private

  def line_feed
    write(LINE_FEED)
  end

  def set_default_heights
    default_for_line = 32
    default_for_barcode = 50
    set_line_height(default_for_line)
    set_barcode_height(default_for_barcode)
  end

  def modify_density setting
    write_bytes(18, 35)
    write_bytes(setting)
  end

  def calculate_density_setting
    density = 15
    break_time = 15
    (density << 4) | break_time
  end

  def not_allowed? char
    char == NOT_ALLOWED_CHAR
  end

  def obtain_bitmap *args
    only_source_provided = (args.size == 1)

    if only_source_provided
      source = args[0]
      bitmap = Bitmap.from_source @connection, source
    else
      bitmap = Bitmap.new @connection, *args
    end
    bitmap
  end

  def method_missing(method, *args)
    [@connection, @control, @format, @print_mode].each do |property|
      if property.respond_to?(method)
        return property.send(method, *args)
      end
    end

    puts "Method #{m} not found."

  end
end
