# RogerThemes

Create themes and release them as static site.

## Themes setup

Your themes live in the themes dir, it will release all pages for your themes
into the theme dir.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'roger_themes'
```

And then execute:

    $ bundle


## Todo

- Add tests
- Complete documentation (especially on how themes work by default)
- Add theme selector views for usage in table of content

## Usage

Include the middleware and processor in the `serve` and `release` block:

```
mockup.serve do |s|
    s.use RogerThemes::Middleware
    # ...
end
```

```
mockup.release do |r|
    # ..
    r.use :themes

    # Finalise your zips for XC
    r.finalize RogerThemes::XcFinalizer
```

## Changelog

### v0.4.0

* Resolve issue around shared paths (#1)

### v0.1.2

* Fix dir merging when a local folder exists

### v0.1.1

* Update processor

### v0.1.0

* `:shared_folders` now also takes a hash to enable nested theme folders
  ```
    {
        shared_folders: {"images" => "rel/images"}
    }
  ```
* Remove `rel` from shared_folders

### v0.0.1 (never released)

* Initial release

## Contributing

1. Fork it ( https://github.com/digitpaint/roger_themes/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
