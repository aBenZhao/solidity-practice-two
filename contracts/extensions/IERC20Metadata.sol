// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IERC20} from "../IERC20.sol";
// 元数据扩展接口，用于提供代币展示信息
interface  IERC20Metadata is IERC20 {

    // 代币名称
    function name() external view returns (string memory);

    // 代币符号（如”MTK“）
    function symbol() external  view returns (string memory);

    // 代币单位换算小数位数（通常为18）
    function decimals() external view returns (uint8);
    
}