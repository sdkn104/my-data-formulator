# Documents

- https://data-formulator.ai/
- https://github.com/microsoft/data-formulator

# Settings

- setting .env, api-keys.env, that is loaded by app.py

# build and start

- refer DEVELOPMENT.md

## build python backend
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
- Visulization
    1. src\views\ChartRecBox.tsx 
        - ChartRecBox() fetch /derive-data
    1. agent_routes.py call PythonDataRecAgent.xxx return response
        - py-src\data_formulator\agents\agent_py_data_rec.py return json viz and python transform
    1. ChartRecBox() 
        - newChart = resolveRecommendedChart(refinedGoal, ...
        - dfActions.addChart(newChart)  -> save in state(redux)

    - src\app\utils.tsx assembleVegaChart
        - input template, chartType, encodingMap, etc.
        - create vega-lite spec. using template
    - templates are defined in src\components\ChartTemplates.tsx

# SEQUENCE

1. data_formulator.agents.agent_data_load
    - DataLoadAgent
        - -> table name, fields, "data summary"
1. /api/agent/get-recommendation-questions -> data_formulator.agents.agent_interactive_explore  (either agent or not)
    - InteractiveExploreAgent
        - input:  [DATASETS][EXPLORATION THREAD][CURRENT DATA] [START QUESTION]
        - output: list of "question(s)", "goal", "difficulty"

1. /derive-data -> SQLDataRecAgent or SQLDataTransformationAgent or PythonDataRecAgent or PythonDataTransformationAgent
    - data_formulator.agents.agent_py_data_rec PythonDataRecAgent (run, followup)
        - input: [CONTEXT] and [GOAL] 
        - output example:

            ```python
            {  
                "recap": "Rank students based on their average scores",
                "display_instruction": "Rank students by average scores",
                "mode": "infer",
                "recommendation": "To rank students based on their average scores, we need to calculate the average score for each student, then sort the data, and finally assign a rank to each student based on their average score.",  
                "input_tables": ["student_exam"],
                "output_fields": ["student", "major", "average_score", "rank"],  
                "chart_type": "bar",  
                "chart_encodings": {"x": "student", "y": "average_score"},  
            }  

            ===python
            def transform_data(df):  
                ...
                return transformed_df 
            ```
1. /code-expl data_formulator.agents.agent_code_explanation
    - CodeExplanationAgent
        - input: a summary of the input data, and the transformation code.
        - output:
            - first section is the code explanation that should be a markdown block explaining the code, in the [CODE EXPLANATION] section.
            - second section is the concepts explanation that should be a json block (start with ```json) in the [CONCEPTS EXPLANATION] section.
        - internally call: data_formulator.agents.agent_data_load for transformed data

