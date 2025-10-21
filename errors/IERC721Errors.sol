// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @dev 标准 ERC-721 错误定义
 * 遵循 https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] 规范的自定义错误接口，
 * 用于 ERC-721 代币合约中，替代传统的 revert 字符串提示，提升错误信息可读性和 Gas 效率。
 */
interface IERC721Errors {
    /**
     * @dev 表示某个地址不能作为所有者（例如，`address(0)` 是 ERC-721 中禁止的所有者地址）。
     * 通常在查询余额（balanceOf）时触发。
     * @param owner 代币的当前所有者地址（此处为无效地址）
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev 表示 `tokenId` 对应的代币不存在（其所有者为零地址）。
     * 通常在查询不存在的代币信息（如 ownerOf）时触发。
     * @param tokenId 代币的唯一标识（无效/未铸造的 ID）
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev 表示代币所有权相关的错误（如转移时发送者不是所有者）。
     * 通常在转移代币（transferFrom）时触发。
     * @param sender 发起转移的地址（非所有者）
     * @param tokenId 代币的唯一标识
     * @param owner 代币的实际所有者地址
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev 表示代币发送者（from）无效（如为零地址）。
     * 通常在转移代币时触发。
     * @param sender 发起转移的地址（无效地址，如 address(0)）
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev 表示代币接收者（to）无效（如为零地址或不支持接收 NFT 的合约）。
     * 通常在转移代币时触发。
     * @param receiver 接收代币的地址（无效地址）
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev 表示操作员（operator）对代币的授权不足（未获得转移权限）。
     * 通常在操作员尝试转移未授权的代币时触发。
     * @param operator 尝试操作代币的操作员地址
     * @param tokenId 代币的唯一标识（未授权给该操作员）
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev 表示授权者（approver）无效（如非代币所有者或未获得批量授权）。
     * 通常在授权操作（approve）时触发。
     * @param approver 发起授权的地址（无授权权限）
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev 表示被授权的操作员（operator）无效（如为零地址）。
     * 通常在批量授权（setApprovalForAll）时触发。
     * @param operator 被授权的操作员地址（无效地址，如 address(0)）
     */
    error ERC721InvalidOperator(address operator);


    error ERC721TokenAlreadyMinted(uint256 tokenId);

    error ERC721ApprovalToCurrentOwner(address to);
}