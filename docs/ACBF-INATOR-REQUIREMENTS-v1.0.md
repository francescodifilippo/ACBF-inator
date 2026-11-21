# ACBF-inator
## Documento di requisiti software e mandato operativo per una sessione AI di sviluppo

**Versione:** 1.0  
**Data di riferimento:** 21 novembre 2026  
**Stato:** specifica iniziale per avvio sviluppo; decisioni architetturali vincolanti, scelte implementative da validare  
**Repository:** https://github.com/francescodifilippo/ACBF-inator  
**Destinatari:** agente AI di sviluppo, maintainer, revisori e collaboratori  
**Lingua:** italiano (codice, API e issue GitHub possono rimanere in inglese)

> **Mandato sintetico.** Sviluppare ACBF-inator come applicazione desktop open source, con un nucleo riutilizzabile per creare, leggere, verificare, correggere e tradurre documenti ACBF da fumetti digitali senza modificare le immagini originali. Le future componenti server self-hosted e reader Android derivato da Mihon devono poter riutilizzare lo stesso contratto dati. La prima priorità è un ACBF realmente conforme allo schema ufficiale, verificabile e riapribile, prima dell'integrazione di modelli AI complessi.

---

## 1. Fonte di verità, stato verificato e gerarchia dei requisiti

### 1.1 Fonti da consultare prima di modificare codice

- Repository operativo: https://github.com/francescodifilippo/ACBF-inator
- Roadmap principale: https://github.com/francescodifilippo/ACBF-inator/issues/1
- Documenti in `main`: `README.md`, `docs/ARCHITECTURE.md`, `docs/OCR_RESEARCH.md`, `docs/SIWC_INTEGRATION.md`, `docs/EXPERIMENT_PROMPTS.md`.
- Specifica ACBF, schema XSD ed esempi: https://github.com/ACBF-Advanced-Comic-Book-Format/ACBF
- Documento programmatico SIWC: https://developers.openai.com/siwc/token-sharing-open-source
- Termini SIWC correnti alla data: https://openai.com/policies/sign-in-with-chatgpt-terms/
- Requisiti di un fork Mihon: https://github.com/mihonapp/mihon/blob/main/CONTRIBUTING.md

**Stato verificato il 21/11/2026:** il branch `main` comprende documentazione e issue, ma non risulta ancora disponibile un'implementazione eseguibile del core. Le PR [#14](https://github.com/francescodifilippo/ACBF-inator/pull/14), relativa alla delimitazione desktop/self-hosted, e [#16](https://github.com/francescodifilippo/ACBF-inator/pull/16), relativa al bootstrap GitHub CLI, risultano ancora aperte e non integrate in `main`. Prima di intervenire, l'agente deve **ricontrollare** branch, PR, issue e file effettivi: il repository può evolvere.

### 1.2 Priorità e regole di interpretazione

- **P0 — obbligatorio per il primo incremento utile:** conformità ACBF, conservazione originali, import/export, validazione, test ripetibili, architettura modulare.
- **P1 — prodotto desktop utilizzabile:** rilevamento aree/vignette, OCR intercambiabile, revisione e correzione, batch e CLI.
- **P2 — integrazioni opzionali:** traduzione, Sign in with ChatGPT per installazione locale autorizzata, GUI desktop completa.
- **P3 — sviluppi successivi:** servizio ACBF-inator Server self-hosted, adattatori media server, reader Android derivato da Mihon.

Le fasi M0–M5 delle issue rappresentano una roadmap di **dipendenze e risultati**, non scadenze rigide. In caso di contrasto, prevalgono: (1) vincoli espliciti di questo documento, (2) standard ACBF e requisiti di sicurezza/licenza, (3) decisioni versionate più recenti e approvate nel repository, (4) ipotesi di ricerca. Evidenziare e risolvere i conflitti prima di implementare.

## 2. Visione e problema da risolvere

Molti fumetti digitali sono disponibili come sole immagini in archivi CBZ/CBR oppure tramite sorgenti online. OCR, traduzione e identificazione delle vignette spesso devono essere ripetuti, con consumo di risorse e perdita delle correzioni precedenti. Le immagini alterate permanentemente rendono difficile cambiare lingua, consultare il testo originale, eseguire TTS e applicare una navigazione guidata.

**Obiettivo di ACBF-inator:** produrre un livello strutturato, persistente e interoperabile in **ACBF (Advanced Comic Book Format)**, associato alle immagini originali. Il file descrive testo nella lingua originale, eventuali traduzioni, aree testuali, geometrie delle vignette e ordine di lettura. Un lettore compatibile potrà usare tali dati per mostrare una traduzione solo al tocco, leggere i dialoghi ad alta voce e navigare vignetta per vignetta, senza modificare la tavola originale.

### 2.1 Tre flussi indipendenti

1. **Consumo di ACBF esistente:** aprire un ACBF valido con immagini associate, navigare, verificarne i dati e consentire a lettori compatibili di usarli. Nessun OCR, modello, rete o traduzione necessari.
2. **Generazione di ACBF:** a richiesta dell'utente, analizzare pagine, individuare vignette/aree testuali, riconoscere testo originale e ordine di lettura, generare un ACBF standard e consentire correzioni.
3. **Traduzione opzionale:** aggiungere lingue a un ACBF già strutturato, conservando integralmente i testi originali. Ripetere l'OCR solo se richiesto per correggere un errore o per pagine cambiate.

