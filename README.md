# Haml::I18n::Extractor

Extract strings likely to be translated from haml into locale file

## Usage

After installing this gem, you can run the binary in a rails app:

`cd your-rails-app; haml-i18n-extractor .`

## Notes

Right now the design works on a per-file basis:

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

This is pretty much beta - but it does work! Since it is beta, it does not overwrite anything but lets you decide what you want, and don't want.

The workflow at the moment is, to run the binary, then do a `git diff` and see all the changes. 

What you should be seeing for a "foo.haml" file is a dumped version "foo.i18n-extractor.haml" file which has the temporary representation of the file it tried to translate. It also dumps the corresponding i18n locale .yml file for the haml just translated in the current working directory, suffixed with the path of the haml file it was working on.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
