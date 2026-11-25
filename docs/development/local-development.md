# Local development

Run the BFF at `https://localhost:7043`. Run Vite separately at `http://localhost:5173`; Vite proxies `/bff` and `/api` to the BFF. The BFF must have a valid local HTTPS development certificate (`dotnet dev-certs https --trust`). The Vite proxy is for development only; production is same-origin.
