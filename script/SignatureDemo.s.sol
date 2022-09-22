// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@forge-std/Script.sol";
import "../src/SignatureDemo.sol";

contract CounterScript is Script {
  SignatureDemo public signatureDemo;
  address public deployer = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);

  function setUp() public {
    signatureDemo = new SignatureDemo();
  }

  function run() public {
    vm.startBroadcast(deployer);
    setUp();
    vm.stopBroadcast();
  }
}
