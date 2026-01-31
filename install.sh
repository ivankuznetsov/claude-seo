#!/bin/bash
# Agent SEO - Installation Script

set -e

echo "Installing Agent SEO..."

# Check for Ruby
if ! command -v ruby &> /dev/null; then
    echo "Error: Ruby is required but not installed."
    echo "Please install Ruby 3.0+ and try again."
    exit 1
fi

# Check Ruby version
RUBY_VERSION=$(ruby -e 'puts RUBY_VERSION')
RUBY_MAJOR=$(echo $RUBY_VERSION | cut -d. -f1)
if [ "$RUBY_MAJOR" -lt 3 ]; then
    echo "Warning: Ruby 3.0+ recommended. Found Ruby $RUBY_VERSION"
fi

# Install Ruby dependencies
echo "Installing Ruby dependencies..."
cd data_sources/ruby
bundle install
cd ../..

# Create context directory if it doesn't exist
if [ ! -d "context" ]; then
    echo "Creating context directory with templates..."
    mkdir -p context

    cat > context/brand-voice.md << 'EOF'
# Brand Voice

## Tone
- Professional yet approachable
- Confident but not arrogant
- Helpful and educational

## Key Messages
- [Add your key brand messages]

## Vocabulary
- Preferred terms: [list]
- Avoid: [list]
EOF

    cat > context/style-guide.md << 'EOF'
# Style Guide

## Formatting
- Use sentence case for headings
- One space after periods
- Oxford comma: yes

## Structure
- Lead with the main point
- Use short paragraphs (2-4 sentences)
- Include subheadings every 300-400 words
EOF

    cat > context/seo-guidelines.md << 'EOF'
# SEO Guidelines

## Keyword Placement
- Primary keyword in H1
- Primary keyword in first 100 words
- Primary keyword in 2-3 H2s
- Keyword density: 1-2%

## Links
- 3-5 internal links per article
- 2-3 external links to authoritative sources
- Descriptive anchor text

## Meta Elements
- Title: 50-60 characters
- Description: 150-160 characters
EOF

    echo "Created template context files. Please customize them for your brand."
fi

# Create working directories
mkdir -p drafts published research rewrites topics

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "1. Customize context files in context/"
echo "2. Configure data sources (optional):"
echo "   - Google Analytics 4: export GA4_PROPERTY_ID=..."
echo "   - Google Search Console: export GSC_SITE_URL=..."
echo "   - DataForSEO: export DATAFORSEO_LOGIN=... DATAFORSEO_PASSWORD=..."
echo ""
echo "Available commands:"
echo "  /seo:research [topic]   - Research keywords and competitors"
echo "  /seo:write [topic]      - Write SEO-optimized article"
echo "  /seo:humanize [file]    - Remove AI writing patterns"
echo "  /seo:fact-check [file]  - Verify claims with web search"
echo "  /seo:optimize [file]    - Final SEO optimization"
echo "  /seo:data [type]        - Fetch performance data"
echo ""
