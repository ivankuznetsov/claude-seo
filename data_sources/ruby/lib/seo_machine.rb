# frozen_string_literal: true

# SEO Machine - Ruby Data Sources
# Rewritten from Python for Ruby integration
module SeoMachine
  VERSION = '1.0.0'

  autoload :GoogleAnalytics, 'seo_machine/google_analytics'
  autoload :GoogleSearchConsole, 'seo_machine/google_search_console'
  autoload :DataForSeo, 'seo_machine/data_for_seo'
  autoload :DataAggregator, 'seo_machine/data_aggregator'
  autoload :KeywordAnalyzer, 'seo_machine/keyword_analyzer'
  autoload :ReadabilityScorer, 'seo_machine/readability_scorer'
  autoload :SeoQualityRater, 'seo_machine/seo_quality_rater'
  autoload :SearchIntentAnalyzer, 'seo_machine/search_intent_analyzer'
  autoload :ContentLengthComparator, 'seo_machine/content_length_comparator'
  autoload :ContentScrubber, 'seo_machine/content_scrubber'

  class Error < StandardError; end
  class ConfigurationError < Error; end
  class ApiError < Error; end

  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end
  end

  class Configuration
    attr_accessor :ga4_property_id, :ga4_credentials_path,
                  :gsc_site_url, :gsc_credentials_path,
                  :dataforseo_login, :dataforseo_password,
                  :cache_enabled, :cache_dir

    def initialize
      @ga4_property_id = ENV.fetch('GA4_PROPERTY_ID', nil)
      @ga4_credentials_path = ENV.fetch('GA4_CREDENTIALS_PATH', nil)
      @gsc_site_url = ENV.fetch('GSC_SITE_URL', nil)
      @gsc_credentials_path = ENV.fetch('GSC_CREDENTIALS_PATH', nil)
      @dataforseo_login = ENV.fetch('DATAFORSEO_LOGIN', nil)
      @dataforseo_password = ENV.fetch('DATAFORSEO_PASSWORD', nil)
      @cache_enabled = true
      @cache_dir = 'data_sources/cache'
    end
  end
end

# Load dotenv if available
begin
  require 'dotenv'
  Dotenv.load('data_sources/config/.env')
rescue LoadError
  # dotenv not available, continue without it
end
