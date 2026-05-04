import mongoose from 'mongoose';
const { Schema } = mongoose;

const userSchema = new Schema({
  fname:     { type: String, required: true }, 
  lname:     { type: String, required: true }, 
  email:     { type: String, required: true, unique: true },
  password:  { type: String, required: true },
  photo:     { type: String, default: '' },
  type:      { type: String, default: "default" },
  

  role:      { type: String, enum: ["student", "admin"], default: "student" }
  
}, { timestamps: true });

export default mongoose.model('User', userSchema);