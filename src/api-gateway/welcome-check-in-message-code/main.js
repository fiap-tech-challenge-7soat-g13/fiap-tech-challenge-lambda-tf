const http = require("http");
const url = "http://tastefood-ecs-1764329678.us-east-1.elb.amazonaws.com/customers/mail/"


exports.handler = async (event) => {

    console.log(JSON.stringify(event))

    const { claims } = event.requestContext.authorizer

    const response = await new Promise(function (resolve, reject) {

        http.get(url + claims.email, (res) => {

            console.log(res.statusCode)

            resolve(res.statusCode)

        }).on("error", (e) => {
            reject(Error(e));
        });
    });


    return {statusCode: response, data: event};


};