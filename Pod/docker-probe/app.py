from flask import Flask
import time
import os

app = Flask(__name__)

@app.route("/")
def greet():
    return "Hello World!"

@app.route("/healthcheck/liveness")
def liveness():
    return "Live for application"

@app.route("/healthcheck/readiness")
def readiness():
    if os.path.isfile("/prod-data/greet.txt"):
        return "Ready for data"
    else:
        return "Already does not exists", 404

if __name__ == "__main__": 
    time.sleep(50) # flask application이 시작되기까지 50초가 걸린다고 가정합니다.
    app.run(host="0.0.0.0",port=8080)