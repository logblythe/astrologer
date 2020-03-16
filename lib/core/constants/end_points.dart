//const String baseUrl = "https://online-astro.azurewebsites.net/api";
//const String baseUrl = "http://43e46452.ngrok.io/api";
const String baseUrl = "http://193.37.152.233:8080/api";
//const String baseUrl = "http://10.6.1.47:8082/api";
//const String baseUrl = "http://127.0.0.1:8082/api";
//const String baseUrl = "http://192.168.138.1:8080/api";

const String login = "$baseUrl/user/login";
const String register = "$baseUrl/user/register";
const String askQuestionUrl = "$baseUrl/user/ask-question";
const String fetchAstrologersUrl = "$baseUrl/user/fetch-astrologers";
const String fetchQuestionPriceUrl = "$baseUrl/user/question-price";
const String uploadProfile = "$baseUrl/user/upload-profile-picture";

const List<String> country = [
  "Select One",
  "Nepal",
  "India",
  "China",
  "Australia"
];
