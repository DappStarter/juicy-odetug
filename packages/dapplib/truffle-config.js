require('@babel/register');
({
    ignore: /node_modules/
});
require('@babel/polyfill');

const WalletProvider = require('./src/lib/wallet-provider');


let mnemonic = 'heavy prize flee venture street rate noise modify grunt light army gas'; 
let testAccounts = [
"0x701a4dc0efc44e71a326e79d03716f1b39f42c8c70d238b028333c17ee42add2",
"0xd5379ec0fbd0dd2c20953e2c6c2139d745e8ead6a920600ce77183833c650bc3",
"0xe5719e1f0976b0a6d1dd3392de9939657df17f3159e017132dca56f54403663c",
"0x7b91c0230a2a982cfae1f5ab9d09e05025fab3b1884ef3ab0470f745eec123bb",
"0xdf6fcc8a353824b226a19b6acd04ef8131eb8f0cbe7faf72f06ccaa7e45b66fa",
"0x9189e7912b5298cb6ef6b51ec84d1cc1b88b34db2b6ec40d2384b61076b9bda7",
"0x72aadabb54ca9a914545a163f475287bd4df6dfb6a6ff7fb22e8a10694f7402e",
"0x04ce469105d8e7889bd402665fee1a4eac64ea09b99bef2437c21e5b2788fa68",
"0x0612c6e1ee71dc094ffc69d9d34497d37ae45a99837b84d7a372e8a625cfd411",
"0x01578717c80f734dd76212dd4936c48daa2f6cd4dc2f5103fb61274d75dbaf0d"
]; 
let devUri = 'https://test.confluxrpc.org/v2';
let host = devUri.replace('http://','').replace('https://','');
let privateKeys = new WalletProvider(mnemonic, 10).privateKeys;

module.exports = {
    testAccounts,
    mnemonic,
    networks: {
        development: {
            uri: devUri,
            network_id: '*',
            host,
            port: 80,
            type: "conflux",
            privateKeys,
            walletProvider: () => new WalletProvider(mnemonic, 10)
        }
    },
    compilers: {
        solc: {
            version: '^0.5.11'
        }
    }
};

