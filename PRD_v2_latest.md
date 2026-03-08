# PRD: Pasar Memory (v2)

## Multimodal End-of-Day Reconciliation Notebook for Hawkers and Fresh Market Merchants

> This PRD is updated based on the latest product decisions and feedback. It remains grounded in the Case Study 8 framing that ASEAN MSMEs are economically critical but often remain digitally weak, informal, and invisible to formal systems, with major constraints around financing access, digital capability, and fragmented business records. fileciteturn13file0 fileciteturn13file1

---

## 1. Document Status

**Version:** v2
**Purpose:** Revised PRD with updated MVP decisions, system architecture, and tech stack
**Delivery target:** **Hackathon demo**

### Latest locked decisions

* Optional **live tapping stays in MVP**
* MVP accepts **both screenshot types**:

  * single payment / proof screenshot
  * transaction-history / settlement screenshot
* Product should accept **e-wallet export ingestion where available**, but export is **not a required dependency** for MVP
* **Counted cash can be entered both ways**:

  * typed manually
  * spoken during voice recap
* Immediate goal is **demo-first**, not production rollout
* Product remains **wallet-agnostic from day one**

### Important implementation constraint

Because e-wallet export availability and formats vary by provider, the MVP should be built so that:

* **screenshots are the default ingestion method**
* **export import is supported when available**, but not assumed to exist universally
* the product still works without direct wallet APIs or provider-specific integrations

---

## 2. Executive Summary

### What the product is

Pasar Memory is a **mobile-first, reconciliation-first business memory product** for informal merchants, starting with a **digitally engaged fried bihun hawker / fresh market food seller**.

It helps merchants answer one urgent daily question:

> **"How much did I actually sell today?"**

Instead of forcing POS-style real-time logging, Pasar Memory reconstructs the day using a small set of familiar inputs:

* **voice recap**
* **single payment screenshot**
* **transaction-history / settlement screenshot**
* **optional live taps** during slower moments
* **counted cash** entered manually or spoken in recap
* **optional e-wallet export / shared payment record** where available

The outcome is a **trusted daily ledger / daily sales summary** with visible uncertainty, source traceability, and merchant confirmation.

### What the MVP solves

The MVP solves a narrow but meaningful problem:

> **Post-market reconciliation for hawkers with messy mixed-payment days and weak records**

### Why now

Case Study 8 highlights that many ASEAN MSMEs remain offline or unbanked, leaving them invisible to markets and formal credit systems, while digital economy benefits remain concentrated among larger firms. fileciteturn13file0
Many small merchants already accept QR / e-wallet payments, but still do not have a usable, trusted, reusable business record.

### Why it matters

This is the **first mile of digitization**.
The MVP does not try to deliver financing, inventory, or POS replacement. Instead, it creates the first credible building block of a **merchant-owned business memory**, which can later support:

* clearer self-tracking
* merchant profile / business passport
* financing-readiness narrative
* formal ecosystem visibility

### Key differentiator

Pasar Memory is differentiated by the combination of:

* **aggregate reconciliation**, not brittle transaction-level certainty
* **multimodal evidence ingestion**
* **wallet-agnostic design**
* **trust-first explainability and correction**
* **business memory as the long-term asset**

### Best category framing

## **A reconciliation notebook and business memory layer for informal merchants**

Not:

* a generic AI assistant
* a POS alternative
* a wallet dashboard clone

---

## 3. Problem Statement

### Core merchant problem

At the end of the day, many hawkers still cannot confidently reconstruct:

* total daily sales
* digital payment total
* cash on hand as part of the day’s sales picture
* rough item-level performance
* whether the day has enough evidence to trust

### Root causes

1. **Rush-hour operating reality**

   * merchants are too busy to log consistently in real time

2. **Mixed-payment environment**

   * cash and QR coexist
   * some digital proof exists, but not in one unified ledger

3. **Evidence is fragmented**

   * screenshots
   * transaction histories
   * wallet dashboards
   * exports when available
   * memory
   * informal notes

