# Agent SEO

A Claude Code plugin for creating, analyzing, and optimizing SEO content. Research topics, write long-form articles, humanize AI content, fact-check claims, and track performance.

## Installation

In Claude Code, run:

```
/plugin marketplace add ivankuznetsov/claude-seo
/plugin install agent-seo@ivankuznetsov-claude-seo
```

Ruby dependencies install automatically on first session start (if Ruby is available).

### Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- Ruby 3.0+ with Bundler (optional — needed for analysis tools only)

### What works without Ruby?

All core commands work without Ruby: research, write, humanize, fact-check, optimize, rewrite, analyze-existing. These are prompt-driven and use web search.

Ruby is only needed for the analysis CLI tools: `seo-keywords`, `seo-readability`, `seo-quality`, `seo-intent`, `seo-scrub`. These provide keyword density scoring, readability metrics, and content scrubbing.

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

## Workflow

```
/seo:research cloud storage        # Research keywords and competitors
/seo:write cloud storage           # Write 2,500+ word article
/seo:humanize drafts/cloud-*.md    # Remove AI patterns
/seo:fact-check drafts/cloud-*.md  # Verify claims with web search
/seo:optimize drafts/cloud-*.md    # Final SEO polish
```

Each step builds on the previous. Research saves a brief, write loads it automatically. Humanize, fact-check, and optimize work on the saved draft.

For existing content:

```
/seo:analyze-existing https://site.com/old-article
/seo:rewrite old article topic
/seo:humanize rewrites/[article].md
/seo:fact-check rewrites/[article].md
```

## Features

### AI Humanization

Detects and removes 24 AI writing patterns based on [Wikipedia's AI Cleanup guidelines](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing):

- Inflated language ("pivotal", "testament", "crucial")
- AI vocabulary ("Additionally", "landscape", "delve")
- Em-dash overuse and copula avoidance
- Sycophantic tone and filler phrases

### Ruby Analysis Tools

Run directly or used automatically by commands:

```bash
seo-keywords --file article.md --keyword "podcast tips" --json
seo-readability --file article.md --json
seo-quality --file article.md --keyword "podcast tips" --json
seo-intent --keyword "how to start a podcast"
seo-scrub --file article.md --output cleaned.md
```

### Quality Targets

- Keyword density: 1-2%, placed in H1, first 100 words, 2-3 H2s
- Internal links: 3-5, external links: 2-3 authoritative sources
- Reading level: 8th-10th grade, sentences: 15-20 words avg
- Meta title: 50-60 chars, description: 150-160 chars

## Configuration

### Context Files

Customize in `context/` for your brand:

| File | Purpose |
|------|---------|
| `brand-voice.md` | Tone, messaging, vocabulary |
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

## Project Structure

```
agent-seo/
├── .claude-plugin/
│   ├── plugin.json          # Plugin manifest
│   └── marketplace.json     # Marketplace catalog
├── skills/seo/SKILL.md      # Skill definition
├── commands/                # Slash commands (seo:*)
├── agents/                  # Analysis agents
├── hooks/hooks.json         # Auto-install deps on session start
├── scripts/ensure-deps.sh   # Dependency installer
├── data_sources/ruby/       # Ruby analysis tools
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

MIT

---

Built with [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
