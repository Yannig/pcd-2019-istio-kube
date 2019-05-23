#!/usr/bin/python3

from flask import Flask
from healthcheck import HealthCheck, EnvironmentDump

app = Flask(__name__)

# wrap the flask app and give a heathcheck url
health = HealthCheck(app, "/healthcheck")
envdump = EnvironmentDump(app, "/environment")

@app.route('/')
def hello_world():
    return "coucou"
