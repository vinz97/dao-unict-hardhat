// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

import {SafeMath} from "./CommonLibrary.sol";

contract TokenUnict {
    struct codeRegistered {
        address student;
        int codeSubject;
    }

    using SafeMath for uint256; //using this library for prevent overflow attacks

    string name;
    string symbol;
    uint256 totalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    codeRegistered[] codeRegisters;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This generates a public event on the blockchain that will notify clients
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    // // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    constructor(
        uint256 total,
        string memory tokenName,
        string memory tokenSymbol,
        address tokenOwner
    ) {
        totalSupply = total;
        balances[tokenOwner] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
    }

    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return balances[tokenOwner];
    }

    function allowance(
        address owner,
        address delegate
    ) public view returns (uint256) {
        return allowed[owner][delegate];
    }

    // transfer token from the balance of the contract owner to another address
    function transfer(
        address receiver,
        uint256 numTokens,
        address tokenOwner
    ) public returns (bool) {
        require(receiver != address(0x0)); // Prevent transfer to 0x0 address. Use burn() instead
        require(numTokens <= balances[tokenOwner]); // check if has a sufficient balance to execute the transfer
        uint256 previousBalances = balances[tokenOwner] + balanceOf(receiver); // var for the next asserts
        balances[tokenOwner] = balances[tokenOwner].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(tokenOwner, receiver, numTokens);
        assert(balances[tokenOwner] + balances[receiver] == previousBalances); // this should never fail
        return true;
    }

    // allow an owner (msg.sender) to approve a delegate account to withdraw tokens from his account and to transfer them to other accounts.
    function approve(
        address delegate,
        uint256 numTokens,
        address tokenOwner
    ) public returns (bool) {
        allowed[tokenOwner][delegate] = numTokens;
        emit Approval(tokenOwner, delegate, numTokens);
        return true;
    }

    // allows a delegate approved for withdrawal to transfer owner funds to a third account.
    function transferFrom(
        address owner,
        address receiver,
        uint256 numTokens,
        address delegate,
        int codeSubject
    ) public returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][delegate]);
        uint256 previousBalances = balances[owner] + balanceOf(receiver); // var for the next asserts

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][delegate] = allowed[owner][delegate].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(owner, receiver, numTokens);
        assert(balances[owner] + balances[receiver] == previousBalances); // this should never fail
        codeRegisters.push(codeRegistered(receiver, codeSubject));
        return true;
    }

    // Destroy tokens
    function burn(
        uint256 _value,
        address tokenOwner
    ) public returns (bool success) {
        require(balances[tokenOwner] >= _value); // Check if the sender has enough
        balances[tokenOwner] = balances[tokenOwner].sub(_value); // Subtract from the sender
        totalSupply = totalSupply.sub(_value); // Updates totalSupply
        emit Burn(tokenOwner, _value);
        return true;
    }

    function checkSubjectAlreadyRegistered(
        address studAddr,
        int codeSub
    ) public view returns (bool) {
        for (uint256 i = 0; i < codeRegisters.length; i++) {
            if (
                codeRegisters[i].student == studAddr &&
                codeRegisters[i].codeSubject == codeSub
            ) {
                return true;
            }
        }
        return false;
    }

    function infoSubectAlreadyRegistered(
        address studAddr
    ) public view returns (int[] memory) {
        int[] memory arrCode = new int[](codeRegisters.length);
        for (uint256 i = 0; i < codeRegisters.length; i++) {
            if (codeRegisters[i].student == studAddr) {
                arrCode[i] = codeRegisters[i].codeSubject;
            }
        }
        return arrCode;
    }
}
