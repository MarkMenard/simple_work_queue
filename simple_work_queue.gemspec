# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "simple_work_queue/version"

Gem::Specification.new do |s|
  s.name        = "simple_work_queue"
  s.version     = SimpleWorkQueue::VERSION
  s.authors     = ["Mark Menard"]
  s.email       = ["mark@mjm.net"]
  s.homepage    = "http://www.github.com/MarkMenard/simple_work_queue"
  s.summary     = %q{A simple work queue for JRuby based on work_queue by Miguel Fonseca.}
  s.description = %q{A simple work queue for JRuby to manage a pool of worker threads.}

  s.rubyforge_project = "simple_work_queue"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
