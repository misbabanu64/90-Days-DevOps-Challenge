import os
from flask import Flask, jsonify

app = Flask(__name__)

@app.get("/")
def home():
    return jsonify(message="Docker security lab")

@app.get("/health")
def health():
    environment = os.getenv("APP_ENV", "dev")
    return "ok", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
