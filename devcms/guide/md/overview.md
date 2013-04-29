RailsCms
==========================

This guide covers the setup process and using of RailsCMS engine, the OpenSource Rails project.

After reading this guide, you will know:

* How to setup RailsCms
* How to use admin mode to create web sites and populate it
* How to use programmed experience to improve the site strength
* How to use the ActiveFile methods and their associations

--------------------------------------------------------------------------------

Why RailsCms?
-------------

Rails CMS, specially developed and designed to effective site content management, and distributed service. Admin back-end allows to make changes to different types of participators:
language translators, front-end designers, ruby and javascript developers. RailsCms can be included at any stage of your project, like any other local gem. 
It will share own routes with your application, and add an admin mode, internatialization and many other features. It is OpenSource, and you can modify it.


What do I need for RailsCms?
----------------------------

It requires any type of ActiveRecord connection established in your project. It can be be mysql, sqlite.. Anything else. It needed to include 2 tables into your database. That's all you need for work. 
The RailsCms wizard script will setup and configure it automatically.

How to setup RailsCms?
----------------------

[This guide](setup.html) explain RailsCms setup process.

In brief, you should:

- add RailsCms gem folder to your project root path
- add to your Gemfile:

```ruby
gem 'railscms', :path => 'railscms'
```

- run `bundle` command
- run `rake cms:wizard` rake command to finish setup.

How to use admin mode to create web sites and populate it
---------------------------------------------------------

##### `Documentation for RailsCms UI coming soon`

How to use programmed experience to improve the site strength
-------------------------------------------------------------

RailsCms uses HAML and SCSS technologies.

-= RailsCms =-