---
name: bookface-investor-research
description: Search and look up investors, companies, and people on YC Bookface (bookface.ycombinator.com). Use when asked to research investors from the YC investor database, look up YC batch companies, find intros, or check investor profiles on Bookface.
metadata:
  { "openclaw": { "emoji": "📒" } }
---

# Bookface

## Credentials

Stored in `.envrc` at the repo root (`repos/platform/.envrc`).

- **URL**: https://bookface.ycombinator.com
- **Email**: `$BOOKFACE_EMAIL`
- **Password**: `$BOOKFACE_PASSWORD`

## Login Flow

1. Open `https://bookface.ycombinator.com` in the browser (profile=openclaw)
2. If redirected to login page, enter email and password from env vars
3. Submit and wait for redirect to dashboard

## Investor Directory

**URL**: `https://bookface.ycombinator.com/directory/investors`

### Search

Type investor name in the search bar (`textbox "Search..."`). Results appear as a list of investor cards. Click into an investor card to view the full profile.

### Profile Page — "Seed Overview" Tab

Each investor profile page (e.g. `/investors/1640`) has a **Seed Overview** tab with these fields:

| Field | Where on page | Example values |
|-------|--------------|----------------|
| **YC Rating** | Top of Seed Overview, after "Rating" | BEST, GREAT, FINE, IF YOU MUST, BAD, UNRATED |
| **Founder Rating** | After "Founder Rating" | BEST, GREAT, FINE, UNRATED |
| **Meeting Conversion Rate** | Heading after "Meeting Conversion Rate" | Very High, High, Medium, Low |
| **Investments Per Batch** | Heading after "Investments Per Batch" | Number (e.g. 13) |
| **Typical Check Size** | Heading after "Typical Check Size" | Dollar amount (e.g. $100K) |
| **Total Investments** | In the tab label "Investments (N)" | Number in parentheses |
| **Tags** | Listed as badges below ratings | Fast Process, Writes First Checks, Highly Technical, Makes Intros, Low Maintenance, Actually Helpful, Demo Day Regular |
| **Summary of Founder Feedback** | Paragraph after "Summary of Founder Feedback ✨" | AI-generated summary of founder reviews. May be absent for investors with few reviews. |

### Data to Capture Per Investor

For each investor lookup, extract:
1. YC Rating
2. Founder Rating
3. Meeting Conversion Rate
4. Typical Check Size (median)
5. Investments Per Batch
6. Total # of Investments
7. First paragraph of "Summary of Founder Feedback" (if present)

## Workflow: Bulk Investor Lookup

1. Log in to Bookface
2. Navigate to `/directory/investors`
3. For each investor name:
   a. Search in the search bar
   b. Click the best-matching result to open their profile
   c. Read the Seed Overview tab and capture the 7 fields above
4. Compile results

## Tips

- Search by person's name first; if no results, try fund name
- If search returns multiple results, pick the one matching the fund/email from the calendar event
- Profile URL pattern: `bookface.ycombinator.com/investors/{id}`
- The investor directory is separate from the company directory
