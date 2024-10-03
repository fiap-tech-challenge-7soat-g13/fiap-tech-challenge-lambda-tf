import json
import logging
import os

import requests
import boto3

cognito_client = boto3.client("cognito-idp")

USER_POOL_ID = os.environ.get("USER_POOL_ID")
LOAD_BALANCER_DNS = os.environ.get("LOAD_BALANCER_DNS")
TARGET_PORT = os.environ.get("TARGET_PORT")


def lambda_handler(event, context):
    print(event)

    cpf = event.get("cpf")
    password = event.get("password")
    email = event.get("email")

    user_attributes = []
    payload = {}

    if cpf:
        print('Teste CPF: ' + cpf)
        username = cpf
        print('username: ' + username)
        print(user_attributes)
        user_attributes.append({"Name": "custom:CPF", "Value": cpf})
        print(user_attributes)
        payload["document"] = cpf
        print(payload["document"])

        print('Teste Password: ' + password)
        print(user_attributes)
        user_attributes.append({"Name": "custom:password", "Value": password})
        print(user_attributes)
        payload["password"] = password
        print(payload["password"])

        print('Teste email: ' + email)
        print(user_attributes)
        user_attributes.append({"Name": "custom:email", "Value": email})
        print(user_attributes)
        payload["email"] = email
        print(payload["email"])
    else:
        return {
            "statusCode": 400,
            "headers": {"Content-Type": "application/json"},
            "body": "{ 'message': 'Please provide either CPF and Password' }",
        }

    response = cognito_client.admin_create_user(
        UserPoolId=USER_POOL_ID,
        Username=username,
        TemporaryPassword=password,
        UserAttributes=[{"Name": "email","Value": email}]
    )

    print(response)

    response = cognito_client.admin_add_user_to_group(
        UserPoolId=USER_POOL_ID, Username=username, GroupName="customer"
    )
    print('response: ' + response)

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({ 'customer_id': customer_id }),
    }