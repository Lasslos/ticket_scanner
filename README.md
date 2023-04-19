# ticket_scanner

An App designed to scan and validate tickets on multiple devices using the ticket's QR-Code and a local network.

Instructions:
1. Generate the tickets with the QR-Codes and save the json file with the data in server/Resources/tickets.json.
2. Connect all devices on a local network. (Ensure that only devices scanning the tickets are able to connect to the server and that all clients are trustworthy! The network should not be accessible from outside the local network.) 
3. Launch the server in python.
4. Open the app for scanning the barcodes. Go to settings and set the server to the address the server is running on.
5. Scanning should now be possible.

Troubleshooting:

**When scanning a QR code the scanning app shows a loading animation for a long time and does not return a result.**

- Ensure that the server's IP address is entered correctly.
- Try disabling mobile data connections on the client and/or server. It is important, that all requests are made through the local network.