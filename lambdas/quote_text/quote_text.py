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
    recipient_number = os.environ['RECIPIENT_PHONE_NUMBER']
    backend_endpoint = os.environ['BACKEND_ENDPOINT']

    # Optional second recipient. Both must be set for anything to be sent.
    reminder_number = os.environ.get('REMINDER_PHONE_NUMBER')
    reminder_message = os.environ.get('REMINDER_MESSAGE')
    reminder_chance = float(os.environ.get('REMINDER_CHANCE', '0.10'))

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
        to=recipient_number
    )

    print(f"Text message sent (Message: {message.body}. Error: {message.error_message})")

    if reminder_number and reminder_message and random.random() < reminder_chance:
        message = client.messages \
            .create(
            body=reminder_message,
            from_=twilio_number,
            to=reminder_number
        )

        print(f"Text message sent (Message: {message.body}. Error: {message.error_message})")
