// SPDX-License-Identifier: BSD-3-Clause
// © 2022-present 0xG
pragma solidity ^0.8.0;

// @title Dolly, cloned NFTs
// @author 0xG

interface IDolly {
  event Clone(address tokenAddress, uint tokenId, address to, uint cloneId);
  event Lend(address from, address to, uint cloneId, uint expires);
  event Claim(address from, address to, uint cloneId);
  event ReturnToken(address from, address to, uint cloneId);
  event Burn(uint cloneId);

  function clone(address tokenAddress, uint tokenId) external;
  function lend(uint cloneId, address to, uint expires) external;
  function claim(uint cloneId) external;
  function returnToken(uint cloneId) external;
  function burn(uint cloneId) external;
  function getCloneInfo(uint cloneId) external view returns (address tokenAddress, uint tokenId, address originalOwner, address owner, uint expires);
}
