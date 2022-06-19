// SPDX-License-Identifier: BSD-3-Clause
// © 2022-present 0xG
pragma solidity ^0.8.0;

// @title Admin
// @author 0xG

interface IAdmin {
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event AdminSet(address indexed addr, bool indexed add);

  function owner() external view returns (address);
  function setOwner(address newOwner) external;
  function isAdmin(address addr) external view returns (bool);
  function setAdmin(address addr, bool add) external;
}
