# SitePad — iOS App

A native SwiftUI conversion of the SitePad field-job-report mockup. Job in,
signed PDF out, before you leave the driveway — now as a real iOS app instead
of a React mockup.

## Requirements

- Xcode 15 or later
- iOS 16.0+ deployment target (simulator or device)

## Opening the project

Open `SitePad.xcodeproj` in Xcode and run the `SitePad` scheme on any iOS
16+ simulator or device. No external dependencies (no CocoaPods/SPM
packages) — everything uses first-party frameworks: SwiftUI, PhotosUI,
PDFKit-adjacent `UIGraphicsPDFRenderer`, and `UIActivityViewController`.

## What's implemented

- **Job list** — jobs grouped into "On site now" / "Next up" / "Report sent",
  matching the original mockup's layout and status colors.
- **New job** — start a job, which records a real clock-in time.
- **Job detail**:
  - Work notes (free text, required)
  - Photos — added via the native Photos picker (multi-select), with
    per-photo captions and removal
  - Safety checklist (5 fixed items, required)
  - Parts & materials with running total
  - Customer signature — captured with a real finger-drawn signature pad
    (SwiftUI `Canvas` + drag gesture), rendered to a PNG
- **Report preview** — mirrors the original design, live-built from the job
  data (photos grid, checklist ticks, parts total, signature image).
- **Real PDF generation** — `Email PDF to customer` builds an actual PDF of
  the report (via `UIGraphicsPDFRenderer`) and hands it to the system share
  sheet, so you can genuinely email, message, AirDrop, or save it. The job
  is marked "sent" once the share sheet reports a completed share.

## Notes / limitations

- There's no backend — jobs live in memory for the session (matches the
  original mockup's behavior, which also had no persistence).
- The PDF's photo grid does not paginate for a very large number of photos
  on a single job; a typical handful of site photos fits fine on one page.
- No app icon artwork is included — the asset catalog has a placeholder
  `AppIcon` slot ready for one.
