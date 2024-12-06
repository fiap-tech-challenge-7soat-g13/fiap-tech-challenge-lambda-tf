FROM swaggerapi/swagger-ui
RUN curl https://raw.githubusercontent.com/fiap-tech-challenge-7soat-g13/order-api/refs/heads/main/docs/openapi3_0.yaml > /usr/share/nginx/html/openapi3_0.yaml
ENV SWAGGER_JSON_URL=openapi3_0.yaml
EXPOSE 8080
