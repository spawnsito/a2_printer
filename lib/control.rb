class Control

  ESC_SEQUENCE = 27
  CONTROL_PARAMETERS = 55
  DEFAULT_RESOLUTION = 7

  def initialize(connection)
    @connection = connection
  end

  def offline
    write_bytes(ESC_SEQUENCE, 61, 0)
  end

  def online
    write_bytes(ESC_SEQUENCE, 61, 1)
  end

  def sleep
    sleep_after(0)
  end

  def wake
    write_bytes(255)
  end

  def reset
    write_bytes(ESC_SEQUENCE, 64)
  end

  def set_parameters heat_time
    write_bytes(ESC_SEQUENCE, CONTROL_PARAMETERS)
    set_default_resolution
    set_heat_conditions heat_time
  end

  private

  def sleep_after(seconds)
    write_bytes(ESC_SEQUENCE, 56, seconds)
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

  def method_missing(method, *args)
      if @connection.respond_to?(method)
        return @connection.send(method, *args)
      else
        puts "Method #{m} not found."
      end
  end
end