import { Address } from "@ton/core";




const parentContractAddress = Address.parse("EQDZHk1QzYCjdAj_201MZ9BVWlRxwowx799-77jqS4qiecuY")
const firstChildAddress = Address.parse("EQA1G-axfYcoKV9t8vJ3v9bKdenU4xe4NTGhHajbpE6mMFxT")



const sleep =(ms: number)=>{
return new Promise(resolve => setTimeout(resolve, ms));
}





export {
    parentContractAddress,
    firstChildAddress,
    sleep
}