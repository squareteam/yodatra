$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'yodatra/version'

Gem::Specification.new 'yodatra', Yodatra::VERSION do |s|
  s.description = "Yodatra is a minimalistic framework built on top of Sinatra."
  s.summary = "Classy backend development with the speed of Sinatra and the power of ActiveRecord"
  s.authors = ["Paul Bonaud"]
  s.email = "paul+st@bonaud.fr"
  s.homepage = "http://squareteam.github.io/yodatra"
  s.license = 'MIT'
  s.files = `git ls-files`.split("\n") - %w[.gitignore .travis.yml]
  s.test_files = s.files.select { |p| p =~ /^spec\/.*_spec.rb/ }
  s.extra_rdoc_files = s.files.select { |p| p =~ /^README/ } << 'LICENSE'
  s.rdoc_options = %w[--line-numbers --inline-source --title Yodatra --main README.rdoc --encoding=UTF-8]

  s.add_dependency 'rack', '~> 1.4'
  s.add_dependency 'sinatra', '~> 1.4.4', '>= 1.4.4'
  s.add_dependency 'sinatra-activerecord'
  s.add_dependency 'sinatra-logger'
  s.add_dependency 'sinatra-contrib', '~> 1.4.2', '>= 1.4.2'
  s.add_dependency 'rack-protection', '~> 1.4'
end