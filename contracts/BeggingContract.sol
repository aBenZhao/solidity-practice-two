// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// 讨饭合约
contract BeggingContract is Ownable {
    // 时间限制：添加一个时间限制，只有在特定时间段内才能捐赠。
    uint256 public donationStartTimestamp;
    uint256 public donationEndTimestamp;

    // 一个 mapping 来记录每个捐赠者的捐赠金额。
    mapping(address => uint256) private _donations;

    // 记录所有捐赠者地址（排名）
    address[] private _donors;

    // 构造函数
    constructor()Ownable(msg.sender){
        donationStartTimestamp = block.timestamp;
        donationEndTimestamp = donationStartTimestamp + 3 days;
    }

    // 捐赠事件：添加 Donation 事件，记录每次捐赠的地址和金额。
    event Donation(address indexed donor, uint256 amount,uint256 timestamp); 

    // 提取事件：提取资金时触发的事件
    event Withdraw(address indexed owner,uint256 amount,uint256 timestamp);

    // ================================================================  核心功能  ===================================================================
    // 一个 donate 函数，允许用户向合约发送以太币，并记录捐赠信息。
    function donate() external payable{
        require(block.timestamp >= donationStartTimestamp, unicode"捐赠未开始");
        require(block.timestamp <= donationEndTimestamp, unicode"捐赠已结束");
        require(msg.value > 0 , unicode"捐赠金额必须大于0！");

        if (_donations[msg.sender] == 0){
            _donors.push(msg.sender);
        }

        _donations[msg.sender] += msg.value;
     
        emit Donation(msg.sender,msg.value,block.timestamp);
    }

    // 一个 withdraw 函数，允许合约所有者提取所有资金。
    function withdraw() external onlyOwner {
        // // 校验：合约余额必须大于0
        uint256 balance = address(this).balance;
        require(balance > 0,unicode"合约中没有可提取的资金!");

        // 提取资金：使用transfer向所有者转账
        address owner = owner();
        payable(owner).transfer(balance);

        // 触发提取事件
        emit Withdraw(owner,balance,block.timestamp);
    }


    // 一个 getDonation 函数，允许查询某个地址的捐赠金额。
    function getDonation(address donor) external view returns (uint256) {
        return _donations[donor];
    }

    // 获取当前合约的余额
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // 获取所有捐赠者地址
    function getDonors() external view returns (address[] memory) {
        return _donors;
    }

    // 捐赠排行榜：实现一个功能，显示捐赠金额最多的前 3 个地址。
    function getTopDonors() external view returns (address[] memory,uint256[] memory) {
        uint256[] memory topAmounts = new uint256[](3);
        address[] memory topDonors = new address[](3);

        // 2. 遍历所有捐赠者
        for (uint256 i = 0; i < _donors.length; i++) {
            address donor = _donors[i];
            uint256 amount = _donations[donor];

                // 3. 若当前金额大于第三名，才需要更新排名（优化效率）
                if (amount > topAmounts[2]) {
                    // 3.1 超过第一名：原第一→第二，原第二→第三，新值→第一
                if (amount > topAmounts[0]) {
                    // 后移原第二→第三
                    topAmounts[2] = topAmounts[1];
                    topDonors[2] = topDonors[1];
                    // 后移原第一→第二
                    topAmounts[1] = topAmounts[0];
                    topDonors[1] = topDonors[0];
                    // 新值→第一
                    topAmounts[0] = amount;
                    topDonors[0] = donor;
                }
                // 3.2 超过第二名但不超过第一名：原第二→第三，新值→第二
                else if (amount > topAmounts[1]) {
                    // 后移原第二→第三
                    topAmounts[2] = topAmounts[1];
                    topDonors[2] = topDonors[1];
                    // 新值→第二
                    topAmounts[1] = amount;
                    topDonors[1] = donor;
                }
                // 3.3 超过第三名但不超过前两名：新值→第三
                else {
                    topAmounts[2] = amount;
                    topDonors[2] = donor;
                }
            }

        }

        return (topDonors,topAmounts);
    }


    // 返回剩余可捐赠时间
    function getRemainingTime() external view returns (uint256) {
        if (block.timestamp > donationEndTimestamp) return 0;
        return donationEndTimestamp - block.timestamp;
    }
}