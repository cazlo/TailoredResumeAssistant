from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def root():
    return {"health": "OK"}

@app.get("/hello/{name}")
async def greet(name: str):
    return {"message": f"Hello, {name}!"}