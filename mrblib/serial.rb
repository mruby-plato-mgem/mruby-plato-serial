#
# Plato::Serial module
#
module Plato
  module Serial
    @@device = nil
    TMO_READ = 2000

    def self.register_device(device)
      @@device = device
    end

    def self.open(baud, dbits=8, start=1, stop=1, parity=:none)
      raise "Serial device is not registered." unless @@device
      @@device.new(baud, dbits, start, stop, parity)
    end

    def _read; end
    def _write(data); end
    def available; end
    def flush; end
    def close; end

    def read(len=nil, type=@datatype, tmo=@timeout)
      tmo = TMO_READ unless @timeout
      data = []
      re = 0
      tm = Machine.millis + tmo
      while true
        # t = Machine.millis
        v = _read
        if v >= 0
          data << v
          break if len && data.size == len
          # tm = t + 100
          re = 0
        else
          # break if tm > t
          break if tm > Machine.millis
          if data.size > 0
            break if re >= 3
            re += 1
          end
          Machine.delay 1
        end
      end
      data = data.inject('') {|s, c| s << c.chr} if type == :as_string
      data.size > 0 ? data : nil
    end

    def write(data)
      case data
      when Fixnum
        _write(data)
      when Array
        data.each {|v|
          raise TypeError.new "write: Specify an array of integer values (#{data})" unless v.instance_of?(Fixnum)
          raise RangeError.new "write: Specify a value of 0..255 (#{v})" if v < 0 || v > 255
          _write(v)
        }
      when String
        data.each_byte {|v| _write(v)}
      else
        data.to_s.each_byte {|v| _write(v)}
      end
    end

    def getc
      v = _read
      v < 0 ? nil : v.chr
    end

    def putc(data)
      raise TypeError.new "putc: Specify a character (#{data})" unless data.instance_of?(String) 
      _write(data[0].ord)
    end

    def gets(*args)
      rs, limit = "\n", 0
      rs = @cr if @cr
      case args.size
      when 1
        case args[0]
        when String
          rs = args[0]
        when Fixnum
          limit = args[0]
        else
          raise TypeError.new "gets: Specify limit(Integer) or rs(String)"
        end
      when 2
        rs, limit = args
      end

      str = ''
      loop {
        v = -1
        3.times {   # retry
          v = _read
          break if v >= 0 || str.size == 0
          Plato::Machine.delay(1)
        }
        break if v < 0
        str << v.chr
        break if v.chr == rs
        break if limit > 0 && str.size == limit
      }
      str
    end

    def puts(*data)
      rs = "\n"
      rs = @cr if @cr
      data.each {|obj| write(obj.to_s + rs)}
    end

    def print(*data)
      data.each {|obj| write(obj.to_s)}
    end

    def <<(data)
      write(data.to_s)
      self
    end

    def term_char=(cr)
      @cr = cr
    end
  end
end
