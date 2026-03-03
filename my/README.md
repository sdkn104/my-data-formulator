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

- Visualization
    - create and store chart spec.
        1. (UI) src\views\ChartRecBox.tsx (one of UI)
            - ChartRecBox() fetch /derive-data
        1. (API) agent_routes.py call PythonDataRecAgent.run?
            - PythonDataRecAgent defined in py-src\data_formulator\agents\agent_py_data_rec.py
            - return response: json viz and python transform
        1. (UI) ChartRecBox() get response
            - refinedGoal = chart object of response
            - newChart = resolveRecommendedChart(refinedGoal, ... in utils.tsx
            - dfActions.addChart(newChart)  -> save in state(redux)

    - convert chart spec to vega-lite, to SVG
        1. load charts from df(redux)
        1. src\app\utils.tsx assembleVegaChart
            - input template, chartType, encodingMap, etc.
            - create vega-lite spec. using template
            - templates are defined in src\components\ChartTemplates.tsx
        1. result = await embed(`#${tempId}`, assembledChart,
        1. svgString = await result.view.toSVG(4);

    - App.tsx - top (About, Heder, )
        - src\views\DataFormulator.tsx - app画面
            - DataThread.tsx  左ペイン
            - VisualizationView.tsx メイン上（右側のEditorペイン含む）
                - ChartRecBox (チャート未選択時の画面)
                - VisualizationViewFC - main chart
                    - ChartEditorFC
                        - header (zoom, etc)
                        - VegaChartRenderer  (チャート)
                        - footer (chat, code, explain, etc)
                        - EncodingShelfThread 左パネル
                            - previousInstructions テーブル履歴
                                -  TriggerCard
                            - EncodingShelfCard - 編集UI
                            - postInstruction
                                - テーブル名
                                - Chartサムネイル群
                                    - ChartElementFC

            - FreeDataView.tsx メイン下（テーブル表示）



- Table data
    - /create-table
        1. /create-table in py-src\data_formulator\tables_routes.py
        1. df = pd.read_csv(file)
        1. save df to duck DB using sessionID
    - /get-table
        - specify table name and page size
        - get table from duck db with limitting page size (row size)


    1. fetchFieldSemanticType fetch /process-data-on-load

    - /derive-data request body contain full table data (input_tables)
    - in PythonDataRecAgent.run
        - call run_transform_in_sandbox2020 for transform execution
            - with input_tables as arg



# SEQUENCE

1. data_formulator.agents.agent_data_load
    - DataLoadAgent
        - -> table name, fields, "data summary"
1. (idea?) /api/agent/get-recommendation-questions -> data_formulator.agents.agent_interactive_explore   (either agent or not)
    - InteractiveExploreAgent
        - input:  [DATASETS][EXPLORATION THREAD][CURRENT DATA] [START QUESTION]
        - output: list of "question(s)", "goal", "difficulty"

1. (select idea) /derive-data -> 
    -  chart_encodingsがあれば, SQLDataRecAgent or PythonDataRecAgent 　メソッドrun()
    -  なければ、SQLDataTransformationAgent or PythonDataTransformationAgent 　メソッドrun()
    - data_formulator.agents.agent_py_data_rec PythonDataRecAgent (run/followup)
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
1. (auto exec) /code-expl data_formulator.agents.agent_code_explanation
    - CodeExplanationAgent
        - input: a summary of the input data, and the transformation code.
        - output:
            - first section is the code explanation that should be a markdown block explaining the code, in the [CODE EXPLANATION] section.
            - second section is the concepts explanation that should be a json block (start with ```json) in the [CONCEPTS EXPLANATION] section.
        - internally call: data_formulator.agents.agent_data_load for transformed data

---

1. (Get Ideas) /get-recommendation-questions
2. (select idea) /derive-data

---

1. (formulate data) /refine-data -> SQLDataTransformationAgent or PythonDataTransformationAgent　メソッドfollowup()
    - py-src\data_formulator\agents\agent_py_data_transform.py
        - PythonDataRecAgent とほぼ同じ

# Goal/Question

- (ideas) Explore Agent returns:
    - Question
    - Goal
    - Difficulty
- -> GUI
    - Question -> prompt box
    - Goal -> idea title
- -> redux
    - setIdeas(questions = {question, goal, difficulity})

- (select ideas) Recommend Agent returns:　use only Goal
    - "recap": "Rank students based on their average scores",  short summary of goal
    - "display_instruction": "Rank students by average scores", more short
    - "recommendation": "To rank students based on their average scores, we need to calculate " explain why this recommendation is made
- -> GUI
    - display_instruction -> title
    - recap, recommendation -> chat内に表示
    - Goal -> prompt box
- -> redux
    - let newChart = resolveRecommendedChart(refinedGoal, currentConcepts, candidateTable); Chart type
    - dispatch(dfActions.addChart(newChart));
    
- input prompt box, send to Agent (/derive-data)
    - prompt -> Goal
