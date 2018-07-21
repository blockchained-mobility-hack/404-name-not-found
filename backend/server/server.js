'use strict'

const WebSocket = require('ws')

const Promise = require('bluebird')
// custom logger
const log = require('./logger.js')
const express = require('express')

const blockchain = require('../blockchain/api')

blockchain.initializeSmartContract().then(() => console.log("Contracts and accounts initalized"))

const app = express()

app.use(require('helmet')()) // use helmet
app.use(require('cors')()) // enable CORS
// serves all static files in /public
app.use(express.static(`${__dirname}/../public`))
const port = process.env.PORT || 8000
const server = require('http').Server(app)

const wss = new WebSocket.Server({port: 8080})

// boilerplate version
const version = `Express-Boilerplate v${require('../package.json').version}`

// start server
server.listen(port, async () => {
    log.info(version)
    log.info(`Listening on port ${port}`)
})

wss.on('connection', function connection(ws) {
    ws.send('connected')
})

// 'body-parser' middleware for POST
const bodyParser = require('body-parser')
// create application/json parser
const jsonParser = bodyParser.json()
// create application/x-www-form-urlencoded parser
const urlencodedParser = bodyParser.urlencoded({
    extended: false
})

// POST /login gets urlencoded bodies
app.post('/login', urlencodedParser, (req, res) => {
    if (!req.body) return res.sendStatus(400)
    res.send(`welcome, ${req.body.username}`)
})

// POST /api/users gets JSON bodies
app.post('/api/users', jsonParser, (req, res) => {
    if (!req.body) return res.sendStatus(400)
    // create user in req.body
})

app.post('/api/mobility-platform/service-provider/propose-service-usage', jsonParser, async (req, res) => {
    const offerId = req.body.offerId
    const timeStarted = Date.parse(req.body.timeStarted)
    const proposedPricePerKilometer = req.body.proposedPrice
    const numberOfKilometers = req.body.numberOfKilometers

    console.log(offerId, timeStarted, proposedPricePerKilometer, numberOfKilometers, serviceBlockchainAddress) // DEBUG purposes

    await blockchain.unlockBlockchainAccount(serviceBlockchainAddress, serviceBlockchainPassword)
    const transactionToBeSend = blockchain.deployedContract.methods.proposeServiceUsage(offerId, timeStarted,
        proposedPricePerKilometer, numberOfKilometers)
    const gasEstimation = transactionToBeSend.estimateGas()
    const commitedTransaction = await transactionToBeSend.send()
    const commitedTransactionEvent = commitedTransaction.event
    ws.send(event)

    res.setHeader('Content-Type', 'application/json')
    res.send(JSON.stringify({event}))
    if (!req.body) return res.sendStatus(400)
})

app.post('/api/mobile-app/mobility-platform/mobile/accept-service', jsonParser, (req, res) => {
    const offerId = req.body.offerId

    const userBlockchainAddress = "0xde0B295669a9FD93d5F28D9Ec85E40f4cb697BAe" // This will be fixed, demo value

    console.log(offerId, userBlockchainAddress) // TODO EXECUTE TRANSACTION acceptService AND RETURN EVENT TO APP
    const event = "ServiceAccepted"
    res.setHeader('Content-Type', 'application/json')
    res.send(JSON.stringify({event}))
    if (!req.body) return res.sendStatus(400)
    // create user in req.body
})

app.post('/api/mobility-platform/service-provider/finishServiceUsage', jsonParser, (req, res) => {
    const offerId = req.body.offerId
    const timeFinished = Date.parse(req.body.timeFinished)
    const numberOfKilometersTraveled = req.body.numberOfKilometersPassed

    const serviceBlockchainAddress = "0xde0B295669a9FD93d5F28D9Ec85E40f4cb697BAe" // This will be fixed, demo value

    console.log(offerId, timeFinished, numberOfKilometersTraveled, serviceBlockchainAddress) // TODO EXECUTE TRANSACTION finishServiceUsage
    const event = "ServiceFinished"
    res.setHeader('Content-Type', 'application/json')
    res.send(JSON.stringify({event}))
    // TODO when event is returned, publish topic on web sockets for APP
    if (!req.body) return res.sendStatus(400)
})

// ex. using 'node-fetch' to call JSON REST API
/*
const fetch = require('node-fetch');
// for all options see https://github.com/bitinn/node-fetch#options
const url = 'https://api.github.com/users/cktang88/repos';
const options = {
  method: 'GET',
  headers: {
    // spoof user-agent
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36'
  }
};

fetch(url, options)
  .then(res => {
    // meta
    console.log(res.ok);
    console.log(res.status);
    console.log(res.statusText);
    console.log(res.headers.raw());
    console.log(res.headers.get('content-type'));
    return res.json();
  })
  .then(json => {
    console.log(`User has ${json.length} repos`);
  })
  .catch(err => {
    // API call failed...
    log.error(err);
  });
*/
