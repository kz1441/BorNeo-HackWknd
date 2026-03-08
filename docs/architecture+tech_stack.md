# Pasar Memory — Architecture & Tech Stack (v2)

> Updated to align with **PRD v2**: aggregate end-of-day reconciliation, voice recap as Must, counted cash as first-class input, optional live taps, wallet-agnostic export ingestion.

---

## Recommended system architecture

```text
[Flutter Mobile App]
   ├─ UI Layer
   ├─ Local DB (SQLite)
   ├─ Evidence Capture Layer
   │   ├─ Screenshot / image import
   │   ├─ Export / file import (where available)
   │   ├─ Voice recording
   │   ├─ Counted cash entry
   │   └─ Optional live tap input
   ├─ On-device OCR (first pass)
   ├─ Local draft ledger preview
   ├─ Local evidence store (images, audio, imports)
   └─ Sync Queue
          ↓
[Supabase Backend]
   ├─ Auth
   ├─ Postgres
   ├─ Storage (screenshots, audio, export files)
   ├─ Edge Functions
   │   ├─ STT orchestration (OpenAI transcription)
   │   ├─ Menu-aware recap parsing
   │   ├─ Optional export file parsing
   │   ├─ Aggregate reconciliation / ledger synthesis
   │   └─ Daily ledger persistence
   └─ Sync / backup
          ↓
[Business Memory Layer]
   ├─ Daily ledgers (confirmed)
   ├─ Evidence references
   ├─ Correction history
   └─ Timeline / history
```

## Why this architecture fits the product

This product is for hawkers and fresh-market merchants, so it must work in **fast, messy, sometimes low-connectivity environments**. Flutter is a good fit because it supports iOS and Android from a single codebase. ([Flutter][1])

For local persistence, the app is **offline-first** with a local SQL store on-device. Flutter's docs recommend SQLite for complex local persistence. ([Flutter Docs][2])

For OCR, **Google ML Kit Text Recognition** runs on-device first, supporting real-time recognition for screenshots and receipts. ([Google for Developers][3])

For backend, **Supabase** gives Postgres, Auth, Storage, Realtime, and Edge Functions in one stack. ([Supabase][4])

For speech-to-text, **cloud transcription** via OpenAI for demo reliability. ([OpenAI Platform][5])

---

## Core synthesis pipeline (v2)

PRD v2 shifts from **transaction-level matching** to **aggregate end-of-day synthesis**. The system no longer tries to match individual payments to individual orders. Instead:

```text
Screenshot(s) / export file(s)
        │
        ▼
  On-device OCR  /  Export parser
        │
        ▼
  Extracted digital total(s)  ──┐
                                │
Voice recap                     │
        │                       │
        ▼                       │
  Cloud STT → transcript        │
        │                       ├──→  Aggregate Reconciliation Engine
        ▼                       │          │
  Menu-aware recap parser       │          ▼
        │                       │     Draft Daily Ledger
        ▼                       │     (with field-level confidence)
  Structured recap ─────────────┤          │
  (item estimates, cues)        │          ▼
                                │     Merchant review + correction
Counted cash ───────────────────┤          │
  (typed or spoken)             │          ▼
                                │     Confirmed Daily Ledger
Optional tap evidence ──────────┘          │
                                           ▼
                                  Saved to Business Memory
```

### What changed from v1

| v1 approach | v2 approach |
|---|---|
| Match individual payments to individual orders | Aggregate totals from all evidence sources |
| Cash inferred from unmatched orders | Cash explicitly entered by merchant |
| Live tapping as primary capture | Live tapping as optional enrichment |
| Voice recap as Should (v1.5) | Voice recap as Must (hero flow) |
| Matching results + unresolved queue | Single daily ledger with field-level confidence |

---

# Recommended tech stack

## 1. Mobile app

**Use:** Flutter + Dart
**Why:** one codebase, fast iteration, Android-first, easy to demo. ([Flutter][1])

### App-layer libraries

* **Flutter**
* **Riverpod** for state management (faster hackathon development than Bloc)
* **go_router** for navigation
* **sqflite** for local DB ([Flutter Docs][2])
* **dio** for API/network calls
* **freezed + json_serializable** for typed models
* **image_picker / file_picker / share_plus** for screenshot + export import
* **record** for audio capture
* **intl** for number/date formatting
* **uuid** for local ID generation

## 2. Local storage and offline layer

**Use:** SQLite on-device
**Why:** hawkers may have weak connectivity; app cannot depend on always-on internet. ([Flutter Docs][2])

### What lives locally

* merchant profile + menu items + aliases
* imported evidence metadata (screenshots, exports, audio)
* OCR extraction results (draft)
* voice transcript + parsed recap (draft)
* counted cash value
* optional tap entries
* draft daily ledger
* sync status / retry queue

### Local-first rule

