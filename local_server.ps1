## Copyright (c) Microsoft Corporation.
## Licensed under the MIT License.

## Set HTTP proxy environment variables only (Flask doesn't support SOCKS5)
## set http_proxy=http://127.0.0.1:7890
## set https_proxy=http://127.0.0.1:7890

$env:FLASK_RUN_PORT=5000
python -m py-src.data_formulator.app --port $env:FLASK_RUN_PORT --dev
