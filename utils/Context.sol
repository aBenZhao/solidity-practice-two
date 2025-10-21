// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// 封装交易执行上下文，提供标准化的调用者地址和交易数据访问方式
abstract contract Context{
    // 返回当前逻辑调用者地址
    function _msgSender() internal  view  virtual returns (address) {
        return msg.sender;
    }

    // 返回当前交易的完整数据
    function _msgData() internal view virtual returns (bytes calldata){
        return msg.data;
    }
    
}