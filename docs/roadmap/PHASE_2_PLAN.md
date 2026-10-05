# ShotKit — Phase 2 plan

Date: 2026-10-04 · Status: draft for review · Live: v1.0.0, 38 installs (Play shows "10+")

---

## 1. Summary

**Where we are.** ShotKit has everything the category treats as basic: projects → scenes →
shots, shot specs, reference images, done tracking, on-set mode, PDF export, and offline use.
It's free, needs no account, and runs on Android only.

**What changed in the market.** In Aug–Sep 2026 at least 8 new Android shot-list apps launched
with nearly the same pitch: offline, no account, templates, on-set mode (Taketino, Shoot Planner,
TakeLedger, ShotList Pocket, and others). Being "free and offline" no longer sets us apart.

**Where the openings are:**

1. **Shoot-day scheduling on Android.** No Android app with real traction offers shooting order
   (separate from story order), time estimates, and a live "ahead/behind" schedule. That's Shot
   Lister's core paid feature (Pro $15.99/mo), and their Play listing has been gone since 2023.
2. **Quality.** The Android apps with real install numbers are rated low or abandoned: Shot
   Designer 3.7★ with a dated UI, Studiovity 3.2★ and buggy, Celtx 2.5★, Artemis abandoned. A
   polished, reliable app stands out on quality alone.
3. **Wedding videographers.** Play search for "wedding shot list" returns only photo-editing and
   wedding-planning apps. Photographers have dedicated tools (ShotLace, My Shot List); video
   shooters don't.
4. **Paywall anger.** The most common complaint across competitors is save, export or PDF
   behind a paywall, or stacked subscriptions. Keep all of that free.

**The phase 2 bet:**

> **ShotKit = the polished, free, offline *shoot-day* app for Android filmmakers and wedding
> videographers.**
> We win on (1) design quality, (2) a shoot-day engine (shooting order + live schedule),
> (3) visual storyboards, and (4) a wedding-specific workflow.

---

## 2. Competitor landscape

### Key competitors

| App | Platform | Price | Traction | What we take from it |
|---|---|---|---|---|
| Shot Lister | iOS/Mac/Watch (Android listing removed Apr 2023)¹ | Free; Pro $15.99/mo or $99.99/yr | iOS 4.6★ (201) | Live Mode (ahead/behind schedule) is the feature people pay for. We bring it to Android, free. |
| Shot Designer | Android, iOS, desktop | Free for 1 scene; Pro $19.99 one-time | Android 100K+, 3.7★ | Camera diagrams are loved; save/export paywall and dated UI are hated. |
| CineFlo | Android, iOS, web | 1 project free; $7.99/mo or $59.99/yr | Android 1K+ | Closest full-suite Android rival (call sheets, budgets). Heavy; we stay light. |
| Studiovity | Android, iOS, web | $2.49–$29.99/mo | Android 100K+, 3.2★ | Users ask for offline mode and complain of blank PDFs and lost data. Reliability wins. |
| Magic Cinema ViewFinder | Android, iOS | Ads + ~$1.49 | Android 1M+, 4.0★ | Proves Android demand for framing tools and cheap one-time unlocks. |
| StudioBinder | Web only (no native app) | Free: 1 project, 10 shots; paid $29–$99/mo | Market leader | Free tier caps at 10 shots. "Unlimited shots, free, on your phone" answers it directly. |
| ShotList (iOS) | iOS only, stale since 2023 | $9.99 | 4.8★ (200) | Users have asked for Android since 2011 and never got it. |
| Taketino, Shoot Planner, TakeLedger… | Android (new, under 600 installs each) | Free / IAP | Tiny | Direct lookalikes. Beat them on polish, ASO, and the wedding niche. |

¹ Sources disagree. A direct Play check returned 404 for both Shot Lister package IDs, but an
APK mirror (andro.io) still shows download stats. Treat it as "not meaningfully on Android".

### Feature gaps

