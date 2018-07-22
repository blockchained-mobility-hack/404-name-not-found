'use strict'

const contractData = require('../build/contracts/MobilityPlatform.json')

const Web3 = require('web3')

let deployedContract, web3

let contractOwnerAddress, contractOwnerPassword = "owner"

let userBlockchainAddress, userBlockchainPassword = "userPassword" // TODO - add identity management?

let serviceBlockchainAddress, serviceBlockchainPassword = "servicePassword"

async function initializeSmartContract() {
    await inializeWeb3()
    contractOwnerAddress = await initializeBlockchainAccount(contractOwnerPassword)
    await unlockBlockchainAccount(contractOwnerAddress, contractOwnerPassword)
    deployedContract = await initializeContract(contractData.abi, contractData.bytecode, contractOwnerAddress, contractOwnerPassword)
    userBlockchainAddress = await initializeBlockchainAccount(userBlockchainPassword)
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
    return deployTransaction.send({gas: estimatedGas, from: contractOwnerAddress})
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
    return deployedContract
}

module.exports = {
    initializeSmartContract,
    getMobilityContract,
    getAccount,
    unlockBlockchainAccount
}