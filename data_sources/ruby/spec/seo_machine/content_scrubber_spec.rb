# frozen_string_literal: true

RSpec.describe SeoMachine::ContentScrubber do
  subject(:scrubber) { described_class.new }

  describe '#scrub' do
    context 'with Unicode watermarks' do
      let(:content_with_watermarks) do
        "This is a test\u200Bcontent with invisible\uFEFF characters.\u200CMore text here."
      end

      it 'removes zero-width spaces' do
        cleaned, stats = scrubber.scrub(content_with_watermarks)
        expect(cleaned).not_to include("\u200B")
      end

      it 'removes BOM characters' do
        cleaned, stats = scrubber.scrub(content_with_watermarks)
        expect(cleaned).not_to include("\uFEFF")
      end

      it 'removes zero-width non-joiners' do
        cleaned, stats = scrubber.scrub(content_with_watermarks)
        expect(cleaned).not_to include("\u200C")
      end

      it 'reports number of characters removed' do
        _, stats = scrubber.scrub(content_with_watermarks)
        expect(stats[:unicode_removed] + stats[:format_control_removed]).to be > 0
      end
    end

    context 'with em-dashes' do
      let(:content_with_emdashes) do
        <<~CONTENT
          Here's a sentence—it has an em-dash.
          This is important—you should remember it.
          The result—however surprising—was clear.
        CONTENT
      end

      it 'replaces em-dashes' do
        cleaned, stats = scrubber.scrub(content_with_emdashes)
        expect(cleaned).not_to include('—')
      end

      it 'reports number of em-dashes replaced' do
        _, stats = scrubber.scrub(content_with_emdashes)
        expect(stats[:emdashes_replaced]).to be > 0
      end

      it 'replaces with contextually appropriate punctuation' do
        cleaned, _ = scrubber.scrub(content_with_emdashes)
        # Should contain comma, semicolon, or period instead
        expect(cleaned).to match(/[,;.]/)
      end
    end

    context 'with format control characters' do
      let(:content_with_format_controls) do
        "Some text\u2060with\u2061invisible\u2062format\u2063controls."
      end

      it 'removes format control characters' do
        cleaned, stats = scrubber.scrub(content_with_format_controls)
        expect(stats[:format_control_removed]).to be > 0
        expect(cleaned).to eq('Some textwith invisible formatcontrols.')
      end
    end

    context 'with multiple issues' do
      let(:complex_content) do
        "Test\u200B content—with multiple\uFEFF issues\u200C here—to clean up."
      end

      it 'handles all issues in one pass' do
        cleaned, stats = scrubber.scrub(complex_content)
        expect(cleaned).not_to include("\u200B")
        expect(cleaned).not_to include("\uFEFF")
        expect(cleaned).not_to include("\u200C")
        expect(cleaned).not_to include('—')
      end
    end

    context 'whitespace cleanup' do
      let(:content_with_bad_whitespace) do
        "Multiple   spaces  here.And no space after punctuation.\n\n\n\n\nToo many newlines."
      end

      it 'removes extra spaces' do
        cleaned, _ = scrubber.scrub(content_with_bad_whitespace)
        expect(cleaned).not_to include('  ')
      end

      it 'reduces excessive newlines' do
        cleaned, _ = scrubber.scrub(content_with_bad_whitespace)
        expect(cleaned).not_to match(/\n{3,}/)
      end

      it 'adds space after punctuation when missing' do
        cleaned, _ = scrubber.scrub(content_with_bad_whitespace)
        expect(cleaned).to include('punctuation. And') # Space added after period
      end
    end
  end

  describe '.scrub_content' do
    it 'returns cleaned content string' do
      content = "Test\u200B content"
      result = described_class.scrub_content(content)
      expect(result).to be_a(String)
      expect(result).not_to include("\u200B")
    end

    context 'with verbose option' do
      it 'outputs statistics when verbose' do
        content = "Test\u200B content—with dash"
        expect { described_class.scrub_content(content, verbose: true) }.to output(/Content Scrubbing Complete/).to_stdout
      end
    end
  end

  describe 'em-dash replacement logic' do
    it 'uses comma for simple separation' do
      content = "This is great—you'll love it"
      cleaned, _ = scrubber.scrub(content)
      expect(cleaned).to include(',')
    end

    it 'uses semicolon for independent clauses' do
      content = 'I tried everything—nothing worked'
      cleaned, _ = scrubber.scrub(content)
      # Could be comma or semicolon depending on context
      expect(cleaned).to match(/[,;]/)
    end

    it 'handles em-dash at end of sentence' do
      content = 'This was the result—.'
      cleaned, _ = scrubber.scrub(content)
      expect(cleaned).not_to include('—')
    end
  end

  describe 'edge cases' do
    it 'handles empty content' do
      cleaned, stats = scrubber.scrub('')
      expect(cleaned).to eq('')
      expect(stats[:unicode_removed]).to eq(0)
    end

    it 'handles content without any issues' do
      clean_content = 'This is perfectly clean content without any issues.'
      cleaned, stats = scrubber.scrub(clean_content)
      expect(cleaned).to eq(clean_content)
      expect(stats[:unicode_removed]).to eq(0)
      expect(stats[:emdashes_replaced]).to eq(0)
    end

    it 'preserves legitimate dashes' do
      content = 'Use a well-known technique or a state-of-the-art method.'
      cleaned, _ = scrubber.scrub(content)
      expect(cleaned).to include('-')
    end

    it 'handles mixed content with markdown' do
      content = "# Header\n\nParagraph\u200B with issues—and em-dashes.\n\n## Subheader"
      cleaned, _ = scrubber.scrub(content)
      expect(cleaned).to include('# Header')
      expect(cleaned).to include('## Subheader')
    end
  end

  describe 'idempotency' do
    let(:content_with_issues) do
      "Test\u200B content—with issues."
    end

    it 'produces same result when run multiple times' do
      first_clean, _ = scrubber.scrub(content_with_issues)
      second_clean, _ = scrubber.scrub(first_clean)
      expect(second_clean).to eq(first_clean)
    end
  end
end
