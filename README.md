# Haml::I18n::Extractor

Extract strings likely to be translated from haml templates for I18n translation. Replace the text, create yaml files, do all things you thought macros would solve, but didn't end up really saving THAT much time. Automate that pain away.

## Installation 

`gem install haml-i18n-extractor`

However I don't upload gems to rubygems in my spare time, so if you want the latest code edge style, you can also simply clone this repo and install the gem from the root of the repo:

`gem uninstall -x haml-i18n-extractor; rm *gem; gem build *gemspec; gem install --local *gem`


## Usage

- You can use the lib directly: 

<pre>
begin
  @ex1 = Haml::I18n::Extractor.new(haml_path)
  @ex1.run
rescue Haml::I18n::Extractor::InvalidSyntax
  puts "There was an error with #{haml_path}"
rescue Haml::I18n::Extractor::NothingToTranslate
  puts "Nothing to translate for #{haml_path}"
end  
</pre>

- You can also simply run the binary provided with the gem on a rails app:

`cd your-rails-app-to-translate && haml-i18n-extractor .` 

The workflow is an interactive one using highline which will allow you to choose if you want to:

1) overwrite the haml file.
2) place a tmp haml file.
3) pass, move on to the next haml file.

Run the binary and see!

## Example output

This should be a before and after picture of using this lib, whether directly in rubyland or using the executable:

- Before running (old haml):

<pre>
  shai@comp ~/p/project ‹master*› » cat app/views/admin/notifications/index.html.haml
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
        %th.last &nbsp;
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

Note how some of the strings are replaced, and the ones that shouldn't, aren't. Yup. Beautiful, right?

Haml:

<pre>
  shai@comp ~/p/project ‹master*› » cat app/views/admin/notifications/index.html.i18n-extractor.haml 
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
        %th.last= t('.nbsp;')
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
  shai@comp ~/p/project ‹master*› » cat notifications.index.html.haml.yml  
  --- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  en: !ruby/hash:ActiveSupport::HashWithIndifferentAccess
    notifications: !ruby/hash:ActiveSupport::HashWithIndifferentAccess
      consumer_notifications: Consumer Notifications
      type: Type
      identifier: Identifier
      data: Data
      success: Success
      reported_to: Reported To
      nbsp;: ! '&nbsp;'
</pre>

## Feedback

Can use github issues to address any concern you have, or simply email me, with the contact info here: [http://shairosenfeld.com/](http://shairosenfeld.com/)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request