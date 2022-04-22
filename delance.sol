// SPDX-License-Identifier: MIT
pragma solidity 0.6.4;
pragma experimental ABIEncoderV2;

contract Delance {
    address public employer;
    address public freelancer;
    uint public deadline;
    uint public price;

    struct Request {
        string title;
        uint256 amount;
        bool loked;
        bool paid;
    }

    Request[] public requests;

    constructor (address _freelancer, uint _deadline) public payable {
        employer = msg.sender;
        freelancer = _freelancer;
        deadline = _deadline;
        price = msg.value;
    }
    receive() external payable {
        price += msg.value;
    }

    modifier onlyFreelancer() {
        require(msg.sender == freelancer ,"only freelancer!");
        _;
    }

    function createRequest(string memory _title, uint256 _amount) public {
        Request memory request = Request (
            {
                title: _title,
                amount: _amount,
                loked: true,
                paid:false
            }
        );
        requests.push(request);
    }
    function getAllRequests() public view returns(Request[] memory) {
        return requests;
    }
}
