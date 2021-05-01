pragma solidity ^0.6.0;
//import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol'; 
 
contract GeneManagerV2 { 
    
    struct Settings {
        uint8 MAX_PTYPE;
        uint8 MAX_CLASS; 
    }
      
    mapping (uint=> uint ) public datas; 
    
    uint[] public uniqueParts;
    event Log(uint myvar);
    event Logger(uint key,uint value);
    event Logger(string key,uint value);
    event LoggerMixGenes(uint mGenes,uint sGenes);
    event LogArray(string str, uint[] myArray);
    
    function _mixGenes2(uint256 _matronGenes,uint32 _matronTraits, uint256 _sireGenes,uint32 _sireTraits) 
    public
    returns(uint _offspringGenes){
        _offspringGenes = 1235;
        return _offspringGenes;
        
    }
        
    
    function _mixGenes(uint256 _matronGenes,uint32 _matronTraits, uint256 _sireGenes,uint32 _sireTraits,uint32 mode) 
            public 
            returns(uint _offspringGenes){
            uint res;
            uint32[8] memory mGenes = unpackGene256(_matronGenes);
            uint32[8] memory sGenes = unpackGene256(_sireGenes);
            uint32[8] memory oGenes;
            
            //emit LoggerMixGenes(mGenes[1],sGenes[1]);
            uint256 loopVar;
            if(mode == 0){
                
            }else{
                
            }
             for (uint i=0; i<7; i++) {
                //for each part get percent calculation for p,r1,r2 adding both matron and sire
                
                uint8[7] memory mPart = unpackGene32(mGenes[i]);
                uint8[7] memory sPart = unpackGene32(sGenes[i]);
                uint16[6] memory allGenes; uint added = 0;
                uint[4] memory rGenes;
                
                allGenes = getAllGenesOfParents(mPart,sPart);
                
                //all r1 r2 genes
                //all r1 r2 genes
                rGenes[0] = allGenes[1]; rGenes[1] = allGenes[2];  rGenes[2] = allGenes[4]; rGenes[3] = allGenes[5]; 
                
                datas[allGenes[0]] = 37500 + datas[allGenes[0]];
                datas[allGenes[1]] = 9375 + datas[allGenes[1]];
                datas[allGenes[2]] = 3125 + datas[allGenes[2]];
                
                datas[allGenes[3]] = 37500 + datas[allGenes[3]];
                datas[allGenes[4]] = 9375 + datas[allGenes[4]];
                datas[allGenes[5]] = 3125 + datas[allGenes[5]];
                
                //shuffle parts and map to 0-100 
               delete uniqueParts;
               
                for(uint i=0; i < allGenes.length; i++){
                    if(datas[allGenes[i]] > 0 && isPresent(allGenes[i],uniqueParts) == false){
                        uniqueParts.push(allGenes[i]);
                    }
                }

                emit LogArray("unique",uniqueParts);
                uint[] memory order = new uint[](uniqueParts.length);
                 
                
                uint[] memory spread = new uint[](uniqueParts.length+1);
                spread[0] = 0;
                
                for(uint i=1; i < spread.length; i++){
                    spread[i] = spread[i-1] + datas[uniqueParts[i-1]]; //dont shuffle for now lets see after gas estimations
                }
                
                emit LogArray("spread",spread);
                uint rndm = rand(i+spread[i]); //uint256(keccak256(abi.encodePacked(now))) % 100000;
                //uint rndm2 = uint256(keccak256(abi.encodePacked(now))) % 100000;
                emit Logger("random",rndm);
                //emit Logger("random2",rndm2);
                
                uint gene; 
                uint geneLoc;
                for(uint i=0; i < spread.length; i++){
                    if(rndm >= spread[i] && rndm <= spread[i+1]){
                        gene = uniqueParts[i];
                        geneLoc = i;
                        break;
                    }
                }
                
                if(gene==0){
                    gene = datas[uniqueParts[0]]; //RESETTING to primary gene if no match happens
                }
                if(i==0){emit Logger("gene_back",gene);}  
                if(i==1){emit Logger("gene_color",gene);}  
                if(i==2){emit Logger("gene_ears",gene);}
                if(i==3){emit Logger("gene_eyes",gene);}  
                if(i==4){emit Logger("gene_head",gene);}  
                if(i==5){emit Logger("gene_mouth",gene);}
                if(i==6){emit Logger("gene_pattern",gene);}  
                if(i==7){emit Logger("gene_tail",gene);}
              
                //shuffle rGenes
                shuffle4rGenes(rGenes,gene);
                emit Logger("rgenes",rGenes[0]); emit Logger("rgenes",rGenes[1]); emit Logger("rgenes",rGenes[2]); emit Logger("rgenes",rGenes[3]);
                
                //get the 32bit created for the _offspringGenes
                oGenes[i] = packGene32(0,uint8(gene >> 12),uint8(gene & ((1 << 6) - 1)),
                             uint8(rGenes[0] >> 12),uint8(rGenes[0] & ((1 << 6) - 1)),
                             uint8(rGenes[0] >> 12),uint8(rGenes[0] & ((1 << 6) - 1)));
                //reset
                 for(uint i=0; i < allGenes.length; i++){
                    datas[allGenes[i]] = 0;
                }
                //reset
             }
             
             uint oG = packGene256(oGenes[0],oGenes[1],oGenes[2],oGenes[3],oGenes[4],oGenes[5],oGenes[6],oGenes[7]);
             
             emit Logger("offspringGenes",oG);
             return oG;
            
    }

    function isPresent(uint x, uint[] memory arr)
            internal
            returns (bool){
            for(uint i=0; i < arr.length; i++){
                if(arr[i]==x){
                    return true;
                }
            }    
        return false;
    }
    
    function rand22(uint salt)
        public
        view
        returns(uint, uint, uint)
        {
            
            return (uint256(keccak256(abi.encodePacked(now)))%100000,uint(now),uint(keccak256(abi.encodePacked(block.gaslimit))));
        }
    function echos()
     public
        view
        returns(uint, uint, address,uint)
        {
            
            return (block.timestamp , block.difficulty, block.coinbase, block.gaslimit);
        }
    function rand(uint salt)
        public
        view
        returns(uint256)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(333 * salt + block.timestamp + block.difficulty + ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)) + block.gaslimit + ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)) +
            block.number
        )));
    
        return seed % 100000;
    }
    
    function shuffle(uint[] memory numberArr) internal {
        for (uint256 i = 0; i < numberArr.length; i++) {
            uint256 n = i + uint256(keccak256(abi.encodePacked(now))) % (numberArr.length - i);
            uint256 temp = numberArr[n];
            numberArr[n] = numberArr[i];
            numberArr[i] = temp;
        }
    }
    
    function shuffle4rGenes(uint[4] memory numberArr, uint gene) internal {
        for (uint256 i = 0; i < 4; i++) {
            uint256 n = i + uint256(keccak256(abi.encodePacked(now))) % (numberArr.length - i);
            uint256 temp = numberArr[n];
            numberArr[n] = numberArr[i];
            numberArr[i] = temp;
            if(numberArr[i] == gene){ //removing already selected gene
                if(i==0)
                numberArr[i] = numberArr[i+1];
                else
                numberArr[i] = numberArr[i-1];
            }
        }
    }
    
     /* GENE32 #### */
    /* <type 2><class 4><primaryGene 6><class 4><secondaryGene1 6><class 4><secondaryGene2 6> 
        2 4 6 4 6 4 6
    */
    function unpackGene32(uint32 x) public view returns(uint8[7] memory){
        uint8[7] memory res;
        res[0] = uint8(x >> 30);
        res[1]  = uint8(x >> 26 & ((1 << 4) - 1));
        res[2]  = uint8(x >> 20 & ((1 << 6) - 1));
        
        res[3]  = uint8(x >> 16 & ((1 << 4) - 1));
        res[4]  = uint8(x >> 10 & ((1 << 6) - 1));
        
        res[5]  = uint8(x >> 6 & ((1 << 4) - 1));
        res[6]  = uint8(x & ((1 << 6) - 1));

        return (res);
    }
    /* GENE32 #### */
    
    function packGene32(uint8 ptype,uint8 pclass,uint8 p,uint8 r1class,uint8 r1,uint8 r2class,uint8 r2) public view returns(uint32){
        return (uint32(ptype) << 30) | (uint32(pclass) << 26) | (uint32(p) << 20) | (uint32(r1class) << 16) | (uint32(r1) << 10) |(uint32(r2class) << 6) | (uint32(r2));
    }
    
    function getAllGenesOfParents(uint8[7] memory mPart, uint8[7] memory sPart) public view returns(uint16[6] memory){
        uint16[6] memory res;
        res[0] = pack16(mPart[1],mPart[2]);
        res[1] = pack16(mPart[3],mPart[4]);
        res[2] = pack16(mPart[5],mPart[6]);
        res[3] = pack16(sPart[1],sPart[2]);
        res[4] = pack16(sPart[3],sPart[4]);
        res[5] = pack16(sPart[5],sPart[6]);
        
        return res;
    }
    function pack16(uint8 p1, uint8 p2) public view returns (uint16){ 
        return (uint16(p1) << 12) | (uint16(p2));
    }
    
    function unpack16(uint16 x) public view returns (uint8, uint8){
        return (uint8(x >> 12),uint8(x & ((1 << 6) - 1)));
    }
    
    /* GENE256 #### */
    function unpackGene256(uint256 x) public view returns(uint32[8] memory){ 
        uint32[8] memory res;
        res[0] = uint32(x >> 224);
        res[1] = uint32(x >> 192 & ((1 << 32) - 1));
        res[2] = uint32(x >> 160 & ((1 << 32) - 1));
        res[3] = uint32(x >> 128 & ((1 << 32) - 1));
        res[4] = uint32(x >> 96 & ((1 << 32) - 1));
        res[5] = uint32(x >> 64 & ((1 << 32) - 1));
        res[6] = uint32(x >> 32 & ((1 << 32) - 1));
        res[7] = uint32(x & ((1 << 32) - 1));
        return (res);

    }

    function packGene256(uint32 a,uint32 b,uint32 c,uint32 d,uint32 e,uint32 f,uint32 g,uint32 h) public view returns(uint256){
        uint256 x = (uint256(a) << 224) | (uint256(b) << 192) | (uint256(c) << 160) | (uint256(d) << 128) | (uint256(e) << 96);
        return x | (uint256(f) << 64) | (uint256(g) << 32)  | uint256(h);
    }
    /* GENE256 #### */
    
    /* TRAIT #### */
    /* 
    *<32bit>
            <main class 4><special class 4><special part1 6><special part2 6><special part3 6><special part4 6>
    */
    function unpackTrait32(uint32 x) public view returns(uint8 class,uint8 splClass,uint8 spPart1,uint8 spPart2,uint8 spPart3,uint8 spPart4){
        uint8 class = uint8(x >> 28);
        uint8 splClass = uint8(x >> 24 & ((1 << 4) - 1));
        uint8 spPart1 = uint8(x >> 18 & ((1 << 6) - 1));
        uint8 spPart2= uint8(x >> 12 & ((1 << 6) - 1));
        uint8 spPart3 = uint8(x >> 6 & ((1 << 6) - 1));
        uint8 spPart4 = uint8(x & ((1 << 8) - 1));
        return (class,splClass,spPart1,spPart2,spPart3,spPart4);
    }
    
    function packTrait32(uint8 class,uint8 splClass,uint8 spPart1,uint8 spPart2,uint8 spPart3,uint8 spPart4) public view returns(uint32){
        return (uint32(class) << 28) | (uint32(splClass) << 24) | (uint32(spPart1) << 18) |(uint32(spPart2) << 12) |(uint32(spPart3) << 6) | uint32(spPart4);
    }
     /* TRAIT #### */
     
     /* DEV TEST METHODS TO BE REMOVED */

}