4. **Existing tools require structured behavior**

   * POS requires disciplined front-of-house usage
   * accounting tools require sustained back-office effort
   * wallet dashboards show only part of reality

5. **False precision destroys trust**

   * exact transaction matching is unrealistic in dense hawker flows
   * cash inference from incomplete signals can look precise while be wrong

### Revised insight

For this wedge, the product should optimize for:

## **Aggregate end-of-day truth with visible uncertainty**

rather than pretending to reconstruct every transaction exactly.

---

## 4. Target User

### Primary persona

**Name:** Kak Lina
**Business:** Fried bihun hawker
**Merchant type:** Fresh market / pasar pagi food seller
**Digital maturity:** Smartphone-using, already QR-enabled, willing to try a lightweight app if end-of-day value is immediate

### Realistic first user

This MVP is for merchants who:

* already accept QR / e-wallet
* can capture or share a screenshot
* may be able to export payment history from some wallets, but do not need that for the app to work
* can record a short recap
* see value in a daily ledger

### Not the first user

Not ideal yet for merchants who:

* do not accept digital payments at all
* strongly resist any digital interaction beyond receiving money
* are unwilling to do even a short end-of-day review

### Jobs-to-be-done

* Help me reconstruct the day fast.
* Help me use the payment evidence I already have.
* Help me record cash honestly, without guesswork.
* Help me save a trusted daily record I can refer to later.

---

## 5. Product Vision and Positioning

### Product vision

Pasar Memory helps informal merchants turn a messy day of business into a **trusted daily ledger**, then accumulates those ledgers into a **merchant-owned business memory**.

### Long-term thesis

The daily notebook is the habit-forming layer.
The business-memory timeline is the strategic asset.

### Positioning statement

**Pasar Memory helps digitally engaged hawkers rebuild a trusted daily ledger from payment proof, voice recap, counted cash, and optional live taps — turning messy market days into reusable business memory.**

### What it is not

* not a full POS
* not an accounting suite
* not a lender
* not a wallet replacement
* not a generic chat assistant for SMEs

---

## 6. Competitive Positioning

### Core overlap

Wallet merchant tools already provide:

* payment acceptance
* digital transaction views
* settlement visibility
* some dashboard and merchant features

### Where Pasar Memory remains different

Only if it remains focused on:

* **mixed cash + digital reality**
* **wallet-agnostic evidence ingestion**
* **post-hoc reconstruction**
* **visible uncertainty and correction**
* **merchant-owned record building over time**

### Competitive risk

If Pasar Memory becomes just a better payment dashboard, it becomes easy to compare directly against wallet players.

### Defensible wedge

The wedge remains strongest when framed as:

## **Post-market reconciliation + business memory**

---

## 7. Scope Definition

### What the MVP solves

The MVP helps a fried bihun seller:

* upload or share digital payment evidence
* optionally import export data where available
* record a voice recap
* enter or confirm counted cash
* optionally add live tap evidence
* generate an aggregate daily ledger
* confirm and save the day into memory

### What the MVP does not depend on

The MVP does not depend on:

* consistent real-time tapping
* deterministic payment-to-order matching
* exact cash inference from weak signals
* direct wallet API integrations
* universal wallet export support

### Live tapping stance

Optional live tapping **stays in MVP**, but as a **supporting enrichment path**, not the backbone.

### Export ingestion stance

E-wallet/export ingestion is accepted where available, but the MVP should still work even if the merchant only provides screenshots.

### Non-goals

* full POS replacement
* inventory system
* financing execution
* direct underwriting
* e-invoicing
* mandatory wallet API integration

---

## 8. Product Principles

### A. Passive-first, not effort-first

Default to the lowest-effort end-of-day flow.

### B. Aggregate truth over fake exactness

Prefer credible aggregate outputs to fragile exact matching.

### C. Trust over automation theater

Every estimate must be labeled. Every important field must be editable.

### D. Business memory is the strategic reason

The daily ledger is the habit. The business-memory timeline is the long-term value.

### E. Wallet-agnostic by design

The product should not depend on one wallet ecosystem to work.

### F. Live tap is optional, not required

Useful when the merchant has time. Not a prerequisite for success.

