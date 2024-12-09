const db = require('../../../utils/firebase');

const User = {
  async createUser(userData) {
    const userRef = db.collection('users').doc(userData.email);
    await userRef.set({
      email: userData.email,
      passwordHash: userData.passwordHash,
      roles: userData.roles,
      createdAt: new Date(),
    });
    return { message: 'Usuario creado Correctamente' };
  },
  async getUserByEmail(email) {
    const userRef = db.collection('users').doc(email);
    const userDoc = await userRef.get();
    if (userDoc.exists) {
      return userDoc.data();
    }
    return null;
  },
};

module.exports = User;
