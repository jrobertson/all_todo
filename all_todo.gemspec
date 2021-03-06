Gem::Specification.new do |s|
  s.name = 'all_todo'
  s.version = '0.4.4'
  s.summary = 'Reads a plain text file called all_todo.txt and generates a Polyrex document from it and more.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/all_todo.rb']
  s.add_runtime_dependency('px_todo', '~> 0.1', '>=0.1.3')
  s.add_runtime_dependency('rexle-diff', '~> 0.6', '>=0.6.1')
  s.signing_key = '../privatekeys/all_todo.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/all_todo'
end