| Feature | ShotKit today | Market | Phase 2 decision |
|---|---|---|---|
| Shot specs, scenes, reorder, images, done, PDF, offline | ✅ | Table stakes | Keep. Polish in the design overhaul |
| Animated framing previews | ✅ | Rare | **Lean into it.** Use them as auto-thumbnails and storyboard panels |
| Shooting order ≠ story order | ❌ | Mid/upper tier | **1.2 (flagship)** |
| Time estimates + live ahead/behind | ❌ (duration stored, unused) | Shot Lister's paid core | **1.2 (flagship)** |
| Takes / circle takes / take notes | ❌ | Requested in reviews | **1.2** |
| CSV/Excel export | ❌ | Common | **1.2** |
| Storyboard grid view + PDF | ❌ | Common, a major search term | **1.3** |
| Aspect ratios incl. 9:16 | ❌ | Rising (Reels, vertical dramas) | **1.3** |
| Gear / lens kit | Partial (custom lens/camera) | Common | **1.3** ("My kit") |
| Backup / restore | ❌ (Android Auto Backup only²) | Rare on Android | **1.4** |
| Share project with crew | ❌ | Desktop table stakes | **1.4** (file-based, no account) |
| Wedding timeline / couple's list | ❌ | No video tool has it | **1.4** |
| Script import (Fountain/FDX) | ❌ | Pro tier | Phase 3 candidate |
| Call sheets, budgets | ❌ | Full suites | Not planned |
| AI image generation | ❌ | Heavily hyped | Not planned (needs cloud, costs per image) |
| Cloud sync / accounts | ❌ | Common | Not planned |

² The manifest doesn't set `allowBackup`, so Android Auto Backup is on by default and may
restore data on a new phone. It isn't guaranteed, it's capped at 25 MB, and users can't move a
project to another person's phone.

---

## 3. Goals for phase 2 (about 90 days, to early Jan 2027)

These are targets to steer by, not predictions.

