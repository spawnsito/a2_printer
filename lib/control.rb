class Control

  ESC_SEQUENCE = 27

  def initialize(connection)
    @connection = connection
  end

  def offline
    @connection.write_bytes(ESC_SEQUENCE, 61, 0)
  end

  def online
    @connection.write_bytes(ESC_SEQUENCE, 61, 1)
  end

  def sleep
    sleep_after(0)
  end

  def wake
    @connection.write_bytes(255)
  end

  def reset
    @connection.write_bytes(ESC_SEQUENCE, 64)
  end

  private

  def sleep_after(seconds)
    @connection.write_bytes(ESC_SEQUENCE, 56, seconds)
  end

end