// per run: yarn hardhat run scripts/deploy.js --network nomenetwork (es. hardhat)
// yarn hardhat node per vedere i nodi della fake blockchain fornita da hardhat
// yarn hardhat console --network nomenetwork, yarn hardhat clean se non compila bene o non runna qualcosa per colpa di qualcosa mantenuto in cache
// yarn hardhat test --grep parolechiavedeltest
// yarn hardhat coverage per verificare se i test sviluppati coprono tutte le funzioni del contratto o no

// imports
const { ethers, run, network } = require("hardhat")

// async main
async function main() {
    const DAOUnictFactory = await ethers.getContractFactory("DAOUnict")
    console.log("Deploying contract...")
    const DAOUnict = await DAOUnictFactory.deploy()
    await DAOUnict.deployed()
    console.log(`Deployed contract to: ${DAOUnict.address}`)
    var updateFE = require("./update_frontend.js")
    updateFE(DAOUnict)
    // what happens when we deploy to our hardhat network?
    if (network.config.chainId === 5 && process.env.ETHERSCAN_API_KEY) {
        console.log("Waiting for block confirmations...")
        await DAOUnict.deployTransaction.wait(6)
        await verify(DAOUnict.address, [])
    }
}

// async function verify(contractAddress, args) {
const verify = async (contractAddress, args) => {
    console.log("Verifying contract...")
    try {
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
        })
    } catch (e) {
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("Already Verified!")
        } else {
            console.log(e)
        }
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
