import React, { useState, useEffect } from "react";
import { ethers } from "ethers";

// Assume frontend has access to deployment config (via a local JSON file)
import deployment from "../config/NFTArt.json";

function NFTMarketplace() {
  const [tokenId, setTokenId] = useState("");
  const [tokenURI, setTokenURI] = useState("");
  const [error, setError] = useState("");
  
  // Connect to a provider (e.g., MetaMask)
  const provider = new ethers.BrowserProvider(window.ethereum);
  const [contract, setContract] = useState(null);
  
  useEffect(() => {
    async function init() {
      await window.ethereum.request({ method: "eth_requestAccounts" });
      const signer = await provider.getSigner();
      const nftContract = new ethers.Contract(deployment.address, deployment.abi, signer);
      setContract(nftContract);
    }
    init().catch(console.error);
  }, []);
  
  async function fetchMetadata() {
    if (!tokenId || !contract) return;
    try {
      const uri = await contract.tokenURI(tokenId);
      setTokenURI(uri);
    } catch (err) {
      console.error("Error fetching metadata:", err);
      setError("Failed to fetch metadata.");
    }
  }
  
  return (
    <div className="nft-marketplace">
      <h2>NFT Art Gallery & Marketplace</h2>
      <div>
        <label>
          Enter Token Id:
          <input
            type="number"
            value={tokenId}
            onChange={(e) => setTokenId(e.target.value)}
          />
        </label>
        <button onClick={fetchMetadata}>Fetch Metadata</button>
      </div>
      {error && <p style={{ color: "red" }}>{error}</p>}
      {tokenURI && (
        <div>
          <h3>Token Metadata</h3>
          <p>{tokenURI}</p>
          {/* In a real app, parse and display metadata more attractively */}
        </div>
      )}
    </div>
  );
}

export default NFTMarketplace;
