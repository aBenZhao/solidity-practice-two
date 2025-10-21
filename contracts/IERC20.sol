// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// 定义ERC20代币的核心功能
interface IERC20 {
    // 转账事件：记录转账操作
    event Transfer(address indexed  from,address indexed to ,uint256 value);

    // 授权时间：记录授权操作
    event Approval(address indexed  owner,address indexed  spender, uint256 value);

    // 返回代币总供应量
    function totalSupply() external  view returns(uint256);

    // 返回指定账户的代币余额
    function balanceOf(address account) external view returns (uint256);

    // 从调用者地址向to地址转账amount数量的代币
    function transfer(address to,uint256 amount) external returns (bool);

    // 允许spender从调用者地址花费amount数量的代币
    function approve(address spender,uint256 amount) external returns (bool);

    // 返回spender从owner地址可花费的代币额度
    function allowance(address owner,address spender) external view returns (uint256);

    // 从from地址向to地址转账amount数量的代币（需要提前授权）
    function transferFrom(address from,address to,uint256 amount)external returns(bool);
}
