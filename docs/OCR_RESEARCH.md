# OCR research and evaluation

**Goal:** choose OCR and text/panel detection for real comics based on reproducible quality, resource and latency measurements, not paper-document leaderboard scores.

| Candidate | Role | Strength / caution |
| --- | --- | --- |
| [MiniCPM-OCR 1.0](https://github.com/OpenBMB/MiniCPM-OCR) (1.3B) | Multimodal OCR / structured parsing | Lightweight relative to large vision LLMs; official primary focus Chinese/English documents; Japanese, Korean manga and small stylized text need independent tests |
| [MiniCPM-OCR Jev](https://github.com/OpenBMB/MiniCPM-OCR/blob/main/docs/minicpm_ocr_jev_en.md) (2B) | Score OCR correctness after recognition | **Not primary OCR**; official local deployment examples mention NVIDIA >=12GB VRAM. Quantized/CPU feasibility is unproven for target hardware |
| [Manga OCR](https://github.com/kha-white/manga-ocr) | Japanese manga recognition | Supports vertical/horizontal text, furigana and multi-line balloon crops; may hallucinate text on blank crops. Weights ~400MB |
| [PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR) | General multilingual detection/recognition | PP-OCRv6 has tiny/small/medium options with CPU capability; verify supported scripts/model versions, including Korean separately |
| [Surya](https://github.com/datalab-to/surya) | Detection, reading order, multilingual OCR | Broad script coverage; published benchmarks are primarily documents, so comic-specific validation required |
| [Comic-specific detector](https://github.com/jancando/manga_ocr) | Balloon/region localization candidate | Evaluate detector architecture, license and actual accuracy independently of OCR recognizer |

## Baseline suite
- Languages: JA (vertical, furigana), ZH, KO, EN, IT and at least one Latin-script translation.
- Targets: speech, thoughts, narration, text embedded in art, SFX, small rotated lettering, overlapping panels, double-page spreads.
- Geometry: polygon IoU and area detection precision/recall; frame recognition distinct from dialogue recognition.
- OCR: CER/WER, insertion/deletion, hallucination on empty crops, missing text, per-language and per-region accuracy.
- Reading order: pairwise order accuracy, panel and balloon sequences.
- Correctness gate: Jev AUROC/precision at review budgets and calibration vs no-Jev baselines.
- Performance: CPU-only latency per page and crop, peak RAM, storage, model cold-start, throughput, optional GPU VRAM and transfers.
- Reproducibility: frozen dataset versions, model IDs/hashes, preprocessing configuration and runtime versions.
- Security/license: every runtime, detector, OCR model and weights license independently reviewed.

## Initial hypothesis (not a final choice)
Use dedicated region/panel detection with **Manga OCR for Japanese**, and test **PaddleOCR / Surya for multilingual** against MiniCPM-OCR 1.0. Treat Jev as an optional, cost-justified review gate, not a mandatory installed model.

Issue: https://github.com/francescodifilippo/ACBF-inator/issues/6
Issue: https://github.com/francescodifilippo/ACBF-inator/issues/7
