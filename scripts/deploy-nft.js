require('dotenv').config();
const { ethers } = require("ethers");
const fs = require("fs");
const path = require("path");

// Read compiled artifact from build folder (assumed to be generated)
const artifactPath = path.join(__dirname, "../build/NFTArt.sol/NFTArt.json");
const artifact = JSON.parse(fs.readFileSync(artifactPath, "utf8"));

// Setup provider and wallet
const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// Deploy NFTArt. Oracle address is taken from environment variable.
async function deployNFTArt() {
  console.log("Deploying NFTArt contract...");
  const factory = new ethers.ContractFactory(artifact.abi, artifact.bytecode, wallet);
  const contract = await factory.deploy(process.env.ORACLE_ADDRESS);
  await contract.deployed();
  console.log("NFTArt deployed at:", contract.address);
  
  // Save deployment info for frontend-backend
  const deploymentDir = path.join(__dirname, "../deployments", "NFTArt");
  if (!fs.existsSync(deploymentDir)) fs.mkdirSync(deploymentDir, { recursive: true });
  const deploymentInfo = {
    address: contract.address,
    abi: artifact.abi,
    deployedAt: new Date().toISOString()
  };
  fs.writeFileSync(path.join(deploymentDir, "NFTArt.json"), JSON.stringify(deploymentInfo, null, 2));
}

deployNFTArt().catch(error => {
  console.error("Deployment failed:", error);
  process.exit(1);
});