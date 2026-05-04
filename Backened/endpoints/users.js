import express from 'express'
import bcrypt from 'bcryptjs'
import User from '../Models/users.js'
import jwt from 'jsonwebtoken'
import dotenv from 'dotenv'
import Authentication from '../Authentication/auth.js'
import isAdmin from '../Authentication/adminChecker.js'
dotenv.config();

const router = express.Router()

router.post('/register', async (req, res) => {
  try {
    const { fname, lname, email, password } = req.body

    if (!fname || !lname || !email || !password) {
      return res.status(400).json({ message: 'All fields required' })
    }

    const existing = await User.findOne({ email })
    if (existing) return res.status(400).json({ message: 'User already registered' })

    const hashPass = await bcrypt.hash(password, 10)
    await User.create({ fname, lname, email, password: hashPass })

    res.status(201).json({ message: 'Register successful' })
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message })
  }
})
router.delete('/deletestudent/:id', Authentication, isAdmin, async (req, res) => {
  try {
    const userid = req.params.id;
    if (!userid) return res.status(400).json({ message: 'User ID required' });

    const deletedUser = await User.findByIdAndDelete(userid);
    if (!deletedUser) return res.status(404).json({ message: 'User not found' });
    res.status(200).json({ message: 'User deleted successfully' }); 
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message })
  }
})
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body
    if (!email || !password) {
      return res.status(400).json({ message: 'All fields required' })
    }

    const user = await User.findOne({ email })
    if (!user) return res.status(404).json({ message: 'User not found' })

    const match = await bcrypt.compare(password, user.password)
    if (!match) return res.status(400).json({ message: 'Wrong password' })

    const token = jwt.sign(
      { 
        id: user._id, 
        _id: user._id,      
        email: user.email, 
        role: user.role     
      },
      process.env.SECRET_KEY,
      { expiresIn: '7d' }
    )

    res.status(200).json({
      token,
      userId: user._id.toString(),
      fname: user.fname,
      lname: user.lname,
      role: user.role
    })
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message })
  }
})


router.get('/all', Authentication, isAdmin, async (req, res) => {
  try {
    const allUsers = await User.find({ _id: { $ne: req.user._id } })
      .select('fname lname email role') 

    res.status(200).json({ message: 'All users', allUsers })
  } catch (e) {
    res.status(500).json({ message: 'Server error', error: e.message })
  }
})

export default router