I tre flussi devono poter essere testati e distribuiti separatamente.

## 3. Vincoli di prodotto e decisioni non negoziabili

**VIN-01 — Immagini originali intatte.** Nessuna modifica ai pixel o sovrascrittura di archivi originali nelle operazioni predefinite. Eventuali rendering tradotti destinati a lettori tradizionali sono prodotti derivati e opzionali; mai la sorgente canonica.

**VIN-02 — ACBF come formato persistente del contenuto.** Testi, traduzioni, aree e vignette devono essere espressi tramite elementi/attributi riconosciuti dallo schema ufficiale. È lecito avere cache, log, manifest tecnici o indici operativi, ma **non** inventare un secondo formato proprietario che sostituisca ACBF per questi dati.

**VIN-03 — Standard verificato.** Non assumere che XML sintatticamente valido sia ACBF valido: eseguire una reale validazione XSD, risoluzione riferimenti immagini, controlli semantici e verifica di apertura con almeno un viewer indipendente.

**VIN-04 — Modularità.** Parser/serializer, importatori archivi, localizzazione dei testi, riconoscimento OCR, valutazione qualità, traduzione, batch e interfacce non devono essere un monolite. Usare contratti espliciti versionati.

**VIN-05 — Elaborazione locale come base.** Il prodotto deve svolgere almeno consumo, validazione, export, correzione e OCR locale senza autenticazione ChatGPT. L'accesso a modelli remoti è facoltativo e attivato dall'utente.

**VIN-06 — Niente servizio AI pubblico.** Non è in programma un proxy pubblico, un servizio commerciale di inferenza, la vendita o condivisione di un abbonamento ChatGPT. Il futuro server è **software open source self-hosted, controllato dall'utente**; funziona anche senza servizi OpenAI.

**VIN-07 — Nessuna dipendenza da Mihon upstream.** La proposta Reader Plugin API all'upstream Mihon è stata chiusa: https://github.com/mihonapp/mihon/issues/4295. Il progetto deve funzionare indipendentemente; il fork reader è un'integrazione futura separata.

**VIN-08 — Comportamento verificabile e dichiarazioni oneste.** Mai dichiarare validazione XSD, test OCR o interoperabilità se non eseguiti. Tutti i risultati di benchmark devono riportare dataset, modello/versione, configurazione e hardware.

## 4. Attori e scenari d'uso

- **Utente desktop:** importa un archivio o cartella, avvia l'elaborazione, corregge testi/poligoni, esporta ACBF, rielabora in batch, confronta versioni linguistiche.
- **Revisore/tester:** valuta file ACBF e output OCR rispetto a immagini di riferimento, esamina errori XSD e indicatori di qualità.
- **Installazione server personale (futura):** collega raccolte locali o media server, conserva ACBF, prepara capitoli autorizzati, pubblica ACBF e immagini originali ai client dell'utente.
- **Lettore Android compatibile (futuro):** legge immagini e ACBF, attiva popup sul balloon, TTS e navigazione guidata delle vignette.
- **Sviluppatore/maintainer:** estende provider OCR e adattatori, aggiunge test, aggiorna dipendenze e documenta decisioni nel repository.

### 4.1 Flussi end-to-end richiesti

**SC-01 — Documento esistente:** apro un ACBF con 6 pagine e relativi JPEG; il programma verifica schema, riferimenti e geometrie e lo esporta senza ricorrere a OCR.

**SC-02 — Conversione originale:** importo un CBZ giapponese; il sistema preserva il file, ordina correttamente le tavole, riconosce balloon/pannelli, OCR originale e scrive un ACBF valido.

**SC-03 — Revisione:** correggo manualmente una stringa OCR o un poligono; il documento esportato riporta la correzione, senza rigenerare il resto del capitolo.

**SC-04 — Traduzione aggiuntiva:** da ACBF originale aggiungo IT ed EN; posso cambiare lingua offline dopo aver salvato l'ACBF, senza OCR o chiamate a servizi.

**SC-05 — Elaborazione batch:** importo una raccolta, interrompo e riprendo; il sistema riconosce ciò che è già valido e non duplica lavoro o danneggia originali.

**SC-06 — Reader compatibile (futuro):** tocco un balloon su una pagina ingrandita, compare un overlay contestuale, il TTS legge il testo nell'ordine giusto e il pannello successivo può essere inquadrato usando i frame ACBF.

## 5. Modello dati e interoperabilità ACBF (P0)

### 5.1 Oggetti concettuali

| Oggetto | Descrizione e vincoli |
|---|---|
| Collection/Chapter | Raggruppamento di pagine; provenienza e posizione originali conservate. |
| Page/ImageAsset | Immagine originale, dimensioni reali, ordine e riferimento risolvibile. |
| Frame/Panel | Poligono della vignetta in coordinate riferite all'immagine originale, ordine di navigazione. |
| TextArea | Poligono con testo e ruolo semantico (dialogo, didascalia, pensiero ecc., solo se codificabile nello standard). |
| TextLayer | Contenuto testuale per lingua e ordine di lettura nel modello ACBF effettivamente supportato dallo XSD. |
| ProcessingRecord | Dati tecnici esterni all'ACBF (strumento, modello, hash, tempi, confidenza, revisioni). Non modificano lo standard. |
| SourceReference | Riferimento stabile e verificabile al file immagine/archivio; evita affidarsi a URL temporanei. |

