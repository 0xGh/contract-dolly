// SPDX-License-Identifier: BSD-3-Clause
// © 2022-present 0xG
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// @title Mock ERC721 contract
// @author 0xG

contract OriginalMock is ERC721 {
  using Strings for uint256;

  constructor() ERC721("Original Mock", "OM") {}

  function mint(uint tokenId, address to) external {
    _safeMint(to, tokenId);
  }

  function burn(uint tokenId) external {
    _burn(tokenId);
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    require(_exists(tokenId), "ERC721: invalid token ID");
    return string(abi.encodePacked(name(), " ", tokenId.toString()));
  }
}
