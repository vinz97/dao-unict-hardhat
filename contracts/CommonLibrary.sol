// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

library sharedObjects {
    struct Professor {
        string name;
        string surname;
        string role; // ex. Associate Professor of Information Processing Systems
        string office;
        string email;
        int telephone;
        string website;
    }

    struct Secretariat {
        string personInCharge; // responsible
        string area;
        string office;
        string email;
        int telephone;
    }

    struct Student {
        string name;
        string surname;
        string courseSubscribed; // expressed as identifier like "LM32" and not like "ing. inf."
        string email;
        int telephone;
    }

    struct ExamRegistration {
        string date;
        int grade;
        int codeSub;
    }

    struct ExamBooking {
        address studentAddress;
        int codeSubject;
        string date;
    }
}

library SafeMath {
    // Only relevant functions
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

library structSubject {
    struct Subject {
        string name;
        int cfu;
        int didacticHours;
        address teacherAddress;
    }
}
