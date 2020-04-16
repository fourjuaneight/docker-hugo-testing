# Hugo (Extended) + Testing

Docker image derived from Alpine Linux that includes [Hugo](https://gohugo.io/) and [PostCSS](https://github.com/postcss/postcss). Enables building Hugo-based static sites that may include [Hugo Pipes](https://gohugo.io/hugo-pipes/) as part of the workflow. Usable with Bitbucket Pipelines, Gitlab CI, and other automated deployment tools that support Docker.

Additionally, this image installs Chrome for headless testig via Cypress, Selenium, Puppeteer, Lighthouse, etc.

This image was made specifically for use on a particular type of project. It's meant to enable the use of Hugo Pipes and Sass.

## More

- [Contributing](https://github.com/fourjuaneight/docker-hugo-testing/blob/master/.github/CONTRIBUTING.md)
- [Code of Conduct](https://github.com/fourjuaneight/docker-hugo-testing/blob/master/CODE_OF_CONDUCT.md)
- [Get in touch](https://www.juanvillela.dev)