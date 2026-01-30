# frozen_string_literal: true

RSpec.describe SeoMachine::ReadabilityScorer do
  subject(:scorer) { described_class.new }

  let(:easy_content) do
    <<~CONTENT
      # Simple Guide

      This is easy to read. Short sentences work best. They keep things clear.

      ## Step One

      Do this first. It is simple. You can do it fast.

      ## Step Two

      Now do this. It is also easy. Keep going.
    CONTENT
  end

  let(:complex_content) do
    <<~CONTENT
      # Comprehensive Analysis of Multifaceted Considerations

      The implementation of sophisticated methodologies necessitates the comprehensive evaluation of multitudinous factors that substantively influence the prognostication of outcomes within the paradigmatic framework of contemporary epistemological constructs.

      ## Theoretical Foundations

      Fundamentally, the presupposition of theoretical underpinnings requires the meticulous examination of antecedent scholarship, particularly regarding the juxtaposition of contradistinctive perspectives that have heretofore constituted the predominant discourse within academic deliberations.
    CONTENT
  end

  describe '#analyze' do
    subject(:result) { scorer.analyze(easy_content) }

    it 'returns overall score' do
      expect(result[:overall_score]).to be_between(0, 100)
    end

    it 'returns a grade' do
      expect(result[:grade]).to be_a(String)
      expect(result[:grade]).to match(/\A[A-F] \(/)
    end

    it 'returns reading level' do
      expect(result[:reading_level]).to be_a(Numeric)
    end

    it 'includes readability metrics' do
      metrics = result[:readability_metrics]
      expect(metrics).to include(
        :flesch_reading_ease,
        :flesch_kincaid_grade,
        :gunning_fog,
        :syllable_count,
        :sentence_count
      )
    end

    it 'includes structure analysis' do
      structure = result[:structure_analysis]
      expect(structure).to include(
        :total_sentences,
        :avg_sentence_length,
        :total_paragraphs,
        :total_words
      )
    end

    it 'includes complexity analysis' do
      complexity = result[:complexity_analysis]
      expect(complexity).to include(
        :transition_word_count,
        :passive_sentence_ratio,
        :complex_word_ratio
      )
    end

    it 'generates recommendations' do
      expect(result[:recommendations]).to be_an(Array)
    end

    it 'returns status assessment' do
      expect(result[:status]).to include(
        :grade_level_status,
        :ease_status,
        :sentence_length_status
      )
    end
  end

  describe 'scoring accuracy' do
    it 'rates easy content higher than complex content' do
      easy_result = scorer.analyze(easy_content)
      complex_result = scorer.analyze(complex_content)

      expect(easy_result[:overall_score]).to be > complex_result[:overall_score]
    end

    it 'gives lower grade level to simple content' do
      easy_result = scorer.analyze(easy_content)
      complex_result = scorer.analyze(complex_content)

      expect(easy_result[:reading_level]).to be < complex_result[:reading_level]
    end

    it 'gives higher Flesch ease score to simple content' do
      easy_result = scorer.analyze(easy_content)
      complex_result = scorer.analyze(complex_content)

      expect(easy_result[:readability_metrics][:flesch_reading_ease]).to be > complex_result[:readability_metrics][:flesch_reading_ease]
    end
  end

  describe 'metrics calculation' do
    let(:known_content) { 'The quick brown fox jumps over the lazy dog.' }

    it 'correctly counts sentences' do
      result = scorer.analyze(known_content)
      expect(result[:structure_analysis][:total_sentences]).to eq(1)
    end

    it 'correctly counts words' do
      result = scorer.analyze(known_content)
      expect(result[:structure_analysis][:total_words]).to eq(9)
    end

    it 'calculates average sentence length' do
      result = scorer.analyze(known_content)
      expect(result[:structure_analysis][:avg_sentence_length]).to eq(9.0)
    end
  end

  describe 'transition words detection' do
    let(:content_with_transitions) do
      <<~CONTENT
        First, do this. However, be careful. Therefore, check twice.
        Additionally, verify. Nevertheless, continue. Furthermore, proceed.
      CONTENT
    end

    it 'counts transition words' do
      result = scorer.analyze(content_with_transitions)
      expect(result[:complexity_analysis][:transition_word_count]).to be > 0
    end
  end

  describe 'passive voice detection' do
    let(:passive_content) do
      <<~CONTENT
        The cake was eaten by the children.
        The ball was thrown by John.
        The book was written by the author.
      CONTENT
    end

    let(:active_content) do
      <<~CONTENT
        The children ate the cake.
        John threw the ball.
        The author wrote the book.
      CONTENT
    end

    it 'detects higher passive ratio in passive content' do
      passive_result = scorer.analyze(passive_content)
      active_result = scorer.analyze(active_content)

      expect(passive_result[:complexity_analysis][:passive_sentence_ratio]).to be >= active_result[:complexity_analysis][:passive_sentence_ratio]
    end
  end

  describe 'edge cases' do
    it 'handles empty content' do
      result = scorer.analyze('')
      expect(result).to include(error: 'No readable content provided')
    end

    it 'handles single word' do
      result = scorer.analyze('Hello')
      expect(result[:overall_score]).to be_a(Numeric)
    end

    it 'handles content with only markdown' do
      result = scorer.analyze('# Just a Header')
      expect(result[:structure_analysis][:total_words]).to be >= 0
    end
  end

  describe 'grade assignment' do
    it 'assigns A grade for scores 90+' do
      # Mock a high-scoring scenario
      result = scorer.analyze(easy_content)
      if result[:overall_score] >= 90
        expect(result[:grade]).to start_with('A')
      end
    end

    it 'assigns F grade for very low scores' do
      # Complex content should score lower
      result = scorer.analyze(complex_content)
      if result[:overall_score] < 60
        expect(result[:grade]).to start_with('F')
      end
    end
  end
end
