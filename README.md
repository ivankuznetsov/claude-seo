# Agent SEO

A Claude Code skill for creating, analyzing, and optimizing SEO content. Features web search integration, AI humanization, fact-checking, and comprehensive Ruby-based analysis tools.

## Installation

### One-Liner

```bash
git clone https://github.com/ivankuznetsov/claude-seo.git && cd claude-seo && ./install.sh && claude .
```

### Step by Step

```bash
# 1. Clone the repository
git clone https://github.com/ivankuznetsov/claude-seo.git
cd claude-seo

# 2. Run installer (installs Ruby gems, creates directories)
./install.sh

# 3. Open in Claude Code
claude .
```

### Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- Ruby 3.0+ with Bundler

## Commands

| Command | Description |
|---------|-------------|
| `/seo:research [topic]` | Keyword research with web search |
| `/seo:write [topic]` | Write SEO-optimized article (2000-3000+ words) |
| `/seo:humanize [file]` | Remove AI writing patterns |
| `/seo:fact-check [file]` | Verify claims using web search |
| `/seo:optimize [file]` | Final SEO optimization |
| `/seo:rewrite [topic]` | Update existing content |
| `/seo:analyze-existing [URL]` | Analyze content for improvements |
| `/seo:scrub [file]` | Remove AI watermarks |
| `/seo:data [type]` | Fetch GA4/GSC/DataForSEO data |
| `/seo:performance-review` | Content performance analysis |

## Features

### Web Search Integration
- Real-time data for research and writing
- Automatic fact verification
- Current statistics and trends
- Authoritative source discovery

### AI Humanization
Removes 24 AI writing patterns based on [Wikipedia's AI Cleanup guidelines](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing):
- Inflated language ("pivotal", "testament", "crucial")
- AI vocabulary ("Additionally", "landscape", "delve")
- Em-dash overuse
- Copula avoidance
- Sycophantic tone

### Ruby Analysis Tools

```bash
# Keyword analysis
seo-keywords --file article.md --keyword "podcast tips" --json

# Readability scoring
seo-readability --file article.md --json

# SEO quality rating (0-100)
seo-quality --file article.md --keyword "podcast tips" --json

# Search intent analysis
seo-intent --keyword "how to start a podcast"

# Content scrubbing
seo-scrub --file article.md --output cleaned.md
```

## Configuration

### Context Files

Customize templates in `context/` for your brand:

| File | Purpose |
|------|---------|
| `brand-voice.md` | Brand voice and messaging |
| `writing-examples.md` | Style reference articles |
| `style-guide.md` | Editorial standards |
| `seo-guidelines.md` | SEO requirements |
| `target-keywords.md` | Keyword priorities |
| `internal-links-map.md` | Internal linking targets |

### Data Sources (Optional)

```bash
# Google Analytics 4
export GA4_PROPERTY_ID="your-property-id"
export GA4_CREDENTIALS_PATH="path/to/credentials.json"

# Google Search Console
export GSC_SITE_URL="https://yoursite.com"
export GSC_CREDENTIALS_PATH="path/to/credentials.json"

# DataForSEO
export DATAFORSEO_LOGIN="your-login"
export DATAFORSEO_PASSWORD="your-password"

# Ahrefs (via MCP server)
export AHREFS_API_KEY="your-api-key"
```

## Ideal Article Writing Workflow

The complete workflow for creating publish-ready SEO content:

### Step 1: Research
```
/seo:research [topic]
```
- Searches the web for current statistics, trends, and market data
- Analyzes search intent (informational, transactional, commercial)
- Identifies competitor content and gaps
- Saves research brief to `research/brief-[topic]-[date].md`

**Output:** Research brief with keywords, intent analysis, content outline, and sources

### Step 2: Write
```
/seo:write [topic]
```
- Loads research brief and context files (brand voice, style guide)
- Searches web for additional statistics and examples
- Writes 2,500+ word article with proper keyword placement
- Runs keyword, readability, and SEO quality analysis
- Saves to `drafts/[topic]-[date].md`

**Output:** Full article with meta elements, SEO checklist, and analysis scores

### Step 3: Humanize
```
/seo:humanize drafts/[article].md
```
- Removes 24 AI writing patterns (inflated language, AI vocabulary, em-dashes)
- Adds natural voice and conversational tone
- Preserves technical accuracy and SEO optimization
- Overwrites file with humanized version

**Output:** Natural-sounding content that passes AI detection

### Step 4: Fact-Check
```
/seo:fact-check drafts/[article].md
```
- Extracts all statistics, dates, and factual claims
- Verifies each claim with web search
- Flags incorrect or outdated information
- Applies corrections automatically
- Saves report to `drafts/fact-check-[topic]-[date].md`

**Output:** Verified article with corrected facts and source citations

### Step 5: Optimize (Optional)
```
/seo:optimize drafts/[article].md
```
- Final SEO polish and keyword optimization
- Internal linking suggestions
- Meta element refinement
- Move to `published/` when ready

### Quick Reference

```bash
# Full workflow - new content
/seo:research cloud storage
/seo:write cloud storage
/seo:humanize drafts/cloud-storage-*.md
/seo:fact-check drafts/cloud-storage-*.md

# Update existing content
/seo:analyze-existing https://site.com/old-article
/seo:rewrite old article topic
/seo:humanize rewrites/[article].md
/seo:fact-check rewrites/[article].md
```

### What Each Step Produces

| Step | Input | Output | Time |
|------|-------|--------|------|
| Research | Topic | Research brief with keywords, intent, outline | 2-3 min |
| Write | Topic + brief | 2,500+ word article with meta elements | 3-5 min |
| Humanize | Draft article | Natural-sounding content | 1-2 min |
| Fact-check | Article | Verified content + correction report | 2-3 min |
| Optimize | Article | Publish-ready content | 1-2 min |

**Total time:** ~10-15 minutes for a complete, fact-checked, SEO-optimized article

## Quality Standards

### SEO
- Keyword density: 1-2%
- Keyword in: H1, first 100 words, 2-3 H2s
- Internal links: 3-5
- External links: 2-3 authoritative sources
- Meta title: 50-60 chars
- Meta description: 150-160 chars

### Readability
- Reading level: 8th-10th grade
- Sentence length: 15-20 words
- Paragraphs: 2-4 sentences
- Subheadings: every 300-400 words

## Directory Structure

```
agent-seo/
├── SKILL.md                 # Skill definition
├── install.sh               # Installation script
├── .claude/
│   ├── commands/            # Namespaced slash commands (seo:*)
│   └── agents/              # Analysis agents
├── data_sources/
│   └── ruby/
│       ├── lib/agent_seo/   # Ruby modules (keyword analyzer, readability, etc.)
│       ├── bin/             # CLI tools (seo-keywords, seo-quality, etc.)
│       └── test/            # Minitest test suite
├── context/                 # Brand configuration
├── drafts/                  # Work in progress
├── published/               # Final content
├── rewrites/                # Updated content
└── research/                # Research briefs
```

## Running Tests

```bash
cd data_sources/ruby
bundle exec ruby -Ilib:test test/*_test.rb
```

## License

MIT License

---

Built with [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
