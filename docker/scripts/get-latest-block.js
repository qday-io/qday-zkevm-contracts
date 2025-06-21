const fs = require('fs');
const path = require('path');
const { ethers } = require('ethers');

async function getLatestBlockAndUpdate() {
  try {
    console.log('Connecting to local node at http://localhost:8545...');
    
    // Connect to local node
    const provider = new ethers.providers.JsonRpcProvider('http://localhost:8545');
    
    // Test connection
    const network = await provider.getNetwork();
    console.log(`Connected to network: ${network.name} (chainId: ${network.chainId})`);
    
    // Get latest block number
    const latestBlockNumber = await provider.getBlockNumber();
    console.log(`Latest block number: ${latestBlockNumber}`);
    
    // Read current deploy_output.json
    const deployOutputPath = path.join(__dirname, '../../deployment/deploy_output.json');
    if (!fs.existsSync(deployOutputPath)) {
      console.error('Error: deploy_output.json not found at:', deployOutputPath);
      return;
    }
    
    const deployOutput = JSON.parse(fs.readFileSync(deployOutputPath, 'utf8'));
    console.log('Current deploy_output.json loaded successfully');
    
    // Add latest block number
    deployOutput.latestBlockNumber = latestBlockNumber;
    deployOutput.updatedAt = new Date().toISOString();
    
    // Write back to file
    fs.writeFileSync(deployOutputPath, JSON.stringify(deployOutput, null, 2));
    console.log(`✅ Successfully updated deploy_output.json with latest block number: ${latestBlockNumber}`);
    console.log(`📝 Updated at: ${deployOutput.updatedAt}`);
    
  } catch (error) {
    console.error('❌ Error getting latest block number:', error.message);
    
    if (error.code === 'ECONNREFUSED') {
      console.error('💡 Tip: Make sure the local node is running on http://localhost:8545');
    } else if (error.code === 'ENOENT') {
      console.error('💡 Tip: Make sure deploy_output.json exists in the deployment directory');
    }
    
    process.exit(1);
  }
}

getLatestBlockAndUpdate(); 