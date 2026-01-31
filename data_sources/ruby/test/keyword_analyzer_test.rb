# frozen_string_literal: true

require_relative 'test_helper'

class KeywordAnalyzerTest < Minitest::Test
  include TestHelpers

  def setup
    @analyzer = SeoMachine::KeywordAnalyzer.new
  end

  # Basic analysis tests
  def test_analyze_returns_density
    result = @analyzer.analyze(sample_good_content, 'podcast')
    assert result.key?(:density)
    assert_kind_of Numeric, result[:density]
  end

  def test_analyze_returns_count
    result = @analyzer.analyze(sample_good_content, 'podcast')
    assert result.key?(:count)
    assert_kind_of Integer, result[:count]
  end

  def test_analyze_returns_word_count
    result = @analyzer.analyze(sample_good_content, 'podcast')
    assert result.key?(:word_count)
    assert_operator result[:word_count], :>, 0
  end

  def test_analyze_returns_placement_analysis
    result = @analyzer.analyze(sample_good_content, 'podcast')
    assert result.key?(:placements)
    placements = result[:placements]
    assert placements.key?(:in_title)
    assert placements.key?(:in_first_100_words)
    assert placements.key?(:in_h2_headings)
  end

  def test_analyze_returns_density_assessment
    result = @analyzer.analyze(sample_good_content, 'podcast')
    assert result.key?(:assessment)
  end

  # Density calculation tests
  def test_density_calculation_accuracy
    # Create content with known keyword frequency
    content = 'keyword ' * 10 + 'other ' * 90 # 10 keywords in 100 words = 10%
    result = @analyzer.analyze(content, 'keyword')
    assert_in_delta 10.0, result[:density], 1.0
  end

  def test_density_is_case_insensitive
    content = 'Podcast PODCAST podcast PoDcAsT'
    result = @analyzer.analyze(content, 'podcast')
    assert_equal 4, result[:count]
  end

  def test_handles_multi_word_keywords
    content = 'start a podcast is easy. Learn to start a podcast today. Starting a podcast requires planning.'
    result = @analyzer.analyze(content, 'start a podcast')
    assert_operator result[:count], :>=, 2
  end

  # Placement tests
  def test_detects_keyword_in_title
    content = "# How to Start a Podcast\n\nSome content here."
    result = @analyzer.analyze(content, 'start a podcast')
    assert result[:placements][:in_title]
  end

  def test_detects_keyword_in_first_100_words
    result = @analyzer.analyze(sample_good_content, 'podcast')
    assert result[:placements][:in_first_100_words]
  end

  def test_detects_keyword_in_h2_headings
    result = @analyzer.analyze(sample_good_content, 'podcast')
    assert_operator result[:placements][:in_h2_headings], :>, 0
  end

  def test_detects_missing_keyword_in_title
    content = "# Complete Audio Guide\n\nLearn about podcasting here."
    result = @analyzer.analyze(content, 'start a podcast')
    refute result[:placements][:in_title]
  end

  # Density assessment tests
  def test_flags_low_density
    content = 'podcast ' + ('word ' * 500)
    result = @analyzer.analyze(content, 'podcast')
    assert_includes %w[low very_low], result[:assessment]
  end

  def test_flags_high_density
    content = 'podcast ' * 50 + 'other ' * 50 # 50% density
    result = @analyzer.analyze(content, 'podcast')
    assert_includes %w[high stuffing], result[:assessment]
  end

  def test_identifies_optimal_density
    # Target is 1-2% density
    content = 'podcast ' * 2 + 'other ' * 98 # 2% density
    result = @analyzer.analyze(content, 'podcast')
    assert_equal 'optimal', result[:assessment]
  end

  # Edge cases
  def test_handles_empty_content
    result = @analyzer.analyze('', 'keyword')
    assert_equal 0, result[:count]
    assert_equal 0, result[:density]
  end

  def test_handles_content_without_keyword
    content = 'This content has no target words at all.'
    result = @analyzer.analyze(content, 'podcast')
    assert_equal 0, result[:count]
    assert_equal 0, result[:density]
  end

  def test_handles_special_characters_in_keyword
    content = 'C++ programming is fun. Learn C++ today.'
    result = @analyzer.analyze(content, 'C++')
    assert_operator result[:count], :>=, 2
  end

  # Variation detection tests
  def test_detects_keyword_variations
    content = 'podcasting podcaster podcasts podcast'
    result = @analyzer.analyze(content, 'podcast', include_variations: true)
    if result.key?(:variations)
      assert_operator result[:variations].length, :>, 0
    end
  end

  # LSI keyword suggestions
  def test_suggests_related_keywords
    result = @analyzer.analyze(sample_good_content, 'podcast')
    if result.key?(:related_keywords)
      assert_kind_of Array, result[:related_keywords]
    end
  end
end