**Nota fondamentale:** il dominio interno non va serializzato ciecamente in XML. Il mapping da/verso ACBF deve rispettare le cardinalità, il nesting, i nomi degli elementi, le regole dei linguaggi e le caratteristiche della revisione XSD scelta. L'eventuale informazione non rappresentabile nello standard va esplicitata come *limite* o mantenuta in un manifest operativo separato, mai introdotta come elemento XML inventato.

### 5.2 Requisiti funzionali di formato

- **FMT-01 [P0]** Pin dello XSD ufficiale a commit/tag e creazione di fixture positive e negative.
- **FMT-02 [P0]** Parser XML sicuro; niente XXE, DTD esterni o fetching implicito di URL non autorizzati.
- **FMT-03 [P0]** Serializer standard con metadata richiesti, riferimenti validi, livelli lingua, aree testuali e frame.
- **FMT-04 [P0]** Round-trip semantico `import → modifica → export → import` per ogni costrutto dichiarato supportato; segnalare costrutti sconosciuti anziché perderli silenziosamente.
- **FMT-05 [P0]** Validatore a due stadi: XSD + semantica (path e risoluzione immagine, dimensioni, poligoni entro limiti, ordine, lingua, duplicazioni, riferimenti mancanti).
- **FMT-06 [P0]** Output sidecar `.acbf` e, dove consentito dallo standard, ACBF integrato in CBZ. Evitare di affermare compatibilità universale dei reader CBZ senza test.
- **FMT-07 [P0]** Riconoscere almeno 3 punti per poligono, coordinamento nello spazio pixel originale, geometrie non degeneri, orientamento/trasformazioni documentati.
- **FMT-08 [P1]** Testi originali sempre recuperabili; più lingue selezionabili senza ricampionare le immagini.
- **FMT-09 [P1]** Export atomico: scrivere su file temporaneo, validare, poi sostituire/creare la destinazione; possibilità di annullamento e backup configurabile.

### 5.3 Collegamento immagini e packaging

L'ACBF può riferirsi a file esterni o essere distribuito con immagini in un contenitore compatibile. Il progetto deve registrare e testare **quale modalità** usa per ciascun output. Il percorso di una pagina non deve diventare ambiguo per differenze di separatori, encoding, maiuscole/minuscole, nomi ripetuti o spostamento della raccolta. Gli originali devono rimanere recuperabili anche senza ACBF-inator.

## 6. Importazione e conservazione degli originali (P0/P1)

- **IMP-01 [P0]** Import di cartelle JPG/PNG/WebP e CBZ/ZIP, con ordinamento deterministico e preview.
- **IMP-02 [P1]** Import CBR/RAR tramite libreria/strumento esterno con licenza verificata e gestione chiara dei casi non supportati; mai promettere scrittura RAR senza verifica.
- **IMP-03 [P0]** Gestione cover, path annidati, doppie pagine, ordini RTL/LTR, nomi Unicode, numerazioni naturali, file nascosti e asset non immagine.
- **IMP-04 [P0]** Difesa da archivi malevoli: path traversal, symlink, decompression bomb, file enormi, payload XML e immagini corrotte.
- **IMP-05 [P0]** Integrità verificabile dei file originali: confronto SHA-256 per fixture, niente sovrascrittura implicitamente autorizzata.
- **IMP-06 [P1]** Individuare le pagine cambiate e aggiornare solo le elaborazioni dipendenti (invalidazione selettiva delle cache).
- **IMP-07 [P1]** Segnalazione esplicita di pagine/immagini mancanti e conversioni parziali; nessun successo silenzioso.

## 7. Comprensione della pagina: pannelli, balloon, ordine (P1)

La segmentazione geometrica è **un problema distinto dall'OCR**. Si devono riconoscere aree di testo e pannelli, stabilire relazioni tra dialoghi e vignette, inferire il verso di lettura e consentire correzioni. I risultati sono sempre espressi, quando possibile, in poligoni ACBF.

- **VIS-01** Rilevare vignette, balloon, pensieri, didascalie, testo fuori-balloon e onomatopee separatamente; usare classi solo quando riconducibili allo standard.
- **VIS-02** Supportare scrittura giapponese verticale, furigana, coreano/cinese, lingue occidentali, testi ruotati, pagine senza testo, doppie pagine e geometrie irregolari.
- **VIS-03** Calcolare un ordine di lettura modificabile manualmente: manga RTL, fumetti LTR, eventuali casi misti e interni al pannello.
- **VIS-04** Mantenere trasformazioni coerenti tra immagine ridotta di elaborazione e coordinate del file originale; definire test su crop, zoom e rotazione.
- **VIS-05** Evitare di creare testo o poligoni per regioni non leggibili: usare un elenco di incertezze e stato «da revisionare».
- **VIS-06** Interfaccia di correzione per aggiungere, unire, dividere, spostare ed eliminare poligoni; modificare contenuti e ordine senza ripetere OCR completo.

## 8. OCR modulare, ricerca e valutazione qualità (P1)

### 8.1 Contratto del riconoscitore