---

## 9. Hero MVP Workflow

## **End-of-Day Memory Dump**

Merchant does 4 key things:

1. provides digital payment evidence
2. records a voice recap
3. enters or confirms counted cash
4. reviews the generated daily ledger

### Evidence input options supported in MVP

#### Digital payment evidence

* single payment screenshot
* transaction-history screenshot
* settlement screenshot
* exported file or share output from e-wallet, **if available**

#### Merchant recap

* short voice recap
* optional typed correction

#### Cash confirmation

* typed counted cash
* spoken counted cash inside recap
* final editable cash field before ledger confirmation

#### Optional enrichment

* live tap capture during slow periods

### Product rule

The product must still work even if the merchant only uses:

* screenshot(s)
* voice recap
* counted cash

---

## 10. Core Product Flows

### 10.1 Morning setup

1. Merchant opens app.
2. Merchant sees Today home screen.
3. Optional: merchant uses tap buttons during slow periods.
4. App passively stores any live inputs.

### 10.2 During selling hours

Two realities are allowed:

* merchant does not use app at all
* merchant optionally taps some common sales

The product should not fail if the merchant ignores the app during rush.

### 10.3 Digital evidence ingestion flow

1. Merchant uploads or shares one or more payment evidence artifacts.
2. Accepted inputs in MVP:

   * single payment screenshot
   * transaction-history screenshot
   * settlement screenshot
   * export file / shareable payment record where available
3. App extracts usable fields.
4. App stores evidence and confidence.
5. Merchant reviews or edits extracted values.

### 10.4 Voice recap flow

1. App prompts merchant with simple recap questions.
2. Merchant records short recap.
3. STT produces transcript.
4. Menu-aware parser converts transcript into structured recap.
5. Merchant confirms or edits parsed recap.

### 10.5 Counted cash flow

1. Merchant enters counted cash manually, or
2. system pre-fills counted cash from spoken recap if detected
3. merchant confirms or edits cash value before final ledger creation

### 10.6 Aggregate reconciliation flow

1. App combines:

   * extracted digital total(s)
   * counted cash
   * recap-derived item estimates
   * optional tap inputs
2. App produces a draft daily ledger.
3. App highlights:

   * confirmed fields
   * estimated fields
   * unresolved uncertainty
4. Merchant confirms day.

### 10.7 Daily memory save flow

1. Day is saved as one business-memory entry.
2. Entry includes:

   * totals
   * evidence sources
   * transcript reference
   * confidence notes
   * corrections made
3. Timeline grows over time.

---

## 11. Detailed Feature Requirements

### 11.1 Merchant setup

**Functional requirements:**

* create merchant profile
* define menu items and prices
* define common aliases for item names
* choose language preference
* choose accepted payment types

**Priority:** Must

### 11.2 Digital evidence ingestion

**Description:** Import and process payment evidence.
**Supported MVP inputs:**

* single payment screenshot
* transaction-history screenshot
* settlement screenshot
* exported payment record / share output where available

**Functional requirements:**

* gallery import
* share-sheet import
* file import for supported export types
* evidence preview
* extraction result review
* manual correction

**Priority:** Must

### 11.3 OCR / parser extraction

**Functional requirements:**

* extract amount(s)
* extract date / time where visible
* detect provider if possible
* retain raw extraction text for auditability
* support partial extraction with manual correction

**Priority:** Must

### 11.4 Counted cash entry

**Functional requirements:**

* typed manual entry
* optional prefill from voice recap parsing
* final editable cash value before save
* label as merchant-entered / merchant-confirmed

**Priority:** Must

### 11.5 Voice recap capture

**Functional requirements:**

* record short clip
* transcript generation
* transcript review UI
* structured recap parsing
* manual edit flow

**Priority:** Must

### 11.6 Menu-aware recap parser

**Functional requirements:**

* use merchant menu as context
* extract item mentions
* infer rough quantities where possible
* detect phrases like “sold out”, “about”, “most were cash”, “the rest QR”
* detect spoken cash total if present
* assign confidence per parsed field

**Priority:** Must

