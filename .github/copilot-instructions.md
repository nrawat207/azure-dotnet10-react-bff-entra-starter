# Copilot instructions
- Preserve the BFF boundary: no OAuth tokens in browser storage or JavaScript.
- All mutating cookie-authenticated endpoints require antiforgery validation.
- Keep backend features modular; add tests for auth, authorization, proxy routing and error handling.
- Use managed identity and Key Vault references in Azure; never commit secrets.
- React uses same-origin `/bff` and `/api` endpoints with `credentials: 'same-origin'`.
- Keep Bicep modules independently deployable and parameterized.
