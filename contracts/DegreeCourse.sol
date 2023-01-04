// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

import {structSubject} from "./CommonLibrary.sol";

contract DegreeCourse {
    mapping(int => structSubject.Subject) private studyPlan;

    function addSubject(
        string calldata _name,
        int _cfu,
        int _didacticHours,
        address _teacherAddress,
        int code
    ) public {
        studyPlan[code] = structSubject.Subject(
            _name,
            _cfu,
            _didacticHours,
            _teacherAddress
        );
    }

    function deleteSubject(int code) public {
        require(
            checkSubject(code) == true,
            "Cannot delete the subjects with this code: it was not found on the study plan"
        );
        delete studyPlan[code];
    }

    // check if the subject is already in the study plan
    function checkSubject(int code) public view returns (bool) {
        int checkCfuSubject = studyPlan[code].cfu;
        if (checkCfuSubject != 0) {
            return true;
        } else {
            return false;
        }
    }

    function infoExistingSubject(
        int code
    ) public view returns (structSubject.Subject memory) {
        int checkCfuSubject = studyPlan[code].cfu;
        require(
            checkCfuSubject != 0,
            "This course degree has not this subject's code"
        );
        return studyPlan[code];
    }

    // list of functions for editing a subject already submitted
    function editCfuSubject(int code, int newCfu) public {
        require(
            checkSubject(code) == true,
            "Cannot edit the subject with this code: it was not found on the study plan"
        );
        studyPlan[code].cfu = newCfu;
    }

    function editProfessorAddress(int code, address newProfAddr) public {
        require(
            checkSubject(code) == true,
            "Cannot edit the subject with this code: it was not found on the study plan"
        );
        studyPlan[code].teacherAddress = newProfAddr;
    }
}
