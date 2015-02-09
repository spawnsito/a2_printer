require "serial_connection"
require "bitmap"

class A2Printer

  DEFAULT_RESOLUTION = 7
  ESC_SEQUENCE = 27
  CONTROL_PARAMETERS = 55
  LINE_FEED = 10
  CARRIAGE_RETURN = "\n"
  NOT_ALLOWED_CHAR = 0x13

  def initialize(connection)
    @connection = connection
    @print_mode = PrintMode.new @connection
  end

  def begin(heat_time)
    reset()
    set_control_parameters heat_time
    modify_density(calculate_density_setting)
  end

  def reset
    write_bytes(ESC_SEQUENCE, 64)
  end

  def reset_formatting
    online
    normal
    underline_off
    justify(:left)

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


  # Character commands

  INVERSE_MASK = (1 << 1)
  UPDOWN_MASK = (1 << 2)
  BOLD_MASK = (1 << 3)
  DOUBLE_HEIGHT_MASK = (1 << 4)
  DOUBLE_WIDTH_MASK = (1 << 5)
  STRIKE_MASK = (1 << 6)

  def set_print_mode(mask)
    @print_mode |= mask;
    write_print_mode
  end

  def unset_print_mode(mask)
    @print_mode &= ~mask;
    write_print_mode
  end

  def write_print_mode
    write_bytes(ESC_SEQUENCE, 33, @print_mode)
  end

  # This will reset bold, inverse, strikeout, upside down and font size
  # It does not reset underline, justification or line height
  def normal
    write_print_mode
  end

  def inverse_on
    set_print_mode(INVERSE_MASK)
  end

  def inverse_off
    unset_print_mode(INVERSE_MASK)
  end

  def upside_down_on
    set_print_mode(UPDOWN_MASK);
  end

  def upside_down_off
    unset_print_mode(UPDOWN_MASK);
  end

  def double_height_on
    set_print_mode(DOUBLE_HEIGHT_MASK)
  end

  def double_height_off
    unset_print_mode(DOUBLE_HEIGHT_MASK)
  end

  def double_width_on
    set_print_mode(DOUBLE_WIDTH_MASK)
  end

  def double_width_off
    unset_print_mode(DOUBLE_WIDTH_MASK)
  end

  def strike_on
    set_print_mode(STRIKE_MASK)
  end

  def strike_off
    unset_print_mode(STRIKE_MASK)
  end

  def bold_on
    set_print_mode(BOLD_MASK)
  end

  def bold_off
    unset_print_mode(BOLD_MASK)
  end

  def set_size(size)
    byte = case size
    when :small
      0
    when :medium
      10
    when :large
      25
    end

    write_bytes(29, 33, byte, 10)
  end

  # Underlines of different weights can be produced:
  # 0 - no underline
  # 1 - normal underline
  # 2 - thick underline
  def underline_on(weight=1)
    write_bytes(ESC_SEQUENCE, 45, weight)
  end

  def underline_off
    underline_on(0)
  end

  def justify(position)
    byte = case position
    when :left
      0
    when :center
      1
    when :right
      2
    end

    write_bytes(0x1B, 0x61, byte)
  end

  def print_bitmap(*args)
    bitmap = Bitmap.new(*args)
    return if (bitmap.width > 384) # maximum width of the printer
    bitmap.each_block do |w, h, bytes|
      write_bytes(18, 42)
      write_bytes(h, w)
      write_bytes(*bytes)
    end
  end

  # Barcodes

  def set_barcode_height(val)
    # default is 50
    write_bytes(29, 104, val)
  end

  UPC_A   = 0
  UPC_E   = 1
  EAN13   = 2
  EAN8    = 3
  CODE39  = 4
  I25     = 5
  CODEBAR = 6
  CODE93  = 7
  CODE128 = 8
  CODE11  = 9
  MSI     = 10

  def print_barcode(text, type)
    write_bytes(29, 107, type) # set the type first
    text.bytes { |b| write(b) }
    write(0) # Terminator
  end

  # Take the printer offline. Print commands sent after this will be
  # ignored until `online` is called
  def offline
    write_bytes(ESC_SEQUENCE, 61, 0)
  end

  # Take the printer back online. Subsequent print commands will be
  # obeyed.
  def online
    write_bytes(ESC_SEQUENCE, 61, 1)
  end

  # Put the printer into a low-energy state immediately
  def sleep
    sleep_after(0)
  end

  # Put the printer into a low-energy state after the given number
  # of seconds
  def sleep_after(seconds)
    write_bytes(ESC_SEQUENCE, 56, seconds)
  end

  # Wake the printer from a low-energy state. This command will wait
  # for 50ms (as directed by the datasheet) before allowing further
  # commands to be send.
  def wake
    write_bytes(255)
    # delay(50) # ?
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

  def set_heat_conditions heat_time
    heat_time = 150 if heat_time.nil?
    heat_interval = 50
    write_bytes(heat_time)
    write_bytes(heat_interval)
  end

  def set_default_resolution
    write_bytes(DEFAULT_RESOLUTION)
  end

  def set_control_parameters heat_time
    write_bytes(ESC_SEQUENCE, CONTROL_PARAMETERS)
    set_default_resolution
    set_heat_conditions heat_time
  end

  def not_allowed? char
    char == NOT_ALLOWED_CHAR
  end

  def write_bytes(*bytes)
    bytes.each { |b| @connection.putc(b) }
  end

end
