# Pasar Memory — Hackathon Task Breakdown v2 (5 People)

> Updated to align with **PRD v2**: aggregate end-of-day reconciliation, voice recap as Must, counted cash as first-class input, optional live taps, wallet-agnostic export ingestion. Replaces v1 transaction-level matching approach.

---

## What Changed from v1 Task Breakdown

| Area | v1 | v2 |
|---|---|---|
| Core paradigm | Transaction-level payment-to-order matching | **Aggregate daily synthesis** (combine totals, not match individual tx) |
| Live tapping | Must — primary capture flow | **Optional enrichment** — not backbone |
| Voice recap | Should (v1.5) | **Must — core hero flow** |
| Counted cash | Inferred from unmatched orders | **Explicit merchant input** (typed or spoken) |
| E-wallet export | Not in scope | **Should — accepted where available** |
| Data model | `OrderEvent`, `MatchRecord`, `DailySummary` | `DailyEvidence`, `OCRExtraction`, `ExportExtraction`, `TranscriptRecord`, `ParsedRecap`, `DailyLedger` |
| Hero flow | Morning → Rush taps → Import → Match → Summary | **End-of-day memory dump**: screenshots → voice → cash → ledger → confirm |
| Screens | 10 (incl. Matching Results, Unmatched Queue) | **7** — Home, Menu Setup, Evidence Upload, Voice Recap, Recap Review, Daily Ledger, History |
| Removed screens | — | Matching Results, Unmatched Queue, Edit Match, Processing Progress |
| New screens | — | Recap Review, Counted Cash, History Timeline |

---

## Team Roles Overview (v2)

| Role | Person | Scope | Primary Directories Owned |
|---|---|---|---|
| **Dev 1** | Architect / Foundation | Project init, data models, local DB, Supabase setup, sync, shared widgets, Home screen | `pubspec.yaml`, `lib/models/`, `lib/data/`, `lib/services/sync/`, `lib/shared/`, `lib/features/home/`, `supabase/migrations/` |
| **Dev 2** | Evidence Ingestion UI | Onboarding, menu setup, screenshot + export import UI, counted cash entry, optional tap capture | `lib/features/onboarding/`, `lib/features/menu_setup/`, `lib/features/evidence/`, `lib/features/cash_entry/`, `lib/features/selling/` |
| **Dev 3** | OCR + Parsing + Reconciliation | OCR service, export parser, aggregate reconciliation engine, daily ledger screen, correction flow | `lib/services/ocr/`, `lib/services/reconciliation/`, `lib/features/ledger/`, `lib/features/correction/`, `supabase/functions/reconcile/` |
| **Dev 4** | Voice + Recap + History | Voice recording, STT service, menu-aware recap parser, recap review screen, history timeline | `lib/services/stt/`, `lib/services/recap_parser/`, `lib/features/voice/`, `lib/features/recap_review/`, `lib/features/history/`, `supabase/functions/transcribe/` |
| **Person 5** | Presentation & Demo | Pitch deck, demo script, narrative, Q&A prep, demo data, screen recordings | `docs/presentation/` |

---

## Proposed Folder Structure (v2, Merge-Conflict-Safe)

