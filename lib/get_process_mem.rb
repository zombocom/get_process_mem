require 'pathname'

# Cribbed from Unicorn Worker Killer, thanks!
class GetProcessMem
  KB_TO_BYTE = 1024          # 2**10   = 1024
  MB_TO_BYTE = 1_048_576     # 1024**2 = 1_048_576
  GB_TO_BYTE = 1_073_741_824 # 1024**3 = 1_073_741_824
  CONVERSION = { "kb" => KB_TO_BYTE, "mb" => MB_TO_BYTE, "gb" => GB_TO_BYTE}
  MEM_TYPE   = "rss" # http://en.wikipedia.org/wiki/Resident_set_size
  attr_reader :pid

  def initialize(pid = Process.pid, mem_type = MEM_TYPE)
    @process_file = Pathname.new "/proc/#{pid}/status"
    @pid          = pid
    @linux        = @process_file.exist?
    self.mem_type = mem_type
  end

  def linux?
    @linux
  end

  def bytes
    memory =   linux_memory if linux?
    memory ||= ps_memory
  end

  def kb(b = bytes)
    b.to_f/KB_TO_BYTE
  end

  def mb(b = bytes)
    b.to_f/MB_TO_BYTE
  end

  def gb(b = bytes)
    b.to_f/GB_TO_BYTE
  end

  def refresh
    @bytes = nil
  end

  def inspect
    b = bytes
    "#<#{self.class}:0x%08x @mb=#{mb b } @gb=#{gb b } @kb=#{kb b } @bytes=#{b}>" % (object_id * 2)
  end

  def mem_type
    @mem_type
  end

  def mem_type=(mem_type)
    @mem_type = mem_type.downcase
  end

  private

  # Pull memory from `ps` command, takes more resources and can freeze
  # in low memory situations
  def ps_memory
    KB_TO_BYTE * `ps -o #{mem_type_for_ps}= -p #{pid}`.to_i
  end

  def mem_type_for_ps
    mem_type
  end

  def mem_type_for_linux
    case mem_type
    when 'rss'
      'VmRSS'
    end
  end

  # linux stores memory info in a file "/proc/#{pid}/status"
  # If it's available it uses less resources than shelling out to ps
  def linux_memory
    line = @process_file.read.each_line.detect {|line| line.include? mem_type_for_linux }
    return unless line
    return unless (name, value, unit = line.split(nil)).length == 3
    multiplier = CONVERSION[unit.downcase]
    multiplier * value.to_i
  end
end

GetProcessMem