Ogni provider OCR deve dichiarare: nome/versione, modello e checksum, lingue supportate, direzione script, input crop e preprocessing, testo riconosciuto e informazioni di errore, risorse necessarie, disponibilità CPU/GPU, licenza di codice e pesi. Il componente ACBF non deve dipendere direttamente dalle librerie di un particolare OCR.

### 8.2 Candidati da confrontare, senza scelta anticipata

| Candidato | Ruolo da sperimentare | Rischio da misurare |
|---|---|---|
| MiniCPM-OCR 1.0 | OCR multimodale, riconoscimento e parsing documentale | Generalizzazione a fumetti, lettering, JA/KO e costo CPU |
| MiniCPM-OCR Jev | Valutatore esterno della correttezza OCR, **non** OCR principale | Calibrazione su fumetti e costo computazionale |
| Manga OCR | Riconoscimento giapponese su balloon | Allucinazioni su crop vuoti, lingue non giapponesi |
| PaddleOCR | Detection/recognition multilingua, alternative leggere | Accuratezza script piccoli, verticali e artistici |
| Surya | Detection, OCR multilingua e ordine di lettura | Benchmark documentali poco rappresentativi di manga |
| Detector specializzati comics | Riconoscimento aree di testo/pannelli | Licenze, robustezza su stili e editori diversi |

**Jev** deve essere inserito come *quality gate* opzionale e valutato contro revisione manuale/metriche più semplici. L'assenza di Jev non deve impedire il lavoro. Includere nuovi modelli soltanto dopo una valutazione ripetibile; non legarsi a versioni non verificate.

### 8.3 Benchmark richiesti

- Dataset con pagine **legalmente utilizzabili**, campioni annotati, balloon vuoti e casi difficili; includere JA verticale con furigana, KO, ZH, EN e IT.
- Metriche OCR: CER/WER e tassi di omissione, duplicazione e allucinazione; resoconti per lingua e tipo di area.
- Metriche di detection: precision/recall e IoU di aree testuali/pannelli, oltre all'accuratezza dell'ordine.
- Valutazione qualità Jev: capacità di identificare output sbagliati, soglie, falsi positivi e costi di revisione.
- Misure risorse: latency cold/warm, throughput pagina/balloon, picco RAM/VRAM, disco, CPU-only e GPU facoltativa.
- Output del benchmark: comandi riproducibili, ambiente, versioni, hash dei modelli, dataset e risultati strutturati.

## 9. Traduzione multilingua (P2)

- **TRA-01** Tradurre a partire dai testi originali già riconosciuti e corretti, mai obbligatoriamente da un'altra traduzione intermedia.
- **TRA-02** Aggiungere più livelli lingua ACBF coerenti per pagina, area, ordine e testi, secondo la semantica effettiva dello XSD.
- **TRA-03** Conservare il testo originale; reimport/export non devono cancellare traduzioni già presenti.
- **TRA-04** Consentire provider indipendenti (eventualmente locali oppure autorizzati da utente via SIWC), selezione lingua e glossario di contesto.
- **TRA-05** Permettere correzione manuale e ripresa dei job per area/capitolo, con controllo di allineamento delle traduzioni.
- **TRA-06** Offrire preview confrontabile originale/tradotto senza inpainting obbligatorio o rendering permanente delle immagini.
- **TRA-07** Trattare il testo dei fumetti come contenuto non fidato nei prompt verso modelli: evitare che istruzioni presenti nell'opera alterino task, processi o accessi.

## 10. Desktop: CLI, GUI, batch e operatività (P1/P2)

### 10.1 Priorità di sviluppo

Una **CLI deterministica e testabile** deve precedere la GUI; i comandi concreti e le opzioni saranno definiti in una piccola specifica CLI versionata. Esempi illustrativi (non interfaccia già implementata):

```bash
acbf-inator validate --acbf /path/chapter.acbf --images /path/pages
acbf-inator import --source /path/chapter.cbz --output /path/workspace
acbf-inator analyze --workspace /path/workspace --ocr-provider local
acbf-inator export --workspace /path/workspace --format acbf
```

### 10.2 Requisiti GUI

- **UI-01** Selezione raccolte, import in batch, preview immagini, lingua e verso di lettura.
- **UI-02** Gestione coda job, indicatori di avanzamento reali, pause/cancel/ripresa e log leggibili.
- **UI-03** Editor a coordinate: visualizzazione/trascinamento poligoni, associazione testo/vignetta e riordino.
- **UI-04** Differenziazione di stati «non processato», «automatico da verificare», «revisionato», «validato», «errore».
- **UI-05** Selezione motore OCR e opzioni di risorse con spiegazione dipendenze, lingue e requisiti.
- **UI-06** Selezione provider traduzione e abilitazione esplicita rete; nessuna trasmissione di pagine senza consenso.
- **UI-07** Export sidecar o pacchetto previsto, file naming sicuro e report XSD/qualità.
- **UI-08** Utilizzabilità con tastiera, lettori di schermo dove praticabile, contrasto e dimensioni UI accessibili.

### 10.3 Persistenza operativa

Si può iniziare senza database: manifest locale per checkpoint dei job, indici e provenance, con riferimenti deterministici al capitolo/sorgente. SQLite rimane un'eventuale ottimizzazione per ricerche e raccolte ampie, **non** un vincolo architetturale. Il file ACBF è il prodotto permanente indipendente da tali manifest.

