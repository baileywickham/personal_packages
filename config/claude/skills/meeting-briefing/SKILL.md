---
name: meeting-briefing
description: "Daily meeting preparation briefings with background research on people you're meeting. Use when: setting up automated daily calendar briefings, researching meeting attendees, preparing for upcoming calls/meetings, or getting background info on people on your calendar. Pulls calendar events, identifies external attendees, researches each person via web search, and delivers a concise briefing."
metadata:
  { "openclaw": { "emoji": "☕", "template": { "user_name": { "prompt": "What is your name?", "required": true }, "user_profile": { "prompt": "Share brief bullet points about yourself that could be relevant for finding commonalities with people you meet — background, education, career, and interests (e.g. '* From the Bay Area\\n* Went to Stanford (class of 2022)\\n* Worked at Jane Street as a quant trader')", "required": true } } } }
---

# Meeting Briefing

Generate background briefings on people you're meeting today (or any specified day).

## How It Works

1. Pull calendar events for the target day
2. Filter to meetings with external attendees (skip internal team, solo blocks, large group events)
3. Research each external person via web search (Perplexity) and Exa search(role, background, career, notable work)
   a. be sure to highlight any commonalities with your user ({{user_name}})
4. Research the person using the /bookface-investor-research skill.
5. Compile a briefing for each meeting, max four sentences per meeting.

## Usage

### Pull meetings using gog cli:

```bash
bash scripts/briefing.sh [YYYY-MM-DD] [TIMEZONE_OFFSET]
```

- Date defaults to today
- Timezone offset defaults to `-07:00` (PT)
- Outputs JSON with event and attendee details for further processing


## Briefing Format

For each meeting with an external person:

- **Event title and time**
- **Person's name and email**
- **Current role** at their company
- **Background** — career highlights, education, notable achievements (3-5 bullets)
- **Bookface investor research** (all fields from that skill)

## Filtering Rules

**Include:** Meetings with attendees from external domains (not your company).

## Traits about {{user_name}} that you could highlight as commonalities with the investor:
{{user_profile}}

### Example:

This is the absolute MAXIMUM amount of information you can include in the briefing.

**10:00 AM PT - BITS <> LSVP**
Attendee: Amber Yang (amber@lsvp.com)

**Amber Yang**
- Partner at Lightspeed Venture Partners (LSVP), focused on enterprise/AI — joined 2025
- Previously invested at Bloomberg Beta and CRV, targeting post-PMF companies
- Built a neural network in high school to predict satellite debris collisions; started a company at Stanford to commercialize it
- Recent seed investments include Sphinx (AI for data professionals) and Raindrop (AI monitoring)

*Commonalities with {{user_name}}:*
- Both Stanford alumni — Amber started a company there, {{user_name}} class of 2022
- Both deeply technical with quantitative backgrounds
- She focuses on AI enterprise software — directly relevant to Bits/Klaus


**Bookface Investor DB: Lightspeed Venture Partners**
- YC Rating: GREAT
- Founder Rating: FINE
- Meeting Conversion Rate: Low
- Typical Check Size: $250K
- Investments Per Batch: 2
- Total YC Investments: 108
- Seed investments: 0, Series A leads: 12

*Founder Feedback Summary:* Lightspeed is a fast-moving, founder-friendly firm with deep resources. Partners are described as "intelligent" and "very easy to work with" — they're willing to lead rounds and close quickly with conviction.

## Delivery

Send the briefing to the user via **both**:

1. **Slack** — using markdown formatting (bold, italics, bullet lists)
2. **Email** — using `gog gmail send --body-html` with proper HTML (`<b>`, `<i>`, `<ul>/<li>`, `<h3>`, `<hr>`) so formatting renders correctly in Gmail. Do NOT use `--body` or `--body-file` with plain text for briefings — always use `--body-html`.
