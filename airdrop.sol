pragma solidity 0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol'; 
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import '@openzeppelin/contracts/utils/Strings.sol'; 

interface irewardToken{
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
     function transferFrom(address from,address to,uint256 amount) external returns (bool);
     function decimals() external view returns (uint8) ;
}

contract KochiAirdrop is Ownable{
     using Strings for uint256;
     using Strings for address;
     irewardToken public _irewardToken;
     bytes32[] private roots;
     mapping (address=>bool) checkClaimed;
     uint[] public rewardTier=[40,30,20];
     uint256 decimalsRewardToken;
     uint public totalTokensClaimed;
      


    function setRewardTokenAddress(address add)public onlyOwner{
       _irewardToken = irewardToken(add);
       decimalsRewardToken = _irewardToken.decimals();
    } 
    

    function depositRewardToken(uint256 amount)public onlyOwner{
       require(_irewardToken.balanceOf(msg.sender)>=amount*10**decimalsRewardToken,"not enoughn balance");
      _irewardToken.transferFrom(msg.sender,address(this),amount*10**decimalsRewardToken);  
    }

  
    function _isValid(bytes32[] memory proof,bytes32 _root,address add)internal view returns(bool){
       bytes32 leaf= keccak256(abi.encodePacked(add));
       return MerkleProof.verify(proof,_root,leaf);  
   }
   

 
    function getReward(address add,bytes32[] memory proof)public view returns(uint){
        bool check;
        for (uint i;i< roots.length;i++){
         
         if(_isValid(proof,roots[i],add)==true){
            check=true;
            return rewardTier[i];

         }
        }
        
        require(check==true,"you are not qualified for airdrop or invalid parameters"); 
   }

   function claimaAirDrop(bytes32[] calldata proof)external {
       uint airDropAmount =getReward(msg.sender,proof);
       require(_irewardToken.balanceOf(address(this))>=airDropAmount*10**decimalsRewardToken,"not enough balance");
       require(checkClaimed[msg.sender]==false,"already claimed airdrop");
       checkClaimed[msg.sender]=true; 
       totalTokensClaimed+=airDropAmount*10**decimalsRewardToken; 
       _irewardToken.transfer(msg.sender, airDropAmount*10**decimalsRewardToken);
      
    } 
   
   function setRewardTierAndRoot(uint[] calldata settier, bytes32[] calldata _root )external onlyOwner{
         require(settier.length==_root.length,"invalid parameters");
         rewardTier=settier;
         roots=_root; 
   }

   function withdrawRewardToken(address tokenAdd,address _to)public onlyOwner{
      irewardToken  _itoken=irewardToken(tokenAdd);
      _itoken.transfer(_to, _itoken.balanceOf(address(this)));
   }

}   