### 11.7 Aggregate reconciliation engine

**Functional requirements:**

* combine digital totals, counted cash, recap estimates, optional taps
* generate gross daily total
* show estimated item counts where possible
* expose unresolved uncertainty instead of fake precision

**Priority:** Must

### 11.8 Daily ledger screen

**Functional requirements:**

* show gross total
* show digital total
* show counted cash
* show estimated item counts
* show evidence sources
* show field-level certainty labels
* confirm-day CTA

**Priority:** Must

### 11.9 Evidence traceability

**Functional requirements:**

* link ledger fields to source screenshot / transcript / manual entry / export file
* show why a field is considered estimated or confirmed

**Priority:** Must

### 11.10 Correction flow

**Functional requirements:**

* edit extracted totals
* edit counted cash
* edit parsed recap quantities
* save correction history

**Priority:** Must

### 11.11 Optional live tap capture

**Functional requirements:**

* quick menu buttons
* simple count increment
* stored as supplemental evidence
* does not block completion if unused

**Priority:** Must for demo scope, but not load-bearing

### 11.12 History / business memory timeline

**Functional requirements:**

* show confirmed days
* show totals per day
* allow open ledger details

**Priority:** Should

### 11.13 Export-aware ingestion support

**Functional requirements:**

* accept imported structured or semi-structured payment export where available
* map imported fields into evidence model
* clearly label source as export-derived
* fallback to manual review if parser confidence is low

**Priority:** Should for demo, not mandatory for base flow

---

## 12. AI / Intelligence Requirements

### 12.1 OCR layer

**Role:** Extract values from screenshots.
**Requirements:**

* strong on-device OCR first pass
* support both single-payment and transaction-history screenshot layouts
* retain raw OCR output
* no silent failure

### 12.2 Export parser layer

**Role:** Parse imported payment record files when available.
**Requirements:**

* treat export ingestion as optional input path
* parse only supported formats in demo
* fail gracefully to manual review when unsupported

### 12.3 STT layer

**Role:** Convert short merchant recap audio to transcript.
**Requirements:**

* short clip support
* noisy environment tolerance as much as feasible
* manual transcript edit fallback

### 12.4 Post-STT parsing layer

**Requirements:**

* menu-aware
* quantity extraction
* sold-out / estimate cue detection
* counted cash detection if spoken
* field-level uncertainty tagging

### 12.5 Aggregate ledger synthesis

The system synthesizes:

* OCR-derived digital totals
* export-derived totals if available
* counted cash
* recap-derived item estimates
* optional live tap evidence

### 12.6 Field-level confidence model

Examples:

* digital total from screenshot: high confidence
* digital total from fuzzy transaction-history OCR: medium confidence
* export-derived parsed total: variable by parser success
* counted cash typed by merchant: merchant-confirmed
* item counts from recap: medium or low confidence

### 12.7 What the AI must not do

* must not pretend transaction-level truth when only aggregate truth exists
* must not treat unsupported exports as reliable automatically
* must not hide uncertainty

---

## 13. Data Model / System Logic

### Core entities

#### Merchant

* profile
* menu
* language/context preferences

#### MenuItem

* name
* price
* aliases

#### DailyEvidence

* screenshots
* export file(s) when available
* audio recap
* optional tap entries
* optional manual notes

#### OCRExtraction

* raw text
* extracted totals / fields
* extraction confidence

#### ExportExtraction

* parsed fields
* parser confidence
* raw import reference

#### TranscriptRecord

* raw transcript
* uncertainty markers

#### ParsedRecap

* item estimates
* sold-out flags
* recap notes
* counted cash if spoken
* parse confidence

#### DailyLedger

* date
* digital total
* counted cash
* gross total
* estimated item counts
* evidence links
* confirmation state
* uncertainty notes

#### CorrectionRecord

* what changed
* old value
* new value
* who edited
* timestamp

### Revised logic rules

1. Daily evidence is collected.
2. OCR and/or export parser extract digital payment information.
3. STT generates transcript.
4. Post-STT parser structures recap.
5. Merchant confirms counted cash.
6. System synthesizes one aggregate daily ledger.
7. Merchant reviews and confirms.
8. Confirmed ledger is saved into business memory.