```
pasar_memory/
├── pubspec.yaml                              # Dev 1 (locked after Phase 0)
├── lib/
│   ├── main.dart                             # Dev 1 (entry point, locked after Phase 0)
│   ├── app.dart                              # Dev 1 (MaterialApp, Riverpod, theme)
│   ├── router.dart                           # Dev 1 (go_router — devs provide screen refs, Dev 1 wires)
│   │
│   ├── models/                               # Dev 1 ONLY
│   │   ├── merchant.dart
│   │   ├── menu_item.dart
│   │   ├── daily_evidence.dart
│   │   ├── ocr_extraction.dart
│   │   ├── export_extraction.dart
│   │   ├── transcript_record.dart
│   │   ├── parsed_recap.dart
│   │   ├── daily_ledger.dart
│   │   ├── correction_record.dart
│   │   └── tap_entry.dart
│   │
│   ├── data/                                 # Dev 1 ONLY
│   │   ├── local/
│   │   │   └── database.dart                 # SQLite schema + DAOs
│   │   ├── remote/
│   │   │   └── supabase_client.dart          # Supabase init + helpers
│   │   └── repositories/
│   │       ├── merchant_repo.dart
│   │       ├── menu_repo.dart
│   │       ├── evidence_repo.dart
│   │       ├── extraction_repo.dart
│   │       ├── recap_repo.dart
│   │       ├── ledger_repo.dart
│   │       └── correction_repo.dart
│   │
│   ├── services/
│   │   ├── sync/                             # Dev 1 ONLY
│   │   │   └── sync_service.dart
│   │   ├── ocr/                              # Dev 3 ONLY
│   │   │   ├── ocr_service.dart
│   │   │   └── screenshot_parser.dart
│   │   ├── reconciliation/                   # Dev 3 ONLY
│   │   │   ├── reconciliation_engine.dart
│   │   │   └── confidence_rules.dart
│   │   ├── stt/                              # Dev 4 ONLY
│   │   │   └── stt_service.dart
│   │   └── recap_parser/                     # Dev 4 ONLY
│   │       └── menu_aware_parser.dart
│   │
│   ├── features/
│   │   ├── home/                             # Dev 1 ONLY
│   │   │   ├── home_screen.dart
│   │   │   └── home_provider.dart
│   │   ├── onboarding/                       # Dev 2 ONLY
│   │   │   ├── onboarding_screen.dart
│   │   │   └── onboarding_provider.dart
│   │   ├── menu_setup/                       # Dev 2 ONLY
│   │   │   ├── menu_setup_screen.dart
│   │   │   ├── menu_item_tile.dart
│   │   │   └── menu_setup_provider.dart
│   │   ├── evidence/                         # Dev 2 ONLY
│   │   │   ├── evidence_upload_screen.dart
│   │   │   ├── extraction_preview.dart
│   │   │   └── evidence_provider.dart
│   │   ├── cash_entry/                       # Dev 2 ONLY
│   │   │   ├── cash_entry_screen.dart
│   │   │   └── cash_entry_provider.dart
│   │   ├── selling/                          # Dev 2 ONLY (optional tap capture)
│   │   │   ├── selling_screen.dart
│   │   │   └── selling_provider.dart
│   │   ├── ledger/                           # Dev 3 ONLY
│   │   │   ├── daily_ledger_screen.dart
│   │   │   └── ledger_provider.dart
│   │   ├── correction/                       # Dev 3 ONLY
│   │   │   ├── correction_screen.dart
│   │   │   └── correction_provider.dart
│   │   ├── voice/                            # Dev 4 ONLY
│   │   │   ├── voice_recap_screen.dart
│   │   │   └── voice_provider.dart
│   │   ├── recap_review/                     # Dev 4 ONLY
│   │   │   ├── recap_review_screen.dart
│   │   │   └── recap_review_provider.dart
│   │   └── history/                          # Dev 4 ONLY
│   │       ├── history_screen.dart
│   │       └── history_provider.dart
│   │
│   └── shared/                               # Dev 1 (shared widgets + theme)
│       ├── theme/
│       │   └── app_theme.dart
│       └── widgets/
│           ├── confidence_label.dart          # "Confirmed", "Estimated", "From screenshot", etc.
│           ├── evidence_source_chip.dart       # Shows where a value came from
│           ├── trust_badge.dart                # Visual badge for trust level
│           └── loading_indicator.dart
│
├── supabase/
│   ├── config.toml                           # Dev 1
│   ├── migrations/                           # Dev 1 ONLY
│   │   └── 001_initial_schema.sql
│   └── functions/
│       ├── reconcile/                        # Dev 3 ONLY
│       │   └── index.ts
│       ├── transcribe/                       # Dev 4 ONLY
│       │   └── index.ts
│       └── parse-recap/                      # Dev 4 ONLY
│           └── index.ts
│
└── docs/
    └── presentation/                         # Person 5 ONLY
        ├── pitch_deck.md
        └── demo_script.md
```

---

## Phase 0 — Bootstrap (Dev 1 leads, everyone waits for skeleton)

Dev 1 must complete this BEFORE anyone else starts coding. Creates the skeleton everyone builds on.

### Dev 1 — Bootstrap Tasks

| # | Task | Output |
|---|---|---|
| 1.0.1 | Run `flutter create pasar_memory` | Project scaffold |
| 1.0.2 | Configure `pubspec.yaml` with ALL dependencies (see below) | Locked pubspec |
| 1.0.3 | Create full folder structure with placeholder files | All directories exist |
| 1.0.4 | Define all v2 data model classes in `lib/models/` (freezed + json_serializable) | 10 model files |
| 1.0.5 | Set up `app.dart` with MaterialApp + ProviderScope + go_router skeleton | Working app shell |
| 1.0.6 | Create `router.dart` with placeholder routes for all 7 screens | Navigation skeleton |
| 1.0.7 | Set up `lib/shared/theme/app_theme.dart` (colors, typography, large touch targets) | Theme file |
| 1.0.8 | Set up `lib/shared/widgets/` with `confidence_label.dart`, `evidence_source_chip.dart`, `trust_badge.dart` | Shared widget stubs |
| 1.0.9 | Initialize Supabase project + create Postgres schema migration for v2 data model | `supabase/migrations/001_initial_schema.sql` |
| 1.0.10 | Set up `supabase_client.dart` with init + env config (.env) | Supabase connection |
| 1.0.11 | Publish repository interfaces (abstract classes / method signatures) | Devs can code against interfaces |
| 1.0.12 | Push skeleton to `main`, create feature branches for each dev | Git branches ready |

