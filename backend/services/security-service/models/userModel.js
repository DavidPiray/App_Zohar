const { db } = require('../shared/utils/firebase');

const User = {
  async createUser(userData) {
    const userRef = db.collection('users').doc(userData.email);
    await userRef.set({
      email: userData.email,
      passwordHash: userData.passwordHash,
      roles: userData.roles,
      createdAt: new Date(),
    });
    return { message: 'Usuario creado Correctamente!' };
  },
  async getUserByEmail(email) {
    const userRef = db.collection('users').doc(email);
    const userDoc = await userRef.get();
    if (userDoc.exists) {
      return userDoc.data();
    }
    return null;
  },

  async updateUserPassword(email, newPasswordHash) {
    const userRef = db.collection('users').doc(email);
    const userDoc = await userRef.get();
    if (!userDoc.exists) {
      console.error('Usuario no encontrado');
      throw new Error('Usuario no encontrado');
    }
    await userRef.update({ passwordHash: newPasswordHash });
    return { message: 'Contraseña actualizada correctamente!' };
  },

};

module.exports = User;
