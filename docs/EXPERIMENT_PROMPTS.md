# Experiment — ChatGPT web ACBF creation + independent review

Use **rights-cleared pages** and, if possible, files with unchanged filenames and known pixel dimensions. Attach the same pages in both chats and include the generated `.acbf` in the review chat. No output from a language model should be assumed XSD-valid until checked with a validator.

## Prompt A — Generate an ACBF from attached comic pages

> I am testing an open-source ACBF authoring workflow. The images attached to this message are comic pages, in the order they should be read. Use the **official Advanced Comic Book Format (ACBF) schema and examples** at https://github.com/ACBF-Advanced-Comic-Book-Format/ACBF. 
>
> Your job is to create **one standards-compliant ACBF XML document** for these pages. Preserve original images without editing them. Make a sidecar `comic.acbf` that references the input image files by their exact names (if the filenames are not available, state the deterministic placeholder naming scheme you used).
>
> For each page: identify text-bearing speech/thought balloons, narration and captions; transcribe **original-language text verbatim** including writing direction where relevant; identify frame/panel polygons and reading order. Use image pixel coordinates, polygons rather than crude generic boxes where visually justified, and ACBF's native `page`, `text-layer`, `text-area`, `frame` and related elements. Include only metadata that can be established from the attachments, and use the correct standard XML namespace/structure. If I do not specify a target language, do **not** translate. If I specify one, add an optional separate language layer while retaining the original, translating from the original and keeping dialogue alignment.
>
> Do **not** invent off-image dialogue, characters, title, author, missing text, coordinates or confidence attributes not supported by the ACBF schema. Keep SFX distinct from ordinary dialogue when the standard supports that semantic distinction. If small text is unreadable, identify the region in a separate uncertainty report rather than inventing it.
>
> Deliver (1) a downloadable `comic.acbf` if file creation is available, otherwise the complete XML in one code block; (2) a short table of per-page detected balloon/frame counts and all uncertainties; (3) schema/validation status, clearly stating whether an actual XSD validation was run. Do not claim schema validity unless you performed the check.

## Prompt B — Independently audit generated ACBF

> You are an independent reviewer. I attach the **same original comic pages** and an `.acbf` file generated in another chat. Independently inspect them, without assuming the original generation was correct. Compare against the official ACBF XSD/examples at https://github.com/ACBF-Advanced-Comic-Book-Format/ACBF.
>
> Audit in two stages. **Structural:** XML well-formedness, namespace, mandatory metadata, element/attribute types and ordering, page/image references, language tags, text-layer/text-area/frame structure, coordinates within image dimensions, polygon validity, and whether sidecar references actually resolve. Run actual XSD validation if tools and schema are available; otherwise state explicitly that this remains unverified.
>
> **Visual/semantic:** compare every page, text-area and frame against the attachments; identify missed/duplicated/imaginary balloons, wrong original-language transcriptions, SFX merged into dialogue, inaccurate polygons, incorrect panel or balloon order (especially right-to-left/vertical), missing furigana, and wrong language-layer correspondence. If translations exist, assess fidelity against the **original text**, not an English intermediary.
>
> Return (1) a severity-ranked table with page number, element/region, expected vs actual and suggested fix; (2) counts of correct/incorrect/missing text regions and frames; (3) a corrected standards-compliant full `.acbf` if feasible, or exact minimal fixes; (4) remaining uncertainties; (5) a clear **PASS / FAIL / INCONCLUSIVE** verdict separately for XML/XSD correctness, geometry/reading order, OCR transcription and translation. Never claim testing that was not performed.