**pubspec.yaml dependencies (all upfront):**
```yaml
dependencies:
  flutter_riverpod:
  go_router:
  sqflite:
  path:
  path_provider:
  dio:
  freezed_annotation:
  json_annotation:
  image_picker:
  file_picker:
  share_plus:
  google_mlkit_text_recognition:
  record:
  supabase_flutter:
  intl:
  uuid:

dev_dependencies:
  freezed:
  json_serializable:
  build_runner:
```

### Everyone Else During Phase 0

| Person | What to do while waiting |
|---|---|
| **Dev 2** | Sketch screen layouts (onboarding, menu setup, evidence upload, cash entry, selling) on paper/Figma; collect sample Malaysian payment screenshots for testing |
| **Dev 3** | Research ML Kit text recognition API; test OCR on sample TNG/DuitNow/Boost screenshots; study common screenshot layouts |
| **Dev 4** | Research OpenAI transcription API; plan menu-aware parsing rules; test with sample Malay/English voice clips |
| **Person 5** | Draft pitch narrative structure; identify key demo moments from PRD v2 hero flow |

---

## Phase 1 — Parallel Feature Build (All devs work simultaneously)

### Dev 1 — Data Layer, Repositories, Home Screen, Shared Widgets

| # | Task | Details |
|---|---|---|
| 1.1.1 | Implement SQLite database helper (`database.dart`) | Tables for all v2 entities (merchant, menu_item, daily_evidence, ocr_extraction, export_extraction, transcript_record, parsed_recap, daily_ledger, correction_record, tap_entry); CRUD ops; migrations |
| 1.1.2 | Implement `merchant_repo.dart` | Create/read/update merchant profile |
| 1.1.3 | Implement `menu_repo.dart` | CRUD for menu items + aliases; toggle active state; preset suggestions |
| 1.1.4 | Implement `evidence_repo.dart` | Store daily evidence records; link screenshots/audio/exports to a day; list by date |
| 1.1.5 | Implement `extraction_repo.dart` | Store OCR extractions + export extractions; link to evidence; query by day |
| 1.1.6 | Implement `recap_repo.dart` | Store transcript records + parsed recaps; link to audio evidence; query by day |
| 1.1.7 | Implement `ledger_repo.dart` | Create/update draft daily ledger; confirm day; list confirmed days for history |
| 1.1.8 | Implement `correction_repo.dart` | Write correction records; query corrections by day/field; support revert |
| 1.1.9 | Implement `sync_service.dart` | Background sync to Supabase (queue + retry); upload evidence files to Storage |
| 1.1.10 | Build shared widget: `confidence_label.dart` | Renders v2 trust labels: "Confirmed by merchant", "From screenshot", "From export", "From voice recap", "Estimated", "Needs review" |
| 1.1.11 | Build shared widget: `evidence_source_chip.dart` | Tappable chip showing origin of a value (links to screenshot/transcript/export) |
| 1.1.12 | Build shared widget: `trust_badge.dart` | Color-coded badge for confidence levels |
| 1.1.13 | Build `home_screen.dart` | Today's status: completion state, start end-of-day CTA, optional quick tap shortcut, unresolved indicator |
| 1.1.14 | Build `home_provider.dart` | Aggregate today's data; determine flow state (no data yet → evidence needed → recap needed → cash needed → ready to review → confirmed) |
| 1.1.15 | Implement home screen contextual CTA logic | Primary CTA changes based on state: "Upload Evidence" → "Record Recap" → "Enter Cash" → "Review Ledger" → "Day Confirmed" |
| 1.1.16 | Wire up go_router with actual screen widgets (once Devs 2/3/4 export their screens) | Final navigation integration |

**Interfaces Dev 1 must publish early (by end of Phase 0):**
- All model classes with `toJson()` / `fromJson()` / `copyWith()`
- Repository method signatures (abstract or documented)
- Riverpod provider patterns for repo access
- Trust label enum + confidence level enum

---

### Dev 2 — Onboarding + Menu Setup + Evidence Upload + Cash Entry + Optional Taps

