const express = require("express");
const { ethers } = require("ethers");
require('dotenv').config();

const app = express();
app.use(express.json());

// Setup provider and wallet to interact with NFTArt contract
const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// Load NFTArt deployment info (assumes deployment info exists)
const deployment = require("../deployments/NFTArt/NFTArt.json");
const nftArtifact = deployment.abi;
const nftContract = new ethers.Contract(deployment.address, nftArtifact, wallet);

// Endpoint to trigger oracle metadata update
app.post("/update-metadata", async (req, res) => {
  try {
    const { tokenId, newTokenURI } = req.body;
    // In a real scenario add verification logic here (e.g., signature)
    const tx = await nftContract.updateTokenURI(tokenId, newTokenURI);
    const receipt = await tx.wait();
    res.json({ status: "Metadata updated", receipt });
  } catch (error) {
    console.error("Error updating metadata:", error);
    res.status(500).json({ error: error.message });
  }
});

// Endpoint to fetch token metadata
app.get("/nft/:tokenId", async (req, res) => {
  try {
    const tokenId = req.params.tokenId;
    const metadata = await nftContract.tokenURI(tokenId);
    res.json({ tokenId, tokenURI: metadata });
  } catch (error) {
    console.error("Error fetching token metadata:", error);
    res.status(500).json({ error: error.message });
  }
});

// ... Additional endpoints for listing, buying, selling NFT ...
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Backend API listening on port ${PORT}`);
});