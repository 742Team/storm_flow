Gem::Specification.new do |s|
  s.name        = 'storm_flow'
  s.version     = '0.1.1'
  s.summary     = 'Micro-framework de workflows basé sur storm_meta'
  s.description = 'StormFlow démontre le DSL d’actions, l’auto-tuning et YJIT via storm_meta.'
  s.authors     = ['DALM1']
  s.email       = ['contact@example.com']
  s.files       = Dir[
    'lib/**/*',
    'vendor/storm_meta/**/*',
    'README.md',
    'NOTICE'
  ]
  s.require_paths = ['lib', 'vendor/storm_meta/lib']
  s.bindir      = 'bin'
  s.executables = ['sync_storm_meta']
  s.homepage    = 'https://github.com/742Team/storm_flow'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 3.2'
  s.platform    = Gem::Platform::RUBY
  s.metadata    = {
    'source_code_uri' => 'https://github.com/742Team/storm_flow'
  }
end