'use strict'

const SocketServer = require('ws').Server

const express = require('express')

const blockchain = require('../blockchain/api')

const moment = require("moment")

blockchain.initializeSmartContract().
    then(() => console.log("Blockchain contracts and accounts initalized")).
    catch(err => {
        console.log("Error during contracts initalization", err)
        process.exit(1)
    })

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
    try {
        if (!req.params) return res.sendStatus(400)

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
    }
    catch (err) {
        console.log(err)
        res.sendStatus(500)
    }
})

app.get('/api/mobility-platform/euro-token/balance', jsonParser, async (req, res) => {
    try {

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
    }
    catch (err) {
        console.log(err)
        res.sendStatus(500)
    }
})

app.post('/api/mobility-platform/service-provider/propose-service-usage', jsonParser, async (req, res) => {
    try {
        if (!req.body) return res.sendStatus(400)

        const offerId = req.body.offerId
        const offerValidUntil = moment(req.body.offerValidUntil).unix()
        const pricePerKm = req.body.pricePerKm

        const service = blockchain.getAccount("service")
        const user = blockchain.getAccount("user")
        await blockchain.unlockBlockchainAccount(service.blockchainAddress, service.blockchainPassword)
        const transactionToBeSend = blockchain.getMobilityContract().
            methods.
            proposeServiceUsage(offerId, offerValidUntil,
                pricePerKm, user.blockchainAddress)
        const gasEstimation = transactionToBeSend.estimateGas()
        const committedTransaction = await transactionToBeSend.send(
            {gas: (gasEstimation * 2), from: service.blockchainAddress})
        const committedTransactionEvent = committedTransaction.events.ServiceUsageProposed

        if (!committedTransactionEvent) {
            return res.sendStatus(422)
        }

        const response = JSON.stringify(
            {
                offerId: committedTransactionEvent.returnValues.offerId,
                provider: committedTransactionEvent.returnValues.provider,
                pricePerKm: committedTransactionEvent.returnValues.pricePerKm,
                validUntil: committedTransactionEvent.returnValues.validUntil,
                hashv: committedTransactionEvent.returnValues.hashV
            })
        if (websocket) {
            const webSocketResponse = Object.assign({}, {type: "proposal"}, response)
            websocket.send(JSON.stringify(webSocketResponse))
        }
        res.setHeader('Content-Type', 'application/json')
        res.send(response)
    }
    catch (err) {
        console.log(err)
        res.sendStatus(500)
    }
})

app.post('/api/mobility-platform/mobile/accept-proposed-offer', jsonParser, async (req, res) => {
    try {
        if (!req.body) return res.sendStatus(400)
        console.log(req.body)
        console.log(req.body.offerId)
        const offerId = parseFloat(req.body.offerId)

        console.log(offerId)


        const user = blockchain.getAccount("user")

        await blockchain.unlockBlockchainAccount(user.blockchainAddress, user.blockchainPassword)
        const transactionToBeSend = blockchain.getMobilityContract().methods.acceptProposedOffer(offerId)
        const gasEstimation = transactionToBeSend.estimateGas()
        const committedTransaction = await transactionToBeSend.send(
            {gas: gasEstimation * 2, from: user.blockchainAddress})
        const committedTransactionEvent = committedTransaction.events.ServiceUsageProposalAccepted

        if (!committedTransactionEvent) {
            return res.sendStatus(422)
        }

        const response = JSON.stringify(
            {
                offerId: committedTransactionEvent.returnValues.offerId
            })
        res.setHeader('Content-Type', 'application/json')
        res.send(response)
    }
    catch (err) {
        console.log(err)
        res.sendStatus(500)
    }
})

app.post('/api/mobility-platform/mobile/decline-proposed-offer', jsonParser, async (req, res) => {
    try {
        if (!req.body) return res.sendStatus(400)

        const offerId = req.body.offerId

        const user = blockchain.getAccount("user")

        await blockchain.unlockBlockchainAccount(user.blockchainAddress, user.blockchainPassword)
        const transactionToBeSend = blockchain.getMobilityContract().methods.declineProposedOffer(offerId)
        const gasEstimation = transactionToBeSend.estimateGas()
        const committedTransaction = await transactionToBeSend.send(
            {gas: gasEstimation * 2, from: user.blockchainAddress})
        const committedTransactionEvent = committedTransaction.events.ServiceUsageProposalDeclined

        if (!committedTransactionEvent) {
            return res.sendStatus(422)
        }

        const response = JSON.stringify(
            {
                offerId: committedTransactionEvent.returnValues.offerId
            })
        res.setHeader('Content-Type', 'application/json')
        res.send(response)
    }
    catch (err) {
        console.log(err)
        res.sendStatus(500)
    }
})

