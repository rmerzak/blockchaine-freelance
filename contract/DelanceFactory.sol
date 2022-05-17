// SPDX-License-Identifier: MIT
pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

import "./Delace.sol";

contract DelanceFactory {
    struct Project {
        address employer;
        address freelancer;
        uint256 deadline;
        uint256 price;
    }

    Project[] public deployedProjects;

    mapping(address => Project[]) public employerProjects;
    mapping(address => Project[]) public freelancerProjects;

    function addEmployerProjects(address _employerAddr, Project memory _project) internal {
        employerProjects[_employerAddr].push(_project);
    }

    function addFreelancerProjects(address _freelance,Project memory _project) internal {
        freelancerProjects[_freelance].push(_project);
    }

    function getEmployerProjects(address _employerAddr) public view returns (Project[] memory) {
        return (employerProjects[_employerAddr]);
    }

    function getFreelancerProjects(address _freelancerAddr) public view returns (Project[] memory) {
        return (freelancerProjects[_freelancerAddr]);
    }

    function createProject(address payable _freelance , uint256 _deadline) public payable {
        require(msg.value > 0, "Low price");
        Project memory project;
        project = Project (
            msg.sender,
            _freelance,
            _deadline,
            msg.value
        );
        deployedProjects.push(project);
        addEmployerProjects(msg.sender, project);
        addFreelancerProjects(_freelance, project);

    // this part is not complete //    
     /*   address payable receiver = payable(project.employer);
        receiver.transfer(msg.value);*/

    }

    function getDeployedProject() public view returns (Project[] memory) {
        return deployedProjects;
    }
}