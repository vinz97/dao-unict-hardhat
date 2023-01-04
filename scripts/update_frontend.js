const frontEndContractsFile =
    "../dao-unict-nextjs/constants/contractAddresses.json"
const frontEndAbiFile = "../dao-unict-nextjs/constants/abi.json"

const fs = require("fs")
const { network, ethers } = require("hardhat")

// updateContractAddresses()
// updateAbi()

module.exports = async (DAOUnict) => {
    if (process.env.UPDATE_FRONT_END) {
        console.log("Writing to front end...")
        await updateContractAddresses(DAOUnict)
        await updateAbi(DAOUnict)
        console.log("Front end written!")
    }
}

async function updateAbi(DAOUnict) {
    //    const DAOUnictFactory = await ethers.getContractFactory("DAOUnict")
    //    const UnictContract = await DAOUnictFactory.deploy()
    //    await UnictContract.deployed()
    //    const DAOUnict = await ethers.getContract("DAOUnict")

    fs.writeFileSync(
        frontEndAbiFile,
        DAOUnict.interface.format(ethers.utils.FormatTypes.json)
    )
}

async function updateContractAddresses(DAOUnict) {
    //    const DAOUnictFactory = await ethers.getContractFactory("DAOUnict")
    //    const UnictContract = await DAOUnictFactory.deploy()
    //    await UnictContract.deployed()
    //    const DAOUnict = UnictContract
    //const DAOUnict = await ethers.getContract("DAOUnict")

    const contractAddresses = JSON.parse(
        fs.readFileSync(frontEndContractsFile, "utf8")
    )
    if (network.config.chainId.toString() in contractAddresses) {
        if (
            !contractAddresses[network.config.chainId.toString()].includes(
                DAOUnict.address
            )
        ) {
            contractAddresses[network.config.chainId.toString()].push(
                DAOUnict.address
            )
        }
    } else {
        contractAddresses[network.config.chainId.toString()] = [
            DAOUnict.address,
        ]
    }
    fs.writeFileSync(frontEndContractsFile, JSON.stringify(contractAddresses))
}

module.exports.tags = ["all", "frontend"]
