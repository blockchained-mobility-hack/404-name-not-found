# MobiPay backend

### Backend API

Api documentation is provided [here](https://documenter.getpostman.com/view/2876778/RWMHKmZt)

Postman collection is provided [here](https://www.getpostman.com/collections/ff953ad7bdcf0c5e04e7)

### Starting locally

First, make sure that Ethereum node is up and running as smart contracts are deployed during start up

You can use parity docker image

```
docker run -p 8545:8545 -p 8546:8546 ruf47/parity-custom-dev
```

Then execute

```
npm run start
```

Server is listening on HTTP request on port 8000.

WS server is listening/publishing on  port 8000.