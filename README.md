# jekyll-action-ts

A GitHub Action to build and publish Jekyll sites to GitHub Pages

Out-of-the-box Jekyll with GitHub Pages allows you to leverage a limited, white-listed, set of gems. Complex sites requiring custom ones or non white-listed ones (AsciiDoc for instance) used to require a continuous integration build in order to pre-process the site.

## About this version

Originated from [helaili/jekyll-action](https://github.com/helaili/jekyll-action), however this has been converted from a Docker action to a typescript/js action to cut down on the Docker initialisation time, as well as to use [ruby/setup-ruby](https://github.com/ruby/setup-ruby) to automatically select bundler version.

V2 of this action removes the `git push` step from this action (basically only building the site and updating bundle dependencies), and instead uses [peaceiris/actions-gh-pages](https://github.com/peaceiris/actions-gh-pages) for more flexibility (you can choose the committer, the repository, etc.). You can also choose to deploy to AWS, Google Cloud, Azure, or wherever else you wish to by removing the gh-pages action. (However I don't have any experience doing that, so you have to experiment at your own risk)

This can also automatically find a `Gemfile` if it isn't in the root directory, and in the case of multiple Gemfiles find the one in the same directory as `_config.yml`. This can be helpful in cases where you have a `docs` folder containing a website inside a ruby project which has a Gemfile by itself.

It also automatically caches the vendor/bundle directory for faster build times, by setting the `enable_cache` input to true in the workflow file. This is preferred over [actions/cache](https://github.com/actions/cache) (for now) since it decreases the time needed to find the Jekyll source and Gemfile.

Additionally, it uses [prettier](prettier.io/) to format the output HTML so it is more readable (since jekyll is known to output [excessive newlines due to liquid](https://github.com/jekyll/jekyll-help/issues/193)). Prettier options can be specified through the `prettier_opts` input.

## Official jekyll tutorial

V2 of this action completely differs from the official jekyll tutorial. However, I probably don't have time to write a full guide.

If you prefer to follow the official [jekyll docs](https://jekyllrb.com/docs/continuous-integration/github-actions/), just use this [sample workflow file](#use-the-action) rather than they one they provide

## Usage

### Create a Jekyll site

If you repo doesn't already have one, create a new Jekyll site: `jekyll new sample-site`. See [the Jekyll website](https://jekyllrb.com/) for more information. In this repo, we have created a site within a `sample_site` folder within the repository because the repository's main goal is not to be a website. If it was the case, we would have created the site at the root of the repository.

### Create a `Gemfile`

As you are using this action to leverage specific Gems, well, you need to declare them! In the sample below we are using [the Jekyll AsciiDoc plugin](https://github.com/asciidoctor/jekyll-asciidoc)

```Ruby

source 'https://rubygems.org'

gem 'jekyll', '~> 3.8.5'
gem 'coderay', '~> 1.1.0'

group :jekyll_plugins do
  gem 'jekyll-asciidoc', '~> 2.1.1'
end

```

### Configure your Jekyll site

Edit the configuration file of your Jekyll site (`_config.yml`) to leverage these plugins. In our sample, we want to leverage AsciiDoc so we added the following section:

```yaml
asciidoc: {}
asciidoctor:
  base_dir: :docdir
  safe: unsafe
  attributes:
    - idseparator=_
    - source-highlighter=coderay
    - icons=font
```

Note that we also renamed `index.html` to `index.adoc` and modified this file accordingly in order to leverage AsciiDoc.

### Use the action

Put the `workflow.yml` file below into `.github/workflows`. It can be copied from [here](https://github.com/limjh16/jekyll-action-ts/blob/master/.github/workflows/workflow.yml) as well. Do take some time to read through the comments to understand the different settings.

[`.github/workflows/workflow.yml`](https://github.com/limjh16/jekyll-action-ts/blob/master/.github/workflows/workflow.yml):

```yaml
name: Build and deploy jekyll site

on:
  push:
    branches:
      - master
      # - source
      # It is highly recommended that you only run this action on push to a
      # specific branch, eg. master or source (if on *.github.io repo)

jobs:
  jekyll:
    runs-on: ubuntu-16.04 # can change this to ubuntu-latest if you prefer
    steps:
      - name: 📂 setup
        uses: actions/checkout@v2

        # include the lines below if you are using jekyll-last-modified-at
        # or if you would otherwise need to fetch the full commit history
        # however this may be very slow for large repositories!
        # with:
        # fetch-depth: '0'
      - name: 💎 setup ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 2.6 # can change this to 2.7 or whatever version you prefer

      - name: 🔨 install dependencies & build site
        uses: limjh16/jekyll-action-ts@v2
        with:
          enable_cache: true
          ### Enables caching. Similar to https://github.com/actions/cache.
          #
          # format_output: true
          ### Uses prettier https://prettier.io to format jekyll output HTML.
          #
          # prettier_opts: '{ "useTabs": true }'
          ### Sets prettier options (in JSON) to format output HTML. For example, output tabs over spaces.
          ### Possible options are outlined in https://prettier.io/docs/en/options.html
          #
          # prettier_ignore: 'about/*'
          ### Ignore paths for prettier to not format those html files.
          ### Useful if the file is exceptionally large, so formatting it takes a while.
          ### Also useful if HTML compression is enabled for that file / formatting messes it up.
          #
          # jekyll_src: sample_site
          ### If the jekyll website source is not in root, specify the directory. (in this case, sample_site)
          ### By default, this is not required as the action searches for a _config.yml automatically.
          #
          # gem_src: sample_site
          ### By default, this is not required as the action searches for a _config.yml automatically.
          ### However, if there are multiple Gemfiles, the action may not be able to determine which to use.
          ### In that case, specify the directory. (in this case, sample_site)
          ###
          ### If jekyll_src is set, the action would automatically choose the Gemfile in jekyll_src.
          ### In that case this input may not be needed as well.
          #
          # key: ${{ runner.os }}-gems-${{ hashFiles('**/Gemfile.lock') }}
          # restore-keys: ${{ runner.os }}-gems-
          ### In cases where you want to specify the cache key, enable the above 2 inputs
          ### Follows the format here https://github.com/actions/cache
          #
          # custom_opts: '--drafts --future'
          ### If you need to specify any Jekyll build options, enable the above input
          ### Flags accepted can be found here https://jekyllrb.com/docs/configuration/options/#build-command-options

      - name: 🚀 deploy
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./_site
          # if the repo you are deploying to is <username>.github.io, uncomment the line below.
          # if you are including the line below, make sure your source files are NOT in the master branch:
          # publish_branch: master
```

Upon successful execution, the GitHub Pages publishing will happen automatically and will be listed on the _*environment*_ tab of your repository.

![image](https://user-images.githubusercontent.com/2787414/51083469-31e29700-171b-11e9-8f10-8c02dd485f83.png)

Just click on the _*View deployment*_ button of the `github-pages` environment to navigate to your GitHub Pages site.

![image](https://user-images.githubusercontent.com/2787414/51083411-188d1b00-171a-11e9-9a25-f8b06f33053e.png)
