MRuby::Gem::Specification.new('mruby-plato-serial') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Plato developers'
  spec.description = 'Plato::Serial module (Serial interface)'

  spec.add_dependency('mruby-string-ext')
  spec.add_dependency('mruby-plato-machine')
  spec.add_test_dependency('mruby-plato-machine-sim')
end
