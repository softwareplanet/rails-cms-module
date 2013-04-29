What is ActiveFile?
-------------------

[![Gem Version](https://badge.fury.io/rb/activefile.png)](http://badge.fury.io/rb/activefile)

ActiveFile is a lightweight file system ORM, specially designed and developed for softwareplanet-cms. It will be free and opensource soon.

ActiveFile build a persistent domain model by mapping file system objects to Ruby classes. It inherits ActiveRecord-similar interface.

## Definition

This is a neat example of ActiveFile power. You can define any file system objects in a ActiveRecord-way. All of them are file objects. No database needed:


```ruby
class Layout < ActiveFile::Base
  has_one :css
  has_one :seo_tag
end

class Content < ActiveFile::Base
  has_one :css
end

class Css < ActiveFile::Base
  belongs_to :layout
  belongs_to :content
  file_path "app/assets/stylesheets"
end

class SeoTag < ActiveFile::Base
  belongs_to :layout
end
```


How to use the ActiveFile methods and their associations?
---------------------------------------------------------

This is another example, with methods describing. Look RDoc for ActiveFile fore more details.

Define a `Shop` model. Inherit from `ActiveFile::Base`.
`parent_to` is an alias to ActiveRecord `has_many` association.

    class Shop < ActiveFile::Base
      has_many :products
    end

Okay, we have a shop which is a **parent** to products. Let's define a `Product`:

    class Product < ActiveFile::Base
      belong_to :shop
    end

From now, add some logic in your controller.
At first, create a shop. `name` is a **important** attribute for every file object:

    shop = Shop.new(:name => "Apple Store")
    shop.save!

Check the sum of shops:

    Shop.all.size  #> 1

Next, create some `product`, and define it as a child of our `shop`

    iPad = Product.new(:name => "iPad", :shop => shop, :data => "The iPad is a line of tablet computers designed and marketed by Apple Inc., which runs Apple's iOS operating system.")
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