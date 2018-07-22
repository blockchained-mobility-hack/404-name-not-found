'use strict'

const mobilityContractData = require('../build/contracts/MobilityPlatform.json')

const euroErcContractData = require('../build/contracts/EuroToken.json')

const Web3 = require('web3')

let deployedMobilityContract, deployedErcEuroToken, web3


let userBlockchainAddress, userBlockchainPassword = "userPassword" // TODO - add identity management?

let serviceBlockchainAddress, serviceBlockchainPassword = "servicePassword"

async function initializeSmartContract() {
    await inializeWeb3()
    userBlockchainAddress = await initializeBlockchainAccount(userBlockchainPassword)
    await unlockBlockchainAccount(userBlockchainAddress, userBlockchainPassword)

    deployedErcEuroToken = await initializeContract(euroErcContractData.abi, euroErcContractData.bytecode, userBlockchainAddress, userBlockchainPassword)
    console.log("ERC20 Euro token contract", deployedErcEuroToken._address)

    await unlockBlockchainAccount(userBlockchainAddress, userBlockchainPassword)
    console.log("ERC 20 owner address", userBlockchainAddress)

    deployedMobilityContract = await initializeContract(mobilityContractData.abi, mobilityContractData.bytecode, userBlockchainAddress, userBlockchainPassword)
    console.log("Mobility contract address", deployedMobilityContract._address)
    serviceBlockchainAddress = await initializeBlockchainAccount(serviceBlockchainPassword)
}

const inializeWeb3 = async () => {
    if (!web3) {
        const rpcUrl = "http://localhost:8545/"
        web3 = new Web3(rpcUrl)
    }
}

const initializeContract = async (abi, bytecode, ownerAddress, ownerPassword) => {
    const contractInterface = new web3.eth.Contract(abi)
    const deployTransaction = contractInterface.deploy({data: bytecode, arguments: []})
    const estimatedGas = await deployTransaction.estimateGas()
    console.log("Estimated gas", estimatedGas)
    return deployTransaction.send({gas: estimatedGas, from: ownerAddress})
}

const initializeBlockchainAccount = async (userBlockchainPassword) => {
    return web3.eth.personal.newAccount(userBlockchainPassword)
}

const unlockBlockchainAccount = async (blockchainAccount, blockchainPassword) => {
    return web3.eth.personal.unlockAccount(blockchainAccount, blockchainPassword)
}

const getAccount = (accountType) => {
    if (accountType === "user") {
        return {blockchainAddress: userBlockchainAddress, blockchainPassword: userBlockchainPassword}
    } else if (accountType === "service") {
        return {blockchainAddress: serviceBlockchainAddress, blockchainPassword: serviceBlockchainPassword}
    }
}

const getMobilityContract = () => {
    return deployedMobilityContract
}

const getEuroTokenContract = () => {
    return deployedErcEuroToken
}

module.exports = {
    initializeSmartContract,
    getMobilityContract,
    getEuroTokenContract,
    getAccount,
    unlockBlockchainAccount
}