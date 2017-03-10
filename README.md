# Haml::I18n::Extractor

*Update: please see https://github.com/COzero/haml-i18n-extractor for newer updates*

Extract strings likely to be translated from haml templates for I18n translation. Replace the text, create yaml files, do all things you thought macros would solve, but didn't end up really saving THAT much time. Automate that pain away.

# Use it over and over again

It doesn't translate already translated keys, or things it identfies that are not text. What this means is that you can run this library/executable against the same haml file(s) after you've already translated stuff, and it will only look at things you really need and not any prior stuff. Pretty great. Try it, and see.

## Usage

You can use the binary which has an interactive (prompting) and non-interactive mode included in this library. You should be able to use the code directly as a lib too.

## CLI usage
Run haml-i18n-extractor GLOB_PATH_TO_HAML_FILES [OPTIONS]

Options:

--interactive (Run in interactive mode)

--yaml-file (Specify path to yaml file)

--i18n-scope (Specify i18n scope (e.g. de for German))

--add-filename-prefix (See add filename prefix docs below)

--base-path (Absolute path to base dir containing HAML files - see add filename prefix docs)

## Add filename prefix
If you have a lot of views, putting all the locale config in one file will be overwhelming and increases the risk of naming clashes. In this case, it's preferable to set up your locale config files inside directories, e.g. config/locales/admin/products/en.yml

To achieve this, you need to specify two config variables:
--add-filename-prefix true
--base-path

e.g. haml-i18n-extractor . --add-filename-prefix true --base-path /Users/jeremynagel/dev/some-project/views/

Make sure that you use the absolute path for base-path and leave a trailing slash at the end otherwise the i18n tags will be missing a dot.

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

## Example output

This should be a before and after picture of using this lib, whether using the non-interactive/interactive mode. There are more examples in the tests where you can see more use cases being translated.

- Before running (old haml):

<pre>

shai@comp $ cat /tmp/foo.haml

= render :partial => "layouts/adminnav", :locals => {:account => nil }
.row
  .admin.span12
    %h1
      Billing Month
      = @billing_month.display_name

    %h3
      All Invoices Billable?
      %span{:style => (@billable_invoices == @active_invoices) ? "color: #090" : "color: #900"}
        = "#{@billable_invoices} out of #{@active_invoices}"
    %h3
      24 hours past end of billing month?
      %span{:style => (@billing_month.past_cutoff) ? "color: #090" : "color: #900"}
        = @billing_month.past_cutoff

    - if @billing_month.open?
      - if @billing_month.past_cutoff && (@billable_invoices == @active_invoices)
        = form_for @billing_month, :url => close_admin_billing_month_url(@billing_month), :method => "POST" do |f|
          = f.submit "Close This Month (cannot be undone)", :class => 'btn btn-primary'
      - else
        %p
          Billing Month cannot be closed yet.
      %p
        Closing the billing month will mark all the invoices as "Posted".
      %p
        After closing you will need to do a payment run to charge all the affected customers for the amounts due in posted invoices.
    - elsif @billing_month.closing?
      Month is currently closing (reload to check if it's done)
    - elsif @billing_month.closed?
      Month is closed
</pre>

- After running (new haml, new yaml):

running this:

`shai@comp /tmp $ haml-i18n-extractor foo.haml -n -y en.yml`

Should give you the below...

Note how some of the strings are replaced, and the ones that shouldn't, aren't. Yup. Beautiful, for 2 and half seconds of work, right?

<pre>

shai@comp $ cat /tmp/foo.haml

= render :partial => "layouts/adminnav", :locals => {:account => nil }
.row
  .admin.span12
    %h1
      = t('.billing_month')
      = @billing_month.display_name

    %h3
      = t('.all_invoices_billable')
      %span{:style => (@billable_invoices == @active_invoices) ? "color: #090" : "color: #900"}
        =t('.billable_invoices_out_of_activ', :billable_invoices => (@billable_invoices), :active_invoices => (@active_invoices))
    %h3
      = t('.24_hours_past_end_of_billing_m')
      %span{:style => (@billing_month.past_cutoff) ? "color: #090" : "color: #900"}
        = @billing_month.past_cutoff

    - if @billing_month.open?
      - if @billing_month.past_cutoff && (@billable_invoices == @active_invoices)
        = form_for @billing_month, :url => close_admin_billing_month_url(@billing_month), :method => "POST" do |f|
          = f.submit t('.close_this_month_cannot_be_und'), :class => 'btn btn-primary'
      - else
        %p
          = t('.billing_month_cannot_be_closed')
      %p
        = t('.closing_the_billing_month_will')
      %p
        = t('.after_closing_you_will_need_to')
    - elsif @billing_month.closing?
      = t('.month_is_currently_closing_rel')
    - elsif @billing_month.closed?
      = t('.month_is_closed')
</pre>

Yaml:

<pre>

shai@comp $ cat /tmp/en.yml

---
en:
  tmp:
    foo:
      billing_month: Billing Month
      all_invoices_billable: All Invoices Billable?
      billable_invoices_out_of_activ: ! ' "%{billable_invoices} out of %{active_invoices}"'
      24_hours_past_end_of_billing_m: 24 hours past end of billing month?
      billing_month_cannot_be_closed: Billing Month cannot be closed yet.
      closing_the_billing_month_will: Closing the billing month will mark all the
        invoices as "Posted".
      after_closing_you_will_need_to: After closing you will need to do a payment
        run to charge all the affected customers for the amounts due in posted invoices.
      month_is_currently_closing_rel: Month is currently closing (reload to check
        if it's done)
      month_is_closed: Month is closed
      close_this_month_cannot_be_und: Close This Month (cannot be undone)
</pre>


## Installation

`gem install haml-i18n-extractor`

If you want the latest code aka edge, you can also simply clone this repo and install the gem from the root of the repo:

`gem uninstall -x haml-i18n-extractor; rm *gem; gem build *gemspec; gem install --local *gem`

## Feedback

Can use github issues to address any concern you have, or simply email me, with the contact info here: [http://shairosenfeld.com/](http://shairosenfeld.com/).

You can also find me on twitter with the same username as my GH one.

## Have an idea or an issue?

Open an [issue](https://github.com/shaiguitar/haml-i18n-extractor/issues/new).
