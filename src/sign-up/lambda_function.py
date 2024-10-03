import json
import logging
import os

import requests
import boto3

cognito_client = boto3.client("cognito-idp")

USER_POOL_ID = os.environ.get("USER_POOL_ID")


def lambda_handler(event, context):
    email = event.get("email")
    password = event.get("password")

    user_attributes = []
    payload = {}

    if email:
        user_attributes.append({"Name": "custom:email", "Value": email})
        payload["email"] = email

        user_attributes.append({"Name": "custom:password", "Value": password})
        payload["password"] = password
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