## 11. Sign in with ChatGPT: integrazione facoltativa (P2)

**AUT-01** Integrare SIWC soltanto quando gli utenti, la modalità di esecuzione e i casi d'uso siano effettivamente ammissibili secondo la documentazione OpenAI aggiornata. L'app locale deve funzionare senza login.

**AUT-02** Utilizzare il flusso OAuth autorizzato con `ext_agent_host_id`, PKCE, state/nonce, convalida dei token e callback locale; preferire SDK ufficiale compatibile, senza raccogliere password/cookie o distribuire API key.

**AUT-03** Conservare le credenziali sotto controllo dell'utente, con protezione del sistema operativo, refresh/revoca/logout e nessun token in repository, log, crash report o manifest.

**AUT-04** Rispettare scope concessi, modelli effettivamente disponibili, limiti d'uso e requisiti delle API. L'accesso all'identità **non** implica accesso all'inferenza.

**AUT-05** Evitare chiamate automatiche non espressamente autorizzate e descrivere cosa viene inviato ai modelli remoti. Nessun uso degli abbonamenti di altri utenti e nessun accesso API generale come sottoprodotto del login.

**AUT-06** Il servizio self-hosted deve rimanere utilizzabile con soli modelli locali. Qualunque futuro uso di SIWC su runtime remoto individuale deve essere verificato contro i termini correnti prima di essere introdotto.

**Nota di conformità al 21/11/2026:** i termini SIWC efficaci dal 4 novembre 2026 richiedono, fra l'altro, richieste originanti dal runtime dell'utente (locale o remoto solo se controllato dallo stesso utente), consenso per automazioni, credenziali persistenti sotto controllo dell'utente e divieto di condivisione dell'utilizzo dei piani; la disponibilità per piani e modelli va verificata al momento dello sviluppo. Riferimento: https://openai.com/policies/sign-in-with-chatgpt-terms/.

## 12. ACBF-inator Server self-hosted e adattatori (P3)

**Obiettivo:** un servizio **installato e controllato dall'utente**, capace di eseguire la stessa pipeline del core, preparare capitoli, conservare ACBF standard e pubblicare immagini originali + livelli strutturati. Non è prevista una piattaforma pubblica di inferenza.

- **SRV-01** Runtime headless con API versionate, autenticazione per client autorizzati, audit essenziale, job queue e storage configurabile.
- **SRV-02** Pubblicazione del documento `.acbf` autentico insieme a immagini e riferimenti risolvibili; cache locali e invalidazione per contenuto/revisione.
- **SRV-03** Adattatori separati per Komga, Kavita, Jellyfin, Suwayomi-Server, LANraragi; valutare anche Calibre-Web, Ubooquity e Mango secondo API/estendibilità **effettivamente disponibili**.
- **SRV-04** Supportare l'elaborazione anticipata di capitoli che l'utente è autorizzato a ottenere, con scheduling configurabile, retry e resume.
- **SRV-05** Fornire a lettori ACBF-aware i documenti e le immagini originali, senza conversioni obbligatorie.
- **SRV-06** Per lettori non ACBF, offrire **facoltativamente** versioni lingua renderizzate come risorse virtuali con ID stabili e cache; non confonderle con i file canonici.
- **SRV-07** La gestione delle traduzioni e delle collezioni è locale al server dell'utente. Nessun sistema centralizzato di condivisione ACBF, sincronizzazione tra utenti o servizio pubblico è richiesto nella prima release.

**Contratti di interoperabilità da progettare, non presunti:** listing di collezioni/capitoli, localizzazione e download ACBF, accesso immagini con hash/ETag, lingue disponibili, aggiornamenti e autorizzazioni. Preferire API/OPDS già idonei dove supportati; non promettere plugin interni per server che forniscono soltanto API.

## 13. Reader Android ACBF-native derivato da Mihon (P3)

Il reader è un **prodotto separato** che riutilizza dati e contratti ACBF-inator; non è prerequisito per il desktop. Un fork Mihon minimale è preferito alla perdita di funzionalità interattive. Rispettare licenza e linee guida upstream (nome, icona, `applicationId`, aggiornamenti, analytics).

- **RDR-01** Aprire capitoli delle sorgenti Mihon tradizionali e associare ACBF locali o recuperati dal server self-hosted.
- **RDR-02** Posizionare indicatori semitrasparenti sui balloon e aprire testi/traduzioni al tocco, **senza alterare l'immagine**.
- **RDR-03** Mantenere l'allineamento dei poligoni durante zoom, pan, scaling, rotazione, pagine doppie e modalità webtoon, secondo le funzionalità del reader.
- **RDR-04** TTS per balloon, pagina o capitolo e ordine coerente con ACBF; controlli play/pausa/avanti/indietro e supporto TalkBack.
- **RDR-05** Navigazione guidata sui frame ACBF, con zoom e panoramica animati nel lettore (*esperienza simile a Smart Panels*, senza pretendere di riprodurre tecnologia proprietaria).
- **RDR-06** Selezione lingua senza ripetere OCR/traduzione; modalità completamente offline quando ACBF/immagini sono locali.
- **RDR-07** Motore ACBF e servizi separati dalle modifiche indispensabili ai componenti reader di Mihon, per ridurre conflitti nei merge upstream.

