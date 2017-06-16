# mruby-plato-serial   [![Build Status](https://travis-ci.org/mruby-plato/mruby-plato-serial.svg?branch=master)](https://travis-ci.org/mruby-plato/mruby-plato-serial)
Plato::Serial module (Serial interface)
## install by mrbgems
- add conf.gem line to `build_config.rb`

```ruby
MRuby::Build.new do |conf|

  # ... (snip) ...

  conf.gem :git => 'https://github.com/mruby-plato/mruby-plato-machine'
  conf.gem :git => 'https://github.com/mruby-plato/mruby-plato-serial'
end
```

## example
```ruby
ser = Plato::Serial.open(9600)
ser.puts "Hello, Plato!"
puts ser.gets
```

## License
under the MIT License:
- see LICENSE file