| # | Task | Details |
|---|---|---|
| **Onboarding** | | |
| 2.1.1 | Build `onboarding_screen.dart` | Merchant profile: stall name, business type, language preference, accepted payment types |
| 2.1.2 | Build `onboarding_provider.dart` | State management for onboarding; calls `merchant_repo` |
| **Menu Setup** | | |
| 2.1.3 | Build `menu_setup_screen.dart` | Add/edit/delete menu items with name + price + aliases; preset suggestions ("Bihun RM6", "Mee RM6", "Teh Ais RM2") |
| 2.1.4 | Build `menu_item_tile.dart` | List tile: name, aliases, price, edit/delete actions |
| 2.1.5 | Build `menu_setup_provider.dart` | State for menu list; calls `menu_repo`; alias management |
| 2.1.6 | Implement alias support | Merchant defines alias names for each item (e.g., "goreng" = "bihun goreng") — used by recap parser |
| **Evidence Upload** | | |
| 2.1.7 | Build `evidence_upload_screen.dart` | Multi-select from gallery via `image_picker`; file import via `file_picker`; share-sheet import via `share_plus`; thumbnail previews |
| 2.1.8 | Build `extraction_preview.dart` | After OCR/parsing: show extracted amounts with editable fields; "From screenshot" / "From export" labels; manual correction inline |
| 2.1.9 | Build `evidence_provider.dart` | Manage selected files; trigger OCR (via Dev 3's service); trigger export parsing; track processing state per file |
| 2.1.10 | Support all v2 screenshot types | Single payment screenshot, transaction-history screenshot, settlement screenshot |
| 2.1.11 | Support export file import | Accept CSV/PDF/text files from wallet exports where available; pass to export parser service |
| 2.1.12 | Handle OCR/parser failures in UI | "Needs clearer image" with retry; "Unsupported format" with manual entry fallback; never silently discard evidence |
| 2.1.13 | Handle duplicate evidence | Warn if same file imported twice (hash check); allow override |
| **Counted Cash** | | |
| 2.1.14 | Build `cash_entry_screen.dart` | Large number input field; optional prefill from voice recap; "Confirm cash" button; label as "merchant-confirmed" |
| 2.1.15 | Build `cash_entry_provider.dart` | State for cash value; prefill logic (listen to parsed recap for spoken cash); save to daily evidence |
| 2.1.16 | Ensure cash is always editable | Even after ledger generation, cash field must be correctable |
| **Optional Tap Capture** | | |
| 2.1.17 | Build `selling_screen.dart` | Large item grid buttons from menu; simple count increment; lightweight — no order tray needed |
| 2.1.18 | Build `selling_provider.dart` | Store tap entries; taps are supplemental evidence, not load-bearing; doesn't block flow if unused |

**Key UX targets from PRD v2:**
- Onboarding + menu setup should be fast (under 60 seconds)
- Evidence upload: multi-format, multi-select, clear extraction preview
- Cash entry: large, friendly, impossible to accidentally skip
- Tap capture: optional, lightweight, not intimidating

---

### Dev 3 — OCR + Export Parser + Aggregate Reconciliation + Daily Ledger + Corrections

| # | Task | Details |
|---|---|---|
| **OCR Service** | | |
| 3.1.1 | Implement `ocr_service.dart` | Integrate `google_mlkit_text_recognition`; accept image path → return raw text blocks with bounding boxes |
| 3.1.2 | Implement `screenshot_parser.dart` | Parse OCR raw text to extract: amount(s) (RM), date/time, provider name, transaction ref; regex + layout heuristics |
| 3.1.3 | Build parsing rules for single-payment screenshots | Extract one amount + timestamp + provider from TNG/DuitNow/Boost single-payment layouts |
| 3.1.4 | Build parsing rules for transaction-history screenshots | Detect multiple rows; extract per-row amounts or aggregate total; handle noisier OCR |
| 3.1.5 | Build parsing rules for settlement screenshots | Extract daily settlement total from provider summary screens |
| 3.1.6 | Create `OCRExtraction` records from parsed results | Store raw text, extracted fields, confidence level, source image ref; save via `extraction_repo` |
| 3.1.7 | Handle OCR edge cases | Blurry images (low confidence flag); partial extraction (save what you got + "needs review"); multiple wallets in one day |
| 3.1.8 | Retain raw OCR text always | Never discard raw text — required for auditability per PRD v2 trust rules |
| **Export Parser** | | |
| 3.1.9 | Implement basic export file parser | Accept CSV/structured file → extract transaction amounts + totals; map to evidence model |
| 3.1.10 | Label export-derived values correctly | Source label = "From export"; confidence = variable by parser success |
| 3.1.11 | Handle unsupported export formats | Fall back to manual review; show raw content + manual entry fields |
| **Aggregate Reconciliation Engine** | | |
| 3.1.12 | Implement `reconciliation_engine.dart` | Core v2 synthesis logic (see algorithm below) |
| 3.1.13 | Implement `confidence_rules.dart` | Field-level confidence assignment based on source type (see rules below) |
| 3.1.14 | Generate draft `DailyLedger` from all evidence | Combine: OCR digital totals + export totals + counted cash + recap estimates + tap evidence |
| 3.1.15 | Surface uncertainty clearly | `uncertainty_notes[]` on ledger: e.g., "Digital total from blurry screenshot — review suggested" |
| 3.1.16 | Handle conflicting evidence | If multiple screenshots show different totals, flag discrepancy; never silently pick one |
| 3.1.17 | Supabase Edge Function: `reconcile/index.ts` | Server-side aggregate reconciliation (same logic, backup path); ledger finalization + persistence |
| **Daily Ledger Screen** | | |
| 3.1.18 | Build `daily_ledger_screen.dart` | Hero output screen: gross total, digital total, counted cash, estimated items, evidence links, certainty labels per field, "Confirm Day" CTA |
| 3.1.19 | Build `ledger_provider.dart` | Drive ledger screen from `ledger_repo`; trigger re-synthesis when evidence changes |
| 3.1.20 | Implement field-level trust labels on ledger | Every value shows its source label: "Confirmed by merchant", "From screenshot", "From export", "From voice recap", "Estimated", "Needs review" |
| 3.1.21 | Implement evidence links on ledger | Tap any value → see its source (screenshot crop, transcript excerpt, export line) |
| 3.1.22 | Implement "Confirm Day" action | Lock ledger; save confirmed state; write to business memory; no further edits without explicit correction |
| **Correction Flow** | | |
| 3.1.23 | Build `correction_screen.dart` | Edit any ledger field: digital total, cash, item counts; show current value + source; save correction |
| 3.1.24 | Build `correction_provider.dart` | Write `CorrectionRecord` via `correction_repo`; update ledger; re-run synthesis if needed |
| 3.1.25 | Support correction on confirmed days | Merchant can reopen + correct even after confirmation; audit trail preserved |

**Aggregate Reconciliation Algorithm (v2 — replaces v1 matching):**
```
INPUTS:
  - ocr_extractions[]:      amounts from screenshot OCR (with confidence)
  - export_extractions[]:   amounts from wallet export parsing (with confidence)
  - counted_cash:           merchant-entered value (or null if not yet entered)
  - parsed_recap:           item estimates + spoken cash (if any)
  - tap_entries[]:          optional tap counts (if used)

SYNTHESIS:
  1. Digital total
     - Sum all unique OCR-extracted amounts (deduplicated by screenshot)
     - Add export-parsed totals (deduplicated)
     - If both sources exist and disagree: flag discrepancy in uncertainty_notes
     - Confidence: based on source clarity (single screenshot = high, history = medium)

  2. Counted cash
     - Use merchant-entered value if available → confidence = "merchant-confirmed"
     - Else use spoken cash from parsed recap → confidence = "medium, needs confirmation"
     - Else leave blank → flag as "Cash not yet entered"

  3. Gross total
     - digital_total + counted_cash
     - If either component is estimated, gross total is also estimated

  4. Estimated item counts
     - Primary source: parsed_recap item mentions + quantities
     - Enrichment: tap_entries (if used, higher confidence for those items)
     - If recap says "sold out of bihun" → mark bihun as sold-out
     - Confidence: per-item, based on source

  5. Evidence references
     - List all evidence used: screenshot IDs, export file IDs, audio ID, tap session

  6. Uncertainty notes
     - Collect all flags: blurry OCR, conflicting totals, missing cash, low-confidence items

OUTPUT: DailyLedger {
  date, digital_total, counted_cash, gross_total,
  estimated_items[], evidence_refs[], uncertainty_notes[],
  confirmation_state: "draft"
}
```

**Field-Level Confidence Rules:**

| Field | Source | Assigned Confidence |
|---|---|---|
| Digital total from clear single screenshot | OCR | High |
| Digital total from transaction-history screenshot | OCR | Medium |
| Digital total from settlement screenshot | OCR | High |
| Digital total from export file | Export parser | Variable (high if clean parse, medium if partial) |
| Counted cash typed by merchant | Manual entry | **Merchant-confirmed** |
| Counted cash spoken in recap | STT + parser | Medium → needs merchant confirmation |
| Item count from voice recap | STT + parser | Medium or Low |
| Item count from tap entries | Tap input | High |
| "Sold out" flag from recap | STT + parser | Medium |

---

### Dev 4 — Voice Recap + STT + Recap Parser + Recap Review + History

| # | Task | Details |
|---|---|---|
| **Voice Recording** | | |
| 4.1.1 | Build `voice_recap_screen.dart` | One-tap record button (max 60s); real-time duration display; replay button; retry button; prompt text: "Tell us about your day — what did you sell? How many? Any sold out?" |
| 4.1.2 | Build `voice_provider.dart` | Audio recording via `record` package; manage states: idle → recording → recorded → processing → done |
| 4.1.3 | Save audio file locally | Store in local evidence directory; create `DailyEvidence` audio reference |
| **STT Service** | | |
| 4.1.4 | Implement `stt_service.dart` | Send audio to OpenAI transcription API (via Supabase Edge Function proxy); return raw transcript text |
| 4.1.5 | Supabase Edge Function: `transcribe/index.ts` | Proxy: accept audio upload → call OpenAI STT → return transcript; keeps API key server-side |
| 4.1.6 | Store transcript as `TranscriptRecord` | Raw text + uncertainty markers + source audio ref; save via `recap_repo` |
| 4.1.7 | Handle STT failures | Keep audio file; show "Needs review" status; allow typed manual transcript entry as fallback |
| **Menu-Aware Recap Parser** | | |
| 4.1.8 | Implement `menu_aware_parser.dart` | Takes transcript + merchant's menu items → outputs structured `ParsedRecap` |
| 4.1.9 | Item mention extraction | Match transcript words against menu item names + aliases; fuzzy matching for spoken variants |
| 4.1.10 | Quantity extraction | Detect number + item patterns: "bihun 30", "30 bihun", "teh ais sepuluh", "about 20 mee" |
| 4.1.11 | Cue detection | Detect phrases: "sold out", "habis", "about", "mostly cash", "the rest QR", "semua cash" |
| 4.1.12 | Spoken cash detection | Detect: "I counted 300 cash", "cash ada 280 lebih kurang", "tunai tiga ratus" |
| 4.1.13 | Field-level confidence tagging | Each parsed field gets confidence: item name matched to menu = medium, quantity with "about" = low, explicit number = medium |
| 4.1.14 | Supabase Edge Function: `parse-recap/index.ts` | Server-side recap parsing (if heavier logic needed); accept transcript + menu → return parsed recap |
| 4.1.15 | Store `ParsedRecap` | Item estimates, sold-out flags, recap notes, spoken cash if detected, per-field confidence; save via `recap_repo` |
| **Recap Review Screen** | | |
| 4.1.16 | Build `recap_review_screen.dart` | Show parsed results: each detected item + quantity (editable); sold-out flags; detected cash value (editable); raw transcript reference |
| 4.1.17 | Build `recap_review_provider.dart` | Manage parsed recap state; allow merchant edits before accepting; propagate accepted recap to evidence |
| 4.1.18 | Implement accept/reject per parsed field | Merchant can accept "30 bihun", reject "10 mee" (if wrong), manually add missed items |
| 4.1.19 | Implement "Apply to today" action | Accepted recap fields are saved as structured evidence for reconciliation |
| 4.1.20 | If spoken cash detected, prefill cash entry | Notify Dev 2's `cash_entry_provider` with suggested cash value from recap |
| **History / Business Memory Timeline** | | |
| 4.1.21 | Build `history_screen.dart` | List of confirmed days: date, gross total, digital total, cash; tap to open ledger detail |
| 4.1.22 | Build `history_provider.dart` | Query confirmed daily ledgers from `ledger_repo`; sorted by date descending |
| 4.1.23 | Implement basic day-detail view | Open a past day's confirmed ledger in read-only mode (reuses Dev 3's ledger screen) |

