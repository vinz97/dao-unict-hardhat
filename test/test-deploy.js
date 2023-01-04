const { ethers } = require("hardhat")
const { expect, assert } = require("chai")

// describe("SimpleStorage", () => {})
describe("DAOUnict", function () {
    let DAOUnictFactory, DAOUnict
    beforeEach(async function () {
        // const [owner, addr1, addr2] = await ethers.getSigners()
        DAOUnictFactory = await ethers.getContractFactory("DAOUnict")
        DAOUnict = await DAOUnictFactory.deploy()
    })

    it("Check existing teacher after add it", async function () {
        const transactionResponse = await DAOUnict.addProfessor(
            "Giuseppe",
            "Ascia",
            "Professore associato",
            "3 Polifunzionale V piano stanza 14",
            "giuseppe.ascia@unict.it",
            "0957382353",
            "utenti.dieei.unict.it/users/gascia/",
            "0xd1c3217ddede2a03c541124077ac87aed734cdac"
        )
        await transactionResponse.wait()

        const newProfessor = await DAOUnict.checkExistingProfessor(
            "0xd1c3217ddede2a03c541124077ac87aed734cdac"
        )
        // console.log(newProfessor[0])
        assert.equal(newProfessor, true)
    })

    it("Check existing secratariat after add it", async function () {
        const transactionResponse = await DAOUnict.addSecretary(
            "Francesco Asero",
            "ingegneria",
            "via del rosario 11 piano terra",
            "francesco.dasero@unict.it",
            "0957382051",
            "0xC94AcAa6699135D84D9d4d1a55CC093E4E160129"
        )
        await transactionResponse.wait()

        const newSecratariat = await DAOUnict.checkExistingSecretariat(
            "0xC94AcAa6699135D84D9d4d1a55CC093E4E160129"
        )
        assert.equal(newSecratariat, true)
    })

    it("Check if a degree course exist after add it and then delete it", async function () {
        const transactionResponse = await DAOUnict.addDegreeCourse("LM32")
        await transactionResponse.wait()
        console.log(
            `Response of the add degree course function: ${DAOUnict.checkDegreeCourse(
                "LM32"
            )}`
        )
        const transactionResponse1 = await DAOUnict.deleteDegreeCourse("LM32")
        await transactionResponse1.wait()

        const check = await DAOUnict.checkDegreeCourse("LM32")
        assert.equal(check, false)
    })

    it("Check if a subject exist after add it into a course and then delete it", async function () {
        const transactionResponse = await DAOUnict.addDegreeCourse("LM32")
        await transactionResponse.wait()

        const transactionResponse2 = await DAOUnict.addProfessor(
            "Giuseppe",
            "Ascia",
            "Professore associato",
            "3 Polifunzionale V piano stanza 14",
            "giuseppe.ascia@unict.it",
            "0957382353",
            "utenti.dieei.unict.it/users/gascia/",
            "0xd1c3217ddede2a03c541124077ac87aed734cdac"
        )
        await transactionResponse2.wait()

        const transactionResponse1 = await DAOUnict.addSubjectToCourse(
            "LM32",
            "ACA",
            "6",
            "200",
            "0xd1c3217ddede2a03c541124077ac87aed734cdac",
            "9"
        )
        await transactionResponse1.wait()
        console.log(
            `Response of the add subject into course function: ${DAOUnict.checkSubjectIntoCourse(
                "LM32",
                "9"
            )}`
        )

        const transactionResponse3 = await DAOUnict.deleteSubjectFromCourse(
            "LM32",
            "9"
        )
        await transactionResponse3.wait()

        const check = await DAOUnict.checkSubjectIntoCourse("LM32", "9")
        assert.equal(check, false)
    })

    it("Check if a student exist after add it (function only for secretariat)", async function () {
        const [addr1] = await ethers.getSigners()

        const transactionResponse_ = await DAOUnict.addSecretary(
            "Francesco Asero",
            "ingegneria",
            "via del rosario 11 piano terra",
            "francesco.dasero@unict.it",
            "0957382051",
            addr1.address
        )
        await transactionResponse_.wait()

        const transactionResponse2 = await DAOUnict.addDegreeCourse("LM32")
        await transactionResponse2.wait()

        const transactionResponse = await DAOUnict.connect(addr1).addStudent(
            "Vincenzo",
            "Pluchino",
            "LM32",
            "nicus@live.it",
            "3394235768",
            "0x573E55b86117cb258C5c4aa4305CAd81AF05F845"
        )
        await transactionResponse.wait()

        const newStudent = await DAOUnict.checkExistingStudent(
            "0x573E55b86117cb258C5c4aa4305CAd81AF05F845"
        )
        assert.equal(newStudent, true)
    })

    it("Modify a subject already submitted on a course (secretariat only)", async function () {
        const [addr1] = await ethers.getSigners()

        const transactionResponse = await DAOUnict.addDegreeCourse("LM32")
        await transactionResponse.wait()

        const transactionResponse2 = await DAOUnict.addProfessor(
            "Giuseppe",
            "Ascia",
            "Professore associato",
            "3 Polifunzionale V piano stanza 14",
            "giuseppe.ascia@unict.it",
            "0957382353",
            "utenti.dieei.unict.it/users/gascia/",
            "0xd1c3217ddede2a03c541124077ac87aed734cdac"
        )
        await transactionResponse2.wait()

        const transactionResponse1 = await DAOUnict.addSubjectToCourse(
            "LM32",
            "ACA",
            "6",
            "200",
            "0xd1c3217ddede2a03c541124077ac87aed734cdac",
            "9"
        )
        await transactionResponse1.wait()

        const transactionResponse_ = await DAOUnict.addSecretary(
            "Francesco Asero",
            "ingegneria",
            "via del rosario 11 piano terra",
            "francesco.dasero@unict.it",
            "0957382051",
            addr1.address
        )
        await transactionResponse_.wait()

        const transactionResponse3 = await DAOUnict.connect(addr1).modifyCFU(
            "LM32",
            "9",
            "10"
        )
        await transactionResponse3.wait()

        const modifiedSubject = await DAOUnict.infoSubject("LM32", "9")
        assert.equal(modifiedSubject[1], "10")
    })

    it("Register an exam and verify the registration and the professor's token (teacher only)", async function () {
        const [addr1, addr2] = await ethers.getSigners()

        const transactionResponse = await DAOUnict.addDegreeCourse("LM32")
        await transactionResponse.wait()

        const transactionResponse2 = await DAOUnict.addProfessor(
            "Giuseppe",
            "Ascia",
            "Professore associato",
            "3 Polifunzionale V piano stanza 14",
            "giuseppe.ascia@unict.it",
            "0957382353",
            "utenti.dieei.unict.it/users/gascia/",
            addr2.address
        )
        await transactionResponse2.wait()

        const transactionResponse1 = await DAOUnict.addSubjectToCourse(
            "LM32",
            "ACA",
            "6",
            "200",
            addr2.address,
            "9"
        )
        await transactionResponse1.wait()

        const transactionResponse_ = await DAOUnict.addSecretary(
            "Francesco Asero",
            "ingegneria",
            "via del rosario 11 piano terra",
            "francesco.dasero@unict.it",
            "0957382051",
            addr1.address
        )
        await transactionResponse_.wait()

        const transactionResponse3 = await DAOUnict.connect(addr1).addStudent(
            "Vincenzo",
            "Pluchino",
            "LM32",
            "nicus@live.it",
            "3394235768",
            "0x573E55b86117cb258C5c4aa4305CAd81AF05F845"
        )
        await transactionResponse3.wait()

        const examRegistration = await DAOUnict.connect(
            addr2
        ).callStatic.registerExam(
            "0x573E55b86117cb258C5c4aa4305CAd81AF05F845",
            "LM32",
            "9",
            "19 dec",
            "30"
        )
        //await examRegistration.wait()

        console.log(examRegistration[1])
        assert.equal(examRegistration[1], "30")
        console.log("First assert checked!")

        await DAOUnict.connect(addr2).registerExam(
            "0x573E55b86117cb258C5c4aa4305CAd81AF05F845",
            "LM32",
            "9",
            "19 dec",
            "30"
        )

        const tokenLeft = await DAOUnict.connect(
            addr2
        ).checkAvailableTokenPerProfessor(addr2.address)
        assert.equal(tokenLeft, "994")
    })

    it("Booking to an exam and verify that booking (student and professor only", async function () {
        const [addr1, addr2, addr3] = await ethers.getSigners()

        const transactionResponse = await DAOUnict.addDegreeCourse("LM32")
        await transactionResponse.wait()

        const transactionResponse2 = await DAOUnict.addProfessor(
            "Giuseppe",
            "Ascia",
            "Professore associato",
            "3 Polifunzionale V piano stanza 14",
            "giuseppe.ascia@unict.it",
            "0957382353",
            "utenti.dieei.unict.it/users/gascia/",
            addr2.address
        )
        await transactionResponse2.wait()

        const transactionResponse1 = await DAOUnict.addSubjectToCourse(
            "LM32",
            "ACA",
            "6",
            "200",
            addr2.address,
            "9"
        )
        await transactionResponse1.wait()

        const transactionResponse_ = await DAOUnict.addSecretary(
            "Francesco Asero",
            "ingegneria",
            "via del rosario 11 piano terra",
            "francesco.dasero@unict.it",
            "0957382051",
            addr1.address
        )
        await transactionResponse_.wait()

        const transactionResponse3 = await DAOUnict.connect(addr1).addStudent(
            "Vincenzo",
            "Pluchino",
            "LM32",
            "nicus@live.it",
            "3394235768",
            addr3.address
        )
        await transactionResponse3.wait()

        const bookingNumber = await DAOUnict.connect(
            addr3
        ).callStatic.registerToExam("19 dec", "9")
        // await bookingNumber.wait()

        console.log(bookingNumber)

        const realTransaction = await DAOUnict.connect(addr3).registerToExam(
            "19 dec",
            "9"
        )
        await realTransaction.wait()

        const verifyBooking = await DAOUnict.connect(
            addr2
        ).checkStudentExamBooking(bookingNumber)
        assert(verifyBooking[2], "19 dec")
        /*
        console.log(
            await DAOUnict.connect(addr3).callStatic.registerToExam(
                "20 dec",
                "9"
            )
        ) */
    })

    /*
    it("Should start with a favorite number of 0", async function () {
        const currentValue = await simpleStorage.retrieve()
        const expectedValue = "0"
        // assert
        // expect
        assert.equal(currentValue.toString(), expectedValue)
        // expect(currentValue.toString()).to.equal(expectedValue)
    }) */
})
