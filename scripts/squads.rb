#!/usr/bin/env ruby

require 'yaml'
require 'fileutils'

# Create a set of `<tr>/<td>` rows listing the members, with a common title spanning across all rows in the first column
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

# Creates the roles HTML table
def roles_table(roles)
  rows = roles.map do |role|
    title = "<strong>#{role['name']}</strong>"
    row_with_members(title, role['members'])
  end
  <<~TABLE
    <table>
      <thead><th>Role</th><th>Person</th><th>GitHub</th><th>Twitter</th></thead>
      #{rows.join("\n  ")}
    </table>
  TABLE
end

# Creates the squads HTML table
def squads_table(squads)
  rows = squads.map do |squad|
    title = "<strong>#{squad['name']}</strong><br/>#{squad['desc']}"
    row_with_members(title, squad['members'])
  end
  <<~TABLE
    <table>
      <thead><th>Squad</th><th>iOS Dev</th><th>GitHub</th><th>Twitter</th></thead>
      #{rows.join("\n  ")}
    </table>
  TABLE
end


### Main ###

yaml_path = File.expand_path('squads.yml', File.dirname(__FILE__))
team = YAML.load_file(yaml_path)

# HTML comment before each table
DO_NOT_EDIT_HEADER = <<~HEADER
    <!--
      DO NOT EDIT MANUALLY: This table has been generated from scripts/squads.yml
      TO UPDATE THIS TABLE:
       - update scripts/squads.yml
       - run `scripts/squad.rb --update` to update the `README.md` section
       - (alternatively, `scripts/squad.rb` without `--update` lets you copy/paste the HTML yourself)
    -->
HEADER

# Generated HTML
html = <<~HTML
  #{DO_NOT_EDIT_HEADER}
  #{roles_table(team['roles']).chomp}

  ----

  We're organised in Squads. Each squad is composed of iOS, Android and QA Engineers, and a Delivery Manager.

  The table below only list the squads in which our iOS Engineers take part, and only list the iOS developers in those respective squads.

  #{DO_NOT_EDIT_HEADER}
  #{squads_table(team['squads']).chomp}
HTML

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