---

### Person 5 — Presentation & Demo

| # | Task | Details |
|---|---|---|
| **Narrative** | | |
| 5.1.1 | Draft v2 pitch narrative | Problem → Persona → Why Now → Solution → Demo → Differentiation → Market → Roadmap → Ask |
| 5.1.2 | Write problem statement slide | Hawkers can't answer "how much did I actually sell today?"; mixed cash + QR; fragmented evidence; existing tools require structured logging |
| 5.1.3 | Create persona slide | "Kak Lina": fried bihun seller, already uses QR, can screenshot, willing to try lightweight tool |
| 5.1.4 | Create "What we're NOT" slide | Not a POS. Not a wallet dashboard. Not an accounting suite. Not a generic AI chat. |
| 5.1.5 | Create solution overview slide | 4-step hero flow: upload evidence → voice recap → confirm cash → review daily ledger; wallet-agnostic, aggregate truth |
| **Demo** | | |
| 5.1.6 | Script v2 live demo flow | Step 1: setup (menu in 60s) → Step 2: upload 2-3 payment screenshots → Step 3: record voice recap → Step 4: enter/confirm cash → Step 5: review daily ledger with trust labels → Step 6: confirm day → show history |
| 5.1.7 | Prepare demo data / seed data | Pre-configured merchant "Kak Lina"; menu items (Bihun RM6, Mee RM6, Teh Ais RM2, Kopi RM2.50); sample screenshots (TNG, DuitNow); sample voice clip |
| 5.1.8 | Prepare fallback demo recording | In case live demo fails: pre-recorded screen capture of full flow |
| **Supporting Slides** | | |
| 5.1.9 | Create product architecture slide | Simplified visual: screenshots + voice + cash → synthesis engine → daily ledger → business memory |
| 5.1.10 | Create competitive positioning slide | Table or 2x2: POS (logging-first) vs wallet dashboards (digital-only) vs Pasar Memory (aggregate truth, mixed evidence) |
| 5.1.11 | Create trust/explainability slide | Show trust labels, evidence links, no hidden automation; address ASEAN trust barriers |
| 5.1.12 | Create market opportunity slide | Case Study 8 ASEAN MSMEs framing; Malaysian DuitNow QR growth; first-mile digitization |
| 5.1.13 | Create roadmap slide | MVP → v1.5 (better exports, history, merchant learning) → v2 (business passport, financing readiness) |
| 5.1.14 | Create "sharpest demo narrative" closing slide | "Hawkers don't need another POS. They need a fast way to turn a messy day into a trusted ledger." |
| **Judge Prep** | | |
| 5.1.15 | Prepare judge Q&A cheat sheet | "Why not just use wallet app?" → only shows digital, no cash, no cross-wallet, no business memory. "How is this different from receipt scanning?" → income reconciliation, not expense tracking. "What about accuracy?" → aggregate truth > fake precision. "Privacy?" → local-first, cloud only for STT + backup |
| 5.1.16 | Final rehearsal with team | Dry run pitch + live demo; time it; refine |

