# frozen_string_literal: true

require 'time'

module SeoMachine
  # Data Aggregator
  # Combines data from multiple sources (GA4, GSC, DataForSEO) for comprehensive analysis.
  class DataAggregator
    attr_reader :ga, :gsc, :dfs

    # Initialize all data source clients
    def initialize
      @ga = begin
        GoogleAnalytics.new
      rescue StandardError => e
        warn "Warning: Google Analytics not configured: #{e.message}"
        nil
      end

      @gsc = begin
        GoogleSearchConsole.new
      rescue StandardError => e
        warn "Warning: Google Search Console not configured: #{e.message}"
        nil
      end

      @dfs = begin
        DataForSeo.new
      rescue StandardError => e
        warn "Warning: DataForSEO not configured: #{e.message}"
        nil
      end
    end

    # Get all available data for a specific page
    #
    # @param url [String] Page path or full URL
    # @param days [Integer] Days to analyze
    # @return [Hash] Data from all sources
    def get_comprehensive_page_performance(url, days: 30)
      result = {
        url: url,
        analyzed_at: Time.now.iso8601,
        period_days: days,
        ga4: nil,
        gsc: nil,
        dataforseo: nil
      }

      # Google Analytics data
      if @ga
        begin
          trends = @ga.get_page_trends(url, days: days)
          result[:ga4] = {
            total_pageviews: trends[:total_pageviews],
            trend_direction: trends[:trend_direction],
            trend_percent: trends[:trend_percent],
            timeline: trends[:timeline]
          }
        rescue StandardError => e
          result[:ga4] = { error: e.message }
        end
      end

      # Google Search Console data
      if @gsc
        begin
          page_perf = @gsc.get_page_performance(url, days: days)
          result[:gsc] = page_perf
        rescue StandardError => e
          result[:gsc] = { error: e.message }
        end
      end

      # DataForSEO - Get rankings for top keywords from GSC
      if @dfs && result[:gsc] && result[:gsc][:top_keywords]
        begin
          top_keywords = result[:gsc][:top_keywords].first(5).map { |kw| kw[:keyword] }
          domain = ENV.fetch('GSC_SITE_URL', '').gsub(%r{https?://}, '')

          rankings = @dfs.get_rankings(domain: domain, keywords: top_keywords)
          result[:dataforseo] = { rankings: rankings }
        rescue StandardError => e
          result[:dataforseo] = { error: e.message }
        end
      end

      result
    end

    # Identify content opportunities across all data sources
    #
    # @param days [Integer] Days to analyze
    # @param min_monthly_pageviews [Integer] Minimum pageviews filter
    # @return [Hash] Categorized opportunities
    def identify_content_opportunities(days: 30, min_monthly_pageviews: 100)
      opportunities = {
        quick_wins: [],
        declining_content: [],
        low_ctr: [],
        trending_topics: [],
        competitor_gaps: []
      }

      # Quick wins from GSC
      if @gsc
        begin
          quick_wins = @gsc.get_quick_wins(days: days)
          opportunities[:quick_wins] = quick_wins.first(20)
        rescue StandardError => e
          warn "Error getting quick wins: #{e.message}"
        end
      end

      # Declining content from GA4
      if @ga
        begin
          declining = @ga.get_declining_pages(comparison_days: days, threshold_percent: -20.0)
          opportunities[:declining_content] = declining.first(15)
        rescue StandardError => e
          warn "Error getting declining pages: #{e.message}"
        end
      end

      # Low CTR pages from GSC
      if @gsc
        begin
          low_ctr = @gsc.get_low_ctr_pages(days: days)
          opportunities[:low_ctr] = low_ctr.first(15)
        rescue StandardError => e
          warn "Error getting low CTR pages: #{e.message}"
        end
      end

      # Trending topics from GSC
      if @gsc
        begin
          trending = @gsc.get_trending_queries
          opportunities[:trending_topics] = trending.first(15)
        rescue StandardError => e
          warn "Error getting trending queries: #{e.message}"
        end
      end

      opportunities
    end

    # Generate comprehensive performance report
    #
    # @param days [Integer] Days to analyze
    # @return [Hash] Complete performance report
    def generate_performance_report(days: 30)
      report = {
        generated_at: Time.now.iso8601,
        period_days: days,
        summary: {},
        top_performers: [],
        opportunities: {},
        recommendations: []
      }

      # Summary metrics from GA4
      if @ga
        begin
          top_pages = @ga.get_top_pages(days: days, limit: 100)
          report[:summary][:total_pageviews] = top_pages.sum { |p| p[:pageviews] }
          report[:summary][:total_sessions] = top_pages.sum { |p| p[:sessions] }
          report[:summary][:avg_engagement_rate] = top_pages.empty? ? 0 : top_pages.sum { |p| p[:engagement_rate] } / top_pages.size
          report[:top_performers] = top_pages.first(10)
        rescue StandardError => e
          warn "Error getting GA4 summary: #{e.message}"
        end
      end

      # Summary from GSC
      if @gsc
        begin
          keywords = @gsc.get_keyword_positions(days: days)
          report[:summary][:total_keywords] = keywords.size
          report[:summary][:total_clicks] = keywords.sum { |kw| kw[:clicks] }
          report[:summary][:total_impressions] = keywords.sum { |kw| kw[:impressions] }
          report[:summary][:avg_ctr] = keywords.empty? ? 0 : keywords.sum { |kw| kw[:ctr] } / keywords.size
        rescue StandardError => e
          warn "Error getting GSC summary: #{e.message}"
        end
      end

      # Opportunities
      report[:opportunities] = identify_content_opportunities(days: days)

      # Generate recommendations
      report[:recommendations] = generate_recommendations(report[:opportunities])

      report
    end

    # Get prioritized list of content tasks
    #
    # @param limit [Integer] Number of tasks to return
    # @return [Array<Hash>] Prioritized task list
    def get_priority_queue(limit: 10)
      opportunities = identify_content_opportunities
      recommendations = generate_recommendations(opportunities)

      priority_order = { 'high' => 0, 'medium' => 1, 'low' => 2 }
      recommendations.sort_by { |r| priority_order[r[:priority]] || 3 }.first(limit)
    end

    private

    # Generate actionable recommendations from opportunities
    #
    # @param opportunities [Hash] Opportunities from identify_content_opportunities
    # @return [Array<Hash>] List of recommendations
    def generate_recommendations(opportunities)
      recommendations = []

      # Quick wins
      if opportunities[:quick_wins]&.any?
        top_quick_win = opportunities[:quick_wins].first
        recommendations << {
          priority: 'high',
          type: 'optimize',
          action: "Optimize for '#{top_quick_win[:keyword]}'",
          reason: "Currently ranking ##{top_quick_win[:position].to_i} with #{top_quick_win[:impressions].to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} impressions. Small improvements could push to page 1.",
          keyword: top_quick_win[:keyword],
          current_position: top_quick_win[:position]
        }
      end

      # Declining content
      if opportunities[:declining_content]&.any?
        worst_decline = opportunities[:declining_content].first
        recommendations << {
          priority: 'high',
          type: 'update',
          action: "Update declining article: #{worst_decline[:title]}",
          reason: "Traffic down #{worst_decline[:change_percent].abs.round(1)}% (#{format_number(worst_decline[:previous_pageviews])} -> #{format_number(worst_decline[:pageviews])} pageviews). Needs refresh.",
          url: worst_decline[:path],
          change_percent: worst_decline[:change_percent]
        }
      end

      # Low CTR
      if opportunities[:low_ctr]&.any?
        worst_ctr = opportunities[:low_ctr].first
        recommendations << {
          priority: 'medium',
          type: 'optimize_meta',
          action: "Improve meta elements for: #{worst_ctr[:url]}",
          reason: "Getting #{format_number(worst_ctr[:impressions])} impressions but only #{worst_ctr[:ctr]}% CTR. Better title/description could add #{format_number(worst_ctr[:missed_clicks])} clicks/month.",
          url: worst_ctr[:url],
          potential_clicks: worst_ctr[:missed_clicks]
        }
      end

      # Trending topics
      if opportunities[:trending_topics]&.any?
        top_trend = opportunities[:trending_topics].first
        recommendations << {
          priority: 'medium',
          type: 'create_new',
          action: "Create content for trending topic: '#{top_trend[:query]}'",
          reason: "Search interest up #{top_trend[:change_percent].round(1)}% with #{format_number(top_trend[:recent_impressions])} recent impressions. Strike while hot!",
          query: top_trend[:query],
          growth: top_trend[:change_percent]
        }
      end

      recommendations
    end

    # Format number with commas
    def format_number(num)
      num.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    end
  end
end
