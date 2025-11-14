/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/views/**/*.{erb,html}",
    "./app/javascript/**/*.{js,jsx,ts,tsx}",
    "./app/helpers/**/*.rb",
    "./app/assets/stylesheets/**/*.{css,scss}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}

