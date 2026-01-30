# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_group 'Data Sources', 'lib/seo_machine'
end

require 'bundler/setup'
require 'webmock/rspec'
require 'vcr'

# Add lib to load path
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'seo_machine'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.filter_sensitive_data('<GA4_PROPERTY_ID>') { ENV.fetch('GA4_PROPERTY_ID', 'test_property') }
  config.filter_sensitive_data('<GSC_SITE_URL>') { ENV.fetch('GSC_SITE_URL', 'https://example.com') }
  config.filter_sensitive_data('<DATAFORSEO_LOGIN>') { ENV.fetch('DATAFORSEO_LOGIN', 'test_login') }
  config.filter_sensitive_data('<DATAFORSEO_PASSWORD>') { ENV.fetch('DATAFORSEO_PASSWORD', 'test_password') }
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = true
  config.order = :random

  Kernel.srand config.seed
end

# Helper methods for tests
module TestHelpers
  def sample_content
    <<~CONTENT
      # How to Start a Podcast: Complete Guide

      Starting a podcast has never been easier. In this guide, you'll learn how to start a podcast from scratch.

      ## Choosing Your Podcast Topic

      When you start a podcast, the first step is choosing your topic. Your podcast topic should be something you're passionate about.

      ## Getting Podcast Equipment

      To start a podcast, you need basic equipment. A good microphone is essential for podcast recording.

      ## Podcast Hosting Platforms

      Podcast hosting is crucial. Choose a reliable podcast hosting platform for your show.

      ## Conclusion

      Now you're ready to start your podcast journey. Good luck!
    CONTENT
  end

  def sample_serp_results
    [
      { 'url' => 'https://example1.com/podcast-guide', 'domain' => 'example1.com', 'title' => 'How to Start a Podcast' },
      { 'url' => 'https://example2.com/podcast-tutorial', 'domain' => 'example2.com', 'title' => 'Podcast Tutorial' },
      { 'url' => 'https://example3.com/podcasting-101', 'domain' => 'example3.com', 'title' => 'Podcasting 101' }
    ]
  end
end

RSpec.configure do |config|
  config.include TestHelpers
end
