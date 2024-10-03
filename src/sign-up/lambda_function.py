import json
import logging
import os

import requests
import boto3

cognito_client = boto3.client("cognito-idp")

USER_POOL_ID = os.environ.get("USER_POOL_ID")


def lambda_handler(event, context):
    print(event)
    email = event.get("email")
    password = event.get("password")

    user_attributes = []
    payload = {}

    if email:
        print('Teste email: ' + email)
        print(user_attributes)
        user_attributes.append({"Name": "custom:email", "Value": email})
        print(user_attributes)
        payload["email"] = email
        print(payload["email"])

        print('Teste Password: ' + password)
        print(user_attributes)
        user_attributes.append({"Name": "custom:password", "Value": password})
        print(user_attributes)
        payload["password"] = password
        print(payload["password"])
    else:
        return {
            "statusCode": 400,
            "headers": {"Content-Type": "application/json"},
            "body": "{ 'message': 'Please provide either Email and Password' }",
        }

    response = cognito_client.admin_create_user(
        UserPoolId=USER_POOL_ID,
        Username=email,
        TemporaryPassword=password
    )

    print(response)

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({ 'email': response.get('User').get('Username') }),
    }