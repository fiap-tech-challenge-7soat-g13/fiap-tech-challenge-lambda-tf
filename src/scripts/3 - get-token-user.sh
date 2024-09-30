aws cognito-idp initiate-auth \
 --client-id 123 \
 --auth-flow USER_PASSWORD_AUTH \
 --auth-parameters USERNAME=joao,PASSWORD=4960 \
 --query 'AuthenticationResult.IdToken' \
 --output text