from fastapi import FastAPI, Body

app = FastAPI()

@app.get("/")
def root():
    return {"msg": "FEA API is running!"}

@app.post("/run-fea/")
def run_fea(engine: str = Body("sfepy")):
    # 這裡將來要引入 engine_sfepy 或 engine_elmer
    return {"msg": f"收到分析請求，選擇引擎：{engine}"}
