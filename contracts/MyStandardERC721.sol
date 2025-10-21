// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// import {Context} from"../utils/Context.sol";
// import {IERC165} from "../utils/IERC165.sol";
// import {ERC165} from "../utils/impl/ERC165.sol";
// import {IERC721} from "./IERC721.sol";
// import {IERC721Metadata} from "./extensions/IERC721Metadata.sol";
import {IERC721Errors} from "../errors/IERC721Errors.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721} from "@openzeppelin/contracts/interfaces/IERC721.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";



contract MyStandardERC20 is Context, ERC165,IERC721,IERC721Metadata,IERC721Errors{
    using Strings for uint256;

    // ==========================状态变量
    // NFT集合名称
    string private _name;

    // NFT集合符号
    string private _symbol;

    // 存储每个tokenId对应的元数据URI
    mapping(uint256 => string) private _tokenURIs;

    // 存储每个tokenId的所有者地址
    mapping(uint256 => address) private _owners;

    // 存储每个地址持有的NFT数量
    mapping(address => uint256) private _balances;

    // 存储每个tokenId的授权地址（单次授权）
    mapping(uint256 => address) private _tokenApprovals;

    // 存储每个地址的批量授权状态（所有者 =〉 操作员 =〉 授权状态 ）
    mapping(address => mapping(address => bool)) private  _operatorApprovals;

    // tokenId自增计数器（确保每个NFT唯一）
    uint256 private _tokenIdCounter;

    // ===========================构造函数
    constructor(string memory name_,string memory symbol_){
        _name = name_;
        _symbol = symbol_;
        _tokenIdCounter = 1;
    }


    // ==================接口检测（ERC165实现）
    // 验证合约是否支持制定接口
    function supportsInterface(bytes4 interfaceId) public  view  virtual  override(ERC165,IERC165) returns (bool){
        return 
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);

    }


    // ==================NTF元数据信息
    /**
     * @dev 返回代币集合的名称（如“Bored Ape Yacht Club”）。
     * @return 集合名称的字符串
     */
    function name() external view virtual override returns (string memory){
        return _name;
    }

    /**
     * @dev 返回代币集合的符号（类似股票代码，如“BAYC”）。
     * @return 集合符号的字符串
     */
    function symbol() external view virtual override returns (string memory){
        return _symbol;
    }

    /**
     * @dev 返回 `tokenId` 对应代币的统一资源标识符（URI）。
     * 该 URI 通常指向一个 JSON 文件，包含该 NFT 的详细元数据（如图片链接、描述、属性等）。
     * 例如："ipfs://QmX...abc" 或 "https://example.com/nft/123.json"。
     * @param tokenId 代币的唯一标识
     * @return 该代币元数据的 URI 字符串
     */
    function tokenURI(uint256 tokenId) external view virtual override returns (string memory){
        // 检查tokenId是否存在（不存在则触发错误）
        if (!_exists(tokenId)){
            revert ERC721NonexistentToken(tokenId);
        }

        // 确保URI不为空
        string memory uri = _tokenURIs[tokenId];
        if (bytes(uri).length == 0) {
            revert("HTF:tokenURI is empty");
        }

        return uri;
    }


    // ===================== 核心NFT功能（IERC721实现）

    /**
     * @dev 返回 `owner` 地址拥有的代币数量。
     * @param owner 要查询的地址
     * @return balance 该地址持有的 NFT 总数
     */
    function balanceOf(address owner) external view override returns (uint256 balance){
        if (owner == address(0)){
            revert ERC721InvalidOwner(owner);
        }

        return _balances[owner];
    }

    /**
     * @dev 返回 `tokenId` 对应的代币所有者地址。
     * 
     * 要求：
     * - `tokenId` 必须是已存在的代币（未被销毁）。
     * @param tokenId 代币唯一标识
     * @return owner 代币所有者地址
     */
    function ownerOf(uint256 tokenId) external view override returns (address){
        address owner = _owners[tokenId];
        if (owner == address(0)){
            revert ERC721NonexistentToken(tokenId);
        }
        return owner;
    }


    /**
     * @dev 将 `tokenId` 代币从 `from` 安全转移到 `to`（带额外数据）。
     * "安全"指：若接收地址是合约，必须实现 `IERC721Receiver-onERC721Received` 函数，否则转移失败。
     * 
     * 要求：
     * - `from` 不能是零地址。
     * - `to` 不能是零地址。
     * - `tokenId` 必须存在且归 `from` 所有。
     * - 若调用者不是 `from`，则必须通过 {approve} 或 {setApprovalForAll} 获得转移授权。
     * - 若 `to` 是合约，必须实现 `IERC721Receiver-onERC721Received` 函数（用于确认接收）。
     * 
     * 触发 {Transfer} 事件。
     * @param from 转移发起地址
     * @param to 接收地址
     * @param tokenId 被转移的代币唯一标识
     * @param data 附加数据（会传递给接收合约的 `onERC721Received` 函数）
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external override {
        // 校验转移权限
        _checkTransferPermission(from,tokenId,_msgSender());
        // 执行安全转移（检查接受合约是否支持NFT接收）
        _safeTransfer(from,to,tokenId,data);
    }

    /**
     * @dev 将 `tokenId` 代币从 `from` 安全转移到 `to`（不带额外数据）。
     * 与上一个函数功能一致，仅缺少 `data` 参数，适用于无需传递附加信息的场景。
     * 
     * 要求：
     * - 同 `safeTransferFrom`（带 data 参数的版本）。
     * 
     * 触发 {Transfer} 事件。
     * @param from 转移发起地址
     * @param to 接收地址
     * @param tokenId 被转移的代币唯一标识
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external override {
        // 调用带数据的安全转移，数据传控
        this.safeTransferFrom(from,to,tokenId,"");
    }





    /**
     * @dev 将 `tokenId` 代币从 `from` 转移到 `to`（非安全转移）。
     * 
     * 警告：调用者需确保接收地址（尤其是合约）能处理 ERC-721 代币，否则代币可能永久锁定。
     * 建议优先使用 {safeTransferFrom} 避免丢失风险，但需注意外部调用可能存在重入漏洞。
     * 
     * 要求：
     * - `from` 不能是零地址。
     * - `to` 不能是零地址。
     * - `tokenId` 必须归 `from` 所有。
     * - 若调用者不是 `from`，则必须通过 {approve} 或 {setApprovalForAll} 获得转移授权。
     * 
     * 触发 {Transfer} 事件。
     * @param from 转移发起地址
     * @param to 接收地址
     * @param tokenId 被转移的代币唯一标识
     */
    function transferFrom(address from, address to, uint256 tokenId) external{
        // 校验转移权限
        _checkTransferPermission(from,tokenId,_msgSender());
        // 执行普通转移（不检查接收合约）
        _transfer(from, to, tokenId);
    }

    /**
     * @dev 授权 `to` 地址转移 `tokenId` 对应的代币（单次授权）。
     * 当代币被转移后，该授权会自动清除。
     * 同一时间只能有一个地址获得授权，授权零地址会清除之前的授权。
     * 
     * 要求：
     * - 调用者必须是代币所有者或已被授权的操作员。
     * - `tokenId` 必须存在。
     * 
     * 触发 {Approval} 事件。
     * @param to 被授权的地址
     * @param tokenId 被授权转移的代币唯一标识
     */
    function approve(address to, uint256 tokenId) external{
        address owner = this.ownerOf(tokenId);
        // 禁止授权给所有者本人
        if (to == owner) {
            revert ERC721ApprovalToCurrentOwner(to);
        }
        // 校验授权者权限（必须是所有者或已批量授权的操作员）
        if (_msgSender() != owner && !this.isApprovedForAll(owner, _msgSender())) {
            revert ERC721InvalidApprover(_msgSender());
        }
        // 存储授权关系并触发事件
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev 授权或撤销 `operator` 作为调用者的操作员（批量授权）。
     * 操作员可调用 {transferFrom} 或 {safeTransferFrom} 转移调用者拥有的所有代币。
     * 
     * 要求：
     * - `operator` 不能是零地址。
     * 
     * 触发 {ApprovalForAll} 事件。
     * @param operator 操作员地址
     * @param approved 授权状态（true 为授权，false 为撤销）
     */
    function setApprovalForAll(address operator, bool approved) external{
        address owner = _msgSender();
        // 禁止授权给零地址
        if (operator == address(0)) {
            revert ERC721InvalidOperator(operator);
        }
        // 禁止授权给所有者本人
        if (operator == owner) {
            revert ERC721InvalidOperator(operator);
        }
        // 存储批量授权状态并触发事件
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev 返回 `tokenId` 代币当前被授权的管理地址。
     * 
     * 要求：
     * - `tokenId` 必须存在。
     * @param tokenId 代币唯一标识
     * @return operator 被授权管理该代币的地址（零地址表示无授权）
     */
    function getApproved(uint256 tokenId) external view returns (address operator){
        // 检查tokenId是否存在
        if (!_exists(tokenId)) {
            revert ERC721NonexistentToken(tokenId);
        }
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev 查看 `operator` 是否被允许管理 `owner` 的所有资产。
     * 参考 {setApprovalForAll} 函数的授权逻辑。
     * @param owner 资产所有者地址
     * @param operator 操作员地址
     * @return 是否拥有批量管理权限
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool){
        return _operatorApprovals[owner][operator]; 
    }


    // ========================自定义铸造功能
    function mintNFT(address recipient,string memory tokenURI_) external returns (uint256) {
        // 禁止铸造到零地址
        if (recipient == address(0)){
            revert ERC721InvalidReceiver(recipient);
        }

        // 禁止元数据URI为空
        if (bytes(tokenURI_).length == 0){
            revert("NFT:tokenURI cannot be empty");
        }

        // 获取当前tokenId并自增（确保下次铸造唯一）
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        // 执行铸造逻辑
        _mint(recipient,tokenId);

        // 关联元数据URI
        _setTokenURI(tokenId,tokenURI_);

        return tokenId;
    }


    
    // =========================内部辅助函数（仅合约内部调用）
    // 内部铸造函数，实际执行NFT创建
    function _mint(address to,uint256 tokenId) internal virtual {
        // 接收接收者地址有效
        if(to == address(0)){
            revert ERC721InvalidReceiver(to);
        }

        // 检查token未被铸造
        if (_exists(tokenId)){
            revert ERC721TokenAlreadyMinted(tokenId);
        }

        // 安全更新余额
        unchecked{
            _balances[to]++;
        }

        // 记录所有者
        _owners[tokenId] = to;

        // 触发NFT转移事件（from为零地址表示铸造）
        emit Transfer(address(0),to,tokenId);
    }


    /**
     * @dev 关联tokenId与元数据URI
     * @param tokenId NFT唯一标识
     * @param tokenURI_ 元数据URI
     */
    function _setTokenURI(uint256 tokenId, string memory tokenURI_) internal virtual {
        // 检查tokenId是否存在
        if (!_exists(tokenId)) {
            revert ERC721NonexistentToken(tokenId);
        }
        _tokenURIs[tokenId] = tokenURI_;
    }


    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _checkTransferPermission(address from, uint256 tokenId,address spender) internal  virtual {
        // 校验当前NFT的所有者
        if (this.ownerOf(tokenId) != from){
            revert ERC721IncorrectOwner(from,tokenId,this.ownerOf(tokenId));
        }

        // 校验调用者权限（必须是所有者，已单次授权地址，已批量授权操作员）
        if (
            spender != from &&
            this.getApproved(tokenId) != spender &&
            !this.isApprovedForAll(from,spender)
        ){
            revert ERC721InsufficientApproval(spender,tokenId);
        }

    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes calldata data)internal virtual  {
        _transfer(from,to,tokenId);
        // 检查接受合约是否支持NFT接收(是否实现IERC721Receiver接口，避免NFT永久锁定)
        // 合约地址的字节码长度大于 0，外部账户的字节码长度为 0。
        if(to.code.length > 0){
            // 调用接收合约的onERC71Received函数，验证是否支持接收
            (bool success,bytes memory returnData) = to.call(
                abi.encodeWithSelector(
                    IERC721Receiver.onERC721Received.selector, 
                    _msgSender(),
                    from,
                    tokenId,
                    data
                    )

            );

            // 若调用失败或返回值不正确，触发错误
            if (!success || returnData.length != 4 || bytes4(returnData) != IERC721Receiver.onERC721Received.selector){
                revert ERC721InvalidReceiver(to);
            }
        }  
    }


    function _transfer(address from, address to, uint256 tokenId) internal  virtual {
        // 校验所有者
        if(this.ownerOf(tokenId) != from){
            revert ERC721IncorrectOwner(from,tokenId,this.ownerOf(tokenId));
        }

        // 校验接收地址
        if(to == address(0)){
            revert ERC721InvalidReceiver(to);
        }

        // 清除该NFT的单次授权
        _approve(address(0),tokenId);

        // 安全更新余额
        unchecked{
            _balances[from]--;
            _balances[to]++;
        }

        // 触发转移事件
        emit Transfer(from,to,tokenId);


    }

    /**
     * @dev 内部授权函数（更新单次授权并触发事件）
     * @param to 被授权地址
     * @param tokenId NFT唯一标识
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(this.ownerOf(tokenId), to, tokenId);
    }
    
}