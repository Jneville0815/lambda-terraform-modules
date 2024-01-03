import os
import urllib3
import json
import random
from twilio.rest import Client


def lambda_handler(event, context):
    account_sid = os.environ['TWILIO_ACCOUNT_SID']
    auth_token = os.environ['TWILIO_AUTH_TOKEN']
    twilio_number = os.environ['TWILIO_PHONE_NUMBER']
    email = os.environ['EMAIL']
    password = os.environ['PASSWORD']

    backend_endpoint = 'https://ogby0w3cuj.execute-api.us-east-1.amazonaws.com/production/api'

    client = Client(account_sid, auth_token)
    http = urllib3.PoolManager()

    encoded_data = json.dumps({'email': email, 'password': password})
    res = http.request('POST', f'{backend_endpoint}/user/login', body=encoded_data, headers={'Content-Type': 'application/json'})
    json_res = json.loads(res.data.decode('utf-8'))

    token = json_res['token']
    user_id = json_res['user_id']

    res = http.request('GET', f'{backend_endpoint}/userInfo/{user_id}/getQuote', headers={'Authorization': f'Bearer {token}'})
    json_res = json.loads(res.data.decode('utf-8'))

    message = client.messages \
        .create(
        body=f"{json_res['source']}: {json_res['quote']}",
        from_=twilio_number,
        to='+1XXXXXXXXXX'
    )

    print(f"Text message sent (Message: {message.body}. Error: {message.error_message})")

    if random.random() < 0.10:
        message = client.messages \
            .create(
            body="REDACTED",
            from_=twilio_number,
            to='+1YYYYYYYYYY'
        )

        print(f"Text message sent (Message: {message.body}. Error: {message.error_message})")
