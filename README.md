# Haml::I18n::Extractor

Extract strings likely to be translated from haml templates for I18n translation. Replace the text, create yaml files, do all things you thought macros would solve, but didn't end up really saving THAT much time. Automate that pain away.

# Use it over and over again

It doesn't translate already translated keys, or things it identfies that are not text. What this means is that you can run this library/executable against the same haml file(s) after you've already translated stuff, and it will only look at things you really need and not any prior stuff. Pretty great. Try it, and see.

## Usage

You can use the binary which has an interactive (prompting) and non-interactive mode included in this library. You should be able to use the code directly as a lib too.

## Examples

- Per file basis. You can use the lib directly in your code, as such:

<pre>
begin
  @ex1 = Haml::I18n::Extractor.new(haml_path)
  @ex1.run
rescue Haml::I18n::Extractor::InvalidSyntax
  puts "There was an error with #{haml_path}"
end
</pre>

- Per-project basis, with the binary. See demo below for usage of the binary.

`cd your-rails-app-to-translate && haml-i18n-extractor --help`

## Demo using interactive mode

The demo is pretty outdated at this point. I would take it off the readme, but heck, I'm lazy. If you want a brief bad version of some of the stuff it does, since that video is pretty old, see it here (your browser needs to support swf):

[Demo](http://shairosenfeld.com/haml-i18n-extractor-demo.swf)

## Example output

This should be a before and after picture of using this lib, whether using the non-interactive/interactive mode. There are more examples in the tests where you can see more use cases being translated.

- Before running (old haml):

<pre>
  shai@comp ~/p/project master $ cat app/views/admin/notifications/index.html.haml
  %h1 Consumer Notifications

  .nav= will_paginate(@consumer_notifications)
  %table.themed{cellspacing: 0}
    %thead
      %tr
        %th.first Type
        %th Identifier
        %th Data
        %th Success
        %th Reported To
    - @consumer_notifications.each do |cn|
      %tr
        %td.type= cn.notification.type
        %td.identifier= cn.notification.identifier
        %td.data= cn.notification.data
        %td.success= cn.success
        %td.reported_to= cn.reported_to
  .nav= will_paginate(@consumer_notifications)
</pre>

- After running (new haml, new yaml):

Note how some of the strings are replaced, and the ones that shouldn't, aren't. Yup. Beautiful, for 2 and half seconds of work, right?

Haml:

<pre>
  shai@comp ~/p/project master $ cat app/views/admin/notifications/index.html.i18n-extractor.haml 
  %h1= t('.consumer_notifications')

  .nav= will_paginate(@consumer_notifications)
  %table.themed{cellspacing: 0}
    %thead
      %tr
        %th.first= t('.type')
        %th= t('.identifier')
        %th= t('.data')
        %th= t('.success')
        %th= t('.reported_to')
    - @consumer_notifications.each do |cn|
      %tr
        %td.type= cn.notification.type
        %td.identifier= cn.notification.identifier
        %td.data= cn.notification.data
        %td.success= cn.success
        %td.reported_to= cn.reported_to
  .nav= will_paginate(@consumer_notifications)
</pre>

Yaml:

<pre>
  shai@comp ~/p/project master $ cat config/locales/en.yml
  ---
  en:
    notifications:
      consumer_notifications: Consumer Notifications
      type: Type
      identifier: Identifier
      data: Data
      success: Success
      reported_to: Reported To
</pre>


## Installation

`gem install haml-i18n-extractor`

If you want the latest code aka edge, you can also simply clone this repo and install the gem from the root of the repo:

`gem uninstall -x haml-i18n-extractor; rm *gem; gem build *gemspec; gem install --local *gem`

## Feedback

Can use github issues to address any concern you have, or simply email me, with the contact info here: [http://shairosenfeld.com/](http://shairosenfeld.com/). 

You can also find me on twitter with the same username as my GH one.

## Have an idea or an issue?

Open an [issue](https://github.com/shaiguitar/haml-i18n-extractor/issues/new). Feeling like giving back? Contribute!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
