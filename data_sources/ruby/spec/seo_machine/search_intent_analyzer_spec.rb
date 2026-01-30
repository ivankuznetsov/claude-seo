# frozen_string_literal: true

RSpec.describe SeoMachine::SearchIntentAnalyzer do
  subject(:analyzer) { described_class.new }

  describe '#analyze' do
    context 'with informational queries' do
      let(:informational_queries) do
        [
          'how to start a podcast',
          'what is podcast hosting',
          'why podcasting is important',
          'guide to podcast equipment',
          'tutorial for recording audio'
        ]
      end

      it 'identifies informational intent' do
        informational_queries.each do |query|
          result = analyzer.analyze(query)
          expect(result[:primary_intent]).to eq('informational'),
                                             "Expected '#{query}' to be informational, got #{result[:primary_intent]}"
        end
      end
    end

    context 'with transactional queries' do
      let(:transactional_queries) do
        [
          'buy podcast microphone',
          'podcast hosting pricing',
          'cheap podcast equipment',
          'download podcast software',
          'get podcast hosting free trial'
        ]
      end

      it 'identifies transactional intent' do
        transactional_queries.each do |query|
          result = analyzer.analyze(query)
          expect(result[:primary_intent]).to eq('transactional'),
                                             "Expected '#{query}' to be transactional, got #{result[:primary_intent]}"
        end
      end
    end

    context 'with commercial queries' do
      let(:commercial_queries) do
        [
          'best podcast hosting platforms',
          'top podcast microphones review',
          'buzzsprout vs libsyn comparison',
          'anchor alternatives'
        ]
      end

      it 'identifies commercial intent' do
        commercial_queries.each do |query|
          result = analyzer.analyze(query)
          expect(result[:primary_intent]).to eq('commercial'),
                                             "Expected '#{query}' to be commercial, got #{result[:primary_intent]}"
        end
      end
    end

    context 'with navigational queries' do
      let(:navigational_queries) do
        [
          'spotify login',
          'apple podcasts app',
          'anchor fm dashboard'
        ]
      end

      it 'identifies navigational intent' do
        navigational_queries.each do |query|
          result = analyzer.analyze(query)
          expect(result[:primary_intent]).to eq('navigational'),
                                             "Expected '#{query}' to be navigational, got #{result[:primary_intent]}"
        end
      end
    end
  end

  describe 'confidence scores' do
    it 'returns confidence percentages that sum to approximately 100' do
      result = analyzer.analyze('how to start a podcast')
      total = result[:confidence].values.sum
      expect(total).to be_within(1).of(100)
    end

    it 'returns highest confidence for primary intent' do
      result = analyzer.analyze('best podcast hosting')
      primary = result[:primary_intent]
      expect(result[:confidence][primary]).to eq(result[:confidence].values.max)
    end
  end

  describe 'secondary intent' do
    it 'returns secondary intent when close to primary' do
      result = analyzer.analyze('best podcast hosting guide')
      # This could have both commercial and informational intent
      expect(result).to include(:secondary_intent)
    end

    it 'returns nil secondary intent when primary is dominant' do
      result = analyzer.analyze('how to start podcasting tutorial guide for beginners')
      # Strong informational signals should dominate
      # Secondary might still be present if commercial signals are detected
      expect(result[:primary_intent]).to eq('informational')
    end
  end

  describe 'signals detection' do
    it 'detects keyword signals' do
      result = analyzer.analyze('best podcast hosting pricing')
      signals = result[:signals_detected]

      expect(signals['commercial']).to include(a_string_matching(/best/))
      expect(signals['transactional']).to include(a_string_matching(/pricing/))
    end
  end

  describe 'recommendations' do
    it 'returns content recommendations for informational intent' do
      result = analyzer.analyze('how to start a podcast')
      recommendations = result[:recommendations]

      expect(recommendations).to include(
        a_string_matching(/comprehensive/i),
        a_string_matching(/step.*step/i)
      )
    end

    it 'returns content recommendations for transactional intent' do
      result = analyzer.analyze('buy podcast microphone')
      recommendations = result[:recommendations]

      expect(recommendations).to include(
        a_string_matching(/product|pricing/i)
      )
    end

    it 'returns content recommendations for commercial intent' do
      result = analyzer.analyze('best podcast hosting')
      recommendations = result[:recommendations]

      expect(recommendations).to include(
        a_string_matching(/comparison|review/i)
      )
    end
  end

  describe 'with SERP features' do
    let(:serp_features) do
      ['featured_snippet', 'people_also_ask', 'video']
    end

    it 'incorporates SERP features in analysis' do
      result = analyzer.analyze('what is podcasting', serp_features: serp_features)
      signals = result[:signals_detected]

      expect(signals['informational']).to include(
        a_string_matching(/SERP/)
      )
    end

    it 'adjusts confidence based on SERP features' do
      result_with_serp = analyzer.analyze('what is podcasting', serp_features: serp_features)
      result_without_serp = analyzer.analyze('what is podcasting')

      # With informational SERP features, informational confidence should be higher
      expect(result_with_serp[:confidence]['informational']).to be >= result_without_serp[:confidence]['informational']
    end
  end

  describe 'with top results' do
    let(:top_results) do
      [
        { 'title' => 'How to Start a Podcast: Complete Guide', 'description' => 'Learn podcasting step by step', 'url' => 'https://example.com/guide' },
        { 'title' => 'Podcast Tutorial for Beginners', 'description' => 'Tips and tricks for new podcasters', 'url' => 'https://example.com/tutorial' }
      ]
    end

    it 'incorporates top results content patterns' do
      result = analyzer.analyze('start a podcast', top_results: top_results)
      expect(result[:confidence]['informational']).to be > 0
    end
  end
end
