Gem::Specification.new do |s|
  s.name = 'all_todo'
  s.version = '0.2.7'
  s.summary = 'Reads a plain text file called all_todo.txt and generates a Polyrex document from it and more.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/all_todo.rb']
  s.add_runtime_dependency('pxrowx', '~> 0.1', '>=0.1.1')
  s.add_runtime_dependency('polyrex-headings', '~> 0.1', '>=0.1.5')
  s.signing_key = '../privatekeys/all_todo.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/all_todo'
end
