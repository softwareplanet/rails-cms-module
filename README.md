![Cms Window](http://softwareplanetpro.com/static/img/sp_logo.png?v=2e51f "SoftwarePlanet")

Software Planet CMS
==================

Software Planet CMS is designed as plugin which can be added to existing Rails application.
We are not building CMS for content managers we are building flexible content management solution
for web developers. Software Planet CMS provides easy to use in place content editing and HAML based layouts/components.
Administrative UI provides content versioning, structure configuration, image gallery, component management, localization & internationalization.

![Code editor](https://github.com/softwareplanet/cms/blob/master/doc/code.png?raw=true "Code editor")

SoftwarePlanet CMS keeps the site sources in fragmented file objects, and accelerate the page building through background precompiling.

SoftwarePlanet CMS is distributed as a local ruby-gem, and can be included to existed Rails project.
It comprises all necessary libraries. Installation process is quite simple.
Installer checks your existing configuration automatically, and it is quite verbose.

* SoftwarePlanet CMS suspect that you familiar with [HAML](http://haml.info/). Alternatively, you can use [converter](http://html2haml.heroku.com/).
* SoftwarePlanet CMS advise you to explore the [Bootstrap](http://twitter.github.io/bootstrap/)

![Image gallery](https://github.com/softwareplanet/cms/blob/master/doc/gallery.png?raw=true "Image gallery")

### Languages support

The SoftwarePlanet CMS is distributed with two administrative locals: en and ru.
Language selector for site guests can be expanded with any number of languages.

### Installation

[This guide](http://htmlpreview.github.io/?https://raw.github.com/softwareplanet/cms/master/softwareplanet-cms/guide/compiled/setup.html)
describes the setup process.

In brief, you should not forget to run this two commands with terminal inside your project root path:

- add softwareplanet-cms gem folder to your project root path
- add to your Gemfile:

```ruby
gem 'softwareplanet-cms', :path => 'softwareplanet-cms'
```
- run `bundle` command
- run `rake cms:wizard` rake command to finish setup.

If you clone from github, you will get the folder with dummy application that included `softwareplanet-cms` cms 
folder inside. It is already configured, and you can run it after both bundle and rake commands listed above.
If you need real gem using, move the `softwareplanet-cms` folder into your project root.

### Contributing

[This guide](http://htmlpreview.github.io/?https://raw.github.com/softwareplanet/cms/master/softwareplanet-cms/guide/compiled/contributing.html)
describes the contributing to the softwareplanet-cms.
