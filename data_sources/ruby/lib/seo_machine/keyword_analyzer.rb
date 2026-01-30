# frozen_string_literal: true

module SeoMachine
  # Keyword Analyzer
  # Calculates keyword density, analyzes distribution, and performs semantic clustering
  # to identify keyword usage patterns and topic clusters within content.
  class KeywordAnalyzer
    STOP_WORDS = %w[
      a an and are as at be by for from has he in is it its of on that the
      to was will with you your this their but or not can have all when there
      been if more so about what which who would could
    ].freeze

    attr_reader :stop_words

    def initialize
      @stop_words = STOP_WORDS.to_set
    end

    # Comprehensive keyword analysis
    #
    # @param content [String] Article content to analyze
    # @param primary_keyword [String] Main target keyword
    # @param secondary_keywords [Array<String>] List of secondary keywords
    # @param target_density [Float] Target keyword density percentage (default 1.5%)
    # @return [Hash] Density metrics, distribution map, and recommendations
    def analyze(content, primary_keyword, secondary_keywords: [], target_density: 1.5)
      word_count = content.split.length
      sections = extract_sections(content)

      # Analyze primary keyword
      primary_analysis = analyze_keyword(content, primary_keyword, word_count, sections, target_density)

      # Analyze secondary keywords
      secondary_analysis = secondary_keywords.map do |keyword|
        analyze_keyword(content, keyword, word_count, sections, target_density * 0.5)
      end

      # Detect keyword stuffing
      stuffing_risk = detect_keyword_stuffing(content, primary_keyword, primary_analysis[:density])

      # Perform topic clustering
      clusters = perform_clustering(content, sections)

      # Distribution heatmap
      heatmap = create_distribution_heatmap(primary_keyword, sections)

      # LSI/semantic keyword suggestions
      lsi_keywords = find_lsi_keywords(content, primary_keyword)

      {
        word_count: word_count,
        primary_keyword: { keyword: primary_keyword }.merge(primary_analysis),
        secondary_keywords: secondary_analysis,
        keyword_stuffing: stuffing_risk,
        topic_clusters: clusters,
        distribution_heatmap: heatmap,
        lsi_keywords: lsi_keywords,
        recommendations: generate_recommendations(
          primary_analysis,
          secondary_analysis,
          stuffing_risk,
          target_density
        )
      }
    end

    private

    # Analyze a single keyword
    def analyze_keyword(content, keyword, word_count, sections, target_density)
      content_lower = content.downcase
      keyword_lower = keyword.downcase

      # Count exact matches
      exact_count = content_lower.scan(keyword_lower).length

      # Count variations for multi-word keywords
      variation_count = 0
      keyword_words = keyword_lower.split
      if keyword_words.length > 1
        pattern = Regexp.new("\\b(?:#{keyword_words.join('|')})\\b", Regexp::IGNORECASE)
        matches = content_lower.scan(pattern)
        variation_count = matches.length - (exact_count * keyword_words.length)
      end

      total_count = exact_count + (keyword_words.length > 1 ? variation_count / keyword_words.length : 0)

      # Calculate density
      density = word_count.positive? ? (total_count.to_f / word_count * 100) : 0

      # Find positions
      positions = find_keyword_positions(content, keyword)

      # Check critical placements
      critical_placements = check_critical_placements(content, sections, keyword)

      # Distribution across sections
      section_distribution = analyze_section_distribution(sections, keyword)

      {
        exact_matches: exact_count,
        total_occurrences: total_count,
        density: density.round(2),
        target_density: target_density,
        density_status: get_density_status(density, target_density),
        positions: positions,
        critical_placements: critical_placements,
        section_distribution: section_distribution
      }
    end

    # Extract sections with headers from content
    def extract_sections(content)
      sections = []
      lines = content.split("\n")
      current_section = { type: 'intro', header: '', content: '', start_pos: 0 }
      current_pos = 0

      lines.each do |line|
        h1_match = line.match(/^#\s+(.+)$/)
        h2_match = line.match(/^##\s+(.+)$/)
        h3_match = line.match(/^###\s+(.+)$/)

        if h1_match || h2_match || h3_match
          # Save previous section
          if current_section[:content].length.positive?
            current_section[:end_pos] = current_pos
            sections << current_section.dup
          end

          # Start new section
          header = if h1_match
                     h1_match[1]
                   elsif h2_match
                     h2_match[1]
                   else
                     h3_match[1]
                   end
          header_type = if h1_match
                          'h1'
                        elsif h2_match
                          'h2'
                        else
                          'h3'
                        end

          current_section = {
            type: header_type,
            header: header,
            content: '',
            start_pos: current_pos
          }
        else
          current_section[:content] += "#{line}\n"
        end

        current_pos += line.length + 1
      end

      # Add last section
      if current_section[:content].length.positive?
        current_section[:end_pos] = current_pos
        sections << current_section
      end

      sections
    end

    # Find all positions where keyword appears
    def find_keyword_positions(content, keyword)
      positions = []
      content_lower = content.downcase
      keyword_lower = keyword.downcase

      start = 0
      while (pos = content_lower.index(keyword_lower, start))
        positions << pos
        start = pos + 1
      end

      positions
    end

    # Check if keyword appears in critical locations
    def check_critical_placements(content, sections, keyword)
      content_lower = content.downcase
      keyword_lower = keyword.downcase

      # First 100 words
      first_100 = content.split.first(100).join(' ').downcase
      in_first_100 = first_100.include?(keyword_lower)

      # Last paragraph (conclusion)
      paragraphs = content.split(/\n\n+/)
      last_para = paragraphs.last&.downcase || content.last(500).downcase
      in_conclusion = last_para.include?(keyword_lower)

      # H1 (first heading)
      in_h1 = sections.any? && sections.first[:header].downcase.include?(keyword_lower)

      # H2 headings
      h2_count = 0
      h2_with_keyword = 0
      sections.each do |section|
        next unless section[:type] == 'h2'

        h2_count += 1
        h2_with_keyword += 1 if section[:header].downcase.include?(keyword_lower)
      end

      {
        in_first_100_words: in_first_100,
        in_conclusion: in_conclusion,
        in_h1: in_h1,
        in_h2_headings: "#{h2_with_keyword}/#{h2_count}",
        h2_keyword_ratio: h2_count.positive? ? (h2_with_keyword.to_f / h2_count) : 0
      }
    end

    # Analyze how keyword is distributed across sections
    def analyze_section_distribution(sections, keyword)
      keyword_lower = keyword.downcase

      sections.map.with_index do |section, i|
        section_text = "#{section[:header]} #{section[:content]}".downcase
        count = section_text.scan(keyword_lower).length
        word_count = section_text.split.length

        {
          section_index: i,
          section_type: section[:type],
          header: section[:header][0, 50],
          keyword_count: count,
          word_count: word_count,
          density: word_count.positive? ? (count.to_f / word_count * 100).round(2) : 0
        }
      end
    end

    # Determine if density is appropriate
    def get_density_status(actual, target)
      if actual < target * 0.5
        'too_low'
      elsif actual < target * 0.8
        'slightly_low'
      elsif actual <= target * 1.2
        'optimal'
      elsif actual <= target * 1.5
        'slightly_high'
      else
        'too_high'
      end
    end

    # Detect potential keyword stuffing
    def detect_keyword_stuffing(content, keyword, density)
      keyword_lower = keyword.downcase
      risk_level = 'none'
      warnings = []

      # High density check
      if density > 3.0
        risk_level = 'high'
        warnings << "Keyword density #{density}% is very high (over 3%)"
      elsif density > 2.5
        risk_level = 'medium'
        warnings << "Keyword density #{density}% is high (over 2.5%)"
      end

      # Check for keyword clustering in paragraphs
      paragraphs = content.split(/\n\n+/)
      paragraphs.each_with_index do |para, i|
        count = para.downcase.scan(keyword_lower).length
        words = para.split.length
        next unless words.positive?

        para_density = (count.to_f / words * 100)
        next unless para_density > 5

        risk_level = 'high' if risk_level == 'medium'
        warnings << "Paragraph #{i + 1} has very high keyword density (#{para_density.round(1)}%)"
      end

      # Check for unnatural repetition (keyword in consecutive sentences)
      sentences = content.split(/[.!?]+/)
      consecutive = 0
      max_consecutive = 0
      sentences.each do |sentence|
        if sentence.downcase.include?(keyword_lower)
          consecutive += 1
          max_consecutive = [max_consecutive, consecutive].max
        else
          consecutive = 0
        end
      end

      if max_consecutive >= 5
        risk_level = 'high'
        warnings << "Keyword appears in #{max_consecutive} consecutive sentences"
      elsif max_consecutive >= 3
        risk_level = 'low' if risk_level == 'none'
        warnings << "Keyword appears in #{max_consecutive} consecutive sentences"
      end

      {
        risk_level: risk_level,
        warnings: warnings,
        safe: %w[none low].include?(risk_level)
      }
    end

    # Perform topic clustering to identify content themes
    def perform_clustering(content, sections)
      section_texts = sections.select { |s| s[:content].split.length > 10 }
                              .map { |s| "#{s[:header]} #{s[:content]}" }

      return { clusters_found: 0, note: 'Insufficient sections for clustering' } if section_texts.length < 3

      # Simple term frequency-based clustering
      # Get top terms from each section
      section_terms = section_texts.map do |text|
        words = text.downcase.scan(/\b[a-z]{4,}\b/)
        word_freq = words.tally
        word_freq.reject! { |word, _| @stop_words.include?(word) }
        word_freq.sort_by { |_, freq| -freq }.first(10).to_h
      end

      # Group sections by common terms
      n_clusters = [5, [2, section_texts.length / 2].max].min
      clusters = []

      # Simple clustering by finding common terms
      all_terms = section_terms.flat_map(&:keys).tally
      top_terms = all_terms.sort_by { |_, freq| -freq }.first(20).map(&:first)

      n_clusters.times do |i|
        cluster_terms = top_terms[i * 4, 4] || []
        sections_in_cluster = section_terms.each_index.select do |j|
          cluster_terms.any? { |term| section_terms[j].key?(term) }
        end

        clusters << {
          cluster_id: i,
          top_terms: cluster_terms,
          section_count: sections_in_cluster.length,
          sections: sections_in_cluster
        }
      end

      {
        clusters_found: clusters.length,
        clusters: clusters
      }
    rescue StandardError => e
      { clusters_found: 0, error: e.message }
    end

    # Create visual representation of keyword distribution
    def create_distribution_heatmap(keyword, sections)
      keyword_lower = keyword.downcase

      sections.map.with_index do |section, i|
        section_text = "#{section[:header]} #{section[:content]}".downcase
        count = section_text.scan(keyword_lower).length
        word_count = section_text.split.length
        density = word_count.positive? ? (count.to_f / word_count * 100) : 0

        heat = case density
               when 0 then 0
               when 0...0.5 then 1
               when 0.5...1.0 then 2
               when 1.0...2.0 then 3
               when 2.0...3.0 then 4
               else 5
               end

        {
          section: section[:header][0, 40].empty? ? "Section #{i + 1}" : section[:header][0, 40],
          keyword_count: count,
          heat_level: heat,
          density: density.round(2)
        }
      end
    end

    # Find LSI (Latent Semantic Indexing) keywords - semantically related terms
    def find_lsi_keywords(content, primary_keyword)
      # Extract common words
      words = content.downcase.scan(/\b[a-z]{4,}\b/)
      word_freq = words.tally

      # Remove stop words and primary keyword terms
      primary_terms = primary_keyword.downcase.split.to_set
      filtered_words = word_freq.reject do |word, _|
        @stop_words.include?(word) || primary_terms.include?(word)
      end

      # Get top terms
      top_terms = filtered_words.sort_by { |_, freq| -freq }.first(20).map(&:first)

      # Extract bigrams and trigrams
      sentences = content.downcase.split(/[.!?]+/)
      phrases = []

      sentences.each do |sentence|
        words = sentence.split
        # Bigrams
        (0...words.length - 1).each do |i|
          phrase = "#{words[i]} #{words[i + 1]}"
          next unless phrase.length > 8 && words[i, 2].none? { |w| @stop_words.include?(w) }

          phrases << phrase
        end
        # Trigrams
        (0...words.length - 2).each do |i|
          phrase = "#{words[i]} #{words[i + 1]} #{words[i + 2]}"
          next unless phrase.length > 12 && words[i, 3].none? { |w| @stop_words.include?(w) }

          phrases << phrase
        end
      end

      phrase_freq = phrases.tally
      top_phrases = phrase_freq.sort_by { |_, freq| -freq }.first(10).map(&:first)

      # Combine and return
      (top_terms.first(10) + top_phrases.first(5)).first(15)
    rescue StandardError
      []
    end

    # Generate actionable recommendations
    def generate_recommendations(primary_analysis, secondary_analysis, stuffing_risk, target_density)
      recommendations = []

      # Primary keyword density
      status = primary_analysis[:density_status]
      case status
      when 'too_low'
        recommendations << "Primary keyword density is too low (#{primary_analysis[:density]}%). " \
                           "Target is #{target_density}%. Add #{primary_analysis[:keyword]} naturally in more paragraphs."
      when 'slightly_low'
        recommendations << "Primary keyword density is slightly low (#{primary_analysis[:density]}%). " \
                           "Consider adding a few more mentions of '#{primary_analysis[:keyword]}'."
      when 'too_high'
        recommendations << "Primary keyword density is too high (#{primary_analysis[:density]}%). " \
                           'This may trigger keyword stuffing penalties. Remove some instances or replace with variations.'
      when 'slightly_high'
        recommendations << "Primary keyword density is slightly high (#{primary_analysis[:density]}%). " \
                           'Consider using more keyword variations or synonyms.'
      end

      # Critical placements
      placements = primary_analysis[:critical_placements]
      recommendations << 'Primary keyword missing from first 100 words - add it to the introduction' unless placements[:in_first_100_words]
      recommendations << 'Primary keyword missing from H1 headline - include it in the title' unless placements[:in_h1]

      if placements[:h2_keyword_ratio] < 0.33
        recommendations << "Primary keyword appears in only #{placements[:in_h2_headings]} H2 headings. " \
                           'Aim for 2-3 H2s with keyword variations.'
      end

      unless placements[:in_conclusion]
        recommendations << 'Consider mentioning primary keyword in the conclusion for better optimization'
      end

      # Keyword stuffing
      unless stuffing_risk[:safe]
        recommendations << "KEYWORD STUFFING RISK: #{stuffing_risk[:risk_level].upcase} - #{stuffing_risk[:warnings].join('; ')}"
      end

      # Secondary keywords
      secondary_analysis.each do |analysis|
        if analysis[:total_occurrences].zero?
          recommendations << "Secondary keyword '#{analysis[:keyword]}' not found in content - consider adding it"
        end
      end

      recommendations
    end
  end
end
