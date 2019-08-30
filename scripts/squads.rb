#!/usr/bin/env ruby

require 'yaml'

# Create a set of `<tr>/<td>` rows listing the members, with a common title spanning across all rows in the first column
#
# +----------+-----------------+-------------------+--------------------+
# | title    | members[0].name | members[0].github | members[0].twitter |
# |          | members[1].name | members[1].github | members[1].twitter |
# |          | members[2].name | members[2].github | members[2].twitter |
# +----------+-----------------+-------------------+--------------------+
def row_with_members(title, members)
  span_row = "<td rowspan='#{members.count}' valign='top'>#{title}</td>"
  members_rows = members.map do |user|
    github = user['github'].nil? ? '' : "<a href='https://github.com/#{user['github'].strip}'>@#{user['github'].strip}</a>"
    twitter = user['twitter'].nil? ? '' : "<a href='https://twitter.com/#{user['twitter'].strip}'>@#{user['twitter'].strip}</a>"
    "<td>#{user['name']}</td><td>#{github}</td><td>#{twitter}</td>"
  end
  members_rows[0] = span_row + "\n      " + members_rows[0] # First row also contains the first-column info <td>, spanning N rows
  return members_rows.map { |row| "  <tr>#{row}</tr>" }.join("\n    ")
end

# Create a table using the rows_data. `title` is first column's title; title_block tells how to compute the text for first column entries
def html_table(title, rows_data, &title_block)
  rows = rows_data.map do |role|
    row_with_members(title_block.call(role), role['members'])
  end

  <<~TABLE
    <!--
      DO NOT EDIT MANUALLY: This table has been auto-generated.
      TO UPDATE THIS TABLE:
       - update scripts/squads.yml
       - run `scripts/squads.rb` to update the `README.md` sections
    -->

    <table>
      <thead><th>#{title}</th><th>Engineer</th><th>GitHub</th><th>Twitter</th></thead>
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

# Update the README
readme_file = File.expand_path('../README.md', File.dirname(__FILE__))
content = File.read(readme_file)
content.gsub!(/(\<\!-- begin:roles -->)(?:.*)(\<!-- end:roles -->)/m, "\\1\n#{roles_table}\\2")
content.gsub!(/(\<\!-- begin:squads -->)(?:.*)(\<!-- end:squads -->)/m, "\\1\n#{squads_table}\\2")
File.write(readme_file, content)

puts "README.md file updated from the content of scripts/squads.yml"