The **phone is the system of capture and draft generation**.
The cloud is the **system of heavy processing (STT, recap parsing), backup, and history persistence**.

---

## 3. OCR / screenshot extraction

**Use:** Google ML Kit Text Recognition on-device
**Why:** runs on Android/iOS, handles Latin script well, fits Malaysian payment screenshots. ([Google for Developers][3])

### OCR responsibilities

* extract amount(s) — single or multiple from history screenshots
* extract date / time where visible
* detect provider text if possible
* detect transaction reference if present
* retain raw OCR text for auditability
* support partial extraction with manual correction fallback

### Screenshot types supported in MVP

* **Single payment screenshot** — one transaction, extract amount + time + provider
* **Transaction-history screenshot** — multiple rows, extract per-row amounts or aggregate total
* **Settlement screenshot** — daily total from provider

### Why on-device first

* faster user feedback
* better privacy
* works offline
* cheaper than cloud image processing

---

## 4. Export / file ingestion

**New in v2.** Wallet-agnostic export support where available.

### Responsibilities

* accept imported structured or semi-structured payment records
* parse supported formats (CSV, PDF statement, provider-specific share output)
* map imported fields into evidence model
* label source as "export-derived"
* fall back to manual review when parser confidence is low

### MVP stance

* support 1-2 demo-ready formats (e.g., TNG eWallet export, generic CSV)
* product must still work without any export — screenshots are the default

---

## 5. Speech-to-text

**MVP choice:** cloud transcription
**Use:** OpenAI transcription API (`gpt-4o-mini-transcribe`)
**Why:** better quality for noisy market audio; faster to integrate for hackathon. ([OpenAI Platform][5])

### STT responsibilities (v2 — now Must, not Should)

* transcribe short recap clips (under 60 seconds)
* output raw transcript for display and review

### Post-STT: Menu-aware recap parser

This is a **separate processing step** after STT, not part of the STT service itself:

* use merchant's menu items as context
* extract item mentions and map to menu
* extract rough quantities
* detect cues: "sold out", "about", "most were cash", "the rest QR"
* detect spoken counted cash if present ("I counted around 300 ringgit cash")
* assign confidence per parsed field
* output: structured recap with item estimates + counted cash candidate + uncertainty flags

### Fallback behavior

If STT fails:
* keep the audio file
* show "needs review" with raw/failed transcript
* allow typed correction / manual recap entry

---

## 6. Backend

**Use:** Supabase (recommended for hackathon speed)

### Why Supabase

Supabase gives: Postgres + Auth + Storage + Realtime + Edge Functions in one platform. ([Supabase][4])

### Recommended Supabase pieces

* **Auth** for merchant identity (phone OTP or email)
* **Postgres** for merchant profile, daily ledgers, correction history, business memory timeline
* **Storage** for screenshots, audio files, imported export files
* **Edge Functions** for:
  * STT orchestration (proxy to OpenAI — keeps API key server-side)
  * Menu-aware recap parsing logic
  * Export file parsing (if heavier logic needed)
  * Aggregate reconciliation / ledger synthesis
  * Daily ledger finalization and persistence

---

## 7. Aggregate reconciliation engine (v2 — replaces matching engine)

**MVP choice:** rules-based aggregate synthesis
**Where:** Supabase Edge Functions + on-device draft preview

### What changed

PRD v2 explicitly rejects transaction-level matching as the hero feature:
> "Prefer credible aggregate outputs to fragile exact matching."
> "Must not pretend transaction-level truth when only aggregate truth exists."

### Reconciliation logic (v2)

The engine combines evidence from four sources into one daily ledger:

```
1. Digital total(s)
   Source: OCR-extracted amounts from screenshots + export-parsed totals
   Treatment: sum all digital evidence; flag if sources disagree

2. Counted cash
   Source: merchant-entered value (typed or spoken in recap)
   Treatment: merchant-confirmed — highest trust level

3. Recap-derived estimates
   Source: menu-aware parsed recap (item names + quantities)
   Treatment: estimated — medium/low confidence; used for item counts

4. Optional tap evidence
   Source: live tap entries during selling hours
   Treatment: supplemental — used to enrich item counts if available
```

### Synthesis output: Draft Daily Ledger

```
{
  date,
  digital_total:       { value, confidence, sources[] },
  counted_cash:        { value, confidence: "merchant-confirmed", source },
  gross_total:         { value: digital + cash, confidence },
  estimated_items:     [{ menu_item, qty, confidence, source }],
  evidence_refs:       [{ type, id, thumbnail? }],
  uncertainty_notes:   ["Digital total from blurry screenshot — review suggested"],
  confirmation_state:  "draft" | "confirmed"
}
```

### Field-level confidence rules

