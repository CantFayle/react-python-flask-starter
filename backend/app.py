from flask import Flask
from utils.require_auth_decorator import require_auth

app = Flask(__name__)

@app.route("/")
# @require_auth
def hello_world():
    return "<p>Hello, World!</p>"
