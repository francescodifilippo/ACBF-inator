# Architecture — baseline (2026-11-15)

## Mission and scope

ACBF-inator is an open-source, desktop-first ACBF authoring and processing system, with a reusable engine for later server and reader integrations. Keep the project independent of one backend, platform or comic reader.

### Three separate workflows
1. **Consume**: parse and use existing standard ACBF without OCR, translation or network access.
2. **Generate**: opt-in page processing (balloon/panel segmentation, OCR, reading order), producing standard ACBF with source text.
3. **Translate**: optional operation on existing ACBF source text, creating or modifying a standard language layer without OCR.

## Stable design choices
- Preserve original images byte-for-byte by default. No inpainting or persistent mask requirement.
- ACBF is the interoperable persisted format for recognized text, multilingual translations, text-area polygons, frame polygons, and reading order; avoid inventing alternative schemas for these.
- ACBF may be embedded in CBZ, or stored alongside original CBZ/CBR/images. Validate all links and support missing-image diagnostics.
- Local chapter/page association need not require SQLite. A deterministic lookup scheme and optional integrity checks suffice initially; an index is a later optimization.
- OCR / translation are pluggable independent components. ACBF validation and manual review are mandatory quality gates for authored documents.
- Build a desktop batch CLI before GUI automation. If practical, retain Windows/Linux support.
- Keep source-language text intact and translate directly from it to avoid cumulative language drift.
- AI and services are optional. No model is required to open or reuse an ACBF.

## Intended future consumers
- ACBF-inator Server, optionally through adapters for Komga, Kavita, Jellyfin, Suwayomi, LANraragi and other library servers.
- A Mihon-derived reader capable of tappable translucent balloon markers, contextual translated text, TalkBack/TTS and frame/panel-guided navigation using **ACBF**, without permanent page rendering.
- Legacy readers may receive separately rendered derived images, but those are not durable core data and must not replace source artwork.

## Source project status
Mihon maintainers declined the proposed upstream generic Reader Plugin API on short-term roadmap grounds: https://github.com/mihonapp/mihon/issues/4295. This is not a blocker for a separate derived reader or source extension.

## Security and legal constraints
- Use rights-cleared pages for public examples, CI fixtures and releases.
- Loading untrusted archives/XML must be sandboxed/validated against path traversal, XML entity attacks, zip bombs and oversized images.
- The product scope consists of an open-source local desktop application, a self-hosted server under the user's control, and a future ACBF-native reader. **No public inference service, ChatGPT subscription pooling or resale is planned.**
- The server can ingest, produce, store and publish ACBF using offline/local components; ChatGPT login is never a prerequisite for ACBF consumption or server publication. SIWC is an optional, separately authorized desktop integration. Do not assume server-side SIWC eligibility until checked against the applicable documentation.
- Declare third-party licenses and avoid claiming a specific model is efficient until measured.

## Planned work
Issues and milestone proposal: https://github.com/francescodifilippo/ACBF-inator/issues/1
