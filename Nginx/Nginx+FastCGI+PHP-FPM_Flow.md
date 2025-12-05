```bash
                 ┌──────────────────────────────┐
                 │          Browser              │
                 │   GET /index.php             │
                 └──────────────┬───────────────┘
                                │ HTTP
                                ▼
                    ┌─────────────────────┐
                    │       NGINX         │
                    │  (Front-end server) │
                    └──────┬──────────────┘
          Checks:  Is this a .php file?
                                │
                                │ Yes → Forward via FastCGI
                                ▼
                    ┌─────────────────────┐
                    │     FastCGI         │
                    │ (Communication       │
                    │   protocol only)     │
                    └──────┬──────────────┘
                                │
                                │ Sends SCRIPT_FILENAME,
                                │ params, env vars, body...
                                ▼
          ┌──────────────────────────────────────────┐
          │                  PHP-FPM                  │
          │  (Pool Manager + PHP Workers running PHP) │
          └──────┬────────────────────────────────────┘
                 │
       ┌─────────┴──────────────────────────────────────┐
       │ A PHP-FPM worker:                               │
       │  - Receives FastCGI request                     │
       │  - Runs PHP interpreter on index.php            │
       │  - Generates output (HTML/JSON/etc.)            │
       └─────────┬──────────────────────────────────────┘
                 │ FastCGI Response
                 ▼
            ┌─────────────┐
            │    NGINX    │
            │ Adds headers │
            │ Sends HTTP   │
            └──────┬──────┘
                   │
                   ▼
        ┌──────────────────────────────┐
        │          Browser              │
        │   Receives final response    │
        └──────────────────────────────┘
```
