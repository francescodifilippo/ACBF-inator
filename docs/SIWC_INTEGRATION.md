# Sign in with ChatGPT (SIWC) — local OSS integration

Status: researched; no application registration or token issuance has been performed.

## Official documentation
- [Open-source overview](https://developers.openai.com/siwc/token-sharing-open-source)
- [Registration and sign-in](https://developers.openai.com/siwc/token-sharing-open-source/sign-in)
- [Models and inference](https://developers.openai.com/siwc/token-sharing-open-source/models-and-inference)
- [Preview limitations](https://developers.openai.com/siwc/token-sharing-open-source/preview-limitations)
- [Sign in with ChatGPT Terms](https://openai.com/policies/sign-in-with-chatgpt-terms/)

## Important distinction
Open-source local clients can use the **dynamic registration** OAuth flow; a static developer API key or advance partner registration is not required for that path. User authorization occurs from within the running app. The issued `client_id` belongs to the user/workspace registration and must be persisted for reauth. Eligibility, scope, model availability and usage caps are account-dependent.

**Project scope:** ACBF-inator is a locally run open-source desktop app plus an optional **self-hosted, user-controlled** ACBF processing/publishing server. No public inference service, multi-user sharing of ChatGPT subscriptions, or resale is planned. SIWC is being evaluated for the desktop app; ACBF-inator Server can work entirely without OpenAI. If an individual user later wants SIWC from their own server runtime, verify separately that the exact deployment mode and authorization comply with the then-current program terms before implementing it.

## Local application flow
1. App generates and stores a stable opaque `ext_agent_host_id` per installation (prefer JWK thumbprint URI; UUID-based `urn:uuid:...` also supported).
2. User selects **Continue with ChatGPT**. Open system browser for OAuth Authorization Code + PKCE, with state and nonce, a local `127.0.0.1` callback, identity scopes `openid profile email`, and optional plan scopes `offline_access resource.invoke chatgpt.tokens.use.direct`.
3. First sign-in uses `client_id=dynamic_agent_client` and `agent_name_hint=ACBF-inator`; server returns an issued client ID (often `oaiapp_...`), which the app stores for subsequent sign-ins.
4. Exchange code using PKCE; validate state, ID token claims and granted scopes; store tokens securely **on the user's own computer** and support refresh/revocation/logout.
5. Use user-authorized access token against `GET /v1/models` for visible model choices, and `POST /v1/responses` with `store:false`, `stream:true`, respecting preview limitations. Supported image input depends on selected model.
6. Present model/usage controls and explain plan eligibility/limits to user; handle exhausted quota or denied permission gracefully.

## Guardrails
- No ChatGPT password/cookie collection; no token in Git, logs, remote hosting or analytics.
- Desktop sign-in is **optional** and tied to the individual user. No shared credentials or secondary service is part of this design.
- Background work needs explicit user consent and compliance with applicable SIWC limits.
- The separate self-hosted ACBF server remains usable without SIWC or a paid OpenAI API; any server-side sign-in proposal must first be assessed against current rules.

## Acceptance test
Local app can complete dynamic sign-in and user consent, discover models, send an eligible test request and stream it to completion. Document decline, logout, expired token and model availability cases.

Track implementation: https://github.com/francescodifilippo/ACBF-inator/issues/9
