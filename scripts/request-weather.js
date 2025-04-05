// ...existing code (if any)...
require('dotenv').config();

const zipcode = process.argv[2];
if (!zipcode) {
  console.error("Please provide a zipcode as argument.");
  process.exit(1);
}

const apiKey = process.env.OPENWEATHER_API_KEY;
if (!apiKey) {
  console.error("OPENWEATHER_API_KEY not defined in environment variables.");
  process.exit(1);
}

const url = `https://api.openweathermap.org/data/2.5/weather?zip=${zipcode},us&appid=${apiKey}&units=imperial`;

fetch(url)
  .then(response => {
    if (!response.ok) {
      throw new Error(`Failed to fetch weather: ${response.statusText}`);
    }
    return response.json();
  })
  .then(data => {
    console.log(`Weather Data for zipcode ${zipcode}:`);
    console.log(data);
  })
  .catch(error => {
    console.error("Error fetching weather data:", error.message);
  });
