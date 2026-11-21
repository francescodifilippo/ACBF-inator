# Sign in with ChatGPT (SIWC) — local OSS integration

Status: researched; no application registration or token issuance has been performed.

## Official documentation
- [Open-source overview](https://developers.openai.com/siwc/token-sharing-open-source)
- [Registration and sign-in](https://developers.openai.com/siwc/token-sharing-open-source/sign-in)
- [Models and inference](https://developers.openai.com/siwc/token-sharing-open-source/models-and-inference)
- [Preview limitations](https://developers.openai.com/siwc/token-sharing-open-source/preview-limitations)
- [Sign in with ChatGPT Terms](https://openai.com/policies/sign-in-with-chatgpt-terms/)

## Product requirement: connect the user's ChatGPT subscription

**ACBF-inator Desktop must offer an optional `Continue with ChatGPT` provider**, enabling eligible users to authorize their **own ChatGPT plan** for eligible multimodal OCR/review/translation requests in the application, without entering a traditional API key. Sign-in for identity **alone** does not authorize AI inference: the app must request and verify `chatgpt.tokens.use.direct` and associated scopes, select an available model for that specific account and honor usage limits. The flow never grants access to the user's ChatGPT conversations.

- Main specification: [requirements v1.1, section 11](ACBF-INATOR-REQUIREMENTS-v1.1.md).
- An OpenAI Responses request must use the OAuth Bearer token at `https://api.openai.com/v1/responses`, `store:false`, `stream:true`, with account-visible models discovered at `GET https://api.openai.com/v1/models`.
- The OSS dynamic registration uses `https://auth.openai.com/api/accounts/authorize` and `https://auth.openai.com/api/accounts/oauth/token`, PKCE/nonce/state and a localhost loopback callback.
- Translation from structured source text, OCR review and supported image analysis are optional tasks. Never send source content remotely without a clear user choice; persist results as standard ACBF, not model-specific artifacts.
- Desktop, a future Android reader and a self-hosted server are **distinct hosts**. Do not copy desktop tokens to the server/Android, and do not expose credentials through reader plugin APIs. Android SIWC support needs an explicit compatibility/terms verification before activation.
- No public multi-user inference service, resale or account-pooling is planned; the self-hosted ACBF server remains operational without OpenAI.

## Important distinction
Open-source local clients can use the **dynamic registration** OAuth flow; a static developer API key or advance partner registration is not required for that path. User authorization occurs from within the running app. The issued `client_id` belongs to the user/workspace registration and must be persisted for reauth. Eligibility, scope, model availability and usage caps are account-dependent.

The project includes a user-controlled self-hosted ACBF server, **not** a public inference platform. If an individual later wants to use SIWC from their own remote runtime, confirm its exact host, consent and storage requirements against the current official terms. Such support is not a prerequisite for Desktop SIWC.

## Local application flow
1. App generates and stores a stable opaque `ext_agent_host_id` per installation (prefer JWK thumbprint URI; UUID-based `urn:uuid:...` also supported).
2. User selects **Continue with ChatGPT**. Open system browser for OAuth Authorization Code + PKCE, with state and nonce, a local `127.0.0.1` callback, identity scopes `openid profile email`, and optional plan scopes `offline_access resource.invoke chatgpt.tokens.use.direct`.
3. First sign-in uses `client_id=dynamic_agent_client` and `agent_name_hint=ACBF-inator`; server returns an issued client ID (often `oaiapp_...`), which the app stores for subsequent sign-ins.
4. Exchange code using PKCE; validate state, ID token claims and granted scopes; store tokens securely **on the user's own computer** and support refresh/revocation/logout.
5. Use user-authorized access token against `GET /v1/models` for visible model choices, and `POST /v1/responses` with `store:false`, `stream:true`, respecting preview limitations. Supported image input depends on selected model.
6. Present model/usage controls and explain plan eligibility/limits to user; handle exhausted quota or denied permission gracefully.

## Guardrails
- No ChatGPT password/cookie collection; no token in Git, logs, remote hosting or analytics.
- No credential pooling, re-selling, use of someone else's account, or unrestricted API proxy.
- Background work needs explicit user consent. A user-controlled remote VM may have a supported path, but multi-user server workloads require separate design, consent and terms review.
- Optional standard API-key usage is a **separate** integration and billing model, not equivalent to subscription/plan usage.

## Acceptance test
Local app can complete dynamic sign-in and user consent, discover models, send an eligible test request and stream it to completion. Document decline, logout, expired token and model availability cases.

Track implementation: https://github.com/francescodifilippo/ACBF-inator/issues/9