---

## 14. Trust and Safety Requirements

### Core rules

* never hide estimation
* never label uncertain values as exact
* always show evidence source
* always allow merchant correction
* prefer human confirmation over fragile automation

### Required trust labels

* **Confirmed by merchant**
* **From screenshot**
* **From export**
* **From voice recap**
* **Estimated**
* **Needs review**

### Privacy expectations

* evidence handled carefully
* local-first where possible
* cloud upload only where needed for demo functionality / backup
* merchant-visible source tracking

---

## 15. Screen-by-Screen MVP Breakdown

### 15.1 Home / Today screen

**Should prioritize:**

* start end-of-day recap
* today’s completion status
* optional quick taps
* unresolved evidence indicator

### 15.2 Menu setup screen

Configure menu and item aliases for parsing.

### 15.3 Digital evidence upload screen

Supports:

* screenshot import
* transaction-history screenshot import
* export file import where available
* extraction preview
* manual correction

### 15.4 Voice recap screen

Record, retry, and review recap transcript.

### 15.5 Recap review screen

Review parsed recap, item estimates, and counted cash.

### 15.6 Daily ledger screen

Hero outcome screen with:

* gross total
* digital total
* counted cash
* estimated items sold
* certainty labels
* evidence links
* confirm-day CTA

### 15.7 History / memory timeline

Show saved days and totals.

---

## 16. MVP Scope (v2)

### Must-have

* merchant + menu setup
* optional live taps
* screenshot import
* transaction-history screenshot support
* OCR extraction + manual correction
* voice recap input
* post-STT menu-aware parsing
* counted cash entry (typed + spoken support)
* aggregate ledger generation
* daily ledger review screen
* evidence traceability
* correction flow

### Should-have

* export-aware ingestion support for selected provider formats in demo
* history timeline
* export daily ledger

### Could-have

* business passport preview
* receipt support
* trend view

### Out of scope

* transaction-level exact matching as hero feature
* full POS
* inventory
* financing execution
* direct wallet integration dependency

---

## 17. Success Metrics

### Primary success metrics

* end-of-day flow completion rate
* merchant-reported trust in ledger output
* number of days saved into memory timeline
* successful reconstruction of demo scenario in under 3 minutes

### Quality metrics

* OCR success on supported screenshot types
* usefulness rate of recap parsing
* percentage of fields corrected manually
* confidence distribution by field
* export parser success on supported demo formats, if included

---

## 18. Risks and Open Questions

### Product risks

1. End-of-day flow may still feel like too much work.
2. Voice STT may struggle with slang and noise.
3. Transaction-history screenshots may be noisier than single-payment screenshots.
4. Export formats vary by wallet and may be hard to generalize.
5. Judges may still ask why wallet apps cannot add similar summaries.

### Clarified stance on exports

Yes, the product should **accept e-wallet exports where available**, but this remains an **optional ingestion channel**, not a guaranteed standard across all wallets in MVP.

### Remaining open questions

* Which wallet export formats are realistic to support in the demo?
* Should transaction-history screenshots be limited to one or two known layouts for demo reliability?
* How much live tap value should be shown in the demo versus kept minimal?

---

## 19. System Architecture (Updated)

### Architecture summary

For demo scope, the recommended architecture is:

## **Offline-first Flutter mobile app + local SQLite + on-device OCR + lightweight backend + cloud STT + rules-based aggregate reconciliation**

### Architecture diagram

```text
[Flutter Mobile App]
  ├─ UI Layer
  ├─ Local SQLite DB
  ├─ Capture Layer
  │   ├─ Optional live taps
  │   ├─ Screenshot import
  │   ├─ Export/file import
  │   └─ Voice recording
  ├─ On-device OCR
  ├─ Local draft generation
  ├─ Local evidence store
  └─ Sync Queue
          ↓
[Backend / Cloud Layer]
  ├─ Auth
  ├─ Storage (screenshots, audio, optional imports)
  ├─ STT service orchestration
  ├─ Recap parsing service
  ├─ Aggregate reconciliation engine
  └─ Daily ledger persistence
          ↓
[Business Memory Layer]
  ├─ Daily ledgers
  ├─ Corrections
  ├─ Evidence references
  └─ Timeline / history
```

