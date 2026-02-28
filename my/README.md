# Documents

- https://data-formulator.ai/
- https://github.com/microsoft/data-formulator

# Settings

- setting .env, api-keys.env, that is loaded by app.py

# build and start

## build python backend
- see DEVELOPMENT.md
1. python 
    ```powershell
    # python 3.13.x
    python -m venv myenv
    .\venv\Scripts\activate.ps1
    pip install -r requirements.txt
    ```
2. edit .env, api-keys.env

### start in development mode
```
local_server.ps1
```

## build Typescript frontend

```powershell
nvm use 22.22.0
corepack enable
corepack prepare yarn@stable --activate
yarn -v

yarn  # install packages
```

### start in development mode
```bash
yarn start
```
- Open [http://localhost:5173](http://localhost:5173) to view it

# code Structure

- Web UI is created using React-Redux 
    - in src/*
- Web API that is called by view of React-Redux
    - in py-src/data_formulator/app.py, *_route.py
- agent classes that is used in Web API
    - in py-src/data_formulator/agents/*
- LLM model config is setting in UI, and used body of API call by UI
    - config is stored in redux df

- LLM model (wrapper) is defined in py-src/data_formulator/agents/client_utils.py  
    ```python
    class OpenAIClientAdapter(object): --> Not Used
    class Client(object):
    ```


# a

