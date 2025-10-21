// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Context} from"../utils/Context.sol";
import {IERC20} from "./IERC20.sol";
import {IERC20Metadata} from "./extensions/IERC20Metadata.sol";
import {IERC20Errors} from "../errors/IERC20Errors.sol";


contract MyStandardERC20 is Context,IERC20,IERC20Metadata, IERC20Errors{
    // 代币元数据存储（私有变量，通过接口函数暴露）
    string private _name;       // 代币名称
    string private _symbol;     // 代币符号
    uint8 private _decimals;    // 小数位数


    // 核心数据存储
    uint256 private _totalSupply;                           // 总供应量（最小单位）
    mapping(address => uint256) private _balances;          // 账户余额映射：地址 => 余额
    mapping(address => mapping(address => uint256)) private _allowances;  // 授权映射：所有者 => 被授权者 => 额度


   // 权限控制
    address private _owner;     // 合约所有者地址（拥有增发权限）


    constructor(string memory name_,string memory symbol_,uint8 decimals_,uint256 initialSupply_) {
        // 初始化元数据
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;

        // 通过Context的_msgSender()获取部署者地址，设置为所有者
        _owner = _msgSender();

        // 计算初始供应的最小单位数量：初始供应 * 10^小数位数
        uint256 initialSupplyWithDecimals = initialSupply_ * (10 **uint256(decimals_));

        // 分配初始供应给部署者
        _totalSupply = initialSupplyWithDecimals;
        _balances[_msgSender()] = initialSupplyWithDecimals;

        // 触发初始转账事件（从0地址到部署者，代表代币发行）
        emit Transfer(address(0),_msgSender(), initialSupplyWithDecimals);
    }

        /**
     * @dev 权限修饰器：限制仅合约所有者可调用
     * 用于保护敏感操作（如增发代币）
     */
    modifier onlyOwner() {
        // 验证调用者是否为所有者（使用_msgSender()确保上下文兼容性）
        require(_msgSender() == _owner, unicode"MyStandardERC20: 仅所有者可执行此操作");
        _; // 执行被修饰的函数体
    }

    // 增发代币功能（仅所有者可调用）
    function mint(address to, uint256 amount) public onlyOwner {
        // 验证接收地址有效
        if (to == address(0)) revert ERC20InvalidReceiver(to);
        // 验证增发数量大于0
        if (amount == 0) revert(unicode"MyStandardERC20: 增发数量必须大于0");

        // 增加总供应量
        _totalSupply += amount;
        // 增加接收地址余额（使用unchecked优化Gas）
        unchecked {
            _balances[to] += amount;
        }

        // 触发转账事件（从0地址到接收地址，代表新代币发行）
        emit Transfer(address(0), to, amount);
    }



    // 代币名称
    function name() public view returns (string memory){
        return _name;
    }

    // 代币符号（如”MTK“）
    function symbol() public  view returns (string memory){
        return _symbol;
    }

    // 代币单位换算小数位数（通常为18）
    function decimals() public view returns (uint8){
        return _decimals;
    }


    // 返回代币总供应量
    function totalSupply() public view override returns(uint256){
        return _totalSupply;
    }

    // 返回指定账户的代币余额
    function balanceOf(address account) public view override returns (uint256){
        return _balances[account];
    }

    // 从调用者地址向to地址转账amount数量的代币
    function transfer(address to,uint256 amount) external override returns (bool){
        address sender = _msgSender();
        _transfer(sender,to,amount);
        return true;
    }

    // 允许spender从调用者地址花费amount数量的代币
    function approve(address spender,uint256 amount) external override returns (bool){
        address owner = _msgSender();
        _approve(owner,spender,amount);
        return true;
    }

    // 返回spender从owner地址可花费的代币额度
    function allowance(address owner,address spender) external view override returns (uint256){
        return _allowances[owner][spender];
    }

    // 从from地址向to地址转账amount数量的代币（需要提前授权:使用授权额度从指定地址转账）
    function transferFrom(address from,address to,uint256 amount)external override returns(bool){
        address spender = _msgSender();
        _spendAllowance(from,spender,amount);// 扣减授权额度
        _transfer(from,to,amount); // 执行转账
        return true;
    }
    

    // 内部转账逻辑（使用IERC20Errors自定义错误）
    function _transfer(address from,address to,uint256 amount)internal {
        // 验证发送者地址有效（非零地址）
        if (from == address(0)) revert ERC20InvalidSender(from);

        // 验证接收者地址有效（非零地址）
        if (to == address(0)) revert ERC20InvalidReceiver(to);

        // 验证发送者余额充足
        uint256 balance = _balances[from];
        if (balance < amount) revert ERC20InsufficientBalance(from,balance,amount);

        // 执行转账（使用unchecked块优化Gas，因已验证balance >= amount）
        unchecked{
            _balances[from] = balance - amount;
            _balances[to] += amount;
        }

        // 触发转账事件
        emit Transfer(from, to, amount);
    }

    // 内部授权逻辑
    function _approve(address owner,address spender,uint256 amount) internal {
        // 验证授权者（owner）不能为零地址（使用 IERC20Errors 标准错误）
        if (owner == address(0)) revert ERC20InvalidApprover(owner);

        // 验证被授权者（spender）不能为零地址（使用 IERC20Errors 标准错误）
        if (spender == address(0)) revert ERC20InvalidSpender(spender);
        
        _allowances[owner][spender] = amount;

        // 触发授权事件
        emit  Approval(owner, spender, amount);
    }

    // 内部扣减授权额度逻辑
    function _spendAllowance(address owner,address spender,uint256 amount) internal  {
        uint256 currentAllowance = _allowances[owner][spender]; 

        // 无限授权（type(uint256).max）无需扣减
        if (currentAllowance != type(uint256).max) {
            // 验证授权额度充足
            if (currentAllowance < amount) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, amount);
            }
            // 扣减授权额度（使用unchecked优化Gas）
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }


    }

}