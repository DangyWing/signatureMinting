// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
// use draft for testing with remix
// import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@erc721a/contracts/extensions/ERC721AQueryable.sol";
import "@solmate/src/auth/Owned.sol";

contract MyToken is ERC721AQueryable, EIP712, Owned {
  // use bool if users can only redeem one
  // use uint256 if users can redeem more than one
  mapping(address => bool) redeemed;

  uint256 MAX_SUPPLY = 6666;
  uint256 mintCost = 0.0666 ether;
  uint256 maxPerTx = 2;

  string private constant SIGNING_DOMAIN = "CAT";
  string private constant SIGNATURE_VERSION = "1";

  address private signer;

  error AlreadyRedeemed();

  constructor(address _signer)
    ERC721A("TOKEN", "TOK")
    EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION)
    Owned(msg.sender)
  {
    signer = _signer;
  }

  function setSigner(address _newSigner) external onlyOwner {
    signer = _newSigner;
  }

  function check(
    uint256 id,
    string memory name,
    bytes memory signature
  ) public view returns (address) {
    bytes32 digest = _hashTypedDataV4(
      keccak256(
        abi.encode(keccak256("Web3Struct(uint256 id,string name)"), id, keccak256(bytes(name)))
      )
    );
    return ECDSA.recover(digest, signature);
  }

  function signatureMint(
    uint256 mintAmount,
    uint256 id,
    string memory name,
    bytes memory signature
  ) public {
    // require that the signer matches the intended signer
    require(check(id, name, signature) == signer, "Voucher Invalid");

    if (redeemed[msg.sender] == true) revert AlreadyRedeemed();

    redeemed[msg.sender] = true;

    _mint(msg.sender, mintAmount);
  }

  // WOULD NEED TO UPDATE
  function tokenURI(uint256 id)
    public
    view
    virtual
    override(ERC721A, IERC721A)
    returns (string memory)
  {
    return Strings.toString(id);
  }

  function _startTokenId() internal view virtual override returns (uint256) {
    return 1;
  }
}