| Field | Source | Confidence |
|---|---|---|
| Digital total from clear single screenshot | OCR | High |
| Digital total from transaction-history screenshot | OCR | Medium (noisier) |
| Digital total from export file | Export parser | Variable by parser success |
| Counted cash typed by merchant | Manual entry | Merchant-confirmed |
| Counted cash from spoken recap | STT + parser | Medium (needs merchant confirmation) |
| Item count from recap | STT + parser | Medium or Low |
| Item count from taps | Tap input | High (if used) |

---

## 8. Storage architecture

### Local (SQLite)

* merchant profile + menu items + aliases
* evidence metadata (screenshot paths, audio paths, export file paths)
* OCR extraction records
* export extraction records
* transcript + parsed recap records
* counted cash value
* tap entries
* draft daily ledger
* correction records
* sync queue

### Cloud (Supabase Postgres + Storage)

* merchant profile + menu items
* daily ledgers (confirmed)
* correction history
* business memory timeline
* evidence files (screenshots, audio, exports) in Storage

### Data objects (v2)

* `merchant` — profile, locale, timezone
* `menu_item` — name, price, aliases, active flag
* `daily_evidence` — screenshots, export files, audio, tap entries, notes for a given day
* `ocr_extraction` — raw text, extracted amounts/fields, confidence, source image ref
* `export_extraction` — parsed fields, parser confidence, raw import ref
* `transcript_record` — raw transcript text, uncertainty markers, source audio ref
* `parsed_recap` — item estimates, sold-out flags, recap notes, counted cash if spoken, parse confidence
* `daily_ledger` — date, digital total, counted cash, gross total, estimated item counts, evidence links, confirmation state, uncertainty notes
* `correction_record` — what changed, old value, new value, who edited, timestamp
* `tap_entry` — (optional) menu item, quantity, timestamp

---

## 9. Trust labels (v2 — required)

Every field in the daily ledger must carry one of these labels:

* **Confirmed by merchant** — manually entered or explicitly confirmed
* **From screenshot** — OCR-derived
* **From export** — export-parser-derived
* **From voice recap** — STT + recap-parser-derived
* **Estimated** — inferred, low confidence
* **Needs review** — extraction uncertain, manual correction recommended

---

# Best stack choice for hackathon MVP

## Frontend

* Flutter + Dart
* Riverpod
* sqflite
* go_router
* dio
* image_picker / file_picker / share_plus
* record
* freezed + json_serializable
* intl + uuid

## AI / multimodal

* Google ML Kit OCR (on-device)
* OpenAI STT (cloud, via Edge Function proxy)
* Menu-aware recap parser (custom rules-based)
* Export file parser (custom, format-specific)
* Aggregate reconciliation engine (rules-based synthesis)

## Backend

* Supabase Auth
* Supabase Postgres
* Supabase Storage
* Supabase Edge Functions

## Dev / infra

* GitHub
* GitHub Actions (optional for demo)
* Sentry or Firebase Crashlytics (if time permits)

---

# What should run on-device vs cloud

## On-device

* menu setup + merchant profile
* screenshot import + file import
* OCR first pass (ML Kit)
* counted cash entry
* optional live tap capture
* voice recording
* local evidence storage
* draft ledger preview
* offline queue

## Cloud (via Supabase Edge Functions)

* speech transcription (OpenAI STT)
* menu-aware recap parsing
* export file parsing (if heavier logic)
* aggregate ledger synthesis (finalization)
* daily ledger persistence + backup
* evidence file backup (Storage)

This split gives you:
* fast UX on-device
* resilience in weak internet
* API keys stay server-side
* lower cloud cost
* simpler MVP ops

---

# Strongest recommendation

## Architecture decision

**Offline-first Flutter mobile app + local SQLite + on-device OCR + Supabase backend + cloud STT + menu-aware recap parser + rules-based aggregate reconciliation**

## Best framing

This is **not** a POS stack.
It is a **post-market reconciliation notebook with a business-memory backend**.

The hero flow is:
1. Merchant finishes selling
2. Uploads payment screenshots (and/or export if available)
3. Records a short voice recap
4. Enters or confirms counted cash
5. Reviews the generated daily ledger
6. Confirms and saves the day into business memory

[1]: https://flutter.dev/ "Flutter - Build apps for any screen"
[2]: https://docs.flutter.dev/cookbook/persistence/sqlite "Persist data with SQLite"
[3]: https://developers.google.com/ml-kit/vision/text-recognition/ "Text recognition v2 | ML Kit"
[4]: https://supabase.com/docs "Supabase Docs"
[5]: https://platform.openai.com/docs/models/gpt-4o-mini-transcribe "GPT-4o mini Transcribe"
[6]: https://developers.google.com/ml-kit/vision/digital-ink-recognition "Digital ink recognition | ML Kit"
[7]: https://supabase.com/docs/guides/realtime "Realtime | Supabase Docs"