**Test PoC reader richiesto prima dello sviluppo completo:** pagina reale → ACBF validato → popup sul balloon con zoom/pan → TTS ordinato → navigazione tre frame. Niente OCR/AI richiesto per questo esperimento.

## 14. Requisiti non funzionali e di sicurezza

### 14.1 Portabilità e prestazioni

- **NFR-01** Desktop target iniziali: Windows 11 e Linux x86-64; valutare macOS successivamente in base allo stack scelto.
- **NFR-02** Il parser e la validazione devono funzionare su hardware ordinario, offline; OCR CPU-only disponibile almeno tramite un provider appropriato. GPU soltanto come acceleratore opzionale.
- **NFR-03** Eseguire benchmark anche su macchina indicativa con **16 GiB RAM**, senza dichiarare supporto universale prima dei test. Definire requisiti hardware minimi dopo i benchmark.
- **NFR-04** Elaborazione streaming/batch a memoria limitata; non caricare l'intera raccolta di immagini ad alta risoluzione in RAM quando non necessario.
- **NFR-05** Riproducibilità deterministica per import/serializzazione e fixture a parità di input e versione di librerie; output AI stocastici devono conservare provenance.

### 14.2 Sicurezza e privacy

- **SEC-01** Archivi non fidati: limite su numero/dimensione di file, espansione, recursion, path traversal/symlink e decompression bomb.
- **SEC-02** XML non fidato: XXE disattivato, limiti di profondità/dimensione, validazione file/referenze, niente esecuzione di contenuti.
- **SEC-03** Contenuti remoti non fidati: protezione da SSRF, fetch controllati, timeout, policy URL e autenticazione, niente risoluzione arbitraria dei path.
- **SEC-04** Nessuna telemetria invasiva di default; log privi di token e testo integrale dei fumetti, salvo richiesta esplicita dell'utente.
- **SEC-05** Licensing: scegliere licenza open source del progetto, verificare compatibilità di dipendenze, librerie di decompressione, modelli e pesi, oltre alla licenza della specifica/esempi ACBF.
- **SEC-06** Dataset e fixture pubbliche solo con diritti di utilizzo/ridistribuzione chiari; informare l'utente sul trattamento di opere private con provider remoti.
- **SEC-07** UI e output non devono confondere un risultato automatico con una revisione umana o un file effettivamente validato.

## 15. Matrice minima di test di accettazione

| ID | Scenario | Risultato verificabile | Issue |
|---|---|---|---|
| AT-01 | Import ACBF ufficiale | XML + XSD superati, immagini risolte | #2, #4 |
| AT-02 | XML errato e path non valido | Esito FAIL con posizione e causa; nessun crash | #2, #13 |
| AT-03 | Import 6 pagine da CBZ | Ordine e nomi corretti; SHA originali invariati | #3 |
| AT-04 | Export/reimport multilayer | Testi, lingue, ordine, geometrie preservati | #4 |
| AT-05 | Rilevamento pagina JA RTL | Poligoni e ordine confrontati con annotazione | #5 |
| AT-06 | OCR crop difficile e vuoto | Errori, omissioni e allucinazioni quantificate | #6 |
| AT-07 | Jev come revisore opzionale | Misura costo e capacità di segnalare errori; nessun blocco se disattivato | #7 |
| AT-08 | Modifica manuale poligono/testo | Aggiornamento locale e round-trip valido | #5, #10 |
| AT-09 | Aggiunta lingua IT | Nessun OCR ripetuto; originale intatto | #8 |
| AT-10 | Stop/resume batch | Nessun output parziale dichiarato valido; nessun dato sorgente perso | #10 |
| AT-11 | SIWC consenso negato/revocato | Logout e degradazione funzionale controllata; funzioni offline disponibili | #9 |
| AT-12 | ACBF pubblicato da server | Reader autorizzato recupera ACBF + immagini corrette | #11 |
| AT-13 | Reader overlay, TTS e frame | Touch/zoom/TTS/navigazione verificati su dispositivo | #12 |
| AT-14 | Sicurezza ZIP/XML | Test malevoli bloccati o gestiti senza esecuzione/traversal | #13 |
| AT-15 | Compatibilità indipendente | ACBF riaperto da almeno un viewer esterno e validato XSD | #2, #4 |

## 16. Piano d'incrementi, dipendenze e Definition of Done

### M0 — Specifica e test corpus (issue #2, #13; dipende da #1)

- Pin XSD ufficiale con versione/commit, verificare licenze; raccogliere fixture con diritti chiari.
- Stabilire test suite `validate`, threat model di base, convenzioni del repository, CI minima.
- **Uscita:** validatore eseguibile su fixture ACBF valide e volutamente invalide; report dei risultati, nessun test falso/di sola intenzione.

### M1 — Core ACBF e import (issue #3, #4)

- Reader/serializer, immagine associata, CBZ e cartelle, CBR quando la dipendenza è verificata.
- Round-trip semantico su casi realistici multilingua, geometrie e ordine.
- **Uscita:** `import`, `validate` e `export` usabili via CLI, test XSD e test viewer esterno, originali immutati.

### M2 — Vision e OCR (issue #5, #6, #7)

- Segmentazione vignette/aree, OCR intercambiabile, correzione base, benchmark candidati, Jev opzionale.
- **Uscita:** un capitolo di test con ACBF generato, metriche di qualità e revisione controllabile; modello predefinito scelto su evidenze.