---

## Phase 2 — Integration & Polish

Begins once Phase 1 core tasks are substantially done.

| # | Task | Owner | Details |
|---|---|---|---|
| INT.1 | Dev 1 wires all screen routes into `router.dart` | Dev 1 | Connect all feature screens to go_router; define v2 flow navigation |
| INT.2 | v2 Hero flow integration: evidence → recap → cash → ledger | Dev 2 + Dev 3 + Dev 4 | End-to-end: upload screenshot → OCR → voice recap → parse → cash entry → reconciliation → ledger |
| INT.3 | OCR results flow to evidence preview | Dev 2 + Dev 3 | Dev 2's evidence screen calls Dev 3's OCR service; extracted values display in Dev 2's preview |
| INT.4 | Parsed recap flows to cash prefill | Dev 4 + Dev 2 | If voice recap detects cash value, prefill Dev 2's cash entry screen |
| INT.5 | All evidence flows to reconciliation engine | Dev 3 | Reconciliation engine reads from all repos (OCR, export, recap, cash, taps) → generates ledger |
| INT.6 | Home screen reflects live flow state | Dev 1 | Home CTA updates as evidence/recap/cash/ledger states change |
| INT.7 | History screen opens past ledger detail | Dev 4 + Dev 3 | History list (Dev 4) opens ledger screen (Dev 3) in read-only mode |
| INT.8 | Full happy-path walkthrough | All devs | Complete v2 hero flow from onboarding to confirmed day |
| INT.9 | Error state + empty state polish | Dev 2 + Dev 3 | OCR failures, empty evidence, missing cash, no recap scenarios |
| INT.10 | UI consistency pass | Dev 1 + Dev 2 | Theme, spacing, font sizes, trust labels consistent across all screens |
| INT.11 | Seed demo data for presentation | Dev 1 + Person 5 | Pre-populate Kak Lina's profile + sample evidence for smooth demo |
| INT.12 | Demo rehearsal with live app | All + Person 5 | Full run-through of demo script on real device |

