'use strict'

const SocketServer = require('ws').Server

const express = require('express')

const blockchain = require('../blockchain/api')

blockchain.initializeSmartContract().then(() => console.log("Blockchain contracts and accounts initalized"))

const app = express()

app.use(require('helmet')()) // use helmet
app.use(require('cors')()) // enable CORS
const port = process.env.PORT || 8000
const server = require('http').Server(app)

const wss = new SocketServer({server: server})

// boilerplate version
const version = `Express-Boilerplate v${require('../package.json').version}`

// start server
server.listen(port, async () => {
    console.info(version)
    console.info(`Listening on port ${port}`)
})

let websocket
wss.on('connection', function connection(ws) {
    websocket = ws
    const message = "Connection established"
    console.log(message)
    ws.send(message + new Date())
})

// 'body-parser' middleware for POST
const bodyParser = require('body-parser')
// create application/json parser
const jsonParser = bodyParser.json()
// create application/x-www-form-urlencoded parser
const urlencodedParser = bodyParser.urlencoded({
    extended: false
})

app.post('/api/mobility-platform/service-provider/propose-service-usage', jsonParser, async (req, res) => {
    const offerId = req.body.offerId
    const timeStarted = Date.parse(req.body.timeStarted)
    const proposedPricePerKilometer = req.body.proposedPrice
    const numberOfKilometers = req.body.numberOfKilometers

    console.log(offerId, timeStarted, proposedPricePerKilometer, numberOfKilometers, blockchain.serviceBlockchainAddress) // DEBUG purposes

    await blockchain.unlockBlockchainAccount(blockchain.serviceBlockchainAddress, blockchain.serviceBlockchainPassword)
    const transactionToBeSend = blockchain.deployedContract.methods.proposeServiceUsage(offerId, timeStarted,
        proposedPricePerKilometer, numberOfKilometers)
    const gasEstimation = transactionToBeSend.estimateGas()
    const commitedTransaction = await transactionToBeSend.send()
    const commitedTransactionEvent = commitedTransaction.event

    const response = JSON.stringify(
        {
            offerId: commitedTransactionEvent.offerId,
            provider: commitedTransactionEvent.provider,
            pricePerKm: commitedTransactionEvent.pricePerKm,
            validUntil: commitedTransactionEvent.validUntil,
            hashv: commitedTransactionEvent.hashV
        })
    websocket.send(response)
    res.setHeader('Content-Type', 'application/json')
    res.send(response)
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
