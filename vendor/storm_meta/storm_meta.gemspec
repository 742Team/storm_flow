Gem::Specification.new do |spec|
  spec.name          = "storm_meta"
  spec.version       = "0.1.0"
  spec.summary       = "Metaprogramming & JIT helpers for high-performance Ruby services"
  spec.description   = "Helpers for YJIT, metaprogramming patterns, and auto-tuning strategies used by STORM and other microservices."
  spec.authors       = ["DALM1"]
  spec.email         = ["dimitri.almon@gmail.com"]

  spec.files         = Dir["lib/**/*"] + ["LICENSE", "README.md", "NOTICE", "NOTICE.md"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 3.2.0"

  spec.homepage      = "https://github.com/742Team/storm_meta"
  spec.license       = "MIT"
end