---

## Coordination Rules (Merge Conflict Prevention)

### Golden Rules

1. **Never edit files outside your owned directories** without team coordination first
2. **`pubspec.yaml` is locked after Phase 0** — need a new package? Tell Dev 1
3. **`router.dart` is owned by Dev 1** — give Dev 1 your screen class name + route path, they wire it
4. **Models are owned by Dev 1** — need a field added/changed? Request it from Dev 1
5. **Each feature screen exports a single top-level widget** — Dev 1 imports it into the router
6. **Services are called via provider interfaces** — Devs don't import each other's files directly; they use Riverpod providers

### Branch Strategy

```
main
├── dev1/foundation-home     # Dev 1
├── dev2/evidence-capture    # Dev 2
├── dev3/ocr-reconciliation  # Dev 3
├── dev4/voice-recap-history # Dev 4
└── docs/presentation        # Person 5
```

- Dev 1 merges skeleton to `main` first (Phase 0 complete)
- Devs 2/3/4 rebase on `main` after Dev 1's merge
- Devs 2/3/4 merge independently (no overlapping files)
- Phase 2 integration fixes on an `integration` branch

### Communication Checkpoints

| When | What |
|---|---|
| Phase 0 done | Dev 1: "Skeleton merged to main — rebase your branches. Here are the model classes and repo interfaces." |
| Models change | Dev 1: "Model X updated — pull latest from main." |
| Repos ready | Dev 1: "Repo X is ready with these methods: [list]" |
| OCR service ready | Dev 3: "OCR service ready — call `ocrService.extract(imagePath)` → returns `OCRExtraction`" |
| STT service ready | Dev 4: "STT service ready — call `sttService.transcribe(audioPath)` → returns `TranscriptRecord`" |
| Recap parser ready | Dev 4: "Recap parser ready — call `recapParser.parse(transcript, menuItems)` → returns `ParsedRecap`" |
| Screen ready | Devs 2/3/4: "Screen X exported as `WidgetName` — add to router" |
| Before Phase 2 | Everyone syncs; resolve any interface mismatches |

