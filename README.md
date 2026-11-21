# ACBF-inator

Open-source tooling to enrich digital comics with **standard ACBF** (Advanced Comic Book Format): reusable original text, optional multilingual translations, text-area geometry, panel/frame order and accessibility-ready reading metadata — **without changing original artwork**.

> Status: planning and first proofs of concept. APIs, supported formats and model choices are subject to tests; no production build yet.

## Why

Comic readers repeatedly perform OCR and translation against the same pages. ACBF-inator aims to process once, preserve structured information as an interoperable ACBF document, and reuse it across sessions, languages and readers.

## Independent workflows

1. **Consume ACBF**: load and validate an existing document; use text and order for contextual display, TTS or guided panel navigation in compatible readers.
2. **Generate ACBF**: user-triggered detection of frames, balloons, text recognition and reading order from original images; preserve source-language text.
3. **Translate on demand**: add or update target-language text layers from the recognized original, without rerunning OCR.

OCR or translation are **not required** merely to open existing ACBF.

## Initial desktop scope

- Batch import of CBZ, CBR and image folders; avoid modifying originals by default.
- Standards-compliant ACBF read/write, external image references and CBZ embedding.
- Text and frame geometry with stable image association and validation.
- Pluggable on-device OCR and quality review; manual correction.
- Optional OpenAI **Sign in with ChatGPT (SIWC)** for eligible users of locally run OSS; subject to explicit authorization and plan limits.
- Offline operation for existing ACBF and local-only OCR workflows.
- Reproducible test corpus, tests and documented resource benchmarks.

## OCR investigation

Benchmark on actual comic pages (including vertical Japanese, furigana, Chinese, Korean, Latin scripts, sound effects and rotated text), rather than assuming document OCR scores transfer to comics:

- [MiniCPM-OCR 1.0](https://github.com/OpenBMB/MiniCPM-OCR), and [MiniCPM-OCR Jev](https://github.com/OpenBMB/MiniCPM-OCR/blob/main/docs/minicpm_ocr_jev_en.md) **for confidence/quality scoring, not for primary OCR**.
- [Manga OCR](https://github.com/kha-white/manga-ocr) (specialized for Japanese manga).
- [PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR) (multilingual/lightweight variants).
- [Surya](https://github.com/datalab-to/surya) (text detection, reading order, multilingual benchmark).
- Separate comic balloon/frame detectors as needed.

A model's size does not guarantee CPU latency; each choice needs measured peak RAM/VRAM, throughput, quality, compatibility and licensing.

## Long-term architecture

The ACBF core must not depend on one reader, OS or content server.

- **Desktop**: batch authoring, processing and editing.
- **Server**: processing queue, preparing chapters, publishing original images + ACBF, adapters for Komga, Kavita, Jellyfin, Suwayomi, LANraragi, etc.
- **Reader**: potential Mihon-derived ACBF-native reader for tappable balloon translations, TalkBack/TTS and guided panel navigation, reusing the same data.

Standard ACBF remains the durable interchange format. Rendered translations may be served to legacy clients as an optional derived view; source images remain intact.

## Project documents

- [Software requirements v1.0 (Italiano)](docs/ACBF-INATOR-REQUIREMENTS-v1.0.md)

- [Architecture and decisions](docs/ARCHITECTURE.md)
- [OCR alternatives and evaluation](docs/OCR_RESEARCH.md)
- [Sign in with ChatGPT integration](docs/SIWC_INTEGRATION.md)
- [Two ChatGPT test prompts](docs/EXPERIMENT_PROMPTS.md)

## Project management

Start with [the project charter and roadmap](https://github.com/francescodifilippo/ACBF-inator/issues/1) and the related GitHub issues. Decisions, metrics, accepted constraints and integration contracts should be committed to docs along with the code. Project boards and milestones may be added when available.

## OpenAI authentication

Sign in with ChatGPT for open-source local apps uses a dynamic OAuth registration and user consent; no general-purpose API key should be embedded in the app. Follow the [official OSS sign-in guide](https://developers.openai.com/siwc/token-sharing-open-source) and [terms](https://openai.com/policies/sign-in-with-chatgpt-terms/). ChatGPT plan usage is not unlimited or shareable between users. Hosted/multi-user plans require separate legal/product evaluation.

## License and contribution

Project licensing to be selected before source implementation. Third-party model weights and dependencies must be reviewed individually. Use only test images for which distribution and processing rights are clear.

Specification: https://github.com/ACBF-Advanced-Comic-Book-Format/ACBF
