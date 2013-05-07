# ActiveFile (Gem under construction)
[![Gem Version](https://badge.fury.io/rb/activefile.png)](http://badge.fury.io/rb/activefile)


ActiveFile is a lightweight file system ORM.

Build a persistent domain model by mapping file system objects to Ruby classes. It inherits ActiveRecord-similar interface.

## Usage

Define a `Shop` model. Inherit from `ActiveFile::Base`.
`parent_to` is an alias to ActiveRecord `has_many` association.

    class Shop < ActiveFile::Base
      parent_to :product
    end

Okay, we have a shop which is a **parent** to products. Let's define a `Product`:

    class Product < ActiveFile::Base
      child_of :shop
    end

From now, add some logic in your controller.
At first, create a shop. `name` is a **important** attribute for every file object:

    shop = Shop.new(:name => "Apple Store")
    shop.save!

Check the sum of shops:

    Shop.all.size  #> 1

Next, create some `product`, and define it as a child of our `shop`

    iPad = Product.new(:name => "iPad", :parent => shop, :data => "The iPad is a line of tablet computers designed and marketed by Apple Inc., which runs Apple's iOS operating system.")
    iPad.save!

Oh, iPad is a great product, ok. Note, that we defined the product file content with `data` attribute.
Let's see what we can do now:

    product = Product.where(:name => "iPad")[0]
    product.data  #>  "The iPad "...
    product.shop  #>  <Shop instance>
    product.shop.name  #> "Apple Store"

In result, two persistent files were created, accessible via ORM mechanism.

## Installation

Add this line to your application's Gemfile:

    gem 'activefile'

And then execute:

    $ bundle

## Credits


## Changelog

**all versions before `1.0.0` future version are Development contributions, and can't be used.**
