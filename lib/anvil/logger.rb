# frozen_string_literal: true

class Anvil::Logger < Struct.new(:prefix)
  def info message, category = nil
    puts [timestamp, category, message].compact.join(" ")
  end

  protected

  def timestamp
    "#{Time.now.strftime("%H:%M:%S")} #{prefix}".rjust(40)
  end
end
