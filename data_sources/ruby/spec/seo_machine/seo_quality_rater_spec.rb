# frozen_string_literal: true

RSpec.describe SeoMachine::SeoQualityRater do
  subject(:rater) { described_class.new }

  let(:good_content) do
    <<~CONTENT
      # How to Start a Podcast in 2024: Complete Guide

      Starting a podcast has never been easier. In this comprehensive guide, you'll learn exactly how to start a podcast from scratch, covering everything from equipment to distribution.

      ## Why Start a Podcast?

      Podcasting continues to grow in popularity. Here's why you should start a podcast today:

      - Build an engaged audience
      - Establish thought leadership
      - Create passive income streams
      - Connect with industry experts

      ## Essential Podcast Equipment

      To start a podcast, you need quality equipment. Here's what you'll need:

      1. A good microphone (USB or XLR)
      2. Headphones for monitoring
      3. Recording software
      4. Pop filter and microphone stand

      ## Choosing Your Podcast Topic

      When you start a podcast, topic selection is crucial. Consider:

      - Your expertise and passion
      - Audience demand
      - Competition analysis
      - Long-term sustainability

      ## Recording Your First Episode

      Ready to start a podcast recording? Follow these steps:

      1. Write an outline
      2. Set up your recording space
      3. Do a test recording
      4. Record your episode
      5. Edit and polish

      ## Publishing and Distribution

      After recording, you need to publish. Most podcast hosting platforms make this easy.

      ## Conclusion

      Now you know how to start a podcast. Take action today and begin your podcasting journey!

      [Start your free trial](https://example.com/trial) to begin hosting your podcast.
    CONTENT
  end

  let(:poor_content) do
    'Short content without structure.'
  end

  describe '#rate' do
    context 'with good content' do
      subject(:result) do
        rater.rate(
          content: good_content,
          meta_title: 'How to Start a Podcast: Complete 2024 Guide',
          meta_description: 'Learn how to start a podcast from scratch with our comprehensive guide. Covers equipment, topic selection, recording, and distribution.',
          primary_keyword: 'start a podcast',
          secondary_keywords: ['podcast equipment', 'podcast hosting'],
          keyword_density: 1.5,
          internal_link_count: 4,
          external_link_count: 2
        )
      end

      it 'returns an overall score' do
        expect(result[:overall_score]).to be_between(0, 100)
      end

      it 'returns a grade' do
        expect(result[:grade]).to match(/\A[A-F] \(/)
      end

      it 'returns category scores' do
        expect(result[:category_scores]).to include(
          :content,
          :keyword_optimization,
          :meta_elements,
          :structure,
          :links,
          :readability
        )
      end

      it 'returns publishing readiness status' do
        expect(result[:publishing_ready]).to be(true).or(be(false))
      end

      it 'returns content details' do
        expect(result[:details]).to include(
          :word_count,
          :h2_count,
          :has_h1
        )
      end

      it 'scores higher than poor content' do
        good_result = result
        poor_result = rater.rate(content: poor_content, primary_keyword: 'test')
        expect(good_result[:overall_score]).to be > poor_result[:overall_score]
      end
    end

    context 'with poor content' do
      subject(:result) do
        rater.rate(
          content: poor_content,
          primary_keyword: 'test'
        )
      end

      it 'flags critical issues for short content' do
        expect(result[:critical_issues]).to include(a_string_matching(/too short/i))
      end

      it 'flags missing meta elements' do
        expect(result[:critical_issues]).to include(
          a_string_matching(/meta title/i),
          a_string_matching(/meta description/i)
        )
      end

      it 'returns lower overall score' do
        expect(result[:overall_score]).to be < 50
      end
    end
  end

  describe 'meta element scoring' do
    it 'penalizes short meta title' do
      result = rater.rate(
        content: good_content,
        meta_title: 'Short',
        meta_description: 'A proper description that meets the minimum length requirement for meta descriptions.',
        primary_keyword: 'podcast'
      )
      expect(result[:warnings]).to include(a_string_matching(/meta title too short/i))
    end

    it 'penalizes long meta title' do
      result = rater.rate(
        content: good_content,
        meta_title: 'This is an extremely long meta title that definitely exceeds the recommended character limit for search engine display purposes',
        meta_description: 'A proper description.',
        primary_keyword: 'podcast'
      )
      expect(result[:warnings]).to include(a_string_matching(/meta title too long/i))
    end

    it 'penalizes missing keyword in meta title' do
      result = rater.rate(
        content: good_content,
        meta_title: 'Complete Guide to Audio Content Creation',
        meta_description: 'Learn everything about creating audio content.',
        primary_keyword: 'start a podcast'
      )
      expect(result[:warnings]).to include(a_string_matching(/keyword.*not in meta title/i))
    end
  end

  describe 'keyword optimization scoring' do
    it 'flags missing keyword in H1' do
      content_without_kw_in_h1 = good_content.sub('# How to Start a Podcast', '# Complete Audio Guide')
      result = rater.rate(content: content_without_kw_in_h1, primary_keyword: 'start a podcast')
      expect(result[:critical_issues]).to include(a_string_matching(/missing from H1/i))
    end

    it 'flags missing keyword in first 100 words' do
      content_without_early_kw = "# Podcast Guide\n\n" + ('Lorem ipsum dolor sit amet. ' * 20) + good_content
      result = rater.rate(content: content_without_early_kw, primary_keyword: 'start a podcast')
      expect(result[:critical_issues]).to include(a_string_matching(/first 100 words/i))
    end

    it 'flags high keyword density' do
      result = rater.rate(content: good_content, primary_keyword: 'podcast', keyword_density: 4.0)
      expect(result[:critical_issues]).to include(a_string_matching(/keyword density.*too high/i))
    end
  end

  describe 'structure scoring' do
    it 'flags missing H1' do
      content_without_h1 = good_content.gsub(/^# .+$/, '')
      result = rater.rate(content: content_without_h1, primary_keyword: 'podcast')
      expect(result[:critical_issues]).to include(a_string_matching(/missing H1/i))
    end

    it 'flags multiple H1s' do
      content_with_multiple_h1 = "# First H1\n\n#{good_content}"
      result = rater.rate(content: content_with_multiple_h1, primary_keyword: 'podcast')
      expect(result[:critical_issues]).to include(a_string_matching(/multiple H1/i))
    end

    it 'flags too few H2 sections' do
      simple_content = "# Title\n\nJust some content without sections."
      result = rater.rate(content: simple_content, primary_keyword: 'test')
      expect(result[:warnings]).to include(a_string_matching(/too few H2/i))
    end
  end

  describe 'link scoring' do
    it 'flags too few internal links' do
      result = rater.rate(content: good_content, primary_keyword: 'podcast', internal_link_count: 0)
      expect(result[:warnings]).to include(a_string_matching(/internal links/i))
    end

    it 'flags too few external links' do
      result = rater.rate(content: good_content, primary_keyword: 'podcast', external_link_count: 0)
      expect(result[:warnings]).to include(a_string_matching(/external links/i))
    end
  end

  describe 'custom guidelines' do
    it 'allows custom word count requirements' do
      custom_rater = described_class.new(guidelines: { min_word_count: 500 })
      result = custom_rater.rate(content: good_content, primary_keyword: 'podcast')
      expect(result[:critical_issues]).not_to include(a_string_matching(/too short/i))
    end

    it 'allows custom link requirements' do
      custom_rater = described_class.new(guidelines: { min_internal_links: 10 })
      result = custom_rater.rate(content: good_content, primary_keyword: 'podcast', internal_link_count: 5)
      expect(result[:warnings]).to include(a_string_matching(/internal links/i))
    end
  end
end
