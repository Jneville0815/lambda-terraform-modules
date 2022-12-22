import os
from botocore.vendored import requests
from twilio.rest import Client


def lambda_handler(event, context):
    account_sid = os.environ['TWILIO_ACCOUNT_SID']
    auth_token = os.environ['TWILIO_AUTH_TOKEN']
    twilio_number = os.environ['TWILIO_PHONE_NUMBER']

    client = Client(account_sid, auth_token)

    res = requests.get('https://3cl6ts0f6f.execute-api.us-east-1.amazonaws.com/production/api/userInfo/jimmyeneville@gmail.com/getQuote')

    print(res)

    # message = client.messages \
    #     .create(
    #     body="This is a test",
    #     from_=twilio_number,
    #     to='+1XXXXXXXXXX'
    # )
    #
    # print(f"Text message sent (Message: {message.body}. Error: {message.error_message})")