### M3 — Lingue e provider ChatGPT (issue #8, #9)

- Traduzione da ACBF e revisioni; integrazione opzionale SIWC locale se ammissibile, con test di consenso/revoca.
- **Uscita:** salvataggio di due livelli linguistici coerenti, senza re-OCR, fruizione offline dell'output.

### M4 — Desktop beta (issue #10)

- GUI accessibile, batch/resume, preview e correzioni, packaging Windows/Linux.
- **Uscita:** installer/documentazione, percorso completo eseguito da utente non sviluppatore su raccolta autorizzata.

### M5 — Ecosistema (issue #11, #12)

- Server personale ACBF + primo adattatore realmente fattibile; PoC reader su fork Mihon.
- **Uscita:** server pubblica ACBF autentici e originali a reader compatibile; touch balloon, TTS e navigazione frame dimostrati in reader separato.

**Definition of Done per incremento:** requisiti e issue collegate; codice leggibile/modulare; test automatici riproducibili; prova di validazione quando pertinente; documentazione e decision log aggiornati; sicurezza/licenze valutate; benchmark con dati reali se si fanno claim prestazionali; PR con diff e test evidenti; nessun merge automatico senza review.

## 17. Architettura software proposta (da verificare con uno spike)

Struttura logica, **non** prescrizione di linguaggi o framework:

```text
acbf-inator/
  core/                # modello dominio, ACBF XML parser/serializer, validation
  importers/           # directory, CBZ, CBR (plugin/tool esterno)
  vision/              # frame + balloon/text-area detection, reading order
  ocr/                 # interfacce provider, benchmark, Jev quality gate
  translation/         # language layers, glossari, provider opzionali
  jobs/                # batch, cache, provenance, resume
  cli/                 # import, validate, analyze, export
  desktop/             # GUI indipendente dal core
  server/              # futuro servizio self-hosted (P3)
  adapters/            # futuri media server
  reader-bridge/       # futuro contratto reader e integrazione Mihon
  tests/               # fixture, golden tests, security tests, benchmarks
  docs/                # ADR, requisiti, benchmark, UX e release
```

**Scelta tecnologica da motivare con spike:** privilegiare interoperabilità, packaging Windows/Linux, sicurezza di parsing XML/archivi, facile integrazione di modelli OCR Python/C++/Rust e mantenibilità. L'agente può proporre Python, Rust o una soluzione ibrida, ma **deve prima dimostrare** che import/validate/export e pipeline di test restino indipendenti da GUI, OCR e server. Non fissare uno stack solo per preferenza personale; creare ADR con alternative e motivazione.

### 17.1 Contratti minimi tra moduli

- `import_source(source) → ordered_pages + references + diagnostics`;
- `parse_acbf(document) → domain_model + parse_diagnostics`;
- `validate_acbf(document, source_assets) → xsd_status + semantic_status + detailed_errors`;
- `detect_regions(page, reading_direction) → frames + text_areas + uncertainty`;
- `recognize(crops, language_hint, provider) → source_text + provenance + diagnostics`;
- `translate(layer, target_language, provider) → translated_layer + unresolved_items`;
- `serialize_acbf(domain_model, target) → artifact + validation_report`.

Le firme sono illustrative; definire tipi concreti, error model, versionamento e cancellazione durante la prima PR tecnica.

## 18. Decisioni aperte e limiti dichiarati

1. **Licenza di progetto:** scegliere e registrare la licenza; non confondere la licenza della specifica ACBF, di Mihon e dei pesi OCR.
2. **Revisione XSD da fissare:** usare repository ufficiale e fixture; verificare coordinate, varianti di text-layer e metadati obbligatori sulla versione scelta.
3. **Stack desktop:** CLI/GUI e toolchain finali scelti dopo prova di interoperabilità e packaging.
4. **CBR:** definire tool di estrazione, sistema operativo e licenza.
5. **Algoritmi di detection:** scegliere da benchmark, senza presupporre che un OCR documentale riconosca automaticamente le vignette.
6. **Supporto lingue:** distinguere lingue testate da nominalmente supportate, specialmente JA verticale, KO e ZH.
7. **Persistenza operativa:** manifest iniziale, valutare indice/database solo quando necessario.
8. **Formati multipagina/ACBF in CBZ:** confermare dettagli ed esempi e testarli con viewer esterno.
9. **Server media adapters:** non dichiarare plugin server-side supportati senza verificare API/documentazione per ciascuna versione.
10. **Fork reader:** mantenere divergenza minima, definire sincronizzazione upstream e limiti del touch/zoom su modalità di lettura diverse.
11. **Comunicazione AI remota:** privacy delle pagine, limiti di dimensione/token, affidabilità, consenso, eventuali controlli di copyright.
12. **Condivisione futura degli ACBF tra utenti:** idea non pianificata; fuori scope fino a decisione esplicita su diritti, versionamento e sicurezza.

## 19. Modalità di lavoro con GitHub e reporting

