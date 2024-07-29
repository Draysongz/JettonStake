import { Address } from "@ton/core";




const parentContractAddress = Address.parse("EQD7mX56FcvwIu_ATVMtsgdsoqwWblWUIkjPNt3MmwKLb270")
const firstChildAddress = Address.parse("EQBc0k2BOGl6ax6tmrNoshv7SwKTHNMuGto4TduzLMFfXSJw")



const sleep =(ms: number)=>{
return new Promise(resolve => setTimeout(resolve, ms));
}





export {
    parentContractAddress,
    firstChildAddress,
    sleep
}