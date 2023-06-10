module.exports = {
  content: ['./../{{ cookiecutter.project_slug }}/**/*.html'],
  theme: {
    fontFamily: {
      'sans': ['Roboto', 'sans-serif'],
      'title': ['Oswald', 'sans-serif']
    }
  },
  variants: {
    extend: {},
  },
  plugins: [
    require('@tailwindcss/typography'),
  ],
}
