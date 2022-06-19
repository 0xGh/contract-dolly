// SPDX-License-Identifier: BSD-3-Clause
// © 2022-present 0xG
pragma solidity ^0.8.0;

// @title Dolly, cloned NFTs
// @author 0xG

interface IDolly {
  function clone(address tokenAddress, uint tokenId) external;
  function lend(uint cloneId, address to, uint expires) external;
  function claim(uint cloneId) external;
  function returnToken(uint cloneId) external;
  function burn(uint cloneId) external;
}
