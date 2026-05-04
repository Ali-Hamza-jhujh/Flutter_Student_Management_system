
const isAdmin = (req, res, next) => {
    console.log('isAdmin check, req.user:', req.user); 
    if (req.user && req.user.role === "admin") {
        next(); 
    } else {
        res.status(403).json({ message: "Access denied. Admins only." });
    }
};

export default isAdmin;