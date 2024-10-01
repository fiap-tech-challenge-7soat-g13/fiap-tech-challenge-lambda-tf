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
    logging.info(event)

    cpf = event.get("cpf")

    user_attributes = []
    payload = {}

    if cpf:
        print('Teste CPF: ' + cpf)
        username = cpf
        print('username: ' + username)
        print('user_attributes1: ' + user_attributes)
        user_attributes.push({"Name": "custom:CPF", "Value": cpf})
        print(user_attributes)
        payload["document"] = cpf
        print(payload["document"])
    else:
        return {
            "statusCode": 400,
            "headers": {"Content-Type": "application/json"},
            "body": "{ 'message': 'Please provide either CPF and Name' }",
        }

    headers = {"Content-Type": "application/json"}
    print(headers)
    print(LOAD_BALANCER_DNS)
    print(TARGET_PORT)
    url = f"http://{LOAD_BALANCER_DNS}:{TARGET_PORT}/customers"
    print(url)
    print(payload)
    response = requests.post(url, json=payload, headers=headers).json()
    print(response)
    customer_id = response["id"]
    user_attributes.push({"Name": "custom:CUSTOMER_ID", "Value": customer_id})

    response = cognito_client.admin_create_user(
        UserPoolId=USER_POOL_ID,
        Username=username,
        UserAttributes=user_attributes,
        MessageAction="SUPPRESS",
    )
    logging.info(response)

    response = cognito_client.admin_add_user_to_group(
        UserPoolId=USER_POOL_ID, Username=username, GroupName="customer"
    )
    logging.info(response)

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({ 'customer_id': customer_id }),
    }