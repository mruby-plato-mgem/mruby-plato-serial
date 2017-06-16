# Plato::Serial module

class Ser
  include Plato::Serial
  attr_accessor :indata
  attr_reader :outdata
  def initialize(baud, dbits=8, start=1, stop=1, parity=:none)
    @indata = []
    @outdata = ''
  end
  def _read
    d = @indata.shift
    d.nil? ? -1 : d
  end
  def _write(v)
    @outdata << v.chr
  end
  def available; @indata.size; end
  def flush; @outdata = ''; end
  def close; end
end

assert('Serial', 'class') do
  assert_equal(Plato::Serial.class, Module)
end

assert('Serial', 'register_device') do
  assert_nothing_raised {
    Plato::Serial.register_device(Ser)
  }
end

assert('Serial', 'open') do
  Plato::Serial.register_device(Ser)
  ser1 = Plato::Serial.open(9600)
  ser2 = Plato::Serial.open(115200, 7)
  ser3 = Plato::Serial.open(9600, 8, 1)
  ser4 = Plato::Serial.open(9600, 8, 1, 1)
  ser5 = Plato::Serial.open(9600, 8, 1, 1, :even)
  assert_true(ser1 && ser2 && ser3 && ser4 && ser5)
end

assert('Serial', 'open - argument error') do
  Plato::Serial.register_device(Ser)
  assert_raise(ArgumentError) {Plato::Serial.open}
  assert_raise(ArgumentError) {Plato::Serial.open(9600, 8, 1, 1, :odd, 0)}
end

assert('Serial', 'open - no device') do
  Plato::Serial.register_device(nil)
  assert_raise(RuntimeError) {Plato::Serial.open(115200)}
end

assert('Serial', '_read') do
  Plato::Serial.register_device(Ser)
  ser = Plato::Serial.open(115200)
  assert_equal(ser._read, -1)
end

assert('Serial', '_write') do
  Plato::Serial.register_device(Ser)
  ser = Plato::Serial.open(115200)
  ser._write(0xff)
  assert_equal(ser.outdata, "\xff")
end

assert('Serial', 'available') do
  assert_nothing_raised {
    Plato::Serial.register_device(Ser)
    Plato::Serial.open(115200).available
  }
end

assert('Serial', 'flush') do
  assert_nothing_raised {
    Plato::Serial.register_device(Ser)
    Plato::Serial.open(115200).flush
  }
end

assert('Serial', 'close') do
  assert_nothing_raised {
    Plato::Serial.register_device(Ser)
    Plato::Serial.open(115200).close
  }
end

assert('Serial', 'read') do
  Plato::Serial.register_device(Ser)
  ser = Plato::Serial.open(9600)
  assert_nil(ser.read)
  '123abcdef'.each_byte {|b| ser.indata << b}
  assert_equal(ser.read(1), [0x31])
  assert_equal(ser.read(3, :as_array), [0x32, 0x33, 0x61])
  assert_equal(ser.read(3, :as_string), 'bcd')
  assert_equal(ser.read(3, :as_string, 100), 'ef')
  assert_nil(ser.read(3, :as_string))
end

assert('Serial', 'read - argument error') do
  Plato::Serial.register_device(Ser)
  ser = Plato::Serial.open(9600)
  assert_raise(ArgumentError) {ser.read(1, :as_string, 1000, 2)}
end

assert('Serial', 'write') do
  Plato::Serial.register_device(Ser)
  ser = Plato::Serial.open(9600)
  ser.write(0)
  ser.write([1, 2, 3])
  ser.write('ABC')
  ser.write(:ok)
  assert_equal(ser.outdata, "\0\1\2\3ABCok")
end

assert('Serial', 'write - argument error') do
  Plato::Serial.register_device(Ser)
  ser = Plato::Serial.open(9600)
  assert_raise(ArgumentError) {ser.write(0, 1)}
end

assert('Serial', 'getc') do
  Plato::Serial.register_device(Ser)
  ser = Plato::Serial.open(9600)
  assert_nil(ser.getc)
  ser.indata = [0x31, 0x61]
  assert_equal(ser.getc, '1')
  assert_equal(ser.getc, 'a')
  assert_nil(ser.getc)
end

assert('Serial', 'putc') do
  Plato::Serial.register_device(Ser)
  ser = Plato::Serial.open(9600)
  ser.putc('a')
  assert_equal(ser.outdata, 'a')
end

assert('Serial', 'putc - type error') do
  Plato::Serial.register_device(Ser)
  ser = Plato::Serial.open(9600)
  assert_raise(TypeError) {ser.putc(0)}
end

assert('Serial', 'gets') do
  Plato::Serial.register_device(Ser)
  ser = Plato::Serial.open(9600)
  assert_equal(ser.gets, '')
  "123\nabcdef\nABC\rDEF\nGHIJ\rKLMN".each_byte {|b| ser.indata << b}
  assert_equal(ser.gets, "123\n")
  assert_equal(ser.gets("\r"), "abcdef\nABC\r")
  assert_equal(ser.gets(2), "DE")
  assert_equal(ser.gets(5), "F\n")
  assert_equal(ser.gets("\r", 3), "GHI")
  assert_equal(ser.gets("\r", 3), "J\r")
  assert_equal(ser.gets, "KLMN")
end

assert('Serial', 'gets - argument error') do
  Plato::Serial.register_device(Ser)
  ser = Plato::Serial.open(9600)
  assert_raise(TypeError) {ser.gets(:ng)}
end

assert('Serial', 'puts') do
  Plato::Serial.register_device(Ser)
  ser = Plato::Serial.open(9600)
  ser.puts('abc')
  ser.puts(1)
  ser.puts(1, 'mruby', [1, 2, 3])
  assert_equal(ser.outdata, "abc\n1\n1\nmruby\n[1, 2, 3]\n")
end

assert('Serial', 'print') do
  Plato::Serial.register_device(Ser)
  ser = Plato::Serial.open(9600)
  ser.print('abc')
  ser.print(1)
  ser.print(1, 'mruby', [1, 2, 3])
  assert_equal(ser.outdata, "abc11mruby[1, 2, 3]")
end

assert('Serial', '<<') do
  Plato::Serial.register_device(Ser)
  ser = Plato::Serial.open(9600)
  ser << 'abc'
  ser << 1
  ser << 1 << 'mruby' << [1, 2, 3]
  assert_equal(ser.outdata, "abc11mruby[1, 2, 3]")
end

assert('Serial', 'term_char=') do
  Plato::Serial.register_device(Ser)
  ser = Plato::Serial.open(9600)
  ser.term_char = "\r\n"
  ser.puts('abc')
  ser.term_char = "\r"
  ser.puts(1)
  ser.term_char = "\n"
  ser.puts(1, 'mruby', [1, 2, 3])
  assert_equal(ser.outdata, "abc\r\n1\r1\nmruby\n[1, 2, 3]\n")
end
