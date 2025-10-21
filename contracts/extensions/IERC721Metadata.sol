// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IERC721} from "../IERC721.sol";

interface IERC721Metadata is IERC721 {
    /**
     * @dev 返回代币集合的名称（如“Bored Ape Yacht Club”）。
     * @return 集合名称的字符串
     */
    function name() external view returns (string memory);

    /**
     * @dev 返回代币集合的符号（类似股票代码，如“BAYC”）。
     * @return 集合符号的字符串
     */
    function symbol() external view returns (string memory);

    /**
     * @dev 返回 `tokenId` 对应代币的统一资源标识符（URI）。
     * 该 URI 通常指向一个 JSON 文件，包含该 NFT 的详细元数据（如图片链接、描述、属性等）。
     * 例如："ipfs://QmX...abc" 或 "https://example.com/nft/123.json"。
     * @param tokenId 代币的唯一标识
     * @return 该代币元数据的 URI 字符串
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}