### Why this architecture fits

* mobile-first for hawker reality
* local-first for weak connectivity and fast UX
* screenshots as default evidence
* export ingestion can be added without redesigning the core
* cloud used only where helpful, especially STT and backup

### Updated system responsibilities

#### On-device

* menu setup
* optional live taps
* screenshot import
* file import handling
* OCR first pass
* local evidence storage
* local draft ledger preview
* offline queue

#### Cloud/backend

* speech transcription
* recap parsing
* optional export parsing if heavier logic is needed
* aggregate ledger synthesis
* backup and history sync

### Important architecture update

The synthesis pipeline is now:

**Screenshot / export -> OCR or parser -> digital totals**
**Voice recap -> STT -> menu-aware parser -> structured recap**
**Counted cash -> merchant-confirmed value**
**Optional taps -> supplemental evidence**
**Aggregate synthesis -> draft daily ledger**

This is simpler and more realistic than deterministic one-to-one transaction matching.

---

## 20. Recommended Tech Stack (Updated)

### Frontend / Mobile

* **Flutter** for cross-platform demo app
* **Dart**
* **Riverpod** for state management
* **go_router** for navigation
* **sqflite** for local SQLite access
* **freezed / json_serializable** for typed models
* **image_picker / file_picker / share_plus** for screenshot and export ingestion
* **record** for voice capture

### Local persistence

* **SQLite** via `sqflite`
* local file storage for screenshots, imported files, and audio before sync

### OCR

* **Google ML Kit Text Recognition** on-device for screenshot OCR first pass

### Speech-to-text

* **Cloud STT** for demo reliability
* recommended current path: OpenAI transcription API or equivalent STT service
* keep provider abstracted behind service layer

### Backend / Cloud

For a demo-first build, two valid options:

#### Option A: Supabase stack (recommended if you want quick auth + storage)

* **Supabase Auth**
* **Supabase Postgres**
* **Supabase Storage**
* **Supabase Edge Functions**

#### Option B: Lightweight custom backend

* **Node.js / TypeScript** backend
* simple file storage + small database
* only if team already prefers custom infra

### Demo recommendation

For speed and simplicity, prefer:

## **Flutter + SQLite + ML Kit + Supabase + cloud STT**

### Parsing / reconciliation logic

* rules-based aggregate reconciliation engine
* field-level confidence rules
* menu-aware recap parser
* optional export parsers for supported demo formats

### Observability / crash tracking

* lightweight logging
* optional Sentry / Crashlytics if time permits

---

## 21. Roadmap

### MVP (demo target)

* screenshot ingestion
* transaction-history screenshot support
* optional export ingestion for supported format(s)
* voice recap
* counted cash
* aggregate daily ledger
* evidence traceability
* correction flow
* optional live taps

### v1.5

* better export support
* stronger history timeline
* improved recap prompts
* merchant-specific parsing improvements

### v2

* business passport view
* richer trend analysis
* financing-readiness storytelling layer

---

## 22. Final Recommendation

This remains a strong concept **if** it is pitched and built as:

## **A post-market reconciliation notebook and business memory tool**

not as:

* a POS competitor
* a wallet dashboard clone
* a generic merchant AI app

### Sharpest demo narrative

**Hawkers do not need another POS. They need a fast way to turn a messy day of mixed cash and QR sales into a trusted daily ledger. Pasar Memory does that using screenshots, voice recap, counted cash, optional live taps, and wallet-agnostic evidence handling — then saves that day into a business memory they can build on later.**

---

## 23. Notes Requiring Later Clarification

These do not block the demo PRD, but will matter later:

* which exact e-wallet export formats will be supported first
* whether transaction-history screenshots are limited to one or two known layouts in demo
* whether live taps should remain visible in the demo or stay secondary
* whether cloud storage is used for all evidence or only selective backup
