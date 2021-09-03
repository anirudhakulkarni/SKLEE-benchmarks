Notes:

1. There are 4 data sets:
   1. [contracts in the benchmark](https://owncloud.tuwien.ac.at/index.php/s/qNq87OBHnyOuru2/download) (720 contracts):
      1. Format: bytecode
      2. Bytecode decompilation - no compiler works - issue with constructor - bytecode need some sort of modification
      3. Web scraping - can extract code from ethervm.io/decompile/{address} - scraping did not work - need help
   2. [Solidity sources for the benchmarks, where available](https://owncloud.tuwien.ac.at/index.php/s/0wH8mrcKNri9IBP/download) (601 contracts):
      1. Same as above contracts but 720-600=120 do not have source codes
      2. Original Code available - regex to extract
      3. Some files have unidentified characters in comments (russian) should not matter in use - manually extracted - 3 files 
      4. TODO: As our tool require original source codes we must work on this. But all contracts on internet are stored primarily with bytecode hence we must find a way to decompile it 
   3. [non-trivial contracts in the benchmark contracts with reconstructed control flow](https://owncloud.tuwien.ac.at/index.php/s/0bL5sT5siEqgSU8/download) (605 contracts):
      1. Same contract as above
      2. Not sure what is meant by reconstructed control flow - is it modified contract with issue fixed by the tool?
   4. [data set for functional correctness case study](https://owncloud.tuwien.ac.at/index.php/s/3IWrEbyXOCnlRFL/download):
      1. 4 small pieces of codes
      2. Safemath library
      3. introduces a piece of code that will make math operations secure avoiding overflow errors and some checks
   5. Extra data sets:
      1. [smac-corpus/handle-download.js at master · aphd/smac-corpus (github.com)](https://github.com/aphd/smac-corpus/blob/master/src/services/handle-download.js) use this link. In the source code, someone forgot to hide apikey and we can use it to scrape contracts.
2. Run script on Data set #2 where we have source codes - make sure to add check for solidity version