# awesome_notifications_assignment

The program made for this assignment is a game break reminder application made using Flutter, Firebase, and Awesome Notifications.

Firebase is used as the cloud database, shared_preferences for local persistence, and awesome_notifications for scheduling and delivering notifications. On startup, Firebase is initialised and notification permissions are granted. A notification channel is defined for break reminders, and the app retrieves the count of gaming sessions from Firestore or local storage. When user starts session, break notification is scheduled using current time and specified session duration.

The UI uses neon blue over a dark background as the theme to make it appear futuristic and appealing to gamers. The main screen displays the number of sessions completed, user input for gaming session duration, and button to start session. When session starts, it schedules future notification and increments session count locally and remotely. The notification is customised visually and includes wake-up feature to ensure visibility.

<img width="1312" alt="image" src="https://github.com/user-attachments/assets/2192e34d-df3b-4ff9-860e-750de4a61331" />

<img width="1312" alt="image" src="https://github.com/user-attachments/assets/72c30ada-1212-42fb-b538-c13d1a55660e" />
