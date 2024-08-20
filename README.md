API V2


**Prerequisites:**
- Node.js and npm installed on your system
- MongoDB server running locally or remotely

**Steps:**

1. **Clone the repository or create a new project directory:**
   ```
   mkdir contact-api
   cd contact-api
   ```

2. **Initialize a new Node.js project and install the required dependencies:**
   ```
   npm init -y
   npm install express mongoose body-parser morgan helmet
   ```

3. **Create a new file, e.g., `app.js`, and copy the provided code into it:**
   ```javascript
   const express = require('express');
   const mongoose = require('mongoose');
   const bodyParser = require('body-parser');
   const morgan = require('morgan');
   const helmet = require('helmet');

   const app = express();

   // Connect to MongoDB
   mongoose.connect('mongodb://localhost/contacts', {
     useNewUrlParser: true,
     useUnifiedTopology: true,
   });

   // Define Contact model
   const Contact = mongoose.model('Contact', {
     name: String,
     email: String,
     phone: String,
   });

   // Middleware
   app.use(bodyParser.json());
   app.use(morgan('dev'));
   app.use(helmet());

   // IP Blocker Middleware
   const blockedIPs = ['192.168.1.1', '10.0.0.1', '172.16.0.1'];

   const blockIPMiddleware = (req, res, next) => {
     const clientIP = req.connection.remoteAddress || req.socket.remoteAddress;
     if (blockedIPs.includes(clientIP)) {
       return res.status(403).json({ error: 'Forbidden' });
     }
     next();
   };

   app.use(blockIPMiddleware);

   // Access Control Middleware
   const whitelist = ['example1@example.com', 'example2@example.com', 'example3@example.com'];
   const blacklist = ['blocked1@example.com', 'blocked2@example.com', 'blocked3@example.com'];

   const checkAccessControl = (req, res, next) => {
     const { email } = req.body;

     if (blacklist.includes(email)) {
       return res.status(403).json({ error: 'Forbidden' });
     }

     if (whitelist.length > 0 && !whitelist.includes(email)) {
       return res.status(403).json({ error: 'Forbidden' });
     }

     next();
   };

   app.use(checkAccessControl);

   // API Endpoints
   app.get('/api/contacts', async (req, res) => {
     const contacts = await Contact.find();
     res.json(contacts);
   });

   app.get('/api/contacts/:id', async (req, res) => {
     const contact = await Contact.findById(req.params.id);
     if (!contact) {
       return res.status(404).json({ error: 'Contact not found' });
     }
     res.json(contact);
   });

   app.post('/api/contacts', async (req, res) => {
     const { name, email, phone } = req.body;
     const contact = new Contact({ name, email, phone });
     await contact.save();
     res.status(201).json(contact);
   });

   app.put('/api/contacts/:id', async (req, res) => {
     const { name, email, phone } = req.body;
     const contact = await Contact.findByIdAndUpdate(
       req.params.id,
       { name, email, phone },
       { new: true }
     );
     if (!contact) {
       return res.status(404).json({ error: 'Contact not found' });
     }
     res.json(contact);
   });

   app.delete('/api/contacts/:id', async (req, res) => {
     const contact = await Contact.findByIdAndDelete(req.params.id);
     if (!contact) {
       return res.status(404).json({ error: 'Contact not found' });
     }
     res.json({ message: 'Contact deleted' });
   });

   // Start the server
   app.listen(3000, () => {
     console.log('Server is running on port 3000');
   });
   ```

4. **Run the server:**
   ```
   node app.js
   ```

5. **Test the API endpoints:**
   - **Get all contacts**: `GET http://localhost:3000/api/contacts`
   - **Get a single contact**: `GET http://localhost:3000/api/contacts/CONTACT_ID`
   - **Create a new contact**: `POST http://localhost:3000/api/contacts`
     - Body: `{ "name": "John Doe", "email": "john@example.com", "phone": "1234567890" }`
   - **Update a contact**: `PUT http://localhost:3000/api/contacts/CONTACT_ID`
     - Body: `{ "name": "Jane Doe", "email": "jane@example.com", "phone": "0987654321" }`
   - **Delete a contact**: `DELETE http://localhost:3000/api/contacts/CONTACT_ID`

**Explanation of the functions:**

1. **Connect to MongoDB**: The code uses Mongoose to connect to a MongoDB database named `contacts`.

2. **Define Contact model**: The `Contact` model is defined using Mongoose, representing the structure of the contact data.

3. **Middleware setup**: The code sets up several middleware functions:
   - `bodyParser.json()`: Parses incoming JSON data in the request body.
   - `morgan('dev')`: Logs incoming requests to the console.
   - `helmet()`: Helps secure the Express app by setting various HTTP headers.
   - `blockIPMiddleware`: Checks the client's IP address against a list of blocked IPs and returns a 403 Forbidden response if the IP is found in the list.
   - `checkAccessControl`: Checks the `email` field in the request body against the `whitelist` and `blacklist` arrays, and returns a 403 Forbidden response if the email is found in the blacklist or is not in the whitelist (if the whitelist is not empty).

4. **API Endpoints**:
   - `GET /api/contacts`: Retrieves all contacts.
   - `GET /api/contacts/:id`: Retrieves a single contact by its ID.
   - `POST /api/contacts`: Creates a new contact.
   - `PUT /api/contacts/:id`: Updates an existing contact by its ID.
   - `DELETE /api/contacts/:id`: Deletes a contact by its ID.

The code uses Mongoose's asynchronous functions, such as `find()`, `findById()`, `save()`, `findByIdAndUpdate()`, and `findByIdAndDelete()`, to interact with the MongoDB database.

The IP blocker and access control mechanisms are applied to all the API endpoints through the middleware functions. If a request is blocked, the middleware functions will return a 403 Forbidden response.

Remember to customize the `blockedIPs`, `whitelist`, and `blacklist` arrays according to your specific requirements.
