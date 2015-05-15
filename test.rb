#!/usr/bin/env ruby
require 'bundler'
require 'json' unless defined?(JSON)
Bundler.require

data = {
  'post-office-box' => '12345',
  'locality' => 'Broomfield',
  'region' => 'CO',
  'country-name' => 'U.S.A'
}

schema = {
  'description' => 'An Address following the convention of http://microformats.org/wiki/hcard',
  'type' => 'object',
  'properties' => {
    "post-office-box" => { 'type' => 'string' },
    "extended-address" => { 'type' => 'string' },
    "street-address" => { 'type' => 'string' },
    "locality" => { 'type' => 'string' },
    'region' => { 'type' => 'string' },
    "postal-code" => { 'type' => 'string' },
    "country-name" => { 'type' => 'string' }
  },
  'required' => ['locality', 'region', 'country-name'],
  'dependencies' => {
    'post-office-box' => 'street-address',
    'extended-address' => 'street-address'
  }
}

schema_file = 'schema.json'

File.open('schema.json','w') do |f|
  f << JSON.dump(schema)
end unless File.exist?(schema_file)

40_000.times do
  JSON::Validator.validate(schema_file, data)
end

40_000.times do
  JSON::Validator.validate(schema, data)
end

Benchmark.ips do |x|
  x.config time: 30, warmup: 90

  x.report('json-schema from file') do
    JSON::Validator.validate(schema_file, data)
  end

  x.report('json-schema from hash') do
    JSON::Validator.validate(schema, data)
  end

  x.compare!
end
