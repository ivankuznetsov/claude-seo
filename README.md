# SEO Machine

A Claude Code-powered workspace for creating long-form, SEO-optimized blog content. Features real-time web search, AI-powered humanization, fact-checking, and comprehensive SEO analysis.

## Overview

SEO Machine provides:

- **Smart Commands**: `/research`, `/write`, `/rewrite`, `/humanize`, `/fact-check`, `/optimize`, `/analyze-existing`
- **Web Search Integration**: Real-time data gathering for research and fact verification
- **AI Humanization**: Remove AI writing patterns for natural-sounding content
- **Specialized Agents**: Content analysis, SEO optimization, meta creation, internal linking, search intent analysis (LLM-powered)
- **Ruby Analysis Modules**: Keyword density, readability scoring, SEO quality rating, content comparison
- **Data Integrations**: Google Analytics 4, Google Search Console, DataForSEO
- **Context-Driven**: Brand voice, style guides, and examples guide all content

## Quick Start

### Prerequisites
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- Ruby 3.0+ (for analysis modules)

### Installation

```bash
# Clone the repository
git clone https://github.com/[your-username]/seomachine.git
cd seomachine

# Install Ruby dependencies
cd data_sources/ruby
bundle install
cd ../..

# Open in Claude Code
claude .
```

### Configure Context Files

Customize templates in `context/` with your company info:

| File | Purpose |
|------|---------|
| `brand-voice.md` | Your brand voice and messaging |
| `writing-examples.md` | 3-5 exemplary blog posts |
| `style-guide.md` | Editorial standards |
| `seo-guidelines.md` | SEO requirements |
| `target-keywords.md` | Keyword clusters |
| `internal-links-map.md` | Key pages for linking |

## Commands

### `/research [topic]`
Comprehensive keyword and competitive research with **web search**.

```
/research podcast monetization strategies
```

**Features**:
- Real-time web search for current data and trends
- LLM-powered search intent analysis (Haiku 4.5)
- Competitor content analysis
- Content gap identification
- Research brief saved to `research/`

---

### `/write [topic]`
Create SEO-optimized long-form articles (2000-3000+ words).

```
/write podcast monetization strategies
```

**Features**:
- Web search for statistics and sources
- Brand voice integration
- Keyword optimization
- Internal/external linking
- Auto-triggers analysis agents
- Saved to `drafts/`

---

### `/humanize [file or text]`
Remove AI writing patterns for natural-sounding content.

```
/humanize drafts/my-article.md
```

**Detects and removes**:
- Inflated language ("pivotal", "testament", "crucial")
- AI vocabulary ("Additionally", "landscape", "delve", "multifaceted")
- Em-dash overuse
- Copula avoidance ("serves as" → "is")
- Sycophantic tone
- Chatbot artifacts
- Filler phrases and excessive hedging

