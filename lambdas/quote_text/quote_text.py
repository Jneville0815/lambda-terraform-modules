import os
import urllib3
import json
from twilio.rest import Client


def lambda_handler(event, context):
    account_sid = os.environ['TWILIO_ACCOUNT_SID']
    auth_token = os.environ['TWILIO_AUTH_TOKEN']
    twilio_number = os.environ['TWILIO_PHONE_NUMBER']

    client = Client(account_sid, auth_token)
    http = urllib3.PoolManager()
    res = http.request('GET', 'https://3cl6ts0f6f.execute-api.us-east-1.amazonaws.com/production/api/userInfo/jimmyeneville@gmail.com/getQuote')
    json_res = json.loads(res.data.decode('utf-8'))

    message = client.messages \
        .create(
        body=f"{json_res['source']}: {json_res['quote']}",
        from_=twilio_number,
        to='+1XXXXXXXXXX'
    )

    print(f"Text message sent (Message: {message.body}. Error: {message.error_message})")
