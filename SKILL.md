---
name: agent-seo
description: This skill provides a complete SEO content workflow for creating, analyzing, and optimizing long-form blog content. Use when the user wants to research topics, write SEO-optimized articles, humanize AI content, fact-check claims, or analyze content performance. Triggers on /research, /write, /humanize, /fact-check, /optimize, /rewrite, /analyze-existing, /scrub, /data, or /performance-review commands.
---

# Agent SEO

A comprehensive SEO content workflow for creating, analyzing, and optimizing long-form blog content with web search integration, AI humanization, and Ruby-based analysis tools.

## Quick Start

To install dependencies:

```bash
cd data_sources/ruby && bundle install
```

## Commands

### `/research [topic]`
Conduct keyword research and competitive analysis with web search.

**Process:**
1. Search the topic for current landscape, statistics, and trends
2. Analyze search intent using LLM (Haiku model)
3. Research competitor content ranking for target keywords
4. Identify content gaps and opportunities
5. Save research brief to `research/` directory

### `/write [topic]`
Create SEO-optimized long-form articles (2000-3000+ words).

**Process:**
1. Review research brief if available from `/research`
2. Load context files (brand voice, style guide, SEO guidelines)
3. Web search for statistics, examples, and authoritative sources
4. Write structured content with proper keyword placement
5. Run analysis agents (keyword, readability, SEO quality)
6. Apply AI humanization to remove telltale patterns
7. Save to `drafts/` directory

### `/humanize [file]`
Remove AI writing patterns for natural-sounding content.

**Detects and removes:**
- Inflated language ("pivotal", "testament", "crucial")
- AI vocabulary ("Additionally", "landscape", "delve", "multifaceted")
- Em-dash overuse
- Copula avoidance ("serves as" instead of "is")
- Sycophantic tone and chatbot artifacts
- Filler phrases and excessive hedging

### `/fact-check [file]`
Verify claims and statistics using web search.

**Process:**
1. Extract factual claims and statistics from content
2. Web search to verify each claim
3. Evaluate source credibility
4. Generate correction suggestions with citations
5. Save fact-check report to `drafts/`

### `/optimize [file]`
Final SEO optimization before publishing.

### `/rewrite [topic]`
Update and improve existing content.

### `/analyze-existing [URL or file]`
Analyze content for improvement opportunities.

### `/scrub [file]`
Remove AI watermarks (invisible Unicode characters, zero-width spaces).

### `/data [type]`
Fetch live performance data from configured sources (GA4, GSC, DataForSEO).

Types: `priority`, `opportunities`, `quick-wins`, `declining`, `page [url]`

### `/performance-review [file or URL]`
Comprehensive content performance analysis.

## Ruby Analysis Tools

CLI tools available in `data_sources/ruby/bin/`:

```bash
# Keyword analysis
seo-keywords --file article.md --keyword "podcast tips" --json

# Readability scoring
seo-readability --file article.md --json

# SEO quality rating (0-100)
seo-quality --file article.md --keyword "podcast tips" --json

# Search intent analysis
seo-intent --keyword "how to start a podcast"

# Content scrubbing (remove AI watermarks)
seo-scrub --file article.md --output cleaned.md
```

Or via Ruby:

```ruby
require_relative 'data_sources/ruby/lib/agent_seo'

# Keyword analysis
analyzer = AgentSeo::KeywordAnalyzer.new
result = analyzer.analyze(content, 'primary keyword')

# Readability scoring
scorer = AgentSeo::ReadabilityScorer.new
result = scorer.score(content)

# SEO quality rating
rater = AgentSeo::SeoQualityRater.new
result = rater.rate(content: content, primary_keyword: 'keyword')

# Content scrubbing
scrubber = AgentSeo::ContentScrubber.new
cleaned, stats = scrubber.scrub(content)
```

## Context Files

Customize templates in `context/` directory:

| File | Purpose |
|------|---------|
| `brand-voice.md` | Brand voice and messaging guidelines |
| `writing-examples.md` | 3-5 exemplary blog posts for style reference |
| `style-guide.md` | Editorial standards and formatting rules |
| `seo-guidelines.md` | SEO requirements and best practices |
| `target-keywords.md` | Keyword clusters and priorities |
| `internal-links-map.md` | Key pages for internal linking |

## Data Source Configuration

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

## Content Quality Standards

### SEO Requirements
- Primary keyword density: 1-2%
- Keyword placement: H1, first 100 words, 2-3 H2s
- Internal links: 3-5 with descriptive anchor text
- External links: 2-3 authoritative sources
- Meta title: 50-60 characters
- Meta description: 150-160 characters

### Readability Targets
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

## Typical Workflow

### Creating New Content
```
/research podcast monetization     # Research with web search
/write podcast monetization        # Write with analysis
/humanize drafts/podcast-*.md      # Remove AI patterns
/fact-check drafts/podcast-*.md    # Verify claims
/optimize drafts/podcast-*.md      # Final optimization
```

### Updating Existing Content
```
/analyze-existing https://site.com/old-article
/rewrite old article topic
/humanize rewrites/old-article-rewrite.md
/fact-check rewrites/old-article-rewrite.md
```