- Prima azione: leggere issue, PR aperte, branch, README/docs e stato della CI. Non assumere che codice o PR precedenti siano già integrate.
- Registrare le nuove decisioni architetturali in `docs/adr/ADR-xxxx-*.md`, con contesto, opzioni, decisione, conseguenze e date.
- Associare ogni incremento a una issue esistente, oppure aprirne una se manca, indicando priorità, dipendenze, test e Definition of Done.
- Usare milestone M0–M5 e Project GitHub **se realmente presenti**; non inventarne l'esistenza. Issue meta: https://github.com/francescodifilippo/ACBF-inator/issues/15.
- Aprire PR piccole, con note di test, output della validazione e documentazione necessaria. Non aprire PR vuote e non effettuare merge non richiesti.
- Ogni intervento conclude con: branch/commit/PR, file cambiati, requisiti soddisfatti, test realmente eseguiti, fallimenti e prossima attività consigliata.
- Preservare la separazione del progetto desktop dalla futura componente server e dal fork Mihon; non importare repository terzi nel core senza review licenze.

## 20. Primo incarico operativo raccomandato alla nuova sessione

L'AI di sviluppo **non deve cercare di costruire immediatamente tutte le funzionalità**. Deve partire da **M0 + prima parte di M1**, con un vertical slice verificabile:

1. Ispezionare realmente il repo, le PR #14/#16 e le issue esistenti; dichiarare cosa è presente su `main`.
2. Fissare la revisione dello schema ACBF ufficiale e prendere 2–3 esempi distribuibili legalmente come fixture (o creare esempi originali minimi).
3. Proporre un ADR sullo stack e sull'organizzazione modulare, con rischi e ragioni.
4. Implementare un parser/validator minimo e un serializer di ACBF standard senza dipendenze OCR.
5. Implementare import di directory/CBZ e collegamento pagine-originali, con SHA di verifica.
6. Scrivere test per validità XSD, invalidità intenzionale, riferimenti immagini, path traversal, round-trip.
7. Dimostrare con una CLI e un ACBF di prova che funziona import → validate → export → reopen.
8. Aprire una PR piccola, allegando log/test e annotando cosa manca; **non** iniziare OCR o SIWC finché questo gate non passa.

**Risultato concreto atteso dal primo incarico:** una PR reviewable con CLI minima, fixture ACBF, test riproducibili e relazione di validazione, non un semplice diagramma o un rapporto di intenti.

---

## 21. Prompt di avvio da incollare nella nuova sessione AI

> **Ruolo:** agisci come lead developer e revisore indipendente di ACBF-inator. Il repository è `https://github.com/francescodifilippo/ACBF-inator`. Questo documento di requisiti è il tuo contratto iniziale. Usa il repository reale come fonte di verità per lo stato effettivo, controlla issue e PR aperte e non dichiarare implementato ciò che è solo pianificato.
>
> **Obiettivo immediato:** realizza un primo incremento M0/M1 piccolo e verificabile: schema ACBF ufficiale fissato a revisione nota, fixture lecite, import CBZ/cartella, parser/serializer, validazione XSD + semantica, round-trip e CLI di prova. Preserva ogni immagine originale e mantieni il core indipendente da OCR/AI, GUI, server e fork Mihon. Registra decisioni tecniche in ADR. Crea test che dimostrino le proprietà, documenta comandi di esecuzione e apri una PR collegata alle issue appropriate.
>
> **Regole:** niente nuovi formati proprietari per testo/geometrie/traduzioni; nessuna modifica alle immagini sorgenti; nessuna dipendenza obbligatoria da ChatGPT; nessun claim non verificato; niente inserimenti di token o contenuti protetti nel repo. Se una decisione tecnica è aperta, verifica con uno spike e documenta opzioni, conseguenze e scelta. Usa GitHub Issues, Milestones, Projects e PR quando disponibili, senza generare rumore amministrativo. Al termine indica esattamente commit/PR, test eseguiti, evidenze, limiti residui e prossimo passo.

## 22. Riferimenti esterni

1. **Standard ACBF:** https://github.com/ACBF-Advanced-Comic-Book-Format/ACBF
2. **ACBF Viewer:** https://github.com/ACBF-Advanced-Comic-Book-Format/ACBF-Viewer
3. **MiniCPM-OCR:** https://github.com/OpenBMB/MiniCPM-OCR
4. **MiniCPM-OCR Jev:** https://github.com/OpenBMB/MiniCPM-OCR/blob/main/docs/minicpm_ocr_jev_en.md
5. **Manga OCR:** https://github.com/kha-white/manga-ocr
6. **PaddleOCR:** https://github.com/PaddlePaddle/PaddleOCR
7. **Surya:** https://github.com/datalab-to/surya
8. **SIWC overview:** https://developers.openai.com/siwc/token-sharing-open-source
9. **SIWC integrazione OSS (OpenAI Cookbook):** https://developers.openai.com/cookbook/articles/sign-in-with-chatgpt
10. **SIWC Terms, efficaci dal 4/11/2026:** https://openai.com/policies/sign-in-with-chatgpt-terms/
11. **Mihon CONTRIBUTING (fork):** https://github.com/mihonapp/mihon/blob/main/CONTRIBUTING.md
12. **Mihon upstream issue Reader Plugin API:** https://github.com/mihonapp/mihon/issues/4295
13. **ACBF-inator issues:** https://github.com/francescodifilippo/ACBF-inator/issues

---

**Fine specifica v1.0.** Ogni modifica ai vincoli o al perimetro richiede un aggiornamento versionato, con motivazione e impatto sui test.
