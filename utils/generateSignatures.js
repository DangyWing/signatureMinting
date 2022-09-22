const { createSignatureEIP712 } = require("./signatureEIP712");
const { ethers } = require("ethers");
const fs = require("fs");
import { addresses } from "../constants/allowedAddresses";
require("dotenv").config();

const privateKey = process.env.COUPON_SIGNER_PRIVATE_KEY;
const signer = new ethers.Wallet(privateKey);

const allowedAddresses = addresses;

const main = async () => {
  let output = [];
  console.log("Generating...");
  for (let i = 0; i < allowedAddresses.length; i++) {
    let signature = await createSignatureEIP712(i, allowedAddresses[i], privateKey);

    output.push({
      id: signature.id,
      name: signature.name,
      signature: signature.signature,
      wallet: addresses[i],
    });
  }

  let data = JSON.stringify(output);

  fs.writeFileSync("../constants/signatures.json", data);

  console.log("Done.");
  console.log("Check the signatures.json file.");
};
const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};
runMain();
