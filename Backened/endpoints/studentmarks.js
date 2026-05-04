import Authentication from '../Authentication/auth.js';
import express from 'express';
import Marks from '../Models/Studentmarks.js';
import User from '../Models/users.js';
import isAdmin from '../Authentication/adminChecker.js';

const StudentRouter = express.Router();

StudentRouter.post('/student', Authentication, isAdmin, async (req, res) => {
    const { totalmarks, obtainedmarks, marksType, studentId } = req.body;

    try {
        if (!totalmarks || !obtainedmarks || !marksType || !studentId) {
            return res.status(400).json({
                message: "Please provide totalmarks, obtainedmarks, marksType and studentId"
            });
        }

        if (!["Quiz", "Assignment", "Lab"].includes(marksType)) {
            return res.status(400).json({
                message: "marksType must be Quiz, Assignment or Lab"
            });
        }

        // Verify the target student exists before saving marks
        const student = await User.findById(studentId);
       
        if (!student) {
            return res.status(404).json({ message: "Student not found" });
        }

        const data = await Marks.create({
            totalmarks,
            obtainedmarks,
            marksType,
            user: studentId   // ✅ Correctly linked to the student, not the admin
        });
 
        res.status(201).json({
            message: "Marks added successfully",
            data
        });

    } catch (e) {
        
        res.status(500).json({ message: `Error1: ${e.message}` });
    }
});

StudentRouter.get('/student', Authentication, async (req, res) => {
    try {
        const marks = await Marks.find({ user: req.user._id })
                                 .sort({ createdAt: -1 });

        res.status(200).json({
            message: "Marks fetched successfully",
            data: marks
        });
    } catch (e) {
        res.status(500).json({ message: `Error: ${e.message}` });
    }
});

export default StudentRouter;