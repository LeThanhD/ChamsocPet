importScripts('https://www.gstatic.com/firebasejs/10.3.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.3.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyDuVUUmb9oT9NskpBLeHBOh6Gy4LHpzq5Y",
  authDomain: "chamsocpet.firebaseapp.com",
  projectId: "chamsocpet",
  messagingSenderId: "1082920654128",
  appId: "1:1082920654128:web:d5a94fb9fdbe1ae0af24f5"
});

const messaging = firebase.messaging();
