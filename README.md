![Cms Window](https://softwareplanetgroup.co.uk/static/img/softwareplanet_group@2x.svg/ "Software Planet Group Ltd.")

# Rails CMS module

## Project description

Very often, we require static content for our Ruby on Rails SaaS web services. The most simple and straightforward way to achieve this is to enable a Rails view for multiple pages (including the landing page, About Us, Contact Us and Privacy Policy). This works well at the very beginning, but as soon as any changes — even small ones — are called for, an extraordinary amount of effort is then suddenly required. In such cases, you can either make use of WordPress or Drupal, or find another CMS system that is capable of performing the migration — suitable Rails CMSes are notoriously difficult to encounter. This is where Rails CMS module comes exceedingly in useful, as it consists of a custom plugin that can easily be configured for static content management and conveniently added to your company’s existing projects.

![Code editor](https://github.com/softwareplanet/cms/blob/master/doc/code.png?raw=true "Code editor")

* Rails CMS module suspect that you familiar with [HAML](http://haml.info/). Alternatively, you can use [converter](http://html2haml.heroku.com/).
* Rails CMS module advise you to explore the [Bootstrap](http://twitter.github.io/bootstrap/)

![Image gallery](https://github.com/softwareplanet/cms/blob/master/doc/gallery.png?raw=true "Image gallery")

## Languages support

Rails CMS module is distributed with two administrative locals: en and ru.
Language selector for site guests can be expanded with any number of languages.

## Installation

[This guide](http://htmlpreview.github.io/?https://raw.github.com/softwareplanet/rails-cms-module/master/guide/compiled/setup.html)
describes the setup process.

In brief, you should not forget to run this two commands with terminal inside your project root path:

- add rails cms module gem folder to your project root path
- add to your Gemfile:

```ruby
gem 'softwareplanet-cms', :path => './cms/softwareplanet-cms'
```
- run `bundle` command
- run `rake cms:wizard` rake command to finish setup.

If you clone from github, you will get the folder with dummy application that included `softwareplanet-cms` cms 
folder inside. It is already configured, and you can run it after both bundle and rake commands listed above.
If you need real gem using, move the `softwareplanet-cms` folder into your project root, and change the `path` for new gem folder.

## Contributing

[This guide](http://htmlpreview.github.io/?https://raw.github.com/softwareplanet/rails-cms-module/master/guide/compiled/contributing.html)
describes the contributing to the Rails CMS module.

## Technologies of Implementation

* Ruby on Rails https://rubyonrails.org/
* MySQL database https://www.mysql.com/

## Customer & developer Information

* Customer: Cubex Software Ltd http://cubexsoftware.com/
* Developer: Software Planet Group Ltd https://softwareplanetgroup.co.uk/
