import mongoose from "mongoose";
import dotenv from 'dotenv'
dotenv.config();
const ConnectToMongo=async()=>{
    try{
   await mongoose.connect(process.env.BACKENED_URL);
   console.log("Conneted to MongoDB Successfully");
    }catch(e){
     console.log("Connection Error ",e);
    }

}
export default ConnectToMongo