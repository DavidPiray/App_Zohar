const bcrypt = require('bcrypt');
bcrypt.hash('password123', 10, (err, hash) => {
    if (err) throw err;
    console.log(hash); // Copia este hash en el documento de Firebase
});
``
