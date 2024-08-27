# Hero's Gambit

**Hero's Gambit** is a turn-based strategy game where two players compete in real-time. The game is built with Flutter for the frontend and Node.js for the backend, utilizing WebSocket for real-time communication.

## Project Structure

- **Frontend**: Built with Flutter.
- **Backend**: Node.js with WebSocket for real-time communication.

## Links

- **Backend Server**: [https://heros-gambit-backend.onrender.com/](https://heros-gambit-backend.onrender.com/)
- **Frontend**: [https://magnificent-dango-e206c3.netlify.app/](https://magnificent-dango-e206c3.netlify.app/)

## Prerequisites

1. **Flutter**: Ensure Flutter is installed on your system. You can download it from [Flutter's official website](https://flutter.dev/docs/get-started/install).
2. **Node.js**: Ensure Node.js is installed. You can download it from [Node.js official website](https://nodejs.org/).

## Running the Project

### Backend

1. **Clone the Repository**

   ```bash
   git clone https://github.com/Dhanesh-Sawant/heros-gambit.git
   cd heros-gambit
Navigate to the Backend Directory

Assuming the backend code is in a subdirectory named backend:

bash
Copy code
cd backend
Install Dependencies

bash
Copy code
npm install
Start the Backend Server

bash
Copy code
node server.js
The server will be available at https://heros-gambit-backend.onrender.com/.

Frontend
Navigate to the Flutter Project Directory

If you are not already in the root directory of the Flutter project, navigate there:

bash
Copy code
cd ../frontend
Install Dependencies

bash
Copy code
flutter pub get
Run the Flutter App

bash
Copy code
flutter run -d chrome
This will start the Flutter app in development mode on your default web browser.

Starting the Game
Start the Backend Server: Ensure that the backend server is running as described in the "Running the Project" section.

Open the Game in a Browser: Go to https://magnificent-dango-e206c3.netlify.app/ in a web browser.

Two Players: Both players should open the frontend link in separate browsers. The game will initialize once both players are connected.

Additional Information
Frontend: The Flutter frontend communicates with the backend via WebSocket to update the game state in real-time.
Backend: The Node.js server manages game logic, player connections, and state synchronization.
Troubleshooting
Ensure that both the frontend and backend servers are running and accessible.
Check browser console and server logs for any errors if something is not working as expected.
Contributing
Feel free to fork the repository and submit pull requests with improvements or bug fixes. Please ensure that your changes are well-documented and tested.

License
This project is licensed under the MIT License - see the LICENSE file for details.
