// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

import "./DegreeCourse.sol";
import {sharedObjects, structSubject} from "./CommonLibrary.sol";
import "./TokenUnict.sol";
import "./NftUnict.sol";

contract DAOUnict {
    address private immutable i_admin_address;
    TokenUnict private immutable i_uniToken;
    NftUnict private immutable i_uniNft;
    uint256 private constant INITIAL_TOKEN_AMOUNT = 10000000;
    uint256 private constant INITIAL_TEACHER_TOKEN = 1000;
    uint8 private codeBookingForExam;

    mapping(string => DegreeCourse) public unictDegreeCourses; // example: "LM32" is the identifier for the course degree "ing.inf.magistrale"

    mapping(address => sharedObjects.Professor) public unictProfessors; // professors, students and secretariats will be recognized by associated public key

    mapping(address => sharedObjects.Secretariat) public unictSecretariats;

    mapping(address => sharedObjects.Student) public unictStudents;

    mapping(uint8 => sharedObjects.ExamBooking) public examBookings;

    mapping(address => string) public unictGraduateStudents;

    constructor() {
        i_admin_address = msg.sender;
        i_uniToken = new TokenUnict(
            INITIAL_TOKEN_AMOUNT,
            "Token UNICT",
            "UNICT",
            msg.sender
        );
        i_uniNft = new NftUnict();
    }

    // adding/delete degree courses
    function addDegreeCourse(string memory courseId) public onlyAdmin {
        unictDegreeCourses[courseId] = new DegreeCourse();
    }

    function deleteDegreeCourse(string memory courseId) public onlyAdmin {
        require(
            checkDegreeCourse(courseId) == true,
            "The identifier of this course was not found"
        );
        delete unictDegreeCourses[courseId];
    }

    // checking degree course
    function checkDegreeCourse(
        string memory courseId
    ) public view returns (bool) {
        address checkingDegreeCourse = address(unictDegreeCourses[courseId]);
        if (checkingDegreeCourse != address(0x0)) {
            return true;
        } else {
            return false;
        }
    }

    // adding or delete subject to some courses
    function addSubjectToCourse(
        string memory courseId,
        string memory _name,
        int _cfu,
        int _didacticHours,
        address _teacherAddress,
        int code
    ) public onlyAdmin {
        bool checkTeacher = checkExistingProfessor(_teacherAddress);
        require(
            checkTeacher == true,
            "The address of this teacher was not found!"
        );
        require(
            checkDegreeCourse(courseId) == true,
            "The identifier of this course was not found"
        );
        unictDegreeCourses[courseId].addSubject(
            _name,
            _cfu,
            _didacticHours,
            _teacherAddress,
            code
        );
    }

    function deleteSubjectFromCourse(
        string memory courseId,
        int code
    ) public onlyAdmin {
        require(
            checkDegreeCourse(courseId) == true,
            "The identifier of this course was not found"
        );
        unictDegreeCourses[courseId].deleteSubject(code);
    }

    // control functions for the subjects
    function checkSubjectIntoCourse(
        string memory courseId,
        int code
    ) public view returns (bool) {
        require(
            checkDegreeCourse(courseId) == true,
            "The identifier of this course was not found"
        );
        return unictDegreeCourses[courseId].checkSubject(code);
    }

    function infoSubject(
        string memory courseId,
        int code
    ) public view returns (structSubject.Subject memory) {
        require(
            checkDegreeCourse(courseId) == true,
            "The identifier of this course was not found"
        );
        return unictDegreeCourses[courseId].infoExistingSubject(code);
    }

    // editing subjects already submitted (available only for secretary)
    function modifyCFU(
        string memory courseId,
        int code,
        int newCFU
    ) public onlySecretariat {
        require(
            checkDegreeCourse(courseId) == true,
            "The identifier of this course was not found"
        );
        unictDegreeCourses[courseId].editCfuSubject(code, newCFU);
    }

    function modifyTeacher(
        string memory courseId,
        int code,
        address newProfessorAddr
    ) public onlySecretariat {
        require(
            checkDegreeCourse(courseId) == true,
            "The identifier of this course was not found"
        );
        unictDegreeCourses[courseId].editProfessorAddress(
            code,
            newProfessorAddr
        );
    }

    function associateDegreeNft(
        string memory urlNft,
        address studentAddr
    ) public onlySecretariat {
        require(
            checkExistingStudent(studentAddr) == true,
            "The address of this student was not found!"
        );
        // future requirement: the degree nft can be associated only if the student has all
        // the tokens acquireable in his degree course
        i_uniNft.mintNft(urlNft, studentAddr);
        unictGraduateStudents[studentAddr] = urlNft;
    }

    // adding teacher to Unict
    function addProfessor(
        string memory _name,
        string memory _surname,
        string memory _role,
        string memory _office,
        string memory _email,
        int _telephone,
        string memory _website,
        address pubKey
    ) public onlyAdmin {
        unictProfessors[pubKey] = sharedObjects.Professor(
            _name,
            _surname,
            _role,
            _office,
            _email,
            _telephone,
            _website
        );
        bool giveTokens = i_uniToken.approve(
            pubKey,
            INITIAL_TEACHER_TOKEN,
            i_admin_address
        );
        require(
            giveTokens == true,
            "Error in the assignments of the tokens for the prof"
        );
    }

    // control functions for teachers
    function checkExistingProfessor(
        address PubKeyProf
    ) public view returns (bool) {
        bytes memory checkTeacher = bytes(unictProfessors[PubKeyProf].email);
        if (checkTeacher.length != 0) {
            return true;
        } else {
            return false;
        }
    }

    function infoExistingProfessor(
        address PubKeyProf
    ) public view returns (sharedObjects.Professor memory) {
        bytes memory checkTeacher = bytes(unictProfessors[PubKeyProf].email);
        require(
            checkTeacher.length != 0,
            "The address of this teacher was not found!"
        );
        return unictProfessors[PubKeyProf];
    }

    // register an exam for a student
    function registerExam(
        address studAddr,
        string memory courseId,
        int codeSubject,
        string memory date,
        int grade
    ) public onlyTeacher returns (sharedObjects.ExamRegistration memory) {
        // check 1: student registered to Unict
        require(
            checkExistingStudent(studAddr) == true,
            "The address of this student was not found!"
        );
        // check 2: student registered to the degree course containing the subject
        sharedObjects.Student memory stud = infoExistingStudent(studAddr);
        bool checkCourse = compare(stud.courseSubscribed, courseId);
        require(
            checkCourse == true,
            "The student is not subscribed in this course"
        );
        // check 3: student already registered the exam
        require(
            i_uniToken.checkSubjectAlreadyRegistered(studAddr, codeSubject) ==
                false,
            "The student already registered this subject"
        );

        structSubject.Subject memory subj = infoSubject(courseId, codeSubject);
        require(
            subj.cfu != 0,
            "Error: code subject not found for this degree course!"
        );
        uint256 _cfu = uint256(subj.cfu);
        i_uniToken.transferFrom(
            i_admin_address,
            studAddr,
            _cfu,
            msg.sender,
            codeSubject
        );
        return sharedObjects.ExamRegistration(date, grade, codeSubject);
    }

    // checking the students' exam bookings
    function checkStudentExamBooking(
        uint8 bookingCode
    ) public view onlyTeacher returns (sharedObjects.ExamBooking memory) {
        require(
            examBookings[bookingCode].codeSubject != 0,
            "This code doesn't belong to any exam booking"
        );
        return examBookings[bookingCode];
    }

    // adding secretariat
    function addSecretary(
        string memory _personInCharge,
        string memory _area,
        string memory _office,
        string memory _email,
        int _telephone,
        address pubKey
    ) public onlyAdmin {
        unictSecretariats[pubKey] = sharedObjects.Secretariat(
            _personInCharge,
            _area,
            _office,
            _email,
            _telephone
        );
    }

    // control functions for secretariats
    function checkExistingSecretariat(
        address PubKeySecretary
    ) public view returns (bool) {
        bytes memory checkSecretary = bytes(
            unictSecretariats[PubKeySecretary].email
        );
        if (checkSecretary.length != 0) {
            return true;
        } else {
            return false;
        }
    }

    function infoExistingSecretariat(
        address PubKeySecretary
    ) public view returns (sharedObjects.Secretariat memory) {
        bytes memory checkSecretary = bytes(
            unictSecretariats[PubKeySecretary].email
        );
        require(
            checkSecretary.length != 0,
            "The address of this secretariat was not found!"
        );
        return unictSecretariats[PubKeySecretary];
    }

    // adding a student
    function addStudent(
        string memory _name,
        string memory _surname,
        string memory _courseSubscribed,
        string memory _email,
        int telephone,
        address pubKey
    ) public onlySecretariat {
        require(
            checkDegreeCourse(_courseSubscribed),
            "The identifier of this course was not found"
        );
        unictStudents[pubKey] = sharedObjects.Student(
            _name,
            _surname,
            _courseSubscribed,
            _email,
            telephone
        );
    }

    // control functions for students
    function infoExistingStudent(
        address PubKeyStudent
    ) public view returns (sharedObjects.Student memory) {
        bytes memory checkStudent = bytes(unictStudents[PubKeyStudent].email);
        require(
            checkStudent.length != 0,
            "The address of this student was not found!"
        );
        return unictStudents[PubKeyStudent];
    }

    function checkExistingStudent(
        address PubKeyStudent
    ) public view returns (bool) {
        bytes memory checkStudent = bytes(unictStudents[PubKeyStudent].email);
        if (checkStudent.length != 0) {
            return true;
        } else {
            return false;
        }
    }

    function checkGraduateStudent(
        address pubKeyStudent
    ) public view returns (bool) {
        bytes memory checkUrl = bytes(unictGraduateStudents[pubKeyStudent]);
        if (checkUrl.length != 0) {
            return true;
        } else {
            return false;
        }
    }

    // booking to an exam
    function registerToExam(
        string memory date,
        int codeSubject
    ) public onlyStudent {
        sharedObjects.Student memory stud = infoExistingStudent(msg.sender);
        require(
            checkSubjectIntoCourse(stud.courseSubscribed, codeSubject) == true,
            "Error: code subject not found for your degree course!"
        );
        codeBookingForExam++; // simulate a code that is an identifier for the bookings
        examBookings[codeBookingForExam] = sharedObjects.ExamBooking(
            msg.sender,
            codeSubject,
            date
        );
    }

    function getCodeBookingForExam() public view returns (uint8) {
        return codeBookingForExam; // the student must keep this code because the professor can check the booking with this
    }

    // check cfu acquired and subject already done
    function checkCfuAcquired() public view onlyStudent returns (uint256) {
        return checkTokenBalance(msg.sender);
    }

    function checkSubjectsDone()
        public
        view
        onlyStudent
        returns (int[] memory)
    {
        return i_uniToken.infoSubectAlreadyRegistered(msg.sender);
    }

    function getDegreeCertificateNft(
        address studAddr
    ) public view returns (string memory) {
        require(
            checkGraduateStudent(studAddr) == true,
            "This address doesn't belong to a graduate student"
        );
        return unictGraduateStudents[studAddr];
    }

    modifier onlyAdmin() {
        require(
            i_admin_address == msg.sender,
            "Function available only for admin"
        );
        _;
    }
    modifier onlySecretariat() {
        require(
            checkExistingSecretariat(msg.sender) == true,
            "Function available only for the secretariat"
        );
        _;
    }
    modifier onlyTeacher() {
        require(
            checkExistingProfessor(msg.sender) == true,
            "Function available only for the professors"
        );
        _;
    }
    modifier onlyStudent() {
        require(
            checkExistingStudent(msg.sender) == true,
            "Function available only for the students"
        );
        _;
    }

    // comparing strings
    function compare(
        string memory str1,
        string memory str2
    ) private pure returns (bool) {
        if (bytes(str1).length != bytes(str2).length) {
            return false;
        }
        return
            keccak256(abi.encodePacked(str1)) ==
            keccak256(abi.encodePacked(str2));
    }

    function checkAdmin(address addr) public view returns (bool) {
        if (addr == i_admin_address) {
            return true;
        } else {
            return false;
        }
    }

    // utility functions about ERC20 token
    function checkAvailableTokenPerProfessor(
        address pubKeyProf
    ) public view onlyTeacher returns (uint256) {
        return i_uniToken.allowance(i_admin_address, pubKeyProf);
    }

    function checkTokenBalance(address addr) public view returns (uint256) {
        return i_uniToken.balanceOf(addr);
    }
}
