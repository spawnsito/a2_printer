class Barcode

  def initialize connection
    @connection = connection
  end
  def set_height(height)
    @connection.write_bytes(29, 104, height)
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

  def print(text, type)
    set_type type
    print text
    end_print
  end

  private
  def set_type type
    @connection.write_bytes(29, 107, type)
  end

  def print text
    text.bytes { |b| @connection.write(b) }
  end

  def end_print
    @connection.write(0)
  end
end

