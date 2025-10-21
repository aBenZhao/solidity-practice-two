// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IERC165} from "../utils/IERC165.sol";

/**
 * @dev ERC-721 标准合规合约的必备接口。
 * 定义了非同质化代币（NFT）的核心功能规范，所有 ERC-721 代币合约必须实现此接口。
 */
interface IERC721 is IERC165 {
    /**
     * @dev 当 `tokenId` 对应的代币从 `from` 地址转移到 `to` 地址时触发。
     * @param from 转移发起地址
     * @param to 接收地址
     * @param tokenId 被转移的代币唯一标识
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev 当 `owner` 授权 `approved` 地址管理 `tokenId` 对应的代币时触发。
     * @param owner 代币所有者地址
     * @param approved 被授权管理代币的地址
     * @param tokenId 被授权的代币唯一标识
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev 当 `owner` 授权或撤销（`approved` 为 true/false）`operator` 管理其所有资产时触发。
     * @param owner 资产所有者地址
     * @param operator 被授权的操作员地址
     * @param approved 授权状态（true 为授权，false 为撤销）
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev 返回 `owner` 地址拥有的代币数量。
     * @param owner 要查询的地址
     * @return balance 该地址持有的 NFT 总数
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev 返回 `tokenId` 对应的代币所有者地址。
     * 
     * 要求：
     * - `tokenId` 必须是已存在的代币（未被销毁）。
     * @param tokenId 代币唯一标识
     * @return owner 代币所有者地址
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function approve(address to, uint256 tokenId) external;

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
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev 返回 `tokenId` 代币当前被授权的管理地址。
     * 
     * 要求：
     * - `tokenId` 必须存在。
     * @param tokenId 代币唯一标识
     * @return operator 被授权管理该代币的地址（零地址表示无授权）
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev 查看 `operator` 是否被允许管理 `owner` 的所有资产。
     * 参考 {setApprovalForAll} 函数的授权逻辑。
     * @param owner 资产所有者地址
     * @param operator 操作员地址
     * @return 是否拥有批量管理权限
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    
}