Based on [Wikipedia's AI Cleanup guidelines](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing).

---

### `/fact-check [file or text]`
Verify claims and statistics using web search.

```
/fact-check drafts/my-article.md
```

**Features**:
- Extracts factual claims and statistics
- Web search for verification
- Source credibility evaluation
- Correction suggestions with citations
- Fact-check report saved to `drafts/`

---

### `/rewrite [topic]`
Update and improve existing content.

```
/rewrite podcast monetization guide
```

---

### `/analyze-existing [URL or file]`
Analyze content for improvement opportunities.

```
/analyze-existing https://yoursite.com/blog/article
```

---

### `/optimize [file]`
Final SEO optimization before publishing.

```
/optimize drafts/my-article.md
```

## Agents

### Search Intent Analyzer (LLM-Powered)
Uses **Haiku 4.5** for accurate intent classification:
- **Informational**: Learning intent (how-to, guides)
- **Navigational**: Finding specific sites
- **Transactional**: Ready to purchase
- **Commercial Investigation**: Comparing options

### Content Analyzer
Comprehensive analysis using Ruby modules:
- Keyword density and distribution
- Readability scoring (Flesch, Flesch-Kincaid)
- SEO quality rating (0-100)
- Content length comparison vs SERP competitors

### Other Agents
- **SEO Optimizer**: On-page SEO recommendations
- **Meta Creator**: Title/description generation
- **Internal Linker**: Strategic linking suggestions
- **Keyword Mapper**: Keyword placement analysis
- **Editor**: Humanity score and voice improvements

## Ruby Analysis Modules

Located in `data_sources/ruby/lib/seo_machine/`:

| Module | Purpose |
|--------|---------|
| `keyword_analyzer.rb` | Density, clustering, LSI keywords |
| `readability_scorer.rb` | Flesch scores, complexity analysis |
| `seo_quality_rater.rb` | SEO scoring (0-100) |
| `search_intent_analyzer.rb` | Pattern-based intent (fallback) |
| `content_length_comparator.rb` | SERP competitor analysis |
| `content_scrubber.rb` | AI watermark removal |
| `google_analytics.rb` | GA4 integration |
| `google_search_console.rb` | GSC integration |
| `data_for_seo.rb` | DataForSEO API |
| `data_aggregator.rb` | Multi-source aggregation |

### Running Tests

```bash
cd data_sources/ruby
bundle exec ruby -Itest test/*_test.rb
```

## Directory Structure

```
seomachine/
├── .claude/
│   ├── commands/              # Workflow commands
│   │   ├── research.md        # Web search + research
│   │   ├── write.md           # Web search + writing
│   │   ├── humanize.md        # AI pattern removal
│   │   ├── fact-check.md      # Claim verification
│   │   ├── rewrite.md
│   │   ├── optimize.md
│   │   ├── analyze-existing.md
│   │   └── scrub.md
│   └── agents/                # Analysis agents
│       ├── search-intent-analyzer.md  # LLM-powered
│       ├── content-analyzer.md
│       ├── seo-optimizer.md
│       ├── meta-creator.md
│       ├── internal-linker.md
│       ├── keyword-mapper.md
│       ├── editor.md
│       └── performance.md
├── data_sources/
│   ├── ruby/                  # Ruby analysis modules
│   │   ├── lib/seo_machine/   # Module source
│   │   ├── test/              # Minitest tests
│   │   └── Gemfile
│   ├── modules/               # Python modules (legacy)
│   └── config/                # API credentials
├── context/                   # Configuration templates
├── topics/                    # Topic ideas
├── research/                  # Research briefs
├── drafts/                    # Work in progress
├── published/                 # Final content
└── rewrites/                  # Updated content
```

## Data Source Setup

### Google Analytics 4
```bash
export GA4_PROPERTY_ID="your-property-id"
export GA4_CREDENTIALS_PATH="path/to/credentials.json"
```

### Google Search Console
```bash
export GSC_SITE_URL="https://yoursite.com"
export GSC_CREDENTIALS_PATH="path/to/credentials.json"
```

### DataForSEO
```bash
export DATAFORSEO_LOGIN="your-login"
export DATAFORSEO_PASSWORD="your-password"
```

## Workflow Example

### Creating New Content

```bash
# 1. Research with web search
/research podcast monetization

# 2. Write article with web search for data
/write podcast monetization

# 3. Remove AI patterns
/humanize drafts/podcast-monetization-2025-01-31.md

# 4. Verify facts
/fact-check drafts/podcast-monetization-2025-01-31.md

# 5. Final optimization
/optimize drafts/podcast-monetization-2025-01-31.md
```

### Updating Existing Content

```bash
# 1. Analyze current performance
/analyze-existing https://yoursite.com/blog/old-article

# 2. Rewrite with improvements
/rewrite old article topic

# 3. Humanize and fact-check
/humanize rewrites/old-article-rewrite.md
/fact-check rewrites/old-article-rewrite.md
```

## Content Quality Standards

### SEO Requirements
- Primary keyword density: 1-2%
- Keyword in: H1, first 100 words, 2-3 H2s
- Internal links: 3-5 with descriptive anchor text
- External links: 2-3 authoritative sources
- Meta title: 50-60 characters
- Meta description: 150-160 characters

### Readability
- Reading level: 8th-10th grade
- Sentence length: 15-20 words average
- Paragraphs: 2-4 sentences
- Subheadings: Every 300-400 words

### Humanization Checklist
- No AI vocabulary ("Additionally", "landscape", "delve")
- No excessive em-dashes
- Natural sentence variation
- Specific examples over generic statements
- First-person perspective where appropriate

## Key Features

### Web Search Integration
- Real-time data for `/research` and `/write`
- Automatic fact verification with `/fact-check`
- Current statistics and trends
- Authoritative source discovery

### AI Humanization
Based on 24 AI writing patterns from Wikipedia's cleanup guidelines:
- Content patterns (inflated language, vague attributions)
- Language patterns (AI vocabulary, copula avoidance)
- Style patterns (em-dash overuse, formatting issues)
- Communication patterns (chatbot artifacts)

### LLM-Powered Analysis
Search intent analyzer uses Haiku 4.5 for:
- Accurate intent classification
- Confidence scoring
- Content format recommendations
- Detailed reasoning

## Contributing

Contributions welcome! Please:
- Report issues via GitHub Issues
- Submit PRs for improvements
- Share workflow examples

## License

MIT License - See LICENSE file

---

Built with [Claude Code](https://docs.anthropic.com/en/docs/claude-code) by Anthropic.
