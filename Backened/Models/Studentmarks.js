import mongoose from 'mongoose';
const { Schema } = mongoose;

const StudentSchema = new Schema({
  marksType: { type: String, enum: ["Quiz","Assignment","Lab"], required: true },
  totalmarks: { type: Number, required: true, min: 0 },
  obtainedmarks: { type: Number, required: true, min: 0 },
  user: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  percentage: { type: Number },
  grade: { type: String },
}, { timestamps: true });

StudentSchema.pre('save', async function() {
  this.percentage = parseFloat(((this.obtainedmarks / this.totalmarks) * 100).toFixed(2));
  const p = this.percentage;
  if (p >= 90)      this.grade = 'A+';
  else if (p >= 80) this.grade = 'A';
  else if (p >= 70) this.grade = 'B';
  else if (p >= 60) this.grade = 'C';
  else if (p >= 50) this.grade = 'D';
  else              this.grade = 'F';
});

export default mongoose.model('Marks', StudentSchema);