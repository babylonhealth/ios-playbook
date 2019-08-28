#!/usr/bin/env ruby

require 'yaml'
require 'fileutils'

# Create a set of `<tr>/<td>` rows listing the members, with a common title spanning across all rows in the first column
#
# +----------+-----------------+-------------------+--------------------+
# | title    | members[0].name | members[0].github | members[0].twitter |
# |          | members[1].name | members[1].github | members[1].twitter |
# |          | members[2].name | members[2].github | members[2].twitter |
# +----------+-----------------+-------------------+--------------------+
def row_with_members(title, members)
  span_row = "<td rowspan='#{members.count}' valign='top'>#{title}</td>"
  members_rows = members.map do |dev|
    github = dev['github'].nil? ? '' : "<a href='https://github.com/#{dev['github'].strip}'>@#{dev['github'].strip}</a>"
    twitter = dev['twitter'].nil? ? '' : "<a href='https://twitter.com/#{dev['twitter'].strip}'>@#{dev['twitter'].strip}</a>"
    "<td>#{dev['name']}</td><td>#{github}</td><td>#{twitter}</td>"
  end
  members_rows[0] = span_row + "\n      " + members_rows[0] # First row also contains the squad info <td>, spanning N rows
  return members_rows.map { |row| "  <tr>#{row}</tr>" }.join("\n    ")
end

# Create a table using the data. `title` is first column's title; title_block tells how to compute the text for first column entries
def html_table(title, data, &title_block)
  rows = data.map do |role|
    row_with_members(title_block.call(role), role['members'])
  end
  <<~TABLE
    <!--
      DO NOT EDIT MANUALLY: This table has been generated from scripts/squads.yml
      TO UPDATE THIS TABLE:
       - update scripts/squads.yml
       - run `scripts/squad.rb --update` to update the `README.md` section
       - (alternatively, `scripts/squad.rb` without `--update` lets you copy/paste the HTML yourself)
    -->

    <table>
      <thead><th>#{title}</th><th>Person</th><th>GitHub</th><th>Twitter</th></thead>
      #{rows.join("\n  ")}
    </table>
  TABLE
end



### Main ###

yaml_path = File.expand_path('squads.yml', File.dirname(__FILE__))
team = YAML.load_file(yaml_path)

# Generate HTML
roles_table = html_table('Role', team['roles']) do |role|
  "<strong>#{role['name']}</strong>"
end

squads_table = html_table('Squad', team['squads']) do |squad|
  "<strong>#{squad['name']}</strong><br/>#{squad['desc']}"
end

html = <<~HTML
  We're organised in Squads. Each squad can be composed of iOS, Android and QA Engineers, as well as Designers and a Delivery Manager, all working on the same part of the app.

  Some of the roles are transverse to all the squads:

  #{roles_table.chomp}

  The rest of the iOS Engineers work in the following squads:

  #{squads_table.chomp}
HTML


# Update the README
#
if ARGV.first == '--update'
  # If we use `--update`, read the original file line by line to replace the section between `## 1.` and `## 2.` with the generated html
  readme = File.expand_path('../README.md', File.dirname(__FILE__))
  tmp_file = File.expand_path('../README.md.bak', File.dirname(__FILE__))
  FileUtils.cp(readme, tmp_file)

  File.open(readme, 'w') do |f|
    in_team_section = false
    File.foreach(tmp_file) do |line|
      f.write(line) unless in_team_section
      if line =~ /\#\# 1\./
        in_team_section = true
        f.write("\n" + html + "\n")
      elsif line =~ /\#\# 2\./
        f.write(line)
        in_team_section = false
      end
    end
  end

  FileUtils.rm(tmp_file)
else
  # Otherwise, just output the HTML to stdout
  puts html
end