---

## Dependency Map (What Blocks What)

```
Phase 0 (Dev 1: scaffold + models + repo interfaces)
    │
    ├──→ Dev 2 can start all UI (uses model classes + repo interfaces)
    ├──→ Dev 3 can start OCR service (independent) + parsing logic
    ├──→ Dev 4 can start voice recording UI + STT service (independent)
    └──→ Person 5 can start full pitch deck (independent)

Dev 1 repos ready (Phase 1 early)
    │
    ├──→ Dev 2 wires providers to repos (evidence_repo, menu_repo, merchant_repo)
    ├──→ Dev 3 wires OCR results to extraction_repo
    └──→ Dev 4 wires transcripts + parsed recaps to recap_repo

Dev 3 OCR service ready
    │
    └──→ Dev 2 can call OCR from evidence upload screen

Dev 4 STT + recap parser ready
    │
    ├──→ Dev 4 builds recap review screen with real parsed data
    └──→ Dev 2 can receive spoken-cash prefill for cash entry

Dev 3 reconciliation engine ready
    │
    └──→ Dev 3 builds daily ledger screen with real synthesized data
    └──→ Dev 1 home screen can show accurate daily state

All screens ready
    │
    └──→ Dev 1 wires router → Phase 2 integration begins
```

---

## Summary: Who Does What, Who Touches What (v2)

| File/Directory | Dev 1 | Dev 2 | Dev 3 | Dev 4 | P5 |
|---|---|---|---|---|---|
| `pubspec.yaml` | **Own** | — | — | — | — |
| `lib/main.dart`, `app.dart`, `router.dart` | **Own** | — | — | — | — |
| `lib/models/*` | **Own** | Read | Read | Read | — |
| `lib/data/*` | **Own** | Read | Read | Read | — |
| `lib/shared/*` | **Own** | Use | Use | Use | — |
| `lib/services/sync/` | **Own** | — | — | — | — |
| `lib/services/ocr/` | — | — | **Own** | — | — |
| `lib/services/reconciliation/` | — | — | **Own** | — | — |
| `lib/services/stt/` | — | — | — | **Own** | — |
| `lib/services/recap_parser/` | — | — | — | **Own** | — |
| `lib/features/home/` | **Own** | — | — | — | — |
| `lib/features/onboarding/` | — | **Own** | — | — | — |
| `lib/features/menu_setup/` | — | **Own** | — | — | — |
| `lib/features/evidence/` | — | **Own** | — | — | — |
| `lib/features/cash_entry/` | — | **Own** | — | — | — |
| `lib/features/selling/` | — | **Own** | — | — | — |
| `lib/features/ledger/` | — | — | **Own** | — | — |
| `lib/features/correction/` | — | — | **Own** | — | — |
| `lib/features/voice/` | — | — | — | **Own** | — |
| `lib/features/recap_review/` | — | — | — | **Own** | — |
| `lib/features/history/` | — | — | — | **Own** | — |
| `supabase/migrations/` | **Own** | — | — | — | — |
| `supabase/functions/reconcile/` | — | — | **Own** | — | — |
| `supabase/functions/transcribe/` | — | — | — | **Own** | — |
| `supabase/functions/parse-recap/` | — | — | — | **Own** | — |
| `docs/presentation/` | — | — | — | — | **Own** |

---

## Quick Reference: v2 Screen List → Owner

| Screen | Owner | Route |
|---|---|---|
| Home / Today | Dev 1 | `/` |
| Onboarding | Dev 2 | `/onboarding` |
| Menu Setup | Dev 2 | `/menu-setup` |
| Evidence Upload | Dev 2 | `/evidence` |
| Cash Entry | Dev 2 | `/cash` |
| Selling (optional taps) | Dev 2 | `/selling` |
| Daily Ledger | Dev 3 | `/ledger` |
| Correction | Dev 3 | `/correction` |
| Voice Recap | Dev 4 | `/voice` |
| Recap Review | Dev 4 | `/recap-review` |
| History Timeline | Dev 4 | `/history` |
