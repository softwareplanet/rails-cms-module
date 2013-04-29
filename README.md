![Cms Window](http://softwareplanetpro.com/static/img/sp_logo.png?v=2e51f "SoftwarePlanet")

Software Planet CMS
==================

Software Planet CMS is designed as plugin which can be added to existing Rails application. 
We are not building CMS for content managers we are building flexible content management solution
for web developers. Software Planet CMS provides easy to use in place content editing and HAML based layouts/components.
Administrative UI provides content versioning, structure configuration, image gallery, component management, localization & internationalization.

![Cms Window](https://github.com/softwareplanet/cms/blob/master/doc/code.gif?raw=true "softwareplanet-cms")

Softwareplanet CMS keeps the site sources in fragmented file objects, and accelerate the page building through background precompiling.

Softwareplanet CMS is distributed as a local ruby-gem, and can be included to existed Rails project.
It comprises all necessary libraries. Installation process is quite simple.
Installer checks your existing configuration automatically, and it is quite verbose.

* Softwareplanet CMS suspect that you familiar with [HAML](http://haml.info/). Alternatively, you can use [converter](http://html2haml.heroku.com/).
* Softwareplanet CMS advise you to explore the [Bootstrap](http://twitter.github.io/bootstrap/)

![Cms Window](https://github.com/softwareplanet/cms/blob/master/doc/gallery.gif?raw=true "softwareplanet-cms")

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
