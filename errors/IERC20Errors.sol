// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IERC20Errors {
    // 转账时发送至余额不足
    error ERC20InsufficientBalance(address sender,uint256 balance,uint256 needed);

    // 发送者地址无效（如零地址）
    error ERC20InvalidSender(address sender);

    // 接受者地址无效（如零地址）
    error ERC20InvalidReceiver(address receiver);

    // 被授权者的授权额度不足
    error ERC20InsufficientAllowance(address spender,uint256 allowance,uint256 needed);

    // 授权者地址无效（如零地址）
    error ERC20InvalidApprover(address approver);

    // 被授权者地址无效（如零地址）
    error ERC20InvalidSpender(address spender);
    
}