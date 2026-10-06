source 'https://rubygems.org'

# Runtime dependencies live in wreckem.gemspec.
gemspec

group :development, :test do
  gem 'rspec', '3.13.2'
  gem 'rake', '13.3.1'
  # SequelStore defaults to a jdbc:sqlite connection and the specs exercise it,
  # but the driver is a deployment choice -- consumers pick their own, so this
  # stays out of the gemspec.
  gem 'jdbc-sqlite3', '3.46.1.1', platforms: :jruby
end
