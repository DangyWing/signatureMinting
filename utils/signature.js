const { ethers } = require("ethers");
require("dotenv").config();

const signingDomainName = process.env.SIGNING_DOMAIN_NAME;
const signingDomainVersion = process.env.SIGNING_DOMAIN_VERSION;
const chainId = process.env.CHAIN_ID;
const verifyingContract = process.env.VERIFYING_CONTRACT;

async function createSignatureEIP712(id, name, privateKey) {
  const signer = new ethers.Wallet(privateKey);

  const obj = { id, name };

  const domain = {
    name: signingDomainName,
    version: signingDomainVersion,
    verifyingContract: verifyingContract,
    chainId: chainId,
  };

  const types = {
    Web3Struct: [
      { name: "id", type: "uint256" },
      { name: "name", type: "string" },
    ],
  };

  const signature = await signer._signTypedData(domain, types, obj);
  return { ...obj, signature };
}

module.exports = {
  createSignatureEIP712,
};
