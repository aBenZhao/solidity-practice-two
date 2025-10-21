### NFT部署与使用步骤（对应作业流程）

1. **合约编译**：

- - 在 Remix 中创建MyTestNFT.sol，粘贴上述代码；

- - 选择编译器版本0.8.25，点击「Compile MyTestNFT.sol」（确保无报错）。

1. **准备 IPFS 元数据**：

- - 上传图片到 Pinata，获取图片 IPFS 链接（如https://gateway.pinata.cloud/ipfs/QmX...）；

- - 创建metadata.json（参考 OpenSea 标准），示例：

```
{
  "name": "My First Test NFT",
  "description": "作业2：测试网图文NFT",
  "image": "https://gateway.pinata.cloud/ipfs/bafybeibvsdi4mejssujzqx7dzgxfrlpeaows63hgx2pqmpswylcfvzhm4y", 
  "attributes": [{"trait_type": "测试属性", "value": "完成作业"}]
}

https://gateway.pinata.cloud/ipfs/bafkreibx3eiyebrqfcoxab3ved6bqbsyi5az24rqhdsri6qszpx6yahssm
```

- - 上传metadata.json到 Pinata，获取元数据 IPFS 链接（如https://gateway.pinata.cloud/ipfs/QmY...）。

1. **部署到测试网**：

- - Remix 中切换到「Deploy & Run Transactions」，Environment选择Injected Provider - MetaMask；

- - 构造函数参数输入：name_（如"MyTestNFT"）、symbol_（如"MTN"）；

- - 点击「Deploy」，MetaMask 确认交易，记录部署后的合约地址。

1. **铸造 NFT**：

- - 在 Remix「Deployed Contracts」中展开合约，找到mintNFT函数；

- - 输入参数：recipient（你的钱包地址）、tokenURI_（元数据 IPFS 链接）；

- - 点击「transact」，MetaMask 确认交易，铸造成功后返回tokenId。

1. **查看 NFT**：

- - 在钱包中查看收藏品

- - **Etherscan 测试网**：访问https://sepolia.etherscan.io/，输入合约地址，在「Token Transfers」中查看铸造记录。