app.post('/api/mobility-platform/service-provider/start-service-usage', jsonParser, async (req, res) => {
    try {
        if (!req.body) return res.sendStatus(400)

        const offerId = req.body.offerId
        const serviceUsageStartTime = moment(req.body.serviceUsageStartTime).unix()

        const service = blockchain.getAccount("service")

        await blockchain.unlockBlockchainAccount(service.blockchainAddress, service.blockchainPassword)
        const transactionToBeSend = blockchain.getMobilityContract().
            methods.
            startServiceUsage(offerId, serviceUsageStartTime)
        const gasEstimation = transactionToBeSend.estimateGas()
        const committedTransaction = await transactionToBeSend.send(
            {gas: gasEstimation * 2, from: service.blockchainAddress})
        const committedTransactionEvent = committedTransaction.events.ServiceUsageStarted

        if (!committedTransactionEvent) {
            return res.sendStatus(422)
        }

        const response = JSON.stringify(
            {
                offerId: committedTransactionEvent.returnValues.offerId,
                serviceUsageStartTime: committedTransactionEvent.returnValues.serviceUsageStartTime,
                hashv: committedTransactionEvent.returnValues.hashV
            })
        if (websocket) {
            const webSocketResponse = Object.assign({}, {type: "started"}, response)
            websocket.send(JSON.stringify(webSocketResponse))
        }
        res.setHeader('Content-Type', 'application/json')
        res.send(response)
    }
    catch (err) {
        console.log(err)
        res.sendStatus(500)
    }
})

app.post('/api/mobility-platform/service-provider/finish-service-usage', jsonParser, async (req, res) => {
    try {
        if (!req.body) return res.sendStatus(400)

        const offerId = req.body.offerId
        const serviceUsageEndTime = moment(req.body.serviceUsageEndTime).unix()
        const distanceTravelled = req.body.distanceTravelled

        const service = blockchain.getAccount("service")
        const user = blockchain.getAccount("user")

        await blockchain.unlockBlockchainAccount(user.blockchainAddress, user.blockchainPassword)
        const erc20ApproveTransaction = blockchain.getEuroTokenContract().
            methods.
            approve(blockchain.getMobilityContract()._address, 100000)
        const erc20GasEstimate = erc20ApproveTransaction.estimateGas()
        const erc20CommitedTransaction = await erc20ApproveTransaction.send({
            gas: (erc20GasEstimate * 2), from: user.blockchainAddress
        })
        console.log(erc20CommitedTransaction.events)

        await blockchain.unlockBlockchainAccount(service.blockchainAddress, service.blockchainPassword)
        const finishServiceTransaction = blockchain.getMobilityContract().
            methods.
            finishServiceUsage(offerId, serviceUsageEndTime, distanceTravelled)
        const finishTransactionGasEstimate = finishServiceTransaction.estimateGas()
        const committedTransaction = await
            finishServiceTransaction.send(
                {gas: (finishTransactionGasEstimate * 2), from: service.blockchainAddress})
        const serviceUsageEndedEvent = committedTransaction.events.ServiceUsageEnded

        console.log(committedTransaction.events)

        await
            blockchain.unlockBlockchainAccount(service.blockchainAddress, service.blockchainPassword)
        const paymentTransactionToBeSend = blockchain.getMobilityContract().
            methods.
            executePayment(blockchain.getEuroTokenContract()._address, offerId)
        const paymentGasEstimate = paymentTransactionToBeSend.estimateGas()
        const committedPayment = await
            paymentTransactionToBeSend.send({gas: (paymentGasEstimate * 2), from: service.blockchainAddress})
        const paymentEvent = committedPayment.events.ServiceUsagePayedUp

        console.log(committedPayment.events)

        if (!serviceUsageEndedEvent) {
            return res.sendStatus(422)
        }

        const response =
            {
                offerId: serviceUsageEndedEvent.returnValues.offerId,
                serviceUsageEndTime: serviceUsageEndedEvent.returnValues.serviceUsageEndTime,
                distanceTravelled: serviceUsageEndedEvent.returnValues.distanceTravelled,
                totalPrice: serviceUsageEndedEvent.returnValues.validUntil,
                hashv: serviceUsageEndedEvent.returnValues.hashV

            }

        res.setHeader('Content-Type', 'application/json')
        const paymentSucceced = Boolean(paymentEvent)

        if (websocket) {
            const webSocketResponse = Object.assign({}, {type: "finished"}, {paymentSucceced}, response)
            websocket.send(JSON.stringify(webSocketResponse))
        }

        paymentSucceced ? res.status(200).send(JSON.stringify(response)) : res.status(422).
            send(JSON.stringify(response))
    }
    catch
        (err) {
        console.log(err)
        res.sendStatus(500)
    }
})
