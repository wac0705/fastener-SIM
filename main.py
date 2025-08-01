from fastapi import FastAPI, Form
from fastapi.responses import FileResponse
from pycalculix import *
import matplotlib.pyplot as plt
import os

app = FastAPI()

@app.post("/run-fea/")
def run_fea(
    rod_length: float = Form(...),
    rod_radius: float = Form(...),
    head_radius: float = Form(...),
    pressure: float = Form(...)
):
    # 建立工程
    prj = Project('cold_forging_demo')
    part = prj.new_part('screw_forging')
    
    # 定義剖面點（軸對稱、左為中心）
    nodes = [
        (0, 0),                               # A: 底面中心
        (0, rod_length),                      # B: 頂面中心
        (rod_radius, rod_length),             # C: 桿部外徑
        (head_radius, 0.7 * rod_length),      # D: 頭部外徑 (例，頭部長佔 0.3*L)
        (head_radius, 0),                     # E: 頭部外圓底
        (0, 0)                                # 回到原點
    ]
    part.add_nodes_on_line(nodes)
    part.add_line('A', 'B')
    part.add_line('B', 'C')
    part.add_line('C', 'D')
    part.add_line('D', 'E')
    part.add_line('E', 'A')
    
    # 材料參數（簡化，碳鋼）
    mat = Material('Steel')
    mat.set_mech_props(young_mod=210e3, poisson=0.3, yield_stress=350)
    part.set_material(mat)
    part.set_mesh_params(elem_size=0.5)

    # 固定底部
    part.add_fixed_boundary('A', 'E')
    # 頂部施加壓力
    part.add_pressure('B', 'C', -abs(pressure))

    # 建立案例並執行
    case = prj.new_analysis('forging_case')
    case.set_analysis_type('linear')
    prj.run()

    # 匯出應力圖
    fig = case.plot_nodvar('s', 'max')
    img_path = '/app/fea_result.png'
    fig.savefig(img_path, dpi=180)
    plt.close(fig)
    
    return FileResponse(img_path, media_type="image/png")

# 測試首頁
@app.get("/")
def root():
    return {"msg": "FEA API is running! Use POST /run-fea/ to start analysis."}
