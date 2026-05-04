import express from 'express'
import morgan from 'morgan'
import cors from 'cors'
import ConnectToMongo from './db.js'
import dotenv from 'dotenv';
import router from './endpoints/users.js';
import StudentRouter from './endpoints/studentmarks.js';
dotenv.config();
const app = express()
app.use(morgan('dev'))    
app.use(cors());     
app.use(express.json());       
app.use('/users', router); 
app.use('/marks',StudentRouter);
ConnectToMongo();
app.get('/', (req, res) => {
  res.send('Hello World!')
})
app.listen(process.env.PORT, () => {
  console.log(`Example app listening on port ${process.env.PORT}`)
})
