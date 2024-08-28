from functools import wraps
from flask import request, json
import requests


def is_access_token_valid(access_token, user_id):
    token_response = requests.get(
        "https://www.googleapis.com/oauth2/v1/userinfo?access_token=" + access_token,
        {
            "headers": {
                "Authorization": "Bearer " + access_token,
                "Accept": "application/json",
            }
        },
    )
    if token_response.status_code != 200:
        return False

    user_info = token_response.json()
    return user_id == user_info.get("id")


def require_auth(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        access_token = request.headers.get("oauth-access-token")
        user_id = request.headers.get("user-id")

        if access_token is None:
            return (
                json.dumps(
                    {
                        "error": "Your session has expired. Please log back in and try again."
                    }
                ),
                401,
            )

        if not is_access_token_valid(access_token, user_id):
            return (
                json.dumps(
                    {"error": "Invalid credentials. Please log back in and try again."}
                ),
                403,
            )

        return func(*args, **kwargs)

    return wrapper
