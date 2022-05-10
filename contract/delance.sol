// SPDX-License-Identifier: MIT
pragma solidity 0.6.4;
pragma experimental ABIEncoderV2;

contract Delance {

    enum Status {COMPLETED, CENCLED, PENDING}
    
    address     payable public  employer;
    address     payable public  freelancer;
    uint256     public          deadline;
    uint256     public          price;
    uint256     public          remainingPayments;
    uint256     public          createdAt;
    Status      public          status;

    struct  Request {
        string  title;
        uint256 amount;
        bool    loked;
        bool    paid;
    }

    Request[]   public  requests;

    event   RequestUnlocked(bool loked);
    event   RequestCreated(string title, uint256 amount, bool locked, bool paid);
    event   RequestPaid(address receiver, uint256 amount);
    event   ProjectCompleted(address employer, address freelancer, uint256 amount, Status status);
    event   ProjectCancled(uint256 remainingPayments, Status status);

    constructor (
        address payable _freelancer, 
        address payable _employer, 
        uint256 _deadline, 
        uint256 _price
        ) public {
        employer = _employer;
        freelancer = _freelancer;
        deadline = _deadline;
        createdAt = now;
        price = _price;
        remainingPayments = _price;
        status = Status.PENDING;
    }

    receive() external payable {
        price += msg.value;
    }

    modifier onlyFreelancer() {
        require(msg.sender == freelancer ,"only freelancer!");
        _;
    }

    modifier onlyEmployer() {
        require(msg.sender == employer, "onlyEmployer");
        _;
    }

    modifier onlyPendingProject() {
        require(status == Status.PENDING, "Only Pending");
        _;
    }

    function getBalance() public returns (uint256){
        return address(this).balance;
    }

    function createRequest(string memory _title, uint256 _amount) public onlyFreelancer {
        Request memory request = Request (
            {
                title: _title,
                amount: _amount,
                loked: true,
                paid: false
            }
        );
        requests.push(request);

        emit RequestCreated(_title, _amount, request.loked, request.paid);
    }

    function getAllRequests() public view returns(Request[] memory) {
        return requests;
    }

    function unlockRequest(uint256 _index) public onlyEmployer {
        Request storage request = requests[_index];
        require(request.loked, "Already unlocked");
        request.loked = false;

        emit RequestUnlocked(request.loked);
    }

    function payRequest(uint256 _index) public onlyEmployer onlyPendingProject {
        Request storage request = requests[_index];
        require(!request.loked,"Request is locked");
        require(!request.paid, "already paid");

        remainingPayments -= request.amount;
        freelancer.transfer(request.amount);
        request.paid = true;
        emit    RequestPaid(msg.sender, request.amount);

    }

    function completeProject() public onlyEmployer onlyPendingProject {
        status = Status.COMPLETED;
        freelancer.transfer(remainingPayments);

        emit ProjectCompleted(employer, freelancer, remainingPayments, status);
    }

    function cancelProject() public onlyEmployer onlyPendingProject {
        require(now > deadline);
        status = Status.CENCLED;
        employer.transfer(remainingPayments);

        emit ProjectCancled(remainingPayments, status);
    }

    function increaseDeadline(uint256 amount) public onlyEmployer onlyPendingProject {
        deadline += amount;
    }

}