| Metric (Play Console) | Now | Target |
|---|---|---|
| Total installs | 38 | 500 (stretch 1,000) |
| Store listing conversion | unknown | At or above the peer median shown in Play Console |
| Ratings | ~0 | 15+ ratings, average ≥ 4.5★ |
| User-perceived crash rate | — | < 0.5% (Play's "bad behavior" line is 1.09%) |
| Search rank for "shot list" | not in top 14 | top 10 |
| Search rank for "wedding shot list" | not ranked | top 5 |

Measure through Play Console only. **No third-party analytics in phase 2**, so the Data Safety
form can keep saying "no data collected." That claim is part of the pitch.

---

## 4. Roadmap

Size guide: **S** = 1–2 days · **M** = 3–5 days · **L** = 1–2 weeks.

| Release | Theme | Main items | Size |
|---|---|---|---|
| **1.0.1** | Store & fixes | ASO rewrite, bug fixes, review prompt, feedback link | S |
| **1.1** | New look | Full design overhaul + new store screenshots | L |
| **1.2** | Shoot day ⭐ | Shooting order, setups, time estimates, live on-set mode, takes, CSV export | L |
| **1.3** | Storyboard | Storyboard grid + PDF, aspect ratios, new templates, coverage generator, My kit | L |
| **1.4** | Team & wedding | `.shotkit` share files, backup/restore, CSV import, wedding pack | L |

The design overhaul comes **before** the new features on purpose: 1.2–1.4 add several new
screens, and building them on the new design system means designing them only once.

### 1.0.1 — Store & fixes (ship this week)

- [ ] **Store listing (no code needed, biggest lever):**
  - Title: `ShotKit: Shot List Planner` (26/30). It captures both "shot list" and "shot planner".
  - Short description: `Free offline shot list planner for filmmakers, videographers & wedding shoots` (77/80)
  - Rewrite the full description to naturally mention *shot list, storyboard, filmmaking,
    videography, wedding videography, music video, interview, short film, offline, PDF*,
    3–5 times each. Don't use "best", "#1", or ALL CAPS (Play metadata policy).
- [ ] Fix the project badge, which shows the raw database ID ("1000A") and overflows
  ([projects_screen.dart:380](../../lib/features/projects/projects_screen.dart#L380)).
- [ ] Add bottom padding so the FAB doesn't cover the last scene or shot row.
- [ ] Add an in-app review prompt (`in_app_review`) after a successful PDF export or after
  finishing an on-set session, only from the 3rd app open onward. Never put it behind a button
  or ask a "do you like us?" pre-question.
- [ ] Add "Send feedback" (shows the email address) in Kit settings.
- [ ] Update the README: it still describes the removed `pro_unlock` purchase and watermark.

### 1.1 — New look (design overhaul)

See [section 5](#5-design-overhaul) for the details.

- [ ] Design tokens and a component library (spacing, type scale, color roles, radius, motion)
  in [app_theme.dart](../../lib/core/theme/app_theme.dart) and
  [shotkit_widgets.dart](../../lib/core/widgets/shotkit_widgets.dart).
- [ ] Redesign Home, Project, Scene/shot list, Shot editor, On-set, Export, and Settings.
- [ ] First-run onboarding, from picking a template to a sample project.
- [ ] **Daylight mode:** a high-contrast light theme for outdoor shoots, where dark screens
  can't be read in sun.
- [ ] New store screenshots and feature graphic (see section 6).

### 1.2 — Shoot day ⭐ (the flagship)

- [ ] **Story order / shoot order toggle** on the project screen. Shoot order is a flat list of
  every shot, grouped into **setups** (same location + camera position or lens). It's
  auto-suggested from scene location and lens, and can be drag-reordered independently of
  story order.
- [ ] **Time estimates:** per-shot estimate with smart defaults by movement (static < gimbal <
  drone), scene and project totals, and a projected wrap time. The existing `durationSec` is
  screen time; shoot time is a new field.
- [ ] **Live on-set mode:**
  - "Start day" sets the call time.
  - An **ahead/behind badge**.
  - A current-shot timer.
  - Done → next, skip to later, and retake.
  - **Triage hint:** when behind schedule, e.g. "20 min behind · 3 must-haves left · consider
    dropping 4 optional shots". No competitor does this.
- [ ] **Takes:** take counter, circle take, take note.
- [ ] **Shoot-day schedule PDF** (shoot order with clock times) and **CSV export** that opens
  cleanly in Google Sheets.
- [ ] **Database v1 → v2 migration:**
  - New shot fields: shoot order, setup, time estimate, status, takes.
  - New project fields: shoot date, call time.
  - Show the existing `scenes.notes` column in the UI.
  - **Before migrating, copy `shotkit.sqlite` to a `.v1.bak` file**, and add drift
    schema-migration tests. 38 people have real data and none of it can be lost.
- [ ] Ship through the Play closed-testing track first, with users found via the feedback link
  and communities.

### 1.3 — Storyboard

- [ ] **Storyboard grid view** (2–3 columns) per scene or project. Each panel shows the
  reference image, or **an auto-generated framing panel** drawn from size and angle, reusing
  the existing frame painters. Every shot gets a visual even without a photo.
- [ ] **Storyboard PDF layout** (6 panels per page) as a third export layout.
- [ ] **Project aspect ratio:** 16:9, 2.39:1, 1.85:1, 4:3, 9:16, 4:5, 1:1. Framing previews and
  panels follow it, and 9:16 shows safe-zone guides.
- [ ] **New templates:** Reels/TikTok (hook → build → payoff), YouTube (A-roll + B-roll),
  Corporate/brand (3-shot rule), Product/commercial, Documentary interview (A/B cam).
- [ ] **Coverage generator.** "Add coverage" on a scene offers offline, rule-based patterns:
  - Two-person dialogue: master, 2 singles, 2 OTS, inserts.
  - Interview: A-cam MCU, B-cam profile CU, 5× B-roll.
  - Product: hero, details, in-use.
  - Event moment: wide, medium, reaction.

  This covers what people want from AI shot lists, with no cloud and no cost.
- [ ] **My kit:** save your own lenses and cameras once; the shot editor shows only those.

### 1.4 — Team & wedding

- [ ] **`.shotkit` project file:** project data plus images in one file, sent through the
  Android share sheet. On another phone it opens in ShotKit and imports as a copy. This covers
  "share with my second shooter" without accounts or servers.
- [ ] **Backup & restore all projects** to Files or Drive through the system file picker, with a
  "last backup 30+ days ago" reminder.
- [ ] **CSV import** from Google Sheets templates, and possibly StudioBinder's CSV export (its
  column format still needs checking).
- [ ] **Wedding pack:**
  - Wedding-day timeline with clock times per block (builds on the 1.2 time engine).
  - Couple's must-capture list (people and moments) that turns into must-have shots.
  - Family-group combinations.
  - **Offline sunset and golden-hour times** from date and city (no location permission).
  - Camera assignment (Cam A / Cam B / 2nd shooter), with a per-camera on-set view.
  - A client-friendly "What we'll capture" PDF to send to the couple.
- [ ] Add a **wedding custom store listing** (`&listing=wedding`) with wedding screenshots and
  copy, for wedding Facebook groups and the landing page.

---

## 5. Design overhaul

### Principles

1. **Keep the brand DNA.** Dark ground, amber accent, hazard-tape header, monospace slate codes,
   and film language ("slates", "in the can"). It's distinctive, so we refine it.
2. **One-handed and glanceable on set.** Big targets, key info at a glance, and nothing a user
   has to read twice at 6 am.
3. **Every shot has a picture.** Use the framing previews everywhere a photo is missing.
4. **Fewer controls per row.** Move secondary actions into gestures, a reorder mode, or a
   detail sheet.
5. **Readable in sunlight.** Daylight mode, WCAG AA contrast, support for large text.

### Audit of the current screens and fixes

| Screen | Problem (from the store screenshots) | Fix |
|---|---|---|
| Home | Mostly empty. The "Ready for the next call" card says little. The badge shows "1000A". Archive takes a whole nav tab. | "Next shoot" card (date, must-haves left, Start on-set). Quick-start templates. Real empty-state onboarding. Archive moves to a filter or settings, and the nav shrinks to 3–4 tabs. |
| Project | The big progress card pushes scenes below the fold. The drag handle sits outside the card. | A compact header with progress plus story/shoot toggle. Drag only in reorder mode. Show scene time totals. |
| Shot list | Titles cut off ("Rings on invita…") because 5 controls share each row. Empty image boxes. "MUST" on every row means nothing. The FAB covers the last row. | Two-line titles. Swipe right = done, swipe left = duplicate/delete. Kebab and drag handle only in reorder mode. Auto framing thumbnail. Mark only *optional* shots (must-have is the default). Bottom padding. |
| On-set | The "Next up" card is a black box. Done shots stay at the top of the queue. | Next up shows the reference image or a large framing preview, plus a timer. Done shots collapse into "Done (2)". A big "Done → next" button within thumb reach. Haptics. |
| Shot editor | 2,300 lines and many steps, slow for quick capture. | "Quick add" (description + size, everything else optional). Remember recent combinations. Keep the guided builder for detail. |
| Export | Fine, but trust copy takes the space. | Live thumbnail preview of the chosen layout. Add the schedule and storyboard layouts. |
| Store screenshots | Raw captures with no captions or framing. | Captioned 1080×1920 set. The first 3 show the real UI plus a benefit. |

### Process

1. Mock the 4 key screens (Home, Shot list, On-set, Storyboard) in **Figma** first, which is
   connected here. Agree on direction before writing code.
2. Build tokens and components, then redesign screen by screen. Keep the existing widget
   tests green.
3. Capture new store screenshots from the real app.

---

## 6. Growth track (runs alongside the releases)

| When | Action |
|---|---|
| Week 1 | ASO rewrite (1.0.1). Note the current ranks for "shot list", "shot planner", "storyboard" and "wedding shot list", then re-check weekly. |
| After 1.1 | New screenshots, 4–8 portrait images. Captions such as "Never miss a must-have shot", "Works offline on set", "Export a PDF for your crew". No "Download now". Taglines take ≤ 20% of each image. |
| After 1.1 | Turn the GitHub Pages site (now only the privacy policy) into a small landing site. Add **free shot-list template pages** (wedding, interview, music video, YouTube B-roll) with PDFs made in ShotKit and a link to Play, to catch "… shot list template" searches. **Keep the current privacy-policy URL working**, because Play Console links to it. |
| Ongoing | Communities, help first and link second: r/Filmmakers, r/videography, r/WeddingVideography (check each sub's promo rules), r/SideProject for a build story, LOOKSLIKEFILM and WEVA Facebook groups (wedding), Discord filmmaking servers. |
| Ongoing | Listings and pitches: submit to Pro Filmmaker Apps and AlternativeTo (as an alternative to Shot Lister, StudioBinder and Shot Designer). Pitch "free Android shot list app" to the Scriptation, Storyflow, Daniel Grindrod and Robb Montgomery roundups. |
| 1.2 | Announce the shoot-day engine as "Shot Lister's Live Mode, free, on Android". Use Product Hunt for this release, mainly for backlinks. |
| 1.4 | Wedding custom store listing + wedding landing page. |
| Weekly | Play Console check: store listing conversion vs. peers, top search terms, installs and uninstalls, crash and ANR rates, new reviews (reply to every one). |

There isn't enough traffic for store A/B experiments yet; they need roughly 500–1,000 listing
visitors a week. Until then, make one big change at a time and compare 2–4 weeks before and
after.

---

## 7. Out of scope for phase 2

| Item | Why not now |
|---|---|
| AI storyboard image generation | Needs cloud, costs money per image, and frames drift between panels. The offline coverage generator covers the useful part. |
| Cloud sync and accounts | Breaks "no account, no data collected". `.shotkit` files cover sharing. |
| Call sheets, budgets, Movie Magic export | Full-suite territory (CineFlo, StudioBinder). Adds scope with little value for solo or mobile users. |
| iOS version | iOS already has strong tools (Shot Lister, Previs, Cadrage). Android is the gap. Revisit in phase 3. |
| Fountain/FDX script import | Valuable for students and short films. **Phase 3 candidate.** |
| Camera capture with framelines | Proven demand (Magic ViewFinder 1M+). **Phase 3 candidate.** |
| Monetization | See below. |

### Monetization stance

Stay **completely free** through phase 2. Revisit at about 1,000 installs. If we add revenue
then, use an optional **one-time** "Supporter" unlock at $4.99–$9.99 for extras such as themes
or advanced layouts. **Never** charge for save, export, PDF, or the number of projects or shots.
Reviews show those paywalls are what users hate most.

---

## 8. Risks

| Risk | Mitigation |
|---|---|
| Lookalike apps keep launching | Compete on polish, shoot-day engine, wedding niche, and ASO, not on "offline and free". |
| Data loss in the v1 → v2 migration | Copy the database before migrating, write migration tests, run a closed-testing beta. |
| Too few users for clear feedback | Feedback link, reply to every review, closed-testing track, ask in communities. |
| Scope creep for a solo developer | Ship each release separately. Anything not on this page goes to phase 3. |
| Research blind spot | Reddit was unreachable during research. Skim 2–3 r/Filmmakers and r/WeddingVideography threads by hand before locking 1.2. |

---

## 9. Sources (key)

**Play and App Store**
- Play search pages, checked 2026-10-04:
  [shot list](https://play.google.com/store/search?q=shot%20list&c=apps),
  [shot planner](https://play.google.com/store/search?q=shot%20planner&c=apps),
  [wedding shot list](https://play.google.com/store/search?q=wedding%20shot%20list&c=apps)
- Shot Lister: https://apps.apple.com/us/app/shot-lister/id529436218 ·
  Android history: https://apkcombo.com/shot-lister/com.reelapps.RAShotListerApp/
- Shot Designer: https://play.google.com/store/apps/details?id=air.us.hollywoodcamerawork.shotdesigner
- CineFlo: https://play.google.com/store/apps/details?id=com.cinelogapp.cinelog
- Studiovity: https://play.google.com/store/apps/details?id=com.studiovity.studiovity
- Taketino: https://play.google.com/store/apps/details?id=com.davidhavlin.taketino ·
  Shoot Planner: https://play.google.com/store/apps/details?id=com.origo.shootplanner

**Competitor docs**
- StudioBinder, no mobile app: https://support.studiobinder.com/en/articles/1065638-is-there-a-mobile-or-tablet-app-available
- Android requests for ShotList (iOS): https://solubleapps.com/shotlist/

**Industry and market**
- Story vs. shoot order pain point: https://storyflow.so/blog/best-shot-list-tools-2026
- AI in production, what's real: https://www.productionhub.com/blog/post/where-ai-is-actually-changing-production-workflows-and-where-it-isnt-yet
- Wedding photo tool (no video equivalent found): https://shotlace.com/

**Google Play guidelines**
- Screenshots and listing guidelines: https://support.google.com/googleplay/android-developer/answer/9866151
- Custom store listings: https://support.google.com/googleplay/android-developer/answer/9867158
- In-app review API: https://developer.android.com/guide/playcore/in-app-review
- Android vitals thresholds: https://developer.android.com/topic/performance/vitals
