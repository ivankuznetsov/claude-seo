# frozen_string_literal: true

RSpec.describe SeoMachine::KeywordAnalyzer do
  subject(:analyzer) { described_class.new }

  let(:sample_content) do
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

  describe '#analyze' do
    subject(:result) { analyzer.analyze(sample_content, 'start a podcast', secondary_keywords: ['podcast hosting', 'podcast equipment']) }

    it 'returns word count' do
      expect(result[:word_count]).to be > 0
    end

    it 'analyzes primary keyword' do
      expect(result[:primary_keyword]).to include(
        keyword: 'start a podcast',
        density: a_kind_of(Numeric),
        exact_matches: a_kind_of(Integer)
      )
    end

    it 'determines density status' do
      expect(result[:primary_keyword][:density_status]).to be_a(String)
      expect(%w[too_low slightly_low optimal slightly_high too_high]).to include(result[:primary_keyword][:density_status])
    end

    it 'checks critical placements' do
      placements = result[:primary_keyword][:critical_placements]
      expect(placements).to include(
        in_first_100_words: a_kind_of(TrueClass).or(a_kind_of(FalseClass)),
        in_conclusion: a_kind_of(TrueClass).or(a_kind_of(FalseClass)),
        in_h1: a_kind_of(TrueClass).or(a_kind_of(FalseClass)),
        in_h2_headings: a_kind_of(String)
      )
    end

    it 'analyzes secondary keywords' do
      expect(result[:secondary_keywords]).to be_an(Array)
      expect(result[:secondary_keywords].length).to eq(2)
    end

    it 'detects keyword stuffing risk' do
      expect(result[:keyword_stuffing]).to include(
        risk_level: a_kind_of(String),
        safe: a_kind_of(TrueClass).or(a_kind_of(FalseClass))
      )
    end

    it 'performs topic clustering' do
      expect(result[:topic_clusters]).to include(:clusters_found)
    end

    it 'creates distribution heatmap' do
      expect(result[:distribution_heatmap]).to be_an(Array)
    end

    it 'finds LSI keywords' do
      expect(result[:lsi_keywords]).to be_an(Array)
    end

    it 'generates recommendations' do
      expect(result[:recommendations]).to be_an(Array)
    end
  end

  describe 'density calculation' do
    let(:content_with_high_density) do
      'Podcast podcast podcast. Start a podcast today. Podcast is great. ' * 10
    end

    it 'detects high density as stuffing risk' do
      result = analyzer.analyze(content_with_high_density, 'podcast')
      expect(result[:keyword_stuffing][:risk_level]).to eq('high').or(eq('medium'))
    end
  end

  describe 'section extraction' do
    it 'correctly identifies H1 headers' do
      result = analyzer.analyze(sample_content, 'podcast')
      sections = result[:distribution_heatmap]
      expect(sections.first[:section]).to include('Guide').or(include('Section'))
    end

    it 'identifies H2 sections' do
      result = analyzer.analyze(sample_content, 'podcast')
      expect(result[:primary_keyword][:critical_placements][:in_h2_headings]).to match(%r{\d+/\d+})
    end
  end

  describe 'edge cases' do
    it 'handles empty content' do
      result = analyzer.analyze('', 'keyword')
      expect(result[:word_count]).to eq(0)
    end

    it 'handles content without headers' do
      result = analyzer.analyze('Just some plain text without any headers.', 'text')
      expect(result).to include(:word_count, :primary_keyword)
    end

    it 'handles keyword not found in content' do
      result = analyzer.analyze(sample_content, 'nonexistent keyword')
      expect(result[:primary_keyword][:exact_matches]).to eq(0)
      expect(result[:primary_keyword][:density_status]).to eq('too_low')
    end
  end
end
