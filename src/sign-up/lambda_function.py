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
    cpf = event.get("password")

    user_attributes = []
    payload = {}

    if cpf:
        print('Teste CPF: ' + cpf)
        print(user_attributes)
        user_attributes.append({"Name": "custom:cpf", "Value": cpf})
        print(user_attributes)
        payload["cpf"] = cpf
        print(payload["cpf"])

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
            "body": "{ 'message': 'Please provide either CPF and Password' }",
        }

    response = client.admin_create_user(
        UserPoolId=USER_POOL_ID,
        Username=cpf,
        TemporaryPassword= password,
        GroupName="customer"
        UserAttributes=[{"Name": "cpf","Value": cpf}, { "Name": "password", "Value": "password" }]
    )

    print(response)

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({ 'customer_id': customer_id }),
    }