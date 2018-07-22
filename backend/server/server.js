'use strict'

const SocketServer = require('ws').Server

const express = require('express')

const blockchain = require('../blockchain/api')

const moment = require("moment")

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

const statusMapping = {
    0: 'OfferProposed',
    1: 'OfferAccepted',
    2: 'OfferDeclined',
    3: 'UsageStarted',
    4: 'UsageEnded',
    5: 'Paid'
}

app.get('/api/mobility-platform/usage-record/:offerId', jsonParser, async (req, res) => {
    const offerId = req.params.offerId
    const user = blockchain.getAccount("user")
    const transactionToBeSend = blockchain.getMobilityContract().methods.getUsageRecord(offerId)
    const data = await transactionToBeSend.call({from: user.blockchainAddress})
    const response = JSON.stringify({
        offerId: data[0],
        provider: data[1],
        user: data[2],
        offerValidUntil: data[3],
        serviceUsageStartTime: data[4],
        serviceUsageEndTime: data[5],
        distanceTravelled: data[6],
        pricePerKm: data[7],
        totalPrice: data[8],
        status: statusMapping[data[9]],
        hashv: data[10]
    })
    res.setHeader('Content-Type', 'application/json')
    res.send(response)
    if (!req.body) return res.sendStatus(400)
})

app.post('/api/mobility-platform/service-provider/propose-service-usage', jsonParser, async (req, res) => {
    const offerId = req.body.offerId
    const offerValidUntil = moment(req.body.offerValidUntil).unix()
    const pricePerKm = req.body.pricePerKm

    const service = blockchain.getAccount("service")
    const user = blockchain.getAccount("user")
    await blockchain.unlockBlockchainAccount(service.blockchainAddress, service.blockchainPassword)
    const transactionToBeSend = blockchain.getMobilityContract().methods.proposeServiceUsage(offerId, offerValidUntil,
        pricePerKm, user.blockchainAddress)
    const gasEstimation = transactionToBeSend.estimateGas()
    const committedTransaction = await transactionToBeSend.send(
        {gas: (gasEstimation * 2), from: service.blockchainAddress})
    const committedTransactionEvent = committedTransaction.events.ServiceUsageProposed

    const response = JSON.stringify(
        {
            offerId: committedTransactionEvent.returnValues.offerId,
            provider: committedTransactionEvent.returnValues.provider,
            pricePerKm: committedTransactionEvent.returnValues.pricePerKm,
            validUntil: committedTransactionEvent.returnValues.validUntil,
            hashv: committedTransactionEvent.returnValues.hashV
        })
    if (websocket) {
        websocket.send(response)
    }
    res.setHeader('Content-Type', 'application/json')
    res.send(response)
    if (!req.body) return res.sendStatus(400)
})

app.post('/api/mobility-platform/mobile/accept-service', jsonParser, async (req, res) => {
    const offerId = req.body.offerId

    const user = blockchain.getAccount("user")

    await blockchain.unlockBlockchainAccount(user.blockchainAddress, user.blockchainPassword)
    const transactionToBeSend = blockchain.getMobilityContract().methods.acceptProposedOffer(offerId)
    const gasEstimation = transactionToBeSend.estimateGas()
    const committedTransaction = await transactionToBeSend.send({gas: gasEstimation * 2, from: user.blockchainAddress})
    const committedTransactionEvent = committedTransaction.events.ServiceUsageProposalAccepted

    const response = JSON.stringify(
        {
            offerId: committedTransactionEvent.returnValues.offerId
        })
    res.setHeader('Content-Type', 'application/json')
    res.send(response)
    if (!req.body) return res.sendStatus(400)
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
