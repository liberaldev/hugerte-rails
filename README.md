Rails Integration for TinyMCE
=============================

The `hugerte-rails` gem integrates the [HugeRTE](https://hugerte.org/) editor with the Rails asset pipeline.

This gem is compatible with Rails 6.0 and higher.

[![Build Status](https://img.shields.io/github/actions/workflow/status/liberaldev/hugerte-rails/rspec.yml)](https://github.com/liberaldev/hugerte-rails/actions)


Instructions
------------

**1. Add `hugerte-rails` to your Gemfile**

```ruby
gem 'hugerte-rails'
```

Be sure to add to the global group, not the `assets` group. Then run `bundle install`.


**2. Create a `config/hugerte.yml` file with your global configuration options:**

```yml
toolbar:
  - styleselect | bold italic | undo redo
  - image | link
plugins:
  - image
  - link
```

The Rails server no longer needs to be restarted when this file is updated in development mode.

To define multiple configuration sets, follow this syntax (a default configuration must be specified):

```yml
default: &default
  plugins:
    - image
    - link

alternate:
  <<: *default
  toolbar: styleselect | bold italic | undo redo | table
  plugins:
    - table
```

See the [TinyMCE 6 Documentation](https://www.tiny.cloud/docs/tinymce/6/) for a full list of configuration options.

**3. Include the TinyMCE assets**

Use *one* of the following options to include TinyMCE assets.

(1) Add to your application.js (Sprockets only):

```js
//= require hugerte
```

or (2) add the script tag to your layout using the `hugerte_assets` helper:

```erb
<%= hugerte_assets data: { turbo_track: "reload" } %>
#=> <script type="text/javascript" src="/assets/hugerte.js" data-turbo-track="reload">
```

When using Propshaft, the `hugerte_assets` helper adds multiple script tags including the pre-init code (available via the `hugerte_preinit` helper), as well as `hugerte/hugerte.js` and `hugerte/rails.js`. You may prefer to selectively include these manually depending on your requirements.

For Sprockets, these are bundled together into one script tag.


**4. Initialize TinyMCE**

For each textarea that you want to use with TinyMCE, add the "hugerte" class and ensure it has a unique ID:

```erb
<%= text_area_tag :content, "", class: "hugerte", rows: 40, cols: 120 %>
```

or if you are using Rails' form builders:

```erb
<%= f.text_area :content, class: "hugerte", rows: 40, cols: 120 %>
```

Then invoke the `hugerte` helper to initialize TinyMCE:

```erb
<%= hugerte %>
```

Custom options can be passed to `hugerte` to override the global options specified in `config/hugerte.yml`:

```erb
<%= hugerte theme: "simple", language: "de", plugins: ["wordcount", "paste"] %>
```

Alternate configurations defined in 'config/hugerte.yml' can be used with:

```erb
<%= hugerte :alternate %>
```


Language Packs
--------------

See the [liberaldev-rails-langs](https://github.com/liberaldev/hugerte-rails-langs) gem for additional language packs for HugeRTE.


Manual Initialization
---------------------

Using the `hugerte` helper and global configuration file is entirely optional. The `hugerte.init` JS function can be invoked manually if desired.

```erb
<%= text_area_tag :editor, "", rows: 40, cols: 120 %>

<script type="text/javascript">
  hugerte.init({
    selector: 'textarea.editor'
  });
</script>
```


Asset Compilation
-----------------

Since TinyMCE loads most of its files dynamically, some workarounds are required to ensure that the TinyMCE asset files are accessible using non-digested filenames.

As of hugerte-rails 3.5.11, 4.1.10 and 4.2.1, two alternative asset installation methods are available, which can be changed by setting `config.hugerte.install` within your `config/application.rb` file. These methods are called when you run `rake asset:precompile` (via `Rake::Task#enhance`) after the regular application assets are compiled.

The default method (as of 4.5.2), `compile`, adds the TinyMCE paths to the Sprockets precompilation paths and then creates symlinks from the non-digested filenames to their digested versions.

```ruby
config.hugerte.install = :compile
```

If you experience issues with the `compile` method, you may wish to use the `copy` method instead, which copies the TinyMCE assets directly into `public/assets` and appends the file information into the asset manifest. The `copy_no_preserve` method is also available of you do not wish to or cannot preserve file modes on your filesystem.

```ruby
config.hugerte.install = :copy
```

If you are including TinyMCE via `application.js` or using the `hugerte_assets` helper, you do not need to manually add the scripts to the Sprockets precompile paths.


Custom Plugins & Skins
----------------------

To use custom plugins or skins, simply add the files to your asset load path so that they are locatable at a path beneath `hugerte/plugins/` or `hugerte/skins/`.

For example, a plugin called `mycustomplugin` could have its main JS file at `app/assets/javascripts/hugerte/plugins/mycustomplugin/plugin.js`.

You should also ensure that your custom paths are added to the asset precompile paths.


Using hugerte-rails as an Engine Dependency
-------------------------------------------

Ensure that you explicitly require `hugerte-rails` within your engine file. Including hugerte-rails as a dependency in your gemspec is not enough.


Updating
--------

When new versions of TinyMCE are released, simply update the `hugerte-rails` gem to the latest version. There is no need to run any extra rake tasks (apart from `rake assets:precompile`).
