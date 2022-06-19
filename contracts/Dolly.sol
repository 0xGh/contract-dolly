// SPDX-License-Identifier: BSD-3-Clause
// © 2022-present 0xG
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Admin.sol";
import "./IDolly.sol";

// @title Dolly, cloned NFTs
// @author 0xG

contract Dolly is IDolly, ERC721, Admin {
  uint cloneId;
  mapping(uint => uint) _originalIds;
  mapping(uint => address) _tokenAddresses;
  mapping(uint => uint) _lendingExpires;

  constructor() ERC721("Dolly", "DLLY") {}

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, Admin) returns (bool) {
    return
      interfaceId == type(IDolly).interfaceId ||
      super.supportsInterface(interfaceId);
  }

  /**
   * @dev See {IDolly-clone}.
   */
  function clone(address tokenAddress, uint tokenId) external adminOnly {
    require(tokenAddress.code.length > 0, "Dolly: token address must be a contract");
    require(msg.sender == IERC721(tokenAddress).ownerOf(tokenId), "Dolly: caller must be owner of the token");
    cloneId += 1;
    _originalIds[cloneId] = tokenId;
    _tokenAddresses[cloneId] = tokenAddress;
    _safeMint(msg.sender, cloneId);
  }

  /**
   * @dev See {IDolly-lend}.
   */
  function lend(uint cloneId, address to, uint expires) external {
    ERC721.safeTransferFrom(ERC721.ownerOf(cloneId), to, cloneId);
    _lendingExpires[cloneId] = expires;
  }

  /**
   * @dev See {IDolly-claim}.
   */
  function claim(uint cloneId) external {
    _transfer(ERC721.ownerOf(cloneId), msg.sender, cloneId);
    delete _lendingExpires[cloneId];
  }

  /**
   * @dev See {IDolly-returnToken}.
   */
  function returnToken(uint cloneId) external {
    address owner = _originalOwnerOf(cloneId);
    _transfer(msg.sender, owner, cloneId);
  }

  /**
   * @dev See {IDolly-burn}.
   */
  function burn(uint cloneId) external {
    require(ERC721.ownerOf(cloneId) == _originalOwnerOf(cloneId), "Dolly: only owner can burn");
    _burn(cloneId);
    delete _originalIds[cloneId];
    delete _tokenAddresses[cloneId];
    delete _lendingExpires[cloneId];
  }

  /**
   * @dev See {IERC721-_beforeTokenTransfer}.
   */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 cloneId
  ) internal virtual override {
    if (from != address(0)) {
      // returnToken
      if (msg.sender == ERC721.ownerOf(cloneId) && to == _originalOwnerOf(cloneId)) {
        delete _lendingExpires[cloneId];
        return;
      }
      require(block.timestamp > _lendingExpires[cloneId], "Dolly: token locked until current lending expiration");
      require(_canTransfer(msg.sender, cloneId), "Dolly: caller is allowed to transfer token");
    }
  }

  /**
   * @dev Returns the original token ID of a cloneId.
   */
  function _originalOwnerOf(uint cloneId) internal view returns (address) {
    uint tokenId = _originalIds[cloneId];
    require(tokenId != 0, "Dolly: invalid token ID");
    address owner = IERC721(_tokenAddresses[cloneId]).ownerOf(tokenId);
    require(owner != address(0), "Dolly: owner for token not found");
    return owner;
  }

  /**
   * @dev Checks if `spender` is the owner or an approved spender of the original token ID.
   * When that's the case the token can be transferred.
   */
  function _canTransfer(address spender, uint256 cloneId) internal view virtual returns (bool) {
    address owner = _originalOwnerOf(cloneId);
    IERC721 token = IERC721(_tokenAddresses[cloneId]);
    return (spender == owner || token.isApprovedForAll(owner, spender) || token.getApproved(_originalIds[cloneId]) == spender);
  }

  function tokenURI(uint256 cloneId) public view virtual override returns (string memory) {
    require(_exists(cloneId), "Dolly: invalid token ID");
    return IERC721Metadata(_tokenAddresses[cloneId]).tokenURI(_originalIds[cloneId]);
  }
}