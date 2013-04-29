![Cms Window](http://softwareplanetpro.com/static/img/sp_logo.png?v=2e51f "SoftwarePlanet")

SoftwarePlanet CMS
==================

SoftwarePlanet CMS specially developed and designed to effective site content management and distributed maintenance.
Administrative mode provides configurable site source control, structure configuration, image gallery and components gallery, internationalization.
Editable frontend allows another person to contribute to your site content. They may be language translators, technical authors or designers.

![Code editor](https://github.com/softwareplanet/cms/blob/master/doc/code.png?raw=true "Code editor")

SoftwarePlanet CMS keeps the site sources in fragmented file objects, and accelerate the page building through background precompiling.

SoftwarePlanet CMS is distributed as a local ruby-gem, and can be included to existed Rails project.
It comprises all necessary libraries. Installation process is quite simple.
Installer checks your existing configuration automatically, and it is quite verbose.

* SoftwarePlanet CMS suspect that you familiar with [HAML](http://haml.info/). Alternatively, you can use [converter](http://html2haml.heroku.com/).
* SoftwarePlanet CMS advise you to explore the [Bootstrap](http://twitter.github.io/bootstrap/)

![Image gallery](https://github.com/softwareplanet/cms/blob/master/doc/gallery.png?raw=true "Image gallery")

### Installation

[This guide](http://htmlpreview.github.io/?https://raw.github.com/softwareplanet/cms/master/devcms/guide/compiled/setup.html)
describes the setup process.

In brief, you should:

- add softwareplanet-cms gem folder to your project root path
- add to your Gemfile:

```ruby
gem 'softwareplanet-cms', :path => 'softwareplanet-cms'
```
- run `bundle` command
- run `rake cms:wizard` rake command to finish setup.

### Contributing

[This guide](http://htmlpreview.github.io/?https://raw.github.com/softwareplanet/cms/master/devcms/guide/compiled/contributing.html)
describes the contributing to the softwareplanet-cms.