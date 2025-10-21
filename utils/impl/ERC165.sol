// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IERC165} from "../IERC165.sol";

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId)external view virtual returns (bool){
        return interfaceId == type(IERC165).interfaceId;
    }
}