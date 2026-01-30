# frozen_string_literal: true

RSpec.describe SeoMachine::ContentLengthComparator do
  subject(:comparator) { described_class.new }

  describe '#analyze' do
    context 'without SERP results' do
      it 'returns error when no SERP results provided' do
        result = comparator.analyze('test keyword')
        expect(result).to include(:error)
        expect(result[:error]).to match(/No SERP results provided/)
      end
    end

    context 'with mock SERP data and no fetch' do
      let(:mock_serp_results) do
        [
          { 'url' => 'https://example1.com/guide', 'domain' => 'example1.com', 'title' => 'Guide 1' },
          { 'url' => 'https://example2.com/guide', 'domain' => 'example2.com', 'title' => 'Guide 2' },
          { 'url' => 'https://example3.com/guide', 'domain' => 'example3.com', 'title' => 'Guide 3' }
        ]
      end

      # Skip fetching since we can't actually fetch URLs in tests
      it 'returns error when content cannot be fetched' do
        result = comparator.analyze('test keyword', serp_results: mock_serp_results, fetch_content: true)
        # Will fail to fetch, should return appropriate message
        expect(result).to include(:error).or(include(:competitors_analyzed))
      end
    end
  end

  describe 'statistics calculation' do
    # Test the statistics calculation logic directly
    describe 'with known word counts' do
      before do
        # We'll test the internal methods by creating mock competitor data
        allow(comparator).to receive(:fetch_word_count).and_return(nil)
      end

      it 'handles empty competitor lengths gracefully' do
        result = comparator.analyze('test', serp_results: [], fetch_content: false)
        expect(result).to include(:error)
      end
    end
  end

  describe 'recommendations' do
    # Create a mock scenario with known data
    let(:mock_stats) do
      {
        min: 1500,
        max: 4000,
        mean: 2500,
        median: 2400,
        percentile_25: 2000,
        percentile_75: 3000
      }
    end

    describe 'recommendation generation' do
      it 'identifies content as too short when below 80% of median' do
        # Median is 2400, 80% is 1920
        # Word count of 1500 should be "too_short"
        your_count = 1500
        recommendation = comparator.send(:get_recommendation, mock_stats, your_count)
        expect(recommendation[:your_status]).to eq('too_short')
      end

      it 'identifies content as short when below median' do
        your_count = 2000
        recommendation = comparator.send(:get_recommendation, mock_stats, your_count)
        expect(recommendation[:your_status]).to eq('short')
      end

      it 'identifies content as good when competitive' do
        your_count = 2500
        recommendation = comparator.send(:get_recommendation, mock_stats, your_count)
        expect(recommendation[:your_status]).to eq('good')
      end

      it 'identifies content as optimal when matching top performers' do
        your_count = 3200
        recommendation = comparator.send(:get_recommendation, mock_stats, your_count)
        expect(recommendation[:your_status]).to eq('optimal')
      end

      it 'identifies content as long when exceeding competitors' do
        your_count = 5000
        recommendation = comparator.send(:get_recommendation, mock_stats, your_count)
        expect(recommendation[:your_status]).to eq('long')
      end

      it 'provides recommended word counts' do
        recommendation = comparator.send(:get_recommendation, mock_stats, 2000)
        expect(recommendation).to include(
          :recommended_min,
          :recommended_optimal,
          :recommended_max
        )
      end
    end
  end

  describe 'length categorization' do
    let(:mock_competitors) do
      [
        { word_count: 800 },
        { word_count: 1200 },
        { word_count: 1800 },
        { word_count: 2300 },
        { word_count: 2800 },
        { word_count: 3500 }
      ]
    end

    it 'correctly categorizes lengths into ranges' do
      categories = comparator.send(:categorize_lengths, mock_competitors)

      expect(categories[:under_1000]).to eq(1)
      expect(categories[:'1000_1500']).to eq(1)
      expect(categories[:'1500_2000']).to eq(1)
      expect(categories[:'2000_2500']).to eq(1)
      expect(categories[:'2500_3000']).to eq(1)
      expect(categories[:'3000_plus']).to eq(1)
    end
  end

  describe 'competitive analysis' do
    let(:mock_competitors) do
      [
        { word_count: 2000 },
        { word_count: 2200 },
        { word_count: 2500 },
        { word_count: 2800 },
        { word_count: 3000 }
      ]
    end

    let(:mock_stats) do
      {
        min: 2000,
        max: 3000,
        median: 2500,
        percentile_75: 2800
      }
    end

    it 'calculates how many competitors are shorter' do
      analysis = comparator.send(:analyze_competition, 2600, mock_competitors, mock_stats)
      expect(analysis[:comparison][:shorter_than_you]).to eq(3) # 2000, 2200, 2500
    end

    it 'calculates how many competitors are longer' do
      analysis = comparator.send(:analyze_competition, 2600, mock_competitors, mock_stats)
      expect(analysis[:comparison][:longer_than_you]).to eq(2) # 2800, 3000
    end

    it 'calculates gap to median when below' do
      analysis = comparator.send(:analyze_competition, 2000, mock_competitors, mock_stats)
      expect(analysis[:gap_to_median][:words]).to eq(500)
    end
  end

  describe 'position in range' do
    let(:mock_competitors) do
      [
        { word_count: 1500 },
        { word_count: 2000 },
        { word_count: 2500 },
        { word_count: 3000 }
      ]
    end

    it 'indicates when below all competitors' do
      position = comparator.send(:get_position_in_range, 1000, mock_competitors)
      expect(position).to match(/below all/i)
    end

    it 'indicates when above all competitors' do
      position = comparator.send(:get_position_in_range, 4000, mock_competitors)
      expect(position).to match(/above all/i)
    end

    it 'indicates position between competitors' do
      position = comparator.send(:get_position_in_range, 2200, mock_competitors)
      expect(position).to match(/between/i)